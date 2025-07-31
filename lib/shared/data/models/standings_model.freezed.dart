// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'standings_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

StandingsModel _$StandingsModelFromJson(Map<String, dynamic> json) {
  return _StandingsModel.fromJson(json);
}

/// @nodoc
mixin _$StandingsModel {
  String get stage => throw _privateConstructorUsedError;
  String get type => throw _privateConstructorUsedError;
  String? get group => throw _privateConstructorUsedError;
  List<StandingTableModel> get table => throw _privateConstructorUsedError;

  /// Serializes this StandingsModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of StandingsModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $StandingsModelCopyWith<StandingsModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $StandingsModelCopyWith<$Res> {
  factory $StandingsModelCopyWith(
          StandingsModel value, $Res Function(StandingsModel) then) =
      _$StandingsModelCopyWithImpl<$Res, StandingsModel>;
  @useResult
  $Res call(
      {String stage,
      String type,
      String? group,
      List<StandingTableModel> table});
}

/// @nodoc
class _$StandingsModelCopyWithImpl<$Res, $Val extends StandingsModel>
    implements $StandingsModelCopyWith<$Res> {
  _$StandingsModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of StandingsModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? stage = null,
    Object? type = null,
    Object? group = freezed,
    Object? table = null,
  }) {
    return _then(_value.copyWith(
      stage: null == stage
          ? _value.stage
          : stage // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      group: freezed == group
          ? _value.group
          : group // ignore: cast_nullable_to_non_nullable
              as String?,
      table: null == table
          ? _value.table
          : table // ignore: cast_nullable_to_non_nullable
              as List<StandingTableModel>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$StandingsModelImplCopyWith<$Res>
    implements $StandingsModelCopyWith<$Res> {
  factory _$$StandingsModelImplCopyWith(_$StandingsModelImpl value,
          $Res Function(_$StandingsModelImpl) then) =
      __$$StandingsModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String stage,
      String type,
      String? group,
      List<StandingTableModel> table});
}

/// @nodoc
class __$$StandingsModelImplCopyWithImpl<$Res>
    extends _$StandingsModelCopyWithImpl<$Res, _$StandingsModelImpl>
    implements _$$StandingsModelImplCopyWith<$Res> {
  __$$StandingsModelImplCopyWithImpl(
      _$StandingsModelImpl _value, $Res Function(_$StandingsModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of StandingsModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? stage = null,
    Object? type = null,
    Object? group = freezed,
    Object? table = null,
  }) {
    return _then(_$StandingsModelImpl(
      stage: null == stage
          ? _value.stage
          : stage // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      group: freezed == group
          ? _value.group
          : group // ignore: cast_nullable_to_non_nullable
              as String?,
      table: null == table
          ? _value._table
          : table // ignore: cast_nullable_to_non_nullable
              as List<StandingTableModel>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$StandingsModelImpl implements _StandingsModel {
  const _$StandingsModelImpl(
      {required this.stage,
      required this.type,
      this.group,
      required final List<StandingTableModel> table})
      : _table = table;

  factory _$StandingsModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$StandingsModelImplFromJson(json);

  @override
  final String stage;
  @override
  final String type;
  @override
  final String? group;
  final List<StandingTableModel> _table;
  @override
  List<StandingTableModel> get table {
    if (_table is EqualUnmodifiableListView) return _table;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_table);
  }

  @override
  String toString() {
    return 'StandingsModel(stage: $stage, type: $type, group: $group, table: $table)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$StandingsModelImpl &&
            (identical(other.stage, stage) || other.stage == stage) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.group, group) || other.group == group) &&
            const DeepCollectionEquality().equals(other._table, _table));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, stage, type, group,
      const DeepCollectionEquality().hash(_table));

  /// Create a copy of StandingsModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$StandingsModelImplCopyWith<_$StandingsModelImpl> get copyWith =>
      __$$StandingsModelImplCopyWithImpl<_$StandingsModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$StandingsModelImplToJson(
      this,
    );
  }
}

abstract class _StandingsModel implements StandingsModel {
  const factory _StandingsModel(
      {required final String stage,
      required final String type,
      final String? group,
      required final List<StandingTableModel> table}) = _$StandingsModelImpl;

