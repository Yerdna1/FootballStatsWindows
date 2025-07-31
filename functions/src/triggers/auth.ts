import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import { logger } from "../utils/logger";
import { authService, UserRole } from "../utils/auth";

const db = admin.firestore();

/**
 * Trigger when a new user is created
 * Creates user profile and sets default permissions
 */
export const createUserRecord = functions.auth.user().onCreate(async (user) => {
  logger.info("Creating user record", { uid: user.uid, email: user.email });

  try {
    // Create user document in Firestore
    const userData = {
      uid: user.uid,
      email: user.email || "",
      display_name: user.displayName || user.email?.split("@")[0] || "User",
      photo_url: user.photoURL || null,
      created_at: admin.firestore.Timestamp.now(),
      last_login: admin.firestore.Timestamp.now(),
      preferences: {
        favorite_leagues: [],
        favorite_teams: [],
        notifications_enabled: true,
        language: "en",
        timezone: "UTC",
        theme: "auto",
      },
      is_active: true,
    };

    // Create user document
    await db.collection("users").doc(user.uid).set(userData);

    // Set default user permissions
    await authService.setUserPermissions(
      user.uid,
      UserRole.USER,
      undefined, // Use default permissions
      "system"
    );

    // Create welcome notification
    await db.collection("notifications").add({
      user_id: user.uid,
      title: "Welcome to Football Stats!",
      message: "Your account has been created successfully. Start exploring your favorite leagues and teams.",
      type: "info",
      data: {
        welcome: true,
        created_at: admin.firestore.Timestamp.now(),
      },
      read: false,
      created_at: admin.firestore.Timestamp.now(),
    });

    // Log user creation activity
    await logger.logUserActivity(
      user.uid,
      "user_created",
      "user",
      user.uid,
      {
        email: user.email,
        provider: user.providerData[0]?.providerId || "unknown",
        creation_method: "auth_trigger",
      }
    );

    logger.info("User record created successfully", { uid: user.uid });

  } catch (error) {
    logger.error("Failed to create user record", error as Error, { uid: user.uid });
    
    // Even if user document creation fails, we don't want to prevent
    // the user from being created in Firebase Auth, so we don't throw
    // Instead, we could create a retry mechanism or manual cleanup process
  }
});

/**
 * Trigger when a user is deleted
 * Cleans up all user-related data
 */
export const deleteUserData = functions.auth.user().onDelete(async (user) => {
  logger.info("Deleting user data", { uid: user.uid, email: user.email });

  try {
    const batch = db.batch();
    let deletedCount = 0;

    // Delete user document
    const userRef = db.collection("users").doc(user.uid);
    batch.delete(userRef);
    deletedCount++;

    // Delete user permissions
    const permissionsRef = db.collection("user_permissions").doc(user.uid);
    batch.delete(permissionsRef);
    deletedCount++;

    // Delete user favorites
    const favoritesSnapshot = await db.collection("user_favorites")
      .where("user_id", "==", user.uid)
      .get();

    favoritesSnapshot.docs.forEach(doc => {
      batch.delete(doc.ref);
      deletedCount++;
    });

    // Delete user notifications
    const notificationsSnapshot = await db.collection("notifications")
      .where("user_id", "==", user.uid)
      .get();

    notificationsSnapshot.docs.forEach(doc => {
      batch.delete(doc.ref);
      deletedCount++;
    });

    // Archive user activity logs instead of deleting (for audit purposes)
    const activityLogsSnapshot = await db.collection("activity_logs")
      .where("user_id", "==", user.uid)
      .get();

    activityLogsSnapshot.docs.forEach(doc => {
      batch.update(doc.ref, {
        user_deleted: true,
        user_deleted_at: admin.firestore.Timestamp.now(),
      });
    });

    // Commit all deletions
    await batch.commit();

    // Log final activity before user is fully deleted
    await db.collection("activity_logs").add({
      user_id: user.uid,
      action_type: "user_deleted",
      resource_type: "user",
      resource_id: user.uid,
      details: {
        email: user.email,
        deleted_records: deletedCount,
        deletion_method: "auth_trigger",
      },
      ip_address: null,
      user_agent: null,
      timestamp: admin.firestore.Timestamp.now(),
    });

    logger.info("User data deleted successfully", { 
      uid: user.uid, 
      deletedRecords: deletedCount 
    });

  } catch (error) {
    logger.error("Failed to delete user data", error as Error, { uid: user.uid });
    
    // Create an alert for manual cleanup if automatic deletion fails
    await db.collection("system_alerts").add({
      type: "user_deletion_failed",
      severity: "high",
      message: `Failed to delete data for user ${user.uid}`,
      details: {
        uid: user.uid,
        email: user.email,
        error: (error as Error).message,
      },
      created_at: admin.firestore.Timestamp.now(),
      resolved: false,
    });
  }
});

