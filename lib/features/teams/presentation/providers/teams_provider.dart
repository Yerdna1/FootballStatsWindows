import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/network_info.dart';
import '../../data/datasources/teams_local_datasource.dart';
import '../../data/datasources/teams_remote_datasource.dart';
import '../../data/repositories/teams_repository_impl.dart';
import '../../domain/entities/team_entity.dart';
import '../../domain/repositories/teams_repository.dart';
import '../../domain/usecases/get_teams_usecase.dart';
import '../../domain/usecases/get_team_details_usecase.dart';
import '../../domain/usecases/search_teams_usecase.dart';
import '../../domain/usecases/manage_favorites_usecase.dart';

// Dependencies
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences must be overridden');
});

final connectivityProvider = Provider<Connectivity>((ref) => Connectivity());

final dioProvider = Provider<Dio>((ref) => Dio());

final apiClientProvider = Provider<ApiClient>((ref) {
  final dio = ref.watch(dioProvider);
  return ApiClient(dio);
});

final networkInfoProvider = Provider<NetworkInfo>((ref) {
  final connectivity = ref.watch(connectivityProvider);
  return NetworkInfoImpl(connectivity: connectivity);
});

// Data sources
final teamsRemoteDataSourceProvider = Provider<TeamsRemoteDataSource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return TeamsRemoteDataSourceImpl(apiClient: apiClient);
});

final teamsLocalDataSourceProvider = Provider<TeamsLocalDataSource>((ref) {
  final sharedPreferences = ref.watch(sharedPreferencesProvider);
  return TeamsLocalDataSourceImpl(sharedPreferences: sharedPreferences);
});

// Repository
final teamsRepositoryProvider = Provider<TeamsRepository>((ref) {
  final remoteDataSource = ref.watch(teamsRemoteDataSourceProvider);
  final localDataSource = ref.watch(teamsLocalDataSourceProvider);
  final networkInfo = ref.watch(networkInfoProvider);
  
  return TeamsRepositoryImpl(
    remoteDataSource: remoteDataSource,
    localDataSource: localDataSource,
    networkInfo: networkInfo,
  );
});

// Use cases
final getTeamsUseCaseProvider = Provider<GetTeamsUseCase>((ref) {
  final repository = ref.watch(teamsRepositoryProvider);
  return GetTeamsUseCase(repository);
});

final getTeamDetailsUseCaseProvider = Provider<GetTeamDetailsUseCase>((ref) {
  final repository = ref.watch(teamsRepositoryProvider);
  return GetTeamDetailsUseCase(repository);
});

final searchTeamsUseCaseProvider = Provider<SearchTeamsUseCase>((ref) {
  final repository = ref.watch(teamsRepositoryProvider);
  return SearchTeamsUseCase(repository);
});

final getFavoriteTeamsUseCaseProvider = Provider<GetFavoriteTeamsUseCase>((ref) {
  final repository = ref.watch(teamsRepositoryProvider);
  return GetFavoriteTeamsUseCase(repository);
});

final addTeamToFavoritesUseCaseProvider = Provider<AddTeamToFavoritesUseCase>((ref) {
  final repository = ref.watch(teamsRepositoryProvider);
  return AddTeamToFavoritesUseCase(repository);
});

final removeTeamFromFavoritesUseCaseProvider = Provider<RemoveTeamFromFavoritesUseCase>((ref) {
  final repository = ref.watch(teamsRepositoryProvider);
  return RemoveTeamFromFavoritesUseCase(repository);
});

final isTeamFavoriteUseCaseProvider = Provider<IsTeamFavoriteUseCase>((ref) {
  final repository = ref.watch(teamsRepositoryProvider);
  return IsTeamFavoriteUseCase(repository);
});

// States
class TeamsState {
  final List<TeamEntity> teams;
  final bool isLoading;
  final String? error;
  final bool hasReachedMax;
  final String? searchQuery;
  final int? selectedLeagueId;
  final String? selectedCountry;

  const TeamsState({
    this.teams = const [],
    this.isLoading = false,
    this.error,
    this.hasReachedMax = false,
    this.searchQuery,
    this.selectedLeagueId,
    this.selectedCountry,
  });

  TeamsState copyWith({
    List<TeamEntity>? teams,
    bool? isLoading,
    String? error,
    bool? hasReachedMax,
    String? searchQuery,
    int? selectedLeagueId,
    String? selectedCountry,
  }) {
    return TeamsState(
      teams: teams ?? this.teams,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedLeagueId: selectedLeagueId ?? this.selectedLeagueId,
      selectedCountry: selectedCountry ?? this.selectedCountry,
    );
  }
}

class TeamDetailsState {
  final TeamEntity? team;
  final bool isLoading;
  final String? error;
  final bool isFavorite;

  const TeamDetailsState({
    this.team,
    this.isLoading = false,
    this.error,
    this.isFavorite = false,
  });

  TeamDetailsState copyWith({
    TeamEntity? team,
    bool? isLoading,
    String? error,
    bool? isFavorite,
  }) {
    return TeamDetailsState(
      team: team ?? this.team,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}

// Providers
class TeamsNotifier extends StateNotifier<TeamsState> {
  final GetTeamsUseCase _getTeamsUseCase;
  final SearchTeamsUseCase _searchTeamsUseCase;
  
  TeamsNotifier(this._getTeamsUseCase, this._searchTeamsUseCase) : super(const TeamsState());

  static const int _pageSize = 20;

  Future<void> loadTeams({
    bool refresh = false,
    String? search,
    int? leagueId,
    String? country,
  }) async {
    if (state.isLoading && !refresh) return;
    
    if (refresh) {
      state = state.copyWith(
        teams: [],
        hasReachedMax: false,
        error: null,
      );
    }

    state = state.copyWith(
      isLoading: true,
      error: null,
      searchQuery: search,
      selectedLeagueId: leagueId,
      selectedCountry: country,
    );

    final result = await _getTeamsUseCase(GetTeamsParams(
      search: search,
      leagueId: leagueId,
      country: country,
      limit: _pageSize,
      offset: refresh ? 0 : state.teams.length,
    ));

    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        error: failure.message,
      ),
      (teams) {
        final allTeams = refresh ? teams : [...state.teams, ...teams];
        state = state.copyWith(
          teams: allTeams,
          isLoading: false,
          hasReachedMax: teams.length < _pageSize,
          error: null,
        );
      },
    );
  }

  Future<void> searchTeams(String query) async {
    if (query.isEmpty) {
      await loadTeams(refresh: true);
      return;
    }

    state = state.copyWith(
      isLoading: true,
      error: null,
      searchQuery: query,
    );

    final result = await _searchTeamsUseCase(SearchTeamsParams(query: query));

    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        error: failure.message,
      ),
      (teams) => state = state.copyWith(
        teams: teams,
        isLoading: false,
        hasReachedMax: true,
        error: null,
      ),
    );
  }

  Future<void> filterByLeague(int? leagueId) async {
    await loadTeams(refresh: true, leagueId: leagueId);
  }

  Future<void> filterByCountry(String? country) async {
    await loadTeams(refresh: true, country: country);
  }

  void clearFilters() {
    loadTeams(refresh: true);
  }
}

class TeamDetailsNotifier extends StateNotifier<TeamDetailsState> {
  final GetTeamDetailsUseCase _getTeamDetailsUseCase;
  final IsTeamFavoriteUseCase _isTeamFavoriteUseCase;
  final AddTeamToFavoritesUseCase _addTeamToFavoritesUseCase;
  final RemoveTeamFromFavoritesUseCase _removeTeamFromFavoritesUseCase;

  TeamDetailsNotifier(
    this._getTeamDetailsUseCase,
    this._isTeamFavoriteUseCase,
    this._addTeamToFavoritesUseCase,
    this._removeTeamFromFavoritesUseCase,
  ) : super(const TeamDetailsState());

  Future<void> loadTeamDetails(int teamId) async {
    state = state.copyWith(isLoading: true, error: null);

    // Load team details and favorite status in parallel
    final detailsResult = await _getTeamDetailsUseCase(GetTeamDetailsParams(teamId: teamId));
    final favoriteResult = await _isTeamFavoriteUseCase(IsTeamFavoriteParams(teamId: teamId));

    detailsResult.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        error: failure.message,
      ),
      (team) {
        favoriteResult.fold(
          (failure) => state = state.copyWith(
            team: team,
            isLoading: false,
            isFavorite: false,
          ),
          (isFavorite) => state = state.copyWith(
            team: team,
            isLoading: false,
            isFavorite: isFavorite,
            error: null,
          ),
        );
      },
    );
  }

  Future<void> toggleFavorite() async {
    if (state.team == null) return;

    final teamId = state.team!.id;
    final wasExclusive = state.isFavorite;

    // Optimistically update UI
    state = state.copyWith(isFavorite: !wasExclusive);

    final result = wasExclusive
        ? await _removeTeamFromFavoritesUseCase(RemoveFromFavoritesParams(teamId: teamId))
        : await _addTeamToFavoritesUseCase(AddToFavoritesParams(teamId: teamId));

    result.fold(
      (failure) {
        // Revert on failure
        state = state.copyWith(isFavorite: wasExclusive);
      },
      (_) {
        // Success - UI already updated optimistically
      },
    );
  }
}

// Provider instances
final teamsProvider = StateNotifierProvider<TeamsNotifier, TeamsState>((ref) {
  final getTeamsUseCase = ref.watch(getTeamsUseCaseProvider);
  final searchTeamsUseCase = ref.watch(searchTeamsUseCaseProvider);
  return TeamsNotifier(getTeamsUseCase, searchTeamsUseCase);
});

final teamDetailsProvider = StateNotifierProvider.family<TeamDetailsNotifier, TeamDetailsState, int>((ref, teamId) {
  final getTeamDetailsUseCase = ref.watch(getTeamDetailsUseCaseProvider);
  final isTeamFavoriteUseCase = ref.watch(isTeamFavoriteUseCaseProvider);
  final addTeamToFavoritesUseCase = ref.watch(addTeamToFavoritesUseCaseProvider);
  final removeTeamFromFavoritesUseCase = ref.watch(removeTeamFromFavoritesUseCaseProvider);
  
  return TeamDetailsNotifier(
    getTeamDetailsUseCase,
    isTeamFavoriteUseCase,
    addTeamToFavoritesUseCase,
    removeTeamFromFavoritesUseCase,
  );
});

final favoriteTeamsProvider = FutureProvider<List<TeamEntity>>((ref) async {
  final getFavoriteTeamsUseCase = ref.watch(getFavoriteTeamsUseCaseProvider);
  final result = await getFavoriteTeamsUseCase(const NoParams());
  
  return result.fold(
    (failure) => throw Exception(failure.message),
    (teams) => teams,
  );
});