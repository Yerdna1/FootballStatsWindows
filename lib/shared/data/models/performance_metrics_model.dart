import 'package:freezed_annotation/freezed_annotation.dart';

part 'performance_metrics_model.freezed.dart';
part 'performance_metrics_model.g.dart';

@freezed
class PerformanceMetricsModel with _$PerformanceMetricsModel {
  const factory PerformanceMetricsModel({
    required String id,
    required int entityId,
    required MetricsType type,
    required String entityName,
    required int seasonId,
    required String competition,
    DateTime? periodStart,
    DateTime? periodEnd,
    required OverallPerformance overall,
    required AttackingMetrics attacking,
    required DefensiveMetrics defensive,
    required PhysicalMetrics physical,
    required MentalMetrics mental,
    required TechnicalMetrics technical,
    @Default([]) List<PerformanceIndicator> indicators,
    @Default([]) List<BenchmarkComparison> benchmarks,
    @Default([]) List<TrendAnalysis> trends,
    DateTime? lastUpdated,
    @Default({}) Map<String, dynamic> customMetrics,
  }) = _PerformanceMetricsModel;

  factory PerformanceMetricsModel.fromJson(Map<String, dynamic> json) =>
      _$PerformanceMetricsModelFromJson(json);
}

@freezed
class OverallPerformance with _$OverallPerformance {
  const factory OverallPerformance({
    @Default(0.0) double overallRating,
    @Default(0.0) double consistency,
    @Default(0.0) double reliability,
    @Default(0.0) double peakPerformance,
    @Default(0.0) double averagePerformance,
    @Default(0.0) double worstPerformance,
    @Default(0.0) double improvementRate,
    @Default(0.0) double formIndex,
    @Default(0.0) double experienceLevel,
    @Default(0.0) double adaptability,
    required PerformanceCategory category,
    @Default([]) List<String> strengths,
    @Default([]) List<String> weaknesses,
  }) = _OverallPerformance;

  factory OverallPerformance.fromJson(Map<String, dynamic> json) =>
      _$OverallPerformanceFromJson(json);
}

@freezed
class AttackingMetrics with _$AttackingMetrics {
  const factory AttackingMetrics({
    @Default(0.0) double attackingRating,
    @Default(0.0) double goalThreat,
    @Default(0.0) double creativity,
    @Default(0.0) double finishing,
    @Default(0.0) double positioning,
    @Default(0.0) double movement,
    @Default(0.0) double linkUpPlay,
    @Default(0.0) double counterAttacking,
    @Default(0.0) double setPieceAbility,
    @Default(0.0) double pressureHandling,
    @Default([]) List<AttackingStrength> strengths,
    @Default([]) List<AttackingWeakness> weaknesses,
  }) = _AttackingMetrics;

  factory AttackingMetrics.fromJson(Map<String, dynamic> json) =>
      _$AttackingMetricsFromJson(json);
}

@freezed
class DefensiveMetrics with _$DefensiveMetrics {
  const factory DefensiveMetrics({
    @Default(0.0) double defensiveRating,
    @Default(0.0) double tacklingAbility,
    @Default(0.0) double interceptionSkill,
    @Default(0.0) double aerialAbility,
    @Default(0.0) double positioning,
    @Default(0.0) double anticipation,
    @Default(0.0) double markingTightness,
    @Default(0.0) double recoverySpeed,
    @Default(0.0) double pressureApplication,
    @Default(0.0) double organizationalSkill,
    @Default([]) List<DefensiveStrength> strengths,
    @Default([]) List<DefensiveWeakness> weaknesses,
  }) = _DefensiveMetrics;

  factory DefensiveMetrics.fromJson(Map<String, dynamic> json) =>
      _$DefensiveMetricsFromJson(json);
}

@freezed
class PhysicalMetrics with _$PhysicalMetrics {
  const factory PhysicalMetrics({
    @Default(0.0) double physicalRating,
    @Default(0.0) double pace,
    @Default(0.0) double acceleration,
    @Default(0.0) double stamina,
    @Default(0.0) double strength,
    @Default(0.0) double agility,
    @Default(0.0) double balance,
    @Default(0.0) double jumpingReach,
    @Default(0.0) double durability,
    @Default(0.0) double workRate,
    @Default([]) List<PhysicalAttribute> attributes,
    InjuryHistory? injuryHistory,
  }) = _PhysicalMetrics;

