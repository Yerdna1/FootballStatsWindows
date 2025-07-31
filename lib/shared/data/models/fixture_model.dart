import 'package:freezed_annotation/freezed_annotation.dart';

part 'fixture_model.freezed.dart';

@freezed
class FixtureModel with _$FixtureModel {
  const factory FixtureModel({
    required int id,
    required DateTime utcDate,
    required String status,
    required int matchday,
    required String stage,
    String? group,
    DateTime? lastUpdated,
    CompetitionModel? competition,
    SeasonModel? season,
    required TeamFixtureModel homeTeam,
    required TeamFixtureModel awayTeam,
    ScoreModel? score,
    List<GoalModel>? goals,
    List<BookingModel>? bookings,
    List<SubstitutionModel>? substitutions,
    OddsModel? odds,
    RefereeModel? referee,
  }) = _FixtureModel;

  factory FixtureModel.fromJson(Map<String, dynamic> json) =>
      _$FixtureModelFromJson(json);
}

@freezed
class CompetitionModel with _$CompetitionModel {
  const factory CompetitionModel({
    required int id,
    required String name,
    required String code,
    required String type,
    required String emblem,
  }) = _CompetitionModel;

  factory CompetitionModel.fromJson(Map<String, dynamic> json) =>
      _$CompetitionModelFromJson(json);
}

@freezed
class TeamFixtureModel with _$TeamFixtureModel {
  const factory TeamFixtureModel({
    required int id,
    required String name,
    required String shortName,
    required String tla,
    required String crest,
    CoachModel? coach,
  }) = _TeamFixtureModel;

  factory TeamFixtureModel.fromJson(Map<String, dynamic> json) =>
      _$TeamFixtureModelFromJson(json);
}

@freezed
class ScoreModel with _$ScoreModel {
  const factory ScoreModel({
    String? winner,
    String? duration,
    ScoreDetailModel? fullTime,
    ScoreDetailModel? halfTime,
    ScoreDetailModel? extraTime,
    ScoreDetailModel? penalties,
  }) = _ScoreModel;

  factory ScoreModel.fromJson(Map<String, dynamic> json) =>
      _$ScoreModelFromJson(json);
}

@freezed
class ScoreDetailModel with _$ScoreDetailModel {
  const factory ScoreDetailModel({
    int? home,
    int? away,
  }) = _ScoreDetailModel;

  factory ScoreDetailModel.fromJson(Map<String, dynamic> json) =>
      _$ScoreDetailModelFromJson(json);
}

@freezed
class GoalModel with _$GoalModel {
  const factory GoalModel({
    required int minute,
    String? injuryTime,
    required String type,
    required TeamFixtureModel team,
    required PlayerModel scorer,
    PlayerModel? assist,
  }) = _GoalModel;

  factory GoalModel.fromJson(Map<String, dynamic> json) =>
      _$GoalModelFromJson(json);
}

@freezed
class BookingModel with _$BookingModel {
  const factory BookingModel({
    required int minute,
    String? injuryTime,
    required TeamFixtureModel team,
    required PlayerModel player,
    required String card,
  }) = _BookingModel;

  factory BookingModel.fromJson(Map<String, dynamic> json) =>
      _$BookingModelFromJson(json);
}

@freezed
class SubstitutionModel with _$SubstitutionModel {
  const factory SubstitutionModel({
    required int minute,
    String? injuryTime,
    required TeamFixtureModel team,
    required PlayerModel playerOut,
    required PlayerModel playerIn,
  }) = _SubstitutionModel;

  factory SubstitutionModel.fromJson(Map<String, dynamic> json) =>
      _$SubstitutionModelFromJson(json);
}

@freezed
class OddsModel with _$OddsModel {
  const factory OddsModel({
    String? msg,
    double? homeWin,
    double? draw,
    double? awayWin,
  }) = _OddsModel;

  factory OddsModel.fromJson(Map<String, dynamic> json) =>
      _$OddsModelFromJson(json);
}

@freezed
class RefereeModel with _$RefereeModel {
  const factory RefereeModel({
    required int id,
    required String name,
    String? role,
    String? nationality,
  }) = _RefereeModel;

  factory RefereeModel.fromJson(Map<String, dynamic> json) =>
      _$RefereeModelFromJson(json);
}

enum FixtureStatus {
  scheduled,
  timed,
  inPlay,
  paused,
  extraTime,
  penaltyShootout,
  finished,
  suspended,
  postponed,
  cancelled,
  awarded,
}

extension FixtureModelX on FixtureModel {
  FixtureStatus get fixtureStatus {
    switch (status.toUpperCase()) {
      case 'SCHEDULED':
        return FixtureStatus.scheduled;
      case 'TIMED':
        return FixtureStatus.timed;
      case 'IN_PLAY':
        return FixtureStatus.inPlay;
      case 'PAUSED':
        return FixtureStatus.paused;
      case 'EXTRA_TIME':
        return FixtureStatus.extraTime;
      case 'PENALTY_SHOOTOUT':
        return FixtureStatus.penaltyShootout;
      case 'FINISHED':
        return FixtureStatus.finished;
      case 'SUSPENDED':
        return FixtureStatus.suspended;
      case 'POSTPONED':
        return FixtureStatus.postponed;
      case 'CANCELLED':
        return FixtureStatus.cancelled;
      case 'AWARDED':
        return FixtureStatus.awarded;
      default:
        return FixtureStatus.scheduled;
    }
  }

