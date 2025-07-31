import { Router } from "express";
import * as admin from "firebase-admin";
import { logger } from "../../utils/logger";
import { ErrorHandler } from "../../utils/error-handler";
import { authenticateMiddleware, requireRoleMiddleware, UserRole } from "../../utils/auth";
import { rateLimiter, RateLimitConfigs } from "../../utils/rate-limiter";
import { validateRequest, LeagueQuerySchema, LeagueCreateSchema } from "../../utils/validation";
import { transformForApiResponse, transformFirestoreQuery } from "../../utils/transformers";
import { footballApi } from "../../services/football-api";
import { throwNotFound, throwValidation } from "../../utils/error-handler";

export const leaguesRouter = Router();
const db = admin.firestore();

/**
 * GET /api/v1/leagues
 * Get all leagues with optional filtering
 */
leaguesRouter.get("/", ErrorHandler.wrapAsyncHandler(async (req, res) => {
  const clientIp = req.ip || req.connection.remoteAddress || "unknown";
  
  // Rate limiting
  const rateLimit = await rateLimiter.checkLimit(
    "leagues:list",
    RateLimitConfigs.API_GENERAL,
    (req as any).user?.uid,
    clientIp
  );

  if (!rateLimit.allowed) {
    return res.status(429).json({
      error: {
        code: "RATE_LIMIT_EXCEEDED",
        message: "Too many requests",
        resetTime: rateLimit.resetTime.toISOString(),
      },
    });
  }

  // Validate query parameters
  const queryParams = validateRequest(LeagueQuerySchema, req.query);

  // Build Firestore query
  let query = db.collection("leagues").where("is_active", "==", true);

  if (queryParams.country) {
    query = query.where("country", "==", queryParams.country);
  }

  if (queryParams.season) {
    query = query.where("season", "==", queryParams.season);
  }

  // Add ordering
  query = query.orderBy("country").orderBy("name");

  // Add pagination
  const page = parseInt(queryParams.page || "1");
  const limit = parseInt(queryParams.limit || "20");
  const offset = (page - 1) * limit;

  if (offset > 0) {
    const offsetSnapshot = await query.limit(offset).get();
    if (!offsetSnapshot.empty) {
      const lastDoc = offsetSnapshot.docs[offsetSnapshot.docs.length - 1];
      query = query.startAfter(lastDoc);
    }
  }

  query = query.limit(limit);

  // Execute query
  const snapshot = await query.get();
  const leagues = transformFirestoreQuery(snapshot);

  // Get total count for pagination
  const totalSnapshot = await db.collection("leagues")
    .where("is_active", "==", true)
    .count()
    .get();
  const total = totalSnapshot.data().count;

  logger.info("Leagues retrieved", {
    count: leagues.length,
    total,
    page,
    limit,
  });

  res.json({
    data: leagues,
    pagination: {
      page,
      limit,
      total,
      pages: Math.ceil(total / limit),
    },
  });
}));

/**
 * GET /api/v1/leagues/:id
 * Get specific league by ID
 */
leaguesRouter.get("/:id", ErrorHandler.wrapAsyncHandler(async (req, res) => {
  const leagueId = req.params.id;
  
  const doc = await db.collection("leagues").doc(leagueId).get();
  
  if (!doc.exists) {
    throwNotFound("League");
  }

  const league = transformForApiResponse(doc.data());
  league.id = doc.id;

  logger.info("League retrieved", { leagueId });

  res.json({ data: league });
}));

/**
 * POST /api/v1/leagues
 * Create new league (Admin only)
 */
leaguesRouter.post("/", 
  authenticateMiddleware,
  requireRoleMiddleware(UserRole.ADMIN),
  ErrorHandler.wrapAsyncHandler(async (req, res) => {
    const leagueData = validateRequest(LeagueCreateSchema, req.body);
    const userId = (req as any).user.uid;

    // Check if league with same API ID already exists
    const existingSnapshot = await db.collection("leagues")
      .where("api_league_id", "==", leagueData.api_league_id)
      .limit(1)
      .get();

    if (!existingSnapshot.empty) {
      throwValidation("League with this API ID already exists");
    }

    // Create league document
    const newLeague = {
      ...leagueData,
      is_active: true,
      created_at: admin.firestore.Timestamp.now(),
    };

    const docRef = await db.collection("leagues").add(newLeague);
    const createdDoc = await docRef.get();
    const league = transformForApiResponse(createdDoc.data());
    league.id = docRef.id;

    logger.info("League created", { leagueId: docRef.id, userId });

    res.status(201).json({ data: league });
  })
);

