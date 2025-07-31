// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'league_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$LeagueModelImpl _$$LeagueModelImplFromJson(Map<String, dynamic> json) =>
    _$LeagueModelImpl(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      code: json['code'] as String,
      type: json['type'] as String,
      emblem: json['emblem'] as String,
      currentSeason: (json['currentSeason'] as num).toInt(),
      numberOfAvailableSeasons:
          (json['numberOfAvailableSeasons'] as num).toInt(),
      lastUpdated: json['lastUpdated'] == null
          ? null
          : DateTime.parse(json['lastUpdated'] as String),
      area: json['area'] == null
          ? null
          : AreaModel.fromJson(json['area'] as Map<String, dynamic>),
      currentSeasonDetails: json['currentSeasonDetails'] == null
          ? null
          : CurrentSeasonModel.fromJson(
              json['currentSeasonDetails'] as Map<String, dynamic>),
      availableSeasons: (json['availableSeasons'] as List<dynamic>?)
              ?.map((e) => SeasonModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$LeagueModelImplToJson(_$LeagueModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'code': instance.code,
      'type': instance.type,
      'emblem': instance.emblem,
      'currentSeason': instance.currentSeason,
      'numberOfAvailableSeasons': instance.numberOfAvailableSeasons,
      'lastUpdated': instance.lastUpdated?.toIso8601String(),
      'area': instance.area,
      'currentSeasonDetails': instance.currentSeasonDetails,
      'availableSeasons': instance.availableSeasons,
    };

_$AreaModelImpl _$$AreaModelImplFromJson(Map<String, dynamic> json) =>
    _$AreaModelImpl(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      code: json['code'] as String,
      flag: json['flag'] as String,
    );

Map<String, dynamic> _$$AreaModelImplToJson(_$AreaModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'code': instance.code,
      'flag': instance.flag,
    };

_$CurrentSeasonModelImpl _$$CurrentSeasonModelImplFromJson(
        Map<String, dynamic> json) =>
    _$CurrentSeasonModelImpl(
      id: (json['id'] as num).toInt(),
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      currentMatchday: (json['currentMatchday'] as num).toInt(),
      winner: json['winner'] as String?,
    );

Map<String, dynamic> _$$CurrentSeasonModelImplToJson(
        _$CurrentSeasonModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'startDate': instance.startDate.toIso8601String(),
      'endDate': instance.endDate.toIso8601String(),
      'currentMatchday': instance.currentMatchday,
      'winner': instance.winner,
    };

_$SeasonModelImpl _$$SeasonModelImplFromJson(Map<String, dynamic> json) =>
    _$SeasonModelImpl(
      id: (json['id'] as num).toInt(),
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      currentMatchday: (json['currentMatchday'] as num).toInt(),
      winner: json['winner'] as String?,
    );

Map<String, dynamic> _$$SeasonModelImplToJson(_$SeasonModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'startDate': instance.startDate.toIso8601String(),
      'endDate': instance.endDate.toIso8601String(),
      'currentMatchday': instance.currentMatchday,
      'winner': instance.winner,
    };
