import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'leagues_api_service.dart';
import 'teams_api_service.dart';
import 'fixtures_api_service.dart';
import 'standings_api_service.dart';

/// Comprehensive football data service that aggregates all API services
class FootballDataService {
  final LeaguesApiService _leaguesService;
  final TeamsApiService _teamsService;
  final FixturesApiService _fixturesService;
  final StandingsApiService _standingsService;

  FootballDataService(
    this._leaguesService,
    this._teamsService,
    this._fixturesService,
    this._standingsService,
  );

  // Leagues
  LeaguesApiService get leagues => _leaguesService;

  // Teams
  TeamsApiService get teams => _teamsService;

  // Fixtures
  FixturesApiService get fixtures => _fixturesService;

  // Standings
  StandingsApiService get standings => _standingsService;

  /// Get comprehensive data for a league (standings, fixtures, teams)
  Future<Map<String, dynamic>> getLeagueOverview({
    required int leagueId,
    required String season,
  }) async {
    try {
      final results = await Future.wait([
        _standingsService.getStandings(leagueId: leagueId, season: season),
        _teamsService.getTeamsByLeague(leagueId: leagueId, season: season),
        _fixturesService.getCurrentMatchdayFixtures(leagueId),
        _leaguesService.getLeagueById(leagueId),
      ]);

      return {
        'standings': results[0],
        'teams': results[1],
        'currentFixtures': results[2],
        'league': results[3],
      };
    } catch (e) {
      throw Exception('Failed to get league overview: $e');
    }
  }

  /// Get comprehensive data for a team
  Future<Map<String, dynamic>> getTeamOverview({
    required int teamId,
    required int leagueId,
    required String season,
  }) async {
    try {
      final results = await Future.wait([
        _teamsService.getTeamById(teamId),
        _teamsService.getTeamStatistics(
          teamId: teamId,
          leagueId: leagueId,
          season: season,
        ),
        _fixturesService.getTeamLastFixtures(teamId: teamId, leagueId: leagueId),
        _fixturesService.getTeamNextFixtures(teamId: teamId, leagueId: leagueId),
        _standingsService.getTeamPosition(
          teamId: teamId,
          leagueId: leagueId,
          season: season,
        ),
      ]);

      return {
        'team': results[0],
        'statistics': results[1],
        'lastFixtures': results[2],
        'nextFixtures': results[3],
        'position': results[4],
      };
    } catch (e) {
      throw Exception('Failed to get team overview: $e');
    }
  }

  /// Get live scores across multiple leagues
  Future<Map<String, dynamic>> getLiveScores({
    List<int>? leagueIds,
  }) async {
    try {
      final liveFixtures = await _fixturesService.getLiveFixtures();
      
      if (leagueIds != null) {
        final filteredFixtures = liveFixtures
            .where((fixture) => leagueIds.contains(fixture.league?.id))
            .toList();
        
        return {
          'fixtures': filteredFixtures,
          'count': filteredFixtures.length,
          'lastUpdated': DateTime.now().toIso8601String(),
        };
      }

      return {
        'fixtures': liveFixtures,
        'count': liveFixtures.length,
        'lastUpdated': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      throw Exception('Failed to get live scores: $e');
    }
  }

  /// Get today's fixtures across multiple leagues
  Future<Map<String, dynamic>> getTodaysFixtures({
    List<int>? leagueIds,
  }) async {
    try {
      if (leagueIds == null) {
        final todayFixtures = await _fixturesService.getTodayFixtures();
        return {
          'fixtures': todayFixtures,
          'count': todayFixtures.length,
          'date': DateTime.now().toIso8601String().split('T').first,
        };
      }

      final allFixtures = <dynamic>[];
      for (final leagueId in leagueIds) {
        final fixtures = await _fixturesService.getTodayFixtures(leagueId: leagueId);
        allFixtures.addAll(fixtures);
      }

      return {
        'fixtures': allFixtures,
        'count': allFixtures.length,
        'date': DateTime.now().toIso8601String().split('T').first,
      };
    } catch (e) {
      throw Exception('Failed to get today\'s fixtures: $e');
    }
  }

  /// Get popular leagues with their current standings
  Future<Map<String, dynamic>> getPopularLeaguesOverview() async {
    try {
      final popularLeagues = await _leaguesService.getPopularLeagues();
      final currentSeason = DateTime.now().year.toString();
      
      final leagueData = <Map<String, dynamic>>[];
      
      for (final league in popularLeagues) {
        try {
          final standings = await _standingsService.getStandings(
            leagueId: league.id,
            season: currentSeason,
          );
          
          final topTeams = await _standingsService.getTopTeams(
            leagueId: league.id,
            season: currentSeason,
            count: 5,
          );

          leagueData.add({
            'league': league,
            'standings': standings,
            'topTeams': topTeams,
          });
        } catch (e) {
          // Continue with other leagues if one fails
          continue;
        }
      }

      return {
        'leagues': leagueData,
        'lastUpdated': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      throw Exception('Failed to get popular leagues overview: $e');
    }
  }

  /// Search across all data types
  Future<Map<String, dynamic>> globalSearch(String query) async {
    try {
      final results = await Future.wait([
        _leaguesService.searchLeagues(query),
        _teamsService.searchTeams(query),
      ]);

      return {
        'leagues': results[0],
        'teams': results[1],
        'query': query,
        'totalResults': (results[0] as List).length + (results[1] as List).length,
      };
    } catch (e) {
      throw Exception('Failed to perform global search: $e');
    }
  }

  /// Get match details with all related information
  Future<Map<String, dynamic>> getMatchDetails(int fixtureId) async {
    try {
      final results = await Future.wait([
        _fixturesService.getFixtureById(fixtureId),
        _fixturesService.getMatchStatistics(fixtureId),
        _fixturesService.getMatchEvents(fixtureId),
        _fixturesService.getMatchLineups(fixtureId),
        _fixturesService.getMatchPlayerStatistics(fixtureId),
      ]);

      return {
        'fixture': results[0],
        'statistics': results[1],
        'events': results[2],
        'lineups': results[3],
        'playerStats': results[4],
      };
    } catch (e) {
      throw Exception('Failed to get match details: $e');
    }
  }
}

// Provider for the comprehensive football data service
final footballDataServiceProvider = Provider<FootballDataService>((ref) {
  return FootballDataService(
    ref.watch(leaguesApiServiceProvider),
    ref.watch(teamsApiServiceProvider),
    ref.watch(fixturesApiServiceProvider),
    ref.watch(standingsApiServiceProvider),
  );
});