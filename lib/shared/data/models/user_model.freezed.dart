// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

UserModel _$UserModelFromJson(Map<String, dynamic> json) {
  return _UserModel.fromJson(json);
}

/// @nodoc
mixin _$UserModel {
  String get id => throw _privateConstructorUsedError;
  String get email => throw _privateConstructorUsedError;
  String get displayName => throw _privateConstructorUsedError;
  String? get firstName => throw _privateConstructorUsedError;
  String? get lastName => throw _privateConstructorUsedError;
  String? get photoUrl => throw _privateConstructorUsedError;
  String? get phoneNumber => throw _privateConstructorUsedError;
  DateTime? get dateOfBirth => throw _privateConstructorUsedError;
  String? get favoriteTeam => throw _privateConstructorUsedError;
  String? get favoriteLeague => throw _privateConstructorUsedError;
  List<String>? get favoriteTeams => throw _privateConstructorUsedError;
  List<String>? get favoriteLeagues => throw _privateConstructorUsedError;
  bool get isEmailVerified => throw _privateConstructorUsedError;
  bool get isPremiumUser => throw _privateConstructorUsedError;
  String get preferredLanguage => throw _privateConstructorUsedError;
  String get themePreference => throw _privateConstructorUsedError;
  List<String> get notificationPreferences =>
      throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;
  DateTime? get lastLoginAt => throw _privateConstructorUsedError;

  /// Serializes this UserModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of UserModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UserModelCopyWith<UserModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserModelCopyWith<$Res> {
  factory $UserModelCopyWith(UserModel value, $Res Function(UserModel) then) =
      _$UserModelCopyWithImpl<$Res, UserModel>;
  @useResult
  $Res call(
      {String id,
      String email,
      String displayName,
      String? firstName,
      String? lastName,
      String? photoUrl,
      String? phoneNumber,
      DateTime? dateOfBirth,
      String? favoriteTeam,
      String? favoriteLeague,
      List<String>? favoriteTeams,
      List<String>? favoriteLeagues,
      bool isEmailVerified,
      bool isPremiumUser,
      String preferredLanguage,
      String themePreference,
      List<String> notificationPreferences,
      DateTime? createdAt,
      DateTime? updatedAt,
      DateTime? lastLoginAt});
}

