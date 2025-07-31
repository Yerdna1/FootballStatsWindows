import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import { logger } from "../utils/logger";
import { cache } from "../utils/cache";
import { footballApi } from "../services/football-api";
import { 
  transformLeagueData,
  transformTeamData,
  transformFixtureData,
  transformStandingData,
  transformTeamStatisticsData
} from "../utils/transformers";

const db = admin.firestore();

/**
 * Scheduled function to refresh football data from API
 * Runs every 6 hours during active season
 */
export const refreshFootballData = functions.pubsub
  .schedule("0 */6 * * *") // Every 6 hours
  .timeZone("UTC")
  .onRun(async (context) => {
    logger.info("Starting scheduled football data refresh");

    try {
      const results = {
        leagues: 0,
        teams: 0,
        fixtures: 0,
        standings: 0,
        statistics: 0,
        errors: 0,
      };

      // Get active leagues from Firestore
      const leaguesSnapshot = await db.collection("leagues")
        .where("is_active", "==", true)
        .get();

      const activeLeagues = leaguesSnapshot.docs.map(doc => ({
        id: doc.id,
        ...doc.data()
      }));

      logger.info(`Found ${activeLeagues.length} active leagues to refresh`);

      // Process each league
      for (const league of activeLeagues) {
        try {
          const leagueId = league.api_league_id;
          const season = league.season || 2025;

          // Refresh fixtures
          try {
            const fixtures = await footballApi.fetchFixtures(leagueId, season);
            
            for (const apiFixture of fixtures) {
              try {
                const fixtureData = transformFixtureData(apiFixture, league.id);
                
                // Check if fixture exists
                const existingSnapshot = await db.collection("fixtures")
                  .where("api_fixture_id", "==", fixtureData.api_fixture_id)
                  .limit(1)
                  .get();

                if (existingSnapshot.empty) {
                  await db.collection("fixtures").add(fixtureData);
                } else {
                  const docId = existingSnapshot.docs[0].id;
                  await db.collection("fixtures").doc(docId).update({
                    ...fixtureData,
                    updated_at: admin.firestore.Timestamp.now(),
                  });
                }
                results.fixtures++;
              } catch (error) {
                logger.error("Error processing fixture", error as Error, { 
                  fixtureId: apiFixture.fixture.id 
                });
                results.errors++;
              }
            }
          } catch (error) {
            logger.error(`Error fetching fixtures for league ${leagueId}`, error as Error);
            results.errors++;
          }

          // Refresh standings
          try {
            const standings = await footballApi.fetchStandings(leagueId, season);
            
            for (const leagueStanding of standings) {
              for (const standing of leagueStanding.league.standings[0] || []) {
                try {
                  const standingData = transformStandingData(standing, league.id, season);
                  
                  // Check if standing exists
                  const existingSnapshot = await db.collection("standings")
                    .where("league_id", "==", league.id)
                    .where("season", "==", season)
                    .where("team_id", "==", standingData.team_id)
                    .limit(1)
                    .get();

                  if (existingSnapshot.empty) {
                    await db.collection("standings").add(standingData);
                  } else {
                    const docId = existingSnapshot.docs[0].id;
                    await db.collection("standings").doc(docId).update(standingData);
                  }
                  results.standings++;
                } catch (error) {
                  logger.error("Error processing standing", error as Error, { 
                    teamId: standing.team.id 
                  });
                  results.errors++;
                }
              }
            }
          } catch (error) {
            logger.error(`Error fetching standings for league ${leagueId}`, error as Error);
            results.errors++;
          }

          // Refresh teams
          try {
            const teams = await footballApi.fetchTeams(leagueId, season);
            
            for (const apiTeam of teams) {
              try {
                const teamData = transformTeamData(apiTeam, league.id);
                
                // Check if team exists
                const existingSnapshot = await db.collection("teams")
                  .where("api_team_id", "==", teamData.api_team_id)
                  .limit(1)
                  .get();

                if (existingSnapshot.empty) {
                  await db.collection("teams").add(teamData);
                } else {
                  const docId = existingSnapshot.docs[0].id;
                  await db.collection("teams").doc(docId).update({
                    ...teamData,
                    updated_at: admin.firestore.Timestamp.now(),
                  });
                }
                results.teams++;

                // Refresh team statistics
                try {
                  const teamStats = await footballApi.fetchTeamStatistics(
                    leagueId, 
                    apiTeam.team.id, 
                    season
                  );

                  if (teamStats) {
                    const statsData = transformTeamStatisticsData(
                      teamStats,
                      apiTeam.team.id.toString(),
                      league.id,
                      season
                    );

                    // Check if statistics exist
                    const existingStatsSnapshot = await db.collection("team_statistics")
                      .where("team_id", "==", statsData.team_id)
                      .where("league_id", "==", league.id)
                      .where("season", "==", season)
                      .limit(1)
                      .get();

                    if (existingStatsSnapshot.empty) {
                      await db.collection("team_statistics").add(statsData);
                    } else {
                      const docId = existingStatsSnapshot.docs[0].id;
                      await db.collection("team_statistics").doc(docId).update(statsData);
                    }
                    results.statistics++;
                  }
                } catch (error) {
                  logger.warn(`Error fetching statistics for team ${apiTeam.team.id}`, {
                    error: (error as Error).message,
                    teamId: apiTeam.team.id,
                  });
                }
              } catch (error) {
                logger.error("Error processing team", error as Error, { 
                  teamId: apiTeam.team.id 
                });
                results.errors++;
              }
            }
          } catch (error) {
            logger.error(`Error fetching teams for league ${leagueId}`, error as Error);
            results.errors++;
          }

          // Add small delay between leagues to avoid API rate limits
          await new Promise(resolve => setTimeout(resolve, 1000));

        } catch (error) {
          logger.error(`Error processing league ${league.id}`, error as Error);
          results.errors++;
        }
      }

      logger.info("Football data refresh completed", results);

      // Store refresh statistics
      await db.collection("system_logs").add({
        type: "data_refresh",
        results,
        timestamp: admin.firestore.Timestamp.now(),
      });

    } catch (error) {
      logger.error("Football data refresh failed", error as Error);
      throw error;
    }
  });

