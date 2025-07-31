import 'package:freezed_annotation/freezed_annotation.dart';

part 'prediction_model.freezed.dart';
part 'prediction_model.g.dart';

@freezed
class PredictionModel with _$PredictionModel {
  const factory PredictionModel({
    required String id,
    required int fixtureId,
    required int homeTeamId,
    required int awayTeamId,
    required String homeTeamName,
    required String awayTeamName,
    required String competition,
    required DateTime matchDate,
    required PredictionResult prediction,
    required List<PredictionFactor> factors,
    required ModelConfidence confidence,
    @Default([]) List<ScenarioAnalysis> scenarios,
    @Default([]) List<KeyInsight> insights,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? modelVersion,
    @Default({}) Map<String, dynamic> metadata,
    ActualResult? actualResult,
    PredictionAccuracy? accuracy,
  }) = _PredictionModel;

  factory PredictionModel.fromJson(Map<String, dynamic> json) =>
      _$PredictionModelFromJson(json);
}

@freezed
class PredictionResult with _$PredictionResult {
  const factory PredictionResult({
    @Default(0.0) double homeWinProbability,
    @Default(0.0) double drawProbability,
    @Default(0.0) double awayWinProbability,
    required MatchOutcome predictedOutcome,
    @Default(0.0) double confidence,
    GoalsPrediction? goalsPrediction,
    ScorePrediction? scorePrediction,
    @Default([]) List<EventPrediction> eventPredictions,
    @Default(0.0) double over25Goals,
    @Default(0.0) double bothTeamsToScore,
    @Default(0.0) double cleanSheetHome,
    @Default(0.0) double cleanSheetAway,
  }) = _PredictionResult;

  factory PredictionResult.fromJson(Map<String, dynamic> json) =>
      _$PredictionResultFromJson(json);
}

@freezed
class PredictionFactor with _$PredictionFactor {
  const factory PredictionFactor({
    required String name,
    required FactorCategory category,
    @Default(0.0) double weight,
    @Default(0.0) double homeAdvantage,
    @Default(0.0) double awayAdvantage,
    @Default(0.0) double impact,
    String? description,
    @Default({}) Map<String, dynamic> details,
  }) = _PredictionFactor;

  factory PredictionFactor.fromJson(Map<String, dynamic> json) =>
      _$PredictionFactorFromJson(json);
}

@freezed
class ModelConfidence with _$ModelConfidence {
  const factory ModelConfidence({
    @Default(0.0) double overall,
    @Default(0.0) double resultConfidence,
    @Default(0.0) double scoreConfidence,
    @Default(0.0) double dataQuality,
    @Default(0.0) double modelReliability,
    @Default([]) List<ConfidenceFactor> factors,
    String? reasoning,
  }) = _ModelConfidence;

  factory ModelConfidence.fromJson(Map<String, dynamic> json) =>
      _$ModelConfidenceFromJson(json);
}

@freezed
class ScenarioAnalysis with _$ScenarioAnalysis {
  const factory ScenarioAnalysis({
    required String name,
    required String description,
    @Default(0.0) double probability,
    @Default(0.0) double homeWinProbability,
    @Default(0.0) double drawProbability,
    @Default(0.0) double awayWinProbability,
    @Default([]) List<String> conditions,
    @Default([]) List<String> implications,
  }) = _ScenarioAnalysis;

  factory ScenarioAnalysis.fromJson(Map<String, dynamic> json) =>
      _$ScenarioAnalysisFromJson(json);
}

@freezed
class KeyInsight with _$KeyInsight {
  const factory KeyInsight({
    required String title,
    required String description,
    required InsightType type,
    @Default(0.0) double importance,
    String? supportingData,
    @Default([]) List<String> tags,
  }) = _KeyInsight;

  factory KeyInsight.fromJson(Map<String, dynamic> json) =>
      _$KeyInsightFromJson(json);
}

@freezed
class GoalsPrediction with _$GoalsPrediction {
  const factory GoalsPrediction({
    @Default(0.0) double homeGoalsExpected,
    @Default(0.0) double awayGoalsExpected,
    @Default(0.0) double totalGoalsExpected,
    @Default(0.0) double homeGoalsVariance,
    @Default(0.0) double awayGoalsVariance,
    @Default([]) List<GoalRange> goalRanges,
  }) = _GoalsPrediction;

