import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/cards/team_card.dart';
import '../providers/teams_provider.dart';
import '../widgets/teams_search_bar.dart';
import '../widgets/teams_filter_sheet.dart';
import '../widgets/teams_grid_view.dart';
import '../widgets/teams_loading_shimmer.dart';

class TeamsPage extends ConsumerStatefulWidget {
  const TeamsPage({super.key});

  @override
  ConsumerState<TeamsPage> createState() => _TeamsPageState();
}

class _TeamsPageState extends ConsumerState<TeamsPage> {
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    
    // Load teams on first build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(teamsProvider.notifier).loadTeams();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent * 0.8) {
      final state = ref.read(teamsProvider);
      if (!state.isLoading && !state.hasReachedMax) {
        ref.read(teamsProvider.notifier).loadTeams();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final teamsState = ref.watch(teamsProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Teams'),
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterSheet(context),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(teamsProvider.notifier).loadTeams(refresh: true);
        },
        child: Column(
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.all(16),
              child: TeamsSearchBar(
                controller: _searchController,
                onChanged: (query) {
                  if (query.isEmpty) {
                    ref.read(teamsProvider.notifier).loadTeams(refresh: true);
                  }
                },
                onSubmitted: (query) {
                  ref.read(teamsProvider.notifier).searchTeams(query);
                },
              ),
            ),
            
            // Active Filters
            if (teamsState.searchQuery != null || 
                teamsState.selectedLeagueId != null || 
                teamsState.selectedCountry != null)
              _buildActiveFilters(teamsState),
            
            // Teams Content
            Expanded(
              child: _buildTeamsContent(teamsState),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveFilters(TeamsState state) {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                if (state.searchQuery != null && state.searchQuery!.isNotEmpty)
                  _buildFilterChip(
                    'Search: ${state.searchQuery}',
                    () => {
                      _searchController.clear(),
                      ref.read(teamsProvider.notifier).loadTeams(refresh: true),
                    },
                  ),
                if (state.selectedLeagueId != null)
                  _buildFilterChip(
                    'League: ${state.selectedLeagueId}',
                    () => ref.read(teamsProvider.notifier).filterByLeague(null),
                  ),
                if (state.selectedCountry != null)
                  _buildFilterChip(
                    'Country: ${state.selectedCountry}',
                    () => ref.read(teamsProvider.notifier).filterByCountry(null),
                  ),
              ],
            ),
          ),
          TextButton(
            onPressed: () {
              _searchController.clear();
              ref.read(teamsProvider.notifier).clearFilters();
            },
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, VoidCallback onRemove) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: Chip(
        label: Text(label),
        deleteIcon: const Icon(Icons.close, size: 16),
        onDeleted: onRemove,
        backgroundColor: AppColors.primary.withOpacity(0.1),
        side: BorderSide(color: AppColors.primary.withOpacity(0.3)),
      ),
    );
  }

  Widget _buildTeamsContent(TeamsState state) {
    if (state.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red[300],
            ),
            const SizedBox(height: 16),
            Text(
              'Error loading teams',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              state.error!,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref.read(teamsProvider.notifier).loadTeams(refresh: true),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (state.teams.isEmpty && state.isLoading) {
      return const TeamsLoadingShimmer();
    }

    if (state.teams.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.sports_soccer,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No teams found',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Try adjusting your search or filters',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      );
    }

    return TeamsGridView(
      teams: state.teams,
      scrollController: _scrollController,
      isLoading: state.isLoading,
      hasReachedMax: state.hasReachedMax,
      onTeamTap: (team) {
        context.push('/teams/${team.id}');
      },
    );
  }

  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => TeamsFilterSheet(
        currentLeagueId: ref.read(teamsProvider).selectedLeagueId,
        currentCountry: ref.read(teamsProvider).selectedCountry,
        onApplyFilters: (leagueId, country) {
          if (leagueId != null) {
            ref.read(teamsProvider.notifier).filterByLeague(leagueId);
          }
          if (country != null) {
            ref.read(teamsProvider.notifier).filterByCountry(country);
          }
        },
      ),
    );
  }
}