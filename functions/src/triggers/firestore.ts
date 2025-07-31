import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import { logger } from "../utils/logger";

const db = admin.firestore();

/**
 * Trigger when user favorites change
 * Updates analytics and sends notifications
 */
export const onUserFavoriteChange = functions.firestore
  .document("user_favorites/{favoriteId}")
  .onWrite(async (change, context) => {
    const favoriteId = context.params.favoriteId;
    const before = change.before.data();
    const after = change.after.data();

    try {
      if (!before && after) {
        // New favorite added
        logger.info("New favorite added", {
          favoriteId,
          userId: after.user_id,
          type: after.type,
          entityId: after.entity_id,
        });

        // Log activity
        await logger.logUserActivity(
          after.user_id,
          "favorite_added",
          after.type,
          after.entity_id,
          {
            favorite_id: favoriteId,
            favorite_type: after.type,
          }
        );

        // Send notification for team favorites
        if (after.type === "team") {
          try {
            // Get team information
            const teamSnapshot = await db.collection("teams")
              .where("api_team_id", "==", parseInt(after.entity_id))
              .limit(1)
              .get();

            if (!teamSnapshot.empty) {
              const teamData = teamSnapshot.docs[0].data();
              
              await db.collection("notifications").add({
                user_id: after.user_id,
                title: "New Favorite Team Added!",
                message: `You're now following ${teamData.name}. You'll receive updates about their matches and performance.`,
                type: "info",
                data: {
                  favorite_type: "team",
                  team_id: after.entity_id,
                  team_name: teamData.name,
                },
                read: false,
                created_at: admin.firestore.Timestamp.now(),
              });
            }
          } catch (error) {
            logger.warn("Failed to send favorite team notification", {
              error: (error as Error).message,
              favoriteId,
            });
          }
        }

        // Update user analytics cache
        await updateUserFavoriteAnalytics(after.user_id);

      } else if (before && !after) {
        // Favorite removed
        logger.info("Favorite removed", {
          favoriteId,
          userId: before.user_id,
          type: before.type,
          entityId: before.entity_id,
        });

        // Log activity
        await logger.logUserActivity(
          before.user_id,
          "favorite_removed",
          before.type,
          before.entity_id,
          {
            favorite_id: favoriteId,
            favorite_type: before.type,
          }
        );

        // Update user analytics cache
        await updateUserFavoriteAnalytics(before.user_id);

      } else if (before && after) {
        // Favorite updated (shouldn't happen often)
        logger.info("Favorite updated", {
          favoriteId,
          userId: after.user_id,
        });

        // Log activity
        await logger.logUserActivity(
          after.user_id,
          "favorite_updated",
          after.type,
          after.entity_id,
          {
            favorite_id: favoriteId,
            changes: {
              before: { type: before.type, entity_id: before.entity_id },
              after: { type: after.type, entity_id: after.entity_id },
            },
          }
        );
      }

    } catch (error) {
      logger.error("Error processing favorite change", error as Error, {
        favoriteId,
        userId: after?.user_id || before?.user_id,
      });
    }
  });

/**
 * Update user favorite analytics
 */
async function updateUserFavoriteAnalytics(userId: string): Promise<void> {
  try {
    // Count user's favorites by type
    const [teamsSnapshot, leaguesSnapshot] = await Promise.all([
      db.collection("user_favorites")
        .where("user_id", "==", userId)
        .where("type", "==", "team")
        .count()
        .get(),
      db.collection("user_favorites")
        .where("user_id", "==", userId)
        .where("type", "==", "league")
        .count()
        .get(),
    ]);

    const analytics = {
      user_id: userId,
      favorite_teams_count: teamsSnapshot.data().count,
      favorite_leagues_count: leaguesSnapshot.data().count,
      last_updated: admin.firestore.Timestamp.now(),
    };

    // Store in analytics cache
    await db.collection("analytics_cache").doc(`user_favorites_${userId}`).set({
      cache_key: `user_favorites_${userId}`,
      data: analytics,
      expires_at: admin.firestore.Timestamp.fromDate(
        new Date(Date.now() + 24 * 60 * 60 * 1000) // 24 hours
      ),
      created_at: admin.firestore.Timestamp.now(),
    });

  } catch (error) {
    logger.error("Failed to update user favorite analytics", error as Error, { userId });
  }
}

/**
 * Trigger when a notification is created
 * Could be used to send push notifications via FCM
 */
