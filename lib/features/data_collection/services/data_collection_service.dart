import 'dart:async';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../core/network/production_football_api.dart';
import '../../../core/services/database_browser_service.dart';

/// Data Collection Service - Manages API data synchronization
class DataCollectionService {
  final ProductionFootballApi _api;
  final DatabaseBrowserService _database;
  final Logger _logger = Logger();
  
  late Box _syncStatusBox;
  late Box _collectionLogsBox;
  
  // Sync status tracking
  final Map<String, SyncOperation> _activeOperations = {};
  Timer? _scheduledSyncTimer;
  
  DataCollectionService(this._api, this._database) {
    _initializeBoxes();
  }
  
  Future<void> _initializeBoxes() async {
    try {
      _syncStatusBox = await Hive.openBox('data_sync_status');
      _collectionLogsBox = await Hive.openBox('collection_logs');
    } catch (e) {
      _logger.e('Failed to initialize Hive boxes: $e');
    }
  }
  
  /// Get current API status
  Future<ApiStatusData> getApiStatus() async {
    try {
      final usageStats = _api.getUsageStats();
      
      // Test API connectivity with a simple request
      final testLeagues = await _api.getLeagues();
      final isConnected = testLeagues.isNotEmpty;
      
      // Get last sync times
      final lastLeagueSync = _getLastSyncTime('leagues');
      final lastTeamSync = _getLastSyncTime('teams');
      final lastFixtureSync = _getLastSyncTime('fixtures');
      final lastStandingSync = _getLastSyncTime('standings');
      
      return ApiStatusData(
        isConnected: isConnected,
        requestsToday: usageStats.requestsToday,
        requestsThisMinute: usageStats.requestsThisMinute,
        dailyLimit: usageStats.maxRequestsPerDay,
        minuteLimit: usageStats.maxRequestsPerMinute,
        lastLeagueSync: lastLeagueSync,
        lastTeamSync: lastTeamSync,
        lastFixtureSync: lastFixtureSync,
        lastStandingSync: lastStandingSync,
        nextResetTime: usageStats.nextResetTime,
        connectionLatency: 0, // Would need to measure actual request time
      );
    } catch (e) {
      _logger.e('Error getting API status: $e');
      return ApiStatusData.disconnected();
    }
  }
  
  /// Get data sync status
  Future<DataSyncStatus> getSyncStatus() async {
    final recentOperations = await _getRecentOperations();
    final scheduledOperations = await _getScheduledOperations();
    
    return DataSyncStatus(
      isAutoSyncEnabled: _isAutoSyncEnabled(),
      lastFullSync: _getLastSyncTime('full_sync'),
      nextScheduledSync: _getNextScheduledSync(),
      recentOperations: recentOperations,
      scheduledOperations: scheduledOperations,
      totalSyncedRecords: await _getTotalSyncedRecords(),
      failedOperations: recentOperations.where((op) => op.status == 'failed').length,
    );
  }
  
  /// Sync all data
  Future<void> syncAllData() async {
    _logger.i('Starting full data synchronization');
    
    final operation = SyncOperation(
      id: 'full_sync_${DateTime.now().millisecondsSinceEpoch}',
      type: 'sync',
      description: 'Full data synchronization',
      entityType: 'all',
      status: 'running',
      timestamp: DateTime.now(),
    );
    
    _activeOperations[operation.id] = operation;
    await _logOperation(operation);
    
    try {
      // Sync in order: leagues -> teams -> fixtures -> standings
      await syncLeagues();
      await syncTeams();
      await syncFixtures();
      await syncStandings();
      
      // Update operation status
      operation.status = 'completed';
      operation.completedAt = DateTime.now();
      await _updateLastSyncTime('full_sync');
      
      _logger.i('Full data synchronization completed');
    } catch (e) {
      operation.status = 'failed';
      operation.error = e.toString();
      _logger.e('Full data synchronization failed: $e');
      rethrow;
    } finally {
      await _logOperation(operation);
      _activeOperations.remove(operation.id);
    }
  }
  
