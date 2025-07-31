import * as functions from "firebase-functions";
import { logger } from "./logger";

export enum ErrorCode {
  // Authentication errors
  UNAUTHORIZED = "UNAUTHORIZED",
  FORBIDDEN = "FORBIDDEN",
  INVALID_TOKEN = "INVALID_TOKEN",
  
  // Validation errors
  VALIDATION_ERROR = "VALIDATION_ERROR",
  INVALID_INPUT = "INVALID_INPUT",
  MISSING_REQUIRED_FIELD = "MISSING_REQUIRED_FIELD",
  
  // Resource errors
  NOT_FOUND = "NOT_FOUND",
  ALREADY_EXISTS = "ALREADY_EXISTS",
  RESOURCE_EXHAUSTED = "RESOURCE_EXHAUSTED",
  
  // External API errors
  EXTERNAL_API_ERROR = "EXTERNAL_API_ERROR",
  API_RATE_LIMIT_EXCEEDED = "API_RATE_LIMIT_EXCEEDED",
  API_TIMEOUT = "API_TIMEOUT",
  
  // Database errors
  DATABASE_ERROR = "DATABASE_ERROR",
  TRANSACTION_FAILED = "TRANSACTION_FAILED",
  
  // System errors
  INTERNAL_ERROR = "INTERNAL_ERROR",
  SERVICE_UNAVAILABLE = "SERVICE_UNAVAILABLE",
  RATE_LIMIT_EXCEEDED = "RATE_LIMIT_EXCEEDED",
}

export class AppError extends Error {
  public readonly code: ErrorCode;
  public readonly statusCode: number;
  public readonly isOperational: boolean;
  public readonly context?: Record<string, any>;

  constructor(
    message: string,
    code: ErrorCode,
    statusCode: number = 500,
    isOperational: boolean = true,
    context?: Record<string, any>
  ) {
    super(message);
    this.name = "AppError";
    this.code = code;
    this.statusCode = statusCode;
    this.isOperational = isOperational;
    this.context = context;

    Error.captureStackTrace(this, this.constructor);
  }
}

export class ValidationError extends AppError {
  constructor(message: string, context?: Record<string, any>) {
    super(message, ErrorCode.VALIDATION_ERROR, 400, true, context);
    this.name = "ValidationError";
  }
}

export class AuthenticationError extends AppError {
  constructor(message: string = "Authentication required", context?: Record<string, any>) {
    super(message, ErrorCode.UNAUTHORIZED, 401, true, context);
    this.name = "AuthenticationError";
  }
}

export class AuthorizationError extends AppError {
  constructor(message: string = "Insufficient permissions", context?: Record<string, any>) {
    super(message, ErrorCode.FORBIDDEN, 403, true, context);
    this.name = "AuthorizationError";
  }
}

export class NotFoundError extends AppError {
  constructor(resource: string, context?: Record<string, any>) {
    super(`${resource} not found`, ErrorCode.NOT_FOUND, 404, true, context);
    this.name = "NotFoundError";
  }
}

export class ConflictError extends AppError {
  constructor(message: string, context?: Record<string, any>) {
    super(message, ErrorCode.ALREADY_EXISTS, 409, true, context);
    this.name = "ConflictError";
  }
}

export class RateLimitError extends AppError {
  constructor(message: string = "Rate limit exceeded", context?: Record<string, any>) {
    super(message, ErrorCode.RATE_LIMIT_EXCEEDED, 429, true, context);
    this.name = "RateLimitError";
  }
}

export class ExternalApiError extends AppError {
  constructor(message: string, context?: Record<string, any>) {
    super(message, ErrorCode.EXTERNAL_API_ERROR, 502, true, context);
    this.name = "ExternalApiError";
  }
}

export interface ErrorResponse {
  error: {
    code: string;
    message: string;
    details?: any;
    timestamp: string;
    requestId?: string;
  };
}