  factory PhysicalMetrics.fromJson(Map<String, dynamic> json) =>
      _$PhysicalMetricsFromJson(json);
}

@freezed
class MentalMetrics with _$MentalMetrics {
  const factory MentalMetrics({
    @Default(0.0) double mentalRating,
    @Default(0.0) double decisionMaking,
    @Default(0.0) double composure,
    @Default(0.0) double concentration,
    @Default(0.0) double determination,
    @Default(0.0) double leadership,
    @Default(0.0) double teamwork,
    @Default(0.0) double adaptability,
    @Default(0.0) double pressureHandling,
    @Default(0.0) double motivation,
    @Default([]) List<MentalAttribute> attributes,
    @Default([]) List<String> mentalStrengths,
    @Default([]) List<String> mentalWeaknesses,
  }) = _MentalMetrics;

  factory MentalMetrics.fromJson(Map<String, dynamic> json) =>
      _$MentalMetricsFromJson(json);
}

@freezed
class TechnicalMetrics with _$TechnicalMetrics {
  const factory TechnicalMetrics({
    @Default(0.0) double technicalRating,
    @Default(0.0) double ballControl,
    @Default(0.0) double firstTouch,
    @Default(0.0) double passing,
    @Default(0.0) double shooting,
    @Default(0.0) double crossing,
    @Default(0.0) double dribbling,
    @Default(0.0) double technique,
    @Default(0.0) double vision,
    @Default(0.0) double setPlayDelivery,
    @Default([]) List<TechnicalSkill> skills,
    @Default([]) List<String> specialties,
  }) = _TechnicalMetrics;

  factory TechnicalMetrics.fromJson(Map<String, dynamic> json) =>
      _$TechnicalMetricsFromJson(json);
}

@freezed
class PerformanceIndicator with _$PerformanceIndicator {
  const factory PerformanceIndicator({
    required String name,
    required IndicatorCategory category,
    @Default(0.0) double value,
    @Default(0.0) double target,
    @Default(0.0) double benchmark,
    @Default(0.0) double percentile,
    required IndicatorStatus status,
    required TrendDirection trend,
    String? unit,
    String? description,
    DateTime? lastUpdated,
  }) = _PerformanceIndicator;

  factory PerformanceIndicator.fromJson(Map<String, dynamic> json) =>
      _$PerformanceIndicatorFromJson(json);
}

@freezed
class BenchmarkComparison with _$BenchmarkComparison {
  const factory BenchmarkComparison({
    required String metric,
    @Default(0.0) double playerValue,
    @Default(0.0) double teamAverage,
    @Default(0.0) double leagueAverage,
    @Default(0.0) double eliteLevel,
    @Default(0.0) double percentileRank,
    required ComparisonResult vsTeam,
    required ComparisonResult vsLeague,
    required ComparisonResult vsElite,
    String? interpretation,
  }) = _BenchmarkComparison;

  factory BenchmarkComparison.fromJson(Map<String, dynamic> json) =>
      _$BenchmarkComparisonFromJson(json);
}

@freezed
class TrendAnalysis with _$TrendAnalysis {
  const factory TrendAnalysis({
    required String metric,
    required String period,
    @Default([]) List<DataPoint> dataPoints,
    @Default(0.0) double startValue,
    @Default(0.0) double endValue,
    @Default(0.0) double change,
    @Default(0.0) double changePercentage,
    required TrendDirection direction,
    @Default(0.0) double volatility,
    @Default(0.0) double r2,
    String? interpretation,
    @Default([]) List<String> influencingFactors,
  }) = _TrendAnalysis;

  factory TrendAnalysis.fromJson(Map<String, dynamic> json) =>
      _$TrendAnalysisFromJson(json);
}

@freezed
class AttackingStrength with _$AttackingStrength {
  const factory AttackingStrength({
    required String name,
    @Default(0.0) double rating,
    String? description,
  }) = _AttackingStrength;

  factory AttackingStrength.fromJson(Map<String, dynamic> json) =>
      _$AttackingStrengthFromJson(json);
}

@freezed
class AttackingWeakness with _$AttackingWeakness {
  const factory AttackingWeakness({
    required String name,
    @Default(0.0) double severity,
    String? description,
  }) = _AttackingWeakness;

  factory AttackingWeakness.fromJson(Map<String, dynamic> json) =>
      _$AttackingWeaknessFromJson(json);
}

