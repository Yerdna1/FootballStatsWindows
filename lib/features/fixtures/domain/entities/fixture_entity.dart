import 'package:equatable/equatable.dart';

class FixtureEntity extends Equatable {
  final int id;
  final DateTime utcDate;
  final String status;
  final int matchday;
  final String stage;
  final String? group;
  final DateTime? lastUpdated;
  final CompetitionEntity? competition;
  final SeasonEntity? season;
  final TeamFixtureEntity homeTeam;
  final TeamFixtureEntity awayTeam;
  final ScoreEntity? score;
  final List<GoalEntity>? goals;
  final List<BookingEntity>? bookings;
  final List<SubstitutionEntity>? substitutions;
  final OddsEntity? odds;
  final RefereeEntity? referee;

  const FixtureEntity({
    required this.id,
    required this.utcDate,
    required this.status,
    required this.matchday,
    required this.stage,
    this.group,
    this.lastUpdated,
    this.competition,
    this.season,
    required this.homeTeam,
    required this.awayTeam,
    this.score,
    this.goals,
    this.bookings,
    this.substitutions,
    this.odds,
    this.referee,
  });

  @override
  List<Object?> get props => [
        id,
        utcDate,
        status,
        matchday,
        stage,
        group,
        lastUpdated,
        competition,
        season,
        homeTeam,
        awayTeam,
        score,
        goals,
        bookings,
        substitutions,
        odds,
        referee,
      ];

  FixtureEntity copyWith({
    int? id,
    DateTime? utcDate,
    String? status,
    int? matchday,
    String? stage,
    String? group,
    DateTime? lastUpdated,
    CompetitionEntity? competition,
    SeasonEntity? season,
    TeamFixtureEntity? homeTeam,
    TeamFixtureEntity? awayTeam,
    ScoreEntity? score,
    List<GoalEntity>? goals,
    List<BookingEntity>? bookings,
    List<SubstitutionEntity>? substitutions,
    OddsEntity? odds,
    RefereeEntity? referee,
  }) {
    return FixtureEntity(
      id: id ?? this.id,
      utcDate: utcDate ?? this.utcDate,
      status: status ?? this.status,
      matchday: matchday ?? this.matchday,
      stage: stage ?? this.stage,
      group: group ?? this.group,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      competition: competition ?? this.competition,
      season: season ?? this.season,
      homeTeam: homeTeam ?? this.homeTeam,
      awayTeam: awayTeam ?? this.awayTeam,
      score: score ?? this.score,
      goals: goals ?? this.goals,
      bookings: bookings ?? this.bookings,
      substitutions: substitutions ?? this.substitutions,
      odds: odds ?? this.odds,
      referee: referee ?? this.referee,
    );
  }

  bool get isFinished => status.toUpperCase() == 'FINISHED';
  bool get isLive => status.toUpperCase() == 'IN_PLAY';
  bool get isScheduled => 
      status.toUpperCase() == 'SCHEDULED' || status.toUpperCase() == 'TIMED';

