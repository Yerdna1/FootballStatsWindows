import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_design_system.dart';

enum FormIndicatorSize { small, medium, large }

class FormIndicator extends StatelessWidget {
  final String form;
  final FormIndicatorSize size;
  final bool animated;
  final Duration animationDelay;

  const FormIndicator({
    super.key,
    required this.form,
    this.size = FormIndicatorSize.medium,
    this.animated = true,
    this.animationDelay = Duration.zero,
  });

  @override
  Widget build(BuildContext context) {
    final formResults = _parseForm(form);
    
    if (formResults.isEmpty) {
      return const SizedBox.shrink();
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: formResults
          .asMap()
          .entries
          .map((entry) => _buildFormResult(
                entry.value,
                entry.key,
                formResults.length,
              ))
          .toList(),
    );
  }

  List<String> _parseForm(String form) {
    // Parse form string (e.g., "WDLWW" -> ["W", "D", "L", "W", "W"])
    return form.toUpperCase().split('').where((char) {
      return ['W', 'D', 'L'].contains(char);
    }).toList();
  }

  Widget _buildFormResult(String result, int index, int total) {
    final resultColor = AppColors.getFormColor(result);
    final resultSize = _getResultSize();
    final spacing = _getSpacing();

    Widget resultWidget = Container(
      width: resultSize,
      height: resultSize,
      margin: EdgeInsets.only(
        right: index < total - 1 ? spacing : 0,
      ),
      decoration: BoxDecoration(
        color: resultColor,
        shape: BoxShape.circle,
        boxShadow: size == FormIndicatorSize.large
            ? [
                BoxShadow(
                  color: resultColor.withOpacity(0.3),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Center(
        child: Text(
          result,
          style: TextStyle(
            color: Colors.white,
            fontSize: _getFontSize(),
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );

    if (animated) {
      return AnimationConfiguration.staggeredList(
        position: index,
        duration: const Duration(milliseconds: 200),
        delay: animationDelay + Duration(milliseconds: index * 100),
        child: SlideAnimation(
          horizontalOffset: 20.0,
          child: FadeInAnimation(
            child: ScaleAnimation(
              scale: 0.8,
              child: resultWidget,
            ),
          ),
        ),
      );
    }

    return resultWidget;
  }

  double _getResultSize() {
    switch (size) {
      case FormIndicatorSize.small:
        return AppDesignSystem.formIndicatorSmall;
      case FormIndicatorSize.medium:
        return AppDesignSystem.formIndicatorSize;
      case FormIndicatorSize.large:
        return 32.0;
    }
  }

  double _getSpacing() {
    switch (size) {
      case FormIndicatorSize.small:
        return 3.0;
      case FormIndicatorSize.medium:
        return 4.0;
      case FormIndicatorSize.large:
        return 6.0;
    }
  }

  double _getFontSize() {
    switch (size) {
      case FormIndicatorSize.small:
        return 10.0;
      case FormIndicatorSize.medium:
        return 12.0;
      case FormIndicatorSize.large:
        return 14.0;
    }
  }
}

/// Enhanced form indicator with additional features
class DetailedFormIndicator extends StatelessWidget {
  final String form;
  final bool showLabels;
  final bool showPercentages;
  final VoidCallback? onTap;

  const DetailedFormIndicator({
    super.key,
    required this.form,
    this.showLabels = true,
    this.showPercentages = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final formResults = _parseForm(form);
    final stats = _calculateStats(formResults);

    return InkWell(
      onTap: onTap,
      borderRadius: AppDesignSystem.borderRadiusSmall,
      child: Container(
        padding: AppDesignSystem.paddingAll12,
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
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showLabels) ...[
              Text(
                'Recent Form',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              AppDesignSystem.gapVertical8,
            ],
            
            // Form visualization
            FormIndicator(
              form: form,
              size: FormIndicatorSize.large,
              animated: true,
            ),
            
            if (showPercentages && formResults.isNotEmpty) ...[
              AppDesignSystem.gapVertical12,
              _buildStatsRow(theme, stats, formResults.length),
            ],
          ],
        ),
      ),
    );
  }

  List<String> _parseForm(String form) {
    return form.toUpperCase().split('').where((char) {
      return ['W', 'D', 'L'].contains(char);
    }).toList();
  }

  Map<String, int> _calculateStats(List<String> formResults) {
    final stats = <String, int>{'W': 0, 'D': 0, 'L': 0};
    for (final result in formResults) {
      stats[result] = (stats[result] ?? 0) + 1;
    }
    return stats;
  }

  Widget _buildStatsRow(ThemeData theme, Map<String, int> stats, int total) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildStatItem(theme, 'W', stats['W']!, total, AppColors.formWin),
        _buildStatItem(theme, 'D', stats['D']!, total, AppColors.formDraw),
        _buildStatItem(theme, 'L', stats['L']!, total, AppColors.formLoss),
      ],
    );
  }

  Widget _buildStatItem(
    ThemeData theme,
    String label,
    int count,
    int total,
    Color color,
  ) {
    final percentage = total > 0 ? (count / total * 100).round() : 0;
    
    return Column(
      children: [
        Text(
          '$count',
          style: theme.textTheme.titleSmall?.copyWith(
            color: color,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          '$percentage%',
          style: theme.textTheme.labelSmall?.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

/// Animated form streak indicator
class FormStreakIndicator extends StatefulWidget {
  final String form;
  final bool showStreak;
  final Duration animationDuration;

  const FormStreakIndicator({
    super.key,
    required this.form,
    this.showStreak = true,
    this.animationDuration = const Duration(milliseconds: 1000),
  });

  @override
  State<FormStreakIndicator> createState() => _FormStreakIndicatorState();
}

class _FormStreakIndicatorState extends State<FormStreakIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    ));

    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final streak = _getCurrentStreak(widget.form);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: Container(
              padding: AppDesignSystem.paddingHorizontal12.add(AppDesignSystem.paddingVertical8),
              decoration: BoxDecoration(
                gradient: _getStreakGradient(streak),
                borderRadius: AppDesignSystem.borderRadiusLarge,
                boxShadow: [
                  BoxShadow(
                    color: _getStreakColor(streak).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _getStreakIcon(streak),
                    color: Colors.white,
                    size: AppDesignSystem.iconSmall,
                  ),
                  AppDesignSystem.gapHorizontal8,
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getStreakText(streak),
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: Colors.white.withOpacity(0.9),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        '${streak.count} ${streak.count == 1 ? 'game' : 'games'}',
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  FormStreak _getCurrentStreak(String form) {
    final formResults = form.toUpperCase().split('').where((char) {
      return ['W', 'D', 'L'].contains(char);
    }).toList();

    if (formResults.isEmpty) {
      return FormStreak(type: 'N', count: 0);
    }

    final latestResult = formResults.last;
    int count = 0;

    for (int i = formResults.length - 1; i >= 0; i--) {
      if (formResults[i] == latestResult) {
        count++;
      } else {
        break;
      }
    }

    return FormStreak(type: latestResult, count: count);
  }

  Color _getStreakColor(FormStreak streak) {
    switch (streak.type) {
      case 'W':
        return AppColors.formWin;
      case 'D':
        return AppColors.formDraw;
      case 'L':
        return AppColors.formLoss;
      default:
        return AppColors.statisticsNeutral;
    }
  }

  Gradient _getStreakGradient(FormStreak streak) {
    final color = _getStreakColor(streak);
    return LinearGradient(
      colors: [
        color,
        color.withOpacity(0.8),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  IconData _getStreakIcon(FormStreak streak) {
    switch (streak.type) {
      case 'W':
        return Icons.trending_up;
      case 'D':
        return Icons.trending_flat;
      case 'L':
        return Icons.trending_down;
      default:
        return Icons.help_outline;
    }
  }

  String _getStreakText(FormStreak streak) {
    switch (streak.type) {
      case 'W':
        return 'Win streak';
      case 'D':
        return 'Draw streak';
      case 'L':
        return 'Loss streak';
      default:
        return 'No streak';
    }
  }
}

class FormStreak {
  final String type;
  final int count;

  FormStreak({required this.type, required this.count});
}