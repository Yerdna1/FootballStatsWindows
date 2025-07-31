import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_design_system.dart';
import '../../../shared/data/models/team_model.dart';
import '../indicators/form_indicator.dart';
import '../indicators/statistics_bar.dart';

enum TeamCardSize { compact, standard, detailed }

class TeamCard extends StatelessWidget {
  final TeamModel team;
  final TeamCardSize size;
  final VoidCallback? onTap;
  final bool showStats;
  final bool showForm;
  final bool isSelected;
  final int? animationIndex;

  const TeamCard({
    super.key,
    required this.team,
    this.size = TeamCardSize.standard,
    this.onTap,
    this.showStats = true,
    this.showForm = true,
    this.isSelected = false,
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
          verticalOffset: 50.0,
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
    final teamColor = AppColors.getTeamColor(team.name);

    return Container(
      height: _getCardHeight(),
      decoration: BoxDecoration(
        borderRadius: AppDesignSystem.cardBorderRadius,
        gradient: isSelected
            ? LinearGradient(
                colors: [
                  teamColor.withOpacity(0.1),
                  teamColor.withOpacity(0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        border: Border.all(
          color: isSelected ? teamColor : AppColors.border,
          width: isSelected ? 2 : 0.5,
        ),
        boxShadow: AppColors.cardShadow,
      ),
      child: Material(
        color: AppColors.cardBackground,
        borderRadius: AppDesignSystem.cardBorderRadius,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppDesignSystem.cardBorderRadius,
          child: _buildCardContent(context, theme, teamColor),
        ),
      ),
    );
  }

  double _getCardHeight() {
    switch (size) {
      case TeamCardSize.compact:
        return 80.0;
      case TeamCardSize.standard:
        return AppDesignSystem.teamCardHeight;
      case TeamCardSize.detailed:
        return 200.0;
    }
  }

  Widget _buildCardContent(BuildContext context, ThemeData theme, Color teamColor) {
    switch (size) {
      case TeamCardSize.compact:
        return _buildCompactContent(theme, teamColor);
      case TeamCardSize.standard:
        return _buildStandardContent(theme, teamColor);
      case TeamCardSize.detailed:
        return _buildDetailedContent(theme, teamColor);
    }
  }

  Widget _buildCompactContent(ThemeData theme, Color teamColor) {
    return Padding(
      padding: AppDesignSystem.paddingAll12,
      child: Row(
        children: [
          // Team Logo
          _buildTeamLogo(AppDesignSystem.teamLogoSize, teamColor),
          AppDesignSystem.gapHorizontal12,
          
          // Team Name and Position
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  team.name,
                  style: AppDesignSystem.teamNameSmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (team.position != null) ...[
                  AppDesignSystem.gapVertical4,
                  Text(
                    'Position: ${team.position}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          
          // Points or Form
          if (showForm && team.form?.isNotEmpty == true)
            FormIndicator(
              form: team.form!,
              size: FormIndicatorSize.small,
            )
          else if (team.points != null)
            Container(
              padding: AppDesignSystem.paddingHorizontal8.add(AppDesignSystem.paddingVertical4),
              decoration: BoxDecoration(
                color: teamColor.withOpacity(0.1),
                borderRadius: AppDesignSystem.borderRadiusSmall,
              ),
              child: Text(
                '${team.points}',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: teamColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStandardContent(ThemeData theme, Color teamColor) {
    return Padding(
      padding: AppDesignSystem.paddingAll16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            children: [
              _buildTeamLogo(AppDesignSystem.teamLogoLarge, teamColor),
              AppDesignSystem.gapHorizontal16,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      team.name,
                      style: AppDesignSystem.teamName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (team.shortName != null && team.shortName != team.name) ...[
                      AppDesignSystem.gapVertical4,
                      Text(
                        team.shortName!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (team.position != null)
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.getPositionColor(team.position!, 20),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${team.position}',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          
          AppDesignSystem.gapVertical16,
          
          // Statistics Row
          if (showStats) ...[
            Row(
              children: [
                _buildStatItem(theme, 'Points', team.points?.toString() ?? '0'),
                AppDesignSystem.gapHorizontal16,
                _buildStatItem(theme, 'Played', team.played?.toString() ?? '0'),
                AppDesignSystem.gapHorizontal16,
                _buildStatItem(theme, 'Goal Diff', _formatGoalDifference(team.goalDifference)),
              ],
            ),
            AppDesignSystem.gapVertical12,
          ],
          
          // Form Indicator
          if (showForm && team.form?.isNotEmpty == true) ...[
            Row(
              children: [
                Text(
                  'Form',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                AppDesignSystem.gapHorizontal8,
                FormIndicator(
                  form: team.form!,
                  size: FormIndicatorSize.medium,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailedContent(ThemeData theme, Color teamColor) {
    return Padding(
      padding: AppDesignSystem.paddingAll20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with team info
          Row(
            children: [
              _buildTeamLogo(AppDesignSystem.teamLogoHero, teamColor),
              AppDesignSystem.gapHorizontal20,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      team.name,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (team.venue != null) ...[
                      AppDesignSystem.gapVertical4,
                      Row(
                        children: [
                          Icon(
                            Icons.stadium_outlined,
                            size: AppDesignSystem.iconSmall,
                            color: AppColors.textSecondary,
                          ),
                          AppDesignSystem.gapHorizontal4,
                          Expanded(
                            child: Text(
                              team.venue!,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          
          AppDesignSystem.gapVertical20,
          
          // Detailed Statistics
          if (showStats) ...[
            _buildDetailedStats(theme),
            AppDesignSystem.gapVertical16,
          ],
          
          // Form and Recent Performance
          if (showForm && team.form?.isNotEmpty == true) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Recent Form',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    AppDesignSystem.gapVertical8,
                    FormIndicator(
                      form: team.form!,
                      size: FormIndicatorSize.large,
                    ),
                  ],
                ),
                if (team.position != null)
                  Column(
                    children: [
                      Text(
                        'Position',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      AppDesignSystem.gapVertical8,
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.getPositionColor(team.position!, 20),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.getPositionColor(team.position!, 20).withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            '${team.position}',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTeamLogo(double size, Color teamColor) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: teamColor.withOpacity(0.2),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: teamColor.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipOval(
        child: team.logo != null
            ? CachedNetworkImage(
                imageUrl: team.logo!,
                width: size,
                height: size,
                fit: BoxFit.cover,
                placeholder: (context, url) => _buildLogoPlaceholder(size, teamColor),
                errorWidget: (context, url, error) => _buildLogoPlaceholder(size, teamColor),
              )
            : _buildLogoPlaceholder(size, teamColor),
      ),
    );
  }

  Widget _buildLogoPlaceholder(double size, Color teamColor) {
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

  Widget _buildStatItem(ThemeData theme, String label, String value) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          AppDesignSystem.gapVertical4,
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedStats(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Season Statistics',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        AppDesignSystem.gapVertical12,
        Row(
          children: [
            Expanded(
              child: _buildStatProgress(
                theme,
                'Wins',
                team.wins ?? 0,
                team.played ?? 1,
                AppColors.win,
              ),
            ),
            AppDesignSystem.gapHorizontal16,
            Expanded(
              child: _buildStatProgress(
                theme,
                'Draws',
                team.draws ?? 0,
                team.played ?? 1,
                AppColors.draw,
              ),
            ),
            AppDesignSystem.gapHorizontal16,
            Expanded(
              child: _buildStatProgress(
                theme,
                'Losses',
                team.losses ?? 0,
                team.played ?? 1,
                AppColors.loss,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatProgress(
    ThemeData theme,
    String label,
    int value,
    int total,
    Color color,
  ) {
    final percentage = total > 0 ? value / total : 0.0;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '$value',
              style: theme.textTheme.labelSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        AppDesignSystem.gapVertical4,
        StatisticsBar(
          value: percentage,
          color: color,
          height: AppDesignSystem.statisticsBarHeight,
        ),
      ],
    );
  }

  String _formatGoalDifference(int? goalDiff) {
    if (goalDiff == null) return '0';
    if (goalDiff > 0) return '+$goalDiff';
    return goalDiff.toString();
  }
}