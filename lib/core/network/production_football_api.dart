import 'dart:collection';
import 'dart:convert';
import 'dart:math' as math;
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Production-ready Football API Client matching Python functionality
class ProductionFootballApi {
  // API Configuration (replace with your actual API key)
  static const String _baseUrl = 'https://api-football-v1.p.rapidapi.com/v3';
  static const String _apiKey = 'YOUR_RAPIDAPI_KEY_HERE'; // Replace with actual key
  static const String _apiHost = 'api-football-v1.p.rapidapi.com';
  
  // Rate limiting configuration (RapidAPI allows 100 requests/day on Free plan)
  static const int _requestsPerMinute = 10;
  static const int _requestsPerDay = 100;
  static const Duration _rateLimitWindow = Duration(minutes: 1);
  static const Duration _dailyLimitWindow = Duration(days: 1);
  
  final Dio _dio;
  final Logger _logger = Logger();
  late Box _cacheBox;
  late Box _rateLimitBox;
  
  // Rate limiting tracking
  final Queue<DateTime> _requestTimes = Queue<DateTime>();
  final Queue<DateTime> _dailyRequestTimes = Queue<DateTime>();
  
  ProductionFootballApi({Dio? dio}) : _dio = dio ?? Dio() {
    _setupInterceptors();
    _initializeBoxes();
  }
  
  Future<void> _initializeBoxes() async {
    try {
      _cacheBox = await Hive.openBox('production_api_cache');
      _rateLimitBox = await Hive.openBox('rate_limit_tracking');
      _loadRateLimitData();
    } catch (e) {
      _logger.e('Failed to initialize Hive boxes: $e');
    }
  }
  
  void _setupInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          options.headers['X-RapidAPI-Key'] = _apiKey;
          options.headers['X-RapidAPI-Host'] = _apiHost;
          options.headers['Accept'] = 'application/json';
          