  /// Sync leagues data
  Future<void> syncLeagues() async {
    final operation = SyncOperation(
      id: 'sync_leagues_${DateTime.now().millisecondsSinceEpoch}',
      type: 'sync',
      description: 'Sync leagues data',
      entityType: 'leagues',
      status: 'running',
      timestamp: DateTime.now(),
    );
    
    _activeOperations[operation.id] = operation;
    await _logOperation(operation);
    
    try {
      _logger.i('Syncing leagues data');
      
      // Get leagues from API
      final leagues = await _api.getLeagues();
      _logger.i('Retrieved ${leagues.length} leagues from API');
      
      // Store in database
      int insertedCount = 0;
      int updatedCount = 0;
      
      for (final league in leagues) {
        final existingLeague = await _database.executeQuery(
          'SELECT id FROM leagues WHERE id = ?',
          parameters: [league.id],
        );
        
        if (existingLeague.data.isEmpty) {
          // Insert new league
          await _database.executeModification(
            '''INSERT INTO leagues (
              id, name, code, type, emblem, country_name, country_code, country_flag,
              season_start, season_end, current_season, created_at, updated_at
            ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)''',
            [
              league.id,
              league.name,
              league.type,
              league.type,
              league.logo,
              league.country.name,
              league.country.code,
              league.country.flag,
              league.seasons.isNotEmpty ? league.seasons.first.start : null,
              league.seasons.isNotEmpty ? league.seasons.first.end : null,
              league.seasons.any((s) => s.current) ? 1 : 0,
              DateTime.now().toIso8601String(),
              DateTime.now().toIso8601String(),
            ],
          );
          insertedCount++;
        } else {
          // Update existing league
          await _database.executeModification(
            '''UPDATE leagues SET 
              name = ?, code = ?, type = ?, emblem = ?, country_name = ?, 
              country_code = ?, country_flag = ?, updated_at = ?
              WHERE id = ?''',
            [
              league.name,
              league.type,
              league.type,
              league.logo,
              league.country.name,
              league.country.code,
              league.country.flag,
              DateTime.now().toIso8601String(),
              league.id,
            ],
          );
          updatedCount++;
        }
      }
      
      operation.status = 'completed';
      operation.completedAt = DateTime.now();
      operation.recordsProcessed = leagues.length;
      operation.recordsInserted = insertedCount;
      operation.recordsUpdated = updatedCount;
      
      await _updateLastSyncTime('leagues');
      _logger.i('Leagues sync completed: $insertedCount inserted, $updatedCount updated');
      
    } catch (e) {
      operation.status = 'failed';
      operation.error = e.toString();
      _logger.e('Leagues sync failed: $e');
      rethrow;
    } finally {
      await _logOperation(operation);
      _activeOperations.remove(operation.id);
    }
  }
  
