import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../data/models/chart_data_model.dart';
import '../../data/models/statistics_filter_model.dart';

class InteractiveChart extends ConsumerStatefulWidget {
  final ChartDataModel data;
  final ChartConfigModel config;
  final VoidCallback? onTap;
  final Function(String?)? onLegendTap;
  final bool showControls;
  final bool allowFullscreen;

  const InteractiveChart({
    super.key,
    required this.data,
    required this.config,
    this.onTap,
    this.onLegendTap,
    this.showControls = true,
    this.allowFullscreen = true,
  });

  @override
  ConsumerState<InteractiveChart> createState() => _InteractiveChartState();
}

class _InteractiveChartState extends ConsumerState<InteractiveChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  int? _touchedIndex;
  List<bool> _seriesVisibility = [];
  bool _showGrid = true;
  bool _showLabels = true;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: widget.config.animationDuration),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    
    _initializeSeriesVisibility();
    
    if (widget.config.animate) {
      _animationController.forward();
    } else {
      _animationController.value = 1.0;
    }
  }

  void _initializeSeriesVisibility() {
    _seriesVisibility = widget.data.series.map((series) => series.visible).toList();
    _showGrid = widget.config.showGrid;
    _showLabels = widget.config.showLabels;
  }

  @override
  void didUpdateWidget(InteractiveChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.data != widget.data) {
      _initializeSeriesVisibility();
      if (widget.config.animate) {
        _animationController.reset();
        _animationController.forward();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (!widget.data.hasData) {
      return _buildEmptyState(context);
    }

    return Container(
      height: widget.config.height,
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
          _buildHeader(context),
          
          SizedBox(height: 16.h),
          
          // Chart
          Expanded(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: _buildChart(context),
            ),
          ),
          
          // Legend
          if (widget.config.showLegend && widget.data.series.length > 1)
            _buildLegend(context),
          
          // Controls
          if (widget.showControls)
            _buildControls(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.config.title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (widget.config.subtitle != null) ...[
                SizedBox(height: 4.h),
                Text(
                  widget.config.subtitle!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ],
          ),
        ),
        
        // Action buttons
        Row(
          children: [
            if (widget.allowFullscreen)
              IconButton(
                onPressed: () => _showFullscreenChart(context),
                icon: const Icon(Icons.fullscreen),
                iconSize: 20.sp,
                tooltip: 'Fullscreen',
              ),
            
            PopupMenuButton<String>(
              icon: Icon(Icons.more_vert, size: 20.sp),
              onSelected: _handleMenuAction,
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'export',
                  child: Row(
                    children: [
                      Icon(Icons.download),
                      SizedBox(width: 8),
                      Text('Export Chart'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'refresh',
                  child: Row(
                    children: [
                      Icon(Icons.refresh),
                      SizedBox(width: 8),
                      Text('Refresh Data'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'settings',
                  child: Row(
                    children: [
                      Icon(Icons.settings),
                      SizedBox(width: 8),
                      Text('Chart Settings'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildChart(BuildContext context) {
    switch (widget.data.type) {
      case ChartDataType.standings:
        return _buildBarChart(context);
      case ChartDataType.form:
        return _buildLineChart(context);
      case ChartDataType.goals:
        return _buildPieChart(context);
      case ChartDataType.radar:
        return _buildRadarChart(context);
      case ChartDataType.trend:
        return _buildAreaChart(context);
      default:
        return _buildLineChart(context);
    }
  }

  Widget _buildBarChart(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: widget.data.maxValue * 1.1,
        barTouchData: BarTouchData(
          enabled: widget.config.interactive,
          touchTooltipData: BarTouchTooltipData(
            tooltipBgColor: colorScheme.inverseSurface,
            tooltipRoundedRadius: 8.r,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final series = widget.data.series[rodIndex];
              final dataPoint = series.data[groupIndex];
              return BarTooltipItem(
                '${dataPoint.label}\n${dataPoint.value.toStringAsFixed(1)}${series.unit ?? ''}',
                TextStyle(
                  color: colorScheme.onInverseSurface,
                  fontWeight: FontWeight.w500,
                ),
              );
            },
          ),
          touchCallback: (FlTouchEvent event, barTouchResponse) {
            setState(() {
              if (!event.isInterestedForInteractions ||
                  barTouchResponse == null ||
                  barTouchResponse.spot == null) {
                _touchedIndex = -1;
                return;
              }
              _touchedIndex = barTouchResponse.spot!.touchedBarGroupIndex;
            });
          },
        ),
        titlesData: FlTitlesData(
          show: _showLabels,
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            axisNameWidget: widget.config.xAxisLabel != null
              ? Text(widget.config.xAxisLabel!)
              : null,
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= widget.data.labels.length) {
                  return const Text('');
                }
                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  child: Text(
                    widget.data.labels[index],
                    style: TextStyle(
                      fontSize: 10.sp,
                      color: colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                );
              },
              reservedSize: 30.h,
            ),
          ),
          leftTitles: AxisTitles(
            axisNameWidget: widget.config.yAxisLabel != null
              ? Text(widget.config.yAxisLabel!)
              : null,
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40.w,
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
          show: _showGrid,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: colorScheme.outline.withOpacity(0.1),
              strokeWidth: 1,
            );
          },
        ),
        barGroups: widget.data.toBarChartGroups(),
      ),
    );
  }

  Widget _buildLineChart(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: _showGrid,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: colorScheme.outline.withOpacity(0.1),
              strokeWidth: 1,
            );
          },
        ),
        titlesData: FlTitlesData(
          show: _showLabels,
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30.h,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= widget.data.labels.length) {
                  return const Text('');
                }
                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  child: Text(
                    widget.data.labels[index],
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
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40.w,
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
        minX: 0,
        maxX: (widget.data.labels.length - 1).toDouble(),
        minY: widget.data.minValue * 0.9,
        maxY: widget.data.maxValue * 1.1,
        lineBarsData: widget.data.series.asMap().entries.map((entry) {
          final index = entry.key;
          final series = entry.value;
          
          if (index >= _seriesVisibility.length || !_seriesVisibility[index]) {
            return LineChartBarData(spots: []);
          }
          
          return LineChartBarData(
            spots: widget.data.toLineChartSpots(index),
            isCurved: true,
            color: series.color != null 
              ? Color(int.parse(series.color!.substring(1), radix: 16) + 0xFF000000)
              : colorScheme.primary,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: true),
            belowBarData: BarAreaData(
              show: widget.data.type == ChartDataType.trend,
              color: (series.color != null 
                ? Color(int.parse(series.color!.substring(1), radix: 16) + 0xFF000000)
                : colorScheme.primary).withOpacity(0.1),
            ),
          );
        }).toList(),
        lineTouchData: LineTouchData(
          enabled: widget.config.interactive,
          touchTooltipData: LineTouchTooltipData(
            tooltipBgColor: colorScheme.inverseSurface,
            tooltipRoundedRadius: 8.r,
            getTooltipItems: (List<LineBarSpot> touchedSpots) {
              return touchedSpots.map((LineBarSpot touchedSpot) {
                final series = widget.data.series[touchedSpot.barIndex];
                final dataPoint = series.data[touchedSpot.spotIndex];
                return LineTooltipItem(
                  '${series.name}\n${dataPoint.value.toStringAsFixed(1)}${series.unit ?? ''}',
                  TextStyle(
                    color: colorScheme.onInverseSurface,
                    fontWeight: FontWeight.w500,
                  ),
                );
              }).toList();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildPieChart(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return PieChart(
      PieChartData(
        pieTouchData: PieTouchData(
          enabled: widget.config.interactive,
          touchCallback: (FlTouchEvent event, pieTouchResponse) {
            setState(() {
              if (!event.isInterestedForInteractions ||
                  pieTouchResponse == null ||
                  pieTouchResponse.touchedSection == null) {
                _touchedIndex = -1;
                return;
              }
              _touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
            });
          },
        ),
        borderData: FlBorderData(show: false),
        sectionsSpace: 2,
        centerSpaceRadius: 40.r,
        sections: widget.data.toPieChartSections().asMap().entries.map((entry) {
          final index = entry.key;
          final section = entry.value;
          final isTouched = index == _touchedIndex;
          
          return PieChartSectionData(
            color: section.color,
            value: section.value,
            title: section.title,
            radius: isTouched ? 70.r : 60.r,
            titleStyle: TextStyle(
              fontSize: isTouched ? 14.sp : 12.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildRadarChart(BuildContext context) {
    // Radar chart implementation would require a different package
    // For now, show a placeholder
    return Center(
      child: Text(
        'Radar Chart\n(Requires specialized implementation)',
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
        ),
      ),
    );
  }

  Widget _buildAreaChart(BuildContext context) {
    // Similar to line chart but with filled areas
    return _buildLineChart(context);
  }

  Widget _buildLegend(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: EdgeInsets.only(top: 16.h),
      child: Wrap(
        spacing: 16.w,
        runSpacing: 8.h,
        children: widget.data.series.asMap().entries.map((entry) {
          final index = entry.key;
          final series = entry.value;
          final isVisible = index < _seriesVisibility.length ? _seriesVisibility[index] : true;
          
          return GestureDetector(
            onTap: () {
              setState(() {
                if (index < _seriesVisibility.length) {
                  _seriesVisibility[index] = !_seriesVisibility[index];
                }
              });
              widget.onLegendTap?.call(series.name);
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 12.w,
                  height: 12.w,
                  decoration: BoxDecoration(
                    color: isVisible 
                      ? (series.color != null 
                          ? Color(int.parse(series.color!.substring(1), radix: 16) + 0xFF000000)
                          : colorScheme.primary)
                      : colorScheme.outline.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
                SizedBox(width: 6.w),
                Text(
                  series.name,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isVisible 
                      ? colorScheme.onSurface
                      : colorScheme.onSurface.withOpacity(0.5),
                    fontWeight: isVisible ? FontWeight.w500 : FontWeight.normal,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildControls(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: EdgeInsets.only(top: 12.h),
      child: Row(
        children: [
          _buildControlChip(
            context,
            'Grid',
            _showGrid,
            Icons.grid_on,
            () => setState(() => _showGrid = !_showGrid),
          ),
          SizedBox(width: 8.w),
          _buildControlChip(
            context,
            'Labels',
            _showLabels,
            Icons.label,
            () => setState(() => _showLabels = !_showLabels),
          ),
        ],
      ),
    );
  }

  Widget _buildControlChip(
    BuildContext context,
    String label,
    bool isSelected,
    IconData icon,
    VoidCallback onTap,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
        decoration: BoxDecoration(
          color: isSelected 
            ? colorScheme.primary.withOpacity(0.1)
            : colorScheme.outline.withOpacity(0.05),
          borderRadius: BorderRadius.circular(4.r),
          border: Border.all(
            color: isSelected 
              ? colorScheme.primary.withOpacity(0.3)
              : colorScheme.outline.withOpacity(0.1),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 12.sp,
              color: isSelected 
                ? colorScheme.primary
                : colorScheme.onSurface.withOpacity(0.6),
            ),
            SizedBox(width: 4.w),
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: isSelected 
                  ? colorScheme.primary
                  : colorScheme.onSurface.withOpacity(0.6),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      height: widget.config.height,
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
              Icons.bar_chart,
              size: 48.sp,
              color: colorScheme.onSurface.withOpacity(0.3),
            ),
            SizedBox(height: 16.h),
            Text(
              'No Data Available',
              style: theme.textTheme.titleMedium?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Please adjust your filters to see chart data',
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

  void _showFullscreenChart(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: Text(widget.config.title),
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
          body: Padding(
            padding: EdgeInsets.all(16.w),
            child: InteractiveChart(
              data: widget.data,
              config: widget.config.copyWith(height: double.infinity),
              showControls: true,
              allowFullscreen: false,
            ),
          ),
        ),
      ),
    );
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'export':
        // Handle export
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Export functionality coming soon')),
        );
        break;
      case 'refresh':
        // Handle refresh
        if (widget.config.animate) {
          _animationController.reset();
          _animationController.forward();
        }
        break;
      case 'settings':
        // Handle settings
        _showChartSettings(context);
        break;
    }
  }

  void _showChartSettings(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Chart Settings'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SwitchListTile(
              title: const Text('Show Grid'),
              value: _showGrid,
              onChanged: (value) {
                setState(() => _showGrid = value);
                Navigator.of(context).pop();
              },
            ),
            SwitchListTile(
              title: const Text('Show Labels'),
              value: _showLabels,
              onChanged: (value) {
                setState(() => _showLabels = value);
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