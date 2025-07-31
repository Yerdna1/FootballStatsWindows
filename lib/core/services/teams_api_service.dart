import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../network/football_api_client.dart';
import '../../shared/data/models/team_model.dart';
import '../../shared/data/models/player_model.dart';

class TeamsApiService {
  final FootballApiClient _apiClient;

  TeamsApiService(this._apiClient);

  /// Get teams by league and season
  Future<List<TeamModel>> getTeamsByLeague({
    required int leagueId,
    required String season,
    int? teamId,
    String? name,
    String? country,
    String? code,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'league': leagueId,
        'season': season,
      };
      
      if (teamId != null) queryParams['id'] = teamId;
      if (name != null) queryParams['name'] = name;
      if (country != null) queryParams['country'] = country;
      if (code != null) queryParams['code'] = code;

      final response = await _apiClient.get('/teams', queryParameters: queryParams);
      
      final teams = <TeamModel>[];
      final responseData = response['response'] as List<dynamic>;
      
      for (final item in responseData) {
        final teamData = item['team'];
        final venueData = item['venue'];
        
        teams.add(TeamModel.fromJson({
          ...teamData,
          'venue': venueData,
        }));
      }
      
      return teams;
    } catch (e) {
      throw Exception('Failed to fetch teams: $e');
    }
  }

  /// Get team by ID
  Future<TeamModel?> getTeamById(int teamId) async {
    try {
      final response = await _apiClient.get('/teams', queryParameters: {'id': teamId});
      
      final responseData = response['response'] as List<dynamic>;
      if (responseData.isEmpty) return null;
      
      final item = responseData.first;
      final teamData = item['team'];
      final venueData = item['venue'];
      
      return TeamModel.fromJson({
        ...teamData,
        'venue': venueData,
      });
    } catch (e) {
      throw Exception('Failed to fetch team by ID: $e');
    }
  }

  /// Get team statistics for a specific league and season
  Future<Map<String, dynamic>> getTeamStatistics({
    required int teamId,
    required int leagueId,
    required String season,
  }) async {
    try {
      final response = await _apiClient.get(
        '/teams/statistics',
        queryParameters: {
          'team': teamId,
          'league': leagueId,
          'season': season,
        },
      );
      
      return response['response'] as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Failed to fetch team statistics: $e');
    }
  }

  /// Search teams by name
  Future<List<TeamModel>> searchTeams(String query, {String? country}) async {
    try {
      final queryParams = <String, dynamic>{
        'search': query,
      };
      
      if (country != null) queryParams['country'] = country;

      final response = await _apiClient.get('/teams', queryParameters: queryParams);
      
      final teams = <TeamModel>[];
      final responseData = response['response'] as List<dynamic>;
      
      for (final item in responseData) {
        final teamData = item['team'];
        final venueData = item['venue'];
        
        teams.add(TeamModel.fromJson({
          ...teamData,
          'venue': venueData,
        }));
      }
      
      return teams;
    } catch (e) {
      throw Exception('Failed to search teams: $e');
    }
  }

  /// Get teams by country
  Future<List<TeamModel>> getTeamsByCountry(String country) async {
    try {
      final response = await _apiClient.get('/teams', queryParameters: {'country': country});
      
      final teams = <TeamModel>[];
      final responseData = response['response'] as List<dynamic>;
      
      for (final item in responseData) {
        final teamData = item['team'];
        final venueData = item['venue'];
        
        teams.add(TeamModel.fromJson({
          ...teamData,
          'venue': venueData,
        }));
      }
      
      return teams;
    } catch (e) {
      throw Exception('Failed to fetch teams by country: $e');
    }
  }

  /// Get team squad/players
  Future<List<PlayerModel>> getTeamSquad({
    required int teamId,
    String? season,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'team': teamId,
      };
      
      if (season != null) queryParams['season'] = season;

      final response = await _apiClient.get('/players/squads', queryParameters: queryParams);
      
      final players = <PlayerModel>[];
      final responseData = response['response'] as List<dynamic>;
      
      if (responseData.isNotEmpty) {
        final squadData = responseData.first['players'] as List<dynamic>;
        
        for (final playerData in squadData) {
          players.add(PlayerModel.fromJson(playerData));
        }
      }
      
      return players;
    } catch (e) {
      throw Exception('Failed to fetch team squad: $e');
    }
  }

  /// Get popular teams (most followed/successful teams)
  Future<List<TeamModel>> getPopularTeams() async {
    try {
      // Get teams from popular leagues
      final popularLeagues = [39, 140, 78, 135, 61]; // Premier League, La Liga, Bundesliga, Serie A, Ligue 1
      final currentSeason = DateTime.now().year.toString();
      final allTeams = <TeamModel>[];
      
      for (final leagueId in popularLeagues) {
        try {
          final teams = await getTeamsByLeague(
            leagueId: leagueId,
            season: currentSeason,
          );
          
          // Take top 4 teams from each league
          allTeams.addAll(teams.take(4));
        } catch (e) {
          // Continue with other leagues if one fails
          continue;
        }
      }
      
      return allTeams;
    } catch (e) {
      throw Exception('Failed to fetch popular teams: $e');
    }
  }

  /// Get team's recent form (last 5 matches)
  Future<List<Map<String, dynamic>>> getTeamForm({
    required int teamId,
    required int leagueId,
    required String season,
  }) async {
    try {
      // This would typically come from fixtures endpoint with team filter
      final response = await _apiClient.get(
        '/fixtures',
        queryParameters: {
          'team': teamId,
          'league': leagueId,
          'season': season,
          'last': 5,
        },
      );
      
      final fixtures = response['response'] as List<dynamic>;
      return fixtures.cast<Map<String, dynamic>>();
    } catch (e) {
      throw Exception('Failed to fetch team form: $e');
    }
  }

  /// Get head to head between two teams
  Future<Map<String, dynamic>> getHeadToHead({
    required int team1Id,
    required int team2Id,
    int? last,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'h2h': '$team1Id-$team2Id',
      };
      
      if (last != null) queryParams['last'] = last;

      final response = await _apiClient.get('/fixtures/headtohead', queryParameters: queryParams);
      
      return response['response'] as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Failed to fetch head to head: $e');
    }
  }

  /// Get team transfers
  Future<List<Map<String, dynamic>>> getTeamTransfers({
    required int teamId,
    String? season,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'team': teamId,
      };
      
      if (season != null) queryParams['season'] = season;

      final response = await _apiClient.get('/transfers', queryParameters: queryParams);
      
      final transfers = response['response'] as List<dynamic>;
      return transfers.cast<Map<String, dynamic>>();
    } catch (e) {
      throw Exception('Failed to fetch team transfers: $e');
    }
  }

  /// Get team's upcoming fixtures
  Future<List<Map<String, dynamic>>> getTeamUpcomingFixtures({
    required int teamId,
    required int leagueId,
    int? next,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'team': teamId,
        'league': leagueId,
      };
      
      if (next != null) queryParams['next'] = next;

      final response = await _apiClient.get('/fixtures', queryParameters: queryParams);
      
      final fixtures = response['response'] as List<dynamic>;
      return fixtures.cast<Map<String, dynamic>>();
    } catch (e) {
      throw Exception('Failed to fetch upcoming fixtures: $e');
    }
  }
}

// Provider for the teams API service
final teamsApiServiceProvider = Provider<TeamsApiService>((ref) {
  final apiClient = ref.watch(footballApiClientProvider);
  return TeamsApiService(apiClient);
});