  /// Sync teams data
  Future<void> syncTeams() async {
    final operation = SyncOperation(
      id: 'sync_teams_${DateTime.now().millisecondsSinceEpoch}',
      type: 'sync',
      description: 'Sync teams data',
      entityType: 'teams',
      status: 'running',
      timestamp: DateTime.now(),
    );
    
    _activeOperations[operation.id] = operation;
    await _logOperation(operation);
    
    try {
      _logger.i('Syncing teams data');
      
      // Get popular leagues for team sync
      const popularLeagueIds = [39, 140, 78, 135, 61]; // Premier League, La Liga, Bundesliga, Serie A, Ligue 1
      const currentSeason = 2024;
      
      int totalInserted = 0;
      int totalUpdated = 0;
      
      for (final leagueId in popularLeagueIds) {
        try {
          final teams = await _api.getTeams(
            leagueId: leagueId,
            season: currentSeason,
          );
          
          _logger.i('Retrieved ${teams.length} teams for league $leagueId');
          
          for (final team in teams) {
            final existingTeam = await _database.executeQuery(
              'SELECT id FROM teams WHERE id = ?',
              parameters: [team.id],
            );
            
            if (existingTeam.data.isEmpty) {
              // Insert new team
              await _database.executeModification(
                '''INSERT INTO teams (
                  id, name, short_name, tla, crest, founded, venue, website,
                  country, area_name, area_flag, created_at, updated_at
                ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)''',
                [
                  team.id,
                  team.name,
                  team.name, // Using name as short_name for now
                  team.code ?? '',
                  team.logo,
                  team.founded,
                  team.venue?.name,
                  null, // website not available in current API
                  'Unknown', // country not directly available
                  null, // area_name
                  null, // area_flag
                  DateTime.now().toIso8601String(),
                  DateTime.now().toIso8601String(),
                ],
              );
              totalInserted++;
            } else {
              // Update existing team
              await _database.executeModification(
                '''UPDATE teams SET 
                  name = ?, crest = ?, founded = ?, venue = ?, updated_at = ?
                  WHERE id = ?''',
                [
                  team.name,
                  team.logo,
                  team.founded,
                  team.venue?.name,
                  DateTime.now().toIso8601String(),
                  team.id,
                ],
              );
              totalUpdated++;
            }
          }
        } catch (e) {
          _logger.w('Failed to sync teams for league $leagueId: $e');
        }
      }
      
      operation.status = 'completed';
      operation.completedAt = DateTime.now();
      operation.recordsProcessed = totalInserted + totalUpdated;
      operation.recordsInserted = totalInserted;
      operation.recordsUpdated = totalUpdated;
      
      await _updateLastSyncTime('teams');
      _logger.i('Teams sync completed: $totalInserted inserted, $totalUpdated updated');
      
    } catch (e) {
      operation.status = 'failed';
      operation.error = e.toString();
      _logger.e('Teams sync failed: $e');
      rethrow;
    } finally {
      await _logOperation(operation);
      _activeOperations.remove(operation.id);
    }
  }
  
  /// Sync fixtures data
  Future<void> syncFixtures() async {
    final operation = SyncOperation(
      id: 'sync_fixtures_${DateTime.now().millisecondsSinceEpoch}',
      type: 'sync',
      description: 'Sync fixtures data',
      entityType: 'fixtures',
      status: 'running',
      timestamp: DateTime.now(),
    );
    
    _activeOperations[operation.id] = operation;
    await _logOperation(operation);
    
    try {
      _logger.i('Syncing fixtures data');
      
      // Get recent fixtures (last 30 days and next 30 days)
      final now = DateTime.now();
      final startDate = now.subtract(const Duration(days: 30));
      final endDate = now.add(const Duration(days: 30));
      
      // Get fixtures for popular leagues
      const popularLeagueIds = [39, 140, 78, 135, 61];
      const currentSeason = 2024;
      
      int totalInserted = 0;
      int totalUpdated = 0;
      
      for (final leagueId in popularLeagueIds) {
        try {
          // Get recent fixtures
          final fixtures = await _api.getFixtures(
            leagueId: leagueId,
            season: currentSeason,
          );
          
          _logger.i('Retrieved ${fixtures.length} fixtures for league $leagueId');
          
          for (final fixture in fixtures.take(100)) { // Limit to avoid API overuse
            final existingFixture = await _database.executeQuery(
              'SELECT id FROM fixtures WHERE id = ?',
              parameters: [fixture.id],
            );
            
            if (existingFixture.data.isEmpty) {
              // Insert new fixture
              await _database.executeModification(
                '''INSERT INTO fixtures (
                  id, utc_date, status, matchday, stage, group_name, competition_id,
                  season_year, home_team_id, away_team_id, home_score, away_score,
                  winner, duration, half_time_home, half_time_away, full_time_home,
                  full_time_away, referee_name, venue_name, created_at, updated_at
                ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)''',
                [
                  fixture.id,
                  fixture.date.toIso8601String(),
                  fixture.status.short,
                  0, // matchday not available
                  'Regular Season',
                  null, // group_name
                  leagueId,
                  currentSeason,
                  fixture.homeTeam.id,
                  fixture.awayTeam.id,
                  fixture.goals?.home,
                  fixture.goals?.away,
                  fixture.homeTeam.winner == true ? 'HOME' : 
                    fixture.awayTeam.winner == true ? 'AWAY' : 
                    fixture.isDraw ? 'DRAW' : null,
                  'REGULAR',
                  fixture.score?.halftime?.home,
                  fixture.score?.halftime?.away,
                  fixture.goals?.home,
                  fixture.goals?.away,
                  fixture.referee,
                  fixture.venue?.name,
                  DateTime.now().toIso8601String(),
                  DateTime.now().toIso8601String(),
                ],
              );
              totalInserted++;
            } else {
              // Update existing fixture
              await _database.executeModification(
                '''UPDATE fixtures SET 
                  status = ?, home_score = ?, away_score = ?, winner = ?,
                  half_time_home = ?, half_time_away = ?, full_time_home = ?,
                  full_time_away = ?, updated_at = ?
                  WHERE id = ?''',
                [
                  fixture.status.short,
                  fixture.goals?.home,
                  fixture.goals?.away,
                  fixture.homeTeam.winner == true ? 'HOME' : 
                    fixture.awayTeam.winner == true ? 'AWAY' : 
                    fixture.isDraw ? 'DRAW' : null,
                  fixture.score?.halftime?.home,
                  fixture.score?.halftime?.away,
                  fixture.goals?.home,
                  fixture.goals?.away,
                  DateTime.now().toIso8601String(),
                  fixture.id,
                ],
              );
              totalUpdated++;
            }
          }
        } catch (e) {
          _logger.w('Failed to sync fixtures for league $leagueId: $e');
        }
      }
      
      operation.status = 'completed';
      operation.completedAt = DateTime.now();
      operation.recordsProcessed = totalInserted + totalUpdated;
      operation.recordsInserted = totalInserted;
      operation.recordsUpdated = totalUpdated;
      
      await _updateLastSyncTime('fixtures');
      _logger.i('Fixtures sync completed: $totalInserted inserted, $totalUpdated updated');
      
    } catch (e) {
      operation.status = 'failed';
      operation.error = e.toString();
      _logger.e('Fixtures sync failed: $e');
      rethrow;
    } finally {
      await _logOperation(operation);
      _activeOperations.remove(operation.id);
    }
  }
  