  String get statusDisplay {
    switch (status.toUpperCase()) {
      case 'SCHEDULED':
      case 'TIMED':
        return 'Scheduled';
      case 'IN_PLAY':
        return 'Live';
      case 'PAUSED':
        return 'HT';
      case 'EXTRA_TIME':
        return 'ET';
      case 'PENALTY_SHOOTOUT':
        return 'Pens';
      case 'FINISHED':
        return 'FT';
      case 'SUSPENDED':
        return 'Suspended';
      case 'POSTPONED':
        return 'Postponed';
      case 'CANCELLED':
        return 'Cancelled';
      case 'AWARDED':
        return 'Awarded';
      default:
        return status;
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

  TeamFixtureEntity? get winningTeam {
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

  List<GoalEntity> getTeamGoals(int teamId) {
    return goals?.where((goal) => goal.team.id == teamId).toList() ?? [];
  }
}

class CompetitionEntity extends Equatable {
  final int id;
  final String name;
  final String code;
  final String type;
  final String emblem;

  const CompetitionEntity({
    required this.id,
    required this.name,
    required this.code,
    required this.type,
    required this.emblem,
  });

  @override
  List<Object> get props => [id, name, code, type, emblem];
}

class SeasonEntity extends Equatable {
  final int id;
  final DateTime startDate;
  final DateTime endDate;
  final int currentMatchday;
  final String? winner;

  const SeasonEntity({
    required this.id,
    required this.startDate,
    required this.endDate,
    required this.currentMatchday,
    this.winner,
  });

  @override
  List<Object?> get props => [id, startDate, endDate, currentMatchday, winner];
}

class TeamFixtureEntity extends Equatable {
  final int id;
  final String name;
  final String shortName;
  final String tla;
  final String crest;

  const TeamFixtureEntity({
    required this.id,
    required this.name,
    required this.shortName,
    required this.tla,
    required this.crest,
  });

  @override
  List<Object> get props => [id, name, shortName, tla, crest];

  String get displayName => shortName.isNotEmpty ? shortName : name;
}

class ScoreEntity extends Equatable {
  final String? winner;
  final String? duration;
  final ScoreDetailEntity? fullTime;
  final ScoreDetailEntity? halfTime;
  final ScoreDetailEntity? extraTime;
  final ScoreDetailEntity? penalties;

  const ScoreEntity({
    this.winner,
    this.duration,
    this.fullTime,
    this.halfTime,
    this.extraTime,
    this.penalties,
  });

  @override
  List<Object?> get props => [winner, duration, fullTime, halfTime, extraTime, penalties];
}

class ScoreDetailEntity extends Equatable {
  final int? home;
  final int? away;

  const ScoreDetailEntity({
    this.home,
    this.away,
  });

  @override
  List<Object?> get props => [home, away];
}

class GoalEntity extends Equatable {
  final int minute;
  final String? injuryTime;
  final String type;
  final TeamFixtureEntity team;
  final PlayerEntity scorer;
  final PlayerEntity? assist;

  const GoalEntity({
    required this.minute,
    this.injuryTime,
    required this.type,
    required this.team,
    required this.scorer,
    this.assist,
  });

  @override
  List<Object?> get props => [minute, injuryTime, type, team, scorer, assist];

  String get minuteDisplay {
    if (injuryTime != null && injuryTime!.isNotEmpty) {
      return '$minute+$injuryTime\'';
    }
    return '$minute\'';
  }
}

class BookingEntity extends Equatable {
  final int minute;
  final String? injuryTime;
  final TeamFixtureEntity team;
  final PlayerEntity player;
  final String card;

  const BookingEntity({
    required this.minute,
    this.injuryTime,
    required this.team,
    required this.player,
    required this.card,
  });

  @override
  List<Object?> get props => [minute, injuryTime, team, player, card];

  String get minuteDisplay {
    if (injuryTime != null && injuryTime!.isNotEmpty) {
      return '$minute+$injuryTime\'';
    }
    return '$minute\'';
  }

  bool get isYellowCard => card.toUpperCase() == 'YELLOW_CARD';
  bool get isRedCard => card.toUpperCase() == 'RED_CARD';
}

class SubstitutionEntity extends Equatable {
  final int minute;
  final String? injuryTime;
  final TeamFixtureEntity team;
  final PlayerEntity playerOut;
  final PlayerEntity playerIn;

  const SubstitutionEntity({
    required this.minute,
    this.injuryTime,
    required this.team,
    required this.playerOut,
    required this.playerIn,
  });

  @override
  List<Object?> get props => [minute, injuryTime, team, playerOut, playerIn];

  String get minuteDisplay {
    if (injuryTime != null && injuryTime!.isNotEmpty) {
      return '$minute+$injuryTime\'';
    }
    return '$minute\'';
  }
}

class OddsEntity extends Equatable {
  final String? msg;
  final double? homeWin;
  final double? draw;
  final double? awayWin;

  const OddsEntity({
    this.msg,
    this.homeWin,
    this.draw,
    this.awayWin,
  });

  @override
  List<Object?> get props => [msg, homeWin, draw, awayWin];
}

class RefereeEntity extends Equatable {
  final int id;
  final String name;
  final String? role;
  final String? nationality;

  const RefereeEntity({
    required this.id,
    required this.name,
    this.role,
    this.nationality,
  });

  @override
  List<Object?> get props => [id, name, role, nationality];
}

class PlayerEntity extends Equatable {
  final int id;
  final String name;
  final String? position;
  final DateTime? dateOfBirth;
  final String? nationality;

  const PlayerEntity({
    required this.id,
    required this.name,
    this.position,
    this.dateOfBirth,
    this.nationality,
  });

  @override
  List<Object?> get props => [id, name, position, dateOfBirth, nationality];

  int? get age {
    if (dateOfBirth == null) return null;
    return DateTime.now().difference(dateOfBirth!).inDays ~/ 365;
  }
}