import 'package:freezed_annotation/freezed_annotation.dart';

part 'team_model.freezed.dart';
part 'team_model.g.dart';

@freezed
class TeamModel with _$TeamModel {
  const factory TeamModel({
    required int id,
    required String name,
    required String shortName,
    required String tla,
    required String crest,
    String? address,
    String? website,
    int? founded,
    String? clubColors,
    String? venue,
    AreaModel? area,
    List<RunningCompetitionModel>? runningCompetitions,
    CoachModel? coach,
    List<PlayerModel>? squad,
    TeamStatisticsModel? statistics,
    DateTime? lastUpdated,
  }) = _TeamModel;

  factory TeamModel.fromJson(Map<String, dynamic> json) =>
      _$TeamModelFromJson(json);
}

@freezed
class RunningCompetitionModel with _$RunningCompetitionModel {
  const factory RunningCompetitionModel({
    required int id,
    required String name,
    required String code,
    required String type,
    required String emblem,
  }) = _RunningCompetitionModel;

  factory RunningCompetitionModel.fromJson(Map<String, dynamic> json) =>
      _$RunningCompetitionModelFromJson(json);
}

@freezed
class CoachModel with _$CoachModel {
  const factory CoachModel({
    required int id,
    required String firstName,
    required String lastName,
    required String name,
    DateTime? dateOfBirth,
    String? nationality,
    ContractModel? contract,
  }) = _CoachModel;

  factory CoachModel.fromJson(Map<String, dynamic> json) =>
      _$CoachModelFromJson(json);
}

@freezed
class PlayerModel with _$PlayerModel {
  const factory PlayerModel({
    required int id,
    required String name,
    required String position,
    DateTime? dateOfBirth,
    String? nationality,
    ContractModel? contract,
  }) = _PlayerModel;

  factory PlayerModel.fromJson(Map<String, dynamic> json) =>
      _$PlayerModelFromJson(json);
}

@freezed
class ContractModel with _$ContractModel {
  const factory ContractModel({
    DateTime? start,
    DateTime? until,
  }) = _ContractModel;

  factory ContractModel.fromJson(Map<String, dynamic> json) =>
      _$ContractModelFromJson(json);
}

@freezed
class TeamStatisticsModel with _$TeamStatisticsModel {
  const factory TeamStatisticsModel({
    @Default(0) int playedGames,
    @Default(0) int form,
    @Default(0) int won,
    @Default(0) int draw,
    @Default(0) int lost,
    @Default(0) int points,
    @Default(0) int goalsFor,
    @Default(0) int goalsAgainst,
    @Default(0) int goalDifference,
  }) = _TeamStatisticsModel;

  factory TeamStatisticsModel.fromJson(Map<String, dynamic> json) =>
      _$TeamStatisticsModelFromJson(json);
}

extension TeamModelX on TeamModel {
  String get displayName => shortName.isNotEmpty ? shortName : name;
  
  int get age {
    if (founded == null) return 0;
    return DateTime.now().year - founded!;
  }

  String get countryName => area?.name ?? 'Unknown';
  String get countryFlag => area?.flag ?? '';

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

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'name': name,
      'shortName': shortName,
      'tla': tla,
      'crest': crest,
      'address': address,
      'website': website,
      'founded': founded,
      'clubColors': clubColors,
      'venue': venue,
      'area': area?.toJson(),
      'runningCompetitions': runningCompetitions?.map((c) => c.toJson()).toList(),
      'coach': coach?.toJson(),
      'squad': squad?.map((p) => p.toJson()).toList(),
      'statistics': statistics?.toJson(),
      'lastUpdated': lastUpdated?.millisecondsSinceEpoch,
    };
  }

  static TeamModel fromFirestore(Map<String, dynamic> data) {
    return TeamModel(
      id: data['id'],
      name: data['name'],
      shortName: data['shortName'],
      tla: data['tla'],
      crest: data['crest'],
      address: data['address'],
      website: data['website'],
      founded: data['founded'],
      clubColors: data['clubColors'],
      venue: data['venue'],
      area: data['area'] != null ? AreaModel.fromJson(data['area']) : null,
      runningCompetitions: (data['runningCompetitions'] as List<dynamic>?)
          ?.map((c) => RunningCompetitionModel.fromJson(c))
          .toList(),
      coach: data['coach'] != null ? CoachModel.fromJson(data['coach']) : null,
      squad: (data['squad'] as List<dynamic>?)
          ?.map((p) => PlayerModel.fromJson(p))
          .toList(),
      statistics: data['statistics'] != null
          ? TeamStatisticsModel.fromJson(data['statistics'])
          : null,
      lastUpdated: data['lastUpdated'] != null
          ? DateTime.fromMillisecondsSinceEpoch(data['lastUpdated'])
          : null,
    );
  }
}