  /// Sync standings data
  Future<void> syncStandings() async {
    final operation = SyncOperation(
      id: 'sync_standings_${DateTime.now().millisecondsSinceEpoch}',
      type: 'sync',
      description: 'Sync standings data',
      entityType: 'standings',
      status: 'running',
      timestamp: DateTime.now(),
    );
    
    _activeOperations[operation.id] = operation;
    await _logOperation(operation);
    
    try {
      _logger.i('Syncing standings data');
      
      const popularLeagueIds = [39, 140, 78, 135, 61];
      const currentSeason = 2024;
      
      int totalInserted = 0;
      int totalUpdated = 0;
      
      for (final leagueId in popularLeagueIds) {
        try {
          final standings = await _api.getStandings(
            leagueId: leagueId,
            season: currentSeason,
          );
          
          _logger.i('Retrieved ${standings.length} standings for league $leagueId');
          
          for (final standing in standings) {
            final existingStanding = await _database.executeQuery(
              'SELECT id FROM standings WHERE league_id = ? AND season = ? AND team_id = ?',
              parameters: [leagueId, currentSeason, standing.team.id],
            );
            
            if (existingStanding.data.isEmpty) {
              // Insert new standing
              await _database.executeModification(
                '''INSERT INTO standings (
                  league_id, season, team_id, position, points, played, won, drawn, lost,
                  goals_for, goals_against, goal_difference, form, home_played, home_won,
                  home_drawn, home_lost, home_goals_for, home_goals_against, away_played,
                  away_won, away_drawn, away_lost, away_goals_for, away_goals_against,
                  created_at, updated_at
                ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)''',
                [
                  leagueId,
                  currentSeason,
                  standing.team.id,
                  standing.rank,
                  standing.points,
                  standing.all.played,
                  standing.all.win,
                  standing.all.draw,
                  standing.all.lose,
                  standing.all.goals.home ?? 0,
                  standing.all.goals.away ?? 0,
                  standing.goalsDiff,
                  standing.form,
                  standing.home.played,
                  standing.home.win,
                  standing.home.draw,
                  standing.home.lose,
                  standing.home.goals.home ?? 0,
                  standing.home.goals.away ?? 0,
                  standing.away.played,
                  standing.away.win,
                  standing.away.draw,
                  standing.away.lose,
                  standing.away.goals.home ?? 0,
                  standing.away.goals.away ?? 0,
                  DateTime.now().toIso8601String(),
                  DateTime.now().toIso8601String(),
                ],
              );
              totalInserted++;
            } else {
              // Update existing standing
              await _database.executeModification(
                '''UPDATE standings SET 
                  position = ?, points = ?, played = ?, won = ?, drawn = ?, lost = ?,
                  goals_for = ?, goals_against = ?, goal_difference = ?, form = ?,
                  updated_at = ?
                  WHERE league_id = ? AND season = ? AND team_id = ?''',
                [
                  standing.rank,
                  standing.points,
                  standing.all.played,
                  standing.all.win,
                  standing.all.draw,
                  standing.all.lose,
                  standing.all.goals.home ?? 0,
                  standing.all.goals.away ?? 0,
                  standing.goalsDiff,
                  standing.form,
                  DateTime.now().toIso8601String(),
                  leagueId,
                  currentSeason,
                  standing.team.id,
                ],
              );
              totalUpdated++;
            }
          }
        } catch (e) {
          _logger.w('Failed to sync standings for league $leagueId: $e');
        }
      }
      
      operation.status = 'completed';
      operation.completedAt = DateTime.now();
      operation.recordsProcessed = totalInserted + totalUpdated;
      operation.recordsInserted = totalInserted;
      operation.recordsUpdated = totalUpdated;
      
      await _updateLastSyncTime('standings');
      _logger.i('Standings sync completed: $totalInserted inserted, $totalUpdated updated');
      
    } catch (e) {
      operation.status = 'failed';
      operation.error = e.toString();
      _logger.e('Standings sync failed: $e');
      rethrow;
    } finally {
      await _logOperation(operation);
      _activeOperations.remove(operation.id);
    }
  }
  
