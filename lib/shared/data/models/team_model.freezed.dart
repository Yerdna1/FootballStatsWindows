// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'team_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

TeamModel _$TeamModelFromJson(Map<String, dynamic> json) {
  return _TeamModel.fromJson(json);
}

/// @nodoc
mixin _$TeamModel {
  int get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get shortName => throw _privateConstructorUsedError;
  String get tla => throw _privateConstructorUsedError;
  String get crest => throw _privateConstructorUsedError;
  String? get address => throw _privateConstructorUsedError;
  String? get website => throw _privateConstructorUsedError;
  int? get founded => throw _privateConstructorUsedError;
  String? get clubColors => throw _privateConstructorUsedError;
  String? get venue => throw _privateConstructorUsedError;
  AreaModel? get area => throw _privateConstructorUsedError;
  List<RunningCompetitionModel>? get runningCompetitions =>
      throw _privateConstructorUsedError;
  CoachModel? get coach => throw _privateConstructorUsedError;
  List<PlayerModel>? get squad => throw _privateConstructorUsedError;
  TeamStatisticsModel? get statistics => throw _privateConstructorUsedError;
  DateTime? get lastUpdated => throw _privateConstructorUsedError;

  /// Serializes this TeamModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TeamModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TeamModelCopyWith<TeamModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TeamModelCopyWith<$Res> {
  factory $TeamModelCopyWith(TeamModel value, $Res Function(TeamModel) then) =
      _$TeamModelCopyWithImpl<$Res, TeamModel>;
  @useResult
  $Res call(
      {int id,
      String name,
      String shortName,
      String tla,
      String crest,
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
      DateTime? lastUpdated});

  $CoachModelCopyWith<$Res>? get coach;
  $TeamStatisticsModelCopyWith<$Res>? get statistics;
}