          _logger.i('🌐 API Request: ${options.method} ${options.uri}');
          handler.next(options);
        },
        onResponse: (response, handler) {
          _logger.i('✅ API Response: ${response.statusCode} ${response.requestOptions.uri}');
          _logApiUsage(response);
          handler.next(response);
        },
        onError: (error, handler) {
          _logger.e('❌ API Error: ${error.response?.statusCode} ${error.requestOptions.uri}');
          _logger.e('Error details: ${error.message}');
          
          // Handle specific API errors
          if (error.response?.statusCode == 429) {
            _logger.w('Rate limit exceeded! Implementing backoff strategy...');
          } else if (error.response?.statusCode == 403) {
            _logger.e('API access forbidden! Check your API key and subscription.');
          }
          
          handler.next(error);
        },
      ),
    );
  }
  
  /// Enforce rate limiting before making requests
  Future<void> _enforceRateLimit() async {
    final now = DateTime.now();
    
    // Clean old requests from queue
    _cleanOldRequests(now);
    
    // Check daily limit
    if (_dailyRequestTimes.length >= _requestsPerDay) {
      final oldestRequest = _dailyRequestTimes.first;
      final waitTime = _dailyLimitWindow - now.difference(oldestRequest);
      if (waitTime.inSeconds > 0) {
        _logger.w('Daily API limit reached. Waiting ${waitTime.inHours} hours...');
        throw ApiException('Daily API limit reached. Try again tomorrow.', 429);
      }
    }
    
    // Check per-minute limit
    if (_requestTimes.length >= _requestsPerMinute) {
      final oldestRequest = _requestTimes.first;
      final waitTime = _rateLimitWindow - now.difference(oldestRequest);
      if (waitTime.inSeconds > 0) {
        _logger.w('Rate limit hit. Waiting ${waitTime.inSeconds} seconds...');
        await Future.delayed(waitTime);
      }
    }
    
    // Add current request to tracking
    _requestTimes.add(now);
    _dailyRequestTimes.add(now);
    _saveRateLimitData();
  }
  
  void _cleanOldRequests(DateTime now) {
    // Remove requests older than 1 minute
    while (_requestTimes.isNotEmpty && 
           now.difference(_requestTimes.first) > _rateLimitWindow) {
      _requestTimes.removeFirst();
    }
    
    // Remove requests older than 1 day
    while (_dailyRequestTimes.isNotEmpty && 
           now.difference(_dailyRequestTimes.first) > _dailyLimitWindow) {
      _dailyRequestTimes.removeFirst();
    }
  }
  
  /// Main API request method with caching and error handling
  Future<Map<String, dynamic>> request(
    String endpoint, {
    Map<String, dynamic>? params,
    Duration? cacheDuration,
    bool forceRefresh = false,
  }) async {
    final cacheKey = _generateCacheKey(endpoint, params);
    
    // Try cache first (unless forced refresh)
    if (!forceRefresh) {
      final cachedData = await _getFromCache(cacheKey);
      if (cachedData != null) {
        _logger.i('📦 Using cached data for $endpoint');
        return cachedData;
      }
    }
    
    // Enforce rate limiting
    await _enforceRateLimit();
    
    try {
      final response = await _dio.get(
        '$_baseUrl$endpoint',
        queryParameters: params,
        options: Options(
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 30),
        ),
      );
      
      final data = response.data as Map<String, dynamic>;
      
      // Validate API response
      if (!_isValidApiResponse(data)) {
        throw ApiException('Invalid API response format', response.statusCode);
      }
      
      // Cache successful response
      await _cacheResponse(cacheKey, data, cacheDuration);
      
      return data;
      
    } on DioException catch (e) {
      // Try to return cached data on error
      final cachedData = await _getFromCache(cacheKey);
      if (cachedData != null) {
        _logger.w('API error, using cached data: ${e.message}');
        return cachedData;
      }
      
      throw _handleDioError(e);
    }
  }
  
  /// Get all leagues
  Future<List<LeagueData>> getLeagues({String? country, int? season}) async {
    final params = <String, dynamic>{};
    if (country != null) params['country'] = country;
    if (season != null) params['season'] = season;
    
    final response = await request(
      '/leagues',
      params: params,
      cacheDuration: const Duration(hours: 24), // Leagues don't change often
    );
    
    final leagues = <LeagueData>[];
    if (response['response'] != null) {
      for (final item in response['response']) {
        try {
          leagues.add(LeagueData.fromJson(item));
        } catch (e) {
          _logger.w('Failed to parse league: $e');
        }
      }
    }
    
    _logger.i('Fetched ${leagues.length} leagues');
    return leagues;
  }
  
  /// Get teams for a specific league
  Future<List<TeamData>> getTeams({required int leagueId, required int season}) async {
    final response = await request(
      '/teams',
      params: {'league': leagueId, 'season': season},
      cacheDuration: const Duration(hours: 6), // Teams change less frequently
    );
    
    final teams = <TeamData>[];
    if (response['response'] != null) {
      for (final item in response['response']) {
        try {
          teams.add(TeamData.fromJson(item['team']));
        } catch (e) {
          _logger.w('Failed to parse team: $e');
        }
      }
    }
    
    _logger.i('Fetched ${teams.length} teams for league $leagueId');
    return teams;
  }
  
  /// Get fixtures with advanced filtering
  Future<List<FixtureData>> getFixtures({
    int? leagueId,
    int? season,
    String? date,
    int? teamId,
    String? status, // 'NS', 'FT', '1H', '2H', 'HT', etc.
    int? last, // Last N fixtures
    int? next, // Next N fixtures
  }) async {
    final params = <String, dynamic>{};
    if (leagueId != null) params['league'] = leagueId;
    if (season != null) params['season'] = season;
    if (date != null) params['date'] = date;
    if (teamId != null) params['team'] = teamId;
    if (status != null) params['status'] = status;
    if (last != null) params['last'] = last;
    if (next != null) params['next'] = next;
    
    final response = await request(
      '/fixtures',
      params: params,
      cacheDuration: const Duration(minutes: 15), // Fixtures update frequently
    );
    
    final fixtures = <FixtureData>[];
    if (response['response'] != null) {
      for (final item in response['response']) {
        try {
          fixtures.add(FixtureData.fromJson(item));
        } catch (e) {
          _logger.w('Failed to parse fixture: $e');
        }
      }
    }
    
    _logger.i('Fetched ${fixtures.length} fixtures');
    return fixtures;
  }
  
  /// Get team statistics for form analysis
  Future<TeamStatsData?> getTeamStatistics({
    required int teamId,
    required int leagueId,
    required int season,
  }) async {
    final response = await request(
      '/teams/statistics',
      params: {
        'team': teamId,
        'league': leagueId,
        'season': season,
      },
      cacheDuration: const Duration(hours: 1),
    );
    
    if (response['response'] != null) {
      try {
        return TeamStatsData.fromJson(response['response']);
      } catch (e) {
        _logger.w('Failed to parse team statistics: $e');
      }
    }
    
    return null;
  }
  
  /// Get league standings
  Future<List<StandingData>> getStandings({
    required int leagueId,
    required int season,
  }) async {
    final response = await request(
      '/standings',
      params: {'league': leagueId, 'season': season},
      cacheDuration: const Duration(minutes: 30),
    );
    
    final standings = <StandingData>[];
    if (response['response'] != null && response['response'].isNotEmpty) {
      final leagueData = response['response'][0];
      if (leagueData['league']?['standings'] != null) {
        for (final group in leagueData['league']['standings']) {
          for (final standing in group) {
            try {
              standings.add(StandingData.fromJson(standing));
            } catch (e) {
              _logger.w('Failed to parse standing: $e');
            }
          }
        }
      }
    }
    
    _logger.i('Fetched ${standings.length} standings for league $leagueId');
    return standings;
  }
  
  /// Get head-to-head data between two teams
  Future<List<FixtureData>> getHeadToHead({
    required int team1Id,
    required int team2Id,
    int? last,
  }) async {
    final params = {
      'h2h': '$team1Id-$team2Id',
    };
    if (last != null) params['last'] = last;
    
    final response = await request(
      '/fixtures/headtohead',
      params: params,
      cacheDuration: const Duration(hours: 24),
    );
    
    final fixtures = <FixtureData>[];
    if (response['response'] != null) {
      for (final item in response['response']) {
        try {
          fixtures.add(FixtureData.fromJson(item));
        } catch (e) {
          _logger.w('Failed to parse H2H fixture: $e');
        }
      }
    }
    
    return fixtures;
  }
  
  /// Get live scores
  Future<List<FixtureData>> getLiveScores() async {
    final response = await request(
      '/fixtures',
      params: {'live': 'all'},
      cacheDuration: const Duration(minutes: 1), // Very short cache for live data
    );
    
    final liveFixtures = <FixtureData>[];
    if (response['response'] != null) {
      for (final item in response['response']) {
        try {
          liveFixtures.add(FixtureData.fromJson(item));
        } catch (e) {
          _logger.w('Failed to parse live fixture: $e');
        }
      }
    }
    
    return liveFixtures;
  }
  
  // Cache management methods
  String _generateCacheKey(String endpoint, Map<String, dynamic>? params) {
    final paramsString = params?.entries
        .map((e) => '${e.key}=${e.value}')
        .join('&') ?? '';
    return '${endpoint}_$paramsString'.hashCode.toString();
  }
  
  Future<Map<String, dynamic>?> _getFromCache(String key) async {
    try {
      final cached = _cacheBox.get(key);
      if (cached != null) {
        final data = Map<String, dynamic>.from(cached);
        final timestamp = DateTime.parse(data['_cached_at']);
        final duration = Duration(minutes: data['_cache_duration'] ?? 15);
        
        if (DateTime.now().difference(timestamp) < duration) {
          data.remove('_cached_at');
          data.remove('_cache_duration');
          return data;
        } else {
          await _cacheBox.delete(key);
        }
      }
    } catch (e) {
      _logger.w('Cache read error: $e');
    }
    return null;
  }
  
  Future<void> _cacheResponse(
    String key, 
    Map<String, dynamic> data, 
    Duration? duration,
  ) async {
    try {
      final cacheData = Map<String, dynamic>.from(data);
      cacheData['_cached_at'] = DateTime.now().toIso8601String();
      cacheData['_cache_duration'] = (duration ?? const Duration(minutes: 15)).inMinutes;
      
      await _cacheBox.put(key, cacheData);
    } catch (e) {
      _logger.w('Cache write error: $e');
    }
  }
  
  bool _isValidApiResponse(Map<String, dynamic> data) {
    return data.containsKey('response') && 
           data.containsKey('results') &&
           data['results'] is int;
  }
  
  void _logApiUsage(Response response) {
    final remaining = response.headers['x-ratelimit-requests-remaining']?.first;
    final resetTime = response.headers['x-ratelimit-requests-reset']?.first;
    
    if (remaining != null) {
      _logger.i('API requests remaining: $remaining');
      if (int.tryParse(remaining)! < 10) {
        _logger.w('⚠️ Low API requests remaining: $remaining');
      }
    }
    
    if (resetTime != null) {
      _logger.i('Rate limit resets at: $resetTime');
    }
  }
  
  void _loadRateLimitData() {
    try {
      final requestTimes = _rateLimitBox.get('request_times', defaultValue: <String>[]);
      final dailyTimes = _rateLimitBox.get('daily_times', defaultValue: <String>[]);
      
      for (final timeStr in requestTimes) {
        _requestTimes.add(DateTime.parse(timeStr));
      }
      
      for (final timeStr in dailyTimes) {
        _dailyRequestTimes.add(DateTime.parse(timeStr));
      }
      
      // Clean old data
      _cleanOldRequests(DateTime.now());
    } catch (e) {
      _logger.w('Failed to load rate limit data: $e');
    }
  }
  
  void _saveRateLimitData() {
    try {
      final requestTimes = _requestTimes.map((t) => t.toIso8601String()).toList();
      final dailyTimes = _dailyRequestTimes.map((t) => t.toIso8601String()).toList();
      
      _rateLimitBox.put('request_times', requestTimes);
      _rateLimitBox.put('daily_times', dailyTimes);
    } catch (e) {
      _logger.w('Failed to save rate limit data: $e');
    }
  }
  
  ApiException _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ApiException('Connection timeout. Please check your internet connection.', 408);
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode ?? 0;
        final message = e.response?.data?['message'] ?? e.message;
        return ApiException(message ?? 'API request failed', statusCode);
      case DioExceptionType.cancel:
        return ApiException('Request was cancelled', 0);
      case DioExceptionType.connectionError:
        return ApiException('Connection error. Please check your internet connection.', 0);
      default:
        return ApiException('Unknown error occurred: ${e.message}', 0);
    }
  }
  
  /// Get API usage statistics
  ApiUsageStats getUsageStats() {
    final now = DateTime.now();
    _cleanOldRequests(now);
    
    return ApiUsageStats(
      requestsThisMinute: _requestTimes.length,
      requestsToday: _dailyRequestTimes.length,
      maxRequestsPerMinute: _requestsPerMinute,
      maxRequestsPerDay: _requestsPerDay,
      nextResetTime: _requestTimes.isNotEmpty 
          ? _requestTimes.first.add(_rateLimitWindow)
          : now,
    );
  }
  
  /// Clear all cached data
  Future<void> clearCache() async {
    try {
      await _cacheBox.clear();
      _logger.i('API cache cleared');
    } catch (e) {
      _logger.e('Failed to clear cache: $e');
    }
  }
}

