// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'fixture_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

FixtureModel _$FixtureModelFromJson(Map<String, dynamic> json) {
  return _FixtureModel.fromJson(json);
}

/// @nodoc
mixin _$FixtureModel {
  int get id => throw _privateConstructorUsedError;
  DateTime get utcDate => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  int get matchday => throw _privateConstructorUsedError;
  String get stage => throw _privateConstructorUsedError;
  String? get group => throw _privateConstructorUsedError;
  DateTime? get lastUpdated => throw _privateConstructorUsedError;
  CompetitionModel? get competition => throw _privateConstructorUsedError;
  SeasonModel? get season => throw _privateConstructorUsedError;
  TeamFixtureModel get homeTeam => throw _privateConstructorUsedError;
  TeamFixtureModel get awayTeam => throw _privateConstructorUsedError;
  ScoreModel? get score => throw _privateConstructorUsedError;
  List<GoalModel>? get goals => throw _privateConstructorUsedError;
  List<BookingModel>? get bookings => throw _privateConstructorUsedError;
  List<SubstitutionModel>? get substitutions =>
      throw _privateConstructorUsedError;
  OddsModel? get odds => throw _privateConstructorUsedError;
  RefereeModel? get referee => throw _privateConstructorUsedError;

  /// Serializes this FixtureModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of FixtureModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FixtureModelCopyWith<FixtureModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FixtureModelCopyWith<$Res> {
  factory $FixtureModelCopyWith(
          FixtureModel value, $Res Function(FixtureModel) then) =
      _$FixtureModelCopyWithImpl<$Res, FixtureModel>;
  @useResult
  $Res call(
      {int id,
      DateTime utcDate,
      String status,
      int matchday,
      String stage,
      String? group,
      DateTime? lastUpdated,
      CompetitionModel? competition,
      SeasonModel? season,
      TeamFixtureModel homeTeam,
      TeamFixtureModel awayTeam,
      ScoreModel? score,
      List<GoalModel>? goals,
      List<BookingModel>? bookings,
      List<SubstitutionModel>? substitutions,
      OddsModel? odds,
      RefereeModel? referee});

  $CompetitionModelCopyWith<$Res>? get competition;
  $TeamFixtureModelCopyWith<$Res> get homeTeam;
  $TeamFixtureModelCopyWith<$Res> get awayTeam;
  $ScoreModelCopyWith<$Res>? get score;
  $OddsModelCopyWith<$Res>? get odds;
  $RefereeModelCopyWith<$Res>? get referee;
}

