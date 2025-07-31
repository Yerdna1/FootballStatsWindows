import 'package:freezed_annotation/freezed_annotation.dart';

part 'advanced_statistics_model.freezed.dart';
part 'advanced_statistics_model.g.dart';

@freezed
class AdvancedStatisticsModel with _$AdvancedStatisticsModel {
  const factory AdvancedStatisticsModel({
    required int entityId,
    required StatisticsType type,
    required String entityName,
    required int seasonId,
    required String competition,
    DateTime? periodStart,
    DateTime? periodEnd,
    required MatchStatistics matchStats,
    required GoalStatistics goalStats,
    required DefensiveStatistics defensiveStats,
    required PassingStatistics passingStats,
    required PossessionStatistics possessionStats,
    required SetPieceStatistics setPieceStats,
    required DisciplinaryStatistics disciplinaryStats,
    @Default([]) List<PerformanceMetric> performanceMetrics,
    @Default([]) List<ComparisonMetric> comparisons,
    DateTime? lastUpdated,
    @Default(0.0) double overallRating,
    @Default(0.0) double formRating,
    @Default(0.0) double strengthIndex,
  }) = _AdvancedStatisticsModel;

  factory AdvancedStatisticsModel.fromJson(Map<String, dynamic> json) =>
      _$AdvancedStatisticsModelFromJson(json);
}

@freezed
class MatchStatistics with _$MatchStatistics {
  const factory MatchStatistics({
    @Default(0) int played,
    @Default(0) int won,
    @Default(0) int drawn,
    @Default(0) int lost,
    @Default(0) int points,
    @Default(0.0) double winPercentage,
    @Default(0.0) double drawPercentage,
    @Default(0.0) double lossPercentage,
    @Default(0.0) double pointsPerGame,
    @Default(0) int homeWins,
    @Default(0) int homeDraws,
    @Default(0) int homeLosses,
    @Default(0) int awayWins,
    @Default(0) int awayDraws,
    @Default(0) int awayLosses,
    @Default(0.0) double homeWinPercentage,
    @Default(0.0) double awayWinPercentage,
    @Default(0) int cleanSheets,
    @Default(0.0) double cleanSheetPercentage,
    @Default(0) int failedToScore,
    @Default(0.0) double failedToScorePercentage,
  }) = _MatchStatistics;

  factory MatchStatistics.fromJson(Map<String, dynamic> json) =>
      _$MatchStatisticsFromJson(json);
}

@freezed
class GoalStatistics with _$GoalStatistics {
  const factory GoalStatistics({
    @Default(0) int goalsScored,
    @Default(0) int goalsConceded,
    @Default(0) int goalDifference,
    @Default(0.0) double goalsPerGame,
    @Default(0.0) double goalsConcededPerGame,
    @Default(0.0) double expectedGoals,
    @Default(0.0) double expectedGoalsAgainst,
    @Default(0.0) double goalConversionRate,
    @Default(0) int shotsTotal,
    @Default(0) int shotsOnTarget,
    @Default(0.0) double shotsPerGame,
    @Default(0.0) double shotsOnTargetPerGame,
    @Default(0.0) double shotAccuracy,
    @Default(0) int bigChances,
    @Default(0) int bigChancesScored,
    @Default(0.0) double bigChanceConversion,
    @Default(0) int firstHalfGoals,
    @Default(0) int secondHalfGoals,
    @Default(0) int goals0to15,
    @Default(0) int goals16to30,
    @Default(0) int goals31to45,
    @Default(0) int goals46to60,
    @Default(0) int goals61to75,
    @Default(0) int goals76to90,
    @Default(0) int penaltiesScored,
    @Default(0) int penaltiesMissed,
    @Default(0.0) double penaltyConversionRate,
  }) = _GoalStatistics;

  factory GoalStatistics.fromJson(Map<String, dynamic> json) =>
      _$GoalStatisticsFromJson(json);
}