/// API Exception class
class ApiException implements Exception {
  final String message;
  final int statusCode;
  
  ApiException(this.message, this.statusCode);
  
  @override
  String toString() => 'ApiException($statusCode): $message';
}

/// API Usage Statistics
class ApiUsageStats {
  final int requestsThisMinute;
  final int requestsToday;
  final int maxRequestsPerMinute;
  final int maxRequestsPerDay;
  final DateTime nextResetTime;
  
  ApiUsageStats({
    required this.requestsThisMinute,
    required this.requestsToday,
    required this.maxRequestsPerMinute,
    required this.maxRequestsPerDay,
    required this.nextResetTime,
  });
  
  double get minuteUsagePercentage => (requestsThisMinute / maxRequestsPerMinute) * 100;
  double get dailyUsagePercentage => (requestsToday / maxRequestsPerDay) * 100;
  bool get isNearMinuteLimit => minuteUsagePercentage > 80;
  bool get isNearDailyLimit => dailyUsagePercentage > 80;
}

// Data models for API responses
class LeagueData {
  final int id;
  final String name;
  final String type;
  final String? logo;
  final CountryData country;
  final List<SeasonData> seasons;
  
  LeagueData({
    required this.id,
    required this.name,
    required this.type,
    this.logo,
    required this.country,
    required this.seasons,
  });
  
