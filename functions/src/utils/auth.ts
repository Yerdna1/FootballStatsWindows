import * as admin from "firebase-admin";
import * as functions from "firebase-functions";
import { logger } from "./logger";
import { throwUnauthorized, throwForbidden } from "./error-handler";

export interface AuthContext {
  uid: string;
  email?: string;
  role?: string;
  permissions?: string[];
}

export enum UserRole {
  USER = "user",
  MODERATOR = "moderator",
  ADMIN = "admin",
}

export enum Permission {
  READ_USERS = "read:users",
  WRITE_USERS = "write:users",
  DELETE_USERS = "delete:users",
  MANAGE_LEAGUES = "manage:leagues",
  MANAGE_TEAMS = "manage:teams",
  MANAGE_FIXTURES = "manage:fixtures",
  MANAGE_STATISTICS = "manage:statistics",
  VIEW_ANALYTICS = "view:analytics",
  MANAGE_NOTIFICATIONS = "manage:notifications",
  SYSTEM_ADMIN = "system:admin",
}

export class AuthService {
  private static instance: AuthService;
  private db = admin.firestore();

  private constructor() {}

  public static getInstance(): AuthService {
    if (!AuthService.instance) {
      AuthService.instance = new AuthService();
    }
    return AuthService.instance;
  }

  /**
   * Verify Firebase ID token and get user context
   */
  public async verifyToken(idToken: string): Promise<AuthContext> {
    try {
      const decodedToken = await admin.auth().verifyIdToken(idToken);
      
      // Get user permissions from Firestore
      const userPermissions = await this.getUserPermissions(decodedToken.uid);
      
      return {
        uid: decodedToken.uid,
        email: decodedToken.email,
        role: userPermissions?.role,
        permissions: userPermissions?.permissions.flatMap(p => p.actions) || [],
      };
    } catch (error) {
      logger.error("Token verification failed", error as Error);
      throwUnauthorized("Invalid or expired token");
    }
  }

  /**
   * Extract and verify authorization from request headers
   */
  public async authenticateRequest(req: functions.Request): Promise<AuthContext> {
    const authHeader = req.headers.authorization;
    
    if (!authHeader || !authHeader.startsWith("Bearer ")) {
      throwUnauthorized("Authorization header missing or invalid");
    }

    const idToken = authHeader.substring(7);
    return this.verifyToken(idToken);
  }

  /**
   * Verify callable function context
   */
  public async authenticateCallable(
    context: functions.https.CallableContext
  ): Promise<AuthContext> {
    if (!context.auth) {
      throwUnauthorized("Authentication required");
    }

    const userPermissions = await this.getUserPermissions(context.auth.uid);
    
    return {
      uid: context.auth.uid,
      email: context.auth.token.email,
      role: userPermissions?.role,
      permissions: userPermissions?.permissions.flatMap(p => p.actions) || [],
    };
  }

  /**
   * Get user permissions from Firestore
   */
  public async getUserPermissions(userId: string): Promise<{
    role: string;
    permissions: Array<{ resource: string; actions: string[] }>;
  } | null> {
    try {
      const doc = await this.db.collection("user_permissions").doc(userId).get();
      
      if (!doc.exists) {
        // Return default user permissions
        return {
          role: UserRole.USER,
          permissions: [
            { resource: "own_data", actions: ["read", "write"] },
            { resource: "public_data", actions: ["read"] },
          ],
        };
      }

      const data = doc.data();
      return data as { role: string; permissions: Array<{ resource: string; actions: string[] }> };
    } catch (error) {
      logger.error("Failed to get user permissions", error as Error, { userId });
      return null;
    }
  }

  /**
   * Check if user has required role
   */
  public requireRole(userContext: AuthContext, requiredRole: UserRole): void {
    if (!userContext.role) {
      throwForbidden("User role not defined");
    }

    const roleHierarchy = {
      [UserRole.USER]: 1,
      [UserRole.MODERATOR]: 2,
      [UserRole.ADMIN]: 3,
    };

    const userRoleLevel = roleHierarchy[userContext.role as UserRole] || 0;
    const requiredRoleLevel = roleHierarchy[requiredRole];

    if (userRoleLevel < requiredRoleLevel) {
      throwForbidden(`Requires ${requiredRole} role or higher`);
    }
  }

  /**
   * Check if user has specific permission
   */
  public requirePermission(userContext: AuthContext, permission: Permission): void {
    if (!userContext.permissions || !userContext.permissions.includes(permission)) {
      throwForbidden(`Missing required permission: ${permission}`);
    }
  }

