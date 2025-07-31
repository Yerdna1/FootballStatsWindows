import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_design_system.dart';
import '../indicators/statistics_bar.dart';

class PerformanceInsights extends StatelessWidget {
  final List<InsightData> insights;
  final VoidCallback? onViewAllTap;

  const PerformanceInsights({
    super.key,
    required this.insights,
    this.onViewAllTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: AppDesignSystem.cardBorderRadius,
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: AppDesignSystem.paddingAll16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: AppDesignSystem.paddingAll8,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: AppDesignSystem.borderRadiusSmall,
                      ),
                      child: Icon(
                        Icons.insights,
                        color: AppColors.primary,
                        size: AppDesignSystem.iconMedium,
                      ),
                    ),
                    AppDesignSystem.gapHorizontal12,
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Performance Insights',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          'Key statistics and trends',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                if (onViewAllTap != null)
                  GestureDetector(
                    onTap: onViewAllTap,
                    child: Container(
                      padding: AppDesignSystem.paddingHorizontal12.add(AppDesignSystem.paddingVertical6),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceVariant,
                        borderRadius: AppDesignSystem.borderRadiusSmall,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'View All',
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          AppDesignSystem.gapHorizontal4,
                          Icon(
                            Icons.arrow_forward,
                            color: AppColors.primary,
                            size: AppDesignSystem.iconSmall,
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          
          // Insights List
          if (insights.isNotEmpty) ...[
            ...insights.asMap().entries.map((entry) {
              final index = entry.key;
              final insight = entry.value;
              
              return AnimationConfiguration.staggeredList(
                position: index,
                duration: AppDesignSystem.animationNormal,
                child: SlideAnimation(
                  verticalOffset: 30.0,
                  child: FadeInAnimation(
                    child: _InsightCard(insight: insight),
                  ),
                ),
              );
            }).toList(),
          ] else ...[
            _buildEmptyState(theme),
          ],
          
          AppDesignSystem.gapVertical16,
        ],
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Padding(
      padding: AppDesignSystem.paddingAll24,
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.insights_outlined,
              color: AppColors.textTertiary,
              size: AppDesignSystem.iconLarge,
            ),
            AppDesignSystem.gapVertical8,
            Text(
              'No insights available',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InsightCard extends StatelessWidget {
  final InsightData insight;

  const _InsightCard({required this.insight});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: AppDesignSystem.paddingHorizontal16.add(AppDesignSystem.paddingVertical4),
      padding: AppDesignSystem.paddingAll16,
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant.withOpacity(0.5),
        borderRadius: AppDesignSystem.borderRadiusSmall,
        border: Border.all(
          color: AppColors.border,
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 24,
                decoration: BoxDecoration(
                  color: _getInsightColor(insight.type),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              AppDesignSystem.gapHorizontal12,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      insight.title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (insight.subtitle != null) ...[
                      AppDesignSystem.gapVertical4,
                      Text(
                        insight.subtitle!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (insight.value != null)
                Container(
                  padding: AppDesignSystem.paddingHorizontal8.add(AppDesignSystem.paddingVertical4),
                  decoration: BoxDecoration(
                    color: _getInsightColor(insight.type).withOpacity(0.1),
                    borderRadius: AppDesignSystem.borderRadiusSmall,
                  ),
                  child: Text(
                    insight.value!,
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: _getInsightColor(insight.type),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
          
          if (insight.progress != null) ...[
            AppDesignSystem.gapVertical12,
            StatisticsBar(
              value: insight.progress!,
              color: _getInsightColor(insight.type),
              height: 6,
              animated: true,
              showPercentage: true,
            ),
          ],
          
          if (insight.description != null) ...[
            AppDesignSystem.gapVertical8,
            Text(
              insight.description!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _getInsightColor(InsightType type) {
    switch (type) {
      case InsightType.positive:
        return AppColors.success;
      case InsightType.negative:
        return AppColors.error;
      case InsightType.neutral:
        return AppColors.info;
      case InsightType.warning:
        return AppColors.warning;
    }
  }
}

/// Quick stats overview widget
class QuickStatsOverview extends StatelessWidget {
  final List<QuickStat> stats;
  final String? title;

  const QuickStatsOverview({
    super.key,
    required this.stats,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: AppDesignSystem.cardBorderRadius,
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Padding(
              padding: AppDesignSystem.paddingAll16,
              child: Text(
                title!,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
          
          Padding(
            padding: AppDesignSystem.paddingHorizontal16.add(AppDesignSystem.paddingBottom16),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: AppDesignSystem.getGridColumns(context),
                mainAxisSpacing: AppDesignSystem.spacing12,
                crossAxisSpacing: AppDesignSystem.spacing12,
                childAspectRatio: 2.5,
              ),
              itemCount: stats.length,
              itemBuilder: (context, index) {
                return AnimationConfiguration.staggeredGrid(
                  position: index,
                  duration: AppDesignSystem.animationNormal,
                  columnCount: AppDesignSystem.getGridColumns(context),
                  child: ScaleAnimation(
                    child: FadeInAnimation(
                      child: _QuickStatCard(stat: stats[index]),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickStatCard extends StatelessWidget {
  final QuickStat stat;

  const _QuickStatCard({required this.stat});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: AppDesignSystem.paddingAll12,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            stat.color.withOpacity(0.1),
            stat.color.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: AppDesignSystem.borderRadiusSmall,
        border: Border.all(
          color: stat.color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(
                stat.icon,
                color: stat.color,
                size: AppDesignSystem.iconMedium,
              ),
              if (stat.trend != null)
                Container(
                  padding: AppDesignSystem.paddingHorizontal6.add(AppDesignSystem.paddingVertical2),
                  decoration: BoxDecoration(
                    color: _getTrendColor(stat.trend!).withOpacity(0.1),
                    borderRadius: AppDesignSystem.borderRadiusSmall,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _getTrendIcon(stat.trend!),
                        color: _getTrendColor(stat.trend!),
                        size: 12,
                      ),
                      AppDesignSystem.gapHorizontal2,
                      Text(
                        '${stat.trendValue ?? ''}%',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: _getTrendColor(stat.trend!),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                stat.value,
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: stat.color,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                stat.label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getTrendColor(TrendDirection trend) {
    switch (trend) {
      case TrendDirection.up:
        return AppColors.success;
      case TrendDirection.down:
        return AppColors.error;
      case TrendDirection.stable:
        return AppColors.warning;
    }
  }

  IconData _getTrendIcon(TrendDirection trend) {
    switch (trend) {
      case TrendDirection.up:
        return Icons.trending_up;
      case TrendDirection.down:
        return Icons.trending_down;
      case TrendDirection.stable:
        return Icons.trending_flat;
    }
  }
}

/// Trending leagues widget
class TrendingLeagues extends StatelessWidget {
  final List<TrendingLeague> leagues;
  final VoidCallback? onViewAllTap;

  const TrendingLeagues({
    super.key,
    required this.leagues,
    this.onViewAllTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: AppDesignSystem.cardBorderRadius,
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: AppDesignSystem.paddingAll16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Trending Leagues',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (onViewAllTap != null)
                  GestureDetector(
                    onTap: onViewAllTap,
                    child: Text(
                      'View All',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          
          // Leagues List
          ...leagues.asMap().entries.map((entry) {
            final index = entry.key;
            final league = entry.value;
            
            return AnimationConfiguration.staggeredList(
              position: index,
              duration: AppDesignSystem.animationNormal,
              child: SlideAnimation(
                horizontalOffset: 50.0,
                child: FadeInAnimation(
                  child: _TrendingLeagueItem(league: league),
                ),
              ),
            );
          }).toList(),
          
          AppDesignSystem.gapVertical8,
        ],
      ),
    );
  }
}

class _TrendingLeagueItem extends StatelessWidget {
  final TrendingLeague league;

  const _TrendingLeagueItem({required this.league});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: AppDesignSystem.paddingHorizontal16.add(AppDesignSystem.paddingVertical4),
      padding: AppDesignSystem.paddingAll12,
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant.withOpacity(0.3),
        borderRadius: AppDesignSystem.borderRadiusSmall,
      ),
      child: Row(
        children: [
          // League Logo/Icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: AppDesignSystem.borderRadiusSmall,
            ),
            child: league.logoUrl != null
                ? ClipRRect(
                    borderRadius: AppDesignSystem.borderRadiusSmall,
                    child: Image.network(
                      league.logoUrl!,
                      width: 40,
                      height: 40,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Icon(
                        Icons.sports_soccer,
                        color: AppColors.primary,
                        size: AppDesignSystem.iconMedium,
                      ),
                    ),
                  )
                : Icon(
                    Icons.sports_soccer,
                    color: AppColors.primary,
                    size: AppDesignSystem.iconMedium,
                  ),
          ),
          
          AppDesignSystem.gapHorizontal12,
          
          // League Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  league.name,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                AppDesignSystem.gapVertical4,
                Text(
                  '${league.matchesCount} matches today',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          
          // Trending Indicator
          Container(
            padding: AppDesignSystem.paddingHorizontal8.add(AppDesignSystem.paddingVertical4),
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.1),
              borderRadius: AppDesignSystem.borderRadiusSmall,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.trending_up,
                  color: AppColors.success,
                  size: 16,
                ),
                AppDesignSystem.gapHorizontal4,
                Text(
                  'Hot',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: AppColors.success,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Data Models
class InsightData {
  final String title;
  final String? subtitle;
  final String? description;
  final String? value;
  final double? progress;
  final InsightType type;

  InsightData({
    required this.title,
    this.subtitle,
    this.description,
    this.value,
    this.progress,
    required this.type,
  });
}

enum InsightType { positive, negative, neutral, warning }

class QuickStat {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final TrendDirection? trend;
  final double? trendValue;

  QuickStat({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.trend,
    this.trendValue,
  });
}

enum TrendDirection { up, down, stable }

class TrendingLeague {
  final String name;
  final String? logoUrl;
  final int matchesCount;

  TrendingLeague({
    required this.name,
    this.logoUrl,
    required this.matchesCount,
  });
}