import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../data/models/statistics_filter_model.dart';
import '../../../../shared/data/models/league_model.dart';
import '../../../../shared/data/models/team_model.dart';
import '../../../../core/network/football_api_client.dart';

// Filter State Management
class FilterNotifier extends StateNotifier<StatisticsFilterModel> {
  FilterNotifier() : super(const StatisticsFilterModel()) {
    _loadSavedFilters();
  }

  Future<void> _loadSavedFilters() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final filtersJson = prefs.getString('statistics_filters');
      
      if (filtersJson != null) {
        final filtersMap = json.decode(filtersJson) as Map<String, dynamic>;
        state = StatisticsFilterModel.fromJson(filtersMap);
      }
    } catch (e) {
      // If loading fails, keep default state
    }
  }

  Future<void> _saveFilters() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final filtersJson = json.encode(state.toJson());
      await prefs.setString('statistics_filters', filtersJson);
    } catch (e) {
      // Ignore save errors
    }
  }

  void updateSelectedLeagues(List<int> leagues) {
    state = state.copyWith(selectedLeagues: leagues);
    _saveFilters();
  }

  void updateSelectedTeams(List<int> teams) {
    state = state.copyWith(selectedTeams: teams);
    _saveFilters();
  }

  void updateSelectedSeasons(List<int> seasons) {
    state = state.copyWith(selectedSeasons: seasons);
    _saveFilters();
  }

  void updateTimeframe(StatisticsTimeframe timeframe) {
    state = state.copyWith(timeframe: timeframe);
    
    // Update dates if it's a predefined timeframe
    final dateRange = timeframe.dateRange;
    if (dateRange != null) {
      state = state.copyWith(
        startDate: dateRange.start,
        endDate: dateRange.end,
      );
    }
    
    _saveFilters();
  }

  void updateCustomDateRange(DateTime? startDate, DateTime? endDate) {
    state = state.copyWith(
      startDate: startDate,
      endDate: endDate,
      timeframe: StatisticsTimeframe.custom,
    );
    _saveFilters();
  }

  void updateViewType(StatisticsViewType viewType) {
    state = state.copyWith(viewType: viewType);
    _saveFilters();
  }

  void updateSelectedMetrics(List<StatisticsMetric> metrics) {
    state = state.copyWith(selectedMetrics: metrics);
    _saveFilters();
  }

  void updateSorting(StatisticsSortBy sortBy, bool descending) {
    state = state.copyWith(
      sortBy: sortBy,
      sortDescending: descending,
    );
    _saveFilters();
  }

  void updateIncludeFlags({
    bool? includeHomeAway,
    bool? includeForm,
    bool? includeComparisons,
  }) {
    state = state.copyWith(
      includeHomeAway: includeHomeAway ?? state.includeHomeAway,
      includeForm: includeForm ?? state.includeForm,
      includeComparisons: includeComparisons ?? state.includeComparisons,
    );
    _saveFilters();
  }

  void toggleLeague(int leagueId) {
    final currentLeagues = [...state.selectedLeagues];
    if (currentLeagues.contains(leagueId)) {
      currentLeagues.remove(leagueId);
    } else {
      currentLeagues.add(leagueId);
    }
    updateSelectedLeagues(currentLeagues);
  }

  void toggleTeam(int teamId) {
    final currentTeams = [...state.selectedTeams];
    if (currentTeams.contains(teamId)) {
      currentTeams.remove(teamId);
    } else {
      currentTeams.add(teamId);
    }
    updateSelectedTeams(currentTeams);
  }

  void toggleMetric(StatisticsMetric metric) {
    final currentMetrics = [...state.selectedMetrics];
    if (currentMetrics.contains(metric)) {
      currentMetrics.remove(metric);
    } else {
      currentMetrics.add(metric);
    }
    updateSelectedMetrics(currentMetrics);
  }

  void clearFilters() {
    state = const StatisticsFilterModel();
    _saveFilters();
  }

  void applyPreset(FilterPreset preset) {
    switch (preset) {
      case FilterPreset.topLeagues:
        state = state.copyWith(
          selectedLeagues: [39, 140, 78, 135, 61], // Premier League, La Liga, Bundesliga, Serie A, Ligue 1
          viewType: StatisticsViewType.overview,
          timeframe: StatisticsTimeframe.season,
        );
        break;
      case FilterPreset.recentForm:
        state = state.copyWith(
          timeframe: StatisticsTimeframe.last30Days,
          viewType: StatisticsViewType.trends,
          selectedMetrics: [StatisticsMetric.form, StatisticsMetric.wins, StatisticsMetric.goals],
        );
        break;
      case FilterPreset.goalAnalysis:
        state = state.copyWith(
          viewType: StatisticsViewType.detailed,
          selectedMetrics: [StatisticsMetric.goals, StatisticsMetric.assists, StatisticsMetric.shots],
        );
        break;
      case FilterPreset.defensiveStats:
        state = state.copyWith(
          viewType: StatisticsViewType.performance,
          selectedMetrics: [StatisticsMetric.cleanSheets, StatisticsMetric.tackles],
        );
        break;
    }
    _saveFilters();
  }

  void reset() {
    state = const StatisticsFilterModel();
    _saveFilters();
  }
}