  factory LeagueData.fromJson(Map<String, dynamic> json) {
    return LeagueData(
      id: json['league']['id'],
      name: json['league']['name'],
      type: json['league']['type'],
      logo: json['league']['logo'],
      country: CountryData.fromJson(json['country']),
      seasons: (json['seasons'] as List?)
          ?.map((s) => SeasonData.fromJson(s))
          .toList() ?? [],
    );
  }
}

class CountryData {
  final String? name;
  final String? code;
  final String? flag;
  
  CountryData({this.name, this.code, this.flag});
  
  factory CountryData.fromJson(Map<String, dynamic> json) {
    return CountryData(
      name: json['name'],
      code: json['code'],
      flag: json['flag'],
    );
  }
}

class SeasonData {
  final int year;
  final String start;
  final String end;
  final bool current;
  
  SeasonData({
    required this.year,
    required this.start,
    required this.end,
    required this.current,
  });
  
  factory SeasonData.fromJson(Map<String, dynamic> json) {
    return SeasonData(
      year: json['year'],
      start: json['start'],
      end: json['end'],
      current: json['current'] ?? false,
    );
  }
}

class TeamData {
  final int id;
  final String name;
  final String? code;
  final int? founded;
  final bool national;
  final String? logo;
  final VenueData? venue;
  
