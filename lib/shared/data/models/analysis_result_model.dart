import 'package:freezed_annotation/freezed_annotation.dart';

part 'analysis_result_model.freezed.dart';
part 'analysis_result_model.g.dart';

@freezed
class AnalysisResultModel with _$AnalysisResultModel {
  const factory AnalysisResultModel({
    required String id,
    required AnalysisType analysisType,
    required String title,
    required String description,
    required AnalysisSubject subject,
    required AnalysisParameters parameters,
    required AnalysisData data,
    required List<Finding> findings,
    required List<Insight> insights,
    required List<Recommendation> recommendations,
    @Default([]) List<Visualization> visualizations,
    required AnalysisMetadata metadata,
    DateTime? createdAt,
    DateTime? completedAt,
    @Default(AnalysisStatus.pending) AnalysisStatus status,
    String? errorMessage,
    @Default(0.0) double confidence,
    @Default({}) Map<String, dynamic> rawData,
  }) = _AnalysisResultModel;

  factory AnalysisResultModel.fromJson(Map<String, dynamic> json) =>
      _$AnalysisResultModelFromJson(json);
}

@freezed
class AnalysisSubject with _$AnalysisSubject {
  const factory AnalysisSubject({
    required SubjectType type,
    required int entityId,
    required String entityName,
    String? entityImage,
    @Default([]) List<int> relatedEntities,
    String? seasonId,
    String? competition,
    DateTime? periodStart,
    DateTime? periodEnd,
  }) = _AnalysisSubject;

  factory AnalysisSubject.fromJson(Map<String, dynamic> json) =>
      _$AnalysisSubjectFromJson(json);
}

@freezed
class AnalysisParameters with _$AnalysisParameters {
  const factory AnalysisParameters({
    @Default(30) int timeFrameDays,
    @Default(10) int maxFixtures,
    @Default(true) bool includeHomeGames,
    @Default(true) bool includeAwayGames,
    @Default([]) List<String> competitions,
    @Default([]) List<int> opponents,
    @Default([]) List<String> venues,
    @Default(false) bool onlyRecentForm,
    @Default(0.7) double confidenceThreshold,
    @Default({}) Map<String, double> weights,
    @Default({}) Map<String, dynamic> customFilters,
  }) = _AnalysisParameters;

  factory AnalysisParameters.fromJson(Map<String, dynamic> json) =>
      _$AnalysisParametersFromJson(json);
}

@freezed
class AnalysisData with _$AnalysisData {
  const factory AnalysisData({
    @Default(0) int totalMatches,
    @Default(0) int wins,
    @Default(0) int draws,
    @Default(0) int losses,
    @Default(0) int goalsFor,
    @Default(0) int goalsAgainst,
    @Default(0) int goalDifference,
    @Default(0.0) double winPercentage,
    @Default(0.0) double averageGoalsFor,
    @Default(0.0) double averageGoalsAgainst,
    @Default([]) List<MatchAnalysis> matchAnalyses,
    @Default([]) List<TrendData> trends,
    @Default([]) List<PatternData> patterns,
    @Default({}) Map<String, double> statistics,
  }) = _AnalysisData;

  factory AnalysisData.fromJson(Map<String, dynamic> json) =>
      _$AnalysisDataFromJson(json);
}

@freezed
class Finding with _$Finding {
  const factory Finding({
    required String id,
    required FindingType type,
    required String title,
    required String description,
    @Default(0.0) double significance,
    @Default(0.0) double confidence,
    @Default([]) List<String> supportingEvidence,
    @Default([]) List<DataPoint> dataPoints,
    String? category,
    @Default({}) Map<String, dynamic> metadata,
  }) = _Finding;

  factory Finding.fromJson(Map<String, dynamic> json) =>
      _$FindingFromJson(json);
}

@freezed
class Insight with _$Insight {
  const factory Insight({
    required String id,
    required InsightType type,
    required String title,
    required String description,
    @Default(0.0) double impact,
    @Default(0.0) double reliability,
    @Default([]) List<String> implications,
    @Default([]) List<ActionItem> actionItems,
    String? timeFrame,
    @Default({}) Map<String, dynamic> context,
  }) = _Insight;

  factory Insight.fromJson(Map<String, dynamic> json) =>
      _$InsightFromJson(json);
}

@freezed
class Recommendation with _$Recommendation {
  const factory Recommendation({
    required String id,
    required RecommendationType type,
    required String title,
    required String description,
    @Default(0.0) double priority,
    @Default(0.0) double feasibility,
    @Default(0.0) double expectedImpact,
    @Default([]) List<String> steps,
    @Default([]) List<String> prerequisites,
    String? timeframe,
    @Default([]) List<String> risks,
    @Default([]) List<String> benefits,
  }) = _Recommendation;

