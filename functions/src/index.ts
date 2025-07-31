import * as admin from "firebase-admin";
import * as functions from "firebase-functions";

// Initialize Firebase Admin SDK
admin.initializeApp();

// Import all function modules
import * as apiRoutes from "./api";
import * as authTriggers from "./triggers/auth";
import * as scheduledJobs from "./scheduled";

// Export API functions
export const api = functions.https.onRequest(apiRoutes.app);

// Export Authentication Triggers
export const createUserRecord = authTriggers.createUserRecord;
export const deleteUserData = authTriggers.deleteUserData;

// Export Scheduled Functions
export const refreshFootballData = scheduledJobs.refreshFootballData;
export const cleanupExpiredCache = scheduledJobs.cleanupExpiredCache;
export const generateAnalytics = scheduledJobs.generateAnalytics;
export const sendNotifications = scheduledJobs.sendNotifications;

// Export Firestore Triggers
export { onUserFavoriteChange } from "./triggers/firestore";

// Export Callable Functions
export { 
  getUserStats,
  getTeamAnalytics,
  getLeagueInsights,
  refreshUserData
} from "./api/callable";

console.log("Firebase Functions initialized successfully");