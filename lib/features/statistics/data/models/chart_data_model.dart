import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:fl_chart/fl_chart.dart';

part 'chart_data_model.freezed.dart';
part 'chart_data_model.g.dart';

@freezed
class ChartDataModel with _$ChartDataModel {
  const factory ChartDataModel({
    required String id,
    required String title,
    String? subtitle,
    required ChartDataType type,
    required List<ChartSeriesModel> series,
    @Default([]) List<String> labels,
    @Default([]) List<String> categories,
    DateTime? lastUpdated,
    @Default(false) bool isLoading,
    String? error,
    Map<String, dynamic>? metadata,
  }) = _ChartDataModel;

  factory ChartDataModel.fromJson(Map<String, dynamic> json) =>
      _$ChartDataModelFromJson(json);
}

@freezed
class ChartSeriesModel with _$ChartSeriesModel {
  const factory ChartSeriesModel({
    required String name,
    required List<ChartDataPointModel> data,
    String? color,
    @Default(true) bool visible,
    @Default(1.0) double opacity,
    String? unit,
    Map<String, dynamic>? metadata,
  }) = _ChartSeriesModel;

  factory ChartSeriesModel.fromJson(Map<String, dynamic> json) =>
      _$ChartSeriesModelFromJson(json);
}

@freezed
class ChartDataPointModel with _$ChartDataPointModel {
  const factory ChartDataPointModel({
    required String label,
    required double value,
    @Default(0.0) double x,
    @Default(0.0) double y,
    String? color,
    String? tooltip,
    Map<String, dynamic>? metadata,
  }) = _ChartDataPointModel;

  factory ChartDataPointModel.fromJson(Map<String, dynamic> json) =>
      _$ChartDataPointModelFromJson(json);
}

@freezed
class StandingsChartDataModel with _$StandingsChartDataModel {
  const factory StandingsChartDataModel({
    required List<StandingsBarDataModel> teams,
    @Default('League Standings') String title,
    @Default('Points') String metric,
    DateTime? lastUpdated,
  }) = _StandingsChartDataModel;

  factory StandingsChartDataModel.fromJson(Map<String, dynamic> json) =>
      _$StandingsChartDataModelFromJson(json);
}

@freezed
class StandingsBarDataModel with _$StandingsBarDataModel {
  const factory StandingsBarDataModel({
    required String teamName,
    required String teamLogo,
    required int position,
    required double points,
    required double wins,
    required double draws,
    required double losses,
    required double goalsFor,
    required double goalsAgainst,
    String? color,
  }) = _StandingsBarDataModel;

  factory StandingsBarDataModel.fromJson(Map<String, dynamic> json) =>
      _$StandingsBarDataModelFromJson(json);
}

@freezed
class FormChartDataModel with _$FormChartDataModel {
  const factory FormChartDataModel({
    required List<FormLineDataModel> teams,
    @Default('Team Form') String title,
    @Default('Points per Game') String yAxisLabel,
    DateTime? lastUpdated,
  }) = _FormChartDataModel;

  factory FormChartDataModel.fromJson(Map<String, dynamic> json) =>
      _$FormChartDataModelFromJson(json);
}

@freezed
class FormLineDataModel with _$FormLineDataModel {
  const factory FormLineDataModel({
    required String teamName,
    required List<FormPointModel> formPoints,
    String? color,
    @Default(true) bool visible,
  }) = _FormLineDataModel;

  factory FormLineDataModel.fromJson(Map<String, dynamic> json) =>
      _$FormLineDataModelFromJson(json);
}

@freezed
class FormPointModel with _$FormPointModel {
  const factory FormPointModel({
    required DateTime date,
    required double points,
    required String result, // 'W', 'D', 'L'
    String? opponent,
    @Default(false) bool isHome,
  }) = _FormPointModel;

  factory FormPointModel.fromJson(Map<String, dynamic> json) =>
      _$FormPointModelFromJson(json);
}

@freezed
class GoalDistributionDataModel with _$GoalDistributionDataModel {
  const factory GoalDistributionDataModel({
    required List<GoalDistributionSegmentModel> segments,
    @Default('Goal Distribution') String title,
    @Default(0) int totalGoals,
    DateTime? lastUpdated,
  }) = _GoalDistributionDataModel;

  factory GoalDistributionDataModel.fromJson(Map<String, dynamic> json) =>
      _$GoalDistributionDataModelFromJson(json);
}

@freezed
class GoalDistributionSegmentModel with _$GoalDistributionSegmentModel {
  const factory GoalDistributionSegmentModel({
    required String label,
    required double value,
    required double percentage,
    String? color,
    String? description,
  }) = _GoalDistributionSegmentModel;

  factory GoalDistributionSegmentModel.fromJson(Map<String, dynamic> json) =>
      _$GoalDistributionSegmentModelFromJson(json);
}

@freezed
class RadarChartDataModel with _$RadarChartDataModel {
  const factory RadarChartDataModel({
    required List<RadarDataSetModel> dataSets,
    required List<String> labels,
    @Default('Performance Radar') String title,
    @Default(100.0) double maxValue,
    DateTime? lastUpdated,
  }) = _RadarChartDataModel;

  factory RadarChartDataModel.fromJson(Map<String, dynamic> json) =>
      _$RadarChartDataModelFromJson(json);
}

@freezed
class RadarDataSetModel with _$RadarDataSetModel {
  const factory RadarDataSetModel({
    required String name,
    required List<double> values,
    String? color,
    @Default(0.3) double fillOpacity,
    @Default(2.0) double borderWidth,
  }) = _RadarDataSetModel;

