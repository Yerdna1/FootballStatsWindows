// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'league_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

LeagueModel _$LeagueModelFromJson(Map<String, dynamic> json) {
  return _LeagueModel.fromJson(json);
}

/// @nodoc
mixin _$LeagueModel {
  int get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get code => throw _privateConstructorUsedError;
  String get type => throw _privateConstructorUsedError;
  String get emblem => throw _privateConstructorUsedError;
  int get currentSeason => throw _privateConstructorUsedError;
  int get numberOfAvailableSeasons => throw _privateConstructorUsedError;
  DateTime? get lastUpdated => throw _privateConstructorUsedError;
  AreaModel? get area => throw _privateConstructorUsedError;
  CurrentSeasonModel? get currentSeasonDetails =>
      throw _privateConstructorUsedError;
  List<SeasonModel> get availableSeasons => throw _privateConstructorUsedError;

  /// Serializes this LeagueModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of LeagueModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LeagueModelCopyWith<LeagueModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LeagueModelCopyWith<$Res> {
  factory $LeagueModelCopyWith(
          LeagueModel value, $Res Function(LeagueModel) then) =
      _$LeagueModelCopyWithImpl<$Res, LeagueModel>;
  @useResult
  $Res call(
      {int id,
      String name,
      String code,
      String type,
      String emblem,
      int currentSeason,
      int numberOfAvailableSeasons,
      DateTime? lastUpdated,
      AreaModel? area,
      CurrentSeasonModel? currentSeasonDetails,
      List<SeasonModel> availableSeasons});

  $AreaModelCopyWith<$Res>? get area;
  $CurrentSeasonModelCopyWith<$Res>? get currentSeasonDetails;
}