  TeamData({
    required this.id,
    required this.name,
    this.code,
    this.founded,
    required this.national,
    this.logo,
    this.venue,
  });
  
  factory TeamData.fromJson(Map<String, dynamic> json) {
    return TeamData(
      id: json['id'],
      name: json['name'],
      code: json['code'],
      founded: json['founded'],
      national: json['national'] ?? false,
      logo: json['logo'],
      venue: json['venue'] != null ? VenueData.fromJson(json['venue']) : null,
    );
  }
}

class VenueData {
  final int? id;
  final String? name;
  final String? address;
  final String? city;
  final int? capacity;
  final String? surface;
  final String? image;
  
  VenueData({
    this.id,
    this.name,
    this.address,
    this.city,
    this.capacity,
    this.surface,
    this.image,
  });
  
  factory VenueData.fromJson(Map<String, dynamic> json) {
    return VenueData(
      id: json['id'],
      name: json['name'],
      address: json['address'],
      city: json['city'],
      capacity: json['capacity'],
      surface: json['surface'],
      image: json['image'],
    );
  }
}

class FixtureData {
  final int id;
  final String? referee;
  final String timezone;
  final DateTime date;
  final int? timestamp;
  final VenueData? venue;
  final FixtureStatusData status;
  final TeamInFixtureData homeTeam;
  final TeamInFixtureData awayTeam;
  final GoalsData? goals;
  final ScoreData? score;
  
