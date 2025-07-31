import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_design_system.dart';
import '../../../../features/authentication/presentation/providers/auth_provider.dart';
import '../../../../shared/providers/theme_provider.dart';
import '../../../../shared/widgets/dashboard/live_scores_ticker.dart';
import '../../../../shared/widgets/dashboard/performance_insights.dart';
import '../../../../shared/data/models/fixture_model.dart';
import '../widgets/dashboard_header.dart';
import '../widgets/quick_stats_card.dart';
import '../widgets/recent_matches_card.dart';
import '../widgets/favorite_teams_card.dart';
import '../widgets/trending_leagues_card.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('${AppConstants.appName} Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => context.push('/notifications'),
          ),
          IconButton(
            icon: const Icon(Icons.person_outlined),
            onPressed: () => context.push('/auth/profile'),
          ),
          IconButton(
            icon: Icon(ref.watch(themeModeProvider) == ThemeMode.dark 
                ? Icons.light_mode 
                : Icons.dark_mode),
            onPressed: () => ref.read(themeModeProvider.notifier).toggleTheme(),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // TODO: Implement refresh logic
          await Future.delayed(const Duration(seconds: 1));
        },
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: AppDesignSystem.getHorizontalPadding(context),
            vertical: AppDesignSystem.spacing16,
          ),
          child: AnimationLimiter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome Header
                AnimationConfiguration.staggeredList(
                  position: 0,
                  duration: AppDesignSystem.animationNormal,
                  child: SlideAnimation(
                    verticalOffset: 50.0,
                    child: FadeInAnimation(
                      child: DashboardHeader(user: user),
                    ),
                  ),
                ),
                
                AppDesignSystem.gapVertical24,
                
                // Live Scores Ticker
                AnimationConfiguration.staggeredList(
                  position: 1,
                  duration: AppDesignSystem.animationNormal,
                  child: SlideAnimation(
                    verticalOffset: 50.0,
                    child: FadeInAnimation(
                      child: LiveScoresTicker(
                        liveMatches: _getMockLiveMatches(),
                        onViewAllTap: () => context.push('/fixtures?filter=live'),
                      ),
                    ),
                  ),
                ),
                
                AppDesignSystem.gapVertical24,
                
                // Quick Stats Overview
                AnimationConfiguration.staggeredList(
                  position: 2,
                  duration: AppDesignSystem.animationNormal,
                  child: SlideAnimation(
                    verticalOffset: 50.0,
                    child: FadeInAnimation(
                      child: QuickStatsOverview(
                        title: 'Quick Stats',
                        stats: _getQuickStats(),
                      ),
                    ),
                  ),
                ),
                
                AppDesignSystem.gapVertical24,
                
                // Performance Insights
                AnimationConfiguration.staggeredList(
                  position: 3,
                  duration: AppDesignSystem.animationNormal,
                  child: SlideAnimation(
                    verticalOffset: 50.0,
                    child: FadeInAnimation(
                      child: PerformanceInsights(
                        insights: _getPerformanceInsights(),
                        onViewAllTap: () => context.push('/analytics'),
                      ),
                    ),
                  ),
                ),
                
                AppDesignSystem.gapVertical24,
                
                // Quick Actions
                AnimationConfiguration.staggeredList(
                  position: 4,
                  duration: AppDesignSystem.animationNormal,
                  child: SlideAnimation(
                    verticalOffset: 50.0,
                    child: FadeInAnimation(
                      child: _buildQuickActions(context),
                    ),
                  ),
                ),
                
                AppDesignSystem.gapVertical24,
                
                // Recent Matches
                AnimationConfiguration.staggeredList(
                  position: 5,
                  duration: AppDesignSystem.animationNormal,
                  child: SlideAnimation(
                    verticalOffset: 50.0,
                    child: FadeInAnimation(
                      child: const RecentMatchesCard(),
                    ),
                  ),
                ),
                
                AppDesignSystem.gapVertical24,
                
                // Favorite Teams (if user has any)
                if (user?.favoriteTeams?.isNotEmpty == true) ...[
                  AnimationConfiguration.staggeredList(
                    position: 6,
                    duration: AppDesignSystem.animationNormal,
                    child: SlideAnimation(
                      verticalOffset: 50.0,
                      child: FadeInAnimation(
                        child: const FavoriteTeamsCard(),
                      ),
                    ),
                  ),
                  AppDesignSystem.gapVertical24,
                ],
                
                // Trending Leagues
                AnimationConfiguration.staggeredList(
                  position: 7,
                  duration: AppDesignSystem.animationNormal,
                  child: SlideAnimation(
                    verticalOffset: 50.0,
                    child: FadeInAnimation(
                      child: TrendingLeagues(
                        leagues: _getTrendingLeagues(),
                        onViewAllTap: () => context.push('/leagues'),
                      ),
                    ),
                  ),
                ),
                
                AppDesignSystem.gapVertical24,
                
                // Quick Links
                AnimationConfiguration.staggeredList(
                  position: 8,
                  duration: AppDesignSystem.animationNormal,
                  child: SlideAnimation(
                    verticalOffset: 50.0,
                    child: FadeInAnimation(
                      child: _buildQuickLinks(context, theme),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quick Actions',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.5,
              children: [
                _buildActionButton(
                  context,
                  icon: Icons.sports_soccer,
                  label: 'Leagues',
                  color: AppColors.primary,
                  onTap: () => context.go('/leagues'),
                ),
                _buildActionButton(
                  context,
                  icon: Icons.group,
                  label: 'Teams',
                  color: AppColors.secondary,
                  onTap: () => context.go('/teams'),
                ),
                _buildActionButton(
                  context,
                  icon: Icons.calendar_today,
                  label: 'Fixtures',
                  color: AppColors.success,
                  onTap: () => context.go('/fixtures'),
                ),
                _buildActionButton(
                  context,
                  icon: Icons.favorite,
                  label: 'Favorites',
                  color: AppColors.error,
                  onTap: () => context.go('/favorites'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 32,
              color: color,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickLinks(BuildContext context, ThemeData theme) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            child: Text(
              'Quick Links',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.analytics_outlined),
            title: const Text('Analytics'),
            subtitle: const Text('View detailed statistics'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.go('/analytics'),
          ),
          ListTile(
            leading: const Icon(Icons.settings_outlined),
            title: const Text('Settings'),
            subtitle: const Text('Manage your preferences'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.go('/settings'),
          ),
          ListTile(
            leading: const Icon(Icons.info_outlined),
            title: const Text('About'),
            subtitle: const Text('App information'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: AppConstants.appName,
                applicationVersion: AppConstants.appVersion,
                applicationIcon: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppColors.primaryGradient,
                  ),
                  child: const Icon(
                    Icons.sports_soccer,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                children: [
                  const Text('A comprehensive football statistics application with real-time data and analytics.'),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  // Mock data methods for demonstration
  List<FixtureModel> _getMockLiveMatches() {
    return [
      // Add mock live matches here
      // This would typically come from a provider/repository
    ];
  }

  List<QuickStat> _getQuickStats() {
    return [
      QuickStat(
        label: 'Matches Today',
        value: '12',
        icon: Icons.sports_soccer,
        color: AppColors.primary,
        trend: TrendDirection.up,
        trendValue: 15.0,
      ),
      QuickStat(
        label: 'Live Matches',
        value: '3',
        icon: Icons.live_tv,
        color: AppColors.live,
      ),
      QuickStat(
        label: 'Favorite Teams',
        value: '5',
        icon: Icons.favorite,
        color: AppColors.error,
        trend: TrendDirection.stable,
      ),
      QuickStat(
        label: 'Leagues',
        value: '8',
        icon: Icons.emoji_events,
        color: AppColors.warning,
        trend: TrendDirection.up,
        trendValue: 12.5,
      ),
    ];
  }

  List<InsightData> _getPerformanceInsights() {
    return [
      InsightData(
        title: 'Match Activity',
        subtitle: 'Increased by 25% this week',
        description: 'More matches are being played compared to last week',
        value: '+25%',
        progress: 0.75,
        type: InsightType.positive,
      ),
      InsightData(
        title: 'Popular Leagues',
        subtitle: 'Premier League leading',
        description: 'Premier League has the most viewer engagement',
        value: '45%',
        progress: 0.45,
        type: InsightType.neutral,
      ),
      InsightData(
        title: 'Goal Average',
        subtitle: 'Slightly below average',
        description: 'Goals per match: 2.3 (average: 2.7)',
        value: '2.3',
        progress: 0.35,
        type: InsightType.warning,
      ),
    ];
  }

  List<TrendingLeague> _getTrendingLeagues() {
    return [
      TrendingLeague(name: 'Premier League', matchesCount: 4),
      TrendingLeague(name: 'La Liga', matchesCount: 3),
      TrendingLeague(name: 'Serie A', matchesCount: 2),
      TrendingLeague(name: 'Bundesliga', matchesCount: 3),
    ];
  }
}