  factory Recommendation.fromJson(Map<String, dynamic> json) =>
      _$RecommendationFromJson(json);
}

@freezed
class Visualization with _$Visualization {
  const factory Visualization({
    required String id,
    required VisualizationType type,
    required String title,
    required String description,
    required Map<String, dynamic> data,
    @Default({}) Map<String, dynamic> options,
    String? category,
  }) = _Visualization;

  factory Visualization.fromJson(Map<String, dynamic> json) =>
      _$VisualizationFromJson(json);
}

@freezed
class AnalysisMetadata with _$AnalysisMetadata {
  const factory AnalysisMetadata({
    required String version,
    required String algorithm,
    @Default(0) int processingTimeMs,
    @Default(0) int dataPointsAnalyzed,
    @Default([]) List<String> dataSources,
    @Default([]) List<String> assumptions,
    @Default([]) List<String> limitations,
    @Default(0.0) double dataQuality,
    DateTime? dataLastUpdated,
    @Default({}) Map<String, String> configuration,
  }) = _AnalysisMetadata;

  factory AnalysisMetadata.fromJson(Map<String, dynamic> json) =>
      _$AnalysisMetadataFromJson(json);
}

@freezed
class MatchAnalysis with _$MatchAnalysis {
  const factory MatchAnalysis({
    required int fixtureId,
    required String opponent,
    required DateTime date,
    required bool isHome,
    required String result,
    @Default(0) int goalsFor,
    @Default(0) int goalsAgainst,
    @Default(0.0) double performanceRating,
    @Default([]) List<String> keyEvents,
    @Default({}) Map<String, double> metrics,
  }) = _MatchAnalysis;

  factory MatchAnalysis.fromJson(Map<String, dynamic> json) =>
      _$MatchAnalysisFromJson(json);
}

@freezed
class TrendData with _$TrendData {
  const factory TrendData({
    required String metric,
    required TrendDirection direction,
    @Default(0.0) double slope,
    @Default(0.0) double correlation,
    @Default([]) List<TimeSeriesPoint> points,
    String? interpretation,
  }) = _TrendData;

  factory TrendData.fromJson(Map<String, dynamic> json) =>
      _$TrendDataFromJson(json);
}

@freezed
class PatternData with _$PatternData {
  const factory PatternData({
    required String name,
    required PatternType type,
    @Default(0.0) double frequency,
    @Default(0.0) double strength,
    String? description,
    @Default([]) List<String> examples,
    @Default({}) Map<String, dynamic> attributes,
  }) = _PatternData;

  factory PatternData.fromJson(Map<String, dynamic> json) =>
      _$PatternDataFromJson(json);
}

@freezed
class DataPoint with _$DataPoint {
  const factory DataPoint({
    required String label,
    @Default(0.0) double value,
    String? unit,
    DateTime? timestamp,
    @Default({}) Map<String, dynamic> context,
  }) = _DataPoint;

  factory DataPoint.fromJson(Map<String, dynamic> json) =>
      _$DataPointFromJson(json);
}

@freezed
class TimeSeriesPoint with _$TimeSeriesPoint {
  const factory TimeSeriesPoint({
    required DateTime timestamp,
    @Default(0.0) double value,
    @Default({}) Map<String, dynamic> metadata,
  }) = _TimeSeriesPoint;

  factory TimeSeriesPoint.fromJson(Map<String, dynamic> json) =>
      _$TimeSeriesPointFromJson(json);
}

@freezed
class ActionItem with _$ActionItem {
  const factory ActionItem({
    required String description,
    @Default(ActionPriority.medium) ActionPriority priority,
    String? owner,
    DateTime? dueDate,
    @Default(ActionStatus.pending) ActionStatus status,
  }) = _ActionItem;

  factory ActionItem.fromJson(Map<String, dynamic> json) =>
      _$ActionItemFromJson(json);
}

enum AnalysisType {
  formAnalysis,
  performanceAnalysis,
  tacticalAnalysis,
  strengthWeaknessAnalysis,
  trendAnalysis,
  comparisonAnalysis,
  predictionAnalysis,
  injuryAnalysis,
  marketValueAnalysis,
  custom,
}

enum SubjectType {
  team,
  player,
  league,
  match,
  season,
}

enum AnalysisStatus {
  pending,
  running,
  completed,
  failed,
  cancelled,
}

enum FindingType {
  strength,
  weakness,
  opportunity,
  threat,
  trend,
  anomaly,
  pattern,
  correlation,
}

enum InsightType {
  tactical,
  strategic,
  operational,
  predictive,
  diagnostic,
  descriptive,
}

enum RecommendationType {
  tactical,
  strategic,
  training,
  recruitment,
  injury,
  performance,
  organizational,
}

