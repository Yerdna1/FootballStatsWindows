import 'package:freezed_annotation/freezed_annotation.dart';

part 'statistics_filter_model.freezed.dart';
part 'statistics_filter_model.g.dart';

@freezed
class StatisticsFilterModel with _$StatisticsFilterModel {
  const factory StatisticsFilterModel({
    @Default([]) List<int> selectedLeagues,
    @Default([]) List<int> selectedTeams,
    @Default([]) List<int> selectedSeasons,
    DateTime? startDate,
    DateTime? endDate,
    @Default(StatisticsTimeframe.season) StatisticsTimeframe timeframe,
    @Default(StatisticsViewType.overview) StatisticsViewType viewType,
    @Default([]) List<StatisticsMetric> selectedMetrics,
    @Default(true) bool includeHomeAway,
    @Default(true) bool includeForm,
    @Default(true) bool includeComparisons,
    @Default(StatisticsSortBy.points) StatisticsSortBy sortBy,
    @Default(true) bool sortDescending,
  }) = _StatisticsFilterModel;

  factory StatisticsFilterModel.fromJson(Map<String, dynamic> json) =>
      _$StatisticsFilterModelFromJson(json);
}

@freezed
class ChartConfigModel with _$ChartConfigModel {
  const factory ChartConfigModel({
    required ChartType type,
    required String title,
    @Default(true) bool showLegend,
    @Default(true) bool showLabels,
    @Default(true) bool showGrid,
    @Default(true) bool interactive,
    @Default([]) List<String> colors,
    @Default(400.0) double height,
    @Default(300.0) double minHeight,
    String? subtitle,
    String? xAxisLabel,
    String? yAxisLabel,
    @Default(true) bool animate,
    @Default(1000) int animationDuration,
  }) = _ChartConfigModel;

  factory ChartConfigModel.fromJson(Map<String, dynamic> json) =>
      _$ChartConfigModelFromJson(json);
}

@freezed
class ExportConfigModel with _$ExportConfigModel {
  const factory ExportConfigModel({
    required ExportFormat format,
    required ExportDataType dataType,
    @Default(true) bool includeCharts,
    @Default(true) bool includeStatistics,
    @Default(true) bool includeFilters,
    @Default([]) List<String> selectedCharts,
    @Default([]) List<String> selectedMetrics,
    String? fileName,
    String? title,
    String? description,
    DateTime? dateGenerated,
  }) = _ExportConfigModel;

  factory ExportConfigModel.fromJson(Map<String, dynamic> json) =>
      _$ExportConfigModelFromJson(json);
}

enum StatisticsTimeframe {
  all,
  season,
  last30Days,
  last90Days,
  currentMonth,
  lastMonth,
  custom,
}

enum StatisticsViewType {
  overview,
  detailed,
  comparison,
  trends,
  performance,
}

enum StatisticsMetric {
  goals,
  assists,
  cleanSheets,
  wins,
  draws,
  losses,
  points,
  possession,
  shots,
  passes,
  tackles,
  cards,
  form,
}

enum StatisticsSortBy {
  points,
  goals,
  wins,
  form,
  name,
  rating,
}

enum ChartType {
  line,
  bar,
  pie,
  radar,
  area,
  scatter,
  donut,
  column,
}

enum ExportFormat {
  csv,
  pdf,
  json,
  excel,
}

enum ExportDataType {
  all,
  statistics,
  charts,
  filtered,
}

extension StatisticsTimeframeX on StatisticsTimeframe {
  String get displayName {
    switch (this) {
      case StatisticsTimeframe.all:
        return 'All Time';
      case StatisticsTimeframe.season:
        return 'Current Season';
      case StatisticsTimeframe.last30Days:
        return 'Last 30 Days';
      case StatisticsTimeframe.last90Days:
        return 'Last 90 Days';
      case StatisticsTimeframe.currentMonth:
        return 'Current Month';
      case StatisticsTimeframe.lastMonth:
        return 'Last Month';
      case StatisticsTimeframe.custom:
        return 'Custom Range';
    }
  }