/**
 * PUT /api/v1/leagues/:id
 * Update league (Moderator+)
 */
leaguesRouter.put("/:id",
  authenticateMiddleware,
  requireRoleMiddleware(UserRole.MODERATOR),
  ErrorHandler.wrapAsyncHandler(async (req, res) => {
    const leagueId = req.params.id;
    const updateData = validateRequest(LeagueCreateSchema.partial(), req.body);
    const userId = (req as any).user.uid;

    // Check if league exists
    const doc = await db.collection("leagues").doc(leagueId).get();
    if (!doc.exists) {
      throwNotFound("League");
    }

    // Update league
    const updatedData = {
      ...updateData,
      updated_at: admin.firestore.Timestamp.now(),
    };

    await db.collection("leagues").doc(leagueId).update(updatedData);
    
    // Get updated document
    const updatedDoc = await db.collection("leagues").doc(leagueId).get();
    const league = transformForApiResponse(updatedDoc.data());
    league.id = leagueId;

    logger.info("League updated", { leagueId, userId });

    res.json({ data: league });
  })
);

/**
 * DELETE /api/v1/leagues/:id
 * Soft delete league (Admin only)
 */
leaguesRouter.delete("/:id",
  authenticateMiddleware,
  requireRoleMiddleware(UserRole.ADMIN),
  ErrorHandler.wrapAsyncHandler(async (req, res) => {
    const leagueId = req.params.id;
    const userId = (req as any).user.uid;

    // Check if league exists
    const doc = await db.collection("leagues").doc(leagueId).get();
    if (!doc.exists) {
      throwNotFound("League");
    }

    // Soft delete by setting is_active to false
    await db.collection("leagues").doc(leagueId).update({
      is_active: false,
      deleted_at: admin.firestore.Timestamp.now(),
    });

    logger.info("League soft deleted", { leagueId, userId });

    res.status(204).send();
  })
);

/**
 * POST /api/v1/leagues/sync
 * Sync leagues from Football API (Admin only)
 */
leaguesRouter.post("/sync",
  authenticateMiddleware,
  requireRoleMiddleware(UserRole.ADMIN),
  ErrorHandler.wrapAsyncHandler(async (req, res) => {
    const userId = (req as any).user.uid;

    logger.info("Starting league sync", { userId });

    try {
      // Fetch leagues from Football API
      const apiLeagues = await footballApi.fetchLeagues();
      
      let created = 0;
      let updated = 0;
      let errors = 0;

      // Process leagues in batches to avoid overwhelming Firestore
      const batchSize = 500;
      for (let i = 0; i < apiLeagues.length; i += batchSize) {
        const batch = apiLeagues.slice(i, i + batchSize);
        
        const promises = batch.map(async (apiLeague: any) => {
          try {
            const leagueData = {
              api_league_id: apiLeague.league.id,
              name: apiLeague.league.name,
              country: apiLeague.country.name,
              logo: apiLeague.league.logo,
              flag: apiLeague.country.flag,
              season: apiLeague.seasons?.[0]?.year || new Date().getFullYear(),
              is_active: true,
            };

            // Check if league exists
            const existingSnapshot = await db.collection("leagues")
              .where("api_league_id", "==", leagueData.api_league_id)
              .limit(1)
              .get();

            if (existingSnapshot.empty) {
              // Create new league
              await db.collection("leagues").add({
                ...leagueData,
                created_at: admin.firestore.Timestamp.now(),
              });
              created++;
            } else {
              // Update existing league
              const docId = existingSnapshot.docs[0].id;
              await db.collection("leagues").doc(docId).update({
                ...leagueData,
                updated_at: admin.firestore.Timestamp.now(),
              });
              updated++;
            }
          } catch (error) {
            logger.error("Error processing league", error as Error, {
              leagueId: apiLeague.league.id,
              leagueName: apiLeague.league.name,
            });
            errors++;
          }
        });

        await Promise.all(promises);
      }

      logger.info("League sync completed", { 
        total: apiLeagues.length,
        created,
        updated,
        errors,
        userId 
      });

      res.json({
        message: "League sync completed",
        stats: {
          total: apiLeagues.length,
          created,
          updated,
          errors,
        },
      });
    } catch (error) {
      logger.error("League sync failed", error as Error, { userId });
      throw error;
    }
  })
);