enum VisualizationType {
  lineChart,
  barChart,
  pieChart,
  scatterPlot,
  heatmap,
  radarChart,
  trendChart,
  comparisonChart,
}

enum TrendDirection {
  increasing,
  decreasing,
  stable,
  cyclical,
  volatile,
}

enum PatternType {
  seasonal,
  cyclical,
  recurring,
  behavioral,
  performance,
  tactical,
}

enum ActionPriority {
  high,
  medium,
  low,
}

enum ActionStatus {
  pending,
  inProgress,
  completed,
  cancelled,
}

extension AnalysisTypeX on AnalysisType {
  String get displayName {
    switch (this) {
      case AnalysisType.formAnalysis:
        return 'Form Analysis';
      case AnalysisType.performanceAnalysis:
        return 'Performance Analysis';
      case AnalysisType.tacticalAnalysis:
        return 'Tactical Analysis';
      case AnalysisType.strengthWeaknessAnalysis:
        return 'Strength & Weakness Analysis';
      case AnalysisType.trendAnalysis:
        return 'Trend Analysis';
      case AnalysisType.comparisonAnalysis:
        return 'Comparison Analysis';
      case AnalysisType.predictionAnalysis:
        return 'Prediction Analysis';
      case AnalysisType.injuryAnalysis:
        return 'Injury Analysis';
      case AnalysisType.marketValueAnalysis:
        return 'Market Value Analysis';
      case AnalysisType.custom:
        return 'Custom Analysis';
    }
  }

  String get icon {
    switch (this) {
      case AnalysisType.formAnalysis:
        return '📈';
      case AnalysisType.performanceAnalysis:
        return '⚽';
      case AnalysisType.tacticalAnalysis:
        return '🎯';
      case AnalysisType.strengthWeaknessAnalysis:
        return '⚖️';
      case AnalysisType.trendAnalysis:
        return '📊';
      case AnalysisType.comparisonAnalysis:
        return '📋';
      case AnalysisType.predictionAnalysis:
        return '🔮';
      case AnalysisType.injuryAnalysis:
        return '🏥';
      case AnalysisType.marketValueAnalysis:
        return '💰';
      case AnalysisType.custom:
        return '🔧';
    }
  }
}

extension FindingTypeX on FindingType {
  String get displayName {
    switch (this) {
      case FindingType.strength:
        return 'Strength';
      case FindingType.weakness:
        return 'Weakness';
      case FindingType.opportunity:
        return 'Opportunity';
      case FindingType.threat:
        return 'Threat';
      case FindingType.trend:
        return 'Trend';
      case FindingType.anomaly:
        return 'Anomaly';
      case FindingType.pattern:
        return 'Pattern';
      case FindingType.correlation:
        return 'Correlation';
    }
  }

  String get icon {
    switch (this) {
      case FindingType.strength:
        return '💪';
      case FindingType.weakness:
        return '⚠️';
      case FindingType.opportunity:
        return '🎯';
      case FindingType.threat:
        return '⚡';
      case FindingType.trend:
        return '📈';
      case FindingType.anomaly:
        return '🔍';
      case FindingType.pattern:
        return '🔄';
      case FindingType.correlation:
        return '🔗';
    }
  }
}

extension AnalysisStatusX on AnalysisStatus {
  String get displayName {
    switch (this) {
      case AnalysisStatus.pending:
        return 'Pending';
      case AnalysisStatus.running:
        return 'Running';
      case AnalysisStatus.completed:
        return 'Completed';
      case AnalysisStatus.failed:
        return 'Failed';
      case AnalysisStatus.cancelled:
        return 'Cancelled';
    }
  }

  String get icon {
    switch (this) {
      case AnalysisStatus.pending:
        return '⏳';
      case AnalysisStatus.running:
        return '🔄';
      case AnalysisStatus.completed:
        return '✅';
      case AnalysisStatus.failed:
        return '❌';
      case AnalysisStatus.cancelled:
        return '🚫';
    }
  }
}

extension AnalysisResultModelX on AnalysisResultModel {
  Duration? get processingDuration {
    if (createdAt != null && completedAt != null) {
      return completedAt!.difference(createdAt!);
    }
    return null;
  }

  bool get isCompleted => status == AnalysisStatus.completed;
  bool get isSuccessful => isCompleted && errorMessage == null;
  bool get hasHighConfidence => confidence >= 0.8;

  List<Finding> get criticalFindings {
    return findings
        .where((f) => f.significance >= 0.8)
        .toList()
      ..sort((a, b) => b.significance.compareTo(a.significance));
  }

  List<Finding> get strengths {
    return findings.where((f) => f.type == FindingType.strength).toList();
  }

