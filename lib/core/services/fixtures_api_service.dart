import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../network/football_api_client.dart';
import '../../shared/data/models/fixture_model.dart';

class FixturesApiService {
  final FootballApiClient _apiClient;

  FixturesApiService(this._apiClient);

  /// Get fixtures by various filters
  Future<List<FixtureModel>> getFixtures({
    int? id,
    int? leagueId,
    String? season,
    int? teamId,
    String? date,
    String? from,
    String? to,
    int? round,
    String? status,
    int? venue,
    String? timezone,
    int? last,
    int? next,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      
      if (id != null) queryParams['id'] = id;
      if (leagueId != null) queryParams['league'] = leagueId;
      if (season != null) queryParams['season'] = season;
      if (teamId != null) queryParams['team'] = teamId;
      if (date != null) queryParams['date'] = date;
      if (from != null) queryParams['from'] = from;
      if (to != null) queryParams['to'] = to;
      if (round != null) queryParams['round'] = round;
      if (status != null) queryParams['status'] = status;
      if (venue != null) queryParams['venue'] = venue;
      if (timezone != null) queryParams['timezone'] = timezone;
      if (last != null) queryParams['last'] = last;
      if (next != null) queryParams['next'] = next;

      final response = await _apiClient.get('/fixtures', queryParameters: queryParams);
      
      final fixtures = <FixtureModel>[];
      final responseData = response['response'] as List<dynamic>;
      
      for (final fixtureData in responseData) {
        fixtures.add(FixtureModel.fromJson(fixtureData));
      }
      
      return fixtures;
    } catch (e) {
      throw Exception('Failed to fetch fixtures: $e');
    }
  }

  /// Get live fixtures
  Future<List<FixtureModel>> getLiveFixtures() async {
    return getFixtures(status: 'live');
  }

  /// Get fixtures for today
  Future<List<FixtureModel>> getTodayFixtures({int? leagueId}) async {
    final today = DateTime.now();
    final dateString = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    
    return getFixtures(
      date: dateString,
      leagueId: leagueId,
    );
  }

  /// Get fixtures for a specific date
  Future<List<FixtureModel>> getFixturesByDate(DateTime date, {int? leagueId}) async {
    final dateString = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    
    return getFixtures(
      date: dateString,
      leagueId: leagueId,
    );
  }

  /// Get fixtures for a date range
  Future<List<FixtureModel>> getFixturesByDateRange({
    required DateTime from,
    required DateTime to,
    int? leagueId,
    int? teamId,
  }) async {
    final fromString = '${from.year}-${from.month.toString().padLeft(2, '0')}-${from.day.toString().padLeft(2, '0')}';
    final toString = '${to.year}-${to.month.toString().padLeft(2, '0')}-${to.day.toString().padLeft(2, '0')}';
    
    return getFixtures(
      from: fromString,
      to: toString,
      leagueId: leagueId,
      teamId: teamId,
    );
  }

  /// Get fixture by ID
  Future<FixtureModel?> getFixtureById(int fixtureId) async {
    try {
      final fixtures = await getFixtures(id: fixtureId);
      return fixtures.isNotEmpty ? fixtures.first : null;
    } catch (e) {
      throw Exception('Failed to fetch fixture by ID: $e');
    }
  }

  /// Get team's last fixtures
  Future<List<FixtureModel>> getTeamLastFixtures({
    required int teamId,
    int? leagueId,
    int count = 5,
  }) async {
    return getFixtures(
      teamId: teamId,
      leagueId: leagueId,
      last: count,
    );
  }

  /// Get team's next fixtures
  Future<List<FixtureModel>> getTeamNextFixtures({
    required int teamId,
    int? leagueId,
    int count = 5,
  }) async {
    return getFixtures(
      teamId: teamId,
      leagueId: leagueId,
      next: count,
    );
  }

  /// Get fixtures by league and season
  Future<List<FixtureModel>> getLeagueFixtures({
    required int leagueId,
    required String season,
    String? status,
    int? round,
  }) async {
    return getFixtures(
      leagueId: leagueId,
      season: season,
      status: status,
      round: round,
    );
  }

