import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:animations/animations.dart';

class StatisticsCard extends ConsumerWidget {
  final String title;
  final String value;
  final String? subtitle;
  final String? unit;
  final IconData? icon;
  final Color? color;
  final Color? backgroundColor;
  final String? trend;
  final TrendDirection? trendDirection;
  final VoidCallback? onTap;
  final Widget? child;
  final bool isLoading;
  final double? percentage;
  final List<StatisticItem>? additionalStats;

  const StatisticsCard({
    super.key,
    required this.title,
    required this.value,
    this.subtitle,
    this.unit,
    this.icon,
    this.color,
    this.backgroundColor,
    this.trend,
    this.trendDirection,
    this.onTap,
    this.child,
    this.isLoading = false,
    this.percentage,
    this.additionalStats,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return OpenContainer(
      transitionType: ContainerTransitionType.fade,
      openBuilder: (context, _) => StatisticsDetailPage(
        title: title,
        value: value,
        subtitle: subtitle,
        additionalStats: additionalStats ?? [],
      ),
      closedBuilder: (context, openContainer) => GestureDetector(
        onTap: onTap ?? openContainer,
        child: Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: backgroundColor ?? colorScheme.surface,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: colorScheme.outline.withOpacity(0.1),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: colorScheme.shadow.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  if (icon != null) ...[
                    Container(
                      padding: EdgeInsets.all(8.w),
                      decoration: BoxDecoration(
                        color: (color ?? colorScheme.primary).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Icon(
                        icon,
                        size: 20.sp,
                        color: color ?? colorScheme.primary,
                      ),
                    ),
                    SizedBox(width: 12.w),
                  ],
                  Expanded(
                    child: Text(
                      title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: colorScheme.onSurface.withOpacity(0.7),
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (trend != null && trendDirection != null)
                    _buildTrendIndicator(context),
                ],
              ),
              
              SizedBox(height: 12.h),
              
              // Main Value
              if (isLoading)
                _buildLoadingShimmer(context)
              else
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Flexible(
                      child: Text(
                        value,
                        style: theme.textTheme.headlineMedium?.copyWith(
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.bold,
                          fontSize: 28.sp,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (unit != null) ...[
                      SizedBox(width: 4.w),
                      Text(
                        unit!,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ],
                ),
              
              if (subtitle != null) ...[
                SizedBox(height: 4.h),
                Text(
                  subtitle!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.6),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              
              // Progress bar
              if (percentage != null) ...[
                SizedBox(height: 12.h),
                _buildProgressBar(context),
              ],
              
              // Custom child content
              if (child != null) ...[
                SizedBox(height: 12.h),
                child!,
              ],
              
              // Additional stats
              if (additionalStats != null && additionalStats!.isNotEmpty) ...[
                SizedBox(height: 12.h),
                _buildAdditionalStats(context),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTrendIndicator(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    Color trendColor;
    IconData trendIcon;
    
    switch (trendDirection!) {
      case TrendDirection.up:
        trendColor = Colors.green;
        trendIcon = Icons.trending_up;
        break;
      case TrendDirection.down:
        trendColor = Colors.red;
        trendIcon = Icons.trending_down;
        break;
      case TrendDirection.stable:
        trendColor = colorScheme.onSurface.withOpacity(0.6);
        trendIcon = Icons.trending_flat;
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: trendColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            trendIcon,
            size: 12.sp,
            color: trendColor,
          ),
          SizedBox(width: 4.w),
          Text(
            trend!,
            style: TextStyle(
              fontSize: 10.sp,
              color: trendColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Progress',
              style: TextStyle(
                fontSize: 12.sp,
                color: colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            Text(
              '${percentage!.toStringAsFixed(1)}%',
              style: TextStyle(
                fontSize: 12.sp,
                color: colorScheme.onSurface.withOpacity(0.8),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        SizedBox(height: 4.h),
        ClipRRect(
          borderRadius: BorderRadius.circular(2.r),
          child: LinearProgressIndicator(
            value: percentage! / 100,
            backgroundColor: colorScheme.outline.withOpacity(0.1),
            valueColor: AlwaysStoppedAnimation(color ?? colorScheme.primary),
            minHeight: 4.h,
          ),
        ),
      ],
    );
  }

  Widget _buildAdditionalStats(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Divider(
          color: colorScheme.outline.withOpacity(0.1),
          height: 1,
        ),
        SizedBox(height: 8.h),
        ...additionalStats!.map((stat) => Padding(
          padding: EdgeInsets.only(bottom: 4.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                stat.label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              Text(
                '${stat.value}${stat.unit ?? ''}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        )),
      ],
    );
  }

  Widget _buildLoadingShimmer(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Container(
      height: 28.h,
      width: 100.w,
      decoration: BoxDecoration(
        color: colorScheme.outline.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: const ShimmerLoading(),
    );
  }
}

// Compact version for grid layouts
class CompactStatisticsCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color? color;
  final VoidCallback? onTap;

  const CompactStatisticsCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(
            color: colorScheme.outline.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              size: 24.sp,
              color: color ?? colorScheme.primary,
            ),
            SizedBox(height: 8.h),
            Text(
              value,
              style: theme.textTheme.titleLarge?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.bold,
                fontSize: 20.sp,
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              title,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.6),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

// Statistics Detail Page (for expanded view)
class StatisticsDetailPage extends StatelessWidget {
  final String title;
  final String value;
  final String? subtitle;
  final List<StatisticItem> additionalStats;

  const StatisticsDetailPage({
    super.key,
    required this.title,
    required this.value,
    this.subtitle,
    required this.additionalStats,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: colorScheme.surface,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Main value display
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(24.w),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Column(
                children: [
                  Text(
                    value,
                    style: theme.textTheme.displayMedium?.copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (subtitle != null) ...[
                    SizedBox(height: 8.h),
                    Text(
                      subtitle!,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            if (additionalStats.isNotEmpty) ...[
              SizedBox(height: 24.h),
              Text(
                'Detailed Statistics',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16.h),
              ...additionalStats.map((stat) => Container(
                margin: EdgeInsets.only(bottom: 12.h),
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(
                    color: colorScheme.outline.withOpacity(0.1),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            stat.label,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          if (stat.description != null) ...[
                            SizedBox(height: 4.h),
                            Text(
                              stat.description!,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurface.withOpacity(0.6),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    Text(
                      '${stat.value}${stat.unit ?? ''}',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              )),
            ],
          ],
        ),
      ),
    );
  }
}

// Shimmer loading animation
class ShimmerLoading extends StatefulWidget {
  const ShimmerLoading({super.key});

  @override
  State<ShimmerLoading> createState() => _ShimmerLoadingState();
}

class _ShimmerLoadingState extends State<ShimmerLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = Tween(begin: -1.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                colorScheme.outline.withOpacity(0.1),
                colorScheme.outline.withOpacity(0.3),
                colorScheme.outline.withOpacity(0.1),
              ],
              stops: [
                (_animation.value - 1.0).clamp(0.0, 1.0),
                _animation.value.clamp(0.0, 1.0),
                (_animation.value + 1.0).clamp(0.0, 1.0),
              ],
            ),
          ),
        );
      },
    );
  }
}

// Data models
enum TrendDirection { up, down, stable }

class StatisticItem {
  final String label;
  final String value;
  final String? unit;
  final String? description;

  const StatisticItem({
    required this.label,
    required this.value,
    this.unit,
    this.description,
  });
}