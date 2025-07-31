import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

export enum LogLevel {
  DEBUG = "debug",
  INFO = "info",
  WARN = "warn",
  ERROR = "error"
}

export interface LogContext {
  userId?: string;
  requestId?: string;
  functionName?: string;
  endpoint?: string;
  metadata?: Record<string, any>;
}

export class Logger {
  private static instance: Logger;
  private db = admin.firestore();

  private constructor() {}

  public static getInstance(): Logger {
    if (!Logger.instance) {
      Logger.instance = new Logger();
    }
    return Logger.instance;
  }

  public debug(message: string, context?: LogContext): void {
    this.log(LogLevel.DEBUG, message, context);
  }

  public info(message: string, context?: LogContext): void {
    this.log(LogLevel.INFO, message, context);
  }

  public warn(message: string, context?: LogContext): void {
    this.log(LogLevel.WARN, message, context);
  }

  public error(message: string, error?: Error, context?: LogContext): void {
    const errorContext = {
      ...context,
      error: error ? {
        name: error.name,
        message: error.message,
        stack: error.stack,
      } : undefined,
    };
    this.log(LogLevel.ERROR, message, errorContext);
  }

  private log(level: LogLevel, message: string, context?: LogContext): void {
    const logEntry = {
      level,
      message,
      timestamp: admin.firestore.Timestamp.now(),
      ...context,
    };

    // Console logging for Cloud Functions
    switch (level) {
      case LogLevel.DEBUG:
        functions.logger.debug(message, logEntry);
        break;
      case LogLevel.INFO:
        functions.logger.info(message, logEntry);
        break;
      case LogLevel.WARN:
        functions.logger.warn(message, logEntry);
        break;
      case LogLevel.ERROR:
        functions.logger.error(message, logEntry);
        break;
    }

    // Store activity logs in Firestore for audit trail
    if (level === LogLevel.ERROR || level === LogLevel.WARN) {
      this.storeActivityLog(level, message, context);
    }
  }

  private async storeActivityLog(
    level: LogLevel,
    message: string,
    context?: LogContext
  ): Promise<void> {
    try {
      await this.db.collection("activity_logs").add({
        user_id: context?.userId || null,
        action_type: level,
        resource_type: "system",
        resource_id: context?.functionName || null,
        details: {
          message,
          endpoint: context?.endpoint,
          metadata: context?.metadata,
        },
        ip_address: null,
        user_agent: null,
        timestamp: admin.firestore.Timestamp.now(),
      });
    } catch (error) {
      functions.logger.error("Failed to store activity log", { error });
    }
  }

  public async logUserActivity(
    userId: string,
    actionType: string,
    resourceType: string,
    resourceId?: string,
    details?: Record<string, any>,
    ipAddress?: string,
    userAgent?: string
  ): Promise<void> {
    try {
      await this.db.collection("activity_logs").add({
        user_id: userId,
        action_type: actionType,
        resource_type: resourceType,
        resource_id: resourceId || null,
        details: details || {},
        ip_address: ipAddress || null,
        user_agent: userAgent || null,
        timestamp: admin.firestore.Timestamp.now(),
      });
    } catch (error) {
      this.error("Failed to log user activity", error, { userId, actionType });
    }
  }
}

export const logger = Logger.getInstance();