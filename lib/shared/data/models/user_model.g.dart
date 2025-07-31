// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserModelImpl _$$UserModelImplFromJson(Map<String, dynamic> json) =>
    _$UserModelImpl(
      id: json['id'] as String,
      email: json['email'] as String,
      displayName: json['displayName'] as String,
      firstName: json['firstName'] as String?,
      lastName: json['lastName'] as String?,
      photoUrl: json['photoUrl'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      dateOfBirth: json['dateOfBirth'] == null
          ? null
          : DateTime.parse(json['dateOfBirth'] as String),
      favoriteTeam: json['favoriteTeam'] as String?,
      favoriteLeague: json['favoriteLeague'] as String?,
      favoriteTeams: (json['favoriteTeams'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      favoriteLeagues: (json['favoriteLeagues'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      isEmailVerified: json['isEmailVerified'] as bool? ?? false,
      isPremiumUser: json['isPremiumUser'] as bool? ?? false,
      preferredLanguage: json['preferredLanguage'] as String? ?? 'en',
      themePreference: json['themePreference'] as String? ?? 'light',
      notificationPreferences:
          (json['notificationPreferences'] as List<dynamic>?)
                  ?.map((e) => e as String)
                  .toList() ??
              const [],
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
      lastLoginAt: json['lastLoginAt'] == null
          ? null
          : DateTime.parse(json['lastLoginAt'] as String),
    );

Map<String, dynamic> _$$UserModelImplToJson(_$UserModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      'displayName': instance.displayName,
      'firstName': instance.firstName,
      'lastName': instance.lastName,
      'photoUrl': instance.photoUrl,
      'phoneNumber': instance.phoneNumber,
      'dateOfBirth': instance.dateOfBirth?.toIso8601String(),
      'favoriteTeam': instance.favoriteTeam,
      'favoriteLeague': instance.favoriteLeague,
      'favoriteTeams': instance.favoriteTeams,
      'favoriteLeagues': instance.favoriteLeagues,
      'isEmailVerified': instance.isEmailVerified,
      'isPremiumUser': instance.isPremiumUser,
      'preferredLanguage': instance.preferredLanguage,
      'themePreference': instance.themePreference,
      'notificationPreferences': instance.notificationPreferences,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
      'lastLoginAt': instance.lastLoginAt?.toIso8601String(),
    };
