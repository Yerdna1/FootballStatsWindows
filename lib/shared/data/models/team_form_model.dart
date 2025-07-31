import 'package:freezed_annotation/freezed_annotation.dart';

part 'team_form_model.freezed.dart';
part 'team_form_model.g.dart';

@freezed
class TeamFormModel with _$TeamFormModel {
  const factory TeamFormModel({
    required int teamId,
    required String teamName,
    required String teamCrest,
    required int seasonId,
    required String competition,
    @Default([]) List<FormResult> recentForm,
    @Default([]) List<FormResult> homeForm,
    @Default([]) List<FormResult> awayForm,
    required FormStreak currentStreak,
    required FormAnalysis formAnalysis,
    required AttackingForm attackingForm,
    required DefensiveForm defensiveForm,
    @Default([]) List<FormTrend> formTrends,
    DateTime? lastUpdated,
    @Default(0) int totalMatches,
    @Default(0) int wins,
    @Default(0) int draws,
    @Default(0) int losses,
    @Default(0.0) double winPercentage,
    @Default(0.0) double formScore,
    @Default(0.0) double consistency,
    @Default(0.0) double momentum,
  }) = _TeamFormModel;

  factory TeamFormModel.fromJson(Map<String, dynamic> json) =>
      _$TeamFormModelFromJson(json);
}

@freezed
class FormResult with _$FormResult {
  const factory FormResult({
    required int fixtureId,
    required DateTime matchDate,
    required String opponent,
    required String opponentCrest,
    required bool isHome,
    required FormResultType result,
    required int goalsFor,
    required int goalsAgainst,
    required int goalDifference,
    @Default(0) int points,
    String? competition,
    @Default(0.0) double performanceRating,
    @Default([]) List<String> keyEvents,
  }) = _FormResult;

  factory FormResult.fromJson(Map<String, dynamic> json) =>
      _$FormResultFromJson(json);
}

@freezed
class FormStreak with _$FormStreak {
  const factory FormStreak({
    required FormResultType type,
    required int length,
    required DateTime startDate,
    DateTime? endDate,
    @Default(0) int points,
    @Default(0) int goalsFor,
    @Default(0) int goalsAgainst,
    @Default(false) bool isActive,
  }) = _FormStreak;

  factory FormStreak.fromJson(Map<String, dynamic> json) =>
      _$FormStreakFromJson(json);
}

@freezed
class FormAnalysis with _$FormAnalysis {
  const factory FormAnalysis({
    @Default(0.0) double overallRating,
    @Default(0.0) double recentFormRating,
    @Default(0.0) double homeFormRating,
    @Default(0.0) double awayFormRating,
    @Default(0.0) double bigGamePerformance,
    @Default(0.0) double consistencyIndex,
    @Default(0.0) double momentumScore,
    @Default(0.0) double pressureHandling,
    required FormPrediction shortTermPrediction,
    required FormPrediction mediumTermPrediction,
    @Default([]) List<String> strengths,
    @Default([]) List<String> weaknesses,
    @Default([]) List<String> keyInsights,
  }) = _FormAnalysis;

  factory FormAnalysis.fromJson(Map<String, dynamic> json) =>
      _$FormAnalysisFromJson(json);
}

@freezed
class AttackingForm with _$AttackingForm {
  const factory AttackingForm({
    @Default(0.0) double goalsPerGame,
    @Default(0.0) double expectedGoals,
    @Default(0.0) double conversionRate,
    @Default(0.0) double bigChancesCreated,
    @Default(0.0) double attackingThirdPasses,
    @Default(0.0) double shotsPerGame,
    @Default(0.0) double shotsOnTarget,
    @Default(0.0) double creativityIndex,
    @Default(0.0) double counterAttackEfficiency,
    @Default(0.0) double setPieceGoals,
    @Default([]) List<AttackingTrend> trends,
  }) = _AttackingForm;

  factory AttackingForm.fromJson(Map<String, dynamic> json) =>
      _$AttackingFormFromJson(json);
}