  FixtureData({
    required this.id,
    this.referee,
    required this.timezone,
    required this.date,
    this.timestamp,
    this.venue,
    required this.status,
    required this.homeTeam,
    required this.awayTeam,
    this.goals,
    this.score,
  });
  
  factory FixtureData.fromJson(Map<String, dynamic> json) {
    return FixtureData(
      id: json['fixture']['id'],
      referee: json['fixture']['referee'],
      timezone: json['fixture']['timezone'],
      date: DateTime.parse(json['fixture']['date']),
      timestamp: json['fixture']['timestamp'],
      venue: json['fixture']['venue'] != null ? VenueData.fromJson(json['fixture']['venue']) : null,
      status: FixtureStatusData.fromJson(json['fixture']['status']),
      homeTeam: TeamInFixtureData.fromJson(json['teams']['home']),
      awayTeam: TeamInFixtureData.fromJson(json['teams']['away']),
      goals: json['goals'] != null ? GoalsData.fromJson(json['goals']) : null,
      score: json['score'] != null ? ScoreData.fromJson(json['score']) : null,
    );
  }
  
  bool get isFinished => status.short == 'FT';
  bool get isLive => ['1H', '2H', 'HT', 'ET', 'BT', 'P'].contains(status.short);
  bool get isScheduled => status.short == 'NS';
  bool get isDraw => isFinished && goals?.home == goals?.away;
  
  bool isTeamWinner(int teamId) {
    if (!isFinished || goals == null) return false;
    if (teamId == homeTeam.id) {
      return goals!.home! > goals!.away!;
    } else if (teamId == awayTeam.id) {
      return goals!.away! > goals!.home!;
    }
    return false;
  }
  
  bool isTeamLoser(int teamId) {
    if (!isFinished || goals == null) return false;
    return !isTeamWinner(teamId) && !isDraw;
  }
}

class FixtureStatusData {
  final String? long;
  final String short;
  final int? elapsed;
  
  FixtureStatusData({
    this.long,
    required this.short,
    this.elapsed,
  });
  
  factory FixtureStatusData.fromJson(Map<String, dynamic> json) {
    return FixtureStatusData(
      long: json['long'],
      short: json['short'],
      elapsed: json['elapsed'],
    );
  }
}

class TeamInFixtureData {
  final int id;
  final String name;
  final String? logo;
  final bool? winner;
  
  TeamInFixtureData({
    required this.id,
    required this.name,
    this.logo,
    this.winner,
  });
  
  factory TeamInFixtureData.fromJson(Map<String, dynamic> json) {
    return TeamInFixtureData(
      id: json['id'],
      name: json['name'],
      logo: json['logo'],
      winner: json['winner'],
    );
  }
}

class GoalsData {
  final int? home;
  final int? away;
  
  GoalsData({this.home, this.away});
  
  factory GoalsData.fromJson(Map<String, dynamic> json) {
    return GoalsData(
      home: json['home'],
      away: json['away'],
    );
  }
}

class ScoreData {
  final GoalsData? halftime;
  final GoalsData? fulltime;
  final GoalsData? extratime;
  final GoalsData? penalty;
  
  ScoreData({
    this.halftime,
    this.fulltime,
    this.extratime,
    this.penalty,
  });
  
  factory ScoreData.fromJson(Map<String, dynamic> json) {
    return ScoreData(
      halftime: json['halftime'] != null ? GoalsData.fromJson(json['halftime']) : null,
      fulltime: json['fulltime'] != null ? GoalsData.fromJson(json['fulltime']) : null,
      extratime: json['extratime'] != null ? GoalsData.fromJson(json['extratime']) : null,
      penalty: json['penalty'] != null ? GoalsData.fromJson(json['penalty']) : null,
    );
  }
}

