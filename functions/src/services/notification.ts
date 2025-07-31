import * as admin from "firebase-admin";
import { logger } from "../utils/logger";
import { Notification } from "../types";

export interface NotificationOptions {
  title: string;
  message: string;
  type: "info" | "warning" | "error" | "success";
  data?: Record<string, any>;
  sendPush?: boolean;
  fcmToken?: string;
}

export interface BulkNotificationOptions extends NotificationOptions {
  userIds: string[];
  batchSize?: number;
}

export class NotificationService {
  private static instance: NotificationService;
  private db = admin.firestore();
  private messaging = admin.messaging();

  private constructor() {}

  public static getInstance(): NotificationService {
    if (!NotificationService.instance) {
      NotificationService.instance = new NotificationService();
    }
    return NotificationService.instance;
  }

  /**
   * Send notification to a single user
   */
  public async sendNotification(
    userId: string,
    options: NotificationOptions
  ): Promise<string> {
    try {
      // Create notification document
      const notificationData: Partial<Notification> = {
        user_id: userId,
        title: options.title,
        message: options.message,
        type: options.type,
        data: options.data || {},
        read: false,
        created_at: admin.firestore.Timestamp.now(),
      };

      const docRef = await this.db.collection("notifications").add(notificationData);

      logger.info("Notification created", {
        notificationId: docRef.id,
        userId,
        type: options.type,
        title: options.title,
      });

      // Send push notification if requested and FCM token available
      if (options.sendPush) {
        await this.sendPushNotification(userId, options, options.fcmToken);
      }

      return docRef.id;

    } catch (error) {
      logger.error("Failed to send notification", error as Error, {
        userId,
        title: options.title,
      });
      throw error;
    }
  }

  /**
   * Send notifications to multiple users
   */
  public async sendBulkNotifications(
    options: BulkNotificationOptions
  ): Promise<{
    success: number;
    failed: number;
    errors: string[];
  }> {
    const { userIds, batchSize = 500, ...notificationOptions } = options;
    const results = { success: 0, failed: 0, errors: [] as string[] };

    try {
      // Process users in batches
      for (let i = 0; i < userIds.length; i += batchSize) {
        const batch = userIds.slice(i, i + batchSize);
        
        const promises = batch.map(async (userId) => {
          try {
            await this.sendNotification(userId, notificationOptions);
            results.success++;
          } catch (error) {
            results.failed++;
            results.errors.push(`User ${userId}: ${(error as Error).message}`);
          }
        });

        await Promise.all(promises);
      }

      logger.info("Bulk notifications completed", {
        totalUsers: userIds.length,
        success: results.success,
        failed: results.failed,
      });

      return results;

    } catch (error) {
      logger.error("Bulk notification failed", error as Error);
      throw error;
    }
  }

  /**
   * Send push notification via FCM
   */
  private async sendPushNotification(
    userId: string,
    options: NotificationOptions,
    fcmToken?: string
  ): Promise<void> {
    try {
      // Get user's FCM token if not provided
      let token = fcmToken;
      if (!token) {
        const userDoc = await this.db.collection("users").doc(userId).get();
        if (userDoc.exists) {
          const userData = userDoc.data();
          token = userData?.fcm_token;
        }
      }

      if (!token) {
        logger.warn("No FCM token available for push notification", { userId });
        return;
      }

      // Prepare FCM message
      const message = {
        notification: {
          title: options.title,
          body: options.message,
        },
        data: {
          type: options.type,
          ...this.serializeData(options.data || {}),
        },
        token,
        android: {
          notification: {
            icon: "ic_notification",
            color: "#4285f4",
            sound: "default",
          },
        },
        apns: {
          payload: {
            aps: {
              sound: "default",
              badge: await this.getUnreadCount(userId),
            },
          },
        },
      };

      // Send FCM message
      const response = await this.messaging.send(message);
      
      logger.info("Push notification sent", {
        userId,
        messageId: response,
        title: options.title,
      });

    } catch (error) {
      logger.error("Failed to send push notification", error as Error, {
        userId,
        title: options.title,
      });
      // Don't throw error for push notification failures
    }
  }

