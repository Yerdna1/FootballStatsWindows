import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import { logger } from "../utils/logger";
import { ErrorHandler } from "../utils/error-handler";
import { authService } from "../utils/auth";
import { cache } from "../utils/cache";
import { rateLimiter, RateLimitConfigs } from "../utils/rate-limiter";
import { footballApi } from "../services/football-api";

const db = admin.firestore();

/**
 * Get user statistics and analytics
 */
export const getUserStats = functions.https.onCall(
  ErrorHandler.wrapCallableHandler(async (data, context) => {
    // Authenticate user
    const userContext = await authService.authenticateCallable(context);
    const userId = data.userId || userContext.uid;

    // Check if user can access this data
    authService.requireOwnershipOrAdmin(userContext, userId);

    // Rate limiting
    const rateLimit = await rateLimiter.checkLimit(
      "getUserStats",
      RateLimitConfigs.API_GENERAL,
      userContext.uid
    );

    if (!rateLimit.allowed) {
      throw new functions.https.HttpsError(
        "resource-exhausted",
        "Rate limit exceeded",
        { resetTime: rateLimit.resetTime.toISOString() }
      );
    }

    try {
      // Check cache first
      const cacheKey = `user_stats_${userId}`;
      const cachedStats = await cache.getAnalyticsCache(cacheKey);
      
      if (cachedStats) {
        logger.info("User stats served from cache", { userId });
        return cachedStats;
      }

      // Calculate user statistics
      const [
        favoritesSnapshot,
        teamFavoritesSnapshot,
        leagueFavoritesSnapshot,
        notificationsSnapshot,
        unreadNotificationsSnapshot,
      ] = await Promise.all([
        db.collection("user_favorites").where("user_id", "==", userId).count().get(),
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
        db.collection("notifications").where("user_id", "==", userId).count().get(),
        db.collection("notifications")
          .where("user_id", "==", userId)
          .where("read", "==", false)
          .count()
          .get(),
      ]);

      // Get user's recent activity
      const recentActivitySnapshot = await db.collection("activity_logs")
        .where("user_id", "==", userId)
        .orderBy("timestamp", "desc")
        .limit(10)
        .get();

      const recentActivity = recentActivitySnapshot.docs.map(doc => ({
        id: doc.id,
        ...doc.data(),
        timestamp: doc.data().timestamp.toDate().toISOString(),
      }));

      const stats = {
        user_id: userId,
        favorites: {
          total: favoritesSnapshot.data().count,
          teams: teamFavoritesSnapshot.data().count,
          leagues: leagueFavoritesSnapshot.data().count,
        },
        notifications: {
          total: notificationsSnapshot.data().count,
          unread: unreadNotificationsSnapshot.data().count,
        },
        recent_activity: recentActivity,
        generated_at: new Date().toISOString(),
      };

      // Cache the results
      await cache.setAnalyticsCache(cacheKey, stats, 1800); // 30 minutes

      logger.info("User stats calculated and cached", { userId });
      return stats;

    } catch (error) {
      logger.error("Failed to get user stats", error as Error, { userId });
      throw error;
    }
  })
);

/**
 * Get team analytics and insights
 */