  bool get isFinished => fixtureStatus == FixtureStatus.finished;
  bool get isLive => fixtureStatus == FixtureStatus.inPlay;
  bool get isScheduled => fixtureStatus == FixtureStatus.scheduled || fixtureStatus == FixtureStatus.timed;

  String get statusDisplay {
    switch (fixtureStatus) {
      case FixtureStatus.scheduled:
      case FixtureStatus.timed:
        return 'Scheduled';
      case FixtureStatus.inPlay:
        return 'Live';
      case FixtureStatus.paused:
        return 'HT';
      case FixtureStatus.extraTime:
        return 'ET';
      case FixtureStatus.penaltyShootout:
        return 'Pens';
      case FixtureStatus.finished:
        return 'FT';
      case FixtureStatus.suspended:
        return 'Suspended';
      case FixtureStatus.postponed:
        return 'Postponed';
      case FixtureStatus.cancelled:
        return 'Cancelled';
      case FixtureStatus.awarded:
        return 'Awarded';
    }
  }

  String get scoreDisplay {
    if (score?.fullTime?.home != null && score?.fullTime?.away != null) {
      return '${score!.fullTime!.home} - ${score!.fullTime!.away}';
    }
    return '- : -';
  }

  String get homeTeamScore => score?.fullTime?.home?.toString() ?? '-';
  String get awayTeamScore => score?.fullTime?.away?.toString() ?? '-';

  TeamFixtureModel? get winningTeam {
    if (score?.winner == null || !isFinished) return null;
    return score!.winner == 'HOME_TEAM' ? homeTeam : awayTeam;
  }

  bool isTeamWinner(int teamId) {
    if (!isFinished || score?.winner == null) return false;
    final winner = winningTeam;
    return winner?.id == teamId;
  }

  bool isTeamLoser(int teamId) {
    if (!isFinished || score?.winner == null) return false;
    final winner = winningTeam;
    return winner?.id != teamId && score!.winner != 'DRAW';
  }

  bool get isDraw => isFinished && score?.winner == 'DRAW';

  int get totalGoals {
    if (score?.fullTime?.home != null && score?.fullTime?.away != null) {
      return score!.fullTime!.home! + score!.fullTime!.away!;
    }
    return 0;
  }

  List<GoalModel> getTeamGoals(int teamId) {
    return goals?.where((goal) => goal.team.id == teamId).toList() ?? [];
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'utcDate': utcDate.millisecondsSinceEpoch,
      'status': status,
      'matchday': matchday,
      'stage': stage,
      'group': group,
      'lastUpdated': lastUpdated?.millisecondsSinceEpoch,
      'competition': competition?.toJson(),
      'season': season?.toJson(),
      'homeTeam': homeTeam.toJson(),
      'awayTeam': awayTeam.toJson(),
      'score': score?.toJson(),
      'goals': goals?.map((g) => g.toJson()).toList(),
      'bookings': bookings?.map((b) => b.toJson()).toList(),
      'substitutions': substitutions?.map((s) => s.toJson()).toList(),
      'odds': odds?.toJson(),
      'referee': referee?.toJson(),
    };
  }

  static FixtureModel fromFirestore(Map<String, dynamic> data) {
    return FixtureModel(
      id: data['id'],
      utcDate: DateTime.fromMillisecondsSinceEpoch(data['utcDate']),
      status: data['status'],
      matchday: data['matchday'],
      stage: data['stage'],
      group: data['group'],
      lastUpdated: data['lastUpdated'] != null
          ? DateTime.fromMillisecondsSinceEpoch(data['lastUpdated'])
          : null,
      competition: data['competition'] != null
          ? CompetitionModel.fromJson(data['competition'])
          : null,
      season: data['season'] != null
          ? SeasonModel.fromJson(data['season'])
          : null,
      homeTeam: TeamFixtureModel.fromJson(data['homeTeam']),
      awayTeam: TeamFixtureModel.fromJson(data['awayTeam']),
      score: data['score'] != null ? ScoreModel.fromJson(data['score']) : null,
      goals: (data['goals'] as List<dynamic>?)
          ?.map((g) => GoalModel.fromJson(g))
          .toList(),
      bookings: (data['bookings'] as List<dynamic>?)
          ?.map((b) => BookingModel.fromJson(b))
          .toList(),
      substitutions: (data['substitutions'] as List<dynamic>?)
          ?.map((s) => SubstitutionModel.fromJson(s))
          .toList(),
      odds: data['odds'] != null ? OddsModel.fromJson(data['odds']) : null,
      referee: data['referee'] != null
          ? RefereeModel.fromJson(data['referee'])
          : null,
    );
  }
}