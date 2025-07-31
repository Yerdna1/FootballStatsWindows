import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import '../../../../core/network/football_api_client.dart';
import '../../../../shared/data/models/advanced_statistics_model.dart';
import '../../../../shared/data/models/team_form_model.dart';
import '../../../../shared/data/models/standings_model.dart';
import '../../../../shared/data/models/fixture_model.dart';
import '../../../../shared/data/models/league_model.dart';
import '../../../../shared/data/models/team_model.dart';
import '../../../teams/presentation/providers/teams_provider.dart';
import '../../data/models/statistics_filter_model.dart';

final logger = Logger();

// Main statistics state
class StatisticsState {
  final bool isLoading;
  final String? error;
  final List<AdvancedStatisticsModel> teamStatistics;
  final List<TeamFormModel> teamForms;
  final List<StandingsModel> standings;
  final List<FixtureModel> recentFixtures;
  final DateTime? lastUpdated;

  const StatisticsState({
    this.isLoading = false,
    this.error,
    this.teamStatistics = const [],
    this.teamForms = const [],
    this.standings = const [],
    this.recentFixtures = const [],
    this.lastUpdated,
  });

  StatisticsState copyWith({
    bool? isLoading,
    String? error,
    List<AdvancedStatisticsModel>? teamStatistics,
    List<TeamFormModel>? teamForms,
    List<StandingsModel>? standings,
    List<FixtureModel>? recentFixtures,
    DateTime? lastUpdated,
  }) {
    return StatisticsState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      teamStatistics: teamStatistics ?? this.teamStatistics,
      teamForms: teamForms ?? this.teamForms,
      standings: standings ?? this.standings,
      recentFixtures: recentFixtures ?? this.recentFixtures,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}

// Statistics notifier
class StatisticsNotifier extends StateNotifier<StatisticsState> {
  final FootballApiClient _apiClient;

  StatisticsNotifier(this._apiClient) : super(const StatisticsState());