  factory _StandingsModel.fromJson(Map<String, dynamic> json) =
      _$StandingsModelImpl.fromJson;

  @override
  String get stage;
  @override
  String get type;
  @override
  String? get group;
  @override
  List<StandingTableModel> get table;

  /// Create a copy of StandingsModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$StandingsModelImplCopyWith<_$StandingsModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

StandingTableModel _$StandingTableModelFromJson(Map<String, dynamic> json) {
  return _StandingTableModel.fromJson(json);
}

/// @nodoc
mixin _$StandingTableModel {
  int get position => throw _privateConstructorUsedError;
  TeamStandingModel get team => throw _privateConstructorUsedError;
  int get playedGames => throw _privateConstructorUsedError;
  String? get form => throw _privateConstructorUsedError;
  int get won => throw _privateConstructorUsedError;
  int get draw => throw _privateConstructorUsedError;
  int get lost => throw _privateConstructorUsedError;
  int get points => throw _privateConstructorUsedError;
  int get goalsFor => throw _privateConstructorUsedError;
  int get goalsAgainst => throw _privateConstructorUsedError;
  int get goalDifference => throw _privateConstructorUsedError;

  /// Serializes this StandingTableModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of StandingTableModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $StandingTableModelCopyWith<StandingTableModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $StandingTableModelCopyWith<$Res> {
  factory $StandingTableModelCopyWith(
          StandingTableModel value, $Res Function(StandingTableModel) then) =
      _$StandingTableModelCopyWithImpl<$Res, StandingTableModel>;
  @useResult
  $Res call(
      {int position,
      TeamStandingModel team,
      int playedGames,
      String? form,
      int won,
      int draw,
      int lost,
      int points,
      int goalsFor,
      int goalsAgainst,
      int goalDifference});

  $TeamStandingModelCopyWith<$Res> get team;
}

/// @nodoc
class _$StandingTableModelCopyWithImpl<$Res, $Val extends StandingTableModel>
    implements $StandingTableModelCopyWith<$Res> {
  _$StandingTableModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of StandingTableModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? position = null,
    Object? team = null,
    Object? playedGames = null,
    Object? form = freezed,
    Object? won = null,
    Object? draw = null,
    Object? lost = null,
    Object? points = null,
    Object? goalsFor = null,
    Object? goalsAgainst = null,
    Object? goalDifference = null,
  }) {
    return _then(_value.copyWith(
      position: null == position
          ? _value.position
          : position // ignore: cast_nullable_to_non_nullable
              as int,
      team: null == team
          ? _value.team
          : team // ignore: cast_nullable_to_non_nullable
              as TeamStandingModel,
      playedGames: null == playedGames
          ? _value.playedGames
          : playedGames // ignore: cast_nullable_to_non_nullable
              as int,
      form: freezed == form
          ? _value.form
          : form // ignore: cast_nullable_to_non_nullable
              as String?,
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

  /// Create a copy of StandingTableModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $TeamStandingModelCopyWith<$Res> get team {
    return $TeamStandingModelCopyWith<$Res>(_value.team, (value) {
      return _then(_value.copyWith(team: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$StandingTableModelImplCopyWith<$Res>
    implements $StandingTableModelCopyWith<$Res> {
  factory _$$StandingTableModelImplCopyWith(_$StandingTableModelImpl value,
          $Res Function(_$StandingTableModelImpl) then) =
      __$$StandingTableModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int position,
      TeamStandingModel team,
      int playedGames,
      String? form,
      int won,
      int draw,
      int lost,
      int points,
      int goalsFor,
      int goalsAgainst,
      int goalDifference});

  @override
  $TeamStandingModelCopyWith<$Res> get team;
}

/// @nodoc
class __$$StandingTableModelImplCopyWithImpl<$Res>
    extends _$StandingTableModelCopyWithImpl<$Res, _$StandingTableModelImpl>
    implements _$$StandingTableModelImplCopyWith<$Res> {
  __$$StandingTableModelImplCopyWithImpl(_$StandingTableModelImpl _value,
      $Res Function(_$StandingTableModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of StandingTableModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? position = null,
    Object? team = null,
    Object? playedGames = null,
    Object? form = freezed,
    Object? won = null,
    Object? draw = null,
    Object? lost = null,
    Object? points = null,
    Object? goalsFor = null,
    Object? goalsAgainst = null,
    Object? goalDifference = null,
  }) {
    return _then(_$StandingTableModelImpl(
      position: null == position
          ? _value.position
          : position // ignore: cast_nullable_to_non_nullable
              as int,
      team: null == team
          ? _value.team
          : team // ignore: cast_nullable_to_non_nullable
              as TeamStandingModel,
      playedGames: null == playedGames
          ? _value.playedGames
          : playedGames // ignore: cast_nullable_to_non_nullable
              as int,
      form: freezed == form
          ? _value.form
          : form // ignore: cast_nullable_to_non_nullable
              as String?,
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
class _$StandingTableModelImpl implements _StandingTableModel {
  const _$StandingTableModelImpl(
      {required this.position,
      required this.team,
      required this.playedGames,
      this.form,
      required this.won,
      required this.draw,
      required this.lost,
      required this.points,
      required this.goalsFor,
      required this.goalsAgainst,
      required this.goalDifference});

  factory _$StandingTableModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$StandingTableModelImplFromJson(json);

  @override
  final int position;
  @override
  final TeamStandingModel team;
  @override
  final int playedGames;
  @override
  final String? form;
  @override
  final int won;
  @override
  final int draw;
  @override
  final int lost;
  @override
  final int points;
  @override
  final int goalsFor;
  @override
  final int goalsAgainst;
  @override
  final int goalDifference;

  @override
  String toString() {
    return 'StandingTableModel(position: $position, team: $team, playedGames: $playedGames, form: $form, won: $won, draw: $draw, lost: $lost, points: $points, goalsFor: $goalsFor, goalsAgainst: $goalsAgainst, goalDifference: $goalDifference)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$StandingTableModelImpl &&
            (identical(other.position, position) ||
                other.position == position) &&
            (identical(other.team, team) || other.team == team) &&
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
  int get hashCode => Object.hash(runtimeType, position, team, playedGames,
      form, won, draw, lost, points, goalsFor, goalsAgainst, goalDifference);

  /// Create a copy of StandingTableModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$StandingTableModelImplCopyWith<_$StandingTableModelImpl> get copyWith =>
      __$$StandingTableModelImplCopyWithImpl<_$StandingTableModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$StandingTableModelImplToJson(
      this,
    );
  }
}

abstract class _StandingTableModel implements StandingTableModel {
  const factory _StandingTableModel(
      {required final int position,
      required final TeamStandingModel team,
      required final int playedGames,
      final String? form,
      required final int won,
      required final int draw,
      required final int lost,
      required final int points,
      required final int goalsFor,
      required final int goalsAgainst,
      required final int goalDifference}) = _$StandingTableModelImpl;

  factory _StandingTableModel.fromJson(Map<String, dynamic> json) =
      _$StandingTableModelImpl.fromJson;

  @override
  int get position;
  @override
  TeamStandingModel get team;
  @override
  int get playedGames;
  @override
  String? get form;
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

  /// Create a copy of StandingTableModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$StandingTableModelImplCopyWith<_$StandingTableModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

TeamStandingModel _$TeamStandingModelFromJson(Map<String, dynamic> json) {
  return _TeamStandingModel.fromJson(json);
}

/// @nodoc
mixin _$TeamStandingModel {
  int get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get shortName => throw _privateConstructorUsedError;
  String get tla => throw _privateConstructorUsedError;
  String get crest => throw _privateConstructorUsedError;

  /// Serializes this TeamStandingModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TeamStandingModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TeamStandingModelCopyWith<TeamStandingModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TeamStandingModelCopyWith<$Res> {
  factory $TeamStandingModelCopyWith(
          TeamStandingModel value, $Res Function(TeamStandingModel) then) =
      _$TeamStandingModelCopyWithImpl<$Res, TeamStandingModel>;
  @useResult
  $Res call({int id, String name, String shortName, String tla, String crest});
}

/// @nodoc
class _$TeamStandingModelCopyWithImpl<$Res, $Val extends TeamStandingModel>
    implements $TeamStandingModelCopyWith<$Res> {
  _$TeamStandingModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TeamStandingModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? shortName = null,
    Object? tla = null,
    Object? crest = null,
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
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TeamStandingModelImplCopyWith<$Res>
    implements $TeamStandingModelCopyWith<$Res> {
  factory _$$TeamStandingModelImplCopyWith(_$TeamStandingModelImpl value,
          $Res Function(_$TeamStandingModelImpl) then) =
      __$$TeamStandingModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int id, String name, String shortName, String tla, String crest});
}

/// @nodoc
class __$$TeamStandingModelImplCopyWithImpl<$Res>
    extends _$TeamStandingModelCopyWithImpl<$Res, _$TeamStandingModelImpl>
    implements _$$TeamStandingModelImplCopyWith<$Res> {
  __$$TeamStandingModelImplCopyWithImpl(_$TeamStandingModelImpl _value,
      $Res Function(_$TeamStandingModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of TeamStandingModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? shortName = null,
    Object? tla = null,
    Object? crest = null,
  }) {
    return _then(_$TeamStandingModelImpl(
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
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TeamStandingModelImpl implements _TeamStandingModel {
  const _$TeamStandingModelImpl(
      {required this.id,
      required this.name,
      required this.shortName,
      required this.tla,
      required this.crest});

  factory _$TeamStandingModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$TeamStandingModelImplFromJson(json);

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
  String toString() {
    return 'TeamStandingModel(id: $id, name: $name, shortName: $shortName, tla: $tla, crest: $crest)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TeamStandingModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.shortName, shortName) ||
                other.shortName == shortName) &&
            (identical(other.tla, tla) || other.tla == tla) &&
            (identical(other.crest, crest) || other.crest == crest));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, name, shortName, tla, crest);

  /// Create a copy of TeamStandingModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TeamStandingModelImplCopyWith<_$TeamStandingModelImpl> get copyWith =>
      __$$TeamStandingModelImplCopyWithImpl<_$TeamStandingModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TeamStandingModelImplToJson(
      this,
    );
  }
}

abstract class _TeamStandingModel implements TeamStandingModel {
  const factory _TeamStandingModel(
      {required final int id,
      required final String name,
      required final String shortName,
      required final String tla,
      required final String crest}) = _$TeamStandingModelImpl;

  factory _TeamStandingModel.fromJson(Map<String, dynamic> json) =
      _$TeamStandingModelImpl.fromJson;

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

  /// Create a copy of TeamStandingModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TeamStandingModelImplCopyWith<_$TeamStandingModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

LeagueStandingsModel _$LeagueStandingsModelFromJson(Map<String, dynamic> json) {
  return _LeagueStandingsModel.fromJson(json);
}

/// @nodoc
mixin _$LeagueStandingsModel {
  CompetitionModel get competition => throw _privateConstructorUsedError;
  SeasonModel get season => throw _privateConstructorUsedError;
  List<StandingsModel> get standings => throw _privateConstructorUsedError;
  DateTime? get lastUpdated => throw _privateConstructorUsedError;

  /// Serializes this LeagueStandingsModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of LeagueStandingsModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LeagueStandingsModelCopyWith<LeagueStandingsModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LeagueStandingsModelCopyWith<$Res> {
  factory $LeagueStandingsModelCopyWith(LeagueStandingsModel value,
          $Res Function(LeagueStandingsModel) then) =
      _$LeagueStandingsModelCopyWithImpl<$Res, LeagueStandingsModel>;
  @useResult
  $Res call(
      {CompetitionModel competition,
      SeasonModel season,
      List<StandingsModel> standings,
      DateTime? lastUpdated});
}

/// @nodoc
class _$LeagueStandingsModelCopyWithImpl<$Res,
        $Val extends LeagueStandingsModel>
    implements $LeagueStandingsModelCopyWith<$Res> {
  _$LeagueStandingsModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LeagueStandingsModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? competition = freezed,
    Object? season = freezed,
    Object? standings = null,
    Object? lastUpdated = freezed,
  }) {
    return _then(_value.copyWith(
      competition: freezed == competition
          ? _value.competition
          : competition // ignore: cast_nullable_to_non_nullable
              as CompetitionModel,
      season: freezed == season
          ? _value.season
          : season // ignore: cast_nullable_to_non_nullable
              as SeasonModel,
      standings: null == standings
          ? _value.standings
          : standings // ignore: cast_nullable_to_non_nullable
              as List<StandingsModel>,
      lastUpdated: freezed == lastUpdated
          ? _value.lastUpdated
          : lastUpdated // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$LeagueStandingsModelImplCopyWith<$Res>
    implements $LeagueStandingsModelCopyWith<$Res> {
  factory _$$LeagueStandingsModelImplCopyWith(_$LeagueStandingsModelImpl value,
          $Res Function(_$LeagueStandingsModelImpl) then) =
      __$$LeagueStandingsModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {CompetitionModel competition,
      SeasonModel season,
      List<StandingsModel> standings,
      DateTime? lastUpdated});
}

/// @nodoc
class __$$LeagueStandingsModelImplCopyWithImpl<$Res>
    extends _$LeagueStandingsModelCopyWithImpl<$Res, _$LeagueStandingsModelImpl>
    implements _$$LeagueStandingsModelImplCopyWith<$Res> {
  __$$LeagueStandingsModelImplCopyWithImpl(_$LeagueStandingsModelImpl _value,
      $Res Function(_$LeagueStandingsModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of LeagueStandingsModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? competition = freezed,
    Object? season = freezed,
    Object? standings = null,
    Object? lastUpdated = freezed,
  }) {
    return _then(_$LeagueStandingsModelImpl(
      competition: freezed == competition
          ? _value.competition
          : competition // ignore: cast_nullable_to_non_nullable
              as CompetitionModel,
      season: freezed == season
          ? _value.season
          : season // ignore: cast_nullable_to_non_nullable
              as SeasonModel,
      standings: null == standings
          ? _value._standings
          : standings // ignore: cast_nullable_to_non_nullable
              as List<StandingsModel>,
      lastUpdated: freezed == lastUpdated
          ? _value.lastUpdated
          : lastUpdated // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$LeagueStandingsModelImpl implements _LeagueStandingsModel {
  const _$LeagueStandingsModelImpl(
      {required this.competition,
      required this.season,
      required final List<StandingsModel> standings,
      this.lastUpdated})
      : _standings = standings;

  factory _$LeagueStandingsModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$LeagueStandingsModelImplFromJson(json);

  @override
  final CompetitionModel competition;
  @override
  final SeasonModel season;
  final List<StandingsModel> _standings;
  @override
  List<StandingsModel> get standings {
    if (_standings is EqualUnmodifiableListView) return _standings;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_standings);
  }

  @override
  final DateTime? lastUpdated;

  @override
  String toString() {
    return 'LeagueStandingsModel(competition: $competition, season: $season, standings: $standings, lastUpdated: $lastUpdated)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LeagueStandingsModelImpl &&
            const DeepCollectionEquality()
                .equals(other.competition, competition) &&
            const DeepCollectionEquality().equals(other.season, season) &&
            const DeepCollectionEquality()
                .equals(other._standings, _standings) &&
            (identical(other.lastUpdated, lastUpdated) ||
                other.lastUpdated == lastUpdated));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(competition),
      const DeepCollectionEquality().hash(season),
      const DeepCollectionEquality().hash(_standings),
      lastUpdated);

  /// Create a copy of LeagueStandingsModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LeagueStandingsModelImplCopyWith<_$LeagueStandingsModelImpl>
      get copyWith =>
          __$$LeagueStandingsModelImplCopyWithImpl<_$LeagueStandingsModelImpl>(
              this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LeagueStandingsModelImplToJson(
      this,
    );
  }
}

abstract class _LeagueStandingsModel implements LeagueStandingsModel {
  const factory _LeagueStandingsModel(
      {required final CompetitionModel competition,
      required final SeasonModel season,
      required final List<StandingsModel> standings,
      final DateTime? lastUpdated}) = _$LeagueStandingsModelImpl;

  factory _LeagueStandingsModel.fromJson(Map<String, dynamic> json) =
      _$LeagueStandingsModelImpl.fromJson;

  @override
  CompetitionModel get competition;
  @override
  SeasonModel get season;
  @override
  List<StandingsModel> get standings;
  @override
  DateTime? get lastUpdated;

  /// Create a copy of LeagueStandingsModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LeagueStandingsModelImplCopyWith<_$LeagueStandingsModelImpl>
      get copyWith => throw _privateConstructorUsedError;
}