// Available Leagues Provider
class AvailableLeaguesNotifier extends StateNotifier<AsyncValue<List<LeagueModel>>> {
  final FootballApiClient _apiClient;

  AvailableLeaguesNotifier(this._apiClient) : super(const AsyncValue.loading()) {
    loadLeagues();
  }

  Future<void> loadLeagues() async {
    try {
      state = const AsyncValue.loading();
      
      // Load popular leagues
      final leagues = await _apiClient.getLeagues();
      
      // Filter to major leagues for better UX
      final majorLeagues = leagues.where((league) => [
        39, 140, 78, 135, 61, // Top 5 European leagues
        2, 3, // Champions League, Europa League
        1, 848, // World Cup, European Championship
        4, 5, // Euro leagues
      ].contains(league.id)).toList();

      state = AsyncValue.data(majorLeagues);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> refresh() => loadLeagues();
}

// Available Teams Provider
class AvailableTeamsNotifier extends StateNotifier<AsyncValue<List<TeamModel>>> {
  final FootballApiClient _apiClient;

  AvailableTeamsNotifier(this._apiClient) : super(const AsyncValue.data([]));

  Future<void> loadTeamsForLeagues(List<int> leagueIds) async {
    if (leagueIds.isEmpty) {
      state = const AsyncValue.data([]);
      return;
    }

    try {
      state = const AsyncValue.loading();
      
      final allTeams = <TeamModel>[];
      final currentSeason = DateTime.now().year;
      
      for (final leagueId in leagueIds.take(3)) { // Limit to 3 leagues
        final teams = await _apiClient.getTeams(
          leagueId: leagueId,
          season: currentSeason,
        );
        allTeams.addAll(teams);
      }

      // Remove duplicates and sort by name
      final uniqueTeams = <int, TeamModel>{};
      for (final team in allTeams) {
        uniqueTeams[team.id] = team;
      }

      final sortedTeams = uniqueTeams.values.toList();
      sortedTeams.sort((a, b) => a.name.compareTo(b.name));

      state = AsyncValue.data(sortedTeams);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  void clear() {
    state = const AsyncValue.data([]);
  }
}

// Filter Validation Provider
final filterValidationProvider = Provider<FilterValidationResult>((ref) {
  final filter = ref.watch(statisticsFilterProvider);
  
  final errors = <String>[];
  final warnings = <String>[];

  // Check for basic requirements
  if (filter.selectedLeagues.isEmpty && filter.selectedTeams.isEmpty) {
    errors.add('Please select at least one league or team');
  }

  // Check date range validity
  if (filter.startDate != null && filter.endDate != null) {
    if (filter.startDate!.isAfter(filter.endDate!)) {
      errors.add('Start date cannot be after end date');
    }
    
    final daysDifference = filter.endDate!.difference(filter.startDate!).inDays;
    if (daysDifference > 365) {
      warnings.add('Date range is very large, this may affect performance');
    }
  }

  // Check for too many selections
  if (filter.selectedLeagues.length > 5) {
    warnings.add('Selecting many leagues may slow down data loading');
  }

  if (filter.selectedTeams.length > 20) {
    warnings.add('Selecting many teams may affect chart readability');
  }

  return FilterValidationResult(
    isValid: errors.isEmpty,
    errors: errors,
    warnings: warnings,
  );
});

// Filter Summary Provider
final filterSummaryProvider = Provider<String>((ref) {
  final filter = ref.watch(statisticsFilterProvider);
  final parts = <String>[];

  if (filter.selectedLeagues.isNotEmpty) {
    parts.add('${filter.selectedLeagues.length} league${filter.selectedLeagues.length > 1 ? 's' : ''}');
  }

  if (filter.selectedTeams.isNotEmpty) {
    parts.add('${filter.selectedTeams.length} team${filter.selectedTeams.length > 1 ? 's' : ''}');
  }

  parts.add(filter.timeframe.displayName);
  parts.add(filter.viewType.displayName);

  if (filter.selectedMetrics.isNotEmpty) {
    parts.add('${filter.selectedMetrics.length} metric${filter.selectedMetrics.length > 1 ? 's' : ''}');
  }

  return parts.join(' • ');
});

// Providers
final statisticsFilterProvider = StateNotifierProvider<FilterNotifier, StatisticsFilterModel>((ref) {
  return FilterNotifier();
});

final availableLeaguesProvider = StateNotifierProvider<AvailableLeaguesNotifier, AsyncValue<List<LeagueModel>>>((ref) {
  final apiClient = ref.watch(footballApiClientProvider);
  return AvailableLeaguesNotifier(apiClient);
});

final availableTeamsProvider = StateNotifierProvider<AvailableTeamsNotifier, AsyncValue<List<TeamModel>>>((ref) {
  final apiClient = ref.watch(footballApiClientProvider);
  return AvailableTeamsNotifier(apiClient);
});

// Auto-load teams when leagues change
final _teamsAutoLoader = Provider((ref) {
  final selectedLeagues = ref.watch(statisticsFilterProvider.select((filter) => filter.selectedLeagues));
  final teamsNotifier = ref.watch(availableTeamsProvider.notifier);
  
  // Load teams for selected leagues
  if (selectedLeagues.isNotEmpty) {
    Future.microtask(() => teamsNotifier.loadTeamsForLeagues(selectedLeagues));
  } else {
    teamsNotifier.clear();
  }
  
  return selectedLeagues;
});

// Filter Presets
enum FilterPreset {
  topLeagues,
  recentForm,
  goalAnalysis,
  defensiveStats,
}

extension FilterPresetX on FilterPreset {
  String get displayName {
    switch (this) {
      case FilterPreset.topLeagues:
        return 'Top Leagues';
      case FilterPreset.recentForm:
        return 'Recent Form';
      case FilterPreset.goalAnalysis:
        return 'Goal Analysis';
      case FilterPreset.defensiveStats:
        return 'Defensive Stats';
    }
  }

  String get description {
    switch (this) {
      case FilterPreset.topLeagues:
        return 'View statistics for major European leagues';
      case FilterPreset.recentForm:
        return 'Focus on recent team performance trends';
      case FilterPreset.goalAnalysis:
        return 'Analyze goal scoring patterns and efficiency';
      case FilterPreset.defensiveStats:
        return 'Focus on defensive performance metrics';
    }
  }
}

// Filter Validation Result
class FilterValidationResult {
  final bool isValid;
  final List<String> errors;
  final List<String> warnings;

  const FilterValidationResult({
    required this.isValid,
    required this.errors,
    required this.warnings,
  });

  bool get hasErrors => errors.isNotEmpty;
  bool get hasWarnings => warnings.isNotEmpty;
  bool get hasIssues => hasErrors || hasWarnings;
}