@freezed
class DefensiveStrength with _$DefensiveStrength {
  const factory DefensiveStrength({
    required String name,
    @Default(0.0) double rating,
    String? description,
  }) = _DefensiveStrength;

  factory DefensiveStrength.fromJson(Map<String, dynamic> json) =>
      _$DefensiveStrengthFromJson(json);
}

@freezed
class DefensiveWeakness with _$DefensiveWeakness {
  const factory DefensiveWeakness({
    required String name,
    @Default(0.0) double severity,
    String? description,
  }) = _DefensiveWeakness;

  factory DefensiveWeakness.fromJson(Map<String, dynamic> json) =>
      _$DefensiveWeaknessFromJson(json);
}

@freezed
class PhysicalAttribute with _$PhysicalAttribute {
  const factory PhysicalAttribute({
    required String name,
    @Default(0.0) double value,
    @Default(0.0) double benchmark,
    String? unit,
  }) = _PhysicalAttribute;

  factory PhysicalAttribute.fromJson(Map<String, dynamic> json) =>
      _$PhysicalAttributeFromJson(json);
}

@freezed
class MentalAttribute with _$MentalAttribute {
  const factory MentalAttribute({
    required String name,
    @Default(0.0) double value,
    @Default(0.0) double importance,
    String? description,
  }) = _MentalAttribute;

  factory MentalAttribute.fromJson(Map<String, dynamic> json) =>
      _$MentalAttributeFromJson(json);
}

@freezed
class TechnicalSkill with _$TechnicalSkill {
  const factory TechnicalSkill({
    required String name,
    @Default(0.0) double proficiency,
    @Default(0.0) double consistency,
    String? description,
  }) = _TechnicalSkill;

  factory TechnicalSkill.fromJson(Map<String, dynamic> json) =>
      _$TechnicalSkillFromJson(json);
}

@freezed
class InjuryHistory with _$InjuryHistory {
  const factory InjuryHistory({
    @Default(0) int totalInjuries,
    @Default(0) int daysInjured,
    @Default(0) int muscularInjuries,
    @Default(0) int contactInjuries,
    @Default(0.0) double injuryProneness,
    @Default(0.0) double recoveryRate,
    @Default([]) List<InjuryRecord> recentInjuries,
  }) = _InjuryHistory;

  factory InjuryHistory.fromJson(Map<String, dynamic> json) =>
      _$InjuryHistoryFromJson(json);
}

@freezed
class InjuryRecord with _$InjuryRecord {
  const factory InjuryRecord({
    required String type,
    required DateTime date,
    @Default(0) int daysOut,
    String? severity,
    String? bodyPart,
  }) = _InjuryRecord;

  factory InjuryRecord.fromJson(Map<String, dynamic> json) =>
      _$InjuryRecordFromJson(json);
}

@freezed
class DataPoint with _$DataPoint {
  const factory DataPoint({
    required DateTime date,
    @Default(0.0) double value,
    String? context,
  }) = _DataPoint;

  factory DataPoint.fromJson(Map<String, dynamic> json) =>
      _$DataPointFromJson(json);
}

enum MetricsType {
  player,
  team,
  goalkeeper,
}

enum PerformanceCategory {
  worldClass,
  excellent,
  veryGood,
  good,
  average,
  belowAverage,
  poor,
}

enum IndicatorCategory {
  attacking,
  defensive,
  physical,
  mental,
  technical,
  overall,
}

enum IndicatorStatus {
  excellent,
  good,
  average,
  needsImprovement,
  concerning,
}

enum TrendDirection {
  increasing,
  decreasing,
  stable,
  volatile,
}

enum ComparisonResult {
  muchBetter,
  better,
  similar,
  worse,
  muchWorse,
}

extension MetricsTypeX on MetricsType {
  String get displayName {
    switch (this) {
      case MetricsType.player:
        return 'Player';
      case MetricsType.team:
        return 'Team';
      case MetricsType.goalkeeper:
        return 'Goalkeeper';
    }
  }
}

extension PerformanceCategoryX on PerformanceCategory {
  String get displayName {
    switch (this) {
      case PerformanceCategory.worldClass:
        return 'World Class';
      case PerformanceCategory.excellent:
        return 'Excellent';
      case PerformanceCategory.veryGood:
        return 'Very Good';
      case PerformanceCategory.good:
        return 'Good';
      case PerformanceCategory.average:
        return 'Average';
      case PerformanceCategory.belowAverage:
        return 'Below Average';
      case PerformanceCategory.poor:
        return 'Poor';
    }
  }

