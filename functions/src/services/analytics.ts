import * as admin from "firebase-admin";
import { logger } from "../utils/logger";
import { cache } from "../utils/cache";

export interface AnalyticsQuery {
  startDate?: Date;
  endDate?: Date;
  groupBy?: "day" | "week" | "month";
  filters?: Record<string, any>;
}

export interface AnalyticsResult {
  data: any[];
  metadata: {
    total: number;
    period: string;
    generated_at: string;
  };
}

export class AnalyticsService {
  private static instance: AnalyticsService;
  private db = admin.firestore();

  private constructor() {}

  public static getInstance(): AnalyticsService {
    if (!AnalyticsService.instance) {
      AnalyticsService.instance = new AnalyticsService();
    }
    return AnalyticsService.instance;
  }

  /**
   * Get user engagement analytics
   */
  public async getUserEngagementAnalytics(query: AnalyticsQuery = {}): Promise<AnalyticsResult> {
    try {
      const cacheKey = `user_engagement_${JSON.stringify(query)}`;
      const cached = await cache.getAnalyticsCache(cacheKey);
      
      if (cached) {
        return cached;
      }

      const endDate = query.endDate || new Date();
      const startDate = query.startDate || new Date(endDate.getTime() - 30 * 24 * 60 * 60 * 1000); // 30 days ago

      // Get user registration stats
      const userRegistrationsSnapshot = await this.db.collection("users")
        .where("created_at", ">=", admin.firestore.Timestamp.fromDate(startDate))
        .where("created_at", "<=", admin.firestore.Timestamp.fromDate(endDate))
        .get();

      // Get user activity stats
      const activitySnapshot = await this.db.collection("activity_logs")
        .where("timestamp", ">=", admin.firestore.Timestamp.fromDate(startDate))
        .where("timestamp", "<=", admin.firestore.Timestamp.fromDate(endDate))
        .get();

      // Group registrations by date
      const registrationsByDate = this.groupByDate(
        userRegistrationsSnapshot.docs.map(doc => ({
          date: doc.data().created_at.toDate(),
          count: 1,
        })),
        query.groupBy || "day"
      );

      // Group activity by date and action type
      const activityByDate = this.groupByDate(
        activitySnapshot.docs.map(doc => ({
          date: doc.data().timestamp.toDate(),
          action_type: doc.data().action_type,
          count: 1,
        })),
        query.groupBy || "day"
      );

      // Calculate engagement metrics
      const totalUsers = await this.getTotalUserCount();
      const activeUsers = new Set(activitySnapshot.docs.map(doc => doc.data().user_id)).size;
      const engagementRate = totalUsers > 0 ? (activeUsers / totalUsers) * 100 : 0;

      const result: AnalyticsResult = {
        data: [
          {
            metric: "user_registrations",
            timeline: registrationsByDate,
            total: userRegistrationsSnapshot.size,
          },
          {
            metric: "user_activity",
            timeline: activityByDate,
            total: activitySnapshot.size,
          },
          {
            metric: "engagement_summary",
            total_users: totalUsers,
            active_users: activeUsers,
            engagement_rate: Math.round(engagementRate * 100) / 100,
          },
        ],
        metadata: {
          total: userRegistrationsSnapshot.size + activitySnapshot.size,
          period: `${startDate.toISOString().split("T")[0]} to ${endDate.toISOString().split("T")[0]}`,
          generated_at: new Date().toISOString(),
        },
      };

      // Cache for 1 hour
      await cache.setAnalyticsCache(cacheKey, result, 3600);

      logger.info("User engagement analytics generated", {
        period: result.metadata.period,
        totalUsers,
        activeUsers,
        engagementRate,
      });

      return result;

    } catch (error) {
      logger.error("Failed to get user engagement analytics", error as Error);
      throw error;
    }
  }