export class ErrorHandler {
  public static handleError(error: Error, context?: Record<string, any>): ErrorResponse {
    let statusCode = 500;
    let errorCode = ErrorCode.INTERNAL_ERROR;
    let message = "An unexpected error occurred";
    let details: any = undefined;

    if (error instanceof AppError) {
      statusCode = error.statusCode;
      errorCode = error.code;
      message = error.message;
      details = error.context;
    } else if (error.name === "ValidationError") {
      statusCode = 400;
      errorCode = ErrorCode.VALIDATION_ERROR;
      message = error.message;
    } else if (error.message.includes("permission-denied")) {
      statusCode = 403;
      errorCode = ErrorCode.FORBIDDEN;
      message = "Permission denied";
    } else if (error.message.includes("not-found")) {
      statusCode = 404;
      errorCode = ErrorCode.NOT_FOUND;
      message = "Resource not found";
    } else if (error.message.includes("already-exists")) {
      statusCode = 409;
      errorCode = ErrorCode.ALREADY_EXISTS;
      message = "Resource already exists";
    }

    // Log the error
    logger.error(`Error handled: ${errorCode}`, error, {
      ...context,
      statusCode,
      errorCode,
    });

    return {
      error: {
        code: errorCode,
        message,
        details,
        timestamp: new Date().toISOString(),
        requestId: context?.requestId,
      },
    };
  }

  public static handleHttpError(
    error: Error, 
    response: functions.Response,
    context?: Record<string, any>
  ): void {
    const errorResponse = this.handleError(error, context);
    let statusCode = 500;

    if (error instanceof AppError) {
      statusCode = error.statusCode;
    } else if (error.name === "ValidationError") {
      statusCode = 400;
    } else if (error.message.includes("permission-denied")) {
      statusCode = 403;
    } else if (error.message.includes("not-found")) {
      statusCode = 404;
    } else if (error.message.includes("already-exists")) {
      statusCode = 409;
    }

    response.status(statusCode).json(errorResponse);
  }

  public static wrapAsyncHandler(
    handler: (req: functions.Request, res: functions.Response) => Promise<void>
  ) {
    return async (req: functions.Request, res: functions.Response): Promise<void> => {
      try {
        await handler(req, res);
      } catch (error) {
        this.handleHttpError(error as Error, res, {
          method: req.method,
          url: req.url,
          userId: (req as any).user?.uid,
        });
      }
    };
  }

  public static wrapCallableHandler<T, R>(
    handler: (data: T, context: functions.https.CallableContext) => Promise<R>
  ) {
    return async (data: T, context: functions.https.CallableContext): Promise<R> => {
      try {
        return await handler(data, context);
      } catch (error) {
        logger.error("Callable function error", error as Error, {
          functionName: context.rawRequest.url,
          userId: context.auth?.uid,
        });

        if (error instanceof AppError) {
          throw new functions.https.HttpsError(
            this.mapToHttpsErrorCode(error.code),
            error.message,
            error.context
          );
        }

        throw new functions.https.HttpsError(
          "internal",
          "An unexpected error occurred",
          { originalError: error instanceof Error ? error.message : String(error) }
        );
      }
    };
  }

  private static mapToHttpsErrorCode(errorCode: ErrorCode): functions.https.FunctionsErrorCode {
    switch (errorCode) {
      case ErrorCode.UNAUTHORIZED:
        return "unauthenticated";
      case ErrorCode.FORBIDDEN:
        return "permission-denied";
      case ErrorCode.NOT_FOUND:
        return "not-found";
      case ErrorCode.ALREADY_EXISTS:
        return "already-exists";
      case ErrorCode.VALIDATION_ERROR:
      case ErrorCode.INVALID_INPUT:
        return "invalid-argument";
      case ErrorCode.RATE_LIMIT_EXCEEDED:
      case ErrorCode.RESOURCE_EXHAUSTED:
        return "resource-exhausted";
      case ErrorCode.SERVICE_UNAVAILABLE:
        return "unavailable";
      default:
        return "internal";
    }
  }
}

// Utility functions for common error scenarios
export const throwNotFound = (resource: string, context?: Record<string, any>): never => {
  throw new NotFoundError(resource, context);
};

export const throwValidation = (message: string, context?: Record<string, any>): never => {
  throw new ValidationError(message, context);
};

export const throwUnauthorized = (message?: string, context?: Record<string, any>): never => {
  throw new AuthenticationError(message, context);
};

export const throwForbidden = (message?: string, context?: Record<string, any>): never => {
  throw new AuthorizationError(message, context);
};

export const throwConflict = (message: string, context?: Record<string, any>): never => {
  throw new ConflictError(message, context);
};

export const throwRateLimit = (message?: string, context?: Record<string, any>): never => {
  throw new RateLimitError(message, context);
};

export const throwExternalApi = (message: string, context?: Record<string, any>): never => {
  throw new ExternalApiError(message, context);
};