  String get icon {
    switch (this) {
      case PerformanceCategory.worldClass:
        return '🌟';
      case PerformanceCategory.excellent:
        return '⭐';
      case PerformanceCategory.veryGood:
        return '🔥';
      case PerformanceCategory.good:
        return '👍';
      case PerformanceCategory.average:
        return '👌';
      case PerformanceCategory.belowAverage:
        return '👎';
      case PerformanceCategory.poor:
        return '⚠️';
    }
  }

  double get minRating {
    switch (this) {
      case PerformanceCategory.worldClass:
        return 95.0;
      case PerformanceCategory.excellent:
        return 85.0;
      case PerformanceCategory.veryGood:
        return 75.0;
      case PerformanceCategory.good:
        return 65.0;
      case PerformanceCategory.average:
        return 50.0;
      case PerformanceCategory.belowAverage:
        return 35.0;
      case PerformanceCategory.poor:
        return 0.0;
    }
  }
}

extension IndicatorStatusX on IndicatorStatus {
  String get displayName {
    switch (this) {
      case IndicatorStatus.excellent:
        return 'Excellent';
      case IndicatorStatus.good:
        return 'Good';
      case IndicatorStatus.average:
        return 'Average';
      case IndicatorStatus.needsImprovement:
        return 'Needs Improvement';
      case IndicatorStatus.concerning:
        return 'Concerning';
    }
  }

  String get icon {
    switch (this) {
      case IndicatorStatus.excellent:
        return '🟢';
      case IndicatorStatus.good:
        return '🔵';
      case IndicatorStatus.average:
        return '🟡';
      case IndicatorStatus.needsImprovement:
        return '🟠';
      case IndicatorStatus.concerning:
        return '🔴';
    }
  }
}

extension TrendDirectionX on TrendDirection {
  String get displayName {
    switch (this) {
      case TrendDirection.increasing:
        return 'Increasing';
      case TrendDirection.decreasing:
        return 'Decreasing';
      case TrendDirection.stable:
        return 'Stable';
      case TrendDirection.volatile:
        return 'Volatile';
    }
  }

  String get icon {
    switch (this) {
      case TrendDirection.increasing:
        return '📈';
      case TrendDirection.decreasing:
        return '📉';
      case TrendDirection.stable:
        return '➡️';
      case TrendDirection.volatile:
        return '📊';
    }
  }
}

extension ComparisonResultX on ComparisonResult {
  String get displayName {
    switch (this) {
      case ComparisonResult.muchBetter:
        return 'Much Better';
      case ComparisonResult.better:
        return 'Better';
      case ComparisonResult.similar:
        return 'Similar';
      case ComparisonResult.worse:
        return 'Worse';
      case ComparisonResult.muchWorse:
        return 'Much Worse';
    }
  }

  String get icon {
    switch (this) {
      case ComparisonResult.muchBetter:
        return '⬆️⬆️';
      case ComparisonResult.better:
        return '⬆️';
      case ComparisonResult.similar:
        return '↔️';
      case ComparisonResult.worse:
        return '⬇️';
      case ComparisonResult.muchWorse:
        return '⬇️⬇️';
    }
  }
}

extension PerformanceMetricsModelX on PerformanceMetricsModel {
  List<PerformanceIndicator> get excellentIndicators {
    return indicators.where((i) => i.status == IndicatorStatus.excellent).toList();
  }

  List<PerformanceIndicator> get concerningIndicators {
    return indicators.where((i) => i.status == IndicatorStatus.concerning).toList();
  }

  List<PerformanceIndicator> get improvingTrends {
    return indicators.where((i) => i.trend == TrendDirection.increasing).toList();
  }

  List<PerformanceIndicator> get decliningTrends {
    return indicators.where((i) => i.trend == TrendDirection.decreasing).toList();
  }

  double get averageRating {
    final ratings = [
      overall.overallRating,
      attacking.attackingRating,
      defensive.defensiveRating,
      physical.physicalRating,
      mental.mentalRating,
      technical.technicalRating,
    ];
    return ratings.fold(0.0, (sum, rating) => sum + rating) / ratings.length;
  }

