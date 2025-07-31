import * as express from "express";
import * as cors from "cors";
import { logger } from "../utils/logger";
import { ErrorHandler } from "../utils/error-handler";

// Import route modules
import { leaguesRouter } from "./routes/leagues";
import { teamsRouter } from "./routes/teams";
import { fixturesRouter } from "./routes/fixtures";
import { standingsRouter } from "./routes/standings";
import { usersRouter } from "./routes/users";
import { favoritesRouter } from "./routes/favorites";
import { notificationsRouter } from "./routes/notifications";
import { analyticsRouter } from "./routes/analytics";
import { adminRouter } from "./routes/admin";

// Create Express app
export const app = express();

// Middleware
app.use(cors({
  origin: true, // Allow all origins in development, configure for production
  credentials: true,
}));

app.use(express.json({ limit: "10mb" }));
app.use(express.urlencoded({ extended: true }));

// Request logging middleware
app.use((req, res, next) => {
  const requestId = `req_${Date.now()}_${Math.random().toString(36).substring(2, 9)}`;
  (req as any).requestId = requestId;

  logger.info(`${req.method} ${req.path}`, {
    requestId,
    method: req.method,
    path: req.path,
    userAgent: req.get("User-Agent"),
    ip: req.ip,
  });

  next();
});

// Health check endpoint
app.get("/health", (req, res) => {
  res.json({
    status: "healthy",
    timestamp: new Date().toISOString(),
    version: "1.0.0",
  });
});

// API version prefix
const apiV1 = express.Router();

// Mount route modules
apiV1.use("/leagues", leaguesRouter);
apiV1.use("/teams", teamsRouter);
apiV1.use("/fixtures", fixturesRouter);
apiV1.use("/standings", standingsRouter);
apiV1.use("/users", usersRouter);
apiV1.use("/favorites", favoritesRouter);
apiV1.use("/notifications", notificationsRouter);
apiV1.use("/analytics", analyticsRouter);
apiV1.use("/admin", adminRouter);

// Mount API v1
app.use("/api/v1", apiV1);

// 404 handler
app.use("*", (req, res) => {
  res.status(404).json({
    error: {
      code: "NOT_FOUND",
      message: `Route ${req.method} ${req.originalUrl} not found`,
      timestamp: new Date().toISOString(),
    },
  });
});

// Global error handler
app.use((
  error: Error,
  req: express.Request,
  res: express.Response,
  next: express.NextFunction
) => {
  ErrorHandler.handleHttpError(error, res, {
    method: req.method,
    url: req.url,
    requestId: (req as any).requestId,
  });
});

logger.info("Express app configured successfully");