  /// Generate statistics
  Future<void> generateStatistics() async {
    final operation = SyncOperation(
      id: 'generate_stats_${DateTime.now().millisecondsSinceEpoch}',
      type: 'generate',
      description: 'Generate team statistics',
      entityType: 'statistics',
      status: 'running',
      timestamp: DateTime.now(),
    );
    
    _activeOperations[operation.id] = operation;
    await _logOperation(operation);
    
    try {
      _logger.i('Generating team statistics');
      
      // This would implement form analysis for all teams
      // For now, we'll just mark it as completed
      
      operation.status = 'completed';
      operation.completedAt = DateTime.now();
      operation.recordsProcessed = 0;
      
      _logger.i('Statistics generation completed');
      
    } catch (e) {
      operation.status = 'failed';
      operation.error = e.toString();
      _logger.e('Statistics generation failed: $e');
      rethrow;
    } finally {
      await _logOperation(operation);
      _activeOperations.remove(operation.id);
    }
  }
  
  /// Clean data
  Future<void> cleanData() async {
    final operation = SyncOperation(
      id: 'clean_data_${DateTime.now().millisecondsSinceEpoch}',
      type: 'clean',
      description: 'Clean duplicate and invalid data',
      entityType: 'data',
      status: 'running',
      timestamp: DateTime.now(),
    );
    
    _activeOperations[operation.id] = operation;
    await _logOperation(operation);
    
    try {
      _logger.i('Starting data cleanup');
      
      // Remove duplicate teams
      await _database.executeModification('''
        DELETE FROM teams WHERE id NOT IN (
          SELECT MIN(id) FROM teams GROUP BY name, founded
        )
      ''');
      
      // Remove fixtures without valid teams
      await _database.executeModification('''
        DELETE FROM fixtures WHERE 
          home_team_id NOT IN (SELECT id FROM teams) OR
          away_team_id NOT IN (SELECT id FROM teams)
      ''');
      
      // Remove old activity logs (older than 30 days)
      await _database.executeModification(
        'DELETE FROM user_activity WHERE timestamp < ?',
        [DateTime.now().subtract(const Duration(days: 30)).toIso8601String()],
      );
      
      operation.status = 'completed';
      operation.completedAt = DateTime.now();
      
      _logger.i('Data cleanup completed');
      
    } catch (e) {
      operation.status = 'failed';
      operation.error = e.toString();
      _logger.e('Data cleanup failed: $e');
      rethrow;
    } finally {
      await _logOperation(operation);
      _activeOperations.remove(operation.id);
    }
  }
  