  /**
   * Check if user can access resource (either owns it or has admin rights)
   */
  public requireOwnershipOrAdmin(
    userContext: AuthContext,
    resourceUserId: string
  ): void {
    if (
      userContext.uid !== resourceUserId &&
      userContext.role !== UserRole.ADMIN
    ) {
      throwForbidden("Access denied: not owner or admin");
    }
  }

  /**
   * Create or update user permissions
   */
  public async setUserPermissions(
    userId: string,
    role: UserRole,
    customPermissions?: Array<{ resource: string; actions: string[] }>,
    grantedBy?: string
  ): Promise<void> {
    try {
      const defaultPermissions = this.getDefaultPermissions(role);
      const permissions = customPermissions || defaultPermissions;

      await this.db.collection("user_permissions").doc(userId).set({
        user_id: userId,
        role,
        permissions,
        granted_at: admin.firestore.Timestamp.now(),
        granted_by: grantedBy || "system",
      });

      logger.info("User permissions updated", {
        userId,
        role,
        grantedBy,
      });
    } catch (error) {
      logger.error("Failed to set user permissions", error as Error, { userId, role });
      throw error;
    }
  }

  /**
   * Remove user permissions
   */
  public async removeUserPermissions(userId: string): Promise<void> {
    try {
      await this.db.collection("user_permissions").doc(userId).delete();
      logger.info("User permissions removed", { userId });
    } catch (error) {
      logger.error("Failed to remove user permissions", error as Error, { userId });
      throw error;
    }
  }

  /**
   * Get default permissions for a role
   */
  private getDefaultPermissions(role: UserRole): Array<{ resource: string; actions: string[] }> {
    switch (role) {
      case UserRole.USER:
        return [
          { resource: "own_data", actions: ["read", "write"] },
          { resource: "public_data", actions: ["read"] },
          { resource: "favorites", actions: ["read", "write", "delete"] },
          { resource: "notifications", actions: ["read", "write"] },
        ];

      case UserRole.MODERATOR:
        return [
          { resource: "own_data", actions: ["read", "write"] },
          { resource: "public_data", actions: ["read", "write"] },
          { resource: "favorites", actions: ["read", "write", "delete"] },
          { resource: "notifications", actions: ["read", "write", "delete"] },
          { resource: "leagues", actions: ["read", "write"] },
          { resource: "teams", actions: ["read", "write"] },
          { resource: "fixtures", actions: ["read", "write"] },
          { resource: "statistics", actions: ["read", "write"] },
        ];

      case UserRole.ADMIN:
        return [
          { resource: "*", actions: ["*"] }, // Full access
        ];

      default:
        return [
          { resource: "public_data", actions: ["read"] },
        ];
    }
  }

  /**
   * Validate API key for external integrations
   */
  public async validateApiKey(apiKey: string): Promise<boolean> {
    try {
      // In a real implementation, you would store API keys in Firestore
      // For now, we'll use environment variables
      const validApiKeys = functions.config().api?.keys?.split(",") || [];
      return validApiKeys.includes(apiKey);
    } catch (error) {
      logger.error("API key validation failed", error as Error);
      return false;
    }
  }

  /**
   * Generate API key for service-to-service communication
   */
  public generateApiKey(): string {
    return `fsa_${Date.now()}_${Math.random().toString(36).substring(2, 15)}`;
  }
}

export const authService = AuthService.getInstance();

// Middleware for Express routes
export const authenticateMiddleware = async (
  req: functions.Request & { user?: AuthContext },
  res: functions.Response,
  next: functions.NextFunction
): Promise<void> => {
  try {
    req.user = await authService.authenticateRequest(req);
    next();
  } catch (error) {
    res.status(401).json({
      error: {
        code: "UNAUTHORIZED",
        message: "Authentication required",
        timestamp: new Date().toISOString(),
      },
    });
  }
};

export const requireRoleMiddleware = (requiredRole: UserRole) => {
  return (
    req: functions.Request & { user?: AuthContext },
    res: functions.Response,
    next: functions.NextFunction
  ): void => {
    try {
      if (!req.user) {
        throw new Error("User not authenticated");
      }
      authService.requireRole(req.user, requiredRole);
      next();
    } catch (error) {
      res.status(403).json({
        error: {
          code: "FORBIDDEN",
          message: (error as Error).message,
          timestamp: new Date().toISOString(),
        },
      });
    }
  };
};