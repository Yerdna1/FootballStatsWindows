import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_design_system.dart';

class StatisticsBar extends StatefulWidget {
  final double value; // Value between 0.0 and 1.0
  final Color color;
  final Color? backgroundColor;
  final double height;
  final double? width;
  final BorderRadius? borderRadius;
  final bool animated;
  final Duration animationDuration;
  final Curve animationCurve;
  final String? label;
  final String? valueText;
  final bool showPercentage;

  const StatisticsBar({
    super.key,
    required this.value,
    required this.color,
    this.backgroundColor,
    this.height = 8.0,
    this.width,
    this.borderRadius,
    this.animated = true,
    this.animationDuration = const Duration(milliseconds: 800),
    this.animationCurve = Curves.easeInOut,
    this.label,
    this.valueText,
    this.showPercentage = false,
  });

  @override
  State<StatisticsBar> createState() => _StatisticsBarState();
}

class _StatisticsBarState extends State<StatisticsBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _animation = Tween<double>(
      begin: 0.0,
      end: widget.value.clamp(0.0, 1.0),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.animationCurve,
    ));

    if (widget.animated) {
      _controller.forward();
    } else {
      _controller.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(StatisticsBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _animation = Tween<double>(
        begin: _animation.value,
        end: widget.value.clamp(0.0, 1.0),
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: widget.animationCurve,
      ));
      _controller.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null || widget.valueText != null || widget.showPercentage) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (widget.label != null)
                Text(
                  widget.label!,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              if (widget.valueText != null)
                Text(
                  widget.valueText!,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: widget.color,
                    fontWeight: FontWeight.w600,
                  ),
                )
              else if (widget.showPercentage)
                Text(
                  '${(widget.value * 100).round()}%',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: widget.color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
          AppDesignSystem.gapVertical4,
        ],
        AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return Container(
              width: widget.width,
              height: widget.height,
              decoration: BoxDecoration(
                color: widget.backgroundColor ?? AppColors.border,
                borderRadius: widget.borderRadius ?? 
                    BorderRadius.circular(widget.height / 2),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: _animation.value,
                child: Container(
                  decoration: BoxDecoration(
                    color: widget.color,
                    borderRadius: widget.borderRadius ?? 
                        BorderRadius.circular(widget.height / 2),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

/// Gradient statistics bar with enhanced visual effects
class GradientStatisticsBar extends StatefulWidget {
  final double value;
  final List<Color> gradientColors;
  final Color? backgroundColor;
  final double height;
  final double? width;
  final bool animated;
  final Duration animationDuration;
  final String? label;
  final String? valueText;
  final bool showGlow;

  const GradientStatisticsBar({
    super.key,
    required this.value,
    required this.gradientColors,
    this.backgroundColor,
    this.height = 12.0,
    this.width,
    this.animated = true,
    this.animationDuration = const Duration(milliseconds: 1000),
    this.label,
    this.valueText,
    this.showGlow = false,
  });

  @override
  State<GradientStatisticsBar> createState() => _GradientStatisticsBarState();
}

class _GradientStatisticsBarState extends State<GradientStatisticsBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _animation = Tween<double>(
      begin: 0.0,
      end: widget.value.clamp(0.0, 1.0),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    if (widget.animated) {
      _controller.forward();
    } else {
      _controller.value = 1.0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null || widget.valueText != null) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (widget.label != null)
                Text(
                  widget.label!,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              if (widget.valueText != null)
                Text(
                  widget.valueText!,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: widget.gradientColors.first,
                    fontWeight: FontWeight.w700,
                  ),
                ),
            ],
          ),
          AppDesignSystem.gapVertical8,
        ],
        AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return Container(
              width: widget.width,
              height: widget.height,
              decoration: BoxDecoration(
                color: widget.backgroundColor ?? AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(widget.height / 2),
                boxShadow: widget.showGlow && _animation.value > 0
                    ? [
                        BoxShadow(
                          color: widget.gradientColors.first.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Stack(
                children: [
                  FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: _animation.value,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: widget.gradientColors,
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(widget.height / 2),
                      ),
                    ),
                  ),
                  if (widget.showGlow && _animation.value > 0.7)
                    Positioned(
                      right: 0,
                      top: 0,
                      bottom: 0,
                      child: Container(
                        width: widget.height * 0.8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.white.withOpacity(0.6),
                              blurRadius: 4,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}

/// Comparison statistics bar showing two values
class ComparisonStatisticsBar extends StatefulWidget {
  final double value1;
  final double value2;
  final Color color1;
  final Color color2;
  final String? label1;
  final String? label2;
  final double height;
  final bool animated;
  final Duration animationDuration;

  const ComparisonStatisticsBar({
    super.key,
    required this.value1,
    required this.value2,
    required this.color1,
    required this.color2,
    this.label1,
    this.label2,
    this.height = 24.0,
    this.animated = true,
    this.animationDuration = const Duration(milliseconds: 1000),
  });

  @override
  State<ComparisonStatisticsBar> createState() => _ComparisonStatisticsBarState();
}

class _ComparisonStatisticsBarState extends State<ComparisonStatisticsBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation1;
  late Animation<double> _animation2;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    final total = widget.value1 + widget.value2;
    final normalizedValue1 = total > 0 ? widget.value1 / total : 0.0;
    final normalizedValue2 = total > 0 ? widget.value2 / total : 0.0;

    _animation1 = Tween<double>(
      begin: 0.0,
      end: normalizedValue1,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
    ));

    _animation2 = Tween<double>(
      begin: 0.0,
      end: normalizedValue2,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
    ));

    if (widget.animated) {
      _controller.forward();
    } else {
      _controller.value = 1.0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        if (widget.label1 != null || widget.label2 != null) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (widget.label1 != null)
                Text(
                  widget.label1!,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: widget.color1,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              if (widget.label2 != null)
                Text(
                  widget.label2!,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: widget.color2,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
          AppDesignSystem.gapVertical8,
        ],
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Container(
              height: widget.height,
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(widget.height / 2),
              ),
              child: Row(
                children: [
                  // Value 1 bar
                  Expanded(
                    flex: (_animation1.value * 100).round(),
                    child: Container(
                      decoration: BoxDecoration(
                        color: widget.color1,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(widget.height / 2),
                          bottomLeft: Radius.circular(widget.height / 2),
                          topRight: _animation2.value == 0 
                              ? Radius.circular(widget.height / 2)
                              : Radius.zero,
                          bottomRight: _animation2.value == 0 
                              ? Radius.circular(widget.height / 2)
                              : Radius.zero,
                        ),
                      ),
                    ),
                  ),
                  // Value 2 bar
                  Expanded(
                    flex: (_animation2.value * 100).round(),
                    child: Container(
                      decoration: BoxDecoration(
                        color: widget.color2,
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(widget.height / 2),
                          bottomRight: Radius.circular(widget.height / 2),
                          topLeft: _animation1.value == 0 
                              ? Radius.circular(widget.height / 2)
                              : Radius.zero,
                          bottomLeft: _animation1.value == 0 
                              ? Radius.circular(widget.height / 2)
                              : Radius.zero,
                        ),
                      ),
                    ),
                  ),
                  // Remaining space
                  if (_animation1.value + _animation2.value < 1.0)
                    Expanded(
                      flex: ((1.0 - _animation1.value - _animation2.value) * 100).round(),
                      child: const SizedBox(),
                    ),
                ],
              ),
            );
          },
        ),
        AppDesignSystem.gapVertical4,
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${widget.value1.toStringAsFixed(0)}',
              style: theme.textTheme.labelSmall?.copyWith(
                color: widget.color1,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '${widget.value2.toStringAsFixed(0)}',
              style: theme.textTheme.labelSmall?.copyWith(
                color: widget.color2,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }
}