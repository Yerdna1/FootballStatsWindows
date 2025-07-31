import 'package:dio/dio.dart';

import '../../../../core/network/api_client.dart';
import '../../../../shared/data/models/team_model.dart';
import '../../../../shared/data/models/fixture_model.dart';

abstract class TeamsRemoteDataSource {
  Future<List<TeamModel>> getTeams({
    String? search,
    int? leagueId,
    String? country,
    int? limit,
    int? offset,
  });

  Future<TeamModel> getTeam(int teamId);
  Future<TeamModel> getTeamDetails(int teamId);
  Future<List<PlayerModel>> getTeamSquad(int teamId);
  Future<List<TeamModel>> getTeamsByLeague(int leagueId);
  Future<List<TeamModel>> searchTeams(String query);
  Future<List<FixtureModel>> getTeamFixtures(
    int teamId, {
    DateTime? from,
    DateTime? to,
    String? status,
    int? limit,
  });
  Future<Map<String, dynamic>> getHeadToHead(int team1Id, int team2Id);
  Future<List<FixtureModel>> getTeamForm(int teamId, {int? limit});
}

class TeamsRemoteDataSourceImpl implements TeamsRemoteDataSource {
  final ApiClient apiClient;

  TeamsRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<TeamModel>> getTeams({
    String? search,
    int? leagueId,
    String? country,
    int? limit,
    int? offset,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      
      if (search != null) queryParams['search'] = search;
      if (leagueId != null) queryParams['leagueId'] = leagueId;
      if (country != null) queryParams['country'] = country;
      if (limit != null) queryParams['limit'] = limit;
      if (offset != null) queryParams['offset'] = offset;

      final response = await apiClient.get('/teams', queryParameters: queryParams);
      
      if (response.statusCode == 200) {
        final List<dynamic> teamsJson = response.data['teams'] ?? response.data;
        return teamsJson.map((json) => TeamModel.fromJson(json)).toList();
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: 'Failed to fetch teams',
        );
      }
    } catch (e) {
      throw DioException(
        requestOptions: RequestOptions(path: '/teams'),
        message: 'Network error: $e',
      );
    }
  }

  @override
  Future<TeamModel> getTeam(int teamId) async {
    try {
      final response = await apiClient.get('/teams/$teamId');
      
      if (response.statusCode == 200) {
        return TeamModel.fromJson(response.data);
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: 'Failed to fetch team',
        );
      }
    } catch (e) {
      throw DioException(
        requestOptions: RequestOptions(path: '/teams/$teamId'),
        message: 'Network error: $e',
      );
    }
  }

  @override
  Future<TeamModel> getTeamDetails(int teamId) async {
    try {
      final response = await apiClient.get('/teams/$teamId/details');
      
      if (response.statusCode == 200) {
        return TeamModel.fromJson(response.data);
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: 'Failed to fetch team details',
        );
      }
    } catch (e) {
      throw DioException(
        requestOptions: RequestOptions(path: '/teams/$teamId/details'),
        message: 'Network error: $e',
      );
    }
  }

  @override
  Future<List<PlayerModel>> getTeamSquad(int teamId) async {
    try {
      final response = await apiClient.get('/teams/$teamId/squad');
      
      if (response.statusCode == 200) {
        final List<dynamic> playersJson = response.data['squad'] ?? response.data;
        return playersJson.map((json) => PlayerModel.fromJson(json)).toList();
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: 'Failed to fetch team squad',
        );
      }
    } catch (e) {
      throw DioException(
        requestOptions: RequestOptions(path: '/teams/$teamId/squad'),
        message: 'Network error: $e',
      );
    }
  }

  @override
  Future<List<TeamModel>> getTeamsByLeague(int leagueId) async {
    try {
      final response = await apiClient.get('/leagues/$leagueId/teams');
      
      if (response.statusCode == 200) {
        final List<dynamic> teamsJson = response.data['teams'] ?? response.data;
        return teamsJson.map((json) => TeamModel.fromJson(json)).toList();
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: 'Failed to fetch league teams',
        );
      }
    } catch (e) {
      throw DioException(
        requestOptions: RequestOptions(path: '/leagues/$leagueId/teams'),
        message: 'Network error: $e',
      );
    }
  }

  @override
  Future<List<TeamModel>> searchTeams(String query) async {
    try {
      final response = await apiClient.get('/teams/search', queryParameters: {
        'q': query,
      });
      
      if (response.statusCode == 200) {
        final List<dynamic> teamsJson = response.data['teams'] ?? response.data;
        return teamsJson.map((json) => TeamModel.fromJson(json)).toList();
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: 'Failed to search teams',
        );
      }
    } catch (e) {
      throw DioException(
        requestOptions: RequestOptions(path: '/teams/search'),
        message: 'Network error: $e',
      );
    }
  }

  @override
  Future<List<FixtureModel>> getTeamFixtures(
    int teamId, {
    DateTime? from,
    DateTime? to,
    String? status,
    int? limit,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      
      if (from != null) queryParams['from'] = from.toIso8601String();
      if (to != null) queryParams['to'] = to.toIso8601String();
      if (status != null) queryParams['status'] = status;
      if (limit != null) queryParams['limit'] = limit;

      final response = await apiClient.get('/teams/$teamId/fixtures', queryParameters: queryParams);
      
      if (response.statusCode == 200) {
        final List<dynamic> fixturesJson = response.data['fixtures'] ?? response.data;
        return fixturesJson.map((json) => FixtureModel.fromJson(json)).toList();
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: 'Failed to fetch team fixtures',
        );
      }
    } catch (e) {
      throw DioException(
        requestOptions: RequestOptions(path: '/teams/$teamId/fixtures'),
        message: 'Network error: $e',
      );
    }
  }

  @override
  Future<Map<String, dynamic>> getHeadToHead(int team1Id, int team2Id) async {
    try {
      final response = await apiClient.get('/teams/$team1Id/head-to-head/$team2Id');
      
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
        requestOptions: RequestOptions(path: '/teams/$team1Id/head-to-head/$team2Id'),
        message: 'Network error: $e',
      );
    }
  }

  @override
  Future<List<FixtureModel>> getTeamForm(int teamId, {int? limit}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (limit != null) queryParams['limit'] = limit;

      final response = await apiClient.get('/teams/$teamId/form', queryParameters: queryParams);
      
      if (response.statusCode == 200) {
        final List<dynamic> fixturesJson = response.data['fixtures'] ?? response.data;
        return fixturesJson.map((json) => FixtureModel.fromJson(json)).toList();
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: 'Failed to fetch team form',
        );
      }
    } catch (e) {
      throw DioException(
        requestOptions: RequestOptions(path: '/teams/$teamId/form'),
        message: 'Network error: $e',
      );
    }
  }
}