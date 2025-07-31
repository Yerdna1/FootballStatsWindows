import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../data/models/chart_data_model.dart';
import '../../providers/chart_data_provider.dart';
import '../interactive_chart.dart';

class LeagueStandingsChart extends ConsumerWidget {
  final bool showTeamLogos;
  final bool showPoints;
  final bool showGoals;
  final int maxTeams;
  final VoidCallback? onTeamTap;

  const LeagueStandingsChart({
    super.key,
    this.showTeamLogos = true,
    this.showPoints = true,
    this.showGoals = false,
    this.maxTeams = 20,
    this.onTeamTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final standingsData = ref.watch(standingsChartDataProvider);
    
    if (standingsData.teams.isEmpty) {
      return _buildEmptyState(context);
    }

    return _buildStandingsChart(context, standingsData);
  }

  Widget _buildStandingsChart(
    BuildContext context,
    StandingsChartDataModel data,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final limitedTeams = data.teams.take(maxTeams).toList();

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.1),
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
          _buildHeader(context, data),
          
          SizedBox(height: 16.h),
          
          // Chart Type Toggle
          _buildChartTypeToggle(context),
          
          SizedBox(height: 16.h),
          
          // Chart Content
          Expanded(
            child: showPoints 
              ? _buildPointsChart(context, limitedTeams)
              : _buildTableView(context, limitedTeams),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, StandingsChartDataModel data) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                data.title,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (data.lastUpdated != null) ...[
                SizedBox(height: 4.h),
                Text(
                  'Updated: ${_formatLastUpdated(data.lastUpdated!)}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ],
          ),
        ),
        
        PopupMenuButton<String>(
          icon: Icon(Icons.more_vert, size: 20.sp),
          onSelected: _handleMenuAction,
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'fullscreen',
              child: Row(
                children: [
                  const Icon(Icons.fullscreen),
                  SizedBox(width: 8.w),
                  const Text('Full Screen'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'export',
              child: Row(
                children: [
                  const Icon(Icons.download),
                  SizedBox(width: 8.w),
                  const Text('Export'),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildChartTypeToggle(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      children: [
        _buildToggleButton(
          context,
          'Points',
          showPoints,
          () => {}, // Would need state management for this
        ),
        SizedBox(width: 8.w),
        _buildToggleButton(
          context,
          'Table',
          !showPoints,
          () => {}, // Would need state management for this
        ),
        const Spacer(),
        
        // Team count selector
        DropdownButton<int>(
          value: maxTeams,
          items: [10, 15, 20].map((count) => DropdownMenuItem(
            value: count,
            child: Text('Top $count'),
          )).toList(),
          onChanged: (value) {
            // Would need callback to parent
          },
          underline: const SizedBox(),
          style: theme.textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildToggleButton(
    BuildContext context,
    String label,
    bool isSelected,
    VoidCallback onTap,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: isSelected 
            ? colorScheme.primary.withOpacity(0.1)
            : Colors.transparent,
          borderRadius: BorderRadius.circular(6.r),
          border: Border.all(
            color: isSelected 
              ? colorScheme.primary
              : colorScheme.outline.withOpacity(0.3),
          ),
        ),
        child: Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(
            color: isSelected 
              ? colorScheme.primary
              : colorScheme.onSurface.withOpacity(0.7),
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildPointsChart(
    BuildContext context,
    List<StandingsBarDataModel> teams,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: teams.isNotEmpty ? teams.first.points * 1.1 : 100,
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            tooltipBgColor: colorScheme.inverseSurface,
            tooltipRoundedRadius: 8.r,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              if (groupIndex >= teams.length) return null;
              
              final team = teams[groupIndex];
              return BarTooltipItem(
                '${team.teamName}\n'
                'Position: ${team.position}\n'
                'Points: ${team.points.toInt()}\n'
                'W-D-L: ${team.wins.toInt()}-${team.draws.toInt()}-${team.losses.toInt()}',
                TextStyle(
                  color: colorScheme.onInverseSurface,
                  fontWeight: FontWeight.w500,
                  fontSize: 12.sp,
                ),
              );
            },
          ),
          touchCallback: (FlTouchEvent event, barTouchResponse) {
            if (event.isInterestedForInteractions &&
                barTouchResponse != null &&
                barTouchResponse.spot != null) {
              onTeamTap?.call();
            }
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= teams.length) {
                  return const Text('');
                }
                
                final team = teams[index];
                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (showTeamLogos && team.teamLogo.isNotEmpty) ...[
                        SizedBox(
                          width: 16.w,
                          height: 16.w,
                          child: CachedNetworkImage(
                            imageUrl: team.teamLogo,
                            placeholder: (context, url) => const CircularProgressIndicator(),
                            errorWidget: (context, url, error) => Icon(
                              Icons.sports_soccer,
                              size: 16.sp,
                            ),
                          ),
                        ),
                        SizedBox(height: 2.h),
                      ],
                      Text(
                        '${team.position}',
                        style: TextStyle(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.bold,
                          color: _getPositionColor(team.position),
                        ),
                      ),
                    ],
                  ),
                );
              },
              reservedSize: showTeamLogos ? 40.h : 20.h,
            ),
          ),
          leftTitles: AxisTitles(
            axisNameWidget: Text('Points'),
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40.w,
              interval: teams.isNotEmpty ? (teams.first.points / 5).ceil().toDouble() : 10,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: colorScheme.onSurface.withOpacity(0.6),
                  ),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: colorScheme.outline.withOpacity(0.1),
              strokeWidth: 1,
            );
          },
        ),
        barGroups: teams.asMap().entries.map((entry) {
          final index = entry.key;
          final team = entry.value;
          
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: team.points,
                color: team.color != null 
                  ? Color(int.parse(team.color!.substring(1), radix: 16) + 0xFF000000)
                  : _getPositionColor(team.position),
                width: 16.w,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTableView(
    BuildContext context,
    List<StandingsBarDataModel> teams,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SingleChildScrollView(
      child: Table(
        columnWidths: {
          0: FixedColumnWidth(40.w), // Position
          1: FlexColumnWidth(3), // Team
          2: FixedColumnWidth(50.w), // Points
          3: FixedColumnWidth(50.w), // W
          4: FixedColumnWidth(50.w), // D
          5: FixedColumnWidth(50.w), // L
          6: FixedColumnWidth(60.w), // GF-GA
        },
        children: [
          // Header
          TableRow(
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4.r),
            ),
            children: [
              _buildTableHeader(context, '#'),
              _buildTableHeader(context, 'Team'),
              _buildTableHeader(context, 'Pts'),
              _buildTableHeader(context, 'W'),
              _buildTableHeader(context, 'D'),
              _buildTableHeader(context, 'L'),
              _buildTableHeader(context, 'GF-GA'),
            ],
          ),
          
          // Teams
          ...teams.map((team) => TableRow(
            decoration: BoxDecoration(
              color: team.position <= 4 
                ? Colors.green.withOpacity(0.05)
                : team.position >= 18 
                  ? Colors.red.withOpacity(0.05)
                  : null,
            ),
            children: [
              _buildTableCell(
                context,
                '${team.position}',
                color: _getPositionColor(team.position),
                bold: true,
              ),
              _buildTeamCell(context, team),
              _buildTableCell(context, '${team.points.toInt()}', bold: true),
              _buildTableCell(context, '${team.wins.toInt()}'),
              _buildTableCell(context, '${team.draws.toInt()}'),
              _buildTableCell(context, '${team.losses.toInt()}'),
              _buildTableCell(
                context,
                '${team.goalsFor.toInt()}-${team.goalsAgainst.toInt()}',
              ),
            ],
          )),
        ],
      ),
    );
  }

  Widget _buildTableHeader(BuildContext context, String text) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 4.w),
      child: Text(
        text,
        style: theme.textTheme.labelMedium?.copyWith(
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildTableCell(
    BuildContext context,
    String text, {
    Color? color,
    bool bold = false,
  }) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 4.w),
      child: Text(
        text,
        style: theme.textTheme.bodySmall?.copyWith(
          color: color,
          fontWeight: bold ? FontWeight.bold : FontWeight.normal,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildTeamCell(BuildContext context, StandingsBarDataModel team) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 4.w),
      child: Row(
        children: [
          if (showTeamLogos && team.teamLogo.isNotEmpty) ...[
            SizedBox(
              width: 16.w,
              height: 16.w,
              child: CachedNetworkImage(
                imageUrl: team.teamLogo,
                placeholder: (context, url) => Icon(
                  Icons.sports_soccer,
                  size: 16.sp,
                ),
                errorWidget: (context, url, error) => Icon(
                  Icons.sports_soccer,
                  size: 16.sp,
                ),
              ),
            ),
            SizedBox(width: 8.w),
          ],
          Expanded(
            child: Text(
              team.teamName,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      height: 300.h,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.1),
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.leaderboard,
              size: 48.sp,
              color: colorScheme.onSurface.withOpacity(0.3),
            ),
            SizedBox(height: 16.h),
            Text(
              'No Standings Data',
              style: theme.textTheme.titleMedium?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Select a league to view standings',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.4),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Color _getPositionColor(int position) {
    if (position <= 4) return Colors.green; // Champions League
    if (position <= 6) return Colors.orange; // Europa League
    if (position >= 18) return Colors.red; // Relegation
    return Colors.grey; // Mid-table
  }

  String _formatLastUpdated(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'fullscreen':
        // Handle fullscreen
        break;
      case 'export':
        // Handle export
        break;
    }
  }
}