export const getTeamAnalytics = functions.https.onCall(
  ErrorHandler.wrapCallableHandler(async (data, context) => {
    // Authenticate user
    await authService.authenticateCallable(context);

    const { teamId, season = 2025 } = data;

    if (!teamId) {
      throw new functions.https.HttpsError(
        "invalid-argument",
        "Team ID is required"
      );
    }

    try {
      // Check cache first
      const cacheKey = `team_analytics_${teamId}_${season}`;
      const cachedAnalytics = await cache.getAnalyticsCache(cacheKey);
      
      if (cachedAnalytics) {
        logger.info("Team analytics served from cache", { teamId, season });
        return cachedAnalytics;
      }

      // Get team information
      const teamSnapshot = await db.collection("teams")
        .where("api_team_id", "==", parseInt(teamId))
        .limit(1)
        .get();

      if (teamSnapshot.empty) {
        throw new functions.https.HttpsError("not-found", "Team not found");
      }

      const teamData = teamSnapshot.docs[0].data();
      const teamDocId = teamSnapshot.docs[0].id;

      // Get team statistics
      const [
        statisticsSnapshot,
        fixturesSnapshot,
        standingsSnapshot,
        followersSnapshot,
      ] = await Promise.all([
        db.collection("team_statistics")
          .where("team_id", "==", teamId)
          .where("season", "==", season)
          .limit(1)
          .get(),
        db.collection("fixtures")
          .where("season", "==", season)
          .where("home_team_id", "==", teamId)
          .get()
          .then(async (homeSnapshot) => {
            const awaySnapshot = await db.collection("fixtures")
              .where("season", "==", season)
              .where("away_team_id", "==", teamId)
              .get();
            return [...homeSnapshot.docs, ...awaySnapshot.docs];
          }),
        db.collection("standings")
          .where("team_id", "==", teamId)
          .where("season", "==", season)
          .limit(1)
          .get(),
        db.collection("user_favorites")
          .where("type", "==", "team")
          .where("entity_id", "==", teamId)
          .count()
          .get(),
      ]);

      // Process fixtures data
      const fixtures = fixturesSnapshot.map(doc => doc.data());
      const completedFixtures = fixtures.filter(f => f.status.short === "FT");
      const upcomingFixtures = fixtures.filter(f => f.status.short === "NS");

      // Calculate performance metrics
      const homeFixtures = fixtures.filter(f => f.home_team_id === teamId);
      const awayFixtures = fixtures.filter(f => f.away_team_id === teamId);

      const homeWins = homeFixtures.filter(f => 
        f.status.short === "FT" && f.goals.home > f.goals.away
      ).length;
      const awayWins = awayFixtures.filter(f => 
        f.status.short === "FT" && f.goals.away > f.goals.home
      ).length;

      const analytics = {
        team: {
          id: teamId,
          name: teamData.name,
          country: teamData.country,
          logo: teamData.logo,
        },
        season,
        statistics: statisticsSnapshot.empty ? null : statisticsSnapshot.docs[0].data(),
        standings: standingsSnapshot.empty ? null : standingsSnapshot.docs[0].data(),
        performance: {
          total_fixtures: fixtures.length,
          completed_fixtures: completedFixtures.length,
          upcoming_fixtures: upcomingFixtures.length,
          home_fixtures: homeFixtures.length,
          away_fixtures: awayFixtures.length,
          home_wins: homeWins,
          away_wins: awayWins,
          total_wins: homeWins + awayWins,
        },
        popularity: {
          followers: followersSnapshot.data().count,
        },
        generated_at: new Date().toISOString(),
      };

      // Cache the results
      await cache.setAnalyticsCache(cacheKey, analytics, 3600); // 1 hour

      logger.info("Team analytics calculated and cached", { teamId, season });
      return analytics;

    } catch (error) {
      logger.error("Failed to get team analytics", error as Error, { teamId, season });
      throw error;
    }
  })
);

/**
 * Get league insights and statistics
 */
export const getLeagueInsights = functions.https.onCall(
  ErrorHandler.wrapCallableHandler(async (data, context) => {
    // Authenticate user
    await authService.authenticateCallable(context);

    const { leagueId, season = 2025 } = data;

    if (!leagueId) {
      throw new functions.https.HttpsError(
        "invalid-argument",
        "League ID is required"
      );
    }

    try {
      // Check cache first
      const cacheKey = `league_insights_${leagueId}_${season}`;
      const cachedInsights = await cache.getAnalyticsCache(cacheKey);
      
      if (cachedInsights) {
        logger.info("League insights served from cache", { leagueId, season });
        return cachedInsights;
      }

      // Get league information
      const leagueDoc = await db.collection("leagues").doc(leagueId).get();
      
      if (!leagueDoc.exists) {
        throw new functions.https.HttpsError("not-found", "League not found");
      }

      const leagueData = leagueDoc.data();

      // Get league statistics
      const [
        teamsSnapshot,
        fixturesSnapshot,
        standingsSnapshot,
        followersSnapshot,
      ] = await Promise.all([
        db.collection("teams").where("league_id", "==", leagueId).count().get(),
        db.collection("fixtures")
          .where("league_id", "==", leagueId)
          .where("season", "==", season)
          .get(),
        db.collection("standings")
          .where("league_id", "==", leagueId)
          .where("season", "==", season)
          .orderBy("position")
          .get(),
        db.collection("user_favorites")
          .where("type", "==", "league")
          .where("entity_id", "==", leagueId)
          .count()
          .get(),
      ]);

      // Process fixtures data
      const fixtures = fixturesSnapshot.docs.map(doc => doc.data());
      const completedFixtures = fixtures.filter(f => f.status.short === "FT");
      const upcomingFixtures = fixtures.filter(f => f.status.short === "NS");

      // Calculate goal statistics
      const totalGoals = completedFixtures.reduce((sum, fixture) => {
        return sum + (fixture.goals.home || 0) + (fixture.goals.away || 0);
      }, 0);

      const averageGoalsPerMatch = completedFixtures.length > 0 
        ? totalGoals / completedFixtures.length 
        : 0;

      // Get top scorers info (this would require player data which we don't have in this schema)
      const standings = standingsSnapshot.docs.map(doc => doc.data());
      const topTeam = standings.find(s => s.position === 1);

      const insights = {
        league: {
          id: leagueId,
          name: leagueData?.name,
          country: leagueData?.country,
          logo: leagueData?.logo,
        },
        season,
        statistics: {
          total_teams: teamsSnapshot.data().count,
          total_fixtures: fixtures.length,
          completed_fixtures: completedFixtures.length,
          upcoming_fixtures: upcomingFixtures.length,
          total_goals: totalGoals,
          average_goals_per_match: Math.round(averageGoalsPerMatch * 100) / 100,
        },
        standings: {
          total_positions: standings.length,
          leader: topTeam ? {
            team_id: topTeam.team_id,
            position: topTeam.position,
            points: topTeam.points,
            goals_diff: topTeam.goals_diff,
          } : null,
        },
        popularity: {
          followers: followersSnapshot.data().count,
        },
        generated_at: new Date().toISOString(),
      };

      // Cache the results
      await cache.setAnalyticsCache(cacheKey, insights, 3600); // 1 hour

      logger.info("League insights calculated and cached", { leagueId, season });
      return insights;

    } catch (error) {
      logger.error("Failed to get league insights", error as Error, { leagueId, season });
      throw error;
    }
  })
);