@freezed
class DefensiveStatistics with _$DefensiveStatistics {
  const factory DefensiveStatistics({
    @Default(0) int tackles,
    @Default(0) int tacklesWon,
    @Default(0.0) double tackleSuccessRate,
    @Default(0) int interceptions,
    @Default(0.0) double interceptionsPerGame,
    @Default(0) int clearances,
    @Default(0.0) double clearancesPerGame,
    @Default(0) int blocks,
    @Default(0.0) double blocksPerGame,
    @Default(0) int aerialDuels,
    @Default(0) int aerialDuelsWon,
    @Default(0.0) double aerialSuccessRate,
    @Default(0) int duels,
    @Default(0) int duelsWon,
    @Default(0.0) double duelSuccessRate,
    @Default(0) int errors,
    @Default(0.0) double errorsPerGame,
    @Default(0.0) double defensiveRating,
    @Default(0.0) double pressureIntensity,
    @Default(0.0) double defensiveStability,
  }) = _DefensiveStatistics;

  factory DefensiveStatistics.fromJson(Map<String, dynamic> json) =>
      _$DefensiveStatisticsFromJson(json);
}

@freezed
class PassingStatistics with _$PassingStatistics {
  const factory PassingStatistics({
    @Default(0) int passes,
    @Default(0) int passesCompleted,
    @Default(0.0) double passAccuracy,
    @Default(0.0) double passesPerGame,
    @Default(0) int shortPasses,
    @Default(0) int shortPassesCompleted,
    @Default(0.0) double shortPassAccuracy,
    @Default(0) int mediumPasses,
    @Default(0) int mediumPassesCompleted,
    @Default(0.0) double mediumPassAccuracy,
    @Default(0) int longPasses,
    @Default(0) int longPassesCompleted,
    @Default(0.0) double longPassAccuracy,
    @Default(0) int keyPasses,
    @Default(0.0) double keyPassesPerGame,
    @Default(0) int assists,
    @Default(0.0) double assistsPerGame,
    @Default(0) int crosses,
    @Default(0) int crossesCompleted,
    @Default(0.0) double crossAccuracy,
    @Default(0) int throughBalls,
    @Default(0) int throughBallsCompleted,
    @Default(0.0) double throughBallAccuracy,
    @Default(0.0) double creativityIndex,
    @Default(0.0) double passingRating,
  }) = _PassingStatistics;

  factory PassingStatistics.fromJson(Map<String, dynamic> json) =>
      _$PassingStatisticsFromJson(json);
}

@freezed
class PossessionStatistics with _$PossessionStatistics {
  const factory PossessionStatistics({
    @Default(0.0) double possessionPercentage,
    @Default(0.0) double avgPossessionPerGame,
    @Default(0) int touches,
    @Default(0.0) double touchesPerGame,
    @Default(0) int attackingThirdTouches,
    @Default(0) int finalThirdEntries,
    @Default(0.0) double finalThirdEntriesPerGame,
    @Default(0) int penaltyAreaEntries,
    @Default(0.0) double penaltyAreaEntriesPerGame,
    @Default(0) int dribbles,
    @Default(0) int dribblesCompleted,
    @Default(0.0) double dribbleSuccessRate,
    @Default(0) int ballRecoveries,
    @Default(0.0) double ballRecoveriesPerGame,
    @Default(0) int dispossessed,
    @Default(0.0) double dispossessedPerGame,
    @Default(0.0) double possessionQuality,
    @Default(0.0) double territorialDominance,
  }) = _PossessionStatistics;

  factory PossessionStatistics.fromJson(Map<String, dynamic> json) =>
      _$PossessionStatisticsFromJson(json);
}

@freezed
class SetPieceStatistics with _$SetPieceStatistics {
  const factory SetPieceStatistics({
    @Default(0) int corners,
    @Default(0) int cornersWon,
    @Default(0.0) double cornersPerGame,
    @Default(0) int cornerGoals,
    @Default(0.0) double cornerConversionRate,
    @Default(0) int freeKicks,
    @Default(0) int freeKickGoals,
    @Default(0.0) double freeKickConversionRate,
    @Default(0) int throwIns,
    @Default(0.0) double throwInsPerGame,
    @Default(0) int offside,
    @Default(0.0) double offsidePerGame,
    @Default(0.0) double setPieceEfficiency,
    @Default(0.0) double setPieceDefenseRating,
  }) = _SetPieceStatistics;

