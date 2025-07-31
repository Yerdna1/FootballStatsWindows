import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_design_system.dart';
import '../../../shared/data/models/fixture_model.dart';
import '../../../shared/data/models/team_model.dart';
import '../indicators/live_indicator.dart';
import '../indicators/statistics_bar.dart';

enum MatchCardStyle { compact, standard, detailed, hero }

class MatchCard extends StatelessWidget {
  final FixtureModel fixture;
  final MatchCardStyle style;
  final VoidCallback? onTap;
  final bool showStats;
  final bool isHighlighted;
  final int? animationIndex;

  const MatchCard({
    super.key,
    required this.fixture,
    this.style = MatchCardStyle.standard,
    this.onTap,
    this.showStats = false,
    this.isHighlighted = false,
    this.animationIndex,
  });

  @override
  Widget build(BuildContext context) {
    Widget card = _buildCard(context);

    if (animationIndex != null) {
      return AnimationConfiguration.staggeredList(
        position: animationIndex!,
        duration: AppDesignSystem.animationNormal,
        child: SlideAnimation(
          verticalOffset: 30.0,
          child: FadeInAnimation(
            child: card,
          ),
        ),
      );
    }

    return card;
  }

  Widget _buildCard(BuildContext context) {
    final theme = Theme.of(context);
    final isLive = fixture.status == 'LIVE';
    final cardHeight = _getCardHeight();

    return Container(
      height: cardHeight,
      margin: AppDesignSystem.paddingAll8,
      decoration: BoxDecoration(
        borderRadius: AppDesignSystem.cardBorderRadius,
        gradient: isHighlighted
            ? LinearGradient(
                colors: [
                  AppColors.primary.withOpacity(0.1),
                  AppColors.primary.withOpacity(0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        border: Border.all(
          color: isLive
              ? AppColors.live
              : isHighlighted
                  ? AppColors.primary
                  : AppColors.border,
          width: isLive || isHighlighted ? 2 : 0.5,
        ),
        boxShadow: style == MatchCardStyle.hero
            ? AppColors.heroShadow
            : AppColors.cardShadow,
      ),
      child: Material(
        color: AppColors.cardBackground,
        borderRadius: AppDesignSystem.cardBorderRadius,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppDesignSystem.cardBorderRadius,
          child: _buildCardContent(context, theme),
        ),
      ),
    );
  }

  double _getCardHeight() {
    switch (style) {
      case MatchCardStyle.compact:
        return AppDesignSystem.matchCardCompactHeight;
      case MatchCardStyle.standard:
        return AppDesignSystem.matchCardHeight;
      case MatchCardStyle.detailed:
        return 160.0;
      case MatchCardStyle.hero:
        return 200.0;
    }
  }

  Widget _buildCardContent(BuildContext context, ThemeData theme) {
    switch (style) {
      case MatchCardStyle.compact:
        return _buildCompactContent(theme);
      case MatchCardStyle.standard:
        return _buildStandardContent(theme);
      case MatchCardStyle.detailed:
        return _buildDetailedContent(theme);
      case MatchCardStyle.hero:
        return _buildHeroContent(theme);
    }
  }

  Widget _buildCompactContent(ThemeData theme) {
    final isLive = fixture.status == 'LIVE';
    
    return Padding(
      padding: AppDesignSystem.paddingAll12,
      child: Row(
        children: [
          // Home Team
          Expanded(
            child: _buildTeamInfo(
              fixture.homeTeam,
              alignment: CrossAxisAlignment.start,
              logoSize: AppDesignSystem.teamLogoSize,
            ),
          ),
          
          // Score and Status
          Container(
            padding: AppDesignSystem.paddingHorizontal12,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isLive) ...[
                  LiveIndicator(size: LiveIndicatorSize.small),
                  AppDesignSystem.gapVertical4,
                ],
                if (fixture.score != null) ...[
                  Text(
                    '${fixture.score!.home} - ${fixture.score!.away}',
                    style: AppDesignSystem.scoreMedium.copyWith(
                      color: isLive ? AppColors.live : AppColors.textPrimary,
                    ),
                  ),
                ] else ...[
                  Text(
                    _formatMatchTime(),
                    style: AppDesignSystem.matchTime.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
                if (fixture.minute != null && isLive) ...[
                  AppDesignSystem.gapVertical4,
                  Text(
                    "${fixture.minute}'",
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: AppColors.live,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
          
          // Away Team
          Expanded(
            child: _buildTeamInfo(
              fixture.awayTeam,
              alignment: CrossAxisAlignment.end,
              logoSize: AppDesignSystem.teamLogoSize,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStandardContent(ThemeData theme) {
    final isLive = fixture.status == 'LIVE';
    
    return Padding(
      padding: AppDesignSystem.paddingAll16,
      child: Column(
        children: [
          // Header with competition and date
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (fixture.competition != null)
                Container(
                  padding: AppDesignSystem.paddingHorizontal8.add(AppDesignSystem.paddingVertical4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: AppDesignSystem.borderRadiusSmall,
                  ),
                  child: Text(
                    fixture.competition!,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              if (isLive)
                LiveIndicator(size: LiveIndicatorSize.medium)
              else
                Text(
                  _formatMatchDate(),
                  style: AppDesignSystem.matchTime.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
            ],
          ),
          
          AppDesignSystem.gapVertical16,
          
          // Teams and Score
          Row(
            children: [
              // Home Team
              Expanded(
                child: _buildTeamInfo(
                  fixture.homeTeam,
                  alignment: CrossAxisAlignment.start,
                  logoSize: AppDesignSystem.teamLogoLarge,
                ),
              ),
              
              // Score Section
              Container(
                padding: AppDesignSystem.paddingHorizontal16,
                child: Column(
                  children: [
                    if (fixture.score != null) ...[
                      Text(
                        '${fixture.score!.home} - ${fixture.score!.away}',
                        style: AppDesignSystem.scoreLarge.copyWith(
                          color: isLive ? AppColors.live : AppColors.textPrimary,
                        ),
                      ),
                      if (fixture.minute != null && isLive) ...[
                        AppDesignSystem.gapVertical4,
                        Text(
                          "${fixture.minute}'",
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: AppColors.live,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ] else ...[
                      Text(
                        'VS',
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: AppColors.textTertiary,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                      AppDesignSystem.gapVertical4,
                      Text(
                        _formatMatchTime(),
                        style: AppDesignSystem.matchTime.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ],
                ),
              ),
              
              // Away Team
              Expanded(
                child: _buildTeamInfo(
                  fixture.awayTeam,
                  alignment: CrossAxisAlignment.end,
                  logoSize: AppDesignSystem.teamLogoLarge,
                ),
              ),
            ],
          ),
          
          // Match Status
          if (fixture.status != null && fixture.status != 'SCHEDULED') ...[
            AppDesignSystem.gapVertical12,
            _buildMatchStatus(theme),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailedContent(ThemeData theme) {
    return Padding(
      padding: AppDesignSystem.paddingAll20,
      child: Column(
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (fixture.competition != null)
                Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: AppDesignSystem.borderRadiusSmall,
                      ),
                      child: const Icon(
                        Icons.sports_soccer,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                    AppDesignSystem.gapHorizontal8,
                    Text(
                      fixture.competition!,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              _buildMatchStatus(theme),
            ],
          ),
          
          AppDesignSystem.gapVertical20,
          
          // Teams and Score
          _buildStandardContent(theme),
          
          // Statistics (if available and showStats is true)
          if (showStats && fixture.statistics != null) ...[
            AppDesignSystem.gapVertical16,
            _buildMatchStatistics(theme),
          ],
        ],
      ),
    );
  }

  Widget _buildHeroContent(ThemeData theme) {
    final isLive = fixture.status == 'LIVE';
    
    return Container(
      decoration: BoxDecoration(
        borderRadius: AppDesignSystem.cardBorderRadius,
        gradient: isLive
            ? AppColors.liveGradient
            : AppColors.primaryGradient,
      ),
      child: Padding(
        padding: AppDesignSystem.paddingAll24,
        child: Column(
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (fixture.competition != null)
                  Container(
                    padding: AppDesignSystem.paddingHorizontal12.add(AppDesignSystem.paddingVertical6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: AppDesignSystem.borderRadiusSmall,
                    ),
                    child: Text(
                      fixture.competition!,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                if (isLive)
                  LiveIndicator(
                    size: LiveIndicatorSize.large,
                    color: Colors.white,
                  ),
              ],
            ),
            
            AppDesignSystem.gapVertical24,
            
            // Teams and Score
            Row(
              children: [
                // Home Team
                Expanded(
                  child: Column(
                    children: [
                      _buildHeroTeamLogo(fixture.homeTeam),
                      AppDesignSystem.gapVertical12,
                      Text(
                        fixture.homeTeam.name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                
                // Score
                Container(
                  padding: AppDesignSystem.paddingHorizontal20,
                  child: Column(
                    children: [
                      if (fixture.score != null) ...[
                        Text(
                          '${fixture.score!.home}',
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            height: 1.0,
                          ),
                        ),
                        Text(
                          '-',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w300,
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                        Text(
                          '${fixture.score!.away}',
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            height: 1.0,
                          ),
                        ),
                      ] else ...[
                        Text(
                          'VS',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w300,
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                        AppDesignSystem.gapVertical8,
                        Text(
                          _formatMatchTime(),
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: Colors.white.withOpacity(0.9),
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                      if (fixture.minute != null && isLive) ...[
                        AppDesignSystem.gapVertical8,
                        Container(
                          padding: AppDesignSystem.paddingHorizontal8.add(AppDesignSystem.paddingVertical4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: AppDesignSystem.borderRadiusSmall,
                          ),
                          child: Text(
                            "${fixture.minute}'",
                            style: theme.textTheme.labelMedium?.copyWith(
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
                      _buildHeroTeamLogo(fixture.awayTeam),
                      AppDesignSystem.gapVertical12,
                      Text(
                        fixture.awayTeam.name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
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
    );
  }

  Widget _buildTeamInfo(
    TeamModel team,
    CrossAxisAlignment alignment,
    double logoSize,
  ) {
    return Column(
      crossAxisAlignment: alignment,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildTeamLogo(team, logoSize),
        AppDesignSystem.gapVertical8,
        Text(
          team.shortName ?? team.name,
          style: AppDesignSystem.teamNameSmall,
          textAlign: alignment == CrossAxisAlignment.start
              ? TextAlign.left
              : alignment == CrossAxisAlignment.end
                  ? TextAlign.right
                  : TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildTeamLogo(TeamModel team, double size) {
    final teamColor = AppColors.getTeamColor(team.name);
    
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: teamColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: ClipOval(
        child: team.logo != null
            ? CachedNetworkImage(
                imageUrl: team.logo!,
                width: size,
                height: size,
                fit: BoxFit.cover,
                placeholder: (context, url) => _buildLogoPlaceholder(team, size),
                errorWidget: (context, url, error) => _buildLogoPlaceholder(team, size),
              )
            : _buildLogoPlaceholder(team, size),
      ),
    );
  }

  Widget _buildHeroTeamLogo(TeamModel team) {
    return Container(
      width: AppDesignSystem.teamLogoHero,
      height: AppDesignSystem.teamLogoHero,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipOval(
        child: team.logo != null
            ? CachedNetworkImage(
                imageUrl: team.logo!,
                width: AppDesignSystem.teamLogoHero,
                height: AppDesignSystem.teamLogoHero,
                fit: BoxFit.cover,
                placeholder: (context, url) => _buildHeroLogoPlaceholder(team),
                errorWidget: (context, url, error) => _buildHeroLogoPlaceholder(team),
              )
            : _buildHeroLogoPlaceholder(team),
      ),
    );
  }

  Widget _buildLogoPlaceholder(TeamModel team, double size) {
    final teamColor = AppColors.getTeamColor(team.name);
    
    return Container(
      width: size,
      height: size,
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
      child: Icon(
        Icons.sports_soccer,
        color: Colors.white,
        size: size * 0.5,
      ),
    );
  }

  Widget _buildHeroLogoPlaceholder(TeamModel team) {
    final teamColor = AppColors.getTeamColor(team.name);
    
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [
            teamColor.withOpacity(0.9),
            teamColor.withOpacity(0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Icon(
        Icons.sports_soccer,
        color: Colors.white,
        size: 32,
      ),
    );
  }

  Widget _buildMatchStatus(ThemeData theme) {
    Color statusColor;
    String statusText;

    switch (fixture.status) {
      case 'LIVE':
        statusColor = AppColors.live;
        statusText = 'LIVE';
        break;
      case 'FINISHED':
        statusColor = AppColors.success;
        statusText = 'FINISHED';
        break;
      case 'SCHEDULED':
        statusColor = AppColors.info;
        statusText = 'SCHEDULED';
        break;
      case 'POSTPONED':
        statusColor = AppColors.warning;
        statusText = 'POSTPONED';
        break;
      case 'CANCELLED':
        statusColor = AppColors.error;
        statusText = 'CANCELLED';
        break;
      default:
        statusColor = AppColors.textSecondary;
        statusText = fixture.status ?? 'UNKNOWN';
    }

    return Container(
      padding: AppDesignSystem.paddingHorizontal8.add(AppDesignSystem.paddingVertical4),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: AppDesignSystem.borderRadiusSmall,
        border: Border.all(
          color: statusColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Text(
        statusText,
        style: theme.textTheme.labelSmall?.copyWith(
          color: statusColor,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildMatchStatistics(ThemeData theme) {
    // This would be implemented based on the actual statistics model
    // For now, showing a placeholder
    return Container(
      padding: AppDesignSystem.paddingAll12,
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant.withOpacity(0.5),
        borderRadius: AppDesignSystem.borderRadiusSmall,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Match Statistics',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          AppDesignSystem.gapVertical8,
          // Add actual statistics here based on fixture.statistics
          Text(
            'Statistics will be displayed here when available',
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  String _formatMatchTime() {
    if (fixture.utcDate != null) {
      final matchTime = DateTime.parse(fixture.utcDate!);
      final now = DateTime.now();
      
      if (matchTime.difference(now).inDays == 0) {
        return '${matchTime.hour.toString().padLeft(2, '0')}:${matchTime.minute.toString().padLeft(2, '0')}';
      } else if (matchTime.difference(now).inDays == 1) {
        return 'Tomorrow';
      } else if (matchTime.difference(now).inDays > 1) {
        return '${matchTime.day}/${matchTime.month}';
      }
    }
    return 'TBD';
  }

  String _formatMatchDate() {
    if (fixture.utcDate != null) {
      final matchTime = DateTime.parse(fixture.utcDate!);
      return '${matchTime.day}/${matchTime.month}/${matchTime.year}';
    }
    return '';
  }
}