import 'package:dio/dio.dart';

import '../../../../core/network/api_client.dart';
import '../../../../shared/data/models/fixture_model.dart';

abstract class FixturesRemoteDataSource {
  Future<List<FixtureModel>> getFixtures({
    int? leagueId,
    int? teamId,
    DateTime? from,
    DateTime? to,
    String? status,
    int? matchday,
    String? venue,
    int? limit,
    int? offset,
  });

  Future<FixtureModel> getFixture(int fixtureId);
  Future<FixtureModel> getFixtureDetails(int fixtureId);
  Future<List<FixtureModel>> getFixturesByLeague(
    int leagueId, {
    DateTime? from,
    DateTime? to,
    String? status,
    int? matchday,
    int? limit,
    int? offset,
  });
  Future<List<FixtureModel>> getFixturesByTeam(
    int teamId, {
    DateTime? from,
    DateTime? to,
    String? status,
    int? limit,
    int? offset,
  });
  Future<List<FixtureModel>> getLiveFixtures();
  Future<List<FixtureModel>> getUpcomingFixtures({
    int? leagueId,
    int? teamId,
    int? limit,
  });
  Future<List<FixtureModel>> getRecentFixtures({
    int? leagueId,
    int? teamId,
    int? limit,
  });
  Future<List<FixtureModel>> getFixturesByDateRange(
    DateTime from,
    DateTime to, {
    int? leagueId,
    int? teamId,
  });
  Future<List<FixtureModel>> getFixturesByMatchday(int leagueId, int matchday);
  Future<List<FixtureModel>> searchFixtures(String query);
  Future<Map<String, dynamic>> getHeadToHead(int team1Id, int team2Id, {int? limit});
  Future<Map<String, dynamic>> getMatchStatistics(int fixtureId);
  Future<List<Map<String, dynamic>>> getMatchEvents(int fixtureId);
  Future<Map<String, dynamic>> getMatchLineups(int fixtureId);
}

class FixturesRemoteDataSourceImpl implements FixturesRemoteDataSource {
  final ApiClient apiClient;

  FixturesRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<FixtureModel>> getFixtures({
    int? leagueId,
    int? teamId,
    DateTime? from,
    DateTime? to,
    String? status,
    int? matchday,
    String? venue,
    int? limit,
    int? offset,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      
      if (leagueId != null) queryParams['leagueId'] = leagueId;
      if (teamId != null) queryParams['teamId'] = teamId;
      if (from != null) queryParams['from'] = from.toIso8601String();
      if (to != null) queryParams['to'] = to.toIso8601String();
      if (status != null) queryParams['status'] = status;
      if (matchday != null) queryParams['matchday'] = matchday;
      if (venue != null) queryParams['venue'] = venue;
      if (limit != null) queryParams['limit'] = limit;
      if (offset != null) queryParams['offset'] = offset;

      final response = await apiClient.get('/fixtures', queryParameters: queryParams);
      
      if (response.statusCode == 200) {
        final List<dynamic> fixturesJson = response.data['matches'] ?? response.data;
        return fixturesJson.map((json) => FixtureModel.fromJson(json)).toList();
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: 'Failed to fetch fixtures',
        );
      }
    } catch (e) {
      throw DioException(
        requestOptions: RequestOptions(path: '/fixtures'),
        message: 'Network error: $e',
      );
    }
  }

  @override
  Future<FixtureModel> getFixture(int fixtureId) async {
    try {
      final response = await apiClient.get('/fixtures/$fixtureId');
      
      if (response.statusCode == 200) {
        return FixtureModel.fromJson(response.data);
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: 'Failed to fetch fixture',
        );
      }
    } catch (e) {
      throw DioException(
        requestOptions: RequestOptions(path: '/fixtures/$fixtureId'),
        message: 'Network error: $e',
      );
    }
  }

  @override
  Future<FixtureModel> getFixtureDetails(int fixtureId) async {
    try {
      final response = await apiClient.get('/fixtures/$fixtureId/details');
      
      if (response.statusCode == 200) {
        return FixtureModel.fromJson(response.data);
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: 'Failed to fetch fixture details',
        );
      }
    } catch (e) {
      throw DioException(
        requestOptions: RequestOptions(path: '/fixtures/$fixtureId/details'),
        message: 'Network error: $e',
      );
    }
  }

  @override
  Future<List<FixtureModel>> getFixturesByLeague(
    int leagueId, {
    DateTime? from,
    DateTime? to,
    String? status,
    int? matchday,
    int? limit,
    int? offset,
  }) async {
    return await getFixtures(
      leagueId: leagueId,
      from: from,
      to: to,
      status: status,
      matchday: matchday,
      limit: limit,
      offset: offset,
    );
  }

  @override
  Future<List<FixtureModel>> getFixturesByTeam(
    int teamId, {
    DateTime? from,
    DateTime? to,
    String? status,
    int? limit,
    int? offset,
  }) async {
    return await getFixtures(
      teamId: teamId,
      from: from,
      to: to,
      status: status,
      limit: limit,
      offset: offset,
    );
  }

  @override
  Future<List<FixtureModel>> getLiveFixtures() async {
    return await getFixtures(status: 'IN_PLAY');
  }

  @override
  Future<List<FixtureModel>> getUpcomingFixtures({
    int? leagueId,
    int? teamId,
    int? limit,
  }) async {
    final now = DateTime.now();
    return await getFixtures(
      leagueId: leagueId,
      teamId: teamId,
      from: now,
      status: 'SCHEDULED',
      limit: limit,
    );
  }

  @override
  Future<List<FixtureModel>> getRecentFixtures({
    int? leagueId,
    int? teamId,
    int? limit,
  }) async {
    final now = DateTime.now();
    return await getFixtures(
      leagueId: leagueId,
      teamId: teamId,
      to: now,
      status: 'FINISHED',
      limit: limit,
    );
  }

  @override
  Future<List<FixtureModel>> getFixturesByDateRange(
    DateTime from,
    DateTime to, {
    int? leagueId,
    int? teamId,
  }) async {
    return await getFixtures(
      leagueId: leagueId,
      teamId: teamId,
      from: from,
      to: to,
    );
  }

  @override
  Future<List<FixtureModel>> getFixturesByMatchday(int leagueId, int matchday) async {
    return await getFixtures(
      leagueId: leagueId,
      matchday: matchday,
    );
  }

  @override
  Future<List<FixtureModel>> searchFixtures(String query) async {
    try {
      final response = await apiClient.get('/fixtures/search', queryParameters: {
        'q': query,
      });
      
      if (response.statusCode == 200) {
        final List<dynamic> fixturesJson = response.data['matches'] ?? response.data;
        return fixturesJson.map((json) => FixtureModel.fromJson(json)).toList();
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: 'Failed to search fixtures',
        );
      }
    } catch (e) {
      throw DioException(
        requestOptions: RequestOptions(path: '/fixtures/search'),
        message: 'Network error: $e',
      );
    }
  }

  @override
  Future<Map<String, dynamic>> getHeadToHead(int team1Id, int team2Id, {int? limit}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (limit != null) queryParams['limit'] = limit;

      final response = await apiClient.get(
        '/fixtures/head-to-head/$team1Id/$team2Id',
        queryParameters: queryParams,
      );
      
      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: 'Failed to fetch head to head',
        );
      }
    } catch (e) {
      throw DioException(
        requestOptions: RequestOptions(path: '/fixtures/head-to-head/$team1Id/$team2Id'),
        message: 'Network error: $e',
      );
    }
  }

  @override
  Future<Map<String, dynamic>> getMatchStatistics(int fixtureId) async {
    try {
      final response = await apiClient.get('/fixtures/$fixtureId/statistics');
      
      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: 'Failed to fetch match statistics',
        );
      }
    } catch (e) {
      throw DioException(
        requestOptions: RequestOptions(path: '/fixtures/$fixtureId/statistics'),
        message: 'Network error: $e',
      );
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getMatchEvents(int fixtureId) async {
    try {
      final response = await apiClient.get('/fixtures/$fixtureId/events');
      
      if (response.statusCode == 200) {
        final List<dynamic> eventsJson = response.data['events'] ?? response.data;
        return eventsJson.cast<Map<String, dynamic>>();
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: 'Failed to fetch match events',
        );
      }
    } catch (e) {
      throw DioException(
        requestOptions: RequestOptions(path: '/fixtures/$fixtureId/events'),
        message: 'Network error: $e',
      );
    }
  }

  @override
  Future<Map<String, dynamic>> getMatchLineups(int fixtureId) async {
    try {
      final response = await apiClient.get('/fixtures/$fixtureId/lineups');
      
      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: 'Failed to fetch match lineups',
        );
      }
    } catch (e) {
      throw DioException(
        requestOptions: RequestOptions(path: '/fixtures/$fixtureId/lineups'),
        message: 'Network error: $e',
      );
    }
  }
}