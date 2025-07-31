import 'package:freezed_annotation/freezed_annotation.dart';

part 'league_model.freezed.dart';
part 'league_model.g.dart';

@freezed
class LeagueModel with _$LeagueModel {
  const factory LeagueModel({
    required int id,
    required String name,
    required String code,
    required String type,
    required String emblem,
    required int currentSeason,
    required int numberOfAvailableSeasons,
    DateTime? lastUpdated,
    AreaModel? area,
    CurrentSeasonModel? currentSeasonDetails,
    @Default([]) List<SeasonModel> availableSeasons,
  }) = _LeagueModel;

  factory LeagueModel.fromJson(Map<String, dynamic> json) =>
      _$LeagueModelFromJson(json);
}

@freezed
class AreaModel with _$AreaModel {
  const factory AreaModel({
    required int id,
    required String name,
    required String code,
    required String flag,
  }) = _AreaModel;

  factory AreaModel.fromJson(Map<String, dynamic> json) =>
      _$AreaModelFromJson(json);
}

@freezed
class CurrentSeasonModel with _$CurrentSeasonModel {
  const factory CurrentSeasonModel({
    required int id,
    required DateTime startDate,
    required DateTime endDate,
    required int currentMatchday,
    String? winner,
  }) = _CurrentSeasonModel;

  factory CurrentSeasonModel.fromJson(Map<String, dynamic> json) =>
      _$CurrentSeasonModelFromJson(json);
}

@freezed
class SeasonModel with _$SeasonModel {
  const factory SeasonModel({
    required int id,
    required DateTime startDate,
    required DateTime endDate,
    required int currentMatchday,
    String? winner,
  }) = _SeasonModel;

  factory SeasonModel.fromJson(Map<String, dynamic> json) =>
      _$SeasonModelFromJson(json);
}

extension LeagueModelX on LeagueModel {
  bool get isActive {
    if (currentSeasonDetails == null) return false;
    final now = DateTime.now();
    return now.isAfter(currentSeasonDetails!.startDate) &&
           now.isBefore(currentSeasonDetails!.endDate);
  }

  String get displayName {
    return name.replaceAll('Premier League', 'EPL')
              .replaceAll('Bundesliga', 'BL')
              .replaceAll('Serie A', 'SA')
              .replaceAll('La Liga', 'LL')
              .replaceAll('Ligue 1', 'L1');
  }

  String get countryName => area?.name ?? 'Unknown';
  String get countryFlag => area?.flag ?? '';
  
  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'type': type,
      'emblem': emblem,
      'currentSeason': currentSeason,
      'numberOfAvailableSeasons': numberOfAvailableSeasons,
      'lastUpdated': lastUpdated?.millisecondsSinceEpoch,
      'area': area?.toJson(),
      'currentSeasonDetails': currentSeasonDetails?.toJson(),
      'availableSeasons': availableSeasons.map((s) => s.toJson()).toList(),
    };
  }

  static LeagueModel fromFirestore(Map<String, dynamic> data) {
    return LeagueModel(
      id: data['id'],
      name: data['name'],
      code: data['code'],
      type: data['type'],
      emblem: data['emblem'],
      currentSeason: data['currentSeason'],
      numberOfAvailableSeasons: data['numberOfAvailableSeasons'],
      lastUpdated: data['lastUpdated'] != null
          ? DateTime.fromMillisecondsSinceEpoch(data['lastUpdated'])
          : null,
      area: data['area'] != null ? AreaModel.fromJson(data['area']) : null,
      currentSeasonDetails: data['currentSeasonDetails'] != null
          ? CurrentSeasonModel.fromJson(data['currentSeasonDetails'])
          : null,
      availableSeasons: (data['availableSeasons'] as List<dynamic>?)
              ?.map((s) => SeasonModel.fromJson(s))
              .toList() ??
          [],
    );
  }
}