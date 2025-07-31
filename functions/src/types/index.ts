export interface User {
  uid: string;
  email: string;
  display_name: string;
  photo_url?: string;
  created_at: FirebaseFirestore.Timestamp;
  updated_at?: FirebaseFirestore.Timestamp;
  last_login?: FirebaseFirestore.Timestamp;
  preferences: UserPreferences;
  is_active: boolean;
}

export interface UserPreferences {
  favorite_leagues: string[];
  favorite_teams: string[];
  notifications_enabled: boolean;
  language: string;
  timezone: string;
  theme: "light" | "dark" | "auto";
}

export interface UserPermissions {
  user_id: string;
  role: "user" | "moderator" | "admin";
  permissions: Permission[];
  granted_at: FirebaseFirestore.Timestamp;
  granted_by: string;
}

export interface Permission {
  resource: string;
  actions: string[];
}

export interface League {
  id: string;
  api_league_id: number;
  name: string;
  country: string;
  logo?: string;
  flag?: string;
  season: number;
  is_active: boolean;
  created_at: FirebaseFirestore.Timestamp;
  updated_at?: FirebaseFirestore.Timestamp;
}

export interface Team {
  id: string;
  api_team_id: number;
  name: string;
  code?: string;
  country: string;
  founded?: number;
  logo?: string;
  league_id: string;
  venue?: Venue;
  is_active: boolean;
  created_at: FirebaseFirestore.Timestamp;
  updated_at?: FirebaseFirestore.Timestamp;
}

export interface Venue {
  id?: number;
  name?: string;
  address?: string;
  city?: string;
  capacity?: number;
  surface?: string;
  image?: string;
}

export interface Standing {
  id: string;
  league_id: string;
  season: number;
  team_id: string;
  position: number;
  points: number;
  goals_diff: number;
  group?: string;
  form?: string;
  status?: string;
  description?: string;
  all: StandingStats;
  home: StandingStats;
  away: StandingStats;
  updated_at: FirebaseFirestore.Timestamp;
}

export interface StandingStats {
  played: number;
  win: number;
  draw: number;
  lose: number;
  goals_for: number;
  goals_against: number;
}

export interface Fixture {
  id: string;
  api_fixture_id: number;
  referee?: string;
  timezone: string;
  date: FirebaseFirestore.Timestamp;
  timestamp: number;
  periods: FixturePeriods;
  venue?: Venue;
  status: FixtureStatus;
  league_id: string;
  season: number;
  round: string;
  home_team_id: string;
  away_team_id: string;
  goals: FixtureGoals;
  score: FixtureScore;
  created_at: FirebaseFirestore.Timestamp;
  updated_at?: FirebaseFirestore.Timestamp;
}

export interface FixturePeriods {
  first?: number;
  second?: number;
}

export interface FixtureStatus {
  long: string;
  short: string;
  elapsed?: number;
}

export interface FixtureGoals {
  home?: number;
  away?: number;
}

export interface FixtureScore {
  halftime: FixtureGoals;
  fulltime: FixtureGoals;
  extratime: FixtureGoals;
  penalty: FixtureGoals;
}

export interface TeamStatistics {
  id: string;
  team_id: string;
  league_id: string;
  season: number;
  form?: string;
  fixtures: TeamFixtureStats;
  goals: TeamGoalStats;
  biggest: TeamBiggestStats;
  clean_sheet: TeamCleanSheetStats;
  failed_to_score: TeamFailedToScoreStats;
  penalty: TeamPenaltyStats;
  lineups: TeamLineupStats[];
  cards: TeamCardStats;
  updated_at: FirebaseFirestore.Timestamp;
}

export interface TeamFixtureStats {
  played: TeamLocationStats;
  wins: TeamLocationStats;
  draws: TeamLocationStats;
  loses: TeamLocationStats;
}

export interface TeamLocationStats {
  home: number;
  away: number;
  total: number;
}

export interface TeamGoalStats {
  for: TeamGoalLocationStats;
  against: TeamGoalLocationStats;
}

export interface TeamGoalLocationStats {
  total: TeamLocationStats;
  average: TeamLocationStatsFloat;
  minute: Record<string, TeamGoalMinuteStats>;
}

export interface TeamLocationStatsFloat {
  home: number;
  away: number;
  total: number;
}

export interface TeamGoalMinuteStats {
  total?: number;
  percentage?: string;
}

export interface TeamBiggestStats {
  streak: {
    wins: number;
    draws: number;
    loses: number;
  };
  wins: {
    home?: string;
    away?: string;
  };
  loses: {
    home?: string;
    away?: string;
  };
  goals: {
    for: {
      home: number;
      away: number;
    };
    against: {
      home: number;
      away: number;
    };
  };
}

export interface TeamCleanSheetStats {
  home: number;
  away: number;
  total: number;
}

export interface TeamFailedToScoreStats {
  home: number;
  away: number;
  total: number;
}

export interface TeamPenaltyStats {
  scored: {
    total: number;
    percentage: string;
  };
  missed: {
    total: number;
    percentage: string;
  };
  total: number;
}

export interface TeamLineupStats {
  formation: string;
  played: number;
}

export interface TeamCardStats {
  yellow: Record<string, TeamGoalMinuteStats>;
  red: Record<string, TeamGoalMinuteStats>;
}

export interface UserFavorite {
  id: string;
  user_id: string;
  type: "team" | "league" | "player";
  entity_id: string;
  created_at: FirebaseFirestore.Timestamp;
}

export interface Notification {
  id: string;
  user_id: string;
  title: string;
  message: string;
  type: "info" | "warning" | "error" | "success";
  data?: Record<string, any>;
  read: boolean;
  read_at?: FirebaseFirestore.Timestamp;
  created_at: FirebaseFirestore.Timestamp;
}

export interface AnalyticsCache {
  id: string;
  cache_key: string;
  data: Record<string, any>;
  expires_at: FirebaseFirestore.Timestamp;
  created_at: FirebaseFirestore.Timestamp;
}

export interface ActivityLog {
  id: string;
  user_id?: string;
  action_type: string;
  resource_type: string;
  resource_id?: string;
  details: Record<string, any>;
  ip_address?: string;
  user_agent?: string;
  timestamp: FirebaseFirestore.Timestamp;
}

export interface ApiCache {
  id: string;
  endpoint: string;
  params: Record<string, any>;
  data: any;
  expires_at: FirebaseFirestore.Timestamp;
  created_at: FirebaseFirestore.Timestamp;
}

export interface RateLimit {
  id: string;
  user_id?: string;
  ip_address?: string;
  endpoint: string;
  count: number;
  window_start: FirebaseFirestore.Timestamp;
  expires_at: FirebaseFirestore.Timestamp;
}

// API Response Types
export interface FootballApiResponse<T> {
  get: string;
  parameters: Record<string, any>;
  errors: any[];
  results: number;
  paging: {
    current: number;
    total: number;
  };
  response: T;
}

export interface ApiError {
  code: string;
  message: string;
  details?: any;
}