  factory GoalsPrediction.fromJson(Map<String, dynamic> json) =>
      _$GoalsPredictionFromJson(json);
}

@freezed
class ScorePrediction with _$ScorePrediction {
  const factory ScorePrediction({
    required String mostLikelyScore,
    @Default(0.0) double probability,
    @Default([]) List<ScoreOption> alternativeScores,
    @Default(0.0) double homeCleanSheetProbability,
    @Default(0.0) double awayCleanSheetProbability,
  }) = _ScorePrediction;

  factory ScorePrediction.fromJson(Map<String, dynamic> json) =>
      _$ScoreOptionFromJson(json);
}

@freezed
class ScoreOption with _$ScoreOption {
  const factory ScoreOption({
    required String score,
    @Default(0.0) double probability,
    required MatchOutcome outcome,
  }) = _ScoreOption;

  factory ScoreOption.fromJson(Map<String, dynamic> json) =>
      _$ScoreOptionFromJson(json);
}

@freezed
class EventPrediction with _$EventPrediction {
  const factory EventPrediction({
    required EventType type,
    @Default(0.0) double probability,
    String? team,
    String? player,
    String? timeFrame,
    @Default({}) Map<String, dynamic> details,
  }) = _EventPrediction;

  factory EventPrediction.fromJson(Map<String, dynamic> json) =>
      _$EventPredictionFromJson(json);
}

@freezed
class GoalRange with _$GoalRange {
  const factory GoalRange({
    required String range,
    @Default(0.0) double probability,
    required GoalRangeType type,
  }) = _GoalRange;

  factory GoalRange.fromJson(Map<String, dynamic> json) =>
      _$GoalRangeFromJson(json);
}

@freezed
class ConfidenceFactor with _$ConfidenceFactor {
  const factory ConfidenceFactor({
    required String name,
    @Default(0.0) double value,
    @Default(0.0) double impact,
    String? description,
  }) = _ConfidenceFactor;

  factory ConfidenceFactor.fromJson(Map<String, dynamic> json) =>
      _$ConfidenceFactorFromJson(json);
}

@freezed
class ActualResult with _$ActualResult {
  const factory ActualResult({
    required MatchOutcome outcome,
    required String finalScore,
    @Default(0) int homeGoals,
    @Default(0) int awayGoals,
    @Default([]) List<String> events,
    DateTime? resultTime,
  }) = _ActualResult;

  factory ActualResult.fromJson(Map<String, dynamic> json) =>
      _$ActualResultFromJson(json);
}

@freezed
class PredictionAccuracy with _$PredictionAccuracy {
  const factory PredictionAccuracy({
    @Default(false) bool correctOutcome,
    @Default(false) bool correctScore,
    @Default(0.0) double probabilityAccuracy,
    @Default(0.0) double goalsAccuracy,
    @Default([]) List<String> correctPredictions,
    @Default([]) List<String> incorrectPredictions,
    @Default(0.0) double overallAccuracy,
  }) = _PredictionAccuracy;

  factory PredictionAccuracy.fromJson(Map<String, dynamic> json) =>
      _$PredictionAccuracyFromJson(json);
}

@freezed
class PredictionAnalyticsModel with _$PredictionAnalyticsModel {
  const factory PredictionAnalyticsModel({
    required String modelId,
    required String modelName,
    required String version,
    @Default(0) int totalPredictions,
    @Default(0) int correctOutcomes,
    @Default(0) int correctScores,
    @Default(0.0) double outcomeAccuracy,
    @Default(0.0) double scoreAccuracy,
    @Default(0.0) double averageConfidence,
    @Default([]) List<AccuracyByCompetition> competitionAccuracy,
    @Default([]) List<AccuracyByTeam> teamAccuracy,
    @Default([]) List<PerformanceMetric> performanceMetrics,
    DateTime? lastUpdated,
  }) = _PredictionAnalyticsModel;