  /**
   * Get content popularity analytics
   */
  public async getContentPopularityAnalytics(query: AnalyticsQuery = {}): Promise<AnalyticsResult> {
    try {
      const cacheKey = `content_popularity_${JSON.stringify(query)}`;
      const cached = await cache.getAnalyticsCache(cacheKey);
      
      if (cached) {
        return cached;
      }

      // Get favorite teams stats
      const teamFavoritesSnapshot = await this.db.collection("user_favorites")
        .where("type", "==", "team")
        .get();

      // Get favorite leagues stats
      const leagueFavoritesSnapshot = await this.db.collection("user_favorites")
        .where("type", "==", "league")
        .get();

      // Count favorites by team
      const teamFavoriteCounts = new Map<string, number>();
      teamFavoritesSnapshot.docs.forEach(doc => {
        const teamId = doc.data().entity_id;
        teamFavoriteCounts.set(teamId, (teamFavoriteCounts.get(teamId) || 0) + 1);
      });

      // Count favorites by league
      const leagueFavoriteCounts = new Map<string, number>();
      leagueFavoritesSnapshot.docs.forEach(doc => {
        const leagueId = doc.data().entity_id;
        leagueFavoriteCounts.set(leagueId, (leagueFavoriteCounts.get(leagueId) || 0) + 1);
      });

      // Get top teams with names
      const topTeams = await this.getTopTeamsWithNames(teamFavoriteCounts, 10);
      const topLeagues = await this.getTopLeaguesWithNames(leagueFavoriteCounts, 10);

      const result: AnalyticsResult = {
        data: [
          {
            metric: "top_teams",
            items: topTeams,
            total_favorites: teamFavoritesSnapshot.size,
          },
          {
            metric: "top_leagues",
            items: topLeagues,
            total_favorites: leagueFavoritesSnapshot.size,
          },
          {
            metric: "favorite_distribution",
            team_favorites: teamFavoritesSnapshot.size,
            league_favorites: leagueFavoritesSnapshot.size,
            unique_teams: teamFavoriteCounts.size,
            unique_leagues: leagueFavoriteCounts.size,
          },
        ],
        metadata: {
          total: teamFavoritesSnapshot.size + leagueFavoritesSnapshot.size,
          period: "all_time",
          generated_at: new Date().toISOString(),
        },
      };

      // Cache for 2 hours
      await cache.setAnalyticsCache(cacheKey, result, 7200);

      logger.info("Content popularity analytics generated", {
        totalTeamFavorites: teamFavoritesSnapshot.size,
        totalLeagueFavorites: leagueFavoritesSnapshot.size,
        uniqueTeams: teamFavoriteCounts.size,
        uniqueLeagues: leagueFavoriteCounts.size,
      });

      return result;

    } catch (error) {
      logger.error("Failed to get content popularity analytics", error as Error);
      throw error;
    }
  }

