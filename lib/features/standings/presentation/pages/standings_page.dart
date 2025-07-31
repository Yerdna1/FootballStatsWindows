import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';

class StandingsPage extends ConsumerStatefulWidget {
  final int leagueId;

  const StandingsPage({
    super.key,
    required this.leagueId,
  });

  @override
  ConsumerState<StandingsPage> createState() => _StandingsPageState();
}

class _StandingsPageState extends ConsumerState<StandingsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _sortColumn = 0;
  bool _sortAscending = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_getLeagueName(widget.leagueId)),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Overall'),
            Tab(text: 'Home'),
            Tab(text: 'Away'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              // TODO: Refresh standings data
            },
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildStandingsTable(context, 'overall'),
          _buildStandingsTable(context, 'home'),
          _buildStandingsTable(context, 'away'),
        ],
      ),
    );
  }

  Widget _buildStandingsTable(BuildContext context, String type) {
    final standings = _getSampleStandings();

    return RefreshIndicator(
      onRefresh: () async {
        // TODO: Implement refresh logic
        await Future.delayed(const Duration(seconds: 1));
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          children: [
            // League Info Card
            _buildLeagueInfoCard(context),
            
            const SizedBox(height: 16),
            
            // Standings Table
            Card(
              child: Column(
                children: [
                  // Table Header
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                      ),
                    ),
                    child: Row(
                      children: [
                        Text(
                          'Standings',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: Icon(
                            _sortAscending ? Icons.arrow_upward : Icons.arrow_downward,
                            size: 20,
                          ),
                          onPressed: () {
                            setState(() {
                              _sortAscending = !_sortAscending;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  
                  // Table Headers
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                    ),
                    child: Row(
                      children: [
                        SizedBox(width: 30, child: Text('#', style: _headerStyle(context))),
                        const SizedBox(width: 8),
                        Expanded(flex: 3, child: Text('Team', style: _headerStyle(context))),
                        SizedBox(width: 35, child: Text('P', style: _headerStyle(context))),
                        SizedBox(width: 35, child: Text('W', style: _headerStyle(context))),
                        SizedBox(width: 35, child: Text('D', style: _headerStyle(context))),
                        SizedBox(width: 35, child: Text('L', style: _headerStyle(context))),
                        SizedBox(width: 45, child: Text('GD', style: _headerStyle(context))),
                        SizedBox(width: 40, child: Text('Pts', style: _headerStyle(context))),
                      ],
                    ),
                  ),
                  
                  // Table Rows
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: standings.length,
                    itemBuilder: (context, index) {
                      return _buildStandingRow(context, standings[index], index);
                    },
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Legend
            _buildLegend(context),
          ],
        ),
      ),
    );
  }

  Widget _buildLeagueInfoCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(
                Icons.sports_soccer,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getLeagueName(widget.leagueId),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Season 2023/24 • Matchday 15',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.favorite_border),
              onPressed: () {
                // TODO: Add to favorites
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Added to favorites!'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStandingRow(BuildContext context, Map<String, dynamic> team, int index) {
    final theme = Theme.of(context);
    final position = index + 1;
    final positionColor = _getPositionColor(position);

    return InkWell(
      onTap: () => context.push('/teams/${team['id']}'),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: theme.colorScheme.outline.withOpacity(0.1),
            ),
            left: BorderSide(
              color: positionColor,
              width: 4,
            ),
          ),
        ),
        child: Row(
          children: [
            // Position
            SizedBox(
              width: 30,
              child: Text(
                position.toString(),
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: positionColor,
                ),
              ),
            ),
            const SizedBox(width: 8),
            
            // Team
            Expanded(
              flex: 3,
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.sports_soccer,
                      size: 12,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      team['name'],
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            
            // Played
            SizedBox(
              width: 35,
              child: Text(
                team['played'].toString(),
                style: theme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ),
            
            // Won
            SizedBox(
              width: 35,
              child: Text(
                team['won'].toString(),
                style: theme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ),
            
            // Draw
            SizedBox(
              width: 35,
              child: Text(
                team['draw'].toString(),
                style: theme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ),
            
            // Lost
            SizedBox(
              width: 35,
              child: Text(
                team['lost'].toString(),
                style: theme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ),
            
            // Goal Difference
            SizedBox(
              width: 45,
              child: Text(
                team['goalDifference'] > 0 
                    ? '+${team['goalDifference']}'
                    : team['goalDifference'].toString(),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: team['goalDifference'] > 0 
                      ? AppColors.success
                      : team['goalDifference'] < 0 
                          ? AppColors.error
                          : null,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            
            // Points
            SizedBox(
              width: 40,
              child: Text(
                team['points'].toString(),
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegend(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Legend',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildLegendItem(context, AppColors.success, 'Champions League'),
                const SizedBox(width: 16),
                _buildLegendItem(context, AppColors.info, 'Europa League'),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildLegendItem(context, AppColors.warning, 'Conference League'),
                const SizedBox(width: 16),
                _buildLegendItem(context, AppColors.error, 'Relegation'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(BuildContext context, Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 4,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  TextStyle _headerStyle(BuildContext context) {
    return Theme.of(context).textTheme.bodySmall?.copyWith(
      fontWeight: FontWeight.bold,
      color: AppColors.textSecondary,
    ) ?? const TextStyle();
  }

  Color _getPositionColor(int position) {
    if (position <= 4) return AppColors.success; // Champions League
    if (position <= 6) return AppColors.info; // Europa League
    if (position == 7) return AppColors.warning; // Conference League
    if (position >= 18) return AppColors.error; // Relegation
    return Colors.grey;
  }

  String _getLeagueName(int leagueId) {
    switch (leagueId) {
      case 2021: return 'Premier League';
      case 2014: return 'La Liga';
      case 2002: return 'Bundesliga';
      case 2019: return 'Serie A';
      case 2015: return 'Ligue 1';
      default: return 'League Standings';
    }
  }

  List<Map<String, dynamic>> _getSampleStandings() {
    return [
      {'id': 1, 'name': 'Manchester City', 'played': 15, 'won': 12, 'draw': 2, 'lost': 1, 'goalDifference': 28, 'points': 38},
      {'id': 2, 'name': 'Arsenal', 'played': 15, 'won': 11, 'draw': 3, 'lost': 1, 'goalDifference': 24, 'points': 36},
      {'id': 3, 'name': 'Liverpool', 'played': 15, 'won': 10, 'draw': 4, 'lost': 1, 'goalDifference': 20, 'points': 34},
      {'id': 4, 'name': 'Tottenham', 'played': 15, 'won': 10, 'draw': 2, 'lost': 3, 'goalDifference': 12, 'points': 32},
      {'id': 5, 'name': 'Chelsea', 'played': 15, 'won': 8, 'draw': 4, 'lost': 3, 'goalDifference': 8, 'points': 28},
      {'id': 6, 'name': 'Manchester United', 'played': 15, 'won': 8, 'draw': 3, 'lost': 4, 'goalDifference': 4, 'points': 27},
      {'id': 7, 'name': 'Newcastle', 'played': 15, 'won': 7, 'draw': 5, 'lost': 3, 'goalDifference': 6, 'points': 26},
      {'id': 8, 'name': 'Brighton', 'played': 15, 'won': 7, 'draw': 4, 'lost': 4, 'goalDifference': 2, 'points': 25},
      {'id': 9, 'name': 'West Ham', 'played': 15, 'won': 6, 'draw': 5, 'lost': 4, 'goalDifference': 0, 'points': 23},
      {'id': 10, 'name': 'Aston Villa', 'played': 15, 'won': 6, 'draw': 4, 'lost': 5, 'goalDifference': -2, 'points': 22},
    ];
  }
}