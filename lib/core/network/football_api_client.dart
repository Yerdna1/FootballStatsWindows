import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../constants/app_constants.dart';
import '../../shared/data/models/fixture_model_simple.dart';

class FootballApiClient {
  final Dio _dio;
  final Logger _logger = Logger();
  late Box _cacheBox;
  static const String _cacheBoxName = 'api_cache';

  FootballApiClient({Dio? dio}) : _dio = dio ?? Dio() {
    _setupInterceptors();
    _initCache();
  }

  Future<void> _initCache() async {
    try {
      _cacheBox = await Hive.openBox(_cacheBoxName);
    } catch (e) {
      _logger.e('Failed to initialize cache box: $e');
    }
  }

  void _setupInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // Add API key to headers
          options.headers['X-RapidAPI-Key'] = AppConstants.footballApiKey;
          options.headers['X-RapidAPI-Host'] = AppConstants.footballApiHost;
          
          _logger.i('🌐 ${options.method} ${options.uri}');
          
          handler.next(options);
        },
        onResponse: (response, handler) {
          _logger.i('✅ ${response.statusCode} ${response.requestOptions.uri}');
          handler.next(response);
        },
        onError: (error, handler) {
          _logger.e('❌ ${error.response?.statusCode} ${error.requestOptions.uri}');
          _logger.e('Error: ${error.message}');
          handler.next(error);
        },
      ),
    );
  }

  // Generic GET request
  Future<Map<String, dynamic>> get(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.get(
        '${AppConstants.footballApiBaseUrl}$endpoint',
        queryParameters: queryParameters,
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // Generic POST request
  Future<Map<String, dynamic>> post(
    String endpoint, {
    Map<String, dynamic>? data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.post(
        '${AppConstants.footballApiBaseUrl}$endpoint',
        data: data,
        queryParameters: queryParameters,
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // Cache management
  Future<T?> _getFromCache<T>(String key) async {
    try {
      final cachedData = _cacheBox.get(key);
      if (cachedData != null) {
        final cacheEntry = Map<String, dynamic>.from(cachedData);
        final timestamp = DateTime.parse(cacheEntry['timestamp']);
        final cacheDuration = Duration(minutes: cacheEntry['duration'] ?? 15);
        
        if (DateTime.now().difference(timestamp) < cacheDuration) {
          return cacheEntry['data'] as T;
        } else {
          await _cacheBox.delete(key);
        }
      }
    } catch (e) {
      _logger.w('Cache read error for key $key: $e');
    }
    return null;
  }

  Future<void> _setCache(String key, dynamic data, {int durationMinutes = 15}) async {
    try {
      await _cacheBox.put(key, {
        'data': data,
        'timestamp': DateTime.now().toIso8601String(),
        'duration': durationMinutes,
      });
    } catch (e) {
      _logger.w('Cache write error for key $key: $e');
    }
  }

  // Enhanced get method with caching
  Future<Map<String, dynamic>> getCached(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
    int cacheDurationMinutes = 15,
  }) async {
    final cacheKey = '$endpoint${queryParameters?.toString() ?? ''}';
    
    // Try to get from cache first
    final cachedData = await _getFromCache<Map<String, dynamic>>(cacheKey);
    if (cachedData != null) {
      _logger.i('📦 Cache hit for $endpoint');
      return cachedData;
    }

    // Fetch from API and cache
    final data = await get(endpoint, queryParameters: queryParameters);
    await _setCache(cacheKey, data, durationMinutes: cacheDurationMinutes);
    return data;
  }

  // Fixtures API methods
  Future<List<FixtureModel>> getFixtures({
    int? leagueId,
    int? season,
    String? date,
    int? teamId,
    bool live = false,
  }) async {
    final queryParams = <String, dynamic>{};
    if (leagueId != null) queryParams['league'] = leagueId;
    if (season != null) queryParams['season'] = season;
    if (date != null) queryParams['date'] = date;
    if (teamId != null) queryParams['team'] = teamId;
    if (live) queryParams['live'] = 'all';

    final response = await getCached('/fixtures', queryParameters: queryParams);
    
    final fixtures = <FixtureModel>[];
    if (response['response'] != null) {
      for (final fixture in response['response']) {
        try {
          fixtures.add(FixtureModel.fromJson(fixture));
        } catch (e) {
          _logger.w('Failed to parse fixture: $e');
        }
      }
    }
    return fixtures;
  }

  // Teams API methods
  Future<List<TeamModel>> getTeams({int? leagueId, int? season}) async {
    final queryParams = <String, dynamic>{};
    if (leagueId != null) queryParams['league'] = leagueId;
    if (season != null) queryParams['season'] = season;

    final response = await getCached('/teams', queryParameters: queryParams, cacheDurationMinutes: 60);
    
    final teams = <TeamModel>[];
    if (response['response'] != null) {
      for (final team in response['response']) {
        try {
          teams.add(TeamModel.fromJson(team['team']));
        } catch (e) {
          _logger.w('Failed to parse team: $e');
        }
      }
    }
    return teams;
  }

  // Team statistics
  Future<AdvancedStatisticsModel?> getTeamStatistics(int teamId, int leagueId, int season) async {
    final queryParams = {
      'team': teamId,
      'league': leagueId,
      'season': season,
    };

    final response = await getCached('/teams/statistics', queryParameters: queryParams, cacheDurationMinutes: 30);
    
    if (response['response'] != null) {
      try {
        return AdvancedStatisticsModel.fromJson(response['response']);
      } catch (e) {
        _logger.w('Failed to parse team statistics: $e');
      }
    }
    return null;
  }

  // Team form analysis
  Future<TeamFormModel?> getTeamForm(int teamId, {int matchCount = 10}) async {
    // Get recent fixtures for the team
    final fixtures = await getFixtures(teamId: teamId);
    final recentFixtures = fixtures.take(matchCount).toList();
    
    if (recentFixtures.isEmpty) return null;

    // Calculate form data
    int wins = 0, draws = 0, losses = 0;
    int goalsFor = 0, goalsAgainst = 0;
    final results = <String>[];

    for (final fixture in recentFixtures) {
      final isHome = fixture.teams?.home?.id == teamId;
      final homeGoals = fixture.goals?.home ?? 0;
      final awayGoals = fixture.goals?.away ?? 0;
      
      goalsFor += isHome ? homeGoals : awayGoals;
      goalsAgainst += isHome ? awayGoals : homeGoals;

      if (homeGoals == awayGoals) {
        draws++;
        results.add('D');
      } else if ((isHome && homeGoals > awayGoals) || (!isHome && awayGoals > homeGoals)) {
        wins++;
        results.add('W');
      } else {
        losses++;
        results.add('L');
      }
    }

    return TeamFormModel(
      teamId: teamId,
      recentMatches: recentFixtures.length,
      wins: wins,
      draws: draws,
      losses: losses,
      goalsFor: goalsFor,
      goalsAgainst: goalsAgainst,
      form: results.join(),
      formPercentage: (wins * 3 + draws) / (recentFixtures.length * 3) * 100,
      lastUpdated: DateTime.now(),
    );
  }

  // Leagues API methods
  Future<List<LeagueModel>> getLeagues({int? countryId, String? countryName}) async {
    final queryParams = <String, dynamic>{};
    if (countryId != null) queryParams['country_id'] = countryId;
    if (countryName != null) queryParams['country'] = countryName;

    final response = await getCached('/leagues', queryParameters: queryParams, cacheDurationMinutes: 120);
    
    final leagues = <LeagueModel>[];
    if (response['response'] != null) {
      for (final league in response['response']) {
        try {
          leagues.add(LeagueModel.fromJson(league['league']));
        } catch (e) {
          _logger.w('Failed to parse league: $e');
        }
      }
    }
    return leagues;
  }

  // Standings API methods
  Future<List<StandingsModel>> getStandings(int leagueId, int season) async {
    final queryParams = {
      'league': leagueId,
      'season': season,
    };

    final response = await getCached('/standings', queryParameters: queryParams, cacheDurationMinutes: 30);
    
    final standings = <StandingsModel>[];
    if (response['response'] != null && response['response'].isNotEmpty) {
      final standingsData = response['response'][0]['league']['standings'];
      if (standingsData != null) {
        for (final group in standingsData) {
          for (final standing in group) {
            try {
              standings.add(StandingsModel.fromJson(standing));
            } catch (e) {
              _logger.w('Failed to parse standing: $e');
            }
          }
        }
      }
    }
    return standings;
  }

  // Predictions (if available from API)
  Future<PredictionModel?> getPrediction(int fixtureId) async {
    final queryParams = {'fixture': fixtureId};

    try {
      final response = await getCached('/predictions', queryParameters: queryParams, cacheDurationMinutes: 60);
      
      if (response['response'] != null && response['response'].isNotEmpty) {
        return PredictionModel.fromJson(response['response'][0]);
      }
    } catch (e) {
      _logger.w('Failed to get prediction for fixture $fixtureId: $e');
    }
    return null;
  }

  // Live scores
  Future<List<FixtureModel>> getLiveFixtures() async {
    return getFixtures(live: true);
  }

  // Batch request method for multiple API calls
  Future<Map<String, dynamic>> batchRequests(List<Map<String, dynamic>> requests) async {
    final results = <String, dynamic>{};
    
    for (final request in requests) {
      final endpoint = request['endpoint'] as String;
      final params = request['params'] as Map<String, dynamic>?;
      final key = request['key'] as String;
      
      try {
        final result = await getCached(endpoint, queryParameters: params);
        results[key] = result;
      } catch (e) {
        _logger.e('Batch request failed for $endpoint: $e');
        results[key] = {'error': e.toString()};
      }
      
      // Small delay to respect rate limits
      await Future.delayed(const Duration(milliseconds: 200));
    }
    
    return results;
  }

  // Clear cache
  Future<void> clearCache() async {
    try {
      await _cacheBox.clear();
      _logger.i('Cache cleared successfully');
    } catch (e) {
      _logger.e('Failed to clear cache: $e');
    }
  }

  Exception _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return Exception('Connection timeout. Please check your internet connection.');
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        if (statusCode == 401) {
          return Exception('Unauthorized. Please check your API key.');
        } else if (statusCode == 403) {
          return Exception('Forbidden. API access denied.');
        } else if (statusCode == 404) {
          return Exception('Data not found.');
        } else if (statusCode == 429) {
          return Exception('Rate limit exceeded. Please try again later.');
        } else if (statusCode == 500) {
          return Exception('Server error. Please try again later.');
        }
        return Exception('HTTP Error: $statusCode');
      case DioExceptionType.cancel:
        return Exception('Request was cancelled.');
      case DioExceptionType.connectionError:
        return Exception('Connection error. Please check your internet connection.');
      default:
        return Exception('Unknown error occurred: ${e.message}');
    }
  }
}

// Provider for the API client
final footballApiClientProvider = Provider<FootballApiClient>((ref) {
  return FootballApiClient();
});