  /**
   * Get system performance analytics
   */
  public async getSystemPerformanceAnalytics(query: AnalyticsQuery = {}): Promise<AnalyticsResult> {
    try {
      const cacheKey = `system_performance_${JSON.stringify(query)}`;
      const cached = await cache.getAnalyticsCache(cacheKey);
      
      if (cached) {
        return cached;
      }

      const endDate = query.endDate || new Date();
      const startDate = query.startDate || new Date(endDate.getTime() - 7 * 24 * 60 * 60 * 1000); // 7 days ago

      // Get system logs
      const systemLogsSnapshot = await this.db.collection("system_logs")
        .where("timestamp", ">=", admin.firestore.Timestamp.fromDate(startDate))
        .where("timestamp", "<=", admin.firestore.Timestamp.fromDate(endDate))
        .get();

      // Get error logs from activity_logs
      const errorLogsSnapshot = await this.db.collection("activity_logs")
        .where("timestamp", ">=", admin.firestore.Timestamp.fromDate(startDate))
        .where("timestamp", "<=", admin.firestore.Timestamp.fromDate(endDate))
        .where("action_type", "==", "error")
        .get();

      // Analyze system operations
      const systemOperations = new Map<string, number>();
      const systemResults = new Map<string, any>();

      systemLogsSnapshot.docs.forEach(doc => {
        const data = doc.data();
        const type = data.type;
        systemOperations.set(type, (systemOperations.get(type) || 0) + 1);
        
        if (data.results) {
          if (!systemResults.has(type)) {
            systemResults.set(type, { success: 0, errors: 0 });
          }
          const current = systemResults.get(type);
          current.success += data.results.success || 0;
          current.errors += data.results.errors || 0;
        }
      });

      // Get cache statistics
      const cacheStats = await cache.getStats();

      const result: AnalyticsResult = {
        data: [
          {
            metric: "system_operations",
            operations: Array.from(systemOperations.entries()).map(([type, count]) => ({
              type,
              count,
              results: systemResults.get(type) || { success: 0, errors: 0 },
            })),
          },
          {
            metric: "error_analysis",
            total_errors: errorLogsSnapshot.size,
            error_by_date: this.groupByDate(
              errorLogsSnapshot.docs.map(doc => ({
                date: doc.data().timestamp.toDate(),
                count: 1,
              })),
              "day"
            ),
          },
          {
            metric: "cache_performance",
            ...cacheStats,
            hit_rate: cacheStats.total > 0 ? 
              Math.round(((cacheStats.active / cacheStats.total) * 100) * 100) / 100 : 0,
          },
        ],
        metadata: {
          total: systemLogsSnapshot.size + errorLogsSnapshot.size,
          period: `${startDate.toISOString().split("T")[0]} to ${endDate.toISOString().split("T")[0]}`,
          generated_at: new Date().toISOString(),
        },
      };

      // Cache for 30 minutes
      await cache.setAnalyticsCache(cacheKey, result, 1800);

      logger.info("System performance analytics generated", {
        period: result.metadata.period,
        systemOperations: systemOperations.size,
        totalErrors: errorLogsSnapshot.size,
      });

      return result;

    } catch (error) {
      logger.error("Failed to get system performance analytics", error as Error);
      throw error;
    }
  }

  /**
   * Generate comprehensive dashboard analytics
   */
  public async getDashboardAnalytics(): Promise<{
    overview: any;
    user_engagement: AnalyticsResult;
    content_popularity: AnalyticsResult;
    system_performance: AnalyticsResult;
  }> {
    try {
      const cacheKey = "dashboard_analytics";
      const cached = await cache.getAnalyticsCache(cacheKey);
      
      if (cached) {
        return cached;
      }

      // Get overview statistics
      const [
        totalUsersSnapshot,
        totalTeamsSnapshot,
        totalLeaguesSnapshot,
        totalFixturesSnapshot,
        totalFavoritesSnapshot,
        totalNotificationsSnapshot,
      ] = await Promise.all([
        this.db.collection("users").count().get(),
        this.db.collection("teams").count().get(),
        this.db.collection("leagues").count().get(),
        this.db.collection("fixtures").count().get(),
        this.db.collection("user_favorites").count().get(),
        this.db.collection("notifications").count().get(),
      ]);

      const overview = {
        total_users: totalUsersSnapshot.data().count,
        total_teams: totalTeamsSnapshot.data().count,
        total_leagues: totalLeaguesSnapshot.data().count,
        total_fixtures: totalFixturesSnapshot.data().count,
        total_favorites: totalFavoritesSnapshot.data().count,
        total_notifications: totalNotificationsSnapshot.data().count,
        generated_at: new Date().toISOString(),
      };

      // Get detailed analytics
      const [userEngagement, contentPopularity, systemPerformance] = await Promise.all([
        this.getUserEngagementAnalytics(),
        this.getContentPopularityAnalytics(),
        this.getSystemPerformanceAnalytics(),
      ]);

      const dashboard = {
        overview,
        user_engagement: userEngagement,
        content_popularity: contentPopularity,
        system_performance: systemPerformance,
      };

      // Cache for 15 minutes
      await cache.setAnalyticsCache(cacheKey, dashboard, 900);

      logger.info("Dashboard analytics generated", overview);

      return dashboard;

    } catch (error) {
      logger.error("Failed to get dashboard analytics", error as Error);
      throw error;
    }
  }