  List<Finding> get weaknesses {
    return findings.where((f) => f.type == FindingType.weakness).toList();
  }

  List<Finding> get opportunities {
    return findings.where((f) => f.type == FindingType.opportunity).toList();
  }

  List<Finding> get threats {
    return findings.where((f) => f.type == FindingType.threat).toList();
  }

  List<Insight> get highImpactInsights {
    return insights
        .where((i) => i.impact >= 0.7)
        .toList()
      ..sort((a, b) => b.impact.compareTo(a.impact));
  }

  List<Recommendation> get priorityRecommendations {
    return recommendations
        .where((r) => r.priority >= 0.7)
        .toList()
      ..sort((a, b) => b.priority.compareTo(a.priority));
  }

  String get confidenceLevel {
    if (confidence >= 0.9) return 'Very High';
    if (confidence >= 0.8) return 'High';
    if (confidence >= 0.7) return 'Good';
    if (confidence >= 0.6) return 'Moderate';
    if (confidence >= 0.5) return 'Fair';
    return 'Low';
  }

  String get executiveSummary {
    final keyPoints = <String>[];
    
    // Add top findings
    final topFindings = criticalFindings.take(3);
    for (final finding in topFindings) {
      keyPoints.add('${finding.type.displayName}: ${finding.title}');
    }
    
    // Add high impact insights
    final topInsights = highImpactInsights.take(2);
    for (final insight in topInsights) {
      keyPoints.add('Insight: ${insight.title}');
    }
    
    // Add priority recommendations
    final topRecommendations = priorityRecommendations.take(2);
    for (final recommendation in topRecommendations) {
      keyPoints.add('Recommendation: ${recommendation.title}');
    }
    
    return keyPoints.join('. ');
  }

  double get dataQualityScore => metadata.dataQuality;
  
  bool get isReliable => confidence >= 0.7 && dataQualityScore >= 0.8;

  Map<String, int> get findingDistribution {
    final distribution = <String, int>{};
    for (final finding in findings) {
      final type = finding.type.displayName;
      distribution[type] = (distribution[type] ?? 0) + 1;
    }
    return distribution;
  }

  Map<String, int> get insightDistribution {
    final distribution = <String, int>{};
    for (final insight in insights) {
      final type = insight.type.displayName;
      distribution[type] = (distribution[type] ?? 0) + 1;
    }
    return distribution;
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'analysisType': analysisType.name,
      'title': title,
      'description': description,
      'subject': subject.toJson(),
      'parameters': parameters.toJson(),
      'data': data.toJson(),
      'findings': findings.map((f) => f.toJson()).toList(),
      'insights': insights.map((i) => i.toJson()).toList(),
      'recommendations': recommendations.map((r) => r.toJson()).toList(),
      'visualizations': visualizations.map((v) => v.toJson()).toList(),
      'metadata': metadata.toJson(),
      'createdAt': createdAt?.millisecondsSinceEpoch,
      'completedAt': completedAt?.millisecondsSinceEpoch,
      'status': status.name,
      'errorMessage': errorMessage,
      'confidence': confidence,
      'rawData': rawData,
    };
  }

  static AnalysisResultModel fromFirestore(Map<String, dynamic> data) {
    return AnalysisResultModel(
      id: data['id'],
      analysisType: AnalysisType.values.firstWhere(
        (t) => t.name == data['analysisType'],
        orElse: () => AnalysisType.custom,
      ),
      title: data['title'],
      description: data['description'],
      subject: AnalysisSubject.fromJson(data['subject']),
      parameters: AnalysisParameters.fromJson(data['parameters']),
      data: AnalysisData.fromJson(data['data']),
      findings: (data['findings'] as List<dynamic>)
          .map((f) => Finding.fromJson(f))
          .toList(),
      insights: (data['insights'] as List<dynamic>)
          .map((i) => Insight.fromJson(i))
          .toList(),
      recommendations: (data['recommendations'] as List<dynamic>)
          .map((r) => Recommendation.fromJson(r))
          .toList(),
      visualizations: (data['visualizations'] as List<dynamic>?)
              ?.map((v) => Visualization.fromJson(v))
              .toList() ??
          [],
      metadata: AnalysisMetadata.fromJson(data['metadata']),
      createdAt: data['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(data['createdAt'])
          : null,
      completedAt: data['completedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(data['completedAt'])
          : null,
      status: AnalysisStatus.values.firstWhere(
        (s) => s.name == data['status'],
        orElse: () => AnalysisStatus.pending,
      ),
      errorMessage: data['errorMessage'],
      confidence: data['confidence']?.toDouble() ?? 0.0,
      rawData: Map<String, dynamic>.from(data['rawData'] ?? {}),
    );
  }
}