  factory SetPieceStatistics.fromJson(Map<String, dynamic> json) =>
      _$SetPieceStatisticsFromJson(json);
}

@freezed
class DisciplinaryStatistics with _$DisciplinaryStatistics {
  const factory DisciplinaryStatistics({
    @Default(0) int yellowCards,
    @Default(0) int redCards,
    @Default(0) int totalCards,
    @Default(0.0) double cardsPerGame,
    @Default(0) int foulsCommitted,
    @Default(0) int foulsDrawn,
    @Default(0.0) double foulsCommittedPerGame,
    @Default(0.0) double foulsDrawnPerGame,
    @Default(0.0) double foulRatio,
    @Default(0.0) double disciplineRating,
  }) = _DisciplinaryStatistics;

  factory DisciplinaryStatistics.fromJson(Map<String, dynamic> json) =>
      _$DisciplinaryStatisticsFromJson(json);
}

@freezed
class PerformanceMetric with _$PerformanceMetric {
  const factory PerformanceMetric({
    required String name,
    required String category,
    @Default(0.0) double value,
    @Default(0.0) double percentile,
    @Default(0.0) double leagueAverage,
    @Default(0.0) double seasonBest,
    @Default(0.0) double seasonWorst,
    required MetricTrend trend,
    String? unit,
    String? description,
  }) = _PerformanceMetric;

  factory PerformanceMetric.fromJson(Map<String, dynamic> json) =>
      _$PerformanceMetricFromJson(json);
}

@freezed
class ComparisonMetric with _$ComparisonMetric {
  const factory ComparisonMetric({
    required String metric,
    @Default(0.0) double teamValue,
    @Default(0.0) double opponentAverage,
    @Default(0.0) double leagueAverage,
    @Default(0.0) double difference,
    @Default(0.0) double percentageDifference,
    required ComparisonResult comparison,
    String? interpretation,
  }) = _ComparisonMetric;

  factory ComparisonMetric.fromJson(Map<String, dynamic> json) =>
      _$ComparisonMetricFromJson(json);
}

enum StatisticsType {
  team,
  player,
  league,
  competition,
}

enum MetricTrend {
  improving,
  stable,
  declining,
  fluctuating,
}

enum ComparisonResult {
  muchBetter,
  better,
  similar,
  worse,
  muchWorse,
}

extension StatisticsTypeX on StatisticsType {
  String get displayName {
    switch (this) {
      case StatisticsType.team:
        return 'Team';
      case StatisticsType.player:
        return 'Player';
      case StatisticsType.league:
        return 'League';
      case StatisticsType.competition:
        return 'Competition';
    }
  }
}

extension MetricTrendX on MetricTrend {
  String get displayName {
    switch (this) {
      case MetricTrend.improving:
        return '↗ Improving';
      case MetricTrend.stable:
        return '→ Stable';
      case MetricTrend.declining:
        return '↘ Declining';
      case MetricTrend.fluctuating:
        return '↕ Fluctuating';
    }
  }

  String get icon {
    switch (this) {
      case MetricTrend.improving:
        return '↗';
      case MetricTrend.stable:
        return '→';
      case MetricTrend.declining:
        return '↘';
      case MetricTrend.fluctuating:
        return '↕';
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
        return '↑↑';
      case ComparisonResult.better:
        return '↑';
      case ComparisonResult.similar:
        return '=';
      case ComparisonResult.worse:
        return '↓';
      case ComparisonResult.muchWorse:
        return '↓↓';
    }
  }
}

extension AdvancedStatisticsModelX on AdvancedStatisticsModel {
  double get attackingEfficiency {
    if (goalStats.shotsTotal == 0) return 0.0;
    return (goalStats.goalsScored / goalStats.shotsTotal) * 100;
  }