/**
 * Update user's last login timestamp when they sign in
 * This could be called from client-side or as a callable function
 */
export const updateLastLogin = functions.https.onCall(async (data, context) => {
  // Verify authentication
  if (!context.auth) {
    throw new functions.https.HttpsError(
      "unauthenticated",
      "Authentication required"
    );
  }

  const uid = context.auth.uid;

  try {
    // Update last login timestamp
    await db.collection("users").doc(uid).update({
      last_login: admin.firestore.Timestamp.now(),
    });

    // Log login activity
    await logger.logUserActivity(
      uid,
      "user_login",
      "user",
      uid,
      {
        login_method: "callable_function",
        timestamp: admin.firestore.Timestamp.now(),
      }
    );

    logger.info("User last login updated", { uid });

    return { success: true };

  } catch (error) {
    logger.error("Failed to update last login", error as Error, { uid });
    throw new functions.https.HttpsError(
      "internal",
      "Failed to update login timestamp"
    );
  }
});

/**
 * Handle user email verification
 */
export const onEmailVerified = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError(
      "unauthenticated",
      "Authentication required"
    );
  }

  const uid = context.auth.uid;

  try {
    // Update user verification status
    await db.collection("users").doc(uid).update({
      email_verified: true,
      email_verified_at: admin.firestore.Timestamp.now(),
    });

    // Send verification confirmation notification
    await db.collection("notifications").add({
      user_id: uid,
      title: "Email Verified!",
      message: "Your email address has been successfully verified.",
      type: "success",
      data: {
        verification: true,
      },
      read: false,
      created_at: admin.firestore.Timestamp.now(),
    });

    // Log verification activity
    await logger.logUserActivity(
      uid,
      "email_verified",
      "user",
      uid,
      {
        email: context.auth.token.email,
        verified_at: admin.firestore.Timestamp.now(),
      }
    );

    logger.info("User email verified", { uid });

    return { success: true };

  } catch (error) {
    logger.error("Failed to handle email verification", error as Error, { uid });
    throw new functions.https.HttpsError(
      "internal",
      "Failed to process email verification"
    );
  }
});

/**
 * Handle password reset completion
 */
export const onPasswordReset = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError(
      "unauthenticated",
      "Authentication required"
    );
  }

  const uid = context.auth.uid;

  try {
    // Log password reset activity
    await logger.logUserActivity(
      uid,
      "password_reset",
      "user",
      uid,
      {
        reset_method: "callable_function",
        timestamp: admin.firestore.Timestamp.now(),
      }
    );

    // Send password reset confirmation notification
    await db.collection("notifications").add({
      user_id: uid,
      title: "Password Reset Complete",
      message: "Your password has been successfully reset. If this wasn't you, please contact support immediately.",
      type: "info",
      data: {
        security: true,
        password_reset: true,
      },
      read: false,
      created_at: admin.firestore.Timestamp.now(),
    });

    logger.info("Password reset logged", { uid });

    return { success: true };

  } catch (error) {
    logger.error("Failed to handle password reset", error as Error, { uid });
    throw new functions.https.HttpsError(
      "internal",
      "Failed to process password reset"
    );
  }
});