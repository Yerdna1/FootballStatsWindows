import axios, { AxiosInstance, AxiosResponse } from "axios";
import * as functions from "firebase-functions";
import { logger } from "../utils/logger";
import { cache } from "../utils/cache";
import { throwExternalApi } from "../utils/error-handler";
import { FootballApiResponse } from "../types";

export interface FootballApiConfig {
  baseUrl: string;
  apiKey: string;
  timeout: number;
  retries: number;
  cacheEnabled: boolean;
  cacheTTL: number;
}

export class FootballApiService {
  private static instance: FootballApiService;
  private client: AxiosInstance;
  private config: FootballApiConfig;

  private constructor() {
    this.config = {
      baseUrl: "https://v3.football.api-sports.io",
      apiKey: "2061b15078fc8e299dd268fb5a066f34",
      timeout: 30000, // 30 seconds
      retries: 3,
      cacheEnabled: true,
      cacheTTL: 3600, // 1 hour
    };

    this.client = axios.create({
      baseURL: this.config.baseUrl,
      timeout: this.config.timeout,
      headers: {
        "X-RapidAPI-Key": this.config.apiKey,
        "X-RapidAPI-Host": "v3.football.api-sports.io",
      },
    });

    this.setupInterceptors();
  }

  public static getInstance(): FootballApiService {
    if (!FootballApiService.instance) {
      FootballApiService.instance = new FootballApiService();
    }
    return FootballApiService.instance;
  }

  private setupInterceptors(): void {
    // Request interceptor
    this.client.interceptors.request.use(
      (config) => {
        logger.debug(`Football API request: ${config.method?.toUpperCase()} ${config.url}`, {
          endpoint: config.url,
          params: config.params,
        });
        return config;
      },
      (error) => Promise.reject(error)
    );

    // Response interceptor
    this.client.interceptors.response.use(
      (response: AxiosResponse) => {
        logger.debug(`Football API response: ${response.status}`, {
          endpoint: response.config.url,
          status: response.status,
          results: response.data?.results,
        });
        return response;
      },
      async (error) => {
        const config = error.config;
        
        // Retry logic
        if (config && !config._retry && config._retryCount < this.config.retries) {
          config._retryCount = config._retryCount || 0;
          config._retryCount += 1;
          config._retry = true;

          logger.warn(`Retrying Football API request (${config._retryCount}/${this.config.retries})`, {
            endpoint: config.url,
            error: error.message,
          });

          // Exponential backoff
          const delay = Math.pow(2, config._retryCount - 1) * 1000;
          await new Promise(resolve => setTimeout(resolve, delay));

          return this.client(config);
        }

        logger.error("Football API request failed", error, {
          endpoint: config?.url,
          status: error.response?.status,
          message: error.response?.data?.message,
        });

        return Promise.reject(error);
      }
    );
  }

  private async makeRequest<T>(
    endpoint: string,
    params: Record<string, any> = {},
    cacheKey?: string
  ): Promise<FootballApiResponse<T>> {
    try {
      // Check cache first if enabled
      if (this.config.cacheEnabled && cacheKey) {
        const cachedData = await cache.get<FootballApiResponse<T>>(cacheKey, "football-api");
        if (cachedData) {
          logger.debug(`Using cached data for: ${endpoint}`, { cacheKey });
          return cachedData;
        }
      }

      const response = await this.client.get<FootballApiResponse<T>>(endpoint, { params });
      const data = response.data;

      // Validate API response
      if (data.errors && data.errors.length > 0) {
        throw new Error(`Football API errors: ${JSON.stringify(data.errors)}`);
      }

      // Cache successful response
      if (this.config.cacheEnabled && cacheKey && data.results > 0) {
        await cache.set(cacheKey, data, { 
          ttl: this.config.cacheTTL,
          keyPrefix: "football-api"
        });
      }

      return data;
    } catch (error: any) {
      if (error.response?.status === 429) {
        throwExternalApi("Football API rate limit exceeded", {
          endpoint,
          status: error.response.status,
        });
      }

      if (error.response?.status >= 500) {
        throwExternalApi("Football API server error", {
          endpoint,
          status: error.response.status,
          message: error.response.data?.message,
        });
      }

      throwExternalApi(`Football API request failed: ${error.message}`, {
        endpoint,
        error: error.message,
      });
    }
  }

  /**
   * Fetch league standings for a specific season
   */
  public async fetchStandings(leagueId: number, season: number = 2025): Promise<any[]> {
    const endpoint = "/standings";
    const params = { league: leagueId, season };
    const cacheKey = `standings_${leagueId}_${season}`;

    try {
      const response = await this.makeRequest(endpoint, params, cacheKey);
      return response.response || [];
    } catch (error) {
      logger.error(`Failed to fetch standings for league ${leagueId}`, error as Error);
      throw error;
    }
  }

  /**
   * Fetch fixtures for a league and season
   */
  public async fetchFixtures(
    leagueId: number, 
    season: number = 2025,
    from?: string,
    to?: string
  ): Promise<any[]> {
    const endpoint = "/fixtures";
    const params: Record<string, any> = { league: leagueId, season };
    
    if (from) params.from = from;
    if (to) params.to = to;

    const cacheKey = `fixtures_${leagueId}_${season}_${from || ""}_${to || ""}`;

    try {
      const response = await this.makeRequest(endpoint, params, cacheKey);
      return response.response || [];
    } catch (error) {
      logger.error(`Failed to fetch fixtures for league ${leagueId}`, error as Error);
      throw error;
    }
  }