/// @nodoc
class _$TeamModelCopyWithImpl<$Res, $Val extends TeamModel>
    implements $TeamModelCopyWith<$Res> {
  _$TeamModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TeamModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? shortName = null,
    Object? tla = null,
    Object? crest = null,
    Object? address = freezed,
    Object? website = freezed,
    Object? founded = freezed,
    Object? clubColors = freezed,
    Object? venue = freezed,
    Object? area = freezed,
    Object? runningCompetitions = freezed,
    Object? coach = freezed,
    Object? squad = freezed,
    Object? statistics = freezed,
    Object? lastUpdated = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      shortName: null == shortName
          ? _value.shortName
          : shortName // ignore: cast_nullable_to_non_nullable
              as String,
      tla: null == tla
          ? _value.tla
          : tla // ignore: cast_nullable_to_non_nullable
              as String,
      crest: null == crest
          ? _value.crest
          : crest // ignore: cast_nullable_to_non_nullable
              as String,
      address: freezed == address
          ? _value.address
          : address // ignore: cast_nullable_to_non_nullable
              as String?,
      website: freezed == website
          ? _value.website
          : website // ignore: cast_nullable_to_non_nullable
              as String?,
      founded: freezed == founded
          ? _value.founded
          : founded // ignore: cast_nullable_to_non_nullable
              as int?,
      clubColors: freezed == clubColors
          ? _value.clubColors
          : clubColors // ignore: cast_nullable_to_non_nullable
              as String?,
      venue: freezed == venue
          ? _value.venue
          : venue // ignore: cast_nullable_to_non_nullable
              as String?,
      area: freezed == area
          ? _value.area
          : area // ignore: cast_nullable_to_non_nullable
              as AreaModel?,
      runningCompetitions: freezed == runningCompetitions
          ? _value.runningCompetitions
          : runningCompetitions // ignore: cast_nullable_to_non_nullable
              as List<RunningCompetitionModel>?,
      coach: freezed == coach
          ? _value.coach
          : coach // ignore: cast_nullable_to_non_nullable
              as CoachModel?,
      squad: freezed == squad
          ? _value.squad
          : squad // ignore: cast_nullable_to_non_nullable
              as List<PlayerModel>?,
      statistics: freezed == statistics
          ? _value.statistics
          : statistics // ignore: cast_nullable_to_non_nullable
              as TeamStatisticsModel?,
      lastUpdated: freezed == lastUpdated
          ? _value.lastUpdated
          : lastUpdated // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }

  /// Create a copy of TeamModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $CoachModelCopyWith<$Res>? get coach {
    if (_value.coach == null) {
      return null;
    }

    return $CoachModelCopyWith<$Res>(_value.coach!, (value) {
      return _then(_value.copyWith(coach: value) as $Val);
    });
  }

  /// Create a copy of TeamModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $TeamStatisticsModelCopyWith<$Res>? get statistics {
    if (_value.statistics == null) {
      return null;
    }

    return $TeamStatisticsModelCopyWith<$Res>(_value.statistics!, (value) {
      return _then(_value.copyWith(statistics: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$TeamModelImplCopyWith<$Res>
    implements $TeamModelCopyWith<$Res> {
  factory _$$TeamModelImplCopyWith(
          _$TeamModelImpl value, $Res Function(_$TeamModelImpl) then) =
      __$$TeamModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id,
      String name,
      String shortName,
      String tla,
      String crest,
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
      DateTime? lastUpdated});

  @override
  $CoachModelCopyWith<$Res>? get coach;
  @override
  $TeamStatisticsModelCopyWith<$Res>? get statistics;
}

/// @nodoc
class __$$TeamModelImplCopyWithImpl<$Res>
    extends _$TeamModelCopyWithImpl<$Res, _$TeamModelImpl>
    implements _$$TeamModelImplCopyWith<$Res> {
  __$$TeamModelImplCopyWithImpl(
      _$TeamModelImpl _value, $Res Function(_$TeamModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of TeamModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? shortName = null,
    Object? tla = null,
    Object? crest = null,
    Object? address = freezed,
    Object? website = freezed,
    Object? founded = freezed,
    Object? clubColors = freezed,
    Object? venue = freezed,
    Object? area = freezed,
    Object? runningCompetitions = freezed,
    Object? coach = freezed,
    Object? squad = freezed,
    Object? statistics = freezed,
    Object? lastUpdated = freezed,
  }) {
    return _then(_$TeamModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      shortName: null == shortName
          ? _value.shortName
          : shortName // ignore: cast_nullable_to_non_nullable
              as String,
      tla: null == tla
          ? _value.tla
          : tla // ignore: cast_nullable_to_non_nullable
              as String,
      crest: null == crest
          ? _value.crest
          : crest // ignore: cast_nullable_to_non_nullable
              as String,
      address: freezed == address
          ? _value.address
          : address // ignore: cast_nullable_to_non_nullable
              as String?,
      website: freezed == website
          ? _value.website
          : website // ignore: cast_nullable_to_non_nullable
              as String?,
      founded: freezed == founded
          ? _value.founded
          : founded // ignore: cast_nullable_to_non_nullable
              as int?,
      clubColors: freezed == clubColors
          ? _value.clubColors
          : clubColors // ignore: cast_nullable_to_non_nullable
              as String?,
      venue: freezed == venue
          ? _value.venue
          : venue // ignore: cast_nullable_to_non_nullable
              as String?,
      area: freezed == area
          ? _value.area
          : area // ignore: cast_nullable_to_non_nullable
              as AreaModel?,
      runningCompetitions: freezed == runningCompetitions
          ? _value._runningCompetitions
          : runningCompetitions // ignore: cast_nullable_to_non_nullable
              as List<RunningCompetitionModel>?,
      coach: freezed == coach
          ? _value.coach
          : coach // ignore: cast_nullable_to_non_nullable
              as CoachModel?,
      squad: freezed == squad
          ? _value._squad
          : squad // ignore: cast_nullable_to_non_nullable
              as List<PlayerModel>?,
      statistics: freezed == statistics
          ? _value.statistics
          : statistics // ignore: cast_nullable_to_non_nullable
              as TeamStatisticsModel?,
      lastUpdated: freezed == lastUpdated
          ? _value.lastUpdated
          : lastUpdated // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TeamModelImpl implements _TeamModel {
  const _$TeamModelImpl(
      {required this.id,
      required this.name,
      required this.shortName,
      required this.tla,
      required this.crest,
      this.address,
      this.website,
      this.founded,
      this.clubColors,
      this.venue,
      this.area,
      final List<RunningCompetitionModel>? runningCompetitions,
      this.coach,
      final List<PlayerModel>? squad,
      this.statistics,
      this.lastUpdated})
      : _runningCompetitions = runningCompetitions,
        _squad = squad;

  factory _$TeamModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$TeamModelImplFromJson(json);

  @override
  final int id;
  @override
  final String name;
  @override
  final String shortName;
  @override
  final String tla;
  @override
  final String crest;
  @override
  final String? address;
  @override
  final String? website;
  @override
  final int? founded;
  @override
  final String? clubColors;
  @override
  final String? venue;
  @override
  final AreaModel? area;
  final List<RunningCompetitionModel>? _runningCompetitions;
  @override
  List<RunningCompetitionModel>? get runningCompetitions {
    final value = _runningCompetitions;
    if (value == null) return null;
    if (_runningCompetitions is EqualUnmodifiableListView)
      return _runningCompetitions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  final CoachModel? coach;
  final List<PlayerModel>? _squad;
  @override
  List<PlayerModel>? get squad {
    final value = _squad;
    if (value == null) return null;
    if (_squad is EqualUnmodifiableListView) return _squad;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  final TeamStatisticsModel? statistics;
  @override
  final DateTime? lastUpdated;

  @override
  String toString() {
    return 'TeamModel(id: $id, name: $name, shortName: $shortName, tla: $tla, crest: $crest, address: $address, website: $website, founded: $founded, clubColors: $clubColors, venue: $venue, area: $area, runningCompetitions: $runningCompetitions, coach: $coach, squad: $squad, statistics: $statistics, lastUpdated: $lastUpdated)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TeamModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.shortName, shortName) ||
                other.shortName == shortName) &&
            (identical(other.tla, tla) || other.tla == tla) &&
            (identical(other.crest, crest) || other.crest == crest) &&
            (identical(other.address, address) || other.address == address) &&
            (identical(other.website, website) || other.website == website) &&
            (identical(other.founded, founded) || other.founded == founded) &&
            (identical(other.clubColors, clubColors) ||
                other.clubColors == clubColors) &&
            (identical(other.venue, venue) || other.venue == venue) &&
            const DeepCollectionEquality().equals(other.area, area) &&
            const DeepCollectionEquality()
                .equals(other._runningCompetitions, _runningCompetitions) &&
            (identical(other.coach, coach) || other.coach == coach) &&
            const DeepCollectionEquality().equals(other._squad, _squad) &&
            (identical(other.statistics, statistics) ||
                other.statistics == statistics) &&
            (identical(other.lastUpdated, lastUpdated) ||
                other.lastUpdated == lastUpdated));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
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
      const DeepCollectionEquality().hash(area),
      const DeepCollectionEquality().hash(_runningCompetitions),
      coach,
      const DeepCollectionEquality().hash(_squad),
      statistics,
      lastUpdated);

  /// Create a copy of TeamModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TeamModelImplCopyWith<_$TeamModelImpl> get copyWith =>
      __$$TeamModelImplCopyWithImpl<_$TeamModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TeamModelImplToJson(
      this,
    );
  }
}

abstract class _TeamModel implements TeamModel {
  const factory _TeamModel(
      {required final int id,
      required final String name,
      required final String shortName,
      required final String tla,
      required final String crest,
      final String? address,
      final String? website,
      final int? founded,
      final String? clubColors,
      final String? venue,
      final AreaModel? area,
      final List<RunningCompetitionModel>? runningCompetitions,
      final CoachModel? coach,
      final List<PlayerModel>? squad,
      final TeamStatisticsModel? statistics,
      final DateTime? lastUpdated}) = _$TeamModelImpl;

  factory _TeamModel.fromJson(Map<String, dynamic> json) =
      _$TeamModelImpl.fromJson;

  @override
  int get id;
  @override
  String get name;
  @override
  String get shortName;
  @override
  String get tla;
  @override
  String get crest;
  @override
  String? get address;
  @override
  String? get website;
  @override
  int? get founded;
  @override
  String? get clubColors;
  @override
  String? get venue;
  @override
  AreaModel? get area;
  @override
  List<RunningCompetitionModel>? get runningCompetitions;
  @override
  CoachModel? get coach;
  @override
  List<PlayerModel>? get squad;
  @override
  TeamStatisticsModel? get statistics;
  @override
  DateTime? get lastUpdated;

  /// Create a copy of TeamModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TeamModelImplCopyWith<_$TeamModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

RunningCompetitionModel _$RunningCompetitionModelFromJson(
    Map<String, dynamic> json) {
  return _RunningCompetitionModel.fromJson(json);
}

/// @nodoc
mixin _$RunningCompetitionModel {
  int get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get code => throw _privateConstructorUsedError;
  String get type => throw _privateConstructorUsedError;
  String get emblem => throw _privateConstructorUsedError;

  /// Serializes this RunningCompetitionModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of RunningCompetitionModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RunningCompetitionModelCopyWith<RunningCompetitionModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RunningCompetitionModelCopyWith<$Res> {
  factory $RunningCompetitionModelCopyWith(RunningCompetitionModel value,
          $Res Function(RunningCompetitionModel) then) =
      _$RunningCompetitionModelCopyWithImpl<$Res, RunningCompetitionModel>;
  @useResult
  $Res call({int id, String name, String code, String type, String emblem});
}

/// @nodoc
class _$RunningCompetitionModelCopyWithImpl<$Res,
        $Val extends RunningCompetitionModel>
    implements $RunningCompetitionModelCopyWith<$Res> {
  _$RunningCompetitionModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RunningCompetitionModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? code = null,
    Object? type = null,
    Object? emblem = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      code: null == code
          ? _value.code
          : code // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      emblem: null == emblem
          ? _value.emblem
          : emblem // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$RunningCompetitionModelImplCopyWith<$Res>
    implements $RunningCompetitionModelCopyWith<$Res> {
  factory _$$RunningCompetitionModelImplCopyWith(
          _$RunningCompetitionModelImpl value,
          $Res Function(_$RunningCompetitionModelImpl) then) =
      __$$RunningCompetitionModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int id, String name, String code, String type, String emblem});
}

/// @nodoc
class __$$RunningCompetitionModelImplCopyWithImpl<$Res>
    extends _$RunningCompetitionModelCopyWithImpl<$Res,
        _$RunningCompetitionModelImpl>
    implements _$$RunningCompetitionModelImplCopyWith<$Res> {
  __$$RunningCompetitionModelImplCopyWithImpl(
      _$RunningCompetitionModelImpl _value,
      $Res Function(_$RunningCompetitionModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of RunningCompetitionModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? code = null,
    Object? type = null,
    Object? emblem = null,
  }) {
    return _then(_$RunningCompetitionModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      code: null == code
          ? _value.code
          : code // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      emblem: null == emblem
          ? _value.emblem
          : emblem // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$RunningCompetitionModelImpl implements _RunningCompetitionModel {
  const _$RunningCompetitionModelImpl(
      {required this.id,
      required this.name,
      required this.code,
      required this.type,
      required this.emblem});

  factory _$RunningCompetitionModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$RunningCompetitionModelImplFromJson(json);

  @override
  final int id;
  @override
  final String name;
  @override
  final String code;
  @override
  final String type;
  @override
  final String emblem;

  @override
  String toString() {
    return 'RunningCompetitionModel(id: $id, name: $name, code: $code, type: $type, emblem: $emblem)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RunningCompetitionModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.code, code) || other.code == code) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.emblem, emblem) || other.emblem == emblem));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, name, code, type, emblem);

  /// Create a copy of RunningCompetitionModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RunningCompetitionModelImplCopyWith<_$RunningCompetitionModelImpl>
      get copyWith => __$$RunningCompetitionModelImplCopyWithImpl<
          _$RunningCompetitionModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RunningCompetitionModelImplToJson(
      this,
    );
  }
}

abstract class _RunningCompetitionModel implements RunningCompetitionModel {
  const factory _RunningCompetitionModel(
      {required final int id,
      required final String name,
      required final String code,
      required final String type,
      required final String emblem}) = _$RunningCompetitionModelImpl;

  factory _RunningCompetitionModel.fromJson(Map<String, dynamic> json) =
      _$RunningCompetitionModelImpl.fromJson;

  @override
  int get id;
  @override
  String get name;
  @override
  String get code;
  @override
  String get type;
  @override
  String get emblem;

  /// Create a copy of RunningCompetitionModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RunningCompetitionModelImplCopyWith<_$RunningCompetitionModelImpl>
      get copyWith => throw _privateConstructorUsedError;
}

CoachModel _$CoachModelFromJson(Map<String, dynamic> json) {
  return _CoachModel.fromJson(json);
}

/// @nodoc
mixin _$CoachModel {
  int get id => throw _privateConstructorUsedError;
  String get firstName => throw _privateConstructorUsedError;
  String get lastName => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  DateTime? get dateOfBirth => throw _privateConstructorUsedError;
  String? get nationality => throw _privateConstructorUsedError;
  ContractModel? get contract => throw _privateConstructorUsedError;

  /// Serializes this CoachModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CoachModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CoachModelCopyWith<CoachModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CoachModelCopyWith<$Res> {
  factory $CoachModelCopyWith(
          CoachModel value, $Res Function(CoachModel) then) =
      _$CoachModelCopyWithImpl<$Res, CoachModel>;
  @useResult
  $Res call(
      {int id,
      String firstName,
      String lastName,
      String name,
      DateTime? dateOfBirth,
      String? nationality,
      ContractModel? contract});

  $ContractModelCopyWith<$Res>? get contract;
}

/// @nodoc
class _$CoachModelCopyWithImpl<$Res, $Val extends CoachModel>
    implements $CoachModelCopyWith<$Res> {
  _$CoachModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CoachModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? firstName = null,
    Object? lastName = null,
    Object? name = null,
    Object? dateOfBirth = freezed,
    Object? nationality = freezed,
    Object? contract = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      firstName: null == firstName
          ? _value.firstName
          : firstName // ignore: cast_nullable_to_non_nullable
              as String,
      lastName: null == lastName
          ? _value.lastName
          : lastName // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      dateOfBirth: freezed == dateOfBirth
          ? _value.dateOfBirth
          : dateOfBirth // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      nationality: freezed == nationality
          ? _value.nationality
          : nationality // ignore: cast_nullable_to_non_nullable
              as String?,
      contract: freezed == contract
          ? _value.contract
          : contract // ignore: cast_nullable_to_non_nullable
              as ContractModel?,
    ) as $Val);
  }

  /// Create a copy of CoachModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ContractModelCopyWith<$Res>? get contract {
    if (_value.contract == null) {
      return null;
    }

    return $ContractModelCopyWith<$Res>(_value.contract!, (value) {
      return _then(_value.copyWith(contract: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$CoachModelImplCopyWith<$Res>
    implements $CoachModelCopyWith<$Res> {
  factory _$$CoachModelImplCopyWith(
          _$CoachModelImpl value, $Res Function(_$CoachModelImpl) then) =
      __$$CoachModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id,
      String firstName,
      String lastName,
      String name,
      DateTime? dateOfBirth,
      String? nationality,
      ContractModel? contract});

  @override
  $ContractModelCopyWith<$Res>? get contract;
}

/// @nodoc
class __$$CoachModelImplCopyWithImpl<$Res>
    extends _$CoachModelCopyWithImpl<$Res, _$CoachModelImpl>
    implements _$$CoachModelImplCopyWith<$Res> {
  __$$CoachModelImplCopyWithImpl(
      _$CoachModelImpl _value, $Res Function(_$CoachModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of CoachModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? firstName = null,
    Object? lastName = null,
    Object? name = null,
    Object? dateOfBirth = freezed,
    Object? nationality = freezed,
    Object? contract = freezed,
  }) {
    return _then(_$CoachModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      firstName: null == firstName
          ? _value.firstName
          : firstName // ignore: cast_nullable_to_non_nullable
              as String,
      lastName: null == lastName
          ? _value.lastName
          : lastName // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      dateOfBirth: freezed == dateOfBirth
          ? _value.dateOfBirth
          : dateOfBirth // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      nationality: freezed == nationality
          ? _value.nationality
          : nationality // ignore: cast_nullable_to_non_nullable
              as String?,
      contract: freezed == contract
          ? _value.contract
          : contract // ignore: cast_nullable_to_non_nullable
              as ContractModel?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CoachModelImpl implements _CoachModel {
  const _$CoachModelImpl(
      {required this.id,
      required this.firstName,
      required this.lastName,
      required this.name,
      this.dateOfBirth,
      this.nationality,
      this.contract});

  factory _$CoachModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$CoachModelImplFromJson(json);

  @override
  final int id;
  @override
  final String firstName;
  @override
  final String lastName;
  @override
  final String name;
  @override
  final DateTime? dateOfBirth;
  @override
  final String? nationality;
  @override
  final ContractModel? contract;

  @override
  String toString() {
    return 'CoachModel(id: $id, firstName: $firstName, lastName: $lastName, name: $name, dateOfBirth: $dateOfBirth, nationality: $nationality, contract: $contract)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CoachModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.firstName, firstName) ||
                other.firstName == firstName) &&
            (identical(other.lastName, lastName) ||
                other.lastName == lastName) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.dateOfBirth, dateOfBirth) ||
                other.dateOfBirth == dateOfBirth) &&
            (identical(other.nationality, nationality) ||
                other.nationality == nationality) &&
            (identical(other.contract, contract) ||
                other.contract == contract));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, firstName, lastName, name,
      dateOfBirth, nationality, contract);

  /// Create a copy of CoachModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CoachModelImplCopyWith<_$CoachModelImpl> get copyWith =>
      __$$CoachModelImplCopyWithImpl<_$CoachModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CoachModelImplToJson(
      this,
    );
  }
}

abstract class _CoachModel implements CoachModel {
  const factory _CoachModel(
      {required final int id,
      required final String firstName,
      required final String lastName,
      required final String name,
      final DateTime? dateOfBirth,
      final String? nationality,
      final ContractModel? contract}) = _$CoachModelImpl;

  factory _CoachModel.fromJson(Map<String, dynamic> json) =
      _$CoachModelImpl.fromJson;

  @override
  int get id;
  @override
  String get firstName;
  @override
  String get lastName;
  @override
  String get name;
  @override
  DateTime? get dateOfBirth;
  @override
  String? get nationality;
  @override
  ContractModel? get contract;

  /// Create a copy of CoachModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CoachModelImplCopyWith<_$CoachModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

PlayerModel _$PlayerModelFromJson(Map<String, dynamic> json) {
  return _PlayerModel.fromJson(json);
}

/// @nodoc
mixin _$PlayerModel {
  int get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get position => throw _privateConstructorUsedError;
  DateTime? get dateOfBirth => throw _privateConstructorUsedError;
  String? get nationality => throw _privateConstructorUsedError;
  ContractModel? get contract => throw _privateConstructorUsedError;

  /// Serializes this PlayerModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PlayerModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PlayerModelCopyWith<PlayerModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PlayerModelCopyWith<$Res> {
  factory $PlayerModelCopyWith(
          PlayerModel value, $Res Function(PlayerModel) then) =
      _$PlayerModelCopyWithImpl<$Res, PlayerModel>;
  @useResult
  $Res call(
      {int id,
      String name,
      String position,
      DateTime? dateOfBirth,
      String? nationality,
      ContractModel? contract});

  $ContractModelCopyWith<$Res>? get contract;
}

/// @nodoc
class _$PlayerModelCopyWithImpl<$Res, $Val extends PlayerModel>
    implements $PlayerModelCopyWith<$Res> {
  _$PlayerModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PlayerModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? position = null,
    Object? dateOfBirth = freezed,
    Object? nationality = freezed,
    Object? contract = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      position: null == position
          ? _value.position
          : position // ignore: cast_nullable_to_non_nullable
              as String,
      dateOfBirth: freezed == dateOfBirth
          ? _value.dateOfBirth
          : dateOfBirth // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      nationality: freezed == nationality
          ? _value.nationality
          : nationality // ignore: cast_nullable_to_non_nullable
              as String?,
      contract: freezed == contract
          ? _value.contract
          : contract // ignore: cast_nullable_to_non_nullable
              as ContractModel?,
    ) as $Val);
  }

  /// Create a copy of PlayerModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ContractModelCopyWith<$Res>? get contract {
    if (_value.contract == null) {
      return null;
    }

    return $ContractModelCopyWith<$Res>(_value.contract!, (value) {
      return _then(_value.copyWith(contract: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$PlayerModelImplCopyWith<$Res>
    implements $PlayerModelCopyWith<$Res> {
  factory _$$PlayerModelImplCopyWith(
          _$PlayerModelImpl value, $Res Function(_$PlayerModelImpl) then) =
      __$$PlayerModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id,
      String name,
      String position,
      DateTime? dateOfBirth,
      String? nationality,
      ContractModel? contract});

  @override
  $ContractModelCopyWith<$Res>? get contract;
}

/// @nodoc
class __$$PlayerModelImplCopyWithImpl<$Res>
    extends _$PlayerModelCopyWithImpl<$Res, _$PlayerModelImpl>
    implements _$$PlayerModelImplCopyWith<$Res> {
  __$$PlayerModelImplCopyWithImpl(
      _$PlayerModelImpl _value, $Res Function(_$PlayerModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of PlayerModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? position = null,
    Object? dateOfBirth = freezed,
    Object? nationality = freezed,
    Object? contract = freezed,
  }) {
    return _then(_$PlayerModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      position: null == position
          ? _value.position
          : position // ignore: cast_nullable_to_non_nullable
              as String,
      dateOfBirth: freezed == dateOfBirth
          ? _value.dateOfBirth
          : dateOfBirth // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      nationality: freezed == nationality
          ? _value.nationality
          : nationality // ignore: cast_nullable_to_non_nullable
              as String?,
      contract: freezed == contract
          ? _value.contract
          : contract // ignore: cast_nullable_to_non_nullable
              as ContractModel?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PlayerModelImpl implements _PlayerModel {
  const _$PlayerModelImpl(
      {required this.id,
      required this.name,
      required this.position,
      this.dateOfBirth,
      this.nationality,
      this.contract});

  factory _$PlayerModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$PlayerModelImplFromJson(json);

  @override
  final int id;
  @override
  final String name;
  @override
  final String position;
  @override
  final DateTime? dateOfBirth;
  @override
  final String? nationality;
  @override
  final ContractModel? contract;

  @override
  String toString() {
    return 'PlayerModel(id: $id, name: $name, position: $position, dateOfBirth: $dateOfBirth, nationality: $nationality, contract: $contract)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PlayerModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.position, position) ||
                other.position == position) &&
            (identical(other.dateOfBirth, dateOfBirth) ||
                other.dateOfBirth == dateOfBirth) &&
            (identical(other.nationality, nationality) ||
                other.nationality == nationality) &&
            (identical(other.contract, contract) ||
                other.contract == contract));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, id, name, position, dateOfBirth, nationality, contract);

  /// Create a copy of PlayerModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PlayerModelImplCopyWith<_$PlayerModelImpl> get copyWith =>
      __$$PlayerModelImplCopyWithImpl<_$PlayerModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PlayerModelImplToJson(
      this,
    );
  }
}

abstract class _PlayerModel implements PlayerModel {
  const factory _PlayerModel(
      {required final int id,
      required final String name,
      required final String position,
      final DateTime? dateOfBirth,
      final String? nationality,
      final ContractModel? contract}) = _$PlayerModelImpl;

  factory _PlayerModel.fromJson(Map<String, dynamic> json) =
      _$PlayerModelImpl.fromJson;

  @override
  int get id;
  @override
  String get name;
  @override
  String get position;
  @override
  DateTime? get dateOfBirth;
  @override
  String? get nationality;
  @override
  ContractModel? get contract;

  /// Create a copy of PlayerModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PlayerModelImplCopyWith<_$PlayerModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ContractModel _$ContractModelFromJson(Map<String, dynamic> json) {
  return _ContractModel.fromJson(json);
}

/// @nodoc
mixin _$ContractModel {
  DateTime? get start => throw _privateConstructorUsedError;
  DateTime? get until => throw _privateConstructorUsedError;

  /// Serializes this ContractModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ContractModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ContractModelCopyWith<ContractModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ContractModelCopyWith<$Res> {
  factory $ContractModelCopyWith(
          ContractModel value, $Res Function(ContractModel) then) =
      _$ContractModelCopyWithImpl<$Res, ContractModel>;
  @useResult
  $Res call({DateTime? start, DateTime? until});
}

/// @nodoc
class _$ContractModelCopyWithImpl<$Res, $Val extends ContractModel>
    implements $ContractModelCopyWith<$Res> {
  _$ContractModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ContractModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? start = freezed,
    Object? until = freezed,
  }) {
    return _then(_value.copyWith(
      start: freezed == start
          ? _value.start
          : start // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      until: freezed == until
          ? _value.until
          : until // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ContractModelImplCopyWith<$Res>
    implements $ContractModelCopyWith<$Res> {
  factory _$$ContractModelImplCopyWith(
          _$ContractModelImpl value, $Res Function(_$ContractModelImpl) then) =
      __$$ContractModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({DateTime? start, DateTime? until});
}

/// @nodoc
class __$$ContractModelImplCopyWithImpl<$Res>
    extends _$ContractModelCopyWithImpl<$Res, _$ContractModelImpl>
    implements _$$ContractModelImplCopyWith<$Res> {
  __$$ContractModelImplCopyWithImpl(
      _$ContractModelImpl _value, $Res Function(_$ContractModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of ContractModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? start = freezed,
    Object? until = freezed,
  }) {
    return _then(_$ContractModelImpl(
      start: freezed == start
          ? _value.start
          : start // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      until: freezed == until
          ? _value.until
          : until // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ContractModelImpl implements _ContractModel {
  const _$ContractModelImpl({this.start, this.until});

  factory _$ContractModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$ContractModelImplFromJson(json);

  @override
  final DateTime? start;
  @override
  final DateTime? until;

  @override
  String toString() {
    return 'ContractModel(start: $start, until: $until)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ContractModelImpl &&
            (identical(other.start, start) || other.start == start) &&
            (identical(other.until, until) || other.until == until));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, start, until);

  /// Create a copy of ContractModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ContractModelImplCopyWith<_$ContractModelImpl> get copyWith =>
      __$$ContractModelImplCopyWithImpl<_$ContractModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ContractModelImplToJson(
      this,
    );
  }
}

abstract class _ContractModel implements ContractModel {
  const factory _ContractModel({final DateTime? start, final DateTime? until}) =
      _$ContractModelImpl;

  factory _ContractModel.fromJson(Map<String, dynamic> json) =
      _$ContractModelImpl.fromJson;

  @override
  DateTime? get start;
  @override
  DateTime? get until;

  /// Create a copy of ContractModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ContractModelImplCopyWith<_$ContractModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

TeamStatisticsModel _$TeamStatisticsModelFromJson(Map<String, dynamic> json) {
  return _TeamStatisticsModel.fromJson(json);
}

/// @nodoc
mixin _$TeamStatisticsModel {
  int get playedGames => throw _privateConstructorUsedError;
  int get form => throw _privateConstructorUsedError;
  int get won => throw _privateConstructorUsedError;
  int get draw => throw _privateConstructorUsedError;
  int get lost => throw _privateConstructorUsedError;
  int get points => throw _privateConstructorUsedError;
  int get goalsFor => throw _privateConstructorUsedError;
  int get goalsAgainst => throw _privateConstructorUsedError;
  int get goalDifference => throw _privateConstructorUsedError;

  /// Serializes this TeamStatisticsModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TeamStatisticsModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TeamStatisticsModelCopyWith<TeamStatisticsModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TeamStatisticsModelCopyWith<$Res> {
  factory $TeamStatisticsModelCopyWith(
          TeamStatisticsModel value, $Res Function(TeamStatisticsModel) then) =
      _$TeamStatisticsModelCopyWithImpl<$Res, TeamStatisticsModel>;
  @useResult
  $Res call(
      {int playedGames,
      int form,
      int won,
      int draw,
      int lost,
      int points,
      int goalsFor,
      int goalsAgainst,
      int goalDifference});
}

/// @nodoc
class _$TeamStatisticsModelCopyWithImpl<$Res, $Val extends TeamStatisticsModel>
    implements $TeamStatisticsModelCopyWith<$Res> {
  _$TeamStatisticsModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TeamStatisticsModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? playedGames = null,
    Object? form = null,
    Object? won = null,
    Object? draw = null,
    Object? lost = null,
    Object? points = null,
    Object? goalsFor = null,
    Object? goalsAgainst = null,
    Object? goalDifference = null,
  }) {
    return _then(_value.copyWith(
      playedGames: null == playedGames
          ? _value.playedGames
          : playedGames // ignore: cast_nullable_to_non_nullable
              as int,
      form: null == form
          ? _value.form
          : form // ignore: cast_nullable_to_non_nullable
              as int,
      won: null == won
          ? _value.won
          : won // ignore: cast_nullable_to_non_nullable
              as int,
      draw: null == draw
          ? _value.draw
          : draw // ignore: cast_nullable_to_non_nullable
              as int,
      lost: null == lost
          ? _value.lost
          : lost // ignore: cast_nullable_to_non_nullable
              as int,
      points: null == points
          ? _value.points
          : points // ignore: cast_nullable_to_non_nullable
              as int,
      goalsFor: null == goalsFor
          ? _value.goalsFor
          : goalsFor // ignore: cast_nullable_to_non_nullable
              as int,
      goalsAgainst: null == goalsAgainst
          ? _value.goalsAgainst
          : goalsAgainst // ignore: cast_nullable_to_non_nullable
              as int,
      goalDifference: null == goalDifference
          ? _value.goalDifference
          : goalDifference // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TeamStatisticsModelImplCopyWith<$Res>
    implements $TeamStatisticsModelCopyWith<$Res> {
  factory _$$TeamStatisticsModelImplCopyWith(_$TeamStatisticsModelImpl value,
          $Res Function(_$TeamStatisticsModelImpl) then) =
      __$$TeamStatisticsModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int playedGames,
      int form,
      int won,
      int draw,
      int lost,
      int points,
      int goalsFor,
      int goalsAgainst,
      int goalDifference});
}

/// @nodoc
class __$$TeamStatisticsModelImplCopyWithImpl<$Res>
    extends _$TeamStatisticsModelCopyWithImpl<$Res, _$TeamStatisticsModelImpl>
    implements _$$TeamStatisticsModelImplCopyWith<$Res> {
  __$$TeamStatisticsModelImplCopyWithImpl(_$TeamStatisticsModelImpl _value,
      $Res Function(_$TeamStatisticsModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of TeamStatisticsModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? playedGames = null,
    Object? form = null,
    Object? won = null,
    Object? draw = null,
    Object? lost = null,
    Object? points = null,
    Object? goalsFor = null,
    Object? goalsAgainst = null,
    Object? goalDifference = null,
  }) {
    return _then(_$TeamStatisticsModelImpl(
      playedGames: null == playedGames
          ? _value.playedGames
          : playedGames // ignore: cast_nullable_to_non_nullable
              as int,
      form: null == form
          ? _value.form
          : form // ignore: cast_nullable_to_non_nullable
              as int,
      won: null == won
          ? _value.won
          : won // ignore: cast_nullable_to_non_nullable
              as int,
      draw: null == draw
          ? _value.draw
          : draw // ignore: cast_nullable_to_non_nullable
              as int,
      lost: null == lost
          ? _value.lost
          : lost // ignore: cast_nullable_to_non_nullable
              as int,
      points: null == points
          ? _value.points
          : points // ignore: cast_nullable_to_non_nullable
              as int,
      goalsFor: null == goalsFor
          ? _value.goalsFor
          : goalsFor // ignore: cast_nullable_to_non_nullable
              as int,
      goalsAgainst: null == goalsAgainst
          ? _value.goalsAgainst
          : goalsAgainst // ignore: cast_nullable_to_non_nullable
              as int,
      goalDifference: null == goalDifference
          ? _value.goalDifference
          : goalDifference // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TeamStatisticsModelImpl implements _TeamStatisticsModel {
  const _$TeamStatisticsModelImpl(
      {this.playedGames = 0,
      this.form = 0,
      this.won = 0,
      this.draw = 0,
      this.lost = 0,
      this.points = 0,
      this.goalsFor = 0,
      this.goalsAgainst = 0,
      this.goalDifference = 0});

  factory _$TeamStatisticsModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$TeamStatisticsModelImplFromJson(json);

  @override
  @JsonKey()
  final int playedGames;
  @override
  @JsonKey()
  final int form;
  @override
  @JsonKey()
  final int won;
  @override
  @JsonKey()
  final int draw;
  @override
  @JsonKey()
  final int lost;
  @override
  @JsonKey()
  final int points;
  @override
  @JsonKey()
  final int goalsFor;
  @override
  @JsonKey()
  final int goalsAgainst;
  @override
  @JsonKey()
  final int goalDifference;

  @override
  String toString() {
    return 'TeamStatisticsModel(playedGames: $playedGames, form: $form, won: $won, draw: $draw, lost: $lost, points: $points, goalsFor: $goalsFor, goalsAgainst: $goalsAgainst, goalDifference: $goalDifference)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TeamStatisticsModelImpl &&
            (identical(other.playedGames, playedGames) ||
                other.playedGames == playedGames) &&
            (identical(other.form, form) || other.form == form) &&
            (identical(other.won, won) || other.won == won) &&
            (identical(other.draw, draw) || other.draw == draw) &&
            (identical(other.lost, lost) || other.lost == lost) &&
            (identical(other.points, points) || other.points == points) &&
            (identical(other.goalsFor, goalsFor) ||
                other.goalsFor == goalsFor) &&
            (identical(other.goalsAgainst, goalsAgainst) ||
                other.goalsAgainst == goalsAgainst) &&
            (identical(other.goalDifference, goalDifference) ||
                other.goalDifference == goalDifference));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, playedGames, form, won, draw,
      lost, points, goalsFor, goalsAgainst, goalDifference);

  /// Create a copy of TeamStatisticsModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TeamStatisticsModelImplCopyWith<_$TeamStatisticsModelImpl> get copyWith =>
      __$$TeamStatisticsModelImplCopyWithImpl<_$TeamStatisticsModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TeamStatisticsModelImplToJson(
      this,
    );
  }
}

abstract class _TeamStatisticsModel implements TeamStatisticsModel {
  const factory _TeamStatisticsModel(
      {final int playedGames,
      final int form,
      final int won,
      final int draw,
      final int lost,
      final int points,
      final int goalsFor,
      final int goalsAgainst,
      final int goalDifference}) = _$TeamStatisticsModelImpl;

  factory _TeamStatisticsModel.fromJson(Map<String, dynamic> json) =
      _$TeamStatisticsModelImpl.fromJson;

  @override
  int get playedGames;
  @override
  int get form;
  @override
  int get won;
  @override
  int get draw;
  @override
  int get lost;
  @override
  int get points;
  @override
  int get goalsFor;
  @override
  int get goalsAgainst;
  @override
  int get goalDifference;

  /// Create a copy of TeamStatisticsModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TeamStatisticsModelImplCopyWith<_$TeamStatisticsModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