  /**
   * Mark notification as read
   */
  public async markAsRead(notificationId: string, userId: string): Promise<void> {
    try {
      const notificationRef = this.db.collection("notifications").doc(notificationId);
      const doc = await notificationRef.get();

      if (!doc.exists) {
        throw new Error("Notification not found");
      }

      const notification = doc.data();
      if (notification?.user_id !== userId) {
        throw new Error("Unauthorized access to notification");
      }

      await notificationRef.update({
        read: true,
        read_at: admin.firestore.Timestamp.now(),
      });

      logger.info("Notification marked as read", { notificationId, userId });

    } catch (error) {
      logger.error("Failed to mark notification as read", error as Error, {
        notificationId,
        userId,
      });
      throw error;
    }
  }

  /**
   * Mark all notifications as read for a user
   */
  public async markAllAsRead(userId: string): Promise<number> {
    try {
      const unreadSnapshot = await this.db.collection("notifications")
        .where("user_id", "==", userId)
        .where("read", "==", false)
        .get();

      if (unreadSnapshot.empty) {
        return 0;
      }

      const batch = this.db.batch();
      const readAt = admin.firestore.Timestamp.now();

      unreadSnapshot.docs.forEach(doc => {
        batch.update(doc.ref, {
          read: true,
          read_at: readAt,
        });
      });

      await batch.commit();
      const count = unreadSnapshot.size;

      logger.info("All notifications marked as read", { userId, count });
      return count;

    } catch (error) {
      logger.error("Failed to mark all notifications as read", error as Error, { userId });
      throw error;
    }
  }

  /**
   * Delete notification
   */
  public async deleteNotification(notificationId: string, userId: string): Promise<void> {
    try {
      const notificationRef = this.db.collection("notifications").doc(notificationId);
      const doc = await notificationRef.get();

      if (!doc.exists) {
        throw new Error("Notification not found");
      }

      const notification = doc.data();
      if (notification?.user_id !== userId) {
        throw new Error("Unauthorized access to notification");
      }

      await notificationRef.delete();

      logger.info("Notification deleted", { notificationId, userId });

    } catch (error) {
      logger.error("Failed to delete notification", error as Error, {
        notificationId,
        userId,
      });
      throw error;
    }
  }

  /**
   * Get user's unread notification count
   */
  public async getUnreadCount(userId: string): Promise<number> {
    try {
      const snapshot = await this.db.collection("notifications")
        .where("user_id", "==", userId)
        .where("read", "==", false)
        .count()
        .get();

      return snapshot.data().count;

    } catch (error) {
      logger.error("Failed to get unread count", error as Error, { userId });
      return 0;
    }
  }

  /**
   * Get notifications for a user with pagination
   */
  public async getUserNotifications(
    userId: string,
    limit: number = 20,
    startAfter?: string
  ): Promise<{
    notifications: any[];
    hasMore: boolean;
    lastId?: string;
  }> {
    try {
      let query = this.db.collection("notifications")
        .where("user_id", "==", userId)
        .orderBy("created_at", "desc")
        .limit(limit + 1); // Get one extra to check if there are more

      if (startAfter) {
        const startDoc = await this.db.collection("notifications").doc(startAfter).get();
        if (startDoc.exists) {
          query = query.startAfter(startDoc);
        }
      }

      const snapshot = await query.get();
      const notifications = snapshot.docs.slice(0, limit).map(doc => ({
        id: doc.id,
        ...doc.data(),
        created_at: doc.data().created_at.toDate().toISOString(),
        read_at: doc.data().read_at?.toDate().toISOString(),
      }));

      const hasMore = snapshot.docs.length > limit;
      const lastId = notifications.length > 0 ? notifications[notifications.length - 1].id : undefined;

      return { notifications, hasMore, lastId };

    } catch (error) {
      logger.error("Failed to get user notifications", error as Error, { userId });
      throw error;
    }
  }