  factory RadarDataSetModel.fromJson(Map<String, dynamic> json) =>
      _$RadarDataSetModelFromJson(json);
}

@freezed
class TrendAnalysisDataModel with _$TrendAnalysisDataModel {
  const factory TrendAnalysisDataModel({
    required List<TrendSeriesModel> series,
    required List<DateTime> timePoints,
    @Default('Trend Analysis') String title,
    String? yAxisLabel,
    DateTime? lastUpdated,
  }) = _TrendAnalysisDataModel;

  factory TrendAnalysisDataModel.fromJson(Map<String, dynamic> json) =>
      _$TrendAnalysisDataModelFromJson(json);
}

@freezed
class TrendSeriesModel with _$TrendSeriesModel {
  const factory TrendSeriesModel({
    required String name,
    required List<TrendDataPointModel> dataPoints,
    String? color,
    @Default(true) bool showTrendLine,
    @Default(TrendDirection.stable) TrendDirection trend,
  }) = _TrendSeriesModel;

  factory TrendSeriesModel.fromJson(Map<String, dynamic> json) =>
      _$TrendSeriesModelFromJson(json);
}

@freezed
class TrendDataPointModel with _$TrendDataPointModel {
  const factory TrendDataPointModel({
    required DateTime date,
    required double value,
    String? tooltip,
    @Default(false) bool isProjected,
  }) = _TrendDataPointModel;

  factory TrendDataPointModel.fromJson(Map<String, dynamic> json) =>
      _$TrendDataPointModelFromJson(json);
}

enum ChartDataType {
  standings,
  form,
  goals,
  radar,
  trend,
  comparison,
  distribution,
}

enum TrendDirection {
  improving,
  stable,
  declining,
}

extension ChartDataTypeX on ChartDataType {
  String get displayName {
    switch (this) {
      case ChartDataType.standings:
        return 'League Standings';
      case ChartDataType.form:
        return 'Team Form';
      case ChartDataType.goals:
        return 'Goal Statistics';
      case ChartDataType.radar:
        return 'Performance Radar';
      case ChartDataType.trend:
        return 'Trend Analysis';
      case ChartDataType.comparison:
        return 'Team Comparison';
      case ChartDataType.distribution:
        return 'Data Distribution';
    }
  }

  String get description {
    switch (this) {
      case ChartDataType.standings:
        return 'Current league table and positions';
      case ChartDataType.form:
        return 'Recent team performance trends';
      case ChartDataType.goals:
        return 'Goal scoring and conceding statistics';
      case ChartDataType.radar:
        return 'Multi-dimensional performance analysis';
      case ChartDataType.trend:
        return 'Performance trends over time';
      case ChartDataType.comparison:
        return 'Side-by-side team comparisons';
      case ChartDataType.distribution:
        return 'Statistical data distribution';
    }
  }
}

extension TrendDirectionX on TrendDirection {
  String get displayName {
    switch (this) {
      case TrendDirection.improving:
        return 'Improving';
      case TrendDirection.stable:
        return 'Stable';
      case TrendDirection.declining:
        return 'Declining';
    }
  }

  String get icon {
    switch (this) {
      case TrendDirection.improving:
        return '↗';
      case TrendDirection.stable:
        return '→';
      case TrendDirection.declining:
        return '↘';
    }
  }
}

// Utility extensions for chart data conversion
extension ChartDataModelX on ChartDataModel {
  List<FlSpot> toLineChartSpots(int seriesIndex) {
    if (seriesIndex >= series.length) return [];
    
    final seriesData = series[seriesIndex].data;
    return seriesData.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.value);
    }).toList();
  }

  List<BarChartGroupData> toBarChartGroups() {
    final List<BarChartGroupData> groups = [];
    
    for (int i = 0; i < (labels.isEmpty ? series.first.data.length : labels.length); i++) {
      final bars = series.asMap().entries.map((seriesEntry) {
        final seriesIndex = seriesEntry.key;
        final seriesData = seriesEntry.value;
        
        if (i < seriesData.data.length) {
          return BarChartRodData(
            toY: seriesData.data[i].value,
            color: seriesData.color != null 
              ? Color(int.parse(seriesData.color!.substring(1), radix: 16) + 0xFF000000)
              : null,
          );
        }
        return BarChartRodData(toY: 0);
      }).toList();

      groups.add(BarChartGroupData(x: i, barRods: bars));
    }
    
    return groups;
  }

  List<PieChartSectionData> toPieChartSections() {
    if (series.isEmpty) return [];
    
    final data = series.first.data;
    final total = data.fold<double>(0, (sum, point) => sum + point.value);
    
    return data.asMap().entries.map((entry) {
      final index = entry.key;
      final point = entry.value;
      final percentage = (point.value / total) * 100;
      
      return PieChartSectionData(
        value: point.value,
        title: '${percentage.toStringAsFixed(1)}%',
        color: point.color != null 
          ? Color(int.parse(point.color!.substring(1), radix: 16) + 0xFF000000)
          : null,
        radius: 60,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }

  bool get hasData => series.isNotEmpty && series.any((s) => s.data.isNotEmpty);
  
  double get maxValue => series.isEmpty 
    ? 0 
    : series.map((s) => s.data.isEmpty 
        ? 0 
        : s.data.map((d) => d.value).reduce((a, b) => a > b ? a : b)
      ).reduce((a, b) => a > b ? a : b);
      
  double get minValue => series.isEmpty 
    ? 0 
    : series.map((s) => s.data.isEmpty 
        ? 0 
        : s.data.map((d) => d.value).reduce((a, b) => a < b ? a : b)
      ).reduce((a, b) => a < b ? a : b);
}