  /**
   * Fetch teams for a specific league and season
   */
  public async fetchTeams(leagueId: number, season: number = 2025): Promise<any[]> {
    const endpoint = "/teams";
    const params = { league: leagueId, season };
    const cacheKey = `teams_${leagueId}_${season}`;

    try {
      const response = await this.makeRequest(endpoint, params, cacheKey);
      return response.response || [];
    } catch (error) {
      logger.error(`Failed to fetch teams for league ${leagueId}`, error as Error);
      throw error;
    }
  }

  /**
   * Fetch team statistics
   */
  public async fetchTeamStatistics(
    leagueId: number,
    teamId: number,
    season: number = 2025
  ): Promise<any> {
    const endpoint = "/teams/statistics";
    const params = { league: leagueId, team: teamId, season };
    const cacheKey = `team_stats_${teamId}_${leagueId}_${season}`;

    try {
      const response = await this.makeRequest(endpoint, params, cacheKey);
      return response.response;
    } catch (error) {
      logger.error(`Failed to fetch team statistics for team ${teamId}`, error as Error);
      throw error;
    }
  }

  /**
   * Fetch next fixtures for a league
   */
  public async fetchNextFixtures(
    leagueId: number,
    season: number = 2025,
    next: number = 10
  ): Promise<any[]> {
    const endpoint = "/fixtures";
    const params = { league: leagueId, season, next };
    const cacheKey = `next_fixtures_${leagueId}_${season}_${next}`;

    try {
      const response = await this.makeRequest(endpoint, params, cacheKey);
      return response.response || [];
    } catch (error) {
      logger.error(`Failed to fetch next fixtures for league ${leagueId}`, error as Error);
      throw error;
    }
  }

  /**
   * Fetch all teams from multiple leagues with match count limit
   */
  public async fetchAllTeams(
    leagueNames: string[],
    matchesCount: number = 5
  ): Promise<Record<string, any[]>> {
    const results: Record<string, any[]> = {};

    // First, get league IDs for the league names
    const leagues = await this.fetchLeagues();
    const leagueMap = new Map<string, number>();
    
    leagues.forEach((league: any) => {
      const leagueName = league.league.name.toLowerCase();
      if (leagueNames.some(name => name.toLowerCase() === leagueName)) {
        leagueMap.set(league.league.name, league.league.id);
      }
    });

    // Fetch teams for each league
    for (const [leagueName, leagueId] of leagueMap.entries()) {
      try {
        const teams = await this.fetchTeams(leagueId);
        
        // For each team, fetch recent matches
        const teamsWithMatches = await Promise.all(
          teams.slice(0, 10).map(async (teamData: any) => { // Limit to first 10 teams to avoid API limits
            try {
              const recentFixtures = await this.fetchTeamRecentFixtures(
                teamData.team.id,
                matchesCount
              );
              return {
                ...teamData,
                recent_fixtures: recentFixtures,
              };
            } catch (error) {
              logger.warn(`Failed to fetch recent fixtures for team ${teamData.team.id}`, {
                teamId: teamData.team.id,
                error: (error as Error).message,
              });
              return {
                ...teamData,
                recent_fixtures: [],
              };
            }
          })
        );

        results[leagueName] = teamsWithMatches;
      } catch (error) {
        logger.error(`Failed to fetch teams for league ${leagueName}`, error as Error);
        results[leagueName] = [];
      }
    }

    return results;
  }

  /**
   * Fetch recent fixtures for a team
   */
  public async fetchTeamRecentFixtures(teamId: number, last: number = 5): Promise<any[]> {
    const endpoint = "/fixtures";
    const params = { team: teamId, last };
    const cacheKey = `team_recent_${teamId}_${last}`;

    try {
      const response = await this.makeRequest(endpoint, params, cacheKey);
      return response.response || [];
    } catch (error) {
      logger.error(`Failed to fetch recent fixtures for team ${teamId}`, error as Error);
      return [];
    }
  }

  /**
   * Fetch all available leagues
   */
  public async fetchLeagues(): Promise<any[]> {
    const endpoint = "/leagues";
    const cacheKey = "all_leagues";

    try {
      const response = await this.makeRequest(endpoint, {}, cacheKey);
      return response.response || [];
    } catch (error) {
      logger.error("Failed to fetch leagues", error as Error);
      throw error;
    }
  }

  /**
   * Fetch specific league by ID
   */
  public async fetchLeague(leagueId: number): Promise<any> {
    const endpoint = "/leagues";
    const params = { id: leagueId };
    const cacheKey = `league_${leagueId}`;

    try {
      const response = await this.makeRequest(endpoint, params, cacheKey);
      return response.response?.[0];
    } catch (error) {
      logger.error(`Failed to fetch league ${leagueId}`, error as Error);
      throw error;
    }
  }

  /**
   * Get API status and quota information
   */
  public async getApiStatus(): Promise<{
    requests: {
      current: number;
      limit_day: number;
    };
    results: number;
  }> {
    try {
      const response = await this.client.get("/status");
      return response.data;
    } catch (error) {
      logger.error("Failed to get API status", error as Error);
      throw error;
    }
  }

  /**
   * Clear all Football API cache
   */
  public async clearCache(): Promise<void> {
    await cache.clearPrefix("football-api");
    logger.info("Football API cache cleared");
  }

  /**
   * Update cache TTL configuration
   */
  public updateCacheConfig(ttl: number, enabled: boolean = true): void {
    this.config.cacheTTL = ttl;
    this.config.cacheEnabled = enabled;
    logger.info("Football API cache configuration updated", { ttl, enabled });
  }
}

export const footballApi = FootballApiService.getInstance();