import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/data/models/fixture_model.dart';
import '../../domain/repositories/teams_repository.dart';
import 'teams_provider.dart';

class TeamFixturesState {
  final List<FixtureModel> fixtures;
  final bool isLoading;
  final String? error;

  const TeamFixturesState({
    this.fixtures = const [],
    this.isLoading = false,
    this.error,
  });

  TeamFixturesState copyWith({
    List<FixtureModel>? fixtures,
    bool? isLoading,
    String? error,
  }) {
    return TeamFixturesState(
      fixtures: fixtures ?? this.fixtures,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  List<FixtureModel> get upcomingFixtures {
    final now = DateTime.now();
    return fixtures
        .where((fixture) => fixture.utcDate.isAfter(now))
        .toList()
      ..sort((a, b) => a.utcDate.compareTo(b.utcDate));
  }

  List<FixtureModel> get recentFixtures {
    final now = DateTime.now();
    return fixtures
        .where((fixture) => fixture.utcDate.isBefore(now))
        .toList()
      ..sort((a, b) => b.utcDate.compareTo(a.utcDate));
  }
}

class TeamFixturesNotifier extends StateNotifier<TeamFixturesState> {
  final TeamsRepository _repository;

  TeamFixturesNotifier(this._repository) : super(const TeamFixturesState());

  Future<void> loadFixtures(int teamId, {bool refresh = false}) async {
    if (state.isLoading && !refresh) return;

    if (refresh) {
      state = state.copyWith(fixtures: [], error: null);
    }

    state = state.copyWith(isLoading: true, error: null);

    final result = await _repository.getTeamFixtures(
      teamId,
      limit: 50,
    );

    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        error: failure.message,
      ),
      (fixtures) {
        final fixtureModels = fixtures.whereType<FixtureModel>().toList();
        state = state.copyWith(
          fixtures: fixtureModels,
          isLoading: false,
          error: null,
        );
      },
    );
  }

  Future<void> loadUpcomingFixtures(int teamId) async {
    final now = DateTime.now();
    final result = await _repository.getTeamFixtures(
      teamId,
      from: now,
      status: 'SCHEDULED',
      limit: 10,
    );

    result.fold(
      (failure) => state = state.copyWith(error: failure.message),
      (fixtures) {
        final fixtureModels = fixtures.whereType<FixtureModel>().toList();
        final currentFixtures = [...state.fixtures];
        
        // Remove old upcoming fixtures and add new ones
        currentFixtures.removeWhere((f) => f.utcDate.isAfter(now));
        currentFixtures.addAll(fixtureModels);
        
        state = state.copyWith(
          fixtures: currentFixtures,
          error: null,
        );
      },
    );
  }

  Future<void> loadRecentFixtures(int teamId) async {
    final now = DateTime.now();
    final result = await _repository.getTeamFixtures(
      teamId,
      to: now,
      status: 'FINISHED',
      limit: 10,
    );

    result.fold(
      (failure) => state = state.copyWith(error: failure.message),
      (fixtures) {
        final fixtureModels = fixtures.whereType<FixtureModel>().toList();
        final currentFixtures = [...state.fixtures];
        
        // Remove old recent fixtures and add new ones
        currentFixtures.removeWhere((f) => f.utcDate.isBefore(now));
        currentFixtures.addAll(fixtureModels);
        
        state = state.copyWith(
          fixtures: currentFixtures,
          error: null,
        );
      },
    );
  }
}

final teamFixturesProvider = StateNotifierProvider.family<TeamFixturesNotifier, TeamFixturesState, int>((ref, teamId) {
  final repository = ref.watch(teamsRepositoryProvider);
  return TeamFixturesNotifier(repository);
});