  String get overallAssessment {
    final rating = averageRating;
    if (rating >= 90) return 'Outstanding performer with exceptional abilities';
    if (rating >= 80) return 'Excellent performer with strong capabilities';
    if (rating >= 70) return 'Very good performer with solid skills';
    if (rating >= 60) return 'Good performer with decent abilities';
    if (rating >= 50) return 'Average performer with room for improvement';
    return 'Below average performer needing significant development';
  }

  List<String> get topStrengths {
    final allStrengths = <String>[];
    allStrengths.addAll(overall.strengths);
    allStrengths.addAll(attacking.strengths.map((s) => s.name));
    allStrengths.addAll(defensive.strengths.map((s) => s.name));
    return allStrengths.take(5).toList();
  }

  List<String> get keyWeaknesses {
    final allWeaknesses = <String>[];
    allWeaknesses.addAll(overall.weaknesses);
    allWeaknesses.addAll(attacking.weaknesses.map((w) => w.name));
    allWeaknesses.addAll(defensive.weaknesses.map((w) => w.name));
    return allWeaknesses.take(5).toList();
  }

  List<BenchmarkComparison> get aboveBenchmarkMetrics {
    return benchmarks.where((b) => 
        b.vsLeague == ComparisonResult.better || 
        b.vsLeague == ComparisonResult.muchBetter
    ).toList();
  }

  List<BenchmarkComparison> get belowBenchmarkMetrics {
    return benchmarks.where((b) => 
        b.vsLeague == ComparisonResult.worse || 
        b.vsLeague == ComparisonResult.muchWorse
    ).toList();
  }

  bool get isElitePerformer => overall.category == PerformanceCategory.worldClass;
  bool get isConsistentPerformer => overall.consistency >= 75.0;
  bool get needsDevelopment => concerningIndicators.length > excellentIndicators.length;

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'entityId': entityId,
      'type': type.name,
      'entityName': entityName,
      'seasonId': seasonId,
      'competition': competition,
      'periodStart': periodStart?.millisecondsSinceEpoch,
      'periodEnd': periodEnd?.millisecondsSinceEpoch,
      'overall': overall.toJson(),
      'attacking': attacking.toJson(),
      'defensive': defensive.toJson(),
      'physical': physical.toJson(),
      'mental': mental.toJson(),
      'technical': technical.toJson(),
      'indicators': indicators.map((i) => i.toJson()).toList(),
      'benchmarks': benchmarks.map((b) => b.toJson()).toList(),
      'trends': trends.map((t) => t.toJson()).toList(),
      'lastUpdated': lastUpdated?.millisecondsSinceEpoch,
      'customMetrics': customMetrics,
    };
  }

  static PerformanceMetricsModel fromFirestore(Map<String, dynamic> data) {
    return PerformanceMetricsModel(
      id: data['id'],
      entityId: data['entityId'],
      type: MetricsType.values.firstWhere(
        (t) => t.name == data['type'],
        orElse: () => MetricsType.player,
      ),
      entityName: data['entityName'],
      seasonId: data['seasonId'],
      competition: data['competition'],
      periodStart: data['periodStart'] != null
          ? DateTime.fromMillisecondsSinceEpoch(data['periodStart'])
          : null,
      periodEnd: data['periodEnd'] != null
          ? DateTime.fromMillisecondsSinceEpoch(data['periodEnd'])
          : null,
      overall: OverallPerformance.fromJson(data['overall']),
      attacking: AttackingMetrics.fromJson(data['attacking']),
      defensive: DefensiveMetrics.fromJson(data['defensive']),
      physical: PhysicalMetrics.fromJson(data['physical']),
      mental: MentalMetrics.fromJson(data['mental']),
      technical: TechnicalMetrics.fromJson(data['technical']),
      indicators: (data['indicators'] as List<dynamic>?)
              ?.map((i) => PerformanceIndicator.fromJson(i))
              .toList() ??
          [],
      benchmarks: (data['benchmarks'] as List<dynamic>?)
              ?.map((b) => BenchmarkComparison.fromJson(b))
              .toList() ??
          [],
      trends: (data['trends'] as List<dynamic>?)
              ?.map((t) => TrendAnalysis.fromJson(t))
              .toList() ??
          [],
      lastUpdated: data['lastUpdated'] != null
          ? DateTime.fromMillisecondsSinceEpoch(data['lastUpdated'])
          : null,
      customMetrics: Map<String, dynamic>.from(data['customMetrics'] ?? {}),
    );
  }
}