/// @nodoc
class _$FixtureModelCopyWithImpl<$Res, $Val extends FixtureModel>
    implements $FixtureModelCopyWith<$Res> {
  _$FixtureModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of FixtureModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? utcDate = null,
    Object? status = null,
    Object? matchday = null,
    Object? stage = null,
    Object? group = freezed,
    Object? lastUpdated = freezed,
    Object? competition = freezed,
    Object? season = freezed,
    Object? homeTeam = null,
    Object? awayTeam = null,
    Object? score = freezed,
    Object? goals = freezed,
    Object? bookings = freezed,
    Object? substitutions = freezed,
    Object? odds = freezed,
    Object? referee = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      utcDate: null == utcDate
          ? _value.utcDate
          : utcDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      matchday: null == matchday
          ? _value.matchday
          : matchday // ignore: cast_nullable_to_non_nullable
              as int,
      stage: null == stage
          ? _value.stage
          : stage // ignore: cast_nullable_to_non_nullable
              as String,
      group: freezed == group
          ? _value.group
          : group // ignore: cast_nullable_to_non_nullable
              as String?,
      lastUpdated: freezed == lastUpdated
          ? _value.lastUpdated
          : lastUpdated // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      competition: freezed == competition
          ? _value.competition
          : competition // ignore: cast_nullable_to_non_nullable
              as CompetitionModel?,
      season: freezed == season
          ? _value.season
          : season // ignore: cast_nullable_to_non_nullable
              as SeasonModel?,
      homeTeam: null == homeTeam
          ? _value.homeTeam
          : homeTeam // ignore: cast_nullable_to_non_nullable
              as TeamFixtureModel,
      awayTeam: null == awayTeam
          ? _value.awayTeam
          : awayTeam // ignore: cast_nullable_to_non_nullable
              as TeamFixtureModel,
      score: freezed == score
          ? _value.score
          : score // ignore: cast_nullable_to_non_nullable
              as ScoreModel?,
      goals: freezed == goals
          ? _value.goals
          : goals // ignore: cast_nullable_to_non_nullable
              as List<GoalModel>?,
      bookings: freezed == bookings
          ? _value.bookings
          : bookings // ignore: cast_nullable_to_non_nullable
              as List<BookingModel>?,
      substitutions: freezed == substitutions
          ? _value.substitutions
          : substitutions // ignore: cast_nullable_to_non_nullable
              as List<SubstitutionModel>?,
      odds: freezed == odds
          ? _value.odds
          : odds // ignore: cast_nullable_to_non_nullable
              as OddsModel?,
      referee: freezed == referee
          ? _value.referee
          : referee // ignore: cast_nullable_to_non_nullable
              as RefereeModel?,
    ) as $Val);
  }

  /// Create a copy of FixtureModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $CompetitionModelCopyWith<$Res>? get competition {
    if (_value.competition == null) {
      return null;
    }

    return $CompetitionModelCopyWith<$Res>(_value.competition!, (value) {
      return _then(_value.copyWith(competition: value) as $Val);
    });
  }

  /// Create a copy of FixtureModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $TeamFixtureModelCopyWith<$Res> get homeTeam {
    return $TeamFixtureModelCopyWith<$Res>(_value.homeTeam, (value) {
      return _then(_value.copyWith(homeTeam: value) as $Val);
    });
  }

  /// Create a copy of FixtureModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $TeamFixtureModelCopyWith<$Res> get awayTeam {
    return $TeamFixtureModelCopyWith<$Res>(_value.awayTeam, (value) {
      return _then(_value.copyWith(awayTeam: value) as $Val);
    });
  }

  /// Create a copy of FixtureModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ScoreModelCopyWith<$Res>? get score {
    if (_value.score == null) {
      return null;
    }

    return $ScoreModelCopyWith<$Res>(_value.score!, (value) {
      return _then(_value.copyWith(score: value) as $Val);
    });
  }

  /// Create a copy of FixtureModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $OddsModelCopyWith<$Res>? get odds {
    if (_value.odds == null) {
      return null;
    }

    return $OddsModelCopyWith<$Res>(_value.odds!, (value) {
      return _then(_value.copyWith(odds: value) as $Val);
    });
  }

  /// Create a copy of FixtureModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $RefereeModelCopyWith<$Res>? get referee {
    if (_value.referee == null) {
      return null;
    }

    return $RefereeModelCopyWith<$Res>(_value.referee!, (value) {
      return _then(_value.copyWith(referee: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$FixtureModelImplCopyWith<$Res>
    implements $FixtureModelCopyWith<$Res> {
  factory _$$FixtureModelImplCopyWith(
          _$FixtureModelImpl value, $Res Function(_$FixtureModelImpl) then) =
      __$$FixtureModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id,
      DateTime utcDate,
      String status,
      int matchday,
      String stage,
      String? group,
      DateTime? lastUpdated,
      CompetitionModel? competition,
      SeasonModel? season,
      TeamFixtureModel homeTeam,
      TeamFixtureModel awayTeam,
      ScoreModel? score,
      List<GoalModel>? goals,
      List<BookingModel>? bookings,
      List<SubstitutionModel>? substitutions,
      OddsModel? odds,
      RefereeModel? referee});

  @override
  $CompetitionModelCopyWith<$Res>? get competition;
  @override
  $TeamFixtureModelCopyWith<$Res> get homeTeam;
  @override
  $TeamFixtureModelCopyWith<$Res> get awayTeam;
  @override
  $ScoreModelCopyWith<$Res>? get score;
  @override
  $OddsModelCopyWith<$Res>? get odds;
  @override
  $RefereeModelCopyWith<$Res>? get referee;
}

/// @nodoc
class __$$FixtureModelImplCopyWithImpl<$Res>
    extends _$FixtureModelCopyWithImpl<$Res, _$FixtureModelImpl>
    implements _$$FixtureModelImplCopyWith<$Res> {
  __$$FixtureModelImplCopyWithImpl(
      _$FixtureModelImpl _value, $Res Function(_$FixtureModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of FixtureModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? utcDate = null,
    Object? status = null,
    Object? matchday = null,
    Object? stage = null,
    Object? group = freezed,
    Object? lastUpdated = freezed,
    Object? competition = freezed,
    Object? season = freezed,
    Object? homeTeam = null,
    Object? awayTeam = null,
    Object? score = freezed,
    Object? goals = freezed,
    Object? bookings = freezed,
    Object? substitutions = freezed,
    Object? odds = freezed,
    Object? referee = freezed,
  }) {
    return _then(_$FixtureModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      utcDate: null == utcDate
          ? _value.utcDate
          : utcDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      matchday: null == matchday
          ? _value.matchday
          : matchday // ignore: cast_nullable_to_non_nullable
              as int,
      stage: null == stage
          ? _value.stage
          : stage // ignore: cast_nullable_to_non_nullable
              as String,
      group: freezed == group
          ? _value.group
          : group // ignore: cast_nullable_to_non_nullable
              as String?,
      lastUpdated: freezed == lastUpdated
          ? _value.lastUpdated
          : lastUpdated // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      competition: freezed == competition
          ? _value.competition
          : competition // ignore: cast_nullable_to_non_nullable
              as CompetitionModel?,
      season: freezed == season
          ? _value.season
          : season // ignore: cast_nullable_to_non_nullable
              as SeasonModel?,
      homeTeam: null == homeTeam
          ? _value.homeTeam
          : homeTeam // ignore: cast_nullable_to_non_nullable
              as TeamFixtureModel,
      awayTeam: null == awayTeam
          ? _value.awayTeam
          : awayTeam // ignore: cast_nullable_to_non_nullable
              as TeamFixtureModel,
      score: freezed == score
          ? _value.score
          : score // ignore: cast_nullable_to_non_nullable
              as ScoreModel?,
      goals: freezed == goals
          ? _value._goals
          : goals // ignore: cast_nullable_to_non_nullable
              as List<GoalModel>?,
      bookings: freezed == bookings
          ? _value._bookings
          : bookings // ignore: cast_nullable_to_non_nullable
              as List<BookingModel>?,
      substitutions: freezed == substitutions
          ? _value._substitutions
          : substitutions // ignore: cast_nullable_to_non_nullable
              as List<SubstitutionModel>?,
      odds: freezed == odds
          ? _value.odds
          : odds // ignore: cast_nullable_to_non_nullable
              as OddsModel?,
      referee: freezed == referee
          ? _value.referee
          : referee // ignore: cast_nullable_to_non_nullable
              as RefereeModel?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$FixtureModelImpl implements _FixtureModel {
  const _$FixtureModelImpl(
      {required this.id,
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
      final List<GoalModel>? goals,
      final List<BookingModel>? bookings,
      final List<SubstitutionModel>? substitutions,
      this.odds,
      this.referee})
      : _goals = goals,
        _bookings = bookings,
        _substitutions = substitutions;

  factory _$FixtureModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$FixtureModelImplFromJson(json);

  @override
  final int id;
  @override
  final DateTime utcDate;
  @override
  final String status;
  @override
  final int matchday;
  @override
  final String stage;
  @override
  final String? group;
  @override
  final DateTime? lastUpdated;
  @override
  final CompetitionModel? competition;
  @override
  final SeasonModel? season;
  @override
  final TeamFixtureModel homeTeam;
  @override
  final TeamFixtureModel awayTeam;
  @override
  final ScoreModel? score;
  final List<GoalModel>? _goals;
  @override
  List<GoalModel>? get goals {
    final value = _goals;
    if (value == null) return null;
    if (_goals is EqualUnmodifiableListView) return _goals;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  final List<BookingModel>? _bookings;
  @override
  List<BookingModel>? get bookings {
    final value = _bookings;
    if (value == null) return null;
    if (_bookings is EqualUnmodifiableListView) return _bookings;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  final List<SubstitutionModel>? _substitutions;
  @override
  List<SubstitutionModel>? get substitutions {
    final value = _substitutions;
    if (value == null) return null;
    if (_substitutions is EqualUnmodifiableListView) return _substitutions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  final OddsModel? odds;
  @override
  final RefereeModel? referee;

  @override
  String toString() {
    return 'FixtureModel(id: $id, utcDate: $utcDate, status: $status, matchday: $matchday, stage: $stage, group: $group, lastUpdated: $lastUpdated, competition: $competition, season: $season, homeTeam: $homeTeam, awayTeam: $awayTeam, score: $score, goals: $goals, bookings: $bookings, substitutions: $substitutions, odds: $odds, referee: $referee)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FixtureModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.utcDate, utcDate) || other.utcDate == utcDate) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.matchday, matchday) ||
                other.matchday == matchday) &&
            (identical(other.stage, stage) || other.stage == stage) &&
            (identical(other.group, group) || other.group == group) &&
            (identical(other.lastUpdated, lastUpdated) ||
                other.lastUpdated == lastUpdated) &&
            (identical(other.competition, competition) ||
                other.competition == competition) &&
            const DeepCollectionEquality().equals(other.season, season) &&
            (identical(other.homeTeam, homeTeam) ||
                other.homeTeam == homeTeam) &&
            (identical(other.awayTeam, awayTeam) ||
                other.awayTeam == awayTeam) &&
            (identical(other.score, score) || other.score == score) &&
            const DeepCollectionEquality().equals(other._goals, _goals) &&
            const DeepCollectionEquality().equals(other._bookings, _bookings) &&
            const DeepCollectionEquality()
                .equals(other._substitutions, _substitutions) &&
            (identical(other.odds, odds) || other.odds == odds) &&
            (identical(other.referee, referee) || other.referee == referee));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      utcDate,
      status,
      matchday,
      stage,
      group,
      lastUpdated,
      competition,
      const DeepCollectionEquality().hash(season),
      homeTeam,
      awayTeam,
      score,
      const DeepCollectionEquality().hash(_goals),
      const DeepCollectionEquality().hash(_bookings),
      const DeepCollectionEquality().hash(_substitutions),
      odds,
      referee);

  /// Create a copy of FixtureModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FixtureModelImplCopyWith<_$FixtureModelImpl> get copyWith =>
      __$$FixtureModelImplCopyWithImpl<_$FixtureModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$FixtureModelImplToJson(
      this,
    );
  }
}

abstract class _FixtureModel implements FixtureModel {
  const factory _FixtureModel(
      {required final int id,
      required final DateTime utcDate,
      required final String status,
      required final int matchday,
      required final String stage,
      final String? group,
      final DateTime? lastUpdated,
      final CompetitionModel? competition,
      final SeasonModel? season,
      required final TeamFixtureModel homeTeam,
      required final TeamFixtureModel awayTeam,
      final ScoreModel? score,
      final List<GoalModel>? goals,
      final List<BookingModel>? bookings,
      final List<SubstitutionModel>? substitutions,
      final OddsModel? odds,
      final RefereeModel? referee}) = _$FixtureModelImpl;

  factory _FixtureModel.fromJson(Map<String, dynamic> json) =
      _$FixtureModelImpl.fromJson;

  @override
  int get id;
  @override
  DateTime get utcDate;
  @override
  String get status;
  @override
  int get matchday;
  @override
  String get stage;
  @override
  String? get group;
  @override
  DateTime? get lastUpdated;
  @override
  CompetitionModel? get competition;
  @override
  SeasonModel? get season;
  @override
  TeamFixtureModel get homeTeam;
  @override
  TeamFixtureModel get awayTeam;
  @override
  ScoreModel? get score;
  @override
  List<GoalModel>? get goals;
  @override
  List<BookingModel>? get bookings;
  @override
  List<SubstitutionModel>? get substitutions;
  @override
  OddsModel? get odds;
  @override
  RefereeModel? get referee;

  /// Create a copy of FixtureModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FixtureModelImplCopyWith<_$FixtureModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

CompetitionModel _$CompetitionModelFromJson(Map<String, dynamic> json) {
  return _CompetitionModel.fromJson(json);
}

/// @nodoc
mixin _$CompetitionModel {
  int get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get code => throw _privateConstructorUsedError;
  String get type => throw _privateConstructorUsedError;
  String get emblem => throw _privateConstructorUsedError;

  /// Serializes this CompetitionModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CompetitionModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CompetitionModelCopyWith<CompetitionModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CompetitionModelCopyWith<$Res> {
  factory $CompetitionModelCopyWith(
          CompetitionModel value, $Res Function(CompetitionModel) then) =
      _$CompetitionModelCopyWithImpl<$Res, CompetitionModel>;
  @useResult
  $Res call({int id, String name, String code, String type, String emblem});
}

/// @nodoc
class _$CompetitionModelCopyWithImpl<$Res, $Val extends CompetitionModel>
    implements $CompetitionModelCopyWith<$Res> {
  _$CompetitionModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CompetitionModel
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
abstract class _$$CompetitionModelImplCopyWith<$Res>
    implements $CompetitionModelCopyWith<$Res> {
  factory _$$CompetitionModelImplCopyWith(_$CompetitionModelImpl value,
          $Res Function(_$CompetitionModelImpl) then) =
      __$$CompetitionModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int id, String name, String code, String type, String emblem});
}

/// @nodoc
class __$$CompetitionModelImplCopyWithImpl<$Res>
    extends _$CompetitionModelCopyWithImpl<$Res, _$CompetitionModelImpl>
    implements _$$CompetitionModelImplCopyWith<$Res> {
  __$$CompetitionModelImplCopyWithImpl(_$CompetitionModelImpl _value,
      $Res Function(_$CompetitionModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of CompetitionModel
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
    return _then(_$CompetitionModelImpl(
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
class _$CompetitionModelImpl implements _CompetitionModel {
  const _$CompetitionModelImpl(
      {required this.id,
      required this.name,
      required this.code,
      required this.type,
      required this.emblem});

  factory _$CompetitionModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$CompetitionModelImplFromJson(json);

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
    return 'CompetitionModel(id: $id, name: $name, code: $code, type: $type, emblem: $emblem)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CompetitionModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.code, code) || other.code == code) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.emblem, emblem) || other.emblem == emblem));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, name, code, type, emblem);

  /// Create a copy of CompetitionModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CompetitionModelImplCopyWith<_$CompetitionModelImpl> get copyWith =>
      __$$CompetitionModelImplCopyWithImpl<_$CompetitionModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CompetitionModelImplToJson(
      this,
    );
  }
}

abstract class _CompetitionModel implements CompetitionModel {
  const factory _CompetitionModel(
      {required final int id,
      required final String name,
      required final String code,
      required final String type,
      required final String emblem}) = _$CompetitionModelImpl;

  factory _CompetitionModel.fromJson(Map<String, dynamic> json) =
      _$CompetitionModelImpl.fromJson;

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

  /// Create a copy of CompetitionModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CompetitionModelImplCopyWith<_$CompetitionModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

TeamFixtureModel _$TeamFixtureModelFromJson(Map<String, dynamic> json) {
  return _TeamFixtureModel.fromJson(json);
}

/// @nodoc
mixin _$TeamFixtureModel {
  int get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get shortName => throw _privateConstructorUsedError;
  String get tla => throw _privateConstructorUsedError;
  String get crest => throw _privateConstructorUsedError;
  CoachModel? get coach => throw _privateConstructorUsedError;

  /// Serializes this TeamFixtureModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TeamFixtureModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TeamFixtureModelCopyWith<TeamFixtureModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TeamFixtureModelCopyWith<$Res> {
  factory $TeamFixtureModelCopyWith(
          TeamFixtureModel value, $Res Function(TeamFixtureModel) then) =
      _$TeamFixtureModelCopyWithImpl<$Res, TeamFixtureModel>;
  @useResult
  $Res call(
      {int id,
      String name,
      String shortName,
      String tla,
      String crest,
      CoachModel? coach});
}

/// @nodoc
class _$TeamFixtureModelCopyWithImpl<$Res, $Val extends TeamFixtureModel>
    implements $TeamFixtureModelCopyWith<$Res> {
  _$TeamFixtureModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TeamFixtureModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? shortName = null,
    Object? tla = null,
    Object? crest = null,
    Object? coach = freezed,
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
      coach: freezed == coach
          ? _value.coach
          : coach // ignore: cast_nullable_to_non_nullable
              as CoachModel?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TeamFixtureModelImplCopyWith<$Res>
    implements $TeamFixtureModelCopyWith<$Res> {
  factory _$$TeamFixtureModelImplCopyWith(_$TeamFixtureModelImpl value,
          $Res Function(_$TeamFixtureModelImpl) then) =
      __$$TeamFixtureModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id,
      String name,
      String shortName,
      String tla,
      String crest,
      CoachModel? coach});
}

/// @nodoc
class __$$TeamFixtureModelImplCopyWithImpl<$Res>
    extends _$TeamFixtureModelCopyWithImpl<$Res, _$TeamFixtureModelImpl>
    implements _$$TeamFixtureModelImplCopyWith<$Res> {
  __$$TeamFixtureModelImplCopyWithImpl(_$TeamFixtureModelImpl _value,
      $Res Function(_$TeamFixtureModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of TeamFixtureModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? shortName = null,
    Object? tla = null,
    Object? crest = null,
    Object? coach = freezed,
  }) {
    return _then(_$TeamFixtureModelImpl(
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
      coach: freezed == coach
          ? _value.coach
          : coach // ignore: cast_nullable_to_non_nullable
              as CoachModel?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TeamFixtureModelImpl implements _TeamFixtureModel {
  const _$TeamFixtureModelImpl(
      {required this.id,
      required this.name,
      required this.shortName,
      required this.tla,
      required this.crest,
      this.coach});

  factory _$TeamFixtureModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$TeamFixtureModelImplFromJson(json);

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
  final CoachModel? coach;

  @override
  String toString() {
    return 'TeamFixtureModel(id: $id, name: $name, shortName: $shortName, tla: $tla, crest: $crest, coach: $coach)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TeamFixtureModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.shortName, shortName) ||
                other.shortName == shortName) &&
            (identical(other.tla, tla) || other.tla == tla) &&
            (identical(other.crest, crest) || other.crest == crest) &&
            const DeepCollectionEquality().equals(other.coach, coach));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, name, shortName, tla, crest,
      const DeepCollectionEquality().hash(coach));

  /// Create a copy of TeamFixtureModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TeamFixtureModelImplCopyWith<_$TeamFixtureModelImpl> get copyWith =>
      __$$TeamFixtureModelImplCopyWithImpl<_$TeamFixtureModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TeamFixtureModelImplToJson(
      this,
    );
  }
}

abstract class _TeamFixtureModel implements TeamFixtureModel {
  const factory _TeamFixtureModel(
      {required final int id,
      required final String name,
      required final String shortName,
      required final String tla,
      required final String crest,
      final CoachModel? coach}) = _$TeamFixtureModelImpl;

  factory _TeamFixtureModel.fromJson(Map<String, dynamic> json) =
      _$TeamFixtureModelImpl.fromJson;

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
  CoachModel? get coach;

  /// Create a copy of TeamFixtureModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TeamFixtureModelImplCopyWith<_$TeamFixtureModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ScoreModel _$ScoreModelFromJson(Map<String, dynamic> json) {
  return _ScoreModel.fromJson(json);
}

/// @nodoc
mixin _$ScoreModel {
  String? get winner => throw _privateConstructorUsedError;
  String? get duration => throw _privateConstructorUsedError;
  ScoreDetailModel? get fullTime => throw _privateConstructorUsedError;
  ScoreDetailModel? get halfTime => throw _privateConstructorUsedError;
  ScoreDetailModel? get extraTime => throw _privateConstructorUsedError;
  ScoreDetailModel? get penalties => throw _privateConstructorUsedError;

  /// Serializes this ScoreModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ScoreModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ScoreModelCopyWith<ScoreModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ScoreModelCopyWith<$Res> {
  factory $ScoreModelCopyWith(
          ScoreModel value, $Res Function(ScoreModel) then) =
      _$ScoreModelCopyWithImpl<$Res, ScoreModel>;
  @useResult
  $Res call(
      {String? winner,
      String? duration,
      ScoreDetailModel? fullTime,
      ScoreDetailModel? halfTime,
      ScoreDetailModel? extraTime,
      ScoreDetailModel? penalties});

  $ScoreDetailModelCopyWith<$Res>? get fullTime;
  $ScoreDetailModelCopyWith<$Res>? get halfTime;
  $ScoreDetailModelCopyWith<$Res>? get extraTime;
  $ScoreDetailModelCopyWith<$Res>? get penalties;
}

/// @nodoc
class _$ScoreModelCopyWithImpl<$Res, $Val extends ScoreModel>
    implements $ScoreModelCopyWith<$Res> {
  _$ScoreModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ScoreModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? winner = freezed,
    Object? duration = freezed,
    Object? fullTime = freezed,
    Object? halfTime = freezed,
    Object? extraTime = freezed,
    Object? penalties = freezed,
  }) {
    return _then(_value.copyWith(
      winner: freezed == winner
          ? _value.winner
          : winner // ignore: cast_nullable_to_non_nullable
              as String?,
      duration: freezed == duration
          ? _value.duration
          : duration // ignore: cast_nullable_to_non_nullable
              as String?,
      fullTime: freezed == fullTime
          ? _value.fullTime
          : fullTime // ignore: cast_nullable_to_non_nullable
              as ScoreDetailModel?,
      halfTime: freezed == halfTime
          ? _value.halfTime
          : halfTime // ignore: cast_nullable_to_non_nullable
              as ScoreDetailModel?,
      extraTime: freezed == extraTime
          ? _value.extraTime
          : extraTime // ignore: cast_nullable_to_non_nullable
              as ScoreDetailModel?,
      penalties: freezed == penalties
          ? _value.penalties
          : penalties // ignore: cast_nullable_to_non_nullable
              as ScoreDetailModel?,
    ) as $Val);
  }

  /// Create a copy of ScoreModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ScoreDetailModelCopyWith<$Res>? get fullTime {
    if (_value.fullTime == null) {
      return null;
    }

    return $ScoreDetailModelCopyWith<$Res>(_value.fullTime!, (value) {
      return _then(_value.copyWith(fullTime: value) as $Val);
    });
  }

  /// Create a copy of ScoreModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ScoreDetailModelCopyWith<$Res>? get halfTime {
    if (_value.halfTime == null) {
      return null;
    }

    return $ScoreDetailModelCopyWith<$Res>(_value.halfTime!, (value) {
      return _then(_value.copyWith(halfTime: value) as $Val);
    });
  }

  /// Create a copy of ScoreModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ScoreDetailModelCopyWith<$Res>? get extraTime {
    if (_value.extraTime == null) {
      return null;
    }

    return $ScoreDetailModelCopyWith<$Res>(_value.extraTime!, (value) {
      return _then(_value.copyWith(extraTime: value) as $Val);
    });
  }

  /// Create a copy of ScoreModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ScoreDetailModelCopyWith<$Res>? get penalties {
    if (_value.penalties == null) {
      return null;
    }

    return $ScoreDetailModelCopyWith<$Res>(_value.penalties!, (value) {
      return _then(_value.copyWith(penalties: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$ScoreModelImplCopyWith<$Res>
    implements $ScoreModelCopyWith<$Res> {
  factory _$$ScoreModelImplCopyWith(
          _$ScoreModelImpl value, $Res Function(_$ScoreModelImpl) then) =
      __$$ScoreModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String? winner,
      String? duration,
      ScoreDetailModel? fullTime,
      ScoreDetailModel? halfTime,
      ScoreDetailModel? extraTime,
      ScoreDetailModel? penalties});

  @override
  $ScoreDetailModelCopyWith<$Res>? get fullTime;
  @override
  $ScoreDetailModelCopyWith<$Res>? get halfTime;
  @override
  $ScoreDetailModelCopyWith<$Res>? get extraTime;
  @override
  $ScoreDetailModelCopyWith<$Res>? get penalties;
}

/// @nodoc
class __$$ScoreModelImplCopyWithImpl<$Res>
    extends _$ScoreModelCopyWithImpl<$Res, _$ScoreModelImpl>
    implements _$$ScoreModelImplCopyWith<$Res> {
  __$$ScoreModelImplCopyWithImpl(
      _$ScoreModelImpl _value, $Res Function(_$ScoreModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of ScoreModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? winner = freezed,
    Object? duration = freezed,
    Object? fullTime = freezed,
    Object? halfTime = freezed,
    Object? extraTime = freezed,
    Object? penalties = freezed,
  }) {
    return _then(_$ScoreModelImpl(
      winner: freezed == winner
          ? _value.winner
          : winner // ignore: cast_nullable_to_non_nullable
              as String?,
      duration: freezed == duration
          ? _value.duration
          : duration // ignore: cast_nullable_to_non_nullable
              as String?,
      fullTime: freezed == fullTime
          ? _value.fullTime
          : fullTime // ignore: cast_nullable_to_non_nullable
              as ScoreDetailModel?,
      halfTime: freezed == halfTime
          ? _value.halfTime
          : halfTime // ignore: cast_nullable_to_non_nullable
              as ScoreDetailModel?,
      extraTime: freezed == extraTime
          ? _value.extraTime
          : extraTime // ignore: cast_nullable_to_non_nullable
              as ScoreDetailModel?,
      penalties: freezed == penalties
          ? _value.penalties
          : penalties // ignore: cast_nullable_to_non_nullable
              as ScoreDetailModel?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ScoreModelImpl implements _ScoreModel {
  const _$ScoreModelImpl(
      {this.winner,
      this.duration,
      this.fullTime,
      this.halfTime,
      this.extraTime,
      this.penalties});

  factory _$ScoreModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$ScoreModelImplFromJson(json);

  @override
  final String? winner;
  @override
  final String? duration;
  @override
  final ScoreDetailModel? fullTime;
  @override
  final ScoreDetailModel? halfTime;
  @override
  final ScoreDetailModel? extraTime;
  @override
  final ScoreDetailModel? penalties;

  @override
  String toString() {
    return 'ScoreModel(winner: $winner, duration: $duration, fullTime: $fullTime, halfTime: $halfTime, extraTime: $extraTime, penalties: $penalties)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ScoreModelImpl &&
            (identical(other.winner, winner) || other.winner == winner) &&
            (identical(other.duration, duration) ||
                other.duration == duration) &&
            (identical(other.fullTime, fullTime) ||
                other.fullTime == fullTime) &&
            (identical(other.halfTime, halfTime) ||
                other.halfTime == halfTime) &&
            (identical(other.extraTime, extraTime) ||
                other.extraTime == extraTime) &&
            (identical(other.penalties, penalties) ||
                other.penalties == penalties));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, winner, duration, fullTime, halfTime, extraTime, penalties);

  /// Create a copy of ScoreModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ScoreModelImplCopyWith<_$ScoreModelImpl> get copyWith =>
      __$$ScoreModelImplCopyWithImpl<_$ScoreModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ScoreModelImplToJson(
      this,
    );
  }
}

abstract class _ScoreModel implements ScoreModel {
  const factory _ScoreModel(
      {final String? winner,
      final String? duration,
      final ScoreDetailModel? fullTime,
      final ScoreDetailModel? halfTime,
      final ScoreDetailModel? extraTime,
      final ScoreDetailModel? penalties}) = _$ScoreModelImpl;

  factory _ScoreModel.fromJson(Map<String, dynamic> json) =
      _$ScoreModelImpl.fromJson;

  @override
  String? get winner;
  @override
  String? get duration;
  @override
  ScoreDetailModel? get fullTime;
  @override
  ScoreDetailModel? get halfTime;
  @override
  ScoreDetailModel? get extraTime;
  @override
  ScoreDetailModel? get penalties;

  /// Create a copy of ScoreModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ScoreModelImplCopyWith<_$ScoreModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ScoreDetailModel _$ScoreDetailModelFromJson(Map<String, dynamic> json) {
  return _ScoreDetailModel.fromJson(json);
}

/// @nodoc
mixin _$ScoreDetailModel {
  int? get home => throw _privateConstructorUsedError;
  int? get away => throw _privateConstructorUsedError;

  /// Serializes this ScoreDetailModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ScoreDetailModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ScoreDetailModelCopyWith<ScoreDetailModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ScoreDetailModelCopyWith<$Res> {
  factory $ScoreDetailModelCopyWith(
          ScoreDetailModel value, $Res Function(ScoreDetailModel) then) =
      _$ScoreDetailModelCopyWithImpl<$Res, ScoreDetailModel>;
  @useResult
  $Res call({int? home, int? away});
}

/// @nodoc
class _$ScoreDetailModelCopyWithImpl<$Res, $Val extends ScoreDetailModel>
    implements $ScoreDetailModelCopyWith<$Res> {
  _$ScoreDetailModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ScoreDetailModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? home = freezed,
    Object? away = freezed,
  }) {
    return _then(_value.copyWith(
      home: freezed == home
          ? _value.home
          : home // ignore: cast_nullable_to_non_nullable
              as int?,
      away: freezed == away
          ? _value.away
          : away // ignore: cast_nullable_to_non_nullable
              as int?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ScoreDetailModelImplCopyWith<$Res>
    implements $ScoreDetailModelCopyWith<$Res> {
  factory _$$ScoreDetailModelImplCopyWith(_$ScoreDetailModelImpl value,
          $Res Function(_$ScoreDetailModelImpl) then) =
      __$$ScoreDetailModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int? home, int? away});
}

/// @nodoc
class __$$ScoreDetailModelImplCopyWithImpl<$Res>
    extends _$ScoreDetailModelCopyWithImpl<$Res, _$ScoreDetailModelImpl>
    implements _$$ScoreDetailModelImplCopyWith<$Res> {
  __$$ScoreDetailModelImplCopyWithImpl(_$ScoreDetailModelImpl _value,
      $Res Function(_$ScoreDetailModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of ScoreDetailModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? home = freezed,
    Object? away = freezed,
  }) {
    return _then(_$ScoreDetailModelImpl(
      home: freezed == home
          ? _value.home
          : home // ignore: cast_nullable_to_non_nullable
              as int?,
      away: freezed == away
          ? _value.away
          : away // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ScoreDetailModelImpl implements _ScoreDetailModel {
  const _$ScoreDetailModelImpl({this.home, this.away});

  factory _$ScoreDetailModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$ScoreDetailModelImplFromJson(json);

  @override
  final int? home;
  @override
  final int? away;

  @override
  String toString() {
    return 'ScoreDetailModel(home: $home, away: $away)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ScoreDetailModelImpl &&
            (identical(other.home, home) || other.home == home) &&
            (identical(other.away, away) || other.away == away));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, home, away);

  /// Create a copy of ScoreDetailModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ScoreDetailModelImplCopyWith<_$ScoreDetailModelImpl> get copyWith =>
      __$$ScoreDetailModelImplCopyWithImpl<_$ScoreDetailModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ScoreDetailModelImplToJson(
      this,
    );
  }
}

abstract class _ScoreDetailModel implements ScoreDetailModel {
  const factory _ScoreDetailModel({final int? home, final int? away}) =
      _$ScoreDetailModelImpl;

  factory _ScoreDetailModel.fromJson(Map<String, dynamic> json) =
      _$ScoreDetailModelImpl.fromJson;

  @override
  int? get home;
  @override
  int? get away;

  /// Create a copy of ScoreDetailModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ScoreDetailModelImplCopyWith<_$ScoreDetailModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

GoalModel _$GoalModelFromJson(Map<String, dynamic> json) {
  return _GoalModel.fromJson(json);
}

/// @nodoc
mixin _$GoalModel {
  int get minute => throw _privateConstructorUsedError;
  String? get injuryTime => throw _privateConstructorUsedError;
  String get type => throw _privateConstructorUsedError;
  TeamFixtureModel get team => throw _privateConstructorUsedError;
  PlayerModel get scorer => throw _privateConstructorUsedError;
  PlayerModel? get assist => throw _privateConstructorUsedError;

  /// Serializes this GoalModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of GoalModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $GoalModelCopyWith<GoalModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GoalModelCopyWith<$Res> {
  factory $GoalModelCopyWith(GoalModel value, $Res Function(GoalModel) then) =
      _$GoalModelCopyWithImpl<$Res, GoalModel>;
  @useResult
  $Res call(
      {int minute,
      String? injuryTime,
      String type,
      TeamFixtureModel team,
      PlayerModel scorer,
      PlayerModel? assist});

  $TeamFixtureModelCopyWith<$Res> get team;
}

/// @nodoc
class _$GoalModelCopyWithImpl<$Res, $Val extends GoalModel>
    implements $GoalModelCopyWith<$Res> {
  _$GoalModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of GoalModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? minute = null,
    Object? injuryTime = freezed,
    Object? type = null,
    Object? team = null,
    Object? scorer = freezed,
    Object? assist = freezed,
  }) {
    return _then(_value.copyWith(
      minute: null == minute
          ? _value.minute
          : minute // ignore: cast_nullable_to_non_nullable
              as int,
      injuryTime: freezed == injuryTime
          ? _value.injuryTime
          : injuryTime // ignore: cast_nullable_to_non_nullable
              as String?,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      team: null == team
          ? _value.team
          : team // ignore: cast_nullable_to_non_nullable
              as TeamFixtureModel,
      scorer: freezed == scorer
          ? _value.scorer
          : scorer // ignore: cast_nullable_to_non_nullable
              as PlayerModel,
      assist: freezed == assist
          ? _value.assist
          : assist // ignore: cast_nullable_to_non_nullable
              as PlayerModel?,
    ) as $Val);
  }

  /// Create a copy of GoalModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $TeamFixtureModelCopyWith<$Res> get team {
    return $TeamFixtureModelCopyWith<$Res>(_value.team, (value) {
      return _then(_value.copyWith(team: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$GoalModelImplCopyWith<$Res>
    implements $GoalModelCopyWith<$Res> {
  factory _$$GoalModelImplCopyWith(
          _$GoalModelImpl value, $Res Function(_$GoalModelImpl) then) =
      __$$GoalModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int minute,
      String? injuryTime,
      String type,
      TeamFixtureModel team,
      PlayerModel scorer,
      PlayerModel? assist});

  @override
  $TeamFixtureModelCopyWith<$Res> get team;
}

/// @nodoc
class __$$GoalModelImplCopyWithImpl<$Res>
    extends _$GoalModelCopyWithImpl<$Res, _$GoalModelImpl>
    implements _$$GoalModelImplCopyWith<$Res> {
  __$$GoalModelImplCopyWithImpl(
      _$GoalModelImpl _value, $Res Function(_$GoalModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of GoalModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? minute = null,
    Object? injuryTime = freezed,
    Object? type = null,
    Object? team = null,
    Object? scorer = freezed,
    Object? assist = freezed,
  }) {
    return _then(_$GoalModelImpl(
      minute: null == minute
          ? _value.minute
          : minute // ignore: cast_nullable_to_non_nullable
              as int,
      injuryTime: freezed == injuryTime
          ? _value.injuryTime
          : injuryTime // ignore: cast_nullable_to_non_nullable
              as String?,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      team: null == team
          ? _value.team
          : team // ignore: cast_nullable_to_non_nullable
              as TeamFixtureModel,
      scorer: freezed == scorer
          ? _value.scorer
          : scorer // ignore: cast_nullable_to_non_nullable
              as PlayerModel,
      assist: freezed == assist
          ? _value.assist
          : assist // ignore: cast_nullable_to_non_nullable
              as PlayerModel?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$GoalModelImpl implements _GoalModel {
  const _$GoalModelImpl(
      {required this.minute,
      this.injuryTime,
      required this.type,
      required this.team,
      required this.scorer,
      this.assist});

  factory _$GoalModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$GoalModelImplFromJson(json);

  @override
  final int minute;
  @override
  final String? injuryTime;
  @override
  final String type;
  @override
  final TeamFixtureModel team;
  @override
  final PlayerModel scorer;
  @override
  final PlayerModel? assist;

  @override
  String toString() {
    return 'GoalModel(minute: $minute, injuryTime: $injuryTime, type: $type, team: $team, scorer: $scorer, assist: $assist)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GoalModelImpl &&
            (identical(other.minute, minute) || other.minute == minute) &&
            (identical(other.injuryTime, injuryTime) ||
                other.injuryTime == injuryTime) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.team, team) || other.team == team) &&
            const DeepCollectionEquality().equals(other.scorer, scorer) &&
            const DeepCollectionEquality().equals(other.assist, assist));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      minute,
      injuryTime,
      type,
      team,
      const DeepCollectionEquality().hash(scorer),
      const DeepCollectionEquality().hash(assist));

  /// Create a copy of GoalModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GoalModelImplCopyWith<_$GoalModelImpl> get copyWith =>
      __$$GoalModelImplCopyWithImpl<_$GoalModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$GoalModelImplToJson(
      this,
    );
  }
}

abstract class _GoalModel implements GoalModel {
  const factory _GoalModel(
      {required final int minute,
      final String? injuryTime,
      required final String type,
      required final TeamFixtureModel team,
      required final PlayerModel scorer,
      final PlayerModel? assist}) = _$GoalModelImpl;

  factory _GoalModel.fromJson(Map<String, dynamic> json) =
      _$GoalModelImpl.fromJson;

  @override
  int get minute;
  @override
  String? get injuryTime;
  @override
  String get type;
  @override
  TeamFixtureModel get team;
  @override
  PlayerModel get scorer;
  @override
  PlayerModel? get assist;

  /// Create a copy of GoalModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GoalModelImplCopyWith<_$GoalModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

BookingModel _$BookingModelFromJson(Map<String, dynamic> json) {
  return _BookingModel.fromJson(json);
}

/// @nodoc
mixin _$BookingModel {
  int get minute => throw _privateConstructorUsedError;
  String? get injuryTime => throw _privateConstructorUsedError;
  TeamFixtureModel get team => throw _privateConstructorUsedError;
  PlayerModel get player => throw _privateConstructorUsedError;
  String get card => throw _privateConstructorUsedError;

  /// Serializes this BookingModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of BookingModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BookingModelCopyWith<BookingModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BookingModelCopyWith<$Res> {
  factory $BookingModelCopyWith(
          BookingModel value, $Res Function(BookingModel) then) =
      _$BookingModelCopyWithImpl<$Res, BookingModel>;
  @useResult
  $Res call(
      {int minute,
      String? injuryTime,
      TeamFixtureModel team,
      PlayerModel player,
      String card});

  $TeamFixtureModelCopyWith<$Res> get team;
}

/// @nodoc
class _$BookingModelCopyWithImpl<$Res, $Val extends BookingModel>
    implements $BookingModelCopyWith<$Res> {
  _$BookingModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of BookingModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? minute = null,
    Object? injuryTime = freezed,
    Object? team = null,
    Object? player = freezed,
    Object? card = null,
  }) {
    return _then(_value.copyWith(
      minute: null == minute
          ? _value.minute
          : minute // ignore: cast_nullable_to_non_nullable
              as int,
      injuryTime: freezed == injuryTime
          ? _value.injuryTime
          : injuryTime // ignore: cast_nullable_to_non_nullable
              as String?,
      team: null == team
          ? _value.team
          : team // ignore: cast_nullable_to_non_nullable
              as TeamFixtureModel,
      player: freezed == player
          ? _value.player
          : player // ignore: cast_nullable_to_non_nullable
              as PlayerModel,
      card: null == card
          ? _value.card
          : card // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }

  /// Create a copy of BookingModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $TeamFixtureModelCopyWith<$Res> get team {
    return $TeamFixtureModelCopyWith<$Res>(_value.team, (value) {
      return _then(_value.copyWith(team: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$BookingModelImplCopyWith<$Res>
    implements $BookingModelCopyWith<$Res> {
  factory _$$BookingModelImplCopyWith(
          _$BookingModelImpl value, $Res Function(_$BookingModelImpl) then) =
      __$$BookingModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int minute,
      String? injuryTime,
      TeamFixtureModel team,
      PlayerModel player,
      String card});

  @override
  $TeamFixtureModelCopyWith<$Res> get team;
}

/// @nodoc
class __$$BookingModelImplCopyWithImpl<$Res>
    extends _$BookingModelCopyWithImpl<$Res, _$BookingModelImpl>
    implements _$$BookingModelImplCopyWith<$Res> {
  __$$BookingModelImplCopyWithImpl(
      _$BookingModelImpl _value, $Res Function(_$BookingModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of BookingModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? minute = null,
    Object? injuryTime = freezed,
    Object? team = null,
    Object? player = freezed,
    Object? card = null,
  }) {
    return _then(_$BookingModelImpl(
      minute: null == minute
          ? _value.minute
          : minute // ignore: cast_nullable_to_non_nullable
              as int,
      injuryTime: freezed == injuryTime
          ? _value.injuryTime
          : injuryTime // ignore: cast_nullable_to_non_nullable
              as String?,
      team: null == team
          ? _value.team
          : team // ignore: cast_nullable_to_non_nullable
              as TeamFixtureModel,
      player: freezed == player
          ? _value.player
          : player // ignore: cast_nullable_to_non_nullable
              as PlayerModel,
      card: null == card
          ? _value.card
          : card // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$BookingModelImpl implements _BookingModel {
  const _$BookingModelImpl(
      {required this.minute,
      this.injuryTime,
      required this.team,
      required this.player,
      required this.card});

  factory _$BookingModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$BookingModelImplFromJson(json);

  @override
  final int minute;
  @override
  final String? injuryTime;
  @override
  final TeamFixtureModel team;
  @override
  final PlayerModel player;
  @override
  final String card;

  @override
  String toString() {
    return 'BookingModel(minute: $minute, injuryTime: $injuryTime, team: $team, player: $player, card: $card)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BookingModelImpl &&
            (identical(other.minute, minute) || other.minute == minute) &&
            (identical(other.injuryTime, injuryTime) ||
                other.injuryTime == injuryTime) &&
            (identical(other.team, team) || other.team == team) &&
            const DeepCollectionEquality().equals(other.player, player) &&
            (identical(other.card, card) || other.card == card));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, minute, injuryTime, team,
      const DeepCollectionEquality().hash(player), card);

  /// Create a copy of BookingModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BookingModelImplCopyWith<_$BookingModelImpl> get copyWith =>
      __$$BookingModelImplCopyWithImpl<_$BookingModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$BookingModelImplToJson(
      this,
    );
  }
}

abstract class _BookingModel implements BookingModel {
  const factory _BookingModel(
      {required final int minute,
      final String? injuryTime,
      required final TeamFixtureModel team,
      required final PlayerModel player,
      required final String card}) = _$BookingModelImpl;

  factory _BookingModel.fromJson(Map<String, dynamic> json) =
      _$BookingModelImpl.fromJson;

  @override
  int get minute;
  @override
  String? get injuryTime;
  @override
  TeamFixtureModel get team;
  @override
  PlayerModel get player;
  @override
  String get card;

  /// Create a copy of BookingModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BookingModelImplCopyWith<_$BookingModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

SubstitutionModel _$SubstitutionModelFromJson(Map<String, dynamic> json) {
  return _SubstitutionModel.fromJson(json);
}

/// @nodoc
mixin _$SubstitutionModel {
  int get minute => throw _privateConstructorUsedError;
  String? get injuryTime => throw _privateConstructorUsedError;
  TeamFixtureModel get team => throw _privateConstructorUsedError;
  PlayerModel get playerOut => throw _privateConstructorUsedError;
  PlayerModel get playerIn => throw _privateConstructorUsedError;

  /// Serializes this SubstitutionModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SubstitutionModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SubstitutionModelCopyWith<SubstitutionModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SubstitutionModelCopyWith<$Res> {
  factory $SubstitutionModelCopyWith(
          SubstitutionModel value, $Res Function(SubstitutionModel) then) =
      _$SubstitutionModelCopyWithImpl<$Res, SubstitutionModel>;
  @useResult
  $Res call(
      {int minute,
      String? injuryTime,
      TeamFixtureModel team,
      PlayerModel playerOut,
      PlayerModel playerIn});

  $TeamFixtureModelCopyWith<$Res> get team;
}

/// @nodoc
class _$SubstitutionModelCopyWithImpl<$Res, $Val extends SubstitutionModel>
    implements $SubstitutionModelCopyWith<$Res> {
  _$SubstitutionModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SubstitutionModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? minute = null,
    Object? injuryTime = freezed,
    Object? team = null,
    Object? playerOut = freezed,
    Object? playerIn = freezed,
  }) {
    return _then(_value.copyWith(
      minute: null == minute
          ? _value.minute
          : minute // ignore: cast_nullable_to_non_nullable
              as int,
      injuryTime: freezed == injuryTime
          ? _value.injuryTime
          : injuryTime // ignore: cast_nullable_to_non_nullable
              as String?,
      team: null == team
          ? _value.team
          : team // ignore: cast_nullable_to_non_nullable
              as TeamFixtureModel,
      playerOut: freezed == playerOut
          ? _value.playerOut
          : playerOut // ignore: cast_nullable_to_non_nullable
              as PlayerModel,
      playerIn: freezed == playerIn
          ? _value.playerIn
          : playerIn // ignore: cast_nullable_to_non_nullable
              as PlayerModel,
    ) as $Val);
  }

  /// Create a copy of SubstitutionModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $TeamFixtureModelCopyWith<$Res> get team {
    return $TeamFixtureModelCopyWith<$Res>(_value.team, (value) {
      return _then(_value.copyWith(team: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$SubstitutionModelImplCopyWith<$Res>
    implements $SubstitutionModelCopyWith<$Res> {
  factory _$$SubstitutionModelImplCopyWith(_$SubstitutionModelImpl value,
          $Res Function(_$SubstitutionModelImpl) then) =
      __$$SubstitutionModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int minute,
      String? injuryTime,
      TeamFixtureModel team,
      PlayerModel playerOut,
      PlayerModel playerIn});

  @override
  $TeamFixtureModelCopyWith<$Res> get team;
}

/// @nodoc
class __$$SubstitutionModelImplCopyWithImpl<$Res>
    extends _$SubstitutionModelCopyWithImpl<$Res, _$SubstitutionModelImpl>
    implements _$$SubstitutionModelImplCopyWith<$Res> {
  __$$SubstitutionModelImplCopyWithImpl(_$SubstitutionModelImpl _value,
      $Res Function(_$SubstitutionModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of SubstitutionModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? minute = null,
    Object? injuryTime = freezed,
    Object? team = null,
    Object? playerOut = freezed,
    Object? playerIn = freezed,
  }) {
    return _then(_$SubstitutionModelImpl(
      minute: null == minute
          ? _value.minute
          : minute // ignore: cast_nullable_to_non_nullable
              as int,
      injuryTime: freezed == injuryTime
          ? _value.injuryTime
          : injuryTime // ignore: cast_nullable_to_non_nullable
              as String?,
      team: null == team
          ? _value.team
          : team // ignore: cast_nullable_to_non_nullable
              as TeamFixtureModel,
      playerOut: freezed == playerOut
          ? _value.playerOut
          : playerOut // ignore: cast_nullable_to_non_nullable
              as PlayerModel,
      playerIn: freezed == playerIn
          ? _value.playerIn
          : playerIn // ignore: cast_nullable_to_non_nullable
              as PlayerModel,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SubstitutionModelImpl implements _SubstitutionModel {
  const _$SubstitutionModelImpl(
      {required this.minute,
      this.injuryTime,
      required this.team,
      required this.playerOut,
      required this.playerIn});

  factory _$SubstitutionModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$SubstitutionModelImplFromJson(json);

  @override
  final int minute;
  @override
  final String? injuryTime;
  @override
  final TeamFixtureModel team;
  @override
  final PlayerModel playerOut;
  @override
  final PlayerModel playerIn;

  @override
  String toString() {
    return 'SubstitutionModel(minute: $minute, injuryTime: $injuryTime, team: $team, playerOut: $playerOut, playerIn: $playerIn)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SubstitutionModelImpl &&
            (identical(other.minute, minute) || other.minute == minute) &&
            (identical(other.injuryTime, injuryTime) ||
                other.injuryTime == injuryTime) &&
            (identical(other.team, team) || other.team == team) &&
            const DeepCollectionEquality().equals(other.playerOut, playerOut) &&
            const DeepCollectionEquality().equals(other.playerIn, playerIn));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      minute,
      injuryTime,
      team,
      const DeepCollectionEquality().hash(playerOut),
      const DeepCollectionEquality().hash(playerIn));

  /// Create a copy of SubstitutionModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SubstitutionModelImplCopyWith<_$SubstitutionModelImpl> get copyWith =>
      __$$SubstitutionModelImplCopyWithImpl<_$SubstitutionModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SubstitutionModelImplToJson(
      this,
    );
  }
}

abstract class _SubstitutionModel implements SubstitutionModel {
  const factory _SubstitutionModel(
      {required final int minute,
      final String? injuryTime,
      required final TeamFixtureModel team,
      required final PlayerModel playerOut,
      required final PlayerModel playerIn}) = _$SubstitutionModelImpl;

  factory _SubstitutionModel.fromJson(Map<String, dynamic> json) =
      _$SubstitutionModelImpl.fromJson;

  @override
  int get minute;
  @override
  String? get injuryTime;
  @override
  TeamFixtureModel get team;
  @override
  PlayerModel get playerOut;
  @override
  PlayerModel get playerIn;

  /// Create a copy of SubstitutionModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SubstitutionModelImplCopyWith<_$SubstitutionModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

OddsModel _$OddsModelFromJson(Map<String, dynamic> json) {
  return _OddsModel.fromJson(json);
}

/// @nodoc
mixin _$OddsModel {
  String? get msg => throw _privateConstructorUsedError;
  double? get homeWin => throw _privateConstructorUsedError;
  double? get draw => throw _privateConstructorUsedError;
  double? get awayWin => throw _privateConstructorUsedError;

  /// Serializes this OddsModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of OddsModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $OddsModelCopyWith<OddsModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $OddsModelCopyWith<$Res> {
  factory $OddsModelCopyWith(OddsModel value, $Res Function(OddsModel) then) =
      _$OddsModelCopyWithImpl<$Res, OddsModel>;
  @useResult
  $Res call({String? msg, double? homeWin, double? draw, double? awayWin});
}

/// @nodoc
class _$OddsModelCopyWithImpl<$Res, $Val extends OddsModel>
    implements $OddsModelCopyWith<$Res> {
  _$OddsModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of OddsModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? msg = freezed,
    Object? homeWin = freezed,
    Object? draw = freezed,
    Object? awayWin = freezed,
  }) {
    return _then(_value.copyWith(
      msg: freezed == msg
          ? _value.msg
          : msg // ignore: cast_nullable_to_non_nullable
              as String?,
      homeWin: freezed == homeWin
          ? _value.homeWin
          : homeWin // ignore: cast_nullable_to_non_nullable
              as double?,
      draw: freezed == draw
          ? _value.draw
          : draw // ignore: cast_nullable_to_non_nullable
              as double?,
      awayWin: freezed == awayWin
          ? _value.awayWin
          : awayWin // ignore: cast_nullable_to_non_nullable
              as double?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$OddsModelImplCopyWith<$Res>
    implements $OddsModelCopyWith<$Res> {
  factory _$$OddsModelImplCopyWith(
          _$OddsModelImpl value, $Res Function(_$OddsModelImpl) then) =
      __$$OddsModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String? msg, double? homeWin, double? draw, double? awayWin});
}

/// @nodoc
class __$$OddsModelImplCopyWithImpl<$Res>
    extends _$OddsModelCopyWithImpl<$Res, _$OddsModelImpl>
    implements _$$OddsModelImplCopyWith<$Res> {
  __$$OddsModelImplCopyWithImpl(
      _$OddsModelImpl _value, $Res Function(_$OddsModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of OddsModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? msg = freezed,
    Object? homeWin = freezed,
    Object? draw = freezed,
    Object? awayWin = freezed,
  }) {
    return _then(_$OddsModelImpl(
      msg: freezed == msg
          ? _value.msg
          : msg // ignore: cast_nullable_to_non_nullable
              as String?,
      homeWin: freezed == homeWin
          ? _value.homeWin
          : homeWin // ignore: cast_nullable_to_non_nullable
              as double?,
      draw: freezed == draw
          ? _value.draw
          : draw // ignore: cast_nullable_to_non_nullable
              as double?,
      awayWin: freezed == awayWin
          ? _value.awayWin
          : awayWin // ignore: cast_nullable_to_non_nullable
              as double?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$OddsModelImpl implements _OddsModel {
  const _$OddsModelImpl({this.msg, this.homeWin, this.draw, this.awayWin});

  factory _$OddsModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$OddsModelImplFromJson(json);

  @override
  final String? msg;
  @override
  final double? homeWin;
  @override
  final double? draw;
  @override
  final double? awayWin;

  @override
  String toString() {
    return 'OddsModel(msg: $msg, homeWin: $homeWin, draw: $draw, awayWin: $awayWin)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$OddsModelImpl &&
            (identical(other.msg, msg) || other.msg == msg) &&
            (identical(other.homeWin, homeWin) || other.homeWin == homeWin) &&
            (identical(other.draw, draw) || other.draw == draw) &&
            (identical(other.awayWin, awayWin) || other.awayWin == awayWin));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, msg, homeWin, draw, awayWin);

  /// Create a copy of OddsModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$OddsModelImplCopyWith<_$OddsModelImpl> get copyWith =>
      __$$OddsModelImplCopyWithImpl<_$OddsModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$OddsModelImplToJson(
      this,
    );
  }
}

abstract class _OddsModel implements OddsModel {
  const factory _OddsModel(
      {final String? msg,
      final double? homeWin,
      final double? draw,
      final double? awayWin}) = _$OddsModelImpl;

  factory _OddsModel.fromJson(Map<String, dynamic> json) =
      _$OddsModelImpl.fromJson;

  @override
  String? get msg;
  @override
  double? get homeWin;
  @override
  double? get draw;
  @override
  double? get awayWin;

  /// Create a copy of OddsModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$OddsModelImplCopyWith<_$OddsModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

RefereeModel _$RefereeModelFromJson(Map<String, dynamic> json) {
  return _RefereeModel.fromJson(json);
}

/// @nodoc
mixin _$RefereeModel {
  int get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String? get role => throw _privateConstructorUsedError;
  String? get nationality => throw _privateConstructorUsedError;

  /// Serializes this RefereeModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of RefereeModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RefereeModelCopyWith<RefereeModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RefereeModelCopyWith<$Res> {
  factory $RefereeModelCopyWith(
          RefereeModel value, $Res Function(RefereeModel) then) =
      _$RefereeModelCopyWithImpl<$Res, RefereeModel>;
  @useResult
  $Res call({int id, String name, String? role, String? nationality});
}

/// @nodoc
class _$RefereeModelCopyWithImpl<$Res, $Val extends RefereeModel>
    implements $RefereeModelCopyWith<$Res> {
  _$RefereeModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RefereeModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? role = freezed,
    Object? nationality = freezed,
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
      role: freezed == role
          ? _value.role
          : role // ignore: cast_nullable_to_non_nullable
              as String?,
      nationality: freezed == nationality
          ? _value.nationality
          : nationality // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$RefereeModelImplCopyWith<$Res>
    implements $RefereeModelCopyWith<$Res> {
  factory _$$RefereeModelImplCopyWith(
          _$RefereeModelImpl value, $Res Function(_$RefereeModelImpl) then) =
      __$$RefereeModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int id, String name, String? role, String? nationality});
}

/// @nodoc
class __$$RefereeModelImplCopyWithImpl<$Res>
    extends _$RefereeModelCopyWithImpl<$Res, _$RefereeModelImpl>
    implements _$$RefereeModelImplCopyWith<$Res> {
  __$$RefereeModelImplCopyWithImpl(
      _$RefereeModelImpl _value, $Res Function(_$RefereeModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of RefereeModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? role = freezed,
    Object? nationality = freezed,
  }) {
    return _then(_$RefereeModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      role: freezed == role
          ? _value.role
          : role // ignore: cast_nullable_to_non_nullable
              as String?,
      nationality: freezed == nationality
          ? _value.nationality
          : nationality // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$RefereeModelImpl implements _RefereeModel {
  const _$RefereeModelImpl(
      {required this.id, required this.name, this.role, this.nationality});

  factory _$RefereeModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$RefereeModelImplFromJson(json);

  @override
  final int id;
  @override
  final String name;
  @override
  final String? role;
  @override
  final String? nationality;

  @override
  String toString() {
    return 'RefereeModel(id: $id, name: $name, role: $role, nationality: $nationality)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RefereeModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.role, role) || other.role == role) &&
            (identical(other.nationality, nationality) ||
                other.nationality == nationality));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, name, role, nationality);

  /// Create a copy of RefereeModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RefereeModelImplCopyWith<_$RefereeModelImpl> get copyWith =>
      __$$RefereeModelImplCopyWithImpl<_$RefereeModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RefereeModelImplToJson(
      this,
    );
  }
}

abstract class _RefereeModel implements RefereeModel {
  const factory _RefereeModel(
      {required final int id,
      required final String name,
      final String? role,
      final String? nationality}) = _$RefereeModelImpl;

  factory _RefereeModel.fromJson(Map<String, dynamic> json) =
      _$RefereeModelImpl.fromJson;

  @override
  int get id;
  @override
  String get name;
  @override
  String? get role;
  @override
  String? get nationality;

  /// Create a copy of RefereeModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RefereeModelImplCopyWith<_$RefereeModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