/**
 * Scheduled function to clean up expired cache entries
 * Runs daily at 2 AM UTC
 */
export const cleanupExpiredCache = functions.pubsub
  .schedule("0 2 * * *") // Daily at 2 AM UTC
  .timeZone("UTC")
  .onRun(async (context) => {
    logger.info("Starting cache cleanup");

    try {
      const apiCacheCleanup = await cache.cleanupExpired();
      
      // Clean up analytics cache
      const now = admin.firestore.Timestamp.now();
      const expiredAnalyticsSnapshot = await db.collection("analytics_cache")
        .where("expires_at", "<", now)
        .limit(500)
        .get();

      let analyticsCleanup = 0;
      if (!expiredAnalyticsSnapshot.empty) {
        const batch = db.batch();
        expiredAnalyticsSnapshot.docs.forEach(doc => {
          batch.delete(doc.ref);
        });
        await batch.commit();
        analyticsCleanup = expiredAnalyticsSnapshot.size;
      }

      // Clean up rate limits
      const expiredRateLimitsSnapshot = await db.collection("rate_limits")
        .where("expires_at", "<", now)
        .limit(500)
        .get();

      let rateLimitsCleanup = 0;
      if (!expiredRateLimitsSnapshot.empty) {
        const batch = db.batch();
        expiredRateLimitsSnapshot.docs.forEach(doc => {
          batch.delete(doc.ref);
        });
        await batch.commit();
        rateLimitsCleanup = expiredRateLimitsSnapshot.size;
      }

      const results = {
        api_cache: apiCacheCleanup,
        analytics_cache: analyticsCleanup,
        rate_limits: rateLimitsCleanup,
      };

      logger.info("Cache cleanup completed", results);

      // Store cleanup statistics
      await db.collection("system_logs").add({
        type: "cache_cleanup",
        results,
        timestamp: admin.firestore.Timestamp.now(),
      });

    } catch (error) {
      logger.error("Cache cleanup failed", error as Error);
      throw error;
    }
  });

/**
 * Scheduled function to generate analytics and insights
 * Runs daily at 4 AM UTC
 */
