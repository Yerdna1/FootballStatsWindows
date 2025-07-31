import { z } from "zod";

// User validation schemas
export const UserCreateSchema = z.object({
  email: z.string().email(),
  display_name: z.string().min(1).max(100),
  photo_url: z.string().url().optional(),
});

export const UserUpdateSchema = z.object({
  display_name: z.string().min(1).max(100).optional(),
  photo_url: z.string().url().optional(),
  preferences: z.object({
    favorite_leagues: z.array(z.string()).optional(),
    favorite_teams: z.array(z.string()).optional(),
    notifications_enabled: z.boolean().optional(),
    language: z.string().optional(),
    timezone: z.string().optional(),
    theme: z.enum(["light", "dark", "auto"]).optional(),
  }).optional(),
});

// League validation schemas
export const LeagueCreateSchema = z.object({
  api_league_id: z.number().positive(),
  name: z.string().min(1).max(200),
  country: z.string().min(1).max(100),
  logo: z.string().url().optional(),
  flag: z.string().url().optional(),
  season: z.number().min(2000).max(2100),
});

// Team validation schemas
export const TeamCreateSchema = z.object({
  api_team_id: z.number().positive(),
  name: z.string().min(1).max(200),
  code: z.string().max(10).optional(),
  country: z.string().min(1).max(100),
  founded: z.number().min(1800).max(2100).optional(),
  logo: z.string().url().optional(),
  league_id: z.string().min(1),
});

// Fixture validation schemas
export const FixtureCreateSchema = z.object({
  api_fixture_id: z.number().positive(),
  referee: z.string().optional(),
  timezone: z.string(),
  date: z.string().datetime(),
  timestamp: z.number(),
  league_id: z.string().min(1),
  season: z.number().min(2000).max(2100),
  round: z.string().min(1),
  home_team_id: z.string().min(1),
  away_team_id: z.string().min(1),
});

// User favorite validation schemas
export const UserFavoriteCreateSchema = z.object({
  type: z.enum(["team", "league", "player"]),
  entity_id: z.string().min(1),
});

// Notification validation schemas
export const NotificationCreateSchema = z.object({
  user_id: z.string().min(1),
  title: z.string().min(1).max(200),
  message: z.string().min(1).max(1000),
  type: z.enum(["info", "warning", "error", "success"]),
  data: z.record(z.any()).optional(),
});

// Query parameter validation schemas
export const PaginationSchema = z.object({
  page: z.string().transform(Number).pipe(z.number().min(1)).optional().default("1"),
  limit: z.string().transform(Number).pipe(z.number().min(1).max(100)).optional().default("20"),
});

export const LeagueQuerySchema = z.object({
  country: z.string().optional(),
  season: z.string().transform(Number).pipe(z.number().min(2000).max(2100)).optional(),
  active: z.string().transform((val) => val === "true").optional(),
}).merge(PaginationSchema);

export const TeamQuerySchema = z.object({
  league_id: z.string().optional(),
  country: z.string().optional(),
  search: z.string().optional(),
}).merge(PaginationSchema);

export const FixtureQuerySchema = z.object({
  league_id: z.string().optional(),
  team_id: z.string().optional(),
  season: z.string().transform(Number).pipe(z.number().min(2000).max(2100)).optional(),
  status: z.string().optional(),
  from: z.string().datetime().optional(),
  to: z.string().datetime().optional(),
}).merge(PaginationSchema);

export const StandingsQuerySchema = z.object({
  league_id: z.string().min(1),
  season: z.string().transform(Number).pipe(z.number().min(2000).max(2100)).optional(),
});

// Validation helper functions
export function validateRequest<T>(schema: z.ZodSchema<T>, data: unknown): T {
  try {
    return schema.parse(data);
  } catch (error) {
    if (error instanceof z.ZodError) {
      const errorMessages = error.errors.map(
        (err) => `${err.path.join(".")}: ${err.message}`
      );
      throw new Error(`Validation failed: ${errorMessages.join(", ")}`);
    }
    throw error;
  }
}

export function validateOptionalRequest<T>(
  schema: z.ZodSchema<T>,
  data: unknown
): T | null {
  if (!data) return null;
  return validateRequest(schema, data);
}

// Custom validation helpers
export function isValidFirebaseUID(uid: string): boolean {
  return /^[a-zA-Z0-9]{28}$/.test(uid);
}

export function isValidEmail(email: string): boolean {
  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  return emailRegex.test(email);
}

export function sanitizeString(str: string, maxLength: number = 255): string {
  return str.trim().substring(0, maxLength);
}

export function isValidUrl(url: string): boolean {
  try {
    new URL(url);
    return true;
  } catch {
    return false;
  }
}

export function isValidDate(dateString: string): boolean {
  const date = new Date(dateString);
  return !isNaN(date.getTime());
}

export function isValidSeason(season: number): boolean {
  const currentYear = new Date().getFullYear();
  return season >= 2000 && season <= currentYear + 1;
}