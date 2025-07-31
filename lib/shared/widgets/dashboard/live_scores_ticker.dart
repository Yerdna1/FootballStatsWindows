import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_design_system.dart';
import '../../../shared/data/models/fixture_model.dart';
import '../cards/match_card.dart';
import '../indicators/live_indicator.dart';

class LiveScoresTicker extends StatefulWidget {
  final List<FixtureModel> liveMatches;
  final VoidCallback? onMatchTap;
  final VoidCallback? onViewAllTap;
  final bool autoScroll;
  final Duration scrollDuration;

  const LiveScoresTicker({
    super.key,
    required this.liveMatches,
    this.onMatchTap,
    this.onViewAllTap,
    this.autoScroll = true,
    this.scrollDuration = const Duration(seconds: 10),
  });

  @override
  State<LiveScoresTicker> createState() => _LiveScoresTickerState();
}

class _LiveScoresTickerState extends State<LiveScoresTicker>
    with SingleTickerProviderStateMixin {
  late ScrollController _scrollController;
  late AnimationController _animationController;
  bool _isScrollingForward = true;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _animationController = AnimationController(
      duration: widget.scrollDuration,
      vsync: this,
    );

    if (widget.autoScroll && widget.liveMatches.isNotEmpty) {
      _startAutoScroll();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _startAutoScroll() {
    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _isScrollingForward = !_isScrollingForward;
        _animationController.reset();
        _animationController.forward();
      }
    });

    _animationController.addListener(() {
      if (_scrollController.hasClients) {
        final maxScroll = _scrollController.position.maxScrollExtent;
        final targetPosition = _isScrollingForward
            ? maxScroll * _animationController.value
            : maxScroll * (1 - _animationController.value);
        
        _scrollController.jumpTo(targetPosition);
      }
    });

    _animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (widget.liveMatches.isEmpty) {
      return _buildEmptyState(theme);
    }

    return Container(
      height: 180,
      decoration: BoxDecoration(
        gradient: AppColors.liveGradient,
        borderRadius: AppDesignSystem.cardBorderRadius,
        boxShadow: AppColors.elevatedCardShadow,
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: AppDesignSystem.paddingAll16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const LiveIndicator(
                      size: LiveIndicatorSize.medium,
                      color: Colors.white,
                      showText: false,
                    ),
                    AppDesignSystem.gapHorizontal8,
                    Text(
                      'Live Matches',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    AppDesignSystem.gapHorizontal8,
                    Container(
                      padding: AppDesignSystem.paddingHorizontal8.add(AppDesignSystem.paddingVertical4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: AppDesignSystem.borderRadiusSmall,
                      ),
                      child: Text(
                        '${widget.liveMatches.length}',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                if (widget.onViewAllTap != null)
                  GestureDetector(
                    onTap: widget.onViewAllTap,
                    child: Container(
                      padding: AppDesignSystem.paddingHorizontal12.add(AppDesignSystem.paddingVertical6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: AppDesignSystem.borderRadiusSmall,
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'View All',
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          AppDesignSystem.gapHorizontal4,
                          const Icon(
                            Icons.arrow_forward,
                            color: Colors.white,
                            size: AppDesignSystem.iconSmall,
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          
          // Scrollable matches
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              padding: AppDesignSystem.paddingHorizontal16,
              itemCount: widget.liveMatches.length,
              itemBuilder: (context, index) {
                return AnimationConfiguration.staggeredList(
                  position: index,
                  duration: AppDesignSystem.animationNormal,
                  child: SlideAnimation(
                    horizontalOffset: 50.0,
                    child: FadeInAnimation(
                      child: Container(
                        width: 280,
                        margin: EdgeInsets.only(
                          right: index < widget.liveMatches.length - 1 
                              ? AppDesignSystem.spacing12 
                              : 0,
                        ),
                        child: _LiveMatchCard(
                          fixture: widget.liveMatches[index],
                          onTap: widget.onMatchTap,
                        ),
                      ),
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

  Widget _buildEmptyState(ThemeData theme) {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant.withOpacity(0.5),
        borderRadius: AppDesignSystem.cardBorderRadius,
        border: Border.all(
          color: AppColors.border,
          width: 1,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.sports_soccer_outlined,
              color: AppColors.textTertiary,
              size: AppDesignSystem.iconLarge,
            ),
            AppDesignSystem.gapVertical8,
            Text(
              'No live matches at the moment',
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

class _LiveMatchCard extends StatelessWidget {
  final FixtureModel fixture;
  final VoidCallback? onTap;

  const _LiveMatchCard({
    required this.fixture,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: AppDesignSystem.borderRadiusSmall,
          border: Border.all(
            color: Colors.white.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Padding(
          padding: AppDesignSystem.paddingAll12,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Home Team
                  Expanded(
                    child: Column(
                      children: [
                        _buildTeamLogo(fixture.homeTeam.logo, fixture.homeTeam.name),
                        AppDesignSystem.gapVertical8,
                        Text(
                          fixture.homeTeam.shortName ?? fixture.homeTeam.name,
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  
                  // Score and Time
                  Container(
                    padding: AppDesignSystem.paddingHorizontal12,
                    child: Column(
                      children: [
                        if (fixture.score != null) ...[
                          Text(
                            '${fixture.score!.home} - ${fixture.score!.away}',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ] else ...[
                          Text(
                            'VS',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: Colors.white.withOpacity(0.8),
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                        ],
                        if (fixture.minute != null) ...[
                          AppDesignSystem.gapVertical4,
                          Container(
                            padding: AppDesignSystem.paddingHorizontal6.add(AppDesignSystem.paddingVertical2),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: AppDesignSystem.borderRadiusSmall,
                            ),
                            child: Text(
                              "${fixture.minute}'",
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  
                  // Away Team
                  Expanded(
                    child: Column(
                      children: [
                        _buildTeamLogo(fixture.awayTeam.logo, fixture.awayTeam.name),
                        AppDesignSystem.gapVertical8,
                        Text(
                          fixture.awayTeam.shortName ?? fixture.awayTeam.name,
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTeamLogo(String? logoUrl, String teamName) {
    final teamColor = AppColors.getTeamColor(teamName);
    
    return Container(
      width: AppDesignSystem.teamLogoSize,
      height: AppDesignSystem.teamLogoSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: ClipOval(
        child: logoUrl != null
            ? Image.network(
                logoUrl,
                width: AppDesignSystem.teamLogoSize,
                height: AppDesignSystem.teamLogoSize,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => _buildLogoPlaceholder(teamColor),
              )
            : _buildLogoPlaceholder(teamColor),
      ),
    );
  }

  Widget _buildLogoPlaceholder(Color teamColor) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [
            teamColor.withOpacity(0.8),
            teamColor.withOpacity(0.6),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Icon(
        Icons.sports_soccer,
        color: Colors.white,
        size: 16,
      ),
    );
  }
}

/// Compact live scores ticker for smaller spaces
class CompactLiveScoresTicker extends StatelessWidget {
  final List<FixtureModel> liveMatches;
  final VoidCallback? onTap;

  const CompactLiveScoresTicker({
    super.key,
    required this.liveMatches,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (liveMatches.isEmpty) {
      return const SizedBox.shrink();
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 40,
        padding: AppDesignSystem.paddingHorizontal16,
        decoration: BoxDecoration(
          gradient: AppColors.liveGradient,
          borderRadius: AppDesignSystem.borderRadiusSmall,
        ),
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: liveMatches.length,
          separatorBuilder: (context, index) => Container(
            width: 1,
            margin: AppDesignSystem.paddingHorizontal8,
            color: Colors.white.withOpacity(0.3),
          ),
          itemBuilder: (context, index) {
            final match = liveMatches[index];
            return Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    match.homeTeam.shortName ?? match.homeTeam.name,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  AppDesignSystem.gapHorizontal4,
                  if (match.score != null)
                    Text(
                      '${match.score!.home}-${match.score!.away}',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    )
                  else
                    Text(
                      'vs',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                  AppDesignSystem.gapHorizontal4,
                  Text(
                    match.awayTeam.shortName ?? match.awayTeam.name,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (match.minute != null) ...[
                    AppDesignSystem.gapHorizontal4,
                    Text(
                      "${match.minute}'",
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: Colors.white.withOpacity(0.9),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}