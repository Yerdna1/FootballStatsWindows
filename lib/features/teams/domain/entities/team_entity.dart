import 'package:equatable/equatable.dart';

class TeamEntity extends Equatable {
  final int id;
  final String name;
  final String shortName;
  final String tla;
  final String crest;
  final String? address;
  final String? website;
  final int? founded;
  final String? clubColors;
  final String? venue;
  final String? countryName;
  final String? countryFlag;
  final List<CompetitionEntity>? competitions;
  final CoachEntity? coach;
  final List<PlayerEntity>? squad;
  final TeamStatisticsEntity? statistics;
  final DateTime? lastUpdated;

  const TeamEntity({
    required this.id,
    required this.name,
    required this.shortName,
    required this.tla,
    required this.crest,
    this.address,
    this.website,
    this.founded,
    this.clubColors,
    this.venue,
    this.countryName,
    this.countryFlag,
    this.competitions,
    this.coach,
    this.squad,
    this.statistics,
    this.lastUpdated,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        shortName,
        tla,
        crest,
        address,
        website,
        founded,
        clubColors,
        venue,
        countryName,
        countryFlag,
        competitions,
        coach,
        squad,
        statistics,
        lastUpdated,
      ];

  TeamEntity copyWith({
    int? id,
    String? name,
    String? shortName,
    String? tla,
    String? crest,
    String? address,
    String? website,
    int? founded,
    String? clubColors,
    String? venue,
    String? countryName,
    String? countryFlag,
    List<CompetitionEntity>? competitions,
    CoachEntity? coach,
    List<PlayerEntity>? squad,
    TeamStatisticsEntity? statistics,
    DateTime? lastUpdated,
  }) {
    return TeamEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      shortName: shortName ?? this.shortName,
      tla: tla ?? this.tla,
      crest: crest ?? this.crest,
      address: address ?? this.address,
      website: website ?? this.website,
      founded: founded ?? this.founded,
      clubColors: clubColors ?? this.clubColors,
      venue: venue ?? this.venue,
      countryName: countryName ?? this.countryName,
      countryFlag: countryFlag ?? this.countryFlag,
      competitions: competitions ?? this.competitions,
      coach: coach ?? this.coach,
      squad: squad ?? this.squad,
      statistics: statistics ?? this.statistics,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  String get displayName => shortName.isNotEmpty ? shortName : name;
  
  int get age {
    if (founded == null) return 0;
    return DateTime.now().year - founded!;
  }

  double get winPercentage {
    if (statistics == null || statistics!.playedGames == 0) return 0.0;
    return (statistics!.won / statistics!.playedGames) * 100;
  }

  double get drawPercentage {
    if (statistics == null || statistics!.playedGames == 0) return 0.0;
    return (statistics!.draw / statistics!.playedGames) * 100;
  }

  double get lossPercentage {
    if (statistics == null || statistics!.playedGames == 0) return 0.0;
    return (statistics!.lost / statistics!.playedGames) * 100;
  }

  String get formDisplay {
    if (statistics == null) return 'N/A';
    return '${statistics!.won}W-${statistics!.draw}D-${statistics!.lost}L';
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

class CoachEntity extends Equatable {
  final int id;
  final String firstName;
  final String lastName;
  final String name;
  final DateTime? dateOfBirth;
  final String? nationality;
  final ContractEntity? contract;

  const CoachEntity({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.name,
    this.dateOfBirth,
    this.nationality,
    this.contract,
  });

  @override
  List<Object?> get props => [
        id,
        firstName,
        lastName,
        name,
        dateOfBirth,
        nationality,
        contract,
      ];

  int? get age {
    if (dateOfBirth == null) return null;
    return DateTime.now().difference(dateOfBirth!).inDays ~/ 365;
  }
}

class PlayerEntity extends Equatable {
  final int id;
  final String name;
  final String position;
  final DateTime? dateOfBirth;
  final String? nationality;
  final ContractEntity? contract;

  const PlayerEntity({
    required this.id,
    required this.name,
    required this.position,
    this.dateOfBirth,
    this.nationality,
    this.contract,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        position,
        dateOfBirth,
        nationality,
        contract,
      ];

  int? get age {
    if (dateOfBirth == null) return null;
    return DateTime.now().difference(dateOfBirth!).inDays ~/ 365;
  }
}

class ContractEntity extends Equatable {
  final DateTime? start;
  final DateTime? until;

  const ContractEntity({
    this.start,
    this.until,
  });

  @override
  List<Object?> get props => [start, until];

  bool get isExpired {
    if (until == null) return false;
    return DateTime.now().isAfter(until!);
  }

  bool get isActive {
    final now = DateTime.now();
    if (start != null && now.isBefore(start!)) return false;
    if (until != null && now.isAfter(until!)) return false;
    return true;
  }
}

class TeamStatisticsEntity extends Equatable {
  final int playedGames;
  final int form;
  final int won;
  final int draw;
  final int lost;
  final int points;
  final int goalsFor;
  final int goalsAgainst;
  final int goalDifference;

  const TeamStatisticsEntity({
    required this.playedGames,
    required this.form,
    required this.won,
    required this.draw,
    required this.lost,
    required this.points,
    required this.goalsFor,
    required this.goalsAgainst,
    required this.goalDifference,
  });

  @override
  List<Object> get props => [
        playedGames,
        form,
        won,
        draw,
        lost,
        points,
        goalsFor,
        goalsAgainst,
        goalDifference,
      ];

  double get averageGoalsFor {
    if (playedGames == 0) return 0.0;
    return goalsFor / playedGames;
  }

  double get averageGoalsAgainst {
    if (playedGames == 0) return 0.0;
    return goalsAgainst / playedGames;
  }

  double get pointsPerGame {
    if (playedGames == 0) return 0.0;
    return points / playedGames;
  }
}