  factory PredictionAnalyticsModel.fromJson(Map<String, dynamic> json) =>
      _$PredictionAnalyticsModelFromJson(json);
}

@freezed
class AccuracyByCompetition with _$AccuracyByCompetition {
  const factory AccuracyByCompetition({
    required String competition,
    @Default(0) int predictions,
    @Default(0.0) double accuracy,
    @Default(0.0) double confidence,
  }) = _AccuracyByCompetition;

  factory AccuracyByCompetition.fromJson(Map<String, dynamic> json) =>
      _$AccuracyByCompetitionFromJson(json);
}

@freezed
class AccuracyByTeam with _$AccuracyByTeam {
  const factory AccuracyByTeam({
    required String teamName,
    @Default(0) int predictions,
    @Default(0.0) double accuracy,
    @Default(0.0) double homeAccuracy,
    @Default(0.0) double awayAccuracy,
  }) = _AccuracyByTeam;

  factory AccuracyByTeam.fromJson(Map<String, dynamic> json) =>
      _$AccuracyByTeamFromJson(json);
}

@freezed
class PerformanceMetric with _$PerformanceMetric {
  const factory PerformanceMetric({
    required String name,
    @Default(0.0) double value,
    String? unit,
    String? description,
    required MetricTrend trend,
  }) = _PerformanceMetric;

  factory PerformanceMetric.fromJson(Map<String, dynamic> json) =>
      _$PerformanceMetricFromJson(json);
}

enum MatchOutcome {
  homeWin,
  draw,
  awayWin,
}

enum FactorCategory {
  form,
  headToHead,
  statistics,
  injuries,
  motivation,
  external,
  tactical,
}

enum InsightType {
  strength,
  weakness,
  opportunity,
  threat,
  trend,
  anomaly,
}

enum EventType {
  goal,
  yellowCard,
  redCard,
  penalty,
  cornerKick,
  substitution,
}

enum GoalRangeType {
  home,
  away,
  total,
}

enum MetricTrend {
  improving,
  stable,
  declining,
}

extension MatchOutcomeX on MatchOutcome {
  String get displayName {
    switch (this) {
      case MatchOutcome.homeWin:
        return 'Home Win';
      case MatchOutcome.draw:
        return 'Draw';
      case MatchOutcome.awayWin:
        return 'Away Win';
    }
  }

  String get shortName {
    switch (this) {
      case MatchOutcome.homeWin:
        return '1';
      case MatchOutcome.draw:
        return 'X';
      case MatchOutcome.awayWin:
        return '2';
    }
  }

  String get symbol {
    switch (this) {
      case MatchOutcome.homeWin:
        return '🏠';
      case MatchOutcome.draw:
        return '🤝';
      case MatchOutcome.awayWin:
        return '✈️';
    }
  }
}

extension FactorCategoryX on FactorCategory {
  String get displayName {
    switch (this) {
      case FactorCategory.form:
        return 'Form';
      case FactorCategory.headToHead:
        return 'Head to Head';
      case FactorCategory.statistics:
        return 'Statistics';
      case FactorCategory.injuries:
        return 'Injuries';
      case FactorCategory.motivation:
        return 'Motivation';
      case FactorCategory.external:
        return 'External';
      case FactorCategory.tactical:
        return 'Tactical';
    }
  }

  String get icon {
    switch (this) {
      case FactorCategory.form:
        return '📈';
      case FactorCategory.headToHead:
        return '⚔️';
      case FactorCategory.statistics:
        return '📊';
      case FactorCategory.injuries:
        return '🏥';
      case FactorCategory.motivation:
        return '🔥';
      case FactorCategory.external:
        return '🌍';
      case FactorCategory.tactical:
        return '🎯';
    }
  }
}

extension InsightTypeX on InsightType {
  String get displayName {
    switch (this) {
      case InsightType.strength:
        return 'Strength';
      case InsightType.weakness:
        return 'Weakness';
      case InsightType.opportunity:
        return 'Opportunity';
      case InsightType.threat:
        return 'Threat';
      case InsightType.trend:
        return 'Trend';
      case InsightType.anomaly:
        return 'Anomaly';
    }
  }

