import * as admin from "firebase-admin";
import { logger } from "./logger";

export interface RateLimitOptions {
  windowMs: number; // Time window in milliseconds
  maxRequests: number; // Maximum requests in the window
  keyGenerator?: (userId?: string, ipAddress?: string) => string;
  skipSuccessfulRequests?: boolean;
  skipFailedRequests?: boolean;
}

export interface RateLimitResult {
  allowed: boolean;
  remaining: number;
  resetTime: Date;
  totalRequests: number;
}

export class RateLimiter {
  private static instance: RateLimiter;
  private db = admin.firestore();

  private constructor() {}

  public static getInstance(): RateLimiter {
    if (!RateLimiter.instance) {
      RateLimiter.instance = new RateLimiter();
    }
    return RateLimiter.instance;
  }

  /**
   * Check if request is within rate limit
   */
  public async checkLimit(
    endpoint: string,
    options: RateLimitOptions,
    userId?: string,
    ipAddress?: string
  ): Promise<RateLimitResult> {
    try {
      const key = this.generateKey(endpoint, options, userId, ipAddress);
      const now = new Date();
      const windowStart = new Date(now.getTime() - options.windowMs);

      // Get current rate limit record
      const rateLimitRef = this.db.collection("rate_limits").doc(key);
      const doc = await rateLimitRef.get();

      let currentCount = 0;
      let resetTime = new Date(now.getTime() + options.windowMs);

      if (doc.exists) {
        const data = doc.data();
        if (data) {
          const windowStartTime = data.window_start.toDate();
          
          // If the window has expired, reset the count
          if (windowStartTime < windowStart) {
            currentCount = 1;
            resetTime = new Date(now.getTime() + options.windowMs);
            
            await rateLimitRef.set({
              user_id: userId || null,
              ip_address: ipAddress || null,
              endpoint,
              count: currentCount,
              window_start: admin.firestore.Timestamp.fromDate(now),
              expires_at: admin.firestore.Timestamp.fromDate(resetTime),
            });
          } else {
            // Window is still active, increment count
            currentCount = data.count + 1;
            resetTime = data.expires_at.toDate();
            
            if (currentCount <= options.maxRequests) {
              await rateLimitRef.update({
                count: currentCount,
              });
            }
          }
        }
      } else {
        // First request in this window
        currentCount = 1;
        resetTime = new Date(now.getTime() + options.windowMs);
        
        await rateLimitRef.set({
          user_id: userId || null,
          ip_address: ipAddress || null,
          endpoint,
          count: currentCount,
          window_start: admin.firestore.Timestamp.fromDate(now),
          expires_at: admin.firestore.Timestamp.fromDate(resetTime),
        });
      }

      const allowed = currentCount <= options.maxRequests;
      const remaining = Math.max(0, options.maxRequests - currentCount);

      if (!allowed) {
        logger.warn(`Rate limit exceeded for endpoint: ${endpoint}`, {
          endpoint,
          userId,
          ipAddress,
          currentCount,
          maxRequests: options.maxRequests,
        });
      }

      return {
        allowed,
        remaining,
        resetTime,
        totalRequests: currentCount,
      };
    } catch (error) {
      logger.error(`Failed to check rate limit for endpoint: ${endpoint}`, error as Error);
      // In case of error, allow the request to proceed
      return {
        allowed: true,
        remaining: options.maxRequests,
        resetTime: new Date(Date.now() + options.windowMs),
        totalRequests: 0,
      };
    }
  }

  /**
   * Reset rate limit for a specific key
   */
  public async resetLimit(
    endpoint: string,
    options: RateLimitOptions,
    userId?: string,
    ipAddress?: string
  ): Promise<void> {
    try {
      const key = this.generateKey(endpoint, options, userId, ipAddress);
      await this.db.collection("rate_limits").doc(key).delete();
      
      logger.info(`Rate limit reset for endpoint: ${endpoint}`, {
        endpoint,
        userId,
        ipAddress,
      });
    } catch (error) {
      logger.error(`Failed to reset rate limit for endpoint: ${endpoint}`, error as Error);
    }
  }

  /**
   * Clean up expired rate limit records
   */
  public async cleanupExpired(): Promise<number> {
    try {
      const now = admin.firestore.Timestamp.now();
      const snapshot = await this.db
        .collection("rate_limits")
        .where("expires_at", "<", now)
        .limit(500) // Process in batches
        .get();

      if (snapshot.empty) {
        return 0;
      }

      const batch = this.db.batch();
      snapshot.docs.forEach((doc) => {
        batch.delete(doc.ref);
      });

      await batch.commit();
      logger.info(`Cleaned up expired rate limit records`, { count: snapshot.size });
      return snapshot.size;
    } catch (error) {
      logger.error("Failed to cleanup expired rate limits", error as Error);
      return 0;
    }
  }

  /**
   * Get rate limit statistics for monitoring
   */
  public async getStats(): Promise<{
    totalLimits: number;
    activeBlocks: number;
    topEndpoints: Array<{ endpoint: string; count: number }>;
  }> {
    try {
      const now = admin.firestore.Timestamp.now();
      
      const [totalSnapshot, activeSnapshot] = await Promise.all([
        this.db.collection("rate_limits").count().get(),
        this.db.collection("rate_limits").where("expires_at", ">", now).count().get(),
      ]);

      // Get top endpoints by rate limit hits
      const endpointsSnapshot = await this.db
        .collection("rate_limits")
        .where("expires_at", ">", now)
        .orderBy("count", "desc")
        .limit(10)
        .get();

      const topEndpoints = endpointsSnapshot.docs.map((doc) => {
        const data = doc.data();
        return {
          endpoint: data.endpoint,
          count: data.count,
        };
      });

      return {
        totalLimits: totalSnapshot.data().count,
        activeBlocks: activeSnapshot.data().count,
        topEndpoints,
      };
    } catch (error) {
      logger.error("Failed to get rate limit stats", error as Error);
      return {
        totalLimits: 0,
        activeBlocks: 0,
        topEndpoints: [],
      };
    }
  }

  private generateKey(
    endpoint: string,
    options: RateLimitOptions,
    userId?: string,
    ipAddress?: string
  ): string {
    if (options.keyGenerator) {
      return options.keyGenerator(userId, ipAddress);
    }

    // Default key generation: prefer userId, fallback to ipAddress
    const identifier = userId || ipAddress || "anonymous";
    return `${endpoint}:${identifier}`;
  }
}

export const rateLimiter = RateLimiter.getInstance();

// Common rate limit configurations
export const RateLimitConfigs = {
  // API endpoints
  API_GENERAL: {
    windowMs: 60 * 1000, // 1 minute
    maxRequests: 60,
  },
  API_INTENSIVE: {
    windowMs: 60 * 1000, // 1 minute
    maxRequests: 10,
  },
  
  // User actions
  USER_FAVORITES: {
    windowMs: 60 * 1000, // 1 minute
    maxRequests: 20,
  },
  USER_PROFILE_UPDATE: {
    windowMs: 60 * 1000, // 1 minute
    maxRequests: 5,
  },
  
  // Authentication
  AUTH_LOGIN: {
    windowMs: 15 * 60 * 1000, // 15 minutes
    maxRequests: 5,
  },
  AUTH_SIGNUP: {
    windowMs: 60 * 60 * 1000, // 1 hour
    maxRequests: 3,
  },
  
  // Admin actions
  ADMIN_DATA_MODIFICATION: {
    windowMs: 60 * 1000, // 1 minute
    maxRequests: 30,
  },
};