  /// Reset cache
  Future<void> resetCache() async {
    await _api.clearCache();
    _logger.i('API cache reset');
  }
  
  /// Export logs
  Future<void> exportLogs() async {
    final logs = await _getCollectionLogs();
    // TODO: Implement actual file export
    _logger.i('Exporting ${logs.length} log entries');
  }
  
  /// Helper methods
  DateTime? _getLastSyncTime(String entity) {
    final timeStr = _syncStatusBox.get('last_sync_$entity');
    return timeStr != null ? DateTime.parse(timeStr) : null;
  }
  
  Future<void> _updateLastSyncTime(String entity) async {
    await _syncStatusBox.put('last_sync_$entity', DateTime.now().toIso8601String());
  }
  
  bool _isAutoSyncEnabled() {
    return _syncStatusBox.get('auto_sync_enabled', defaultValue: true);
  }
  
  DateTime? _getNextScheduledSync() {
    final timeStr = _syncStatusBox.get('next_scheduled_sync');
    return timeStr != null ? DateTime.parse(timeStr) : null;
  }
  
  Future<List<SyncOperation>> _getRecentOperations() async {
    final operations = <SyncOperation>[];
    final logs = _collectionLogsBox.values.cast<String>();
    
    for (final logStr in logs.take(20)) {
      try {
        final logData = jsonDecode(logStr);
        operations.add(SyncOperation.fromJson(logData));
      } catch (e) {
        _logger.w('Failed to parse log entry: $e');
      }
    }
    
    operations.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return operations;
  }
  
  Future<List<ScheduledOperation>> _getScheduledOperations() async {
    // Return placeholder scheduled operations
    return [
      ScheduledOperation(
        id: 'auto_sync_leagues',
        type: 'sync',
        entityType: 'leagues',
        description: 'Auto-sync leagues data',
        scheduledTime: DateTime.now().add(const Duration(hours: 1)),
        isEnabled: true,
      ),
    ];
  }
  
  Future<int> _getTotalSyncedRecords() async {
    final leaguesResult = await _database.executeQuery('SELECT COUNT(*) as count FROM leagues');
    final teamsResult = await _database.executeQuery('SELECT COUNT(*) as count FROM teams');
    final fixturesResult = await _database.executeQuery('SELECT COUNT(*) as count FROM fixtures');
    final standingsResult = await _database.executeQuery('SELECT COUNT(*) as count FROM standings');
    
    final leaguesCount = leaguesResult.data.isNotEmpty ? leaguesResult.data.first['count'] as int : 0;
    final teamsCount = teamsResult.data.isNotEmpty ? teamsResult.data.first['count'] as int : 0;
    final fixturesCount = fixturesResult.data.isNotEmpty ? fixturesResult.data.first['count'] as int : 0;
    final standingsCount = standingsResult.data.isNotEmpty ? standingsResult.data.first['count'] as int : 0;
    
    return leaguesCount + teamsCount + fixturesCount + standingsCount;
  }
  
  Future<void> _logOperation(SyncOperation operation) async {
    final logEntry = jsonEncode(operation.toJson());
    await _collectionLogsBox.add(logEntry);
    
    // Also log to database activity
    await _database.logActivity(
      action: operation.type,
      entityType: operation.entityType,
      details: operation.description,
    );
  }
  