  String get icon {
    switch (this) {
      case InsightType.strength:
        return '💪';
      case InsightType.weakness:
        return '⚠️';
      case InsightType.opportunity:
        return '🎯';
      case InsightType.threat:
        return '⚡';
      case InsightType.trend:
        return '📈';
      case InsightType.anomaly:
        return '🔍';
    }
  }
}

extension PredictionModelX on PredictionModel {
  MatchOutcome get mostLikelyOutcome {
    final homeProb = prediction.homeWinProbability;
    final drawProb = prediction.drawProbability;
    final awayProb = prediction.awayWinProbability;

    if (homeProb >= drawProb && homeProb >= awayProb) {
      return MatchOutcome.homeWin;
    } else if (drawProb >= homeProb && drawProb >= awayProb) {
      return MatchOutcome.draw;
    } else {
      return MatchOutcome.awayWin;
    }
  }

  double get highestProbability {
    return [
      prediction.homeWinProbability,
      prediction.drawProbability,
      prediction.awayWinProbability,
    ].reduce((a, b) => a > b ? a : b);
  }

  String get confidenceLevel {
    final overall = confidence.overall;
    if (overall >= 90) return 'Very High';
    if (overall >= 75) return 'High';
    if (overall >= 60) return 'Medium';
    if (overall >= 40) return 'Low';
    return 'Very Low';
  }

  bool get isHighConfidence => confidence.overall >= 75.0;
  bool get isLowConfidence => confidence.overall < 40.0;

  List<PredictionFactor> get topFactors {
    return factors
        .where((factor) => factor.impact.abs() >= 0.1)
        .toList()
      ..sort((a, b) => b.impact.abs().compareTo(a.impact.abs()));
  }

  List<KeyInsight> get importantInsights {
    return insights
        .where((insight) => insight.importance >= 0.7)
        .toList()
      ..sort((a, b) => b.importance.compareTo(a.importance));
  }

  String get predictionSummary {
    final outcome = mostLikelyOutcome;
    final probability = (highestProbability * 100).toStringAsFixed(1);
    final confidenceText = confidenceLevel.toLowerCase();
    
    return '${outcome.displayName} (${probability}%) with $confidenceText confidence';
  }

  bool get hasActualResult => actualResult != null;