  double get defensiveSolidity {
    if (matchStats.played == 0) return 0.0;
    return (matchStats.cleanSheets / matchStats.played) * 100;
  }

  double get overallEfficiency {
    final attack = attackingEfficiency;
    final defense = defensiveStats.defensiveRating;
    final possession = possessionStats.possessionQuality;
    return (attack + defense + possession) / 3;
  }

  bool get isAboveAverage => overallRating > 50.0;
  bool get isTopPerformer => overallRating > 80.0;

  String get performanceLevel {
    if (overallRating >= 90) return 'Elite';
    if (overallRating >= 80) return 'Excellent';
    if (overallRating >= 70) return 'Very Good';
    if (overallRating >= 60) return 'Good';
    if (overallRating >= 50) return 'Average';
    if (overallRating >= 40) return 'Below Average';
    return 'Poor';
  }

  List<PerformanceMetric> get topMetrics {
    return performanceMetrics
        .where((metric) => metric.percentile >= 80.0)
        .toList()
      ..sort((a, b) => b.percentile.compareTo(a.percentile));
  }

  List<PerformanceMetric> get weakestMetrics {
    return performanceMetrics
        .where((metric) => metric.percentile <= 20.0)
        .toList()
      ..sort((a, b) => a.percentile.compareTo(b.percentile));
  }

  Map<String, dynamic> toFirestore() {
    return {
      'entityId': entityId,
      'type': type.name,
      'entityName': entityName,
      'seasonId': seasonId,
      'competition': competition,
      'periodStart': periodStart?.millisecondsSinceEpoch,
      'periodEnd': periodEnd?.millisecondsSinceEpoch,
      'matchStats': matchStats.toJson(),
      'goalStats': goalStats.toJson(),
      'defensiveStats': defensiveStats.toJson(),
      'passingStats': passingStats.toJson(),
      'possessionStats': possessionStats.toJson(),
      'setPieceStats': setPieceStats.toJson(),
      'disciplinaryStats': disciplinaryStats.toJson(),
      'performanceMetrics': performanceMetrics.map((m) => m.toJson()).toList(),
      'comparisons': comparisons.map((c) => c.toJson()).toList(),
      'lastUpdated': lastUpdated?.millisecondsSinceEpoch,
      'overallRating': overallRating,
      'formRating': formRating,
      'strengthIndex': strengthIndex,
    };
  }

  static AdvancedStatisticsModel fromFirestore(Map<String, dynamic> data) {
    return AdvancedStatisticsModel(
      entityId: data['entityId'],
      type: StatisticsType.values.firstWhere(
        (t) => t.name == data['type'],
        orElse: () => StatisticsType.team,
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
      matchStats: MatchStatistics.fromJson(data['matchStats']),
      goalStats: GoalStatistics.fromJson(data['goalStats']),
      defensiveStats: DefensiveStatistics.fromJson(data['defensiveStats']),
      passingStats: PassingStatistics.fromJson(data['passingStats']),
      possessionStats: PossessionStatistics.fromJson(data['possessionStats']),
      setPieceStats: SetPieceStatistics.fromJson(data['setPieceStats']),
      disciplinaryStats: DisciplinaryStatistics.fromJson(data['disciplinaryStats']),
      performanceMetrics: (data['performanceMetrics'] as List<dynamic>?)
              ?.map((m) => PerformanceMetric.fromJson(m))
              .toList() ??
          [],
      comparisons: (data['comparisons'] as List<dynamic>?)
              ?.map((c) => ComparisonMetric.fromJson(c))
              .toList() ??
          [],
      lastUpdated: data['lastUpdated'] != null
          ? DateTime.fromMillisecondsSinceEpoch(data['lastUpdated'])
          : null,
      overallRating: data['overallRating']?.toDouble() ?? 0.0,
      formRating: data['formRating']?.toDouble() ?? 0.0,
      strengthIndex: data['strengthIndex']?.toDouble() ?? 0.0,
    );
  }
}