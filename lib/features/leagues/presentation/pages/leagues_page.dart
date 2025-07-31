import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';

class LeaguesPage extends ConsumerStatefulWidget {
  const LeaguesPage({super.key});

  @override
  ConsumerState<LeaguesPage> createState() => _LeaguesPageState();
}

class _LeaguesPageState extends ConsumerState<LeaguesPage> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Leagues'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterDialog(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search leagues...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),

          // Leagues List
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                // TODO: Implement refresh logic
                await Future.delayed(const Duration(seconds: 1));
              },
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.defaultPadding,
                ),
                itemCount: _getFilteredLeagues().length,
                itemBuilder: (context, index) {
                  final league = _getFilteredLeagues()[index];
                  return _buildLeagueCard(context, league);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _getFilteredLeagues() {
    final leagues = _getSampleLeagues();
    if (_searchQuery.isEmpty) return leagues;
    
    return leagues.where((league) {
      return league['name'].toLowerCase().contains(_searchQuery.toLowerCase()) ||
             league['country'].toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  List<Map<String, dynamic>> _getSampleLeagues() {
    return [
      {
        'id': 2021,
        'name': 'Premier League',
        'country': 'England',
        'season': '2023/24',
        'matchday': 15,
        'teams': 20,
        'matches': 380,
      },
      {
        'id': 2014,
        'name': 'La Liga',
        'country': 'Spain',
        'season': '2023/24',
        'matchday': 14,
        'teams': 20,
        'matches': 380,
      },
      {
        'id': 2002,
        'name': 'Bundesliga',
        'country': 'Germany',
        'season': '2023/24',
        'matchday': 13,
        'teams': 18,
        'matches': 306,
      },
      {
        'id': 2019,
        'name': 'Serie A',
        'country': 'Italy',
        'season': '2023/24',
        'matchday': 14,
        'teams': 20,
        'matches': 380,
      },
      {
        'id': 2015,
        'name': 'Ligue 1',
        'country': 'France',
        'season': '2023/24',
        'matchday': 14,
        'teams': 18,
        'matches': 306,
      },
      {
        'id': 2001,
        'name': 'UEFA Champions League',
        'country': 'Europe',
        'season': '2023/24',
        'matchday': 6,
        'teams': 32,
        'matches': 125,
      },
    ];
  }

  Widget _buildLeagueCard(BuildContext context, Map<String, dynamic> league) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => context.push('/leagues/${league['id']}'),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Row(
            children: [
              // League Logo Placeholder
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Icon(
                  Icons.sports_soccer,
                  size: 28,
                  color: AppColors.primary,
                ),
              ),

              const SizedBox(width: 16),

              // League Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      league['name'],
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      league['country'],
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildInfoChip(
                          context,
                          'Matchday ${league['matchday']}',
                          Icons.calendar_today,
                        ),
                        const SizedBox(width: 8),
                        _buildInfoChip(
                          context,
                          '${league['teams']} teams',
                          Icons.group,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Action Buttons
              Column(
                children: [
                  IconButton(
                    icon: const Icon(Icons.table_chart_outlined),
                    onPressed: () => context.push('/leagues/${league['id']}/standings'),
                    tooltip: 'Standings',
                  ),
                  IconButton(
                    icon: const Icon(Icons.schedule_outlined),
                    onPressed: () => context.push('/leagues/${league['id']}/fixtures'),
                    tooltip: 'Fixtures',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(BuildContext context, String text, IconData icon) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Leagues'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CheckboxListTile(
              title: const Text('Premier League'),
              value: true,
              onChanged: (value) {},
            ),
            CheckboxListTile(
              title: const Text('La Liga'),
              value: true,
              onChanged: (value) {},
            ),
            CheckboxListTile(
              title: const Text('Bundesliga'),
              value: false,
              onChanged: (value) {},
            ),
            CheckboxListTile(
              title: const Text('Serie A'),
              value: false,
              onChanged: (value) {},
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }
}