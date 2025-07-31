import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../data/models/statistics_filter_model.dart';
import '../../data/models/chart_data_model.dart';
import '../providers/statistics_provider.dart';
import '../providers/filter_provider.dart';
import '../providers/chart_data_provider.dart';
import '../widgets/statistics_card.dart';
import '../widgets/statistics_filter.dart';
import '../widgets/export_button.dart';
import '../widgets/charts/league_standings_chart.dart';
import '../widgets/charts/team_form_chart.dart';

class StatisticsPage extends ConsumerStatefulWidget {
  const StatisticsPage({super.key});

  @override
  ConsumerState<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends ConsumerState<StatisticsPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  bool _isFilterExpanded = false;
  ScrollController? _scrollController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _scrollController = ScrollController();
    
    // Load initial data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController?.dispose();
    super.dispose();
  }

  void _loadInitialData() {
    final filter = ref.read(statisticsFilterProvider);
    
    // If no leagues selected, apply a default filter
    if (filter.selectedLeagues.isEmpty) {
      ref.read(statisticsFilterProvider.notifier).applyPreset(FilterPreset.topLeagues);
    }
    
    // Load statistics with current filter
    ref.read(statisticsProvider.notifier).loadStatistics(filter: filter);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = constraints.maxWidth > 1200;
            final isTablet = constraints.maxWidth > 600 && constraints.maxWidth <= 1200;
            
            if (isDesktop) {
              return _buildDesktopLayout(context);
            } else if (isTablet) {
              return _buildTabletLayout(context);
            } else {
              return _buildMobileLayout(context);
            }
          },
        ),
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return Row(
      children: [
        // Sidebar with filters
        Container(
          width: 320.w,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            border: Border(
              right: BorderSide(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
              ),
            ),
          ),
          child: Column(
            children: [
              _buildHeader(context, showMenuButton: false),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(16.w),
                  child: Column(
                    children: [
                      StatisticsFilter(
                        onFiltersChanged: _onFiltersChanged,
                        isCompact: false,
                      ),
                      SizedBox(height: 16.h),
                      ExportButton(
                        isCompact: false,
                        onExportCompleted: _onExportCompleted,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        
        // Main content
        Expanded(
          child: Column(
            children: [
              _buildSummaryCards(context),
              Expanded(
                child: _buildMainContent(context),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTabletLayout(BuildContext context) {
    return Column(
      children: [
        _buildHeader(context),
        
        // Collapsible filter section
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: _isFilterExpanded ? 200.h : 60.h,
          child: _isFilterExpanded
            ? StatisticsFilter(
                onFiltersChanged: _onFiltersChanged,
                isCompact: false,
              )
            : StatisticsFilter(
                onFiltersChanged: _onFiltersChanged,
                isCompact: true,
              ),
        ),
        
        _buildSummaryCards(context),
        
        Expanded(
          child: _buildMainContent(context),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return Column(
      children: [
        _buildHeader(context),
        
        // Compact filter
        StatisticsFilter(
          onFiltersChanged: _onFiltersChanged,
          isCompact: true,
        ),
        
        _buildSummaryCards(context),
        
        Expanded(
          child: _buildMainContent(context),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, {bool showMenuButton = true}) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final statisticsState = ref.watch(statisticsProvider);

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: colorScheme.outline.withOpacity(0.1),
          ),
        ),
      ),
      child: Row(
        children: [
          if (showMenuButton)
            IconButton(
              onPressed: () => Scaffold.of(context).openDrawer(),
              icon: const Icon(Icons.menu),
            ),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Statistics Dashboard',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (statisticsState.lastUpdated != null) ...[
                  SizedBox(height: 4.h),
                  Text(
                    'Last updated: ${_formatLastUpdated(statisticsState.lastUpdated!)}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ],
            ),
          ),
          
          // Action buttons
          Row(
            children: [
              if (statisticsState.isLoading)
                SizedBox(
                  width: 16.w,
                  height: 16.w,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(colorScheme.primary),
                  ),
                )
              else
                IconButton(
                  onPressed: _refreshData,
                  icon: const Icon(Icons.refresh),
                  tooltip: 'Refresh Data',
                ),
              
              // Export button for mobile/tablet
              if (MediaQuery.of(context).size.width < 1200)
                ExportButton(
                  isCompact: true,
                  onExportCompleted: _onExportCompleted,
                ),
              
              // Filter toggle for tablet
              if (MediaQuery.of(context).size.width > 600 && 
                  MediaQuery.of(context).size.width <= 1200)
                IconButton(
                  onPressed: () => setState(() => _isFilterExpanded = !_isFilterExpanded),
                  icon: Icon(_isFilterExpanded ? Icons.expand_less : Icons.expand_more),
                  tooltip: 'Toggle Filters',
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCards(BuildContext context) {
    final summary = ref.watch(statisticsSummaryProvider);
    final topPerformers = ref.watch(topPerformersProvider);

    return Container(
      padding: EdgeInsets.all(16.w),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final cardWidth = constraints.maxWidth > 1200 
            ? (constraints.maxWidth - 32.w) / 4
            : constraints.maxWidth > 600
              ? (constraints.maxWidth - 24.w) / 3
              : (constraints.maxWidth - 16.w) / 2;

          return Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: [
              SizedBox(
                width: cardWidth,
                child: CompactStatisticsCard(
                  title: 'Total Teams',
                  value: '${summary['totalTeams']}',
                  icon: Icons.groups,
                  color: Colors.blue,
                ),
              ),
              SizedBox(
                width: cardWidth,
                child: CompactStatisticsCard(
                  title: 'Total Goals',
                  value: '${summary['totalGoals']}',
                  icon: Icons.sports_soccer,
                  color: Colors.green,
                ),
              ),
              SizedBox(
                width: cardWidth,
                child: CompactStatisticsCard(
                  title: 'Avg Goals/Match',
                  value: '${(summary['avgGoalsPerMatch'] as double).toStringAsFixed(1)}',
                  icon: Icons.analytics,
                  color: Colors.orange,
                ),
              ),
              SizedBox(
                width: cardWidth,
                child: CompactStatisticsCard(
                  title: 'Clean Sheets',
                  value: '${summary['cleanSheets']}',
                  icon: Icons.shield,
                  color: Colors.purple,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMainContent(BuildContext context) {
    return Column(
      children: [
        // Tab Bar
        TabBar(
          controller: _tabController,
          tabs: const [
            Tab(
              icon: Icon(Icons.leaderboard),
              text: 'Standings',
            ),
            Tab(
              icon: Icon(Icons.trending_up),
              text: 'Form',
            ),
            Tab(
              icon: Icon(Icons.pie_chart),
              text: 'Analysis',
            ),
            Tab(
              icon: Icon(Icons.compare),
              text: 'Compare',
            ),
          ],
          labelStyle: Theme.of(context).textTheme.labelMedium,
          unselectedLabelStyle: Theme.of(context).textTheme.labelMedium,
        ),
        
        // Tab Content
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildStandingsTab(context),
              _buildFormTab(context),
              _buildAnalysisTab(context),
              _buildCompareTab(context),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStandingsTab(BuildContext context) {
    return SingleChildScrollView(
      controller: _scrollController,
      padding: EdgeInsets.all(16.w),
      child: Column(
        children: [
          // Main standings chart
          SizedBox(
            height: 500.h,
            child: const LeagueStandingsChart(
              showTeamLogos: true,
              showPoints: true,
              maxTeams: 20,
            ),
          ),
          
          SizedBox(height: 16.h),
          
          // Additional stats cards
          _buildDetailedStatsSection(context),
        ],
      ),
    );
  }

  Widget _buildFormTab(BuildContext context) {
    return SingleChildScrollView(
      controller: _scrollController,
      padding: EdgeInsets.all(16.w),
      child: Column(
        children: [
          // Team form chart
          SizedBox(
            height: 400.h,
            child: const TeamFormChart(
              showMultipleTeams: true,
              showTrendLines: true,
              maxMatches: 10,
            ),
          ),
          
          SizedBox(height: 16.h),
          
          // Form analysis cards
          _buildFormAnalysisSection(context),
        ],
      ),
    );
  }

  Widget _buildAnalysisTab(BuildContext context) {
    return SingleChildScrollView(
      controller: _scrollController,
      padding: EdgeInsets.all(16.w),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 800;
          
          return Column(
            children: [
              if (isWide) ...[
                // Two charts side by side
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 300.h,
                        child: _buildGoalDistributionChart(context),
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: SizedBox(
                        height: 300.h,
                        child: _buildPerformanceRadarChart(context),
                      ),
                    ),
                  ],
                ),
              ] else ...[
                // Stacked charts
                SizedBox(
                  height: 300.h,
                  child: _buildGoalDistributionChart(context),
                ),
                SizedBox(height: 16.h),
                SizedBox(
                  height: 300.h,
                  child: _buildPerformanceRadarChart(context),
                ),
              ],
              
              SizedBox(height: 16.h),
              
              // Trend analysis
              SizedBox(
                height: 400.h,
                child: _buildTrendAnalysisChart(context),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCompareTab(BuildContext context) {
    return SingleChildScrollView(
      controller: _scrollController,
      padding: EdgeInsets.all(16.w),
      child: Column(
        children: [
          // Team comparison selector
          _buildTeamComparisonSelector(context),
          
          SizedBox(height: 16.h),
          
          // Comparison charts
          _buildComparisonCharts(context),
        ],
      ),
    );
  }

  Widget _buildDetailedStatsSection(BuildContext context) {
    final statistics = ref.watch(filteredTeamStatisticsProvider);
    
    if (statistics.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Detailed Statistics',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        
        SizedBox(height: 12.h),
        
        LayoutBuilder(
          builder: (context, constraints) {
            final cardWidth = constraints.maxWidth > 800 
              ? (constraints.maxWidth - 24.w) / 3
              : constraints.maxWidth > 600
                ? (constraints.maxWidth - 16.w) / 2
                : constraints.maxWidth;

            return Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: statistics.take(6).map((stat) {
                return SizedBox(
                  width: cardWidth,
                  child: StatisticsCard(
                    title: stat.entityName,
                    value: '${stat.matchStats.points}',
                    subtitle: '${stat.matchStats.won}W ${stat.matchStats.drawn}D ${stat.matchStats.lost}L',
                    unit: 'pts',
                    icon: Icons.sports_soccer,
                    trend: '${stat.formRating.toStringAsFixed(1)}%',
                    trendDirection: stat.formRating > 50 
                      ? TrendDirection.up 
                      : stat.formRating < 50
                        ? TrendDirection.down
                        : TrendDirection.stable,
                    additionalStats: [
                      StatisticItem(
                        label: 'Goals Scored',
                        value: '${stat.goalStats.goalsScored}',
                      ),
                      StatisticItem(
                        label: 'Goals Conceded',
                        value: '${stat.goalStats.goalsConceded}',
                      ),
                      StatisticItem(
                        label: 'Clean Sheets',
                        value: '${stat.matchStats.cleanSheets}',
                      ),
                    ],
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildFormAnalysisSection(BuildContext context) {
    final teamForms = ref.watch(statisticsProvider).teamForms;
    
    if (teamForms.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Form Analysis',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        
        SizedBox(height: 12.h),
        
        LayoutBuilder(
          builder: (context, constraints) {
            final cardWidth = constraints.maxWidth > 600 
              ? (constraints.maxWidth - 16.w) / 2
              : constraints.maxWidth;

            return Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: teamForms.take(4).map((form) {
                return SizedBox(
                  width: cardWidth,
                  child: StatisticsCard(
                    title: 'Team ${form.teamId}',
                    value: '${form.formPercentage.toStringAsFixed(1)}',
                    unit: '%',
                    subtitle: 'Last ${form.recentMatches} matches: ${form.form}',
                    icon: Icons.trending_up,
                    trend: '${form.wins}W ${form.draws}D ${form.losses}L',
                    additionalStats: [
                      StatisticItem(
                        label: 'Goals For',
                        value: '${form.goalsFor}',
                      ),
                      StatisticItem(
                        label: 'Goals Against',
                        value: '${form.goalsAgainst}',
                      ),
                    ],
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildGoalDistributionChart(BuildContext context) {
    final goalDistribution = ref.watch(goalDistributionChartDataProvider);
    
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            goalDistribution.title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16.h),
          Expanded(
            child: Center(
              child: Text(
                'Goal Distribution Chart\n(Pie Chart Implementation)',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceRadarChart(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Performance Radar',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16.h),
          Expanded(
            child: Center(
              child: Text(
                'Performance Radar Chart\n(Requires specialized implementation)',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendAnalysisChart(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Trend Analysis',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16.h),
          Expanded(
            child: Center(
              child: Text(
                'Trend Analysis Chart\n(Area Chart Implementation)',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamComparisonSelector(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Team Comparison',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16.h),
          const Text('Select teams to compare their performance metrics'),
        ],
      ),
    );
  }

  Widget _buildComparisonCharts(BuildContext context) {
    return Container(
      height: 400.h,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
        ),
      ),
      child: Center(
        child: Text(
          'Team Comparison Charts\n(Side-by-side comparison implementation)',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
      ),
    );
  }

  void _onFiltersChanged() {
    final filter = ref.read(statisticsFilterProvider);
    ref.read(statisticsProvider.notifier).loadStatistics(filter: filter);
  }

  void _refreshData() {
    final filter = ref.read(statisticsFilterProvider);
    ref.read(statisticsProvider.notifier).refreshStatistics(filter);
  }

  void _onExportCompleted(String filePath) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Export completed: ${filePath.split('/').last}'),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  String _formatLastUpdated(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} minutes ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else {
      return '${difference.inDays} days ago';
    }
  }
}