@freezed
class DefensiveForm with _$DefensiveForm {
  const factory DefensiveForm({
    @Default(0.0) double goalsConcededPerGame,
    @Default(0.0) double expectedGoalsAgainst,
    @Default(0.0) double cleanSheetPercentage,
    @Default(0.0) double tacklesWon,
    @Default(0.0) double interceptionsPerGame,
    @Default(0.0) double aerialDuelsWon,
    @Default(0.0) double defensiveStability,
    @Default(0.0) double pressureResistance,
    @Default(0.0) double setPieceDefense,
    @Default(0.0) double counterAttackVulnerability,
    @Default([]) List<DefensiveTrend> trends,
  }) = _DefensiveForm;

  factory DefensiveForm.fromJson(Map<String, dynamic> json) =>
      _$DefensiveFormFromJson(json);
}

@freezed
class FormTrend with _$FormTrend {
  const factory FormTrend({
    required String metric,
    required String period,
    @Default(0.0) double value,
    @Default(0.0) double previousValue,
    @Default(0.0) double change,
    @Default(0.0) double changePercentage,
    required TrendDirection direction,
    String? interpretation,
  }) = _FormTrend;

  factory FormTrend.fromJson(Map<String, dynamic> json) =>
      _$FormTrendFromJson(json);
}

@freezed
class AttackingTrend with _$AttackingTrend {
  const factory AttackingTrend({
    required String metric,
    @Default(0.0) double currentValue,
    @Default(0.0) double trend,
    required TrendDirection direction,
  }) = _AttackingTrend;

  factory AttackingTrend.fromJson(Map<String, dynamic> json) =>
      _$AttackingTrendFromJson(json);
}

@freezed
class DefensiveTrend with _$DefensiveTrend {
  const factory DefensiveTrend({
    required String metric,
    @Default(0.0) double currentValue,
    @Default(0.0) double trend,
    required TrendDirection direction,
  }) = _DefensiveTrend;

  factory DefensiveTrend.fromJson(Map<String, dynamic> json) =>
      _$DefensiveTrendFromJson(json);
}

@freezed
class FormPrediction with _$FormPrediction {
  const factory FormPrediction({
    @Default(0.0) double winProbability,
    @Default(0.0) double drawProbability,
    @Default(0.0) double lossProbability,
    @Default(0.0) double expectedPoints,
    @Default(0.0) double confidence,
    @Default([]) List<String> factors,
    String? summary,
  }) = _FormPrediction;

  factory FormPrediction.fromJson(Map<String, dynamic> json) =>
      _$FormPredictionFromJson(json);
}

enum FormResultType {
  win,
  draw,
  loss,
}

enum TrendDirection {
  improving,
  declining,
  stable,
}

extension FormResultTypeX on FormResultType {
  String get displayName {
    switch (this) {
      case FormResultType.win:
        return 'W';
      case FormResultType.draw:
        return 'D';
      case FormResultType.loss:
        return 'L';
    }
  }

  String get fullName {
    switch (this) {
      case FormResultType.win:
        return 'Win';
      case FormResultType.draw:
        return 'Draw';
      case FormResultType.loss:
        return 'Loss';
    }
  }

  int get points {
    switch (this) {
      case FormResultType.win:
        return 3;
      case FormResultType.draw:
        return 1;
      case FormResultType.loss:
        return 0;
    }
  }
}

extension TrendDirectionX on TrendDirection {
  String get displayName {
    switch (this) {
      case TrendDirection.improving:
        return '↗';
      case TrendDirection.declining:
        return '↘';
      case TrendDirection.stable:
        return '→';
    }
  }

  String get description {
    switch (this) {
      case TrendDirection.improving:
        return 'Improving';
      case TrendDirection.declining:
        return 'Declining';
      case TrendDirection.stable:
        return 'Stable';
    }
  }
}

extension TeamFormModelX on TeamFormModel {
  String get formString {
    return recentForm
        .take(5)
        .map((result) => result.result.displayName)
        .join(' ');
  }

  double get recentFormScore {
    if (recentForm.isEmpty) return 0.0;
    final recentMatches = recentForm.take(5);
    final points = recentMatches.fold<int>(0, (sum, match) => sum + match.points);
    return (points / (recentMatches.length * 3)) * 100;
  }