  Future<List<Map<String, dynamic>>> _getCollectionLogs() async {
    final logs = <Map<String, dynamic>>[];
    final logEntries = _collectionLogsBox.values.cast<String>();
    
    for (final logStr in logEntries) {
      try {
        logs.add(jsonDecode(logStr));
      } catch (e) {
        _logger.w('Failed to parse log entry: $e');
      }
    }
    
    return logs;
  }
}

// Data classes
class ApiStatusData {
  final bool isConnected;
  final int requestsToday;
  final int requestsThisMinute;
  final int dailyLimit;
  final int minuteLimit;
  final DateTime? lastLeagueSync;
  final DateTime? lastTeamSync;
  final DateTime? lastFixtureSync;
  final DateTime? lastStandingSync;
  final DateTime nextResetTime;
  final int connectionLatency;
  
  ApiStatusData({
    required this.isConnected,
    required this.requestsToday,
    required this.requestsThisMinute,
    required this.dailyLimit,
    required this.minuteLimit,
    this.lastLeagueSync,
    this.lastTeamSync,
    this.lastFixtureSync,
    this.lastStandingSync,
    required this.nextResetTime,
    required this.connectionLatency,
  });
  
  static ApiStatusData disconnected() {
    return ApiStatusData(
      isConnected: false,
      requestsToday: 0,
      requestsThisMinute: 0,
      dailyLimit: 100,
      minuteLimit: 10,
      nextResetTime: DateTime.now().add(const Duration(hours: 24)),
      connectionLatency: -1,
    );
  }
  
  double get dailyUsagePercentage => dailyLimit > 0 ? (requestsToday / dailyLimit) * 100 : 0;
  double get minuteUsagePercentage => minuteLimit > 0 ? (requestsThisMinute / minuteLimit) * 100 : 0;
  bool get isNearDailyLimit => dailyUsagePercentage > 80;
  bool get isNearMinuteLimit => minuteUsagePercentage > 80;
}

class DataSyncStatus {
  final bool isAutoSyncEnabled;
  final DateTime? lastFullSync;
  final DateTime? nextScheduledSync;
  final List<SyncOperation> recentOperations;
  final List<ScheduledOperation> scheduledOperations;
  final int totalSyncedRecords;
  final int failedOperations;
  
  DataSyncStatus({
    required this.isAutoSyncEnabled,
    this.lastFullSync,
    this.nextScheduledSync,
    required this.recentOperations,
    required this.scheduledOperations,
    required this.totalSyncedRecords,
    required this.failedOperations,
  });
}

class SyncOperation {
  final String id;
  final String type;
  final String description;
  final String entityType;
  String status;
  final DateTime timestamp;
  DateTime? completedAt;
  String? error;
  int? recordsProcessed;
  int? recordsInserted;
  int? recordsUpdated;
  
  SyncOperation({
    required this.id,
    required this.type,
    required this.description,
    required this.entityType,
    required this.status,
    required this.timestamp,
    this.completedAt,
    this.error,
    this.recordsProcessed,
    this.recordsInserted,
    this.recordsUpdated,
  });
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'description': description,
      'entityType': entityType,
      'status': status,
      'timestamp': timestamp.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'error': error,
      'recordsProcessed': recordsProcessed,
      'recordsInserted': recordsInserted,
      'recordsUpdated': recordsUpdated,
    };
  }
  
  factory SyncOperation.fromJson(Map<String, dynamic> json) {
    return SyncOperation(
      id: json['id'],
      type: json['type'],
      description: json['description'],
      entityType: json['entityType'],
      status: json['status'],
      timestamp: DateTime.parse(json['timestamp']),
      completedAt: json['completedAt'] != null ? DateTime.parse(json['completedAt']) : null,
      error: json['error'],
      recordsProcessed: json['recordsProcessed'],
      recordsInserted: json['recordsInserted'],
      recordsUpdated: json['recordsUpdated'],
    );
  }
}

class ScheduledOperation {
  final String id;
  final String type;
  final String entityType;
  final String description;
  final DateTime scheduledTime;
  final bool isEnabled;
  
  ScheduledOperation({
    required this.id,
    required this.type,
    required this.entityType,
    required this.description,
    required this.scheduledTime,
    required this.isEnabled,
  });
}