export const generateAnalytics = functions.pubsub
  .schedule("0 4 * * *") // Daily at 4 AM UTC
  .timeZone("UTC")
  .onRun(async (context) => {
    logger.info("Starting analytics generation");

    try {
      const results = {
        league_analytics: 0,
        team_analytics: 0,
        user_analytics: 0,
        errors: 0,
      };

      // Generate league analytics
      try {
        const leaguesSnapshot = await db.collection("leagues")
          .where("is_active", "==", true)
          .get();

        for (const leagueDoc of leaguesSnapshot.docs) {
          try {
            const leagueId = leagueDoc.id;
            const leagueData = leagueDoc.data();

            // Calculate league statistics
            const [teamsSnapshot, fixturesSnapshot, standingsSnapshot] = await Promise.all([
              db.collection("teams").where("league_id", "==", leagueId).count().get(),
              db.collection("fixtures").where("league_id", "==", leagueId).count().get(),
              db.collection("standings").where("league_id", "==", leagueId).count().get(),
            ]);

            const analytics = {
              league_id: leagueId,
              total_teams: teamsSnapshot.data().count,
              total_fixtures: fixturesSnapshot.data().count,
              total_standings: standingsSnapshot.data().count,
              last_updated: admin.firestore.Timestamp.now(),
            };

            // Store analytics
            await cache.setAnalyticsCache(`league_analytics_${leagueId}`, analytics, 86400); // 24 hours
            results.league_analytics++;

          } catch (error) {
            logger.error(`Error generating analytics for league ${leagueDoc.id}`, error as Error);
            results.errors++;
          }
        }
      } catch (error) {
        logger.error("Error in league analytics generation", error as Error);
        results.errors++;
      }

      // Generate user analytics
      try {
        const [usersSnapshot, favoritesSnapshot] = await Promise.all([
          db.collection("users").count().get(),
          db.collection("user_favorites").count().get(),
        ]);

        const userAnalytics = {
          total_users: usersSnapshot.data().count,
          total_favorites: favoritesSnapshot.data().count,
          generated_at: admin.firestore.Timestamp.now(),
        };

        await cache.setAnalyticsCache("user_analytics", userAnalytics, 86400);
        results.user_analytics++;
      } catch (error) {
        logger.error("Error generating user analytics", error as Error);
        results.errors++;
      }

      logger.info("Analytics generation completed", results);

      // Store generation statistics
      await db.collection("system_logs").add({
        type: "analytics_generation",
        results,
        timestamp: admin.firestore.Timestamp.now(),
      });

    } catch (error) {
      logger.error("Analytics generation failed", error as Error);
      throw error;
    }
  });

/**
 * Scheduled function to send pending notifications
 * Runs every 30 minutes
 */
export const sendNotifications = functions.pubsub
  .schedule("*/30 * * * *") // Every 30 minutes
  .timeZone("UTC")
  .onRun(async (context) => {
    logger.info("Starting notification processing");

    try {
      const results = {
        processed: 0,
        sent: 0,
        failed: 0,
      };

      // Get pending notifications (could be expanded with FCM integration)
      const pendingSnapshot = await db.collection("notifications")
        .where("read", "==", false)
        .orderBy("created_at", "desc")
        .limit(100)
        .get();

      for (const notificationDoc of pendingSnapshot.docs) {
        try {
          const notification = notificationDoc.data();
          
          // Here you would integrate with FCM or other notification services
          // For now, we'll just mark as processed
          
          logger.debug("Processing notification", {
            notificationId: notificationDoc.id,
            userId: notification.user_id,
            type: notification.type,
          });

          results.processed++;
          // In a real implementation, increment sent or failed based on delivery result
          results.sent++;

        } catch (error) {
          logger.error(`Error processing notification ${notificationDoc.id}`, error as Error);
          results.failed++;
        }
      }

      logger.info("Notification processing completed", results);

      if (results.processed > 0) {
        await db.collection("system_logs").add({
          type: "notification_processing",
          results,
          timestamp: admin.firestore.Timestamp.now(),
        });
      }

    } catch (error) {
      logger.error("Notification processing failed", error as Error);
      throw error;
    }
  });