  double get goalsPerGameRecent {
    if (recentForm.isEmpty) return 0.0;
    final recentMatches = recentForm.take(5);
    final totalGoals = recentMatches.fold<int>(0, (sum, match) => sum + match.goalsFor);
    return totalGoals / recentMatches.length;
  }

  double get goalsConcededPerGameRecent {
    if (recentForm.isEmpty) return 0.0;
    final recentMatches = recentForm.take(5);
    final totalConceded = recentMatches.fold<int>(0, (sum, match) => sum + match.goalsAgainst);
    return totalConceded / recentMatches.length;
  }

  double get goalDifferencePerGameRecent {
    return goalsPerGameRecent - goalsConcededPerGameRecent;
  }

  bool get isInGoodForm => formScore >= 70.0;
  bool get isInPoorForm => formScore <= 30.0;

  String get formDescription {
    if (formScore >= 80) return 'Excellent';
    if (formScore >= 70) return 'Good';
    if (formScore >= 50) return 'Average';
    if (formScore >= 30) return 'Poor';
    return 'Very Poor';
  }

  List<FormResult> get lastFiveMatches => recentForm.take(5).toList();

  Map<String, dynamic> toFirestore() {
    return {
      'teamId': teamId,
      'teamName': teamName,
      'teamCrest': teamCrest,
      'seasonId': seasonId,
      'competition': competition,
      'recentForm': recentForm.map((f) => f.toJson()).toList(),
      'homeForm': homeForm.map((f) => f.toJson()).toList(),
      'awayForm': awayForm.map((f) => f.toJson()).toList(),
      'currentStreak': currentStreak.toJson(),
      'formAnalysis': formAnalysis.toJson(),
      'attackingForm': attackingForm.toJson(),
      'defensiveForm': defensiveForm.toJson(),
      'formTrends': formTrends.map((t) => t.toJson()).toList(),
      'lastUpdated': lastUpdated?.millisecondsSinceEpoch,
      'totalMatches': totalMatches,
      'wins': wins,
      'draws': draws,
      'losses': losses,
      'winPercentage': winPercentage,
      'formScore': formScore,
      'consistency': consistency,
      'momentum': momentum,
    };
  }

  static TeamFormModel fromFirestore(Map<String, dynamic> data) {
    return TeamFormModel(
      teamId: data['teamId'],
      teamName: data['teamName'],
      teamCrest: data['teamCrest'],
      seasonId: data['seasonId'],
      competition: data['competition'],
      recentForm: (data['recentForm'] as List<dynamic>?)
              ?.map((f) => FormResult.fromJson(f))
              .toList() ??
          [],
      homeForm: (data['homeForm'] as List<dynamic>?)
              ?.map((f) => FormResult.fromJson(f))
              .toList() ??
          [],
      awayForm: (data['awayForm'] as List<dynamic>?)
              ?.map((f) => FormResult.fromJson(f))
              .toList() ??
          [],
      currentStreak: FormStreak.fromJson(data['currentStreak']),
      formAnalysis: FormAnalysis.fromJson(data['formAnalysis']),
      attackingForm: AttackingForm.fromJson(data['attackingForm']),
      defensiveForm: DefensiveForm.fromJson(data['defensiveForm']),
      formTrends: (data['formTrends'] as List<dynamic>?)
              ?.map((t) => FormTrend.fromJson(t))
              .toList() ??
          [],
      lastUpdated: data['lastUpdated'] != null
          ? DateTime.fromMillisecondsSinceEpoch(data['lastUpdated'])
          : null,
      totalMatches: data['totalMatches'] ?? 0,
      wins: data['wins'] ?? 0,
      draws: data['draws'] ?? 0,
      losses: data['losses'] ?? 0,
      winPercentage: data['winPercentage']?.toDouble() ?? 0.0,
      formScore: data['formScore']?.toDouble() ?? 0.0,
      consistency: data['consistency']?.toDouble() ?? 0.0,
      momentum: data['momentum']?.toDouble() ?? 0.0,
    );
  }
}