import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_design_system.dart';

enum LiveIndicatorSize { small, medium, large }

class LiveIndicator extends StatefulWidget {
  final LiveIndicatorSize size;
  final Color? color;
  final bool showText;
  final String? customText;
  final bool animated;

  const LiveIndicator({
    super.key,
    this.size = LiveIndicatorSize.medium,
    this.color,
    this.showText = true,
    this.customText,
    this.animated = true,
  });

  @override
  State<LiveIndicator> createState() => _LiveIndicatorState();
}

class _LiveIndicatorState extends State<LiveIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    
    if (widget.animated) {
      _controller = AnimationController(
        duration: const Duration(milliseconds: 1000),
        vsync: this,
      );

      _scaleAnimation = Tween<double>(
        begin: 1.0,
        end: AppDesignSystem.liveIndicatorPulseScale,
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ));

      _opacityAnimation = Tween<double>(
        begin: 1.0,
        end: 0.3,
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ));

      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    if (widget.animated) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final indicatorColor = widget.color ?? AppColors.live;
    final theme = Theme.of(context);

    if (!widget.animated) {
      return _buildStaticIndicator(theme, indicatorColor);
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Transform.scale(
              scale: _scaleAnimation.value,
              child: Opacity(
                opacity: _opacityAnimation.value,
                child: Container(
                  width: _getIndicatorSize(),
                  height: _getIndicatorSize(),
                  decoration: AppDesignSystem.liveIndicatorDecoration(indicatorColor),
                ),
              ),
            ),
            if (widget.showText) ...[
              AppDesignSystem.gapHorizontal8,
              Text(
                widget.customText ?? 'LIVE',
                style: _getTextStyle(theme, indicatorColor),
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _buildStaticIndicator(ThemeData theme, Color indicatorColor) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: _getIndicatorSize(),
          height: _getIndicatorSize(),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: indicatorColor,
          ),
        ),
        if (widget.showText) ...[
          AppDesignSystem.gapHorizontal8,
          Text(
            widget.customText ?? 'LIVE',
            style: _getTextStyle(theme, indicatorColor),
          ),
        ],
      ],
    );
  }

  double _getIndicatorSize() {
    switch (widget.size) {
      case LiveIndicatorSize.small:
        return 6.0;
      case LiveIndicatorSize.medium:
        return AppDesignSystem.liveIndicatorSize;
      case LiveIndicatorSize.large:
        return 12.0;
    }
  }

  TextStyle _getTextStyle(ThemeData theme, Color color) {
    switch (widget.size) {
      case LiveIndicatorSize.small:
        return theme.textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ) ??
            const TextStyle();
      case LiveIndicatorSize.medium:
        return theme.textTheme.labelMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ) ??
            const TextStyle();
      case LiveIndicatorSize.large:
        return theme.textTheme.titleSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ) ??
            const TextStyle();
    }
  }
}

/// Enhanced live indicator with background and more styling options
class EnhancedLiveIndicator extends StatefulWidget {
  final LiveIndicatorSize size;
  final Color? color;
  final String? text;
  final bool showBackground;
  final VoidCallback? onTap;

  const EnhancedLiveIndicator({
    super.key,
    this.size = LiveIndicatorSize.medium,
    this.color,
    this.text,
    this.showBackground = true,
    this.onTap,
  });

  @override
  State<EnhancedLiveIndicator> createState() => _EnhancedLiveIndicatorState();
}

