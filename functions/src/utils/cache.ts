import * as admin from "firebase-admin";
import { logger } from "./logger";

export interface CacheOptions {
  ttl?: number; // Time to live in seconds
  keyPrefix?: string;
}

export class CacheManager {
  private static instance: CacheManager;
  private db = admin.firestore();
  private defaultTTL = 3600; // 1 hour

  private constructor() {}

  public static getInstance(): CacheManager {
    if (!CacheManager.instance) {
      CacheManager.instance = new CacheManager();
    }
    return CacheManager.instance;
  }

  /**
   * Store data in cache
   */
  public async set(
    key: string,
    data: any,
    options: CacheOptions = {}
  ): Promise<void> {
    try {
      const ttl = options.ttl || this.defaultTTL;
      const prefixedKey = options.keyPrefix ? `${options.keyPrefix}:${key}` : key;
      const expiresAt = new Date(Date.now() + ttl * 1000);

      await this.db.collection("api_cache").doc(prefixedKey).set({
        endpoint: prefixedKey,
        params: {},
        data,
        expires_at: admin.firestore.Timestamp.fromDate(expiresAt),
        created_at: admin.firestore.Timestamp.now(),
      });

      logger.debug(`Cache set for key: ${prefixedKey}`, { key: prefixedKey, ttl });
    } catch (error) {
      logger.error(`Failed to set cache for key: ${key}`, error as Error);
      throw error;
    }
  }

  /**
   * Retrieve data from cache
   */
  public async get<T>(key: string, keyPrefix?: string): Promise<T | null> {
    try {
      const prefixedKey = keyPrefix ? `${keyPrefix}:${key}` : key;
      const doc = await this.db.collection("api_cache").doc(prefixedKey).get();

      if (!doc.exists) {
        logger.debug(`Cache miss for key: ${prefixedKey}`, { key: prefixedKey });
        return null;
      }

      const data = doc.data();
      if (!data) return null;

      // Check if cache has expired
      const now = admin.firestore.Timestamp.now();
      if (data.expires_at && data.expires_at.toMillis() < now.toMillis()) {
        logger.debug(`Cache expired for key: ${prefixedKey}`, { key: prefixedKey });
        // Clean up expired cache
        await this.delete(key, keyPrefix);
        return null;
      }

      logger.debug(`Cache hit for key: ${prefixedKey}`, { key: prefixedKey });
      return data.data as T;
    } catch (error) {
      logger.error(`Failed to get cache for key: ${key}`, error as Error);
      return null;
    }
  }

  /**
   * Delete cache entry
   */
  public async delete(key: string, keyPrefix?: string): Promise<void> {
    try {
      const prefixedKey = keyPrefix ? `${keyPrefix}:${key}` : key;
      await this.db.collection("api_cache").doc(prefixedKey).delete();
      logger.debug(`Cache deleted for key: ${prefixedKey}`, { key: prefixedKey });
    } catch (error) {
      logger.error(`Failed to delete cache for key: ${key}`, error as Error);
    }
  }

  /**
   * Clear all cache entries with a specific prefix
   */
  public async clearPrefix(prefix: string): Promise<void> {
    try {
      const snapshot = await this.db
        .collection("api_cache")
        .where("endpoint", ">=", prefix)
        .where("endpoint", "<", prefix + "\uf8ff")
        .get();

      const batch = this.db.batch();
      snapshot.docs.forEach((doc) => {
        batch.delete(doc.ref);
      });

      await batch.commit();
      logger.info(`Cleared cache with prefix: ${prefix}`, { prefix, count: snapshot.size });
    } catch (error) {
      logger.error(`Failed to clear cache with prefix: ${prefix}`, error as Error);
    }
  }

  /**
   * Clean up expired cache entries
   */
  public async cleanupExpired(): Promise<number> {
    try {
      const now = admin.firestore.Timestamp.now();
      const snapshot = await this.db
        .collection("api_cache")
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
      logger.info(`Cleaned up expired cache entries`, { count: snapshot.size });
      return snapshot.size;
    } catch (error) {
      logger.error("Failed to cleanup expired cache", error as Error);
      return 0;
    }
  }

  /**
   * Get cache statistics
   */
  public async getStats(): Promise<{
    total: number;
    expired: number;
    active: number;
  }> {
    try {
      const now = admin.firestore.Timestamp.now();
      
      const [totalSnapshot, expiredSnapshot] = await Promise.all([
        this.db.collection("api_cache").count().get(),
        this.db.collection("api_cache").where("expires_at", "<", now).count().get(),
      ]);

      const total = totalSnapshot.data().count;
      const expired = expiredSnapshot.data().count;
      const active = total - expired;

      return { total, expired, active };
    } catch (error) {
      logger.error("Failed to get cache stats", error as Error);
      return { total: 0, expired: 0, active: 0 };
    }
  }

  /**
   * Store analytics cache with specific TTL
   */
  public async setAnalyticsCache(
    key: string,
    data: any,
    ttl: number = 7200 // 2 hours default for analytics
  ): Promise<void> {
    try {
      const expiresAt = new Date(Date.now() + ttl * 1000);

      await this.db.collection("analytics_cache").doc(key).set({
        cache_key: key,
        data,
        expires_at: admin.firestore.Timestamp.fromDate(expiresAt),
        created_at: admin.firestore.Timestamp.now(),
      });

      logger.debug(`Analytics cache set for key: ${key}`, { key, ttl });
    } catch (error) {
      logger.error(`Failed to set analytics cache for key: ${key}`, error as Error);
      throw error;
    }
  }

  /**
   * Get analytics cache
   */
  public async getAnalyticsCache<T>(key: string): Promise<T | null> {
    try {
      const doc = await this.db.collection("analytics_cache").doc(key).get();

      if (!doc.exists) {
        return null;
      }

      const data = doc.data();
      if (!data) return null;

      // Check if cache has expired
      const now = admin.firestore.Timestamp.now();
      if (data.expires_at && data.expires_at.toMillis() < now.toMillis()) {
        // Clean up expired cache
        await this.db.collection("analytics_cache").doc(key).delete();
        return null;
      }

      return data.data as T;
    } catch (error) {
      logger.error(`Failed to get analytics cache for key: ${key}`, error as Error);
      return null;
    }
  }
}

export const cache = CacheManager.getInstance();