/**
 * Refresh user's favorite teams data from external API
 */
export const refreshUserData = functions.https.onCall(
  ErrorHandler.wrapCallableHandler(async (data, context) => {
    // Authenticate user
    const userContext = await authService.authenticateCallable(context);
    const userId = userContext.uid;

    // Rate limiting - more restrictive for intensive operations
    const rateLimit = await rateLimiter.checkLimit(
      "refreshUserData",
      RateLimitConfigs.API_INTENSIVE,
      userId
    );

    if (!rateLimit.allowed) {
      throw new functions.https.HttpsError(
        "resource-exhausted",
        "Rate limit exceeded. Please try again later.",
        { resetTime: rateLimit.resetTime.toISOString() }
      );
    }

    try {
      logger.info("Starting user data refresh", { userId });

      // Get user's favorite teams
      const favoritesSnapshot = await db.collection("user_favorites")
        .where("user_id", "==", userId)
        .where("type", "==", "team")
        .get();

      if (favoritesSnapshot.empty) {
        return {
          message: "No favorite teams to refresh",
          refreshed_teams: 0,
        };
      }

      const favoriteTeamIds = favoritesSnapshot.docs.map(doc => doc.data().entity_id);
      let refreshedCount = 0;
      const errors: string[] = [];

      // Refresh data for each favorite team
      for (const teamId of favoriteTeamIds) {
        try {
          // Get team's league information
          const teamSnapshot = await db.collection("teams")
            .where("api_team_id", "==", parseInt(teamId))
            .limit(1)
            .get();

          if (teamSnapshot.empty) {
            errors.push(`Team ${teamId} not found in database`);
            continue;
          }

          const teamData = teamSnapshot.docs[0].data();
          const leagueDoc = await db.collection("leagues").doc(teamData.league_id).get();
          
          if (!leagueDoc.exists) {
            errors.push(`League not found for team ${teamId}`);
            continue;
          }

          const leagueData = leagueDoc.data();
          const season = leagueData?.season || 2025;

          // Fetch fresh team statistics
          const teamStats = await footballApi.fetchTeamStatistics(
            leagueData.api_league_id,
            parseInt(teamId),
            season
          );

          if (teamStats) {
            // Update team statistics in database
            const statsData = {
              team_id: teamId,
              league_id: teamData.league_id,
              season,
              ...teamStats,
              updated_at: admin.firestore.Timestamp.now(),
            };

            const existingStatsSnapshot = await db.collection("team_statistics")
              .where("team_id", "==", teamId)
              .where("league_id", "==", teamData.league_id)
              .where("season", "==", season)
              .limit(1)
              .get();

            if (existingStatsSnapshot.empty) {
              await db.collection("team_statistics").add(statsData);
            } else {
              const docId = existingStatsSnapshot.docs[0].id;
              await db.collection("team_statistics").doc(docId).update(statsData);
            }

            refreshedCount++;
          }

          // Add small delay to avoid API rate limits
          await new Promise(resolve => setTimeout(resolve, 500));

        } catch (error) {
          const errorMessage = `Failed to refresh team ${teamId}: ${(error as Error).message}`;
          errors.push(errorMessage);
          logger.warn(errorMessage, { userId, teamId });
        }
      }

      // Clear user's cached analytics
      await cache.delete(`user_stats_${userId}`);
      
      // Send notification about refresh completion
      await db.collection("notifications").add({
        user_id: userId,
        title: "Data Refresh Complete",
        message: `Refreshed data for ${refreshedCount} of your favorite teams.`,
        type: refreshedCount > 0 ? "success" : "warning",
        data: {
          refresh_results: {
            refreshed_teams: refreshedCount,
            total_teams: favoriteTeamIds.length,
            errors_count: errors.length,
          },
        },
        read: false,
        created_at: admin.firestore.Timestamp.now(),
      });

      logger.info("User data refresh completed", { 
        userId, 
        refreshedCount, 
        totalTeams: favoriteTeamIds.length, 
        errorsCount: errors.length 
      });

      return {
        message: "Data refresh completed",
        refreshed_teams: refreshedCount,
        total_teams: favoriteTeamIds.length,
        errors: errors.length > 0 ? errors : undefined,
      };

    } catch (error) {
      logger.error("Failed to refresh user data", error as Error, { userId });
      throw error;
    }
  })
);