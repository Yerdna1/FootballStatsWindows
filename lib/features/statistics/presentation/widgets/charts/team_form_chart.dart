import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../data/models/chart_data_model.dart';
import '../../providers/chart_data_provider.dart';

class TeamFormChart extends ConsumerStatefulWidget {
  final bool showMultipleTeams;
  final bool showTrendLines;
  final int maxMatches;
  final List<int>? specificTeamIds;
  final Function(int?)? onTeamSelected;

  const TeamFormChart({
    super.key,
    this.showMultipleTeams = true,
    this.showTrendLines = true,
    this.maxMatches = 10,
    this.specificTeamIds,
    this.onTeamSelected,
  });

  @override
  ConsumerState<TeamFormChart> createState() => _TeamFormChartState();
}

class _TeamFormChartState extends ConsumerState<TeamFormChart> {
  List<bool> _teamVisibility = [];
  int? _selectedTeamIndex;
  bool _showTrendLines = true;
  FormViewType _viewType = FormViewType.points;

  @override
  void initState() {
    super.initState();
    _showTrendLines = widget.showTrendLines;
  }

  @override
  Widget build(BuildContext context) {
    final formData = ref.watch(formChartDataProvider);
    
    if (formData.teams.isEmpty) {
      return _buildEmptyState(context);
    }

    // Initialize visibility if needed
    if (_teamVisibility.length != formData.teams.length) {
      _teamVisibility = List.generate(
        formData.teams.length,
        (index) => widget.showMultipleTeams ? true : index == 0,
      );
    }

    return _buildFormChart(context, formData);
  }

  Widget _buildFormChart(BuildContext context, FormChartDataModel data) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

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
          
          // Controls
          _buildControls(context),
          
          SizedBox(height: 16.h),
          
          // Chart
          Expanded(
            child: _buildChart(context, data),
          ),
          