/// @nodoc
class _$LeagueModelCopyWithImpl<$Res, $Val extends LeagueModel>
    implements $LeagueModelCopyWith<$Res> {
  _$LeagueModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LeagueModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? code = null,
    Object? type = null,
    Object? emblem = null,
    Object? currentSeason = null,
    Object? numberOfAvailableSeasons = null,
    Object? lastUpdated = freezed,
    Object? area = freezed,
    Object? currentSeasonDetails = freezed,
    Object? availableSeasons = null,
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
      currentSeason: null == currentSeason
          ? _value.currentSeason
          : currentSeason // ignore: cast_nullable_to_non_nullable
              as int,
      numberOfAvailableSeasons: null == numberOfAvailableSeasons
          ? _value.numberOfAvailableSeasons
          : numberOfAvailableSeasons // ignore: cast_nullable_to_non_nullable
              as int,
      lastUpdated: freezed == lastUpdated
          ? _value.lastUpdated
          : lastUpdated // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      area: freezed == area
          ? _value.area
          : area // ignore: cast_nullable_to_non_nullable
              as AreaModel?,
      currentSeasonDetails: freezed == currentSeasonDetails
          ? _value.currentSeasonDetails
          : currentSeasonDetails // ignore: cast_nullable_to_non_nullable
              as CurrentSeasonModel?,
      availableSeasons: null == availableSeasons
          ? _value.availableSeasons
          : availableSeasons // ignore: cast_nullable_to_non_nullable
              as List<SeasonModel>,
    ) as $Val);
  }

  /// Create a copy of LeagueModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $AreaModelCopyWith<$Res>? get area {
    if (_value.area == null) {
      return null;
    }

    return $AreaModelCopyWith<$Res>(_value.area!, (value) {
      return _then(_value.copyWith(area: value) as $Val);
    });
  }

  /// Create a copy of LeagueModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $CurrentSeasonModelCopyWith<$Res>? get currentSeasonDetails {
    if (_value.currentSeasonDetails == null) {
      return null;
    }

    return $CurrentSeasonModelCopyWith<$Res>(_value.currentSeasonDetails!,
        (value) {
      return _then(_value.copyWith(currentSeasonDetails: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$LeagueModelImplCopyWith<$Res>
    implements $LeagueModelCopyWith<$Res> {
  factory _$$LeagueModelImplCopyWith(
          _$LeagueModelImpl value, $Res Function(_$LeagueModelImpl) then) =
      __$$LeagueModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id,
      String name,
      String code,
      String type,
      String emblem,
      int currentSeason,
      int numberOfAvailableSeasons,
      DateTime? lastUpdated,
      AreaModel? area,
      CurrentSeasonModel? currentSeasonDetails,
      List<SeasonModel> availableSeasons});

  @override
  $AreaModelCopyWith<$Res>? get area;
  @override
  $CurrentSeasonModelCopyWith<$Res>? get currentSeasonDetails;
}

/// @nodoc
class __$$LeagueModelImplCopyWithImpl<$Res>
    extends _$LeagueModelCopyWithImpl<$Res, _$LeagueModelImpl>
    implements _$$LeagueModelImplCopyWith<$Res> {
  __$$LeagueModelImplCopyWithImpl(
      _$LeagueModelImpl _value, $Res Function(_$LeagueModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of LeagueModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? code = null,
    Object? type = null,
    Object? emblem = null,
    Object? currentSeason = null,
    Object? numberOfAvailableSeasons = null,
    Object? lastUpdated = freezed,
    Object? area = freezed,
    Object? currentSeasonDetails = freezed,
    Object? availableSeasons = null,
  }) {
    return _then(_$LeagueModelImpl(
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
      currentSeason: null == currentSeason
          ? _value.currentSeason
          : currentSeason // ignore: cast_nullable_to_non_nullable
              as int,
      numberOfAvailableSeasons: null == numberOfAvailableSeasons
          ? _value.numberOfAvailableSeasons
          : numberOfAvailableSeasons // ignore: cast_nullable_to_non_nullable
              as int,
      lastUpdated: freezed == lastUpdated
          ? _value.lastUpdated
          : lastUpdated // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      area: freezed == area
          ? _value.area
          : area // ignore: cast_nullable_to_non_nullable
              as AreaModel?,
      currentSeasonDetails: freezed == currentSeasonDetails
          ? _value.currentSeasonDetails
          : currentSeasonDetails // ignore: cast_nullable_to_non_nullable
              as CurrentSeasonModel?,
      availableSeasons: null == availableSeasons
          ? _value._availableSeasons
          : availableSeasons // ignore: cast_nullable_to_non_nullable
              as List<SeasonModel>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$LeagueModelImpl implements _LeagueModel {
  const _$LeagueModelImpl(
      {required this.id,
      required this.name,
      required this.code,
      required this.type,
      required this.emblem,
      required this.currentSeason,
      required this.numberOfAvailableSeasons,
      this.lastUpdated,
      this.area,
      this.currentSeasonDetails,
      final List<SeasonModel> availableSeasons = const []})
      : _availableSeasons = availableSeasons;

  factory _$LeagueModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$LeagueModelImplFromJson(json);

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
  final int currentSeason;
  @override
  final int numberOfAvailableSeasons;
  @override
  final DateTime? lastUpdated;
  @override
  final AreaModel? area;
  @override
  final CurrentSeasonModel? currentSeasonDetails;
  final List<SeasonModel> _availableSeasons;
  @override
  @JsonKey()
  List<SeasonModel> get availableSeasons {
    if (_availableSeasons is EqualUnmodifiableListView)
      return _availableSeasons;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_availableSeasons);
  }

  @override
  String toString() {
    return 'LeagueModel(id: $id, name: $name, code: $code, type: $type, emblem: $emblem, currentSeason: $currentSeason, numberOfAvailableSeasons: $numberOfAvailableSeasons, lastUpdated: $lastUpdated, area: $area, currentSeasonDetails: $currentSeasonDetails, availableSeasons: $availableSeasons)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LeagueModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.code, code) || other.code == code) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.emblem, emblem) || other.emblem == emblem) &&
            (identical(other.currentSeason, currentSeason) ||
                other.currentSeason == currentSeason) &&
            (identical(
                    other.numberOfAvailableSeasons, numberOfAvailableSeasons) ||
                other.numberOfAvailableSeasons == numberOfAvailableSeasons) &&
            (identical(other.lastUpdated, lastUpdated) ||
                other.lastUpdated == lastUpdated) &&
            (identical(other.area, area) || other.area == area) &&
            (identical(other.currentSeasonDetails, currentSeasonDetails) ||
                other.currentSeasonDetails == currentSeasonDetails) &&
            const DeepCollectionEquality()
                .equals(other._availableSeasons, _availableSeasons));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      name,
      code,
      type,
      emblem,
      currentSeason,
      numberOfAvailableSeasons,
      lastUpdated,
      area,
      currentSeasonDetails,
      const DeepCollectionEquality().hash(_availableSeasons));

  /// Create a copy of LeagueModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LeagueModelImplCopyWith<_$LeagueModelImpl> get copyWith =>
      __$$LeagueModelImplCopyWithImpl<_$LeagueModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LeagueModelImplToJson(
      this,
    );
  }
}

abstract class _LeagueModel implements LeagueModel {
  const factory _LeagueModel(
      {required final int id,
      required final String name,
      required final String code,
      required final String type,
      required final String emblem,
      required final int currentSeason,
      required final int numberOfAvailableSeasons,
      final DateTime? lastUpdated,
      final AreaModel? area,
      final CurrentSeasonModel? currentSeasonDetails,
      final List<SeasonModel> availableSeasons}) = _$LeagueModelImpl;

  factory _LeagueModel.fromJson(Map<String, dynamic> json) =
      _$LeagueModelImpl.fromJson;

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
  @override
  int get currentSeason;
  @override
  int get numberOfAvailableSeasons;
  @override
  DateTime? get lastUpdated;
  @override
  AreaModel? get area;
  @override
  CurrentSeasonModel? get currentSeasonDetails;
  @override
  List<SeasonModel> get availableSeasons;

  /// Create a copy of LeagueModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LeagueModelImplCopyWith<_$LeagueModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

AreaModel _$AreaModelFromJson(Map<String, dynamic> json) {
  return _AreaModel.fromJson(json);
}

/// @nodoc
mixin _$AreaModel {
  int get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get code => throw _privateConstructorUsedError;
  String get flag => throw _privateConstructorUsedError;

  /// Serializes this AreaModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AreaModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AreaModelCopyWith<AreaModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AreaModelCopyWith<$Res> {
  factory $AreaModelCopyWith(AreaModel value, $Res Function(AreaModel) then) =
      _$AreaModelCopyWithImpl<$Res, AreaModel>;
  @useResult
  $Res call({int id, String name, String code, String flag});
}

/// @nodoc
class _$AreaModelCopyWithImpl<$Res, $Val extends AreaModel>
    implements $AreaModelCopyWith<$Res> {
  _$AreaModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AreaModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? code = null,
    Object? flag = null,
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
      flag: null == flag
          ? _value.flag
          : flag // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AreaModelImplCopyWith<$Res>
    implements $AreaModelCopyWith<$Res> {
  factory _$$AreaModelImplCopyWith(
          _$AreaModelImpl value, $Res Function(_$AreaModelImpl) then) =
      __$$AreaModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int id, String name, String code, String flag});
}

/// @nodoc
class __$$AreaModelImplCopyWithImpl<$Res>
    extends _$AreaModelCopyWithImpl<$Res, _$AreaModelImpl>
    implements _$$AreaModelImplCopyWith<$Res> {
  __$$AreaModelImplCopyWithImpl(
      _$AreaModelImpl _value, $Res Function(_$AreaModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of AreaModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? code = null,
    Object? flag = null,
  }) {
    return _then(_$AreaModelImpl(
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
      flag: null == flag
          ? _value.flag
          : flag // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AreaModelImpl implements _AreaModel {
  const _$AreaModelImpl(
      {required this.id,
      required this.name,
      required this.code,
      required this.flag});

  factory _$AreaModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$AreaModelImplFromJson(json);

  @override
  final int id;
  @override
  final String name;
  @override
  final String code;
  @override
  final String flag;

  @override
  String toString() {
    return 'AreaModel(id: $id, name: $name, code: $code, flag: $flag)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AreaModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.code, code) || other.code == code) &&
            (identical(other.flag, flag) || other.flag == flag));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, name, code, flag);

  /// Create a copy of AreaModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AreaModelImplCopyWith<_$AreaModelImpl> get copyWith =>
      __$$AreaModelImplCopyWithImpl<_$AreaModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AreaModelImplToJson(
      this,
    );
  }
}

abstract class _AreaModel implements AreaModel {
  const factory _AreaModel(
      {required final int id,
      required final String name,
      required final String code,
      required final String flag}) = _$AreaModelImpl;

  factory _AreaModel.fromJson(Map<String, dynamic> json) =
      _$AreaModelImpl.fromJson;

  @override
  int get id;
  @override
  String get name;
  @override
  String get code;
  @override
  String get flag;

  /// Create a copy of AreaModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AreaModelImplCopyWith<_$AreaModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

CurrentSeasonModel _$CurrentSeasonModelFromJson(Map<String, dynamic> json) {
  return _CurrentSeasonModel.fromJson(json);
}

/// @nodoc
mixin _$CurrentSeasonModel {
  int get id => throw _privateConstructorUsedError;
  DateTime get startDate => throw _privateConstructorUsedError;
  DateTime get endDate => throw _privateConstructorUsedError;
  int get currentMatchday => throw _privateConstructorUsedError;
  String? get winner => throw _privateConstructorUsedError;

  /// Serializes this CurrentSeasonModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CurrentSeasonModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CurrentSeasonModelCopyWith<CurrentSeasonModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CurrentSeasonModelCopyWith<$Res> {
  factory $CurrentSeasonModelCopyWith(
          CurrentSeasonModel value, $Res Function(CurrentSeasonModel) then) =
      _$CurrentSeasonModelCopyWithImpl<$Res, CurrentSeasonModel>;
  @useResult
  $Res call(
      {int id,
      DateTime startDate,
      DateTime endDate,
      int currentMatchday,
      String? winner});
}

/// @nodoc
class _$CurrentSeasonModelCopyWithImpl<$Res, $Val extends CurrentSeasonModel>
    implements $CurrentSeasonModelCopyWith<$Res> {
  _$CurrentSeasonModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CurrentSeasonModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? startDate = null,
    Object? endDate = null,
    Object? currentMatchday = null,
    Object? winner = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      startDate: null == startDate
          ? _value.startDate
          : startDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      endDate: null == endDate
          ? _value.endDate
          : endDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      currentMatchday: null == currentMatchday
          ? _value.currentMatchday
          : currentMatchday // ignore: cast_nullable_to_non_nullable
              as int,
      winner: freezed == winner
          ? _value.winner
          : winner // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CurrentSeasonModelImplCopyWith<$Res>
    implements $CurrentSeasonModelCopyWith<$Res> {
  factory _$$CurrentSeasonModelImplCopyWith(_$CurrentSeasonModelImpl value,
          $Res Function(_$CurrentSeasonModelImpl) then) =
      __$$CurrentSeasonModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id,
      DateTime startDate,
      DateTime endDate,
      int currentMatchday,
      String? winner});
}

/// @nodoc
class __$$CurrentSeasonModelImplCopyWithImpl<$Res>
    extends _$CurrentSeasonModelCopyWithImpl<$Res, _$CurrentSeasonModelImpl>
    implements _$$CurrentSeasonModelImplCopyWith<$Res> {
  __$$CurrentSeasonModelImplCopyWithImpl(_$CurrentSeasonModelImpl _value,
      $Res Function(_$CurrentSeasonModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of CurrentSeasonModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? startDate = null,
    Object? endDate = null,
    Object? currentMatchday = null,
    Object? winner = freezed,
  }) {
    return _then(_$CurrentSeasonModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      startDate: null == startDate
          ? _value.startDate
          : startDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      endDate: null == endDate
          ? _value.endDate
          : endDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      currentMatchday: null == currentMatchday
          ? _value.currentMatchday
          : currentMatchday // ignore: cast_nullable_to_non_nullable
              as int,
      winner: freezed == winner
          ? _value.winner
          : winner // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CurrentSeasonModelImpl implements _CurrentSeasonModel {
  const _$CurrentSeasonModelImpl(
      {required this.id,
      required this.startDate,
      required this.endDate,
      required this.currentMatchday,
      this.winner});

  factory _$CurrentSeasonModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$CurrentSeasonModelImplFromJson(json);

  @override
  final int id;
  @override
  final DateTime startDate;
  @override
  final DateTime endDate;
  @override
  final int currentMatchday;
  @override
  final String? winner;

  @override
  String toString() {
    return 'CurrentSeasonModel(id: $id, startDate: $startDate, endDate: $endDate, currentMatchday: $currentMatchday, winner: $winner)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CurrentSeasonModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.startDate, startDate) ||
                other.startDate == startDate) &&
            (identical(other.endDate, endDate) || other.endDate == endDate) &&
            (identical(other.currentMatchday, currentMatchday) ||
                other.currentMatchday == currentMatchday) &&
            (identical(other.winner, winner) || other.winner == winner));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, startDate, endDate, currentMatchday, winner);

  /// Create a copy of CurrentSeasonModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CurrentSeasonModelImplCopyWith<_$CurrentSeasonModelImpl> get copyWith =>
      __$$CurrentSeasonModelImplCopyWithImpl<_$CurrentSeasonModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CurrentSeasonModelImplToJson(
      this,
    );
  }
}

abstract class _CurrentSeasonModel implements CurrentSeasonModel {
  const factory _CurrentSeasonModel(
      {required final int id,
      required final DateTime startDate,
      required final DateTime endDate,
      required final int currentMatchday,
      final String? winner}) = _$CurrentSeasonModelImpl;

  factory _CurrentSeasonModel.fromJson(Map<String, dynamic> json) =
      _$CurrentSeasonModelImpl.fromJson;

  @override
  int get id;
  @override
  DateTime get startDate;
  @override
  DateTime get endDate;
  @override
  int get currentMatchday;
  @override
  String? get winner;

  /// Create a copy of CurrentSeasonModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CurrentSeasonModelImplCopyWith<_$CurrentSeasonModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

SeasonModel _$SeasonModelFromJson(Map<String, dynamic> json) {
  return _SeasonModel.fromJson(json);
}

/// @nodoc
mixin _$SeasonModel {
  int get id => throw _privateConstructorUsedError;
  DateTime get startDate => throw _privateConstructorUsedError;
  DateTime get endDate => throw _privateConstructorUsedError;
  int get currentMatchday => throw _privateConstructorUsedError;
  String? get winner => throw _privateConstructorUsedError;

  /// Serializes this SeasonModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SeasonModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SeasonModelCopyWith<SeasonModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SeasonModelCopyWith<$Res> {
  factory $SeasonModelCopyWith(
          SeasonModel value, $Res Function(SeasonModel) then) =
      _$SeasonModelCopyWithImpl<$Res, SeasonModel>;
  @useResult
  $Res call(
      {int id,
      DateTime startDate,
      DateTime endDate,
      int currentMatchday,
      String? winner});
}

/// @nodoc
class _$SeasonModelCopyWithImpl<$Res, $Val extends SeasonModel>
    implements $SeasonModelCopyWith<$Res> {
  _$SeasonModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SeasonModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? startDate = null,
    Object? endDate = null,
    Object? currentMatchday = null,
    Object? winner = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      startDate: null == startDate
          ? _value.startDate
          : startDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      endDate: null == endDate
          ? _value.endDate
          : endDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      currentMatchday: null == currentMatchday
          ? _value.currentMatchday
          : currentMatchday // ignore: cast_nullable_to_non_nullable
              as int,
      winner: freezed == winner
          ? _value.winner
          : winner // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SeasonModelImplCopyWith<$Res>
    implements $SeasonModelCopyWith<$Res> {
  factory _$$SeasonModelImplCopyWith(
          _$SeasonModelImpl value, $Res Function(_$SeasonModelImpl) then) =
      __$$SeasonModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id,
      DateTime startDate,
      DateTime endDate,
      int currentMatchday,
      String? winner});
}

/// @nodoc
class __$$SeasonModelImplCopyWithImpl<$Res>
    extends _$SeasonModelCopyWithImpl<$Res, _$SeasonModelImpl>
    implements _$$SeasonModelImplCopyWith<$Res> {
  __$$SeasonModelImplCopyWithImpl(
      _$SeasonModelImpl _value, $Res Function(_$SeasonModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of SeasonModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? startDate = null,
    Object? endDate = null,
    Object? currentMatchday = null,
    Object? winner = freezed,
  }) {
    return _then(_$SeasonModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      startDate: null == startDate
          ? _value.startDate
          : startDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      endDate: null == endDate
          ? _value.endDate
          : endDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      currentMatchday: null == currentMatchday
          ? _value.currentMatchday
          : currentMatchday // ignore: cast_nullable_to_non_nullable
              as int,
      winner: freezed == winner
          ? _value.winner
          : winner // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SeasonModelImpl implements _SeasonModel {
  const _$SeasonModelImpl(
      {required this.id,
      required this.startDate,
      required this.endDate,
      required this.currentMatchday,
      this.winner});

  factory _$SeasonModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$SeasonModelImplFromJson(json);

  @override
  final int id;
  @override
  final DateTime startDate;
  @override
  final DateTime endDate;
  @override
  final int currentMatchday;
  @override
  final String? winner;

  @override
  String toString() {
    return 'SeasonModel(id: $id, startDate: $startDate, endDate: $endDate, currentMatchday: $currentMatchday, winner: $winner)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SeasonModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.startDate, startDate) ||
                other.startDate == startDate) &&
            (identical(other.endDate, endDate) || other.endDate == endDate) &&
            (identical(other.currentMatchday, currentMatchday) ||
                other.currentMatchday == currentMatchday) &&
            (identical(other.winner, winner) || other.winner == winner));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, startDate, endDate, currentMatchday, winner);

  /// Create a copy of SeasonModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SeasonModelImplCopyWith<_$SeasonModelImpl> get copyWith =>
      __$$SeasonModelImplCopyWithImpl<_$SeasonModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SeasonModelImplToJson(
      this,
    );
  }
}

abstract class _SeasonModel implements SeasonModel {
  const factory _SeasonModel(
      {required final int id,
      required final DateTime startDate,
      required final DateTime endDate,
      required final int currentMatchday,
      final String? winner}) = _$SeasonModelImpl;

  factory _SeasonModel.fromJson(Map<String, dynamic> json) =
      _$SeasonModelImpl.fromJson;

  @override
  int get id;
  @override
  DateTime get startDate;
  @override
  DateTime get endDate;
  @override
  int get currentMatchday;
  @override
  String? get winner;

  /// Create a copy of SeasonModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SeasonModelImplCopyWith<_$SeasonModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