/// @nodoc
class _$UserModelCopyWithImpl<$Res, $Val extends UserModel>
    implements $UserModelCopyWith<$Res> {
  _$UserModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UserModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? email = null,
    Object? displayName = null,
    Object? firstName = freezed,
    Object? lastName = freezed,
    Object? photoUrl = freezed,
    Object? phoneNumber = freezed,
    Object? dateOfBirth = freezed,
    Object? favoriteTeam = freezed,
    Object? favoriteLeague = freezed,
    Object? favoriteTeams = freezed,
    Object? favoriteLeagues = freezed,
    Object? isEmailVerified = null,
    Object? isPremiumUser = null,
    Object? preferredLanguage = null,
    Object? themePreference = null,
    Object? notificationPreferences = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? lastLoginAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      email: null == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
      displayName: null == displayName
          ? _value.displayName
          : displayName // ignore: cast_nullable_to_non_nullable
              as String,
      firstName: freezed == firstName
          ? _value.firstName
          : firstName // ignore: cast_nullable_to_non_nullable
              as String?,
      lastName: freezed == lastName
          ? _value.lastName
          : lastName // ignore: cast_nullable_to_non_nullable
              as String?,
      photoUrl: freezed == photoUrl
          ? _value.photoUrl
          : photoUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      phoneNumber: freezed == phoneNumber
          ? _value.phoneNumber
          : phoneNumber // ignore: cast_nullable_to_non_nullable
              as String?,
      dateOfBirth: freezed == dateOfBirth
          ? _value.dateOfBirth
          : dateOfBirth // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      favoriteTeam: freezed == favoriteTeam
          ? _value.favoriteTeam
          : favoriteTeam // ignore: cast_nullable_to_non_nullable
              as String?,
      favoriteLeague: freezed == favoriteLeague
          ? _value.favoriteLeague
          : favoriteLeague // ignore: cast_nullable_to_non_nullable
              as String?,
      favoriteTeams: freezed == favoriteTeams
          ? _value.favoriteTeams
          : favoriteTeams // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      favoriteLeagues: freezed == favoriteLeagues
          ? _value.favoriteLeagues
          : favoriteLeagues // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      isEmailVerified: null == isEmailVerified
          ? _value.isEmailVerified
          : isEmailVerified // ignore: cast_nullable_to_non_nullable
              as bool,
      isPremiumUser: null == isPremiumUser
          ? _value.isPremiumUser
          : isPremiumUser // ignore: cast_nullable_to_non_nullable
              as bool,
      preferredLanguage: null == preferredLanguage
          ? _value.preferredLanguage
          : preferredLanguage // ignore: cast_nullable_to_non_nullable
              as String,
      themePreference: null == themePreference
          ? _value.themePreference
          : themePreference // ignore: cast_nullable_to_non_nullable
              as String,
      notificationPreferences: null == notificationPreferences
          ? _value.notificationPreferences
          : notificationPreferences // ignore: cast_nullable_to_non_nullable
              as List<String>,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      lastLoginAt: freezed == lastLoginAt
          ? _value.lastLoginAt
          : lastLoginAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$UserModelImplCopyWith<$Res>
    implements $UserModelCopyWith<$Res> {
  factory _$$UserModelImplCopyWith(
          _$UserModelImpl value, $Res Function(_$UserModelImpl) then) =
      __$$UserModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String email,
      String displayName,
      String? firstName,
      String? lastName,
      String? photoUrl,
      String? phoneNumber,
      DateTime? dateOfBirth,
      String? favoriteTeam,
      String? favoriteLeague,
      List<String>? favoriteTeams,
      List<String>? favoriteLeagues,
      bool isEmailVerified,
      bool isPremiumUser,
      String preferredLanguage,
      String themePreference,
      List<String> notificationPreferences,
      DateTime? createdAt,
      DateTime? updatedAt,
      DateTime? lastLoginAt});
}

/// @nodoc
class __$$UserModelImplCopyWithImpl<$Res>
    extends _$UserModelCopyWithImpl<$Res, _$UserModelImpl>
    implements _$$UserModelImplCopyWith<$Res> {
  __$$UserModelImplCopyWithImpl(
      _$UserModelImpl _value, $Res Function(_$UserModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of UserModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? email = null,
    Object? displayName = null,
    Object? firstName = freezed,
    Object? lastName = freezed,
    Object? photoUrl = freezed,
    Object? phoneNumber = freezed,
    Object? dateOfBirth = freezed,
    Object? favoriteTeam = freezed,
    Object? favoriteLeague = freezed,
    Object? favoriteTeams = freezed,
    Object? favoriteLeagues = freezed,
    Object? isEmailVerified = null,
    Object? isPremiumUser = null,
    Object? preferredLanguage = null,
    Object? themePreference = null,
    Object? notificationPreferences = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? lastLoginAt = freezed,
  }) {
    return _then(_$UserModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      email: null == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
      displayName: null == displayName
          ? _value.displayName
          : displayName // ignore: cast_nullable_to_non_nullable
              as String,
      firstName: freezed == firstName
          ? _value.firstName
          : firstName // ignore: cast_nullable_to_non_nullable
              as String?,
      lastName: freezed == lastName
          ? _value.lastName
          : lastName // ignore: cast_nullable_to_non_nullable
              as String?,
      photoUrl: freezed == photoUrl
          ? _value.photoUrl
          : photoUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      phoneNumber: freezed == phoneNumber
          ? _value.phoneNumber
          : phoneNumber // ignore: cast_nullable_to_non_nullable
              as String?,
      dateOfBirth: freezed == dateOfBirth
          ? _value.dateOfBirth
          : dateOfBirth // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      favoriteTeam: freezed == favoriteTeam
          ? _value.favoriteTeam
          : favoriteTeam // ignore: cast_nullable_to_non_nullable
              as String?,
      favoriteLeague: freezed == favoriteLeague
          ? _value.favoriteLeague
          : favoriteLeague // ignore: cast_nullable_to_non_nullable
              as String?,
      favoriteTeams: freezed == favoriteTeams
          ? _value._favoriteTeams
          : favoriteTeams // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      favoriteLeagues: freezed == favoriteLeagues
          ? _value._favoriteLeagues
          : favoriteLeagues // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      isEmailVerified: null == isEmailVerified
          ? _value.isEmailVerified
          : isEmailVerified // ignore: cast_nullable_to_non_nullable
              as bool,
      isPremiumUser: null == isPremiumUser
          ? _value.isPremiumUser
          : isPremiumUser // ignore: cast_nullable_to_non_nullable
              as bool,
      preferredLanguage: null == preferredLanguage
          ? _value.preferredLanguage
          : preferredLanguage // ignore: cast_nullable_to_non_nullable
              as String,
      themePreference: null == themePreference
          ? _value.themePreference
          : themePreference // ignore: cast_nullable_to_non_nullable
              as String,
      notificationPreferences: null == notificationPreferences
          ? _value._notificationPreferences
          : notificationPreferences // ignore: cast_nullable_to_non_nullable
              as List<String>,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      lastLoginAt: freezed == lastLoginAt
          ? _value.lastLoginAt
          : lastLoginAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$UserModelImpl implements _UserModel {
  const _$UserModelImpl(
      {required this.id,
      required this.email,
      required this.displayName,
      this.firstName,
      this.lastName,
      this.photoUrl,
      this.phoneNumber,
      this.dateOfBirth,
      this.favoriteTeam,
      this.favoriteLeague,
      final List<String>? favoriteTeams,
      final List<String>? favoriteLeagues,
      this.isEmailVerified = false,
      this.isPremiumUser = false,
      this.preferredLanguage = 'en',
      this.themePreference = 'light',
      final List<String> notificationPreferences = const [],
      this.createdAt,
      this.updatedAt,
      this.lastLoginAt})
      : _favoriteTeams = favoriteTeams,
        _favoriteLeagues = favoriteLeagues,
        _notificationPreferences = notificationPreferences;

  factory _$UserModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserModelImplFromJson(json);

  @override
  final String id;
  @override
  final String email;
  @override
  final String displayName;
  @override
  final String? firstName;
  @override
  final String? lastName;
  @override
  final String? photoUrl;
  @override
  final String? phoneNumber;
  @override
  final DateTime? dateOfBirth;
  @override
  final String? favoriteTeam;
  @override
  final String? favoriteLeague;
  final List<String>? _favoriteTeams;
  @override
  List<String>? get favoriteTeams {
    final value = _favoriteTeams;
    if (value == null) return null;
    if (_favoriteTeams is EqualUnmodifiableListView) return _favoriteTeams;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  final List<String>? _favoriteLeagues;
  @override
  List<String>? get favoriteLeagues {
    final value = _favoriteLeagues;
    if (value == null) return null;
    if (_favoriteLeagues is EqualUnmodifiableListView) return _favoriteLeagues;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  @JsonKey()
  final bool isEmailVerified;
  @override
  @JsonKey()
  final bool isPremiumUser;
  @override
  @JsonKey()
  final String preferredLanguage;
  @override
  @JsonKey()
  final String themePreference;
  final List<String> _notificationPreferences;
  @override
  @JsonKey()
  List<String> get notificationPreferences {
    if (_notificationPreferences is EqualUnmodifiableListView)
      return _notificationPreferences;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_notificationPreferences);
  }

  @override
  final DateTime? createdAt;
  @override
  final DateTime? updatedAt;
  @override
  final DateTime? lastLoginAt;

  @override
  String toString() {
    return 'UserModel(id: $id, email: $email, displayName: $displayName, firstName: $firstName, lastName: $lastName, photoUrl: $photoUrl, phoneNumber: $phoneNumber, dateOfBirth: $dateOfBirth, favoriteTeam: $favoriteTeam, favoriteLeague: $favoriteLeague, favoriteTeams: $favoriteTeams, favoriteLeagues: $favoriteLeagues, isEmailVerified: $isEmailVerified, isPremiumUser: $isPremiumUser, preferredLanguage: $preferredLanguage, themePreference: $themePreference, notificationPreferences: $notificationPreferences, createdAt: $createdAt, updatedAt: $updatedAt, lastLoginAt: $lastLoginAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.displayName, displayName) ||
                other.displayName == displayName) &&
            (identical(other.firstName, firstName) ||
                other.firstName == firstName) &&
            (identical(other.lastName, lastName) ||
                other.lastName == lastName) &&
            (identical(other.photoUrl, photoUrl) ||
                other.photoUrl == photoUrl) &&
            (identical(other.phoneNumber, phoneNumber) ||
                other.phoneNumber == phoneNumber) &&
            (identical(other.dateOfBirth, dateOfBirth) ||
                other.dateOfBirth == dateOfBirth) &&
            (identical(other.favoriteTeam, favoriteTeam) ||
                other.favoriteTeam == favoriteTeam) &&
            (identical(other.favoriteLeague, favoriteLeague) ||
                other.favoriteLeague == favoriteLeague) &&
            const DeepCollectionEquality()
                .equals(other._favoriteTeams, _favoriteTeams) &&
            const DeepCollectionEquality()
                .equals(other._favoriteLeagues, _favoriteLeagues) &&
            (identical(other.isEmailVerified, isEmailVerified) ||
                other.isEmailVerified == isEmailVerified) &&
            (identical(other.isPremiumUser, isPremiumUser) ||
                other.isPremiumUser == isPremiumUser) &&
            (identical(other.preferredLanguage, preferredLanguage) ||
                other.preferredLanguage == preferredLanguage) &&
            (identical(other.themePreference, themePreference) ||
                other.themePreference == themePreference) &&
            const DeepCollectionEquality().equals(
                other._notificationPreferences, _notificationPreferences) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.lastLoginAt, lastLoginAt) ||
                other.lastLoginAt == lastLoginAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        email,
        displayName,
        firstName,
        lastName,
        photoUrl,
        phoneNumber,
        dateOfBirth,
        favoriteTeam,
        favoriteLeague,
        const DeepCollectionEquality().hash(_favoriteTeams),
        const DeepCollectionEquality().hash(_favoriteLeagues),
        isEmailVerified,
        isPremiumUser,
        preferredLanguage,
        themePreference,
        const DeepCollectionEquality().hash(_notificationPreferences),
        createdAt,
        updatedAt,
        lastLoginAt
      ]);

  /// Create a copy of UserModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UserModelImplCopyWith<_$UserModelImpl> get copyWith =>
      __$$UserModelImplCopyWithImpl<_$UserModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UserModelImplToJson(
      this,
    );
  }
}

abstract class _UserModel implements UserModel {
  const factory _UserModel(
      {required final String id,
      required final String email,
      required final String displayName,
      final String? firstName,
      final String? lastName,
      final String? photoUrl,
      final String? phoneNumber,
      final DateTime? dateOfBirth,
      final String? favoriteTeam,
      final String? favoriteLeague,
      final List<String>? favoriteTeams,
      final List<String>? favoriteLeagues,
      final bool isEmailVerified,
      final bool isPremiumUser,
      final String preferredLanguage,
      final String themePreference,
      final List<String> notificationPreferences,
      final DateTime? createdAt,
      final DateTime? updatedAt,
      final DateTime? lastLoginAt}) = _$UserModelImpl;

  factory _UserModel.fromJson(Map<String, dynamic> json) =
      _$UserModelImpl.fromJson;

  @override
  String get id;
  @override
  String get email;
  @override
  String get displayName;
  @override
  String? get firstName;
  @override
  String? get lastName;
  @override
  String? get photoUrl;
  @override
  String? get phoneNumber;
  @override
  DateTime? get dateOfBirth;
  @override
  String? get favoriteTeam;
  @override
  String? get favoriteLeague;
  @override
  List<String>? get favoriteTeams;
  @override
  List<String>? get favoriteLeagues;
  @override
  bool get isEmailVerified;
  @override
  bool get isPremiumUser;
  @override
  String get preferredLanguage;
  @override
  String get themePreference;
  @override
  List<String> get notificationPreferences;
  @override
  DateTime? get createdAt;
  @override
  DateTime? get updatedAt;
  @override
  DateTime? get lastLoginAt;

  /// Create a copy of UserModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserModelImplCopyWith<_$UserModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