          // Legend
          if (widget.showMultipleTeams && data.teams.length > 1)
            _buildLegend(context, data),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, FormChartDataModel data) {
    final theme = Theme.of(context);

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
              Text(
                'Recent ${widget.maxMatches} matches',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ),
        
        PopupMenuButton<String>(
          icon: Icon(Icons.more_vert, size: 20.sp),
          onSelected: _handleMenuAction,
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'export',
              child: Row(
                children: [
                  const Icon(Icons.download),
                  SizedBox(width: 8.w),
                  const Text('Export Chart'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'settings',
              child: Row(
                children: [
                  const Icon(Icons.settings),
                  SizedBox(width: 8.w),
                  const Text('Chart Settings'),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildControls(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Wrap(
      spacing: 8.w,
      runSpacing: 8.h,
      children: [
        // View Type Toggle
        Container(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(6.r),
            border: Border.all(
              color: colorScheme.outline.withOpacity(0.2),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: FormViewType.values.map((type) {
              final isSelected = _viewType == type;
              return GestureDetector(
                onTap: () => setState(() => _viewType = type),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: isSelected 
                      ? colorScheme.primary
                      : Colors.transparent,
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  child: Text(
                    type.displayName,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: isSelected 
                        ? colorScheme.onPrimary
                        : colorScheme.onSurface.withOpacity(0.7),
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        
        // Trend Lines Toggle
        FilterChip(
          label: const Text('Trend Lines'),
          selected: _showTrendLines,
          onSelected: (selected) => setState(() => _showTrendLines = selected),
        ),
        
        // Matches Count Selector
        PopupMenuButton<int>(
          child: Chip(
            label: Text('${widget.maxMatches} matches'),
            avatar: const Icon(Icons.filter_list, size: 16),
          ),
          onSelected: (value) {
            // Would need to pass back to parent component
          },
          itemBuilder: (context) => [5, 10, 15, 20].map((count) =>
            PopupMenuItem(
              value: count,
              child: Text('Last $count matches'),
            ),
          ).toList(),
        ),
      ],
    );
  }

  Widget _buildChart(BuildContext context, FormChartDataModel data) {
    final colorScheme = Theme.of(context).colorScheme;
    final visibleTeams = data.teams.where((team) {
      final index = data.teams.indexOf(team);
      return index < _teamVisibility.length ? _teamVisibility[index] : true;
    }).toList();

    if (visibleTeams.isEmpty) {
      return Center(
        child: Text(
          'No teams selected',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
      );
    }

    return LineChart(
      LineChartData(
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
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            axisNameWidget: Text(
              'Recent Matches',
              style: TextStyle(
                fontSize: 12.sp,
                color: colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30.h,
              interval: 1,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  child: Text(
                    '${index + 1}',
                    style: TextStyle(
                      fontSize: 10.sp,
                      color: colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            axisNameWidget: Transform.rotate(
              angle: -1.5708, // -90 degrees
              child: Text(
                _viewType.yAxisLabel,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ),
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40.w,
              getTitlesWidget: (value, meta) {
                return Text(
                  _formatYAxisLabel(value),
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
        minX: 0,
        maxX: (widget.maxMatches - 1).toDouble(),
        minY: _getMinY(),
        maxY: _getMaxY(),
        lineBarsData: visibleTeams.map((team) {
          final teamIndex = data.teams.indexOf(team);
          final color = team.color != null 
            ? Color(int.parse(team.color!.substring(1), radix: 16) + 0xFF000000)
            : _getTeamColor(teamIndex);

          return LineChartBarData(
            spots: _getFormSpots(team),
            isCurved: true,
            color: color,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                final formPoint = team.formPoints[spot.x.toInt()];
                return FlDotCirclePainter(
                  radius: 4,
                  color: _getResultColor(formPoint.result),
                  strokeWidth: 2,
                  strokeColor: color,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: false,
            ),
          );
        }).toList(),
        lineTouchData: LineTouchData(
          enabled: true,
          touchTooltipData: LineTouchTooltipData(
            tooltipBgColor: colorScheme.inverseSurface,
            tooltipRoundedRadius: 8.r,
            getTooltipItems: (List<LineBarSpot> touchedSpots) {
              return touchedSpots.map((LineBarSpot touchedSpot) {
                final teamIndex = touchedSpots.indexOf(touchedSpot);
                if (teamIndex >= visibleTeams.length) return null;
                
                final team = visibleTeams[teamIndex];
                final matchIndex = touchedSpot.x.toInt();
                if (matchIndex >= team.formPoints.length) return null;
                
                final formPoint = team.formPoints[matchIndex];
                return LineTooltipItem(
                  '${team.teamName}\n'
                  'Match ${matchIndex + 1}\n'
                  'Result: ${formPoint.result}\n'
                  '${_viewType.getTooltipValue(formPoint)}',
                  TextStyle(
                    color: colorScheme.onInverseSurface,
                    fontWeight: FontWeight.w500,
                    fontSize: 12.sp,
                  ),
                );
              }).toList();
            },
          ),
          touchCallback: (FlTouchEvent event, LineTouchResponse? touchResponse) {
            if (event is FlTapUpEvent && touchResponse?.lineBarSpots != null) {
              final spot = touchResponse!.lineBarSpots!.first;
              final teamIndex = visibleTeams.indexWhere((team) => 
                data.teams.indexOf(team) == spot.barIndex);
              if (teamIndex >= 0) {
                setState(() => _selectedTeamIndex = teamIndex);
                widget.onTeamSelected?.call(teamIndex);
              }
            }
          },
        ),
      ),
    );
  }

  Widget _buildLegend(BuildContext context, FormChartDataModel data) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: EdgeInsets.only(top: 16.h),
      child: Wrap(
        spacing: 16.w,
        runSpacing: 8.h,
        children: data.teams.asMap().entries.map((entry) {
          final index = entry.key;
          final team = entry.value;
          final isVisible = index < _teamVisibility.length ? _teamVisibility[index] : true;
          final isSelected = _selectedTeamIndex == index;
          
          return GestureDetector(
            onTap: () {
              setState(() {
                if (widget.showMultipleTeams) {
                  _teamVisibility[index] = !_teamVisibility[index];
                } else {
                  // Single team mode - hide others, show this one
                  for (int i = 0; i < _teamVisibility.length; i++) {
                    _teamVisibility[i] = i == index;
                  }
                }
                _selectedTeamIndex = isSelected ? null : index;
              });
              widget.onTeamSelected?.call(isSelected ? null : index);
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: isSelected 
                  ? colorScheme.primary.withOpacity(0.1)
                  : Colors.transparent,
                borderRadius: BorderRadius.circular(4.r),
                border: Border.all(
                  color: isSelected 
                    ? colorScheme.primary
                    : Colors.transparent,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 12.w,
                    height: 12.w,
                    decoration: BoxDecoration(
                      color: isVisible 
                        ? (team.color != null 
                            ? Color(int.parse(team.color!.substring(1), radix: 16) + 0xFF000000)
                            : _getTeamColor(index))
                        : colorScheme.outline.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),
                  SizedBox(width: 6.w),
                  Text(
                    team.teamName,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isVisible 
                        ? colorScheme.onSurface
                        : colorScheme.onSurface.withOpacity(0.5),
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                  
                  // Form indicator
                  SizedBox(width: 8.w),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: team.formPoints.take(5).map((point) {
                      return Container(
                        margin: EdgeInsets.only(right: 2.w),
                        width: 8.w,
                        height: 8.w,
                        decoration: BoxDecoration(
                          color: _getResultColor(point.result),
                          borderRadius: BorderRadius.circular(1.r),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
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
              Icons.trending_up,
              size: 48.sp,
              color: colorScheme.onSurface.withOpacity(0.3),
            ),
            SizedBox(height: 16.h),
            Text(
              'No Form Data',
              style: theme.textTheme.titleMedium?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Select teams to view their recent form',
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

  List<FlSpot> _getFormSpots(FormLineDataModel team) {
    return team.formPoints.asMap().entries.map((entry) {
      final index = entry.key;
      final point = entry.value;
      final yValue = _viewType.getValue(point);
      return FlSpot(index.toDouble(), yValue);
    }).toList();
  }

  double _getMinY() {
    switch (_viewType) {
      case FormViewType.points:
        return 0;
      case FormViewType.cumulative:
        return 0;
      case FormViewType.form:
        return 0;
    }
  }

  double _getMaxY() {
    switch (_viewType) {
      case FormViewType.points:
        return 3;
      case FormViewType.cumulative:
        return widget.maxMatches * 3.0;
      case FormViewType.form:
        return 100;
    }
  }

  String _formatYAxisLabel(double value) {
    switch (_viewType) {
      case FormViewType.points:
        return value.toInt().toString();
      case FormViewType.cumulative:
        return value.toInt().toString();
      case FormViewType.form:
        return '${value.toInt()}%';
    }
  }

  Color _getTeamColor(int index) {
    final colors = [
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.pink,
      Colors.indigo,
    ];
    return colors[index % colors.length];
  }

  Color _getResultColor(String result) {
    switch (result) {
      case 'W':
        return Colors.green;
      case 'D':
        return Colors.orange;
      case 'L':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'export':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Export functionality coming soon')),
        );
        break;
      case 'settings':
        _showSettingsDialog();
        break;
    }
  }

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Chart Settings'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SwitchListTile(
              title: const Text('Show Trend Lines'),
              value: _showTrendLines,
              onChanged: (value) {
                setState(() => _showTrendLines = value);
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

enum FormViewType {
  points,
  cumulative,
  form,
}

extension FormViewTypeX on FormViewType {
  String get displayName {
    switch (this) {
      case FormViewType.points:
        return 'Points';
      case FormViewType.cumulative:
        return 'Total';
      case FormViewType.form:
        return 'Form %';
    }
  }

  String get yAxisLabel {
    switch (this) {
      case FormViewType.points:
        return 'Points per Match';
      case FormViewType.cumulative:
        return 'Total Points';
      case FormViewType.form:
        return 'Form Rating (%)';
    }
  }

  double getValue(FormPointModel point) {
    switch (this) {
      case FormViewType.points:
        return point.points;
      case FormViewType.cumulative:
        // Would need cumulative calculation
        return point.points;
      case FormViewType.form:
        // Convert to percentage
        return (point.points / 3) * 100;
    }
  }

  String getTooltipValue(FormPointModel point) {
    switch (this) {
      case FormViewType.points:
        return '${point.points} points';
      case FormViewType.cumulative:
        return '${point.points} total';
      case FormViewType.form:
        return '${((point.points / 3) * 100).toStringAsFixed(1)}%';
    }
  }
}