class StandingData {
  final int rank;
  final TeamData team;
  final int points;
  final int goalsDiff;
  final String group;
  final String form;
  final String status;
  final String? description;
  final MatchStatsData all;
  final MatchStatsData home;
  final MatchStatsData away;
  
  StandingData({
    required this.rank,
    required this.team,
    required this.points,
    required this.goalsDiff,
    required this.group,
    required this.form,
    required this.status,
    this.description,
    required this.all,
    required this.home,
    required this.away,
  });
  
  factory StandingData.fromJson(Map<String, dynamic> json) {
    return StandingData(
      rank: json['rank'],
      team: TeamData.fromJson(json['team']),
      points: json['points'],
      goalsDiff: json['goalsDiff'],
      group: json['group'],
      form: json['form'] ?? '',
      status: json['status'],
      description: json['description'],
      all: MatchStatsData.fromJson(json['all']),
      home: MatchStatsData.fromJson(json['home']),
      away: MatchStatsData.fromJson(json['away']),
    );
  }
}

class MatchStatsData {
  final int played;
  final int win;
  final int draw;
  final int lose;
  final GoalsData goals;
  
  MatchStatsData({
    required this.played,
    required this.win,
    required this.draw,
    required this.lose,
    required this.goals,
  });
  
  factory MatchStatsData.fromJson(Map<String, dynamic> json) {
    return MatchStatsData(
      played: json['played'],
      win: json['win'],
      draw: json['draw'],
      lose: json['lose'],
      goals: GoalsData.fromJson(json['goals']),
    );
  }
}

class TeamStatsData {
  final String form;
  final MatchStatsData all;
  final MatchStatsData home;
  final MatchStatsData away;
  final GoalsStatsData goals;
  final int? biggestWinHome;
  final int? biggestWinAway;
  final int? biggestLoseHome;
  final int? biggestLoseAway;
  
  TeamStatsData({
    required this.form,
    required this.all,
    required this.home,
    required this.away,
    required this.goals,
    this.biggestWinHome,
    this.biggestWinAway,
    this.biggestLoseHome,
    this.biggestLoseAway,
  });
  
  factory TeamStatsData.fromJson(Map<String, dynamic> json) {
    return TeamStatsData(
      form: json['form'] ?? '',
      all: MatchStatsData.fromJson(json['fixtures']['played']),
      home: MatchStatsData.fromJson(json['fixtures']['played']['home']),
      away: MatchStatsData.fromJson(json['fixtures']['played']['away']),
      goals: GoalsStatsData.fromJson(json['goals']),
      biggestWinHome: json['biggest']['wins']?['home'],
      biggestWinAway: json['biggest']['wins']?['away'],
      biggestLoseHome: json['biggest']['loses']?['home'],
      biggestLoseAway: json['biggest']['loses']?['away'],
    );
  }
}

class GoalsStatsData {
  final GoalsForAgainstData goalsFor;
  final GoalsForAgainstData goalsAgainst;
  
  GoalsStatsData({
    required this.goalsFor,
    required this.goalsAgainst,
  });
  
  factory GoalsStatsData.fromJson(Map<String, dynamic> json) {
    return GoalsStatsData(
      goalsFor: GoalsForAgainstData.fromJson(json['for']),
      goalsAgainst: GoalsForAgainstData.fromJson(json['against']),
    );
  }
}

class GoalsForAgainstData {
  final int total;
  final double average;
  
  GoalsForAgainstData({
    required this.total,
    required this.average,
  });
  
  factory GoalsForAgainstData.fromJson(Map<String, dynamic> json) {
    return GoalsForAgainstData(
      total: json['total']?['total'] ?? 0,
      average: (json['average']?['total'] ?? 0.0).toDouble(),
    );
  }
}

// Provider for the production API client
final productionFootballApiProvider = Provider<ProductionFootballApi>((ref) {
  return ProductionFootballApi();
});