  DateRange? get dateRange {
    final now = DateTime.now();
    switch (this) {
      case StatisticsTimeframe.last30Days:
        return DateRange(
          start: now.subtract(const Duration(days: 30)),
          end: now,
        );
      case StatisticsTimeframe.last90Days:
        return DateRange(
          start: now.subtract(const Duration(days: 90)),
          end: now,
        );
      case StatisticsTimeframe.currentMonth:
        return DateRange(
          start: DateTime(now.year, now.month, 1),
          end: now,
        );
      case StatisticsTimeframe.lastMonth:
        final lastMonth = DateTime(now.year, now.month - 1, 1);
        return DateRange(
          start: lastMonth,
          end: DateTime(now.year, now.month, 0),
        );
      default:
        return null;
    }
  }
}

extension StatisticsViewTypeX on StatisticsViewType {
  String get displayName {
    switch (this) {
      case StatisticsViewType.overview:
        return 'Overview';
      case StatisticsViewType.detailed:
        return 'Detailed';
      case StatisticsViewType.comparison:
        return 'Comparison';
      case StatisticsViewType.trends:
        return 'Trends';
      case StatisticsViewType.performance:
        return 'Performance';
    }
  }

  String get description {
    switch (this) {
      case StatisticsViewType.overview:
        return 'Key statistics and metrics overview';
      case StatisticsViewType.detailed:
        return 'Comprehensive statistical analysis';
      case StatisticsViewType.comparison:
        return 'Compare teams and players';
      case StatisticsViewType.trends:
        return 'Performance trends over time';
      case StatisticsViewType.performance:
        return 'Advanced performance metrics';
    }
  }
}

extension StatisticsMetricX on StatisticsMetric {
  String get displayName {
    switch (this) {
      case StatisticsMetric.goals:
        return 'Goals';
      case StatisticsMetric.assists:
        return 'Assists';
      case StatisticsMetric.cleanSheets:
        return 'Clean Sheets';
      case StatisticsMetric.wins:
        return 'Wins';
      case StatisticsMetric.draws:
        return 'Draws';
      case StatisticsMetric.losses:
        return 'Losses';
      case StatisticsMetric.points:
        return 'Points';
      case StatisticsMetric.possession:
        return 'Possession';
      case StatisticsMetric.shots:
        return 'Shots';
      case StatisticsMetric.passes:
        return 'Passes';
      case StatisticsMetric.tackles:
        return 'Tackles';
      case StatisticsMetric.cards:
        return 'Cards';
      case StatisticsMetric.form:
        return 'Form';
    }
  }

  String get unit {
    switch (this) {
      case StatisticsMetric.possession:
        return '%';
      case StatisticsMetric.form:
        return 'pts/game';
      default:
        return '';
    }
  }
}

extension ChartTypeX on ChartType {
  String get displayName {
    switch (this) {
      case ChartType.line:
        return 'Line Chart';
      case ChartType.bar:
        return 'Bar Chart';
      case ChartType.pie:
        return 'Pie Chart';
      case ChartType.radar:
        return 'Radar Chart';
      case ChartType.area:
        return 'Area Chart';
      case ChartType.scatter:
        return 'Scatter Chart';
      case ChartType.donut:
        return 'Donut Chart';
      case ChartType.column:
        return 'Column Chart';
    }
  }

  bool get supportsMultipleSeries => 
      this == ChartType.line || 
      this == ChartType.bar || 
      this == ChartType.area ||
      this == ChartType.column;
}

class DateRange {
  final DateTime start;
  final DateTime end;

  const DateRange({required this.start, required this.end});

  Duration get duration => end.difference(start);
  
  bool contains(DateTime date) => 
      date.isAfter(start.subtract(const Duration(days: 1))) && 
      date.isBefore(end.add(const Duration(days: 1)));
}