  /**
   * Send team-related notifications to followers
   */
  public async notifyTeamFollowers(
    teamId: string,
    options: Omit<NotificationOptions, "sendPush">
  ): Promise<number> {
    try {
      // Get all users following this team
      const followersSnapshot = await this.db.collection("user_favorites")
        .where("type", "==", "team")
        .where("entity_id", "==", teamId)
        .get();

      if (followersSnapshot.empty) {
        return 0;
      }

      const userIds = followersSnapshot.docs.map(doc => doc.data().user_id);

      const result = await this.sendBulkNotifications({
        ...options,
        userIds,
        sendPush: true, // Enable push notifications for team updates
      });

      logger.info("Team followers notified", {
        teamId,
        totalFollowers: userIds.length,
        success: result.success,
        failed: result.failed,
      });

      return result.success;

    } catch (error) {
      logger.error("Failed to notify team followers", error as Error, { teamId });
      throw error;
    }
  }

  /**
   * Send league-related notifications to followers
   */
  public async notifyLeagueFollowers(
    leagueId: string,
    options: Omit<NotificationOptions, "sendPush">
  ): Promise<number> {
    try {
      // Get all users following this league
      const followersSnapshot = await this.db.collection("user_favorites")
        .where("type", "==", "league")
        .where("entity_id", "==", leagueId)
        .get();

      if (followersSnapshot.empty) {
        return 0;
      }

      const userIds = followersSnapshot.docs.map(doc => doc.data().user_id);

      const result = await this.sendBulkNotifications({
        ...options,
        userIds,
        sendPush: true,
      });

      logger.info("League followers notified", {
        leagueId,
        totalFollowers: userIds.length,
        success: result.success,
        failed: result.failed,
      });

      return result.success;

    } catch (error) {
      logger.error("Failed to notify league followers", error as Error, { leagueId });
      throw error;
    }
  }

  /**
   * Update user's FCM token
   */
  public async updateFCMToken(userId: string, fcmToken: string): Promise<void> {
    try {
      await this.db.collection("users").doc(userId).update({
        fcm_token: fcmToken,
        fcm_token_updated_at: admin.firestore.Timestamp.now(),
      });

      logger.info("FCM token updated", { userId });

    } catch (error) {
      logger.error("Failed to update FCM token", error as Error, { userId });
      throw error;
    }
  }

  /**
   * Serialize data for FCM (convert complex types to strings)
   */
  private serializeData(data: Record<string, any>): Record<string, string> {
    const serialized: Record<string, string> = {};
    
    for (const [key, value] of Object.entries(data)) {
      if (typeof value === "string") {
        serialized[key] = value;
      } else {
        serialized[key] = JSON.stringify(value);
      }
    }

    return serialized;
  }

  /**
   * Clean up old notifications (should be called periodically)
   */
  public async cleanupOldNotifications(olderThanDays: number = 30): Promise<number> {
    try {
      const cutoffDate = new Date();
      cutoffDate.setDate(cutoffDate.getDate() - olderThanDays);
      const cutoffTimestamp = admin.firestore.Timestamp.fromDate(cutoffDate);

      const oldNotificationsSnapshot = await this.db.collection("notifications")
        .where("created_at", "<", cutoffTimestamp)
        .limit(500) // Process in batches
        .get();

      if (oldNotificationsSnapshot.empty) {
        return 0;
      }

      const batch = this.db.batch();
      oldNotificationsSnapshot.docs.forEach(doc => {
        batch.delete(doc.ref);
      });

      await batch.commit();
      const deletedCount = oldNotificationsSnapshot.size;

      logger.info("Old notifications cleaned up", {
        deletedCount,
        olderThanDays,
      });

      return deletedCount;

    } catch (error) {
      logger.error("Failed to clean up old notifications", error as Error);
      return 0;
    }
  }
}

export const notificationService = NotificationService.getInstance();