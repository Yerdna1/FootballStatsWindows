import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

@freezed
class UserModel with _$UserModel {
  const factory UserModel({
    required String id,
    required String email,
    required String displayName,
    String? firstName,
    String? lastName,
    String? photoUrl,
    String? phoneNumber,
    DateTime? dateOfBirth,
    String? favoriteTeam,
    String? favoriteLeague,
    List<String>? favoriteTeams,
    List<String>? favoriteLeagues,
    @Default(false) bool isEmailVerified,
    @Default(false) bool isPremiumUser,
    @Default('en') String preferredLanguage,
    @Default('light') String themePreference,
    @Default([]) List<String> notificationPreferences,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastLoginAt,
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);
}

extension UserModelX on UserModel {
  String get fullName {
    if (firstName != null && lastName != null) {
      return '$firstName $lastName';
    }
    return displayName;
  }

  String get initials {
    final names = fullName.split(' ');
    if (names.length >= 2) {
      return '${names.first.substring(0, 1)}${names.last.substring(0, 1)}';
    } else if (names.isNotEmpty) {
      return names.first.substring(0, 1);
    }
    return 'U';
  }

  bool get hasCompletedProfile {
    return firstName != null &&
           lastName != null &&
           phoneNumber != null &&
           dateOfBirth != null;
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'email': email,
      'displayName': displayName,
      'firstName': firstName,
      'lastName': lastName,
      'photoUrl': photoUrl,
      'phoneNumber': phoneNumber,
      'dateOfBirth': dateOfBirth?.millisecondsSinceEpoch,
      'favoriteTeam': favoriteTeam,
      'favoriteLeague': favoriteLeague,
      'favoriteTeams': favoriteTeams,
      'favoriteLeagues': favoriteLeagues,
      'isEmailVerified': isEmailVerified,
      'isPremiumUser': isPremiumUser,
      'preferredLanguage': preferredLanguage,
      'themePreference': themePreference,
      'notificationPreferences': notificationPreferences,
      'createdAt': createdAt?.millisecondsSinceEpoch,
      'updatedAt': updatedAt?.millisecondsSinceEpoch,
      'lastLoginAt': lastLoginAt?.millisecondsSinceEpoch,
    };
  }

  static UserModel fromFirestore(Map<String, dynamic> data) {
    return UserModel(
      id: data['id'] ?? '',
      email: data['email'] ?? '',
      displayName: data['displayName'] ?? '',
      firstName: data['firstName'],
      lastName: data['lastName'],
      photoUrl: data['photoUrl'],
      phoneNumber: data['phoneNumber'],
      dateOfBirth: data['dateOfBirth'] != null
          ? DateTime.fromMillisecondsSinceEpoch(data['dateOfBirth'])
          : null,
      favoriteTeam: data['favoriteTeam'],
      favoriteLeague: data['favoriteLeague'],
      favoriteTeams: List<String>.from(data['favoriteTeams'] ?? []),
      favoriteLeagues: List<String>.from(data['favoriteLeagues'] ?? []),
      isEmailVerified: data['isEmailVerified'] ?? false,
      isPremiumUser: data['isPremiumUser'] ?? false,
      preferredLanguage: data['preferredLanguage'] ?? 'en',
      themePreference: data['themePreference'] ?? 'light',
      notificationPreferences:
          List<String>.from(data['notificationPreferences'] ?? []),
      createdAt: data['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(data['createdAt'])
          : null,
      updatedAt: data['updatedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(data['updatedAt'])
          : null,
      lastLoginAt: data['lastLoginAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(data['lastLoginAt'])
          : null,
    );
  }
}