  bool get predictionWasCorrect {
    if (!hasActualResult) return false;
    return mostLikelyOutcome == actualResult!.outcome;
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'fixtureId': fixtureId,
      'homeTeamId': homeTeamId,
      'awayTeamId': awayTeamId,
      'homeTeamName': homeTeamName,
      'awayTeamName': awayTeamName,
      'competition': competition,
      'matchDate': matchDate.millisecondsSinceEpoch,
      'prediction': prediction.toJson(),
      'factors': factors.map((f) => f.toJson()).toList(),
      'confidence': confidence.toJson(),
      'scenarios': scenarios.map((s) => s.toJson()).toList(),
      'insights': insights.map((i) => i.toJson()).toList(),
      'createdAt': createdAt?.millisecondsSinceEpoch,
      'updatedAt': updatedAt?.millisecondsSinceEpoch,
      'modelVersion': modelVersion,
      'metadata': metadata,
      'actualResult': actualResult?.toJson(),
      'accuracy': accuracy?.toJson(),
    };
  }

  static PredictionModel fromFirestore(Map<String, dynamic> data) {
    return PredictionModel(
      id: data['id'],
      fixtureId: data['fixtureId'],
      homeTeamId: data['homeTeamId'],
      awayTeamId: data['awayTeamId'],
      homeTeamName: data['homeTeamName'],
      awayTeamName: data['awayTeamName'],
      competition: data['competition'],
      matchDate: DateTime.fromMillisecondsSinceEpoch(data['matchDate']),
      prediction: PredictionResult.fromJson(data['prediction']),
      factors: (data['factors'] as List<dynamic>)
          .map((f) => PredictionFactor.fromJson(f))
          .toList(),
      confidence: ModelConfidence.fromJson(data['confidence']),
      scenarios: (data['scenarios'] as List<dynamic>?)
              ?.map((s) => ScenarioAnalysis.fromJson(s))
              .toList() ??
          [],
      insights: (data['insights'] as List<dynamic>?)
              ?.map((i) => KeyInsight.fromJson(i))
              .toList() ??
          [],
      createdAt: data['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(data['createdAt'])
          : null,
      updatedAt: data['updatedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(data['updatedAt'])
          : null,
      modelVersion: data['modelVersion'],
      metadata: Map<String, dynamic>.from(data['metadata'] ?? {}),
      actualResult: data['actualResult'] != null
          ? ActualResult.fromJson(data['actualResult'])
          : null,
      accuracy: data['accuracy'] != null
          ? PredictionAccuracy.fromJson(data['accuracy'])
          : null,
    );
  }
}

extension PredictionAnalyticsModelX on PredictionAnalyticsModel {
  double get overallAccuracy => totalPredictions > 0 ? (correctOutcomes / totalPredictions) * 100 : 0.0;
  
  double get scoreAccuracyRate => totalPredictions > 0 ? (correctScores / totalPredictions) * 100 : 0.0;

  String get performanceLevel {
    final accuracy = overallAccuracy;
    if (accuracy >= 70) return 'Excellent';
    if (accuracy >= 60) return 'Good';
    if (accuracy >= 50) return 'Average';
    if (accuracy >= 40) return 'Below Average';
    return 'Poor';
  }

  bool get isPerformingWell => overallAccuracy >= 60.0;
  bool get needsImprovement => overallAccuracy < 50.0;

  AccuracyByCompetition? getBestCompetition() {
    if (competitionAccuracy.isEmpty) return null;
    return competitionAccuracy.reduce((a, b) => a.accuracy > b.accuracy ? a : b);
  }

  AccuracyByCompetition? getWorstCompetition() {
    if (competitionAccuracy.isEmpty) return null;
    return competitionAccuracy.reduce((a, b) => a.accuracy < b.accuracy ? a : b);
  }

  Map<String, dynamic> toFirestore() {
    return {
      'modelId': modelId,
      'modelName': modelName,
      'version': version,
      'totalPredictions': totalPredictions,
      'correctOutcomes': correctOutcomes,
      'correctScores': correctScores,
      'outcomeAccuracy': outcomeAccuracy,
      'scoreAccuracy': scoreAccuracy,
      'averageConfidence': averageConfidence,
      'competitionAccuracy': competitionAccuracy.map((c) => c.toJson()).toList(),
      'teamAccuracy': teamAccuracy.map((t) => t.toJson()).toList(),
      'performanceMetrics': performanceMetrics.map((p) => p.toJson()).toList(),
      'lastUpdated': lastUpdated?.millisecondsSinceEpoch,
    };
  }

  static PredictionAnalyticsModel fromFirestore(Map<String, dynamic> data) {
    return PredictionAnalyticsModel(
      modelId: data['modelId'],
      modelName: data['modelName'],
      version: data['version'],
      totalPredictions: data['totalPredictions'] ?? 0,
      correctOutcomes: data['correctOutcomes'] ?? 0,
      correctScores: data['correctScores'] ?? 0,
      outcomeAccuracy: data['outcomeAccuracy']?.toDouble() ?? 0.0,
      scoreAccuracy: data['scoreAccuracy']?.toDouble() ?? 0.0,
      averageConfidence: data['averageConfidence']?.toDouble() ?? 0.0,
      competitionAccuracy: (data['competitionAccuracy'] as List<dynamic>?)
              ?.map((c) => AccuracyByCompetition.fromJson(c))
              .toList() ??
          [],
      teamAccuracy: (data['teamAccuracy'] as List<dynamic>?)
              ?.map((t) => AccuracyByTeam.fromJson(t))
              .toList() ??
          [],
      performanceMetrics: (data['performanceMetrics'] as List<dynamic>?)
              ?.map((p) => PerformanceMetric.fromJson(p))
              .toList() ??
          [],
      lastUpdated: data['lastUpdated'] != null
          ? DateTime.fromMillisecondsSinceEpoch(data['lastUpdated'])
          : null,
    );
  }
}