  /// Get finished fixtures
  Future<List<FixtureModel>> getFinishedFixtures({
    int? leagueId,
    int? teamId,
    String? season,
    DateTime? from,
    DateTime? to,
  }) async {
    String? fromString;
    String? toString;
    
    if (from != null) {
      fromString = '${from.year}-${from.month.toString().padLeft(2, '0')}-${from.day.toString().padLeft(2, '0')}';
    }
    
    if (to != null) {
      toString = '${to.year}-${to.month.toString().padLeft(2, '0')}-${to.day.toString().padLeft(2, '0')}';
    }
    
    return getFixtures(
      leagueId: leagueId,
      teamId: teamId,
      season: season,
      from: fromString,
      to: toString,
      status: 'FT', // Full Time
    );
  }

  /// Get upcoming fixtures
  Future<List<FixtureModel>> getUpcomingFixtures({
    int? leagueId,
    int? teamId,
    DateTime? from,
    DateTime? to,
    int? next,
  }) async {
    String? fromString;
    String? toString;
    
    if (from != null) {
      fromString = '${from.year}-${from.month.toString().padLeft(2, '0')}-${from.day.toString().padLeft(2, '0')}';
    }
    
    if (to != null) {
      toString = '${to.year}-${to.month.toString().padLeft(2, '0')}-${to.day.toString().padLeft(2, '0')}';
    }
    
    return getFixtures(
      leagueId: leagueId,
      teamId: teamId,
      from: fromString,
      to: toString,
      status: 'NS', // Not Started
      next: next,
    );
  }

  /// Get match statistics
  Future<Map<String, dynamic>> getMatchStatistics(int fixtureId) async {
    try {
      final response = await _apiClient.get(
        '/fixtures/statistics',
        queryParameters: {'fixture': fixtureId},
      );
      
      return response['response'] as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Failed to fetch match statistics: $e');
    }
  }

  /// Get match events (goals, cards, substitutions)
  Future<List<Map<String, dynamic>>> getMatchEvents(int fixtureId) async {
    try {
      final response = await _apiClient.get(
        '/fixtures/events',
        queryParameters: {'fixture': fixtureId},
      );
      
      final events = response['response'] as List<dynamic>;
      return events.cast<Map<String, dynamic>>();
    } catch (e) {
      throw Exception('Failed to fetch match events: $e');
    }
  }

  /// Get match lineups
  Future<Map<String, dynamic>> getMatchLineups(int fixtureId) async {
    try {
      final response = await _apiClient.get(
        '/fixtures/lineups',
        queryParameters: {'fixture': fixtureId},
      );
      
      return response['response'] as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Failed to fetch match lineups: $e');
    }
  }

  /// Get player statistics for a match
  Future<List<Map<String, dynamic>>> getMatchPlayerStatistics(int fixtureId) async {
    try {
      final response = await _apiClient.get(
        '/fixtures/players',
        queryParameters: {'fixture': fixtureId},
      );
      
      final players = response['response'] as List<dynamic>;
      return players.cast<Map<String, dynamic>>();
    } catch (e) {
      throw Exception('Failed to fetch match player statistics: $e');
    }
  }

  /// Get head to head fixtures between two teams
  Future<List<FixtureModel>> getHeadToHeadFixtures({
    required int team1Id,
    required int team2Id,
    int? last,
    String? date,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'h2h': '$team1Id-$team2Id',
      };
      
      if (last != null) queryParams['last'] = last;
      if (date != null) queryParams['date'] = date;

      final response = await _apiClient.get('/fixtures/headtohead', queryParameters: queryParams);
      
      final fixtures = <FixtureModel>[];
      final responseData = response['response'] as List<dynamic>;
      
      for (final fixtureData in responseData) {
        fixtures.add(FixtureModel.fromJson(fixtureData));
      }
      
      return fixtures;
    } catch (e) {
      throw Exception('Failed to fetch head to head fixtures: $e');
    }
  }

  /// Get fixtures by round
  Future<List<FixtureModel>> getFixturesByRound({
    required int leagueId,
    required String season,
    required String round,
  }) async {
    return getFixtures(
      leagueId: leagueId,
      season: season,
      round: int.tryParse(round.replaceAll(RegExp(r'[^\d]'), '')),
    );
  }

  /// Get current matchday fixtures
  Future<List<FixtureModel>> getCurrentMatchdayFixtures(int leagueId) async {
    final now = DateTime.now();
    final from = now.subtract(const Duration(days: 3));
    final to = now.add(const Duration(days: 3));
    
    return getFixturesByDateRange(
      from: from,
      to: to,
      leagueId: leagueId,
    );
  }
}

// Provider for the fixtures API service
final fixturesApiServiceProvider = Provider<FixturesApiService>((ref) {
  final apiClient = ref.watch(footballApiClientProvider);
  return FixturesApiService(apiClient);
});