  Future<void> loadStatistics({
    required StatisticsFilterModel filter,
    bool forceRefresh = false,
  }) async {
    if (state.isLoading) return;

    state = state.copyWith(isLoading: true, error: null);

    try {
      final results = await Future.wait([
        _loadTeamStatistics(filter),
        _loadTeamForms(filter),
        _loadStandings(filter),
        _loadRecentFixtures(filter),
      ]);

      final teamStats = results[0] as List<AdvancedStatisticsModel>;
      final teamForms = results[1] as List<TeamFormModel>;
      final standings = results[2] as List<StandingsModel>;
      final fixtures = results[3] as List<FixtureModel>;

      state = state.copyWith(
        isLoading: false,
        teamStatistics: teamStats,
        teamForms: teamForms,
        standings: standings,
        recentFixtures: fixtures,
        lastUpdated: DateTime.now(),
      );

      logger.i('Statistics loaded successfully: ${teamStats.length} team stats, ${standings.length} standings');
    } catch (e) {
      logger.e('Error loading statistics: $e');
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<List<AdvancedStatisticsModel>> _loadTeamStatistics(StatisticsFilterModel filter) async {
    final statistics = <AdvancedStatisticsModel>[];

    try {
      // Get current season if not specified
      final currentSeason = filter.selectedSeasons.isNotEmpty 
        ? filter.selectedSeasons.first 
        : DateTime.now().year;

      // Load statistics for selected teams or all teams in selected leagues
      if (filter.selectedTeams.isNotEmpty) {
        for (final teamId in filter.selectedTeams) {
          final leagueId = filter.selectedLeagues.isNotEmpty 
            ? filter.selectedLeagues.first 
            : 39; // Premier League default

          final teamStats = await _apiClient.getTeamStatistics(teamId, leagueId, currentSeason);
          if (teamStats != null) {
            statistics.add(teamStats);
          }
        }
      } else if (filter.selectedLeagues.isNotEmpty) {
        // Load for all teams in the league
        for (final leagueId in filter.selectedLeagues) {
          final teams = await _apiClient.getTeams(leagueId: leagueId, season: currentSeason);
          
          // Limit to prevent API overuse
          final limitedTeams = teams.take(20).toList();
          
          for (final team in limitedTeams) {
            try {
              final teamStats = await _apiClient.getTeamStatistics(team.id, leagueId, currentSeason);
              if (teamStats != null) {
                statistics.add(teamStats);
              }
              // Small delay to respect rate limits
              await Future.delayed(const Duration(milliseconds: 100));
            } catch (e) {
              logger.w('Failed to load statistics for team ${team.name}: $e');
            }
          }
        }
      }

      return statistics;
    } catch (e) {
      logger.e('Error loading team statistics: $e');
      return [];
    }
  }

  Future<List<TeamFormModel>> _loadTeamForms(StatisticsFilterModel filter) async {
    final forms = <TeamFormModel>[];

    try {
      final teamIds = filter.selectedTeams.isNotEmpty 
        ? filter.selectedTeams
        : await _getTeamIdsFromLeagues(filter.selectedLeagues);

      for (final teamId in teamIds.take(10)) { // Limit to prevent API overuse
        try {
          final form = await _apiClient.getTeamForm(teamId);
          if (form != null) {
            forms.add(form);
          }
          await Future.delayed(const Duration(milliseconds: 100));
        } catch (e) {
          logger.w('Failed to load form for team $teamId: $e');
        }
      }

      return forms;
    } catch (e) {
      logger.e('Error loading team forms: $e');
      return [];
    }
  }

  Future<List<StandingsModel>> _loadStandings(StatisticsFilterModel filter) async {
    final allStandings = <StandingsModel>[];

    try {
      final currentSeason = filter.selectedSeasons.isNotEmpty 
        ? filter.selectedSeasons.first 
        : DateTime.now().year;

      final leagueIds = filter.selectedLeagues.isNotEmpty 
        ? filter.selectedLeagues 
        : [39]; // Premier League default

      for (final leagueId in leagueIds) {
        try {
          final standings = await _apiClient.getStandings(leagueId, currentSeason);
          allStandings.addAll(standings);
        } catch (e) {
          logger.w('Failed to load standings for league $leagueId: $e');
        }
      }

      return allStandings;
    } catch (e) {
      logger.e('Error loading standings: $e');
      return [];
    }
  }

  Future<List<FixtureModel>> _loadRecentFixtures(StatisticsFilterModel filter) async {
    try {
      final dateRange = filter.timeframe.dateRange;
      final fixtures = <FixtureModel>[];

      if (filter.selectedLeagues.isNotEmpty) {
        for (final leagueId in filter.selectedLeagues) {
          try {
            final leagueFixtures = await _apiClient.getFixtures(
              leagueId: leagueId,
              date: dateRange?.end.toIso8601String().split('T')[0],
            );
            fixtures.addAll(leagueFixtures.take(50)); // Limit fixtures
          } catch (e) {
            logger.w('Failed to load fixtures for league $leagueId: $e');
          }
        }
      }

      // Sort by date, most recent first
      fixtures.sort((a, b) => b.utcDate.compareTo(a.utcDate));
      return fixtures.take(100).toList(); // Keep only 100 most recent
    } catch (e) {
      logger.e('Error loading recent fixtures: $e');
      return [];
    }
  }

  Future<List<int>> _getTeamIdsFromLeagues(List<int> leagueIds) async {
    final teamIds = <int>[];

    if (leagueIds.isEmpty) return teamIds;

    try {
      final currentSeason = DateTime.now().year;
      
      for (final leagueId in leagueIds) {
        final teams = await _apiClient.getTeams(leagueId: leagueId, season: currentSeason);
        teamIds.addAll(teams.map((t) => t.id));
      }

      return teamIds;
    } catch (e) {
      logger.e('Error getting team IDs from leagues: $e');
      return [];
    }
  }

  Future<void> refreshStatistics(StatisticsFilterModel filter) async {
    await loadStatistics(filter: filter, forceRefresh: true);
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  void reset() {
    state = const StatisticsState();
  }
}

// Providers
final statisticsProvider = StateNotifierProvider<StatisticsNotifier, StatisticsState>((ref) {
  final apiClient = ref.watch(footballApiClientProvider);
  return StatisticsNotifier(apiClient);
});

// Filter provider
final statisticsFilterProvider = StateProvider<StatisticsFilterModel>((ref) {
  return const StatisticsFilterModel();
});

// Computed providers
final filteredTeamStatisticsProvider = Provider<List<AdvancedStatisticsModel>>((ref) {
  final statistics = ref.watch(statisticsProvider).teamStatistics;
  final filter = ref.watch(statisticsFilterProvider);

  var filtered = statistics.where((stat) {
    // Apply date filters
    if (filter.startDate != null && stat.lastUpdated != null) {
      if (stat.lastUpdated!.isBefore(filter.startDate!)) return false;
    }
    if (filter.endDate != null && stat.lastUpdated != null) {
      if (stat.lastUpdated!.isAfter(filter.endDate!)) return false;
    }

    return true;
  }).toList();

  // Apply sorting
  switch (filter.sortBy) {
    case StatisticsSortBy.points:
      filtered.sort((a, b) => filter.sortDescending
        ? b.matchStats.points.compareTo(a.matchStats.points)
        : a.matchStats.points.compareTo(b.matchStats.points));
      break;
    case StatisticsSortBy.goals:
      filtered.sort((a, b) => filter.sortDescending
        ? b.goalStats.goalsScored.compareTo(a.goalStats.goalsScored)
        : a.goalStats.goalsScored.compareTo(b.goalStats.goalsScored));
      break;
    case StatisticsSortBy.wins:
      filtered.sort((a, b) => filter.sortDescending
        ? b.matchStats.won.compareTo(a.matchStats.won)
        : a.matchStats.won.compareTo(b.matchStats.won));
      break;
    case StatisticsSortBy.form:
      filtered.sort((a, b) => filter.sortDescending
        ? b.formRating.compareTo(a.formRating)
        : a.formRating.compareTo(b.formRating));
      break;
    case StatisticsSortBy.rating:
      filtered.sort((a, b) => filter.sortDescending
        ? b.overallRating.compareTo(a.overallRating)
        : a.overallRating.compareTo(b.overallRating));
      break;
    case StatisticsSortBy.name:
      filtered.sort((a, b) => filter.sortDescending
        ? b.entityName.compareTo(a.entityName)
        : a.entityName.compareTo(b.entityName));
      break;
  }

  return filtered;
});

final topPerformersProvider = Provider<List<AdvancedStatisticsModel>>((ref) {
  final statistics = ref.watch(filteredTeamStatisticsProvider);
  return statistics.where((stat) => stat.isTopPerformer).take(5).toList();
});

final statisticsSummaryProvider = Provider<Map<String, dynamic>>((ref) {
  final statistics = ref.watch(filteredTeamStatisticsProvider);
  final standings = ref.watch(statisticsProvider).standings;
  final fixtures = ref.watch(statisticsProvider).recentFixtures;

  if (statistics.isEmpty) {
    return {
      'totalTeams': 0,
      'totalGoals': 0,
      'totalMatches': 0,
      'avgGoalsPerMatch': 0.0,
      'topScorer': null,
      'cleanSheets': 0,
    };
  }

  final totalGoals = statistics.fold<int>(0, (sum, stat) => sum + stat.goalStats.goalsScored);
  final totalMatches = statistics.fold<int>(0, (sum, stat) => sum + stat.matchStats.played);
  final cleanSheets = statistics.fold<int>(0, (sum, stat) => sum + stat.matchStats.cleanSheets);

  final topScorer = statistics.isNotEmpty
    ? statistics.reduce((a, b) => 
        a.goalStats.goalsScored > b.goalStats.goalsScored ? a : b)
    : null;

  return {
    'totalTeams': statistics.length,
    'totalGoals': totalGoals,
    'totalMatches': totalMatches,
    'avgGoalsPerMatch': totalMatches > 0 ? totalGoals / totalMatches : 0.0,
    'topScorer': topScorer,
    'cleanSheets': cleanSheets,
    'totalFixtures': fixtures.length,
    'standingsCount': standings.length,
  };
});

// Auto-refresh provider
final autoRefreshProvider = StreamProvider<void>((ref) async* {
  while (true) {
    await Future.delayed(const Duration(minutes: 5));
    
    final filter = ref.read(statisticsFilterProvider);
    final notifier = ref.read(statisticsProvider.notifier);
    
    // Only refresh if we have active filters
    if (filter.selectedLeagues.isNotEmpty || filter.selectedTeams.isNotEmpty) {
      yield* Stream.fromFuture(notifier.refreshStatistics(filter));
    }
  }
});