class _EnhancedLiveIndicatorState extends State<EnhancedLiveIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulseAnimation;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    final indicatorColor = widget.color ?? AppColors.live;

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.3,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _colorAnimation = ColorTween(
      begin: indicatorColor,
      end: indicatorColor.withOpacity(0.6),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final indicatorColor = widget.color ?? AppColors.live;

    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Container(
            padding: widget.showBackground
                ? AppDesignSystem.paddingHorizontal12.add(AppDesignSystem.paddingVertical6)
                : EdgeInsets.zero,
            decoration: widget.showBackground
                ? BoxDecoration(
                    color: AppColors.liveBackground,
                    borderRadius: AppDesignSystem.borderRadiusLarge,
                    border: Border.all(
                      color: _colorAnimation.value ?? indicatorColor,
                      width: 1,
                    ),
                  )
                : null,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    // Pulse effect
                    Transform.scale(
                      scale: _pulseAnimation.value,
                      child: Container(
                        width: _getIndicatorSize() * 1.5,
                        height: _getIndicatorSize() * 1.5,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: (_colorAnimation.value ?? indicatorColor).withOpacity(0.3),
                        ),
                      ),
                    ),
                    // Main indicator
                    Container(
                      width: _getIndicatorSize(),
                      height: _getIndicatorSize(),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _colorAnimation.value ?? indicatorColor,
                        boxShadow: [
                          BoxShadow(
                            color: (_colorAnimation.value ?? indicatorColor).withOpacity(0.5),
                            blurRadius: 4,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (widget.text != null) ...[
                  AppDesignSystem.gapHorizontal8,
                  Text(
                    widget.text!,
                    style: _getTextStyle(theme, indicatorColor),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  double _getIndicatorSize() {
    switch (widget.size) {
      case LiveIndicatorSize.small:
        return 8.0;
      case LiveIndicatorSize.medium:
        return 10.0;
      case LiveIndicatorSize.large:
        return 14.0;
    }
  }

  TextStyle _getTextStyle(ThemeData theme, Color color) {
    switch (widget.size) {
      case LiveIndicatorSize.small:
        return theme.textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
            ) ??
            const TextStyle();
      case LiveIndicatorSize.medium:
        return theme.textTheme.labelMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
            ) ??
            const TextStyle();
      case LiveIndicatorSize.large:
        return theme.textTheme.titleSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
            ) ??
            const TextStyle();
    }
  }
}

/// Live match timer widget
class LiveMatchTimer extends StatefulWidget {
  final int currentMinute;
  final bool isPaused;
  final VoidCallback? onTap;

  const LiveMatchTimer({
    super.key,
    required this.currentMinute,
    this.isPaused = false,
    this.onTap,
  });

  @override
  State<LiveMatchTimer> createState() => _LiveMatchTimerState();
}

class _LiveMatchTimerState extends State<LiveMatchTimer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _blinkAnimation;

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _blinkAnimation = Tween<double>(
      begin: 1.0,
      end: 0.3,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    if (!widget.isPaused) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(LiveMatchTimer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isPaused != widget.isPaused) {
      if (widget.isPaused) {
        _controller.stop();
        _controller.value = 1.0;
      } else {
        _controller.repeat(reverse: true);
      }
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

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        padding: AppDesignSystem.paddingHorizontal16.add(AppDesignSystem.paddingVertical8),
        decoration: BoxDecoration(
          gradient: AppColors.liveGradient,
          borderRadius: AppDesignSystem.borderRadiusLarge,
          boxShadow: [
            BoxShadow(
              color: AppColors.live.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: AnimatedBuilder(
          animation: _blinkAnimation,
          builder: (context, child) {
            return Opacity(
              opacity: widget.isPaused ? 1.0 : _blinkAnimation.value,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                  ),
                  AppDesignSystem.gapHorizontal8,
                  Text(
                    "${widget.currentMinute}'",
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                  AppDesignSystem.gapHorizontal4,
                  Text(
                    'LIVE',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: Colors.white.withOpacity(0.9),
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.0,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Match status indicator for different match states
class MatchStatusIndicator extends StatelessWidget {
  final String status;
  final Color? customColor;
  final bool showIcon;

  const MatchStatusIndicator({
    super.key,
    required this.status,
    this.customColor,
    this.showIcon = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusData = _getStatusData(status);

    return Container(
      padding: AppDesignSystem.paddingHorizontal8.add(AppDesignSystem.paddingVertical4),
      decoration: BoxDecoration(
        color: (customColor ?? statusData.color).withOpacity(0.1),
        borderRadius: AppDesignSystem.borderRadiusSmall,
        border: Border.all(
          color: (customColor ?? statusData.color).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showIcon && statusData.icon != null) ...[
            Icon(
              statusData.icon,
              size: AppDesignSystem.iconSmall,
              color: customColor ?? statusData.color,
            ),
            AppDesignSystem.gapHorizontal4,
          ],
          Text(
            statusData.displayText,
            style: theme.textTheme.labelSmall?.copyWith(
              color: customColor ?? statusData.color,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  _StatusData _getStatusData(String status) {
    switch (status.toUpperCase()) {
      case 'LIVE':
        return _StatusData(
          color: AppColors.live,
          displayText: 'LIVE',
          icon: Icons.radio_button_checked,
        );
      case 'FINISHED':
        return _StatusData(
          color: AppColors.success,
          displayText: 'FINISHED',
          icon: Icons.check_circle_outline,
        );
      case 'SCHEDULED':
        return _StatusData(
          color: AppColors.info,
          displayText: 'SCHEDULED',
          icon: Icons.schedule,
        );
      case 'POSTPONED':
        return _StatusData(
          color: AppColors.warning,
          displayText: 'POSTPONED',
          icon: Icons.pause_circle_outline,
        );
      case 'CANCELLED':
        return _StatusData(
          color: AppColors.error,
          displayText: 'CANCELLED',
          icon: Icons.cancel_outlined,
        );
      case 'HALFTIME':
        return _StatusData(
          color: AppColors.warning,
          displayText: 'HALF TIME',
          icon: Icons.pause,
        );
      default:
        return _StatusData(
          color: AppColors.textSecondary,
          displayText: status,
          icon: Icons.help_outline,
        );
    }
  }
}

class _StatusData {
  final Color color;
  final String displayText;
  final IconData? icon;

  _StatusData({
    required this.color,
    required this.displayText,
    this.icon,
  });
}