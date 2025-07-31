import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../network/football_api_client.dart';
import '../../shared/data/models/standings_model.dart';

class StandingsApiService {
  final FootballApiClient _apiClient;

  StandingsApiService(this._apiClient);

  /// Get standings by league and season
  Future<List<StandingsModel>> getStandings({
    required int leagueId,
    required String season,
    int? teamId,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'league': leagueId,
        'season': season,
      };
      
      if (teamId != null) queryParams['team'] = teamId;

      final response = await _apiClient.get('/standings', queryParameters: queryParams);
      
      final standings = <StandingsModel>[];
      final responseData = response['response'] as List<dynamic>;
      
      for (final standingData in responseData) {
        standings.add(StandingsModel.fromJson(standingData));
      }
      
      return standings;
    } catch (e) {
      throw Exception('Failed to fetch standings: $e');
    }
  }

  /// Get current season standings for a league
  Future<List<StandingsModel>> getCurrentSeasonStandings(int leagueId) async {
    final currentYear = DateTime.now().year;
    return getStandings(
      leagueId: leagueId,
      season: currentYear.toString(),
    );
  }

  /// Get team position in league table
  Future<int?> getTeamPosition({
    required int teamId,
    required int leagueId,
    required String season,
  }) async {
    try {
      final standings = await getStandings(
        leagueId: leagueId,
        season: season,
        teamId: teamId,
      );
      
      if (standings.isEmpty) return null;
      
      final leagueStandings = standings.first.league?.standings;
      if (leagueStandings == null || leagueStandings.isEmpty) return null;
      
      final tableStandings = leagueStandings.first;
      final teamStanding = tableStandings.firstWhere(
        (standing) => standing.team?.id == teamId,
        orElse: () => throw Exception('Team not found in standings'),
      );
      
      return teamStanding.rank;
    } catch (e) {
      throw Exception('Failed to get team position: $e');
    }
  }

  /// Get top teams from standings
  Future<List<dynamic>> getTopTeams({
    required int leagueId,
    required String season,
    int count = 10,
  }) async {
    try {
      final standings = await getStandings(
        leagueId: leagueId,
        season: season,
      );
      
      if (standings.isEmpty) return [];
      
      final leagueStandings = standings.first.league?.standings;
      if (leagueStandings == null || leagueStandings.isEmpty) return [];
      
      final tableStandings = leagueStandings.first;
      
      // Sort by rank and take top teams
      tableStandings.sort((a, b) => (a.rank ?? 0).compareTo(b.rank ?? 0));
      
      return tableStandings.take(count).toList();
    } catch (e) {
      throw Exception('Failed to get top teams: $e');
    }
  }

  /// Get bottom teams from standings (relegation zone)
  Future<List<dynamic>> getBottomTeams({
    required int leagueId,
    required String season,
    int count = 5,
  }) async {
    try {
      final standings = await getStandings(
        leagueId: leagueId,
        season: season,
      );
      
      if (standings.isEmpty) return [];
      
      final leagueStandings = standings.first.league?.standings;
      if (leagueStandings == null || leagueStandings.isEmpty) return [];
      
      final tableStandings = leagueStandings.first;
      
      // Sort by rank (descending) and take bottom teams
      tableStandings.sort((a, b) => (b.rank ?? 0).compareTo(a.rank ?? 0));
      
      return tableStandings.take(count).toList();
    } catch (e) {
      throw Exception('Failed to get bottom teams: $e');
    }
  }

  /// Get teams in European competition spots
  Future<Map<String, List<dynamic>>> getEuropeanQualificationSpots({
    required int leagueId,
    required String season,
  }) async {
    try {
      final standings = await getStandings(
        leagueId: leagueId,
        season: season,
      );
      
      if (standings.isEmpty) return {};
      
      final leagueStandings = standings.first.league?.standings;
      if (leagueStandings == null || leagueStandings.isEmpty) return {};
      
      final tableStandings = leagueStandings.first;
      tableStandings.sort((a, b) => (a.rank ?? 0).compareTo(b.rank ?? 0));
      
      final result = <String, List<dynamic>>{};
      
      // Champions League (typically top 4 for major leagues)
      result['Champions League'] = tableStandings
          .where((team) => (team.rank ?? 0) <= 4)
          .toList();
      
      // Europa League (typically 5th-6th place)
      result['Europa League'] = tableStandings
          .where((team) => (team.rank ?? 0) >= 5 && (team.rank ?? 0) <= 6)
          .toList();
      
      // Conference League (typically 7th place)
      result['Conference League'] = tableStandings
          .where((team) => (team.rank ?? 0) == 7)
          .toList();
      
      return result;
    } catch (e) {
      throw Exception('Failed to get European qualification spots: $e');
    }
  }

  /// Get relegation zone teams
  Future<List<dynamic>> getRelegationZoneTeams({
    required int leagueId,
    required String season,
  }) async {
    try {
      final standings = await getStandings(
        leagueId: leagueId,
        season: season,
      );
      
      if (standings.isEmpty) return [];
      
      final leagueStandings = standings.first.league?.standings;
      if (leagueStandings == null || leagueStandings.isEmpty) return [];
      
      final tableStandings = leagueStandings.first;
      final totalTeams = tableStandings.length;
      
      // Typically last 3 teams are relegated in major leagues
      final relegationSpots = 3;
      final relegationThreshold = totalTeams - relegationSpots + 1;
      
      return tableStandings
          .where((team) => (team.rank ?? 0) >= relegationThreshold)
          .toList();
    } catch (e) {
      throw Exception('Failed to get relegation zone teams: $e');
    }
  }

  /// Get team's form based on last 5 matches
  Future<String> getTeamForm({
    required int teamId,
    required int leagueId,
    required String season,
  }) async {
    try {
      final standings = await getStandings(
        leagueId: leagueId,
        season: season,
        teamId: teamId,
      );
      
      if (standings.isEmpty) return '';
      
      final leagueStandings = standings.first.league?.standings;
      if (leagueStandings == null || leagueStandings.isEmpty) return '';
      
      final tableStandings = leagueStandings.first;
      final teamStanding = tableStandings.firstWhere(
        (standing) => standing.team?.id == teamId,
        orElse: () => throw Exception('Team not found in standings'),
      );
      
      return teamStanding.form ?? '';
    } catch (e) {
      throw Exception('Failed to get team form: $e');
    }
  }

  /// Compare two teams in the same league
  Future<Map<String, dynamic>> compareTeams({
    required int team1Id,
    required int team2Id,
    required int leagueId,
    required String season,
  }) async {
    try {
      final standings = await getStandings(
        leagueId: leagueId,
        season: season,
      );
      
      if (standings.isEmpty) return {};
      
      final leagueStandings = standings.first.league?.standings;
      if (leagueStandings == null || leagueStandings.isEmpty) return {};
      
      final tableStandings = leagueStandings.first;
      
      final team1Standing = tableStandings.firstWhere(
        (standing) => standing.team?.id == team1Id,
        orElse: () => throw Exception('Team 1 not found in standings'),
      );
      
      final team2Standing = tableStandings.firstWhere(
        (standing) => standing.team?.id == team2Id,
        orElse: () => throw Exception('Team 2 not found in standings'),
      );
      
      return {
        'team1': {
          'name': team1Standing.team?.name,
          'position': team1Standing.rank,
          'points': team1Standing.points,
          'goalsFor': team1Standing.all?.goals?.goalsFor,
          'goalsAgainst': team1Standing.all?.goals?.against,
          'goalDifference': team1Standing.goalsDiff,
          'form': team1Standing.form,
        },
        'team2': {
          'name': team2Standing.team?.name,
          'position': team2Standing.rank,
          'points': team2Standing.points,
          'goalsFor': team2Standing.all?.goals?.goalsFor,
          'goalsAgainst': team2Standing.all?.goals?.against,
          'goalDifference': team2Standing.goalsDiff,
          'form': team2Standing.form,
        },
        'comparison': {
          'positionDifference': (team1Standing.rank ?? 0) - (team2Standing.rank ?? 0),
          'pointsDifference': (team1Standing.points ?? 0) - (team2Standing.points ?? 0),
          'goalDifference': (team1Standing.goalsDiff ?? 0) - (team2Standing.goalsDiff ?? 0),
        }
      };
    } catch (e) {
      throw Exception('Failed to compare teams: $e');
    }
  }

  /// Get standings for multiple leagues
  Future<Map<int, List<StandingsModel>>> getMultipleLeagueStandings({
    required List<int> leagueIds,
    required String season,
  }) async {
    final result = <int, List<StandingsModel>>{};
    
    for (final leagueId in leagueIds) {
      try {
        final standings = await getStandings(
          leagueId: leagueId,
          season: season,
        );
        result[leagueId] = standings;
      } catch (e) {
        // Continue with other leagues if one fails
        result[leagueId] = [];
      }
    }
    
    return result;
  }
}

// Provider for the standings API service
final standingsApiServiceProvider = Provider<StandingsApiService>((ref) {
  final apiClient = ref.watch(footballApiClientProvider);
  return StandingsApiService(apiClient);
});