export const onNotificationCreated = functions.firestore
  .document("notifications/{notificationId}")
  .onCreate(async (snap, context) => {
    const notificationId = context.params.notificationId;
    const notification = snap.data();

    try {
      logger.info("New notification created", {
        notificationId,
        userId: notification.user_id,
        type: notification.type,
        title: notification.title,
      });

      // Here you could integrate with FCM to send push notifications
      // For now, we'll just log the activity
      
      await logger.logUserActivity(
        notification.user_id,
        "notification_received",
        "notification",
        notificationId,
        {
          notification_type: notification.type,
          title: notification.title,
          auto_generated: true,
        }
      );

      // Could implement FCM logic here:
      /*
      const message = {
        notification: {
          title: notification.title,
          body: notification.message,
        },
        data: notification.data || {},
        token: userFCMToken, // Would need to get this from user document
      };
      
      await admin.messaging().send(message);
      */

    } catch (error) {
      logger.error("Error processing new notification", error as Error, {
        notificationId,
        userId: notification.user_id,
      });
    }
  });

/**
 * Trigger when user profile is updated
 */
export const onUserProfileUpdate = functions.firestore
  .document("users/{userId}")
  .onUpdate(async (change, context) => {
    const userId = context.params.userId;
    const before = change.before.data();
    const after = change.after.data();

    try {
      // Track what fields were changed
      const changedFields: string[] = [];
      const changes: Record<string, { before: any; after: any }> = {};

      Object.keys(after).forEach(key => {
        if (JSON.stringify(before[key]) !== JSON.stringify(after[key])) {
          changedFields.push(key);
          changes[key] = {
            before: before[key],
            after: after[key],
          };
        }
      });

      if (changedFields.length > 0) {
        logger.info("User profile updated", {
          userId,
          changedFields,
        });

        // Log profile update activity
        await logger.logUserActivity(
          userId,
          "profile_updated",
          "user",
          userId,
          {
            changed_fields: changedFields,
            changes: changes,
          }
        );

        // Send notification for significant changes
        const significantFields = ["email", "display_name"];
        const significantChanges = changedFields.filter(field => 
          significantFields.includes(field)
        );

        if (significantChanges.length > 0) {
          await db.collection("notifications").add({
            user_id: userId,
            title: "Profile Updated",
            message: `Your profile information has been updated: ${significantChanges.join(", ")}.`,
            type: "info",
            data: {
              profile_update: true,
              changed_fields: significantChanges,
            },
            read: false,
            created_at: admin.firestore.Timestamp.now(),
          });
        }
      }

    } catch (error) {
      logger.error("Error processing user profile update", error as Error, { userId });
    }
  });

/**
 * Trigger when a team's statistics are updated
 * Could trigger notifications for users following that team
 */
export const onTeamStatisticsUpdate = functions.firestore
  .document("team_statistics/{statsId}")
  .onWrite(async (change, context) => {
    const statsId = context.params.statsId;
    const after = change.after.data();

    if (!after) return; // Document deleted

    try {
      const teamId = after.team_id;
      
      // Find users who have this team as a favorite
      const favoritesSnapshot = await db.collection("user_favorites")
        .where("type", "==", "team")
        .where("entity_id", "==", teamId)
        .get();

      if (favoritesSnapshot.empty) return;

      // Get team information
      const teamSnapshot = await db.collection("teams")
        .where("api_team_id", "==", parseInt(teamId))
        .limit(1)
        .get();

      if (teamSnapshot.empty) return;

      const teamData = teamSnapshot.docs[0].data();

      // Send notifications to followers
      const batch = db.batch();
      
      favoritesSnapshot.docs.forEach(favoriteDoc => {
        const favorite = favoriteDoc.data();
        
        const notificationRef = db.collection("notifications").doc();
        batch.set(notificationRef, {
          user_id: favorite.user_id,
          title: `${teamData.name} Statistics Updated`,
          message: `New performance statistics are available for ${teamData.name}.`,
          type: "info",
          data: {
            team_id: teamId,
            team_name: teamData.name,
            statistics_update: true,
            league_id: after.league_id,
            season: after.season,
          },
          read: false,
          created_at: admin.firestore.Timestamp.now(),
        });
      });

      await batch.commit();

      logger.info("Team statistics update notifications sent", {
        statsId,
        teamId,
        teamName: teamData.name,
        notificationCount: favoritesSnapshot.size,
      });

    } catch (error) {
      logger.error("Error processing team statistics update", error as Error, {
        statsId,
        teamId: after?.team_id,
      });
    }
  });