  /**
   * Helper: Group data by date
   */
  private groupByDate(
    data: Array<{ date: Date; count: number; [key: string]: any }>,
    groupBy: "day" | "week" | "month"
  ): Array<{ date: string; count: number; [key: string]: any }> {
    const grouped = new Map<string, any>();

    data.forEach(item => {
      let key: string;
      
      switch (groupBy) {
        case "day":
          key = item.date.toISOString().split("T")[0];
          break;
        case "week":
          const weekStart = new Date(item.date);
          weekStart.setDate(weekStart.getDate() - weekStart.getDay());
          key = weekStart.toISOString().split("T")[0];
          break;
        case "month":
          key = `${item.date.getFullYear()}-${String(item.date.getMonth() + 1).padStart(2, "0")}`;
          break;
        default:
          key = item.date.toISOString().split("T")[0];
      }

      if (!grouped.has(key)) {
        grouped.set(key, { date: key, count: 0, ...item });
        delete grouped.get(key).date; // Remove duplicate date from item
        grouped.get(key).date = key; // Set the grouped date key
      }
      
      grouped.get(key).count += item.count;
    });

    return Array.from(grouped.values()).sort((a, b) => a.date.localeCompare(b.date));
  }

  /**
   * Helper: Get total user count
   */
  private async getTotalUserCount(): Promise<number> {
    const snapshot = await this.db.collection("users").count().get();
    return snapshot.data().count;
  }

  /**
   * Helper: Get top teams with names
   */
  private async getTopTeamsWithNames(
    teamCounts: Map<string, number>,
    limit: number
  ): Promise<Array<{ id: string; name: string; country: string; favorites: number }>> {
    const sortedTeams = Array.from(teamCounts.entries())
      .sort(([, a], [, b]) => b - a)
      .slice(0, limit);

    const teamsWithNames = await Promise.all(
      sortedTeams.map(async ([teamId, count]) => {
        try {
          const teamSnapshot = await this.db.collection("teams")
            .where("api_team_id", "==", parseInt(teamId))
            .limit(1)
            .get();

          if (!teamSnapshot.empty) {
            const teamData = teamSnapshot.docs[0].data();
            return {
              id: teamId,
              name: teamData.name,
              country: teamData.country,
              favorites: count,
            };
          }
        } catch (error) {
          logger.warn(`Failed to get team data for ${teamId}`, { error: (error as Error).message });
        }

        return {
          id: teamId,
          name: `Team ${teamId}`,
          country: "Unknown",
          favorites: count,
        };
      })
    );

    return teamsWithNames;
  }

  /**
   * Helper: Get top leagues with names
   */
  private async getTopLeaguesWithNames(
    leagueCounts: Map<string, number>,
    limit: number
  ): Promise<Array<{ id: string; name: string; country: string; favorites: number }>> {
    const sortedLeagues = Array.from(leagueCounts.entries())
      .sort(([, a], [, b]) => b - a)
      .slice(0, limit);

    const leaguesWithNames = await Promise.all(
      sortedLeagues.map(async ([leagueId, count]) => {
        try {
          const leagueDoc = await this.db.collection("leagues").doc(leagueId).get();

          if (leagueDoc.exists) {
            const leagueData = leagueDoc.data();
            return {
              id: leagueId,
              name: leagueData?.name || `League ${leagueId}`,
              country: leagueData?.country || "Unknown",
              favorites: count,
            };
          }
        } catch (error) {
          logger.warn(`Failed to get league data for ${leagueId}`, { error: (error as Error).message });
        }

        return {
          id: leagueId,
          name: `League ${leagueId}`,
          country: "Unknown",
          favorites: count,
        };
      })
    );

    return leaguesWithNames;
  }

  /**
   * Clear all analytics cache
   */
  public async clearAnalyticsCache(): Promise<void> {
    try {
      // Clear analytics cache collection
      const expiredSnapshot = await this.db.collection("analytics_cache").get();

      if (!expiredSnapshot.empty) {
        const batch = this.db.batch();
        expiredSnapshot.docs.forEach(doc => {
          batch.delete(doc.ref);
        });
        await batch.commit();
      }

      logger.info("Analytics cache cleared", { count: expiredSnapshot.size });

    } catch (error) {
      logger.error("Failed to clear analytics cache", error as Error);
      throw error;
    }
  }
}

export const analyticsService = AnalyticsService.getInstance();