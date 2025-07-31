import * as admin from "firebase-admin";
import { 
  League, 
  Team, 
  Fixture, 
  Standing, 
  TeamStatistics,
  FootballApiResponse 
} from "../types";

/**
 * Transform Football API league data to our internal format
 */
export function transformLeagueData(apiData: any): Partial<League> {
  return {
    api_league_id: apiData.league.id,
    name: apiData.league.name,
    country: apiData.country.name,
    logo: apiData.league.logo,
    flag: apiData.country.flag,
    season: apiData.seasons?.[0]?.year || new Date().getFullYear(),
    is_active: true,
    created_at: admin.firestore.Timestamp.now(),
  };
}

/**
 * Transform Football API team data to our internal format
 */
export function transformTeamData(apiData: any, leagueId: string): Partial<Team> {
  return {
    api_team_id: apiData.team.id,
    name: apiData.team.name,
    code: apiData.team.code,
    country: apiData.team.country,
    founded: apiData.team.founded,
    logo: apiData.team.logo,
    league_id: leagueId,
    venue: apiData.venue ? {
      id: apiData.venue.id,
      name: apiData.venue.name,
      address: apiData.venue.address,
      city: apiData.venue.city,
      capacity: apiData.venue.capacity,
      surface: apiData.venue.surface,
      image: apiData.venue.image,
    } : undefined,
    is_active: true,
    created_at: admin.firestore.Timestamp.now(),
  };
}

/**
 * Transform Football API fixture data to our internal format
 */
export function transformFixtureData(apiData: any, leagueId: string): Partial<Fixture> {
  const fixtureDate = new Date(apiData.fixture.date);
  
  return {
    api_fixture_id: apiData.fixture.id,
    referee: apiData.fixture.referee,
    timezone: apiData.fixture.timezone,
    date: admin.firestore.Timestamp.fromDate(fixtureDate),
    timestamp: apiData.fixture.timestamp,
    periods: {
      first: apiData.fixture.periods?.first,
      second: apiData.fixture.periods?.second,
    },
    venue: apiData.fixture.venue ? {
      id: apiData.fixture.venue.id,
      name: apiData.fixture.venue.name,
      city: apiData.fixture.venue.city,
    } : undefined,
    status: {
      long: apiData.fixture.status.long,
      short: apiData.fixture.status.short,
      elapsed: apiData.fixture.status.elapsed,
    },
    league_id: leagueId,
    season: apiData.league.season,
    round: apiData.league.round,
    home_team_id: apiData.teams.home.id.toString(),
    away_team_id: apiData.teams.away.id.toString(),
    goals: {
      home: apiData.goals?.home,
      away: apiData.goals?.away,
    },
    score: {
      halftime: {
        home: apiData.score?.halftime?.home,
        away: apiData.score?.halftime?.away,
      },
      fulltime: {
        home: apiData.score?.fulltime?.home,
        away: apiData.score?.fulltime?.away,
      },
      extratime: {
        home: apiData.score?.extratime?.home,
        away: apiData.score?.extratime?.away,
      },
      penalty: {
        home: apiData.score?.penalty?.home,
        away: apiData.score?.penalty?.away,
      },
    },
    created_at: admin.firestore.Timestamp.now(),
  };
}

/**
 * Transform Football API standings data to our internal format
 */
export function transformStandingData(
  apiData: any, 
  leagueId: string, 
  season: number
): Partial<Standing> {
  return {
    league_id: leagueId,
    season,
    team_id: apiData.team.id.toString(),
    position: apiData.rank,
    points: apiData.points,
    goals_diff: apiData.goalsDiff,
    group: apiData.group,
    form: apiData.form,
    status: apiData.status,
    description: apiData.description,
    all: {
      played: apiData.all.played,
      win: apiData.all.win,
      draw: apiData.all.draw,
      lose: apiData.all.lose,
      goals_for: apiData.all.goals.for,
      goals_against: apiData.all.goals.against,
    },
    home: {
      played: apiData.home.played,
      win: apiData.home.win,
      draw: apiData.home.draw,
      lose: apiData.home.lose,
      goals_for: apiData.home.goals.for,
      goals_against: apiData.home.goals.against,
    },
    away: {
      played: apiData.away.played,
      win: apiData.away.win,
      draw: apiData.away.draw,
      lose: apiData.away.lose,
      goals_for: apiData.away.goals.for,
      goals_against: apiData.away.goals.against,
    },
    updated_at: admin.firestore.Timestamp.now(),
  };
}

/**
 * Transform Football API team statistics data to our internal format
 */
export function transformTeamStatisticsData(
  apiData: any,
  teamId: string,
  leagueId: string,
  season: number
): Partial<TeamStatistics> {
  return {
    team_id: teamId,
    league_id: leagueId,
    season,
    form: apiData.form,
    fixtures: {
      played: {
        home: apiData.fixtures.played.home,
        away: apiData.fixtures.played.away,
        total: apiData.fixtures.played.total,
      },
      wins: {
        home: apiData.fixtures.wins.home,
        away: apiData.fixtures.wins.away,
        total: apiData.fixtures.wins.total,
      },
      draws: {
        home: apiData.fixtures.draws.home,
        away: apiData.fixtures.draws.away,
        total: apiData.fixtures.draws.total,
      },
      loses: {
        home: apiData.fixtures.loses.home,
        away: apiData.fixtures.loses.away,
        total: apiData.fixtures.loses.total,
      },
    },
    goals: {
      for: {
        total: {
          home: apiData.goals.for.total.home,
          away: apiData.goals.for.total.away,
          total: apiData.goals.for.total.total,
        },
        average: {
          home: parseFloat(apiData.goals.for.average.home) || 0,
          away: parseFloat(apiData.goals.for.average.away) || 0,
          total: parseFloat(apiData.goals.for.average.total) || 0,
        },
        minute: apiData.goals.for.minute || {},
      },
      against: {
        total: {
          home: apiData.goals.against.total.home,
          away: apiData.goals.against.total.away,
          total: apiData.goals.against.total.total,
        },
        average: {
          home: parseFloat(apiData.goals.against.average.home) || 0,
          away: parseFloat(apiData.goals.against.average.away) || 0,
          total: parseFloat(apiData.goals.against.average.total) || 0,
        },
        minute: apiData.goals.against.minute || {},
      },
    },
    biggest: {
      streak: {
        wins: apiData.biggest.streak.wins,
        draws: apiData.biggest.streak.draws,
        loses: apiData.biggest.streak.loses,
      },
      wins: {
        home: apiData.biggest.wins.home,
        away: apiData.biggest.wins.away,
      },
      loses: {
        home: apiData.biggest.loses.home,
        away: apiData.biggest.loses.away,
      },
      goals: {
        for: {
          home: apiData.biggest.goals.for.home,
          away: apiData.biggest.goals.for.away,
        },
        against: {
          home: apiData.biggest.goals.against.home,
          away: apiData.biggest.goals.against.away,
        },
      },
    },
    clean_sheet: {
      home: apiData.clean_sheet.home,
      away: apiData.clean_sheet.away,
      total: apiData.clean_sheet.total,
    },
    failed_to_score: {
      home: apiData.failed_to_score.home,
      away: apiData.failed_to_score.away,
      total: apiData.failed_to_score.total,
    },
    penalty: {
      scored: {
        total: apiData.penalty.scored.total,
        percentage: apiData.penalty.scored.percentage,
      },
      missed: {
        total: apiData.penalty.missed.total,
        percentage: apiData.penalty.missed.percentage,
      },
      total: apiData.penalty.total,
    },
    lineups: apiData.lineups || [],
    cards: {
      yellow: apiData.cards.yellow || {},
      red: apiData.cards.red || {},
    },
    updated_at: admin.firestore.Timestamp.now(),
  };
}

/**
 * Transform internal data for API responses (remove sensitive fields, format dates)
 */
export function transformForApiResponse<T extends Record<string, any>>(
  data: T,
  excludeFields: string[] = []
): Partial<T> {
  const transformed = { ...data };

  // Remove excluded fields
  excludeFields.forEach(field => {
    delete transformed[field];
  });

  // Transform Firestore timestamps to ISO strings
  Object.keys(transformed).forEach(key => {
    if (transformed[key] && typeof transformed[key] === "object") {
      if (transformed[key].toDate && typeof transformed[key].toDate === "function") {
        transformed[key] = transformed[key].toDate().toISOString();
      }
    }
  });

  return transformed;
}

/**
 * Transform query parameters to Firestore query constraints
 */
export function transformQueryParams(params: Record<string, any>): {
  filters: Array<{ field: string; operator: FirebaseFirestore.WhereFilterOp; value: any }>;
  orderBy?: { field: string; direction: "asc" | "desc" };
  limit?: number;
  offset?: number;
} {
  const filters: Array<{ field: string; operator: FirebaseFirestore.WhereFilterOp; value: any }> = [];
  let orderBy: { field: string; direction: "asc" | "desc" } | undefined;
  let limit: number | undefined;
  let offset: number | undefined;

  Object.entries(params).forEach(([key, value]) => {
    if (value === undefined || value === null) return;

    switch (key) {
      case "page":
        // Handle pagination
        break;
      case "limit":
        limit = parseInt(value as string, 10);
        break;
      case "sort":
        if (typeof value === "string") {
          const [field, direction] = value.split(":");
          orderBy = { field, direction: (direction === "desc" ? "desc" : "asc") };
        }
        break;
      case "search":
        // For text search, we'll need to implement this differently
        // Firestore doesn't support full-text search natively
        break;
      default:
        // Regular field filters
        if (typeof value === "string" && value.includes(",")) {
          // Handle array values
          filters.push({ field: key, operator: "in", value: value.split(",") });
        } else {
          filters.push({ field: key, operator: "==", value });
        }
        break;
    }
  });

  return { filters, orderBy, limit, offset };
}

/**
 * Transform Firestore document to API response format
 */
export function transformFirestoreDoc<T>(
  doc: FirebaseFirestore.DocumentSnapshot,
  includeId: boolean = true
): T | null {
  if (!doc.exists) return null;

  const data = doc.data() as T;
  
  if (includeId) {
    (data as any).id = doc.id;
  }

  return transformForApiResponse(data) as T;
}

/**
 * Transform Firestore query snapshot to API response format
 */
export function transformFirestoreQuery<T>(
  snapshot: FirebaseFirestore.QuerySnapshot,
  includeId: boolean = true
): T[] {
  return snapshot.docs.map(doc => transformFirestoreDoc<T>(doc, includeId)).filter(Boolean) as T[];
}

/**
 * Batch transform multiple documents
 */
export function batchTransform<T, R>(
  items: T[],
  transformer: (item: T) => R
): R[] {
  return items.map(transformer);
}

/**
 * Safe date parsing
 */
export function parseDate(dateInput: string | number | Date): Date | null {
  try {
    const date = new Date(dateInput);
    return isNaN(date.getTime()) ? null : date;
  } catch {
    return null;
  }
}

/**
 * Generate cache key from parameters
 */
export function generateCacheKey(prefix: string, params: Record<string, any>): string {
  const sortedParams = Object.keys(params)
    .sort()
    .reduce((result, key) => {
      result[key] = params[key];
      return result;
    }, {} as Record<string, any>);

  const paramString = JSON.stringify(sortedParams);
  return `${prefix}:${Buffer.from(paramString).toString("base64")}`;
}