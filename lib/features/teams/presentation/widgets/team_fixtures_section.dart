import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/data/models/fixture_model.dart';
import '../../../../shared/widgets/cards/match_card.dart';
import '../providers/team_fixtures_provider.dart';

class TeamFixturesSection extends ConsumerStatefulWidget {
  final int teamId;

  const TeamFixturesSection({super.key, required this.teamId});

  @override
  ConsumerState<TeamFixturesSection> createState() => _TeamFixturesSectionState();
}

class _TeamFixturesSectionState extends ConsumerState<TeamFixturesSection>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    // Load fixtures on first build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(teamFixturesProvider(widget.teamId).notifier).loadFixtures(widget.teamId);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fixturesState = ref.watch(teamFixturesProvider(widget.teamId));

    return Column(
      children: [
        // Tab Bar
        Container(
          color: Theme.of(context).scaffoldBackgroundColor,
          child: TabBar(
            controller: _tabController,
            labelColor: Theme.of(context).primaryColor,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Theme.of(context).primaryColor,
            tabs: const [
              Tab(text: 'Upcoming'),
              Tab(text: 'Recent'),
              Tab(text: 'All'),
            ],
          ),
        ),
        
        // Tab Content
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildFixturesList(fixturesState, 'upcoming'),
              _buildFixturesList(fixturesState, 'recent'),
              _buildFixturesList(fixturesState, 'all'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFixturesList(TeamFixturesState state, String filter) {
    if (state.error != null) {
      return _buildErrorView(state.error!);
    }

    if (state.isLoading && state.fixtures.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    List<FixtureModel> filteredFixtures;
    switch (filter) {
      case 'upcoming':
        filteredFixtures = state.upcomingFixtures;
        break;
      case 'recent':
        filteredFixtures = state.recentFixtures;
        break;
      default:
        filteredFixtures = state.fixtures;
    }

    if (filteredFixtures.isEmpty) {
      return _buildEmptyView(filter);
    }

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(teamFixturesProvider(widget.teamId).notifier).loadFixtures(widget.teamId, refresh: true);
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: filteredFixtures.length + (state.isLoading ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == filteredFixtures.length) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(),
              ),
            );
          }

          final fixture = filteredFixtures[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: MatchCard(
              fixture: fixture,
              onTap: () => context.push('/fixtures/${fixture.id}'),
              highlightTeamId: widget.teamId,
            ),
          );
        },
      ),
    );
  }

  Widget _buildErrorView(String error) {
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
            'Error loading fixtures',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              ref.read(teamFixturesProvider(widget.teamId).notifier).loadFixtures(widget.teamId, refresh: true);
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyView(String filter) {
    String message;
    IconData icon;
    
    switch (filter) {
      case 'upcoming':
        message = 'No upcoming fixtures';
        icon = Icons.schedule;
        break;
      case 'recent':
        message = 'No recent fixtures';
        icon = Icons.history;
        break;
      default:
        message = 'No fixtures found';
        icon = Icons.sports_soccer;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Check back later for updates',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}