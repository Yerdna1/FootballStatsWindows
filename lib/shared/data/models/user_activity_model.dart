import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_activity_model.freezed.dart';
part 'user_activity_model.g.dart';

@freezed
class UserActivityModel with _$UserActivityModel {
  const factory UserActivityModel({
    required String id,
    required String userId,
    required ActivityType type,
    required String action,
    String? description,
    Map<String, dynamic>? metadata,
    DateTime? timestamp,
    String? sessionId,
    String? deviceInfo,
    String? platform,
    String? appVersion,
    UserLocation? location,
    @Default(false) bool isImportant,
    @Default([]) List<String> tags,
    ActivityContext? context,
  }) = _UserActivityModel;

  factory UserActivityModel.fromJson(Map<String, dynamic> json) =>
      _$UserActivityModelFromJson(json);
}

@freezed
class UserPreferencesModel with _$UserPreferencesModel {
  const factory UserPreferencesModel({
    required String userId,
    required NotificationPreferences notifications,
    required DisplayPreferences display,
    required DataPreferences data,
    required PrivacyPreferences privacy,
    @Default([]) List<String> favoriteTeams,
    @Default([]) List<String> favoriteLeagues,
    @Default([]) List<String> favoriteCompetitions,
    @Default([]) List<String> blockedTeams,
    @Default([]) List<String> pinnedFixtures,
    @Default({}) Map<String, String> customSettings,
    DateTime? lastUpdated,
  }) = _UserPreferencesModel;

  factory UserPreferencesModel.fromJson(Map<String, dynamic> json) =>
      _$UserPreferencesModelFromJson(json);
}

@freezed
class ActivityLogModel with _$ActivityLogModel {
  const factory ActivityLogModel({
    required String id,
    required String userId,
    required DateTime date,
    @Default([]) List<UserActivityModel> activities,
    @Default(0) int totalActivities,
    @Default(0) int viewActivities,
    @Default(0) int interactionActivities,
    @Default(0) int searchActivities,
    @Default(0) int shareActivities,
    ActivitySummary? summary,
  }) = _ActivityLogModel;

  factory ActivityLogModel.fromJson(Map<String, dynamic> json) =>
      _$ActivityLogModelFromJson(json);
}

@freezed
class UserEngagementModel with _$UserEngagementModel {
  const factory UserEngagementModel({
    required String userId,
    required DateTime date,
    @Default(0) int sessionCount,
    @Default(0) int totalSessionDuration,
    @Default(0) int averageSessionDuration,
    @Default(0) int screenViews,
    @Default(0) int uniqueScreens,
    @Default(0) int interactions,
    @Default(0) int searches,
    @Default(0) int shares,
    @Default(0) int bookmarks,
    @Default(0.0) double engagementScore,
    @Default([]) List<String> mostVisitedScreens,
    @Default([]) List<String> searchTerms,
    @Default([]) List<EngagementMetric> metrics,
    EngagementTrend? trend,
  }) = _UserEngagementModel;

  factory UserEngagementModel.fromJson(Map<String, dynamic> json) =>
      _$UserEngagementModelFromJson(json);
}

@freezed
class NotificationPreferences with _$NotificationPreferences {
  const factory NotificationPreferences({
    @Default(true) bool matchStartReminder,
    @Default(true) bool goalAlerts,
    @Default(true) bool resultNotifications,
    @Default(false) bool lineupAnnouncements,
    @Default(false) bool injuryUpdates,
    @Default(false) bool transferNews,
    @Default(true) bool favoriteTeamUpdates,
    @Default(false) bool leagueUpdates,
    @Default(false) bool weeklyDigest,
    @Default(30) int reminderMinutes,
    @Default([]) List<String> soundPreferences,
    @Default(true) bool vibration,
    @Default('all') String frequency,
    @Default([]) List<TimeRange> quietHours,
  }) = _NotificationPreferences;

  factory NotificationPreferences.fromJson(Map<String, dynamic> json) =>
      _$NotificationPreferencesFromJson(json);
}

@freezed
class DisplayPreferences with _$DisplayPreferences {
  const factory DisplayPreferences({
    @Default('light') String theme,
    @Default('system') String themeMode,
    @Default('en') String language,
    @Default('auto') String dateFormat,
    @Default('24h') String timeFormat,
    @Default('metric') String units,
    @Default('auto') String timezone,
    @Default(false) bool compactMode,
    @Default(true) bool showImages,
    @Default(true) bool showAnimations,
    @Default(1.0) double textScale,
    @Default('default') String fontFamily,
    @Default({}) Map<String, bool> widgetVisibility,
  }) = _DisplayPreferences;

  factory DisplayPreferences.fromJson(Map<String, dynamic> json) =>
      _$DisplayPreferencesFromJson(json);
}

@freezed
class DataPreferences with _$DataPreferences {
  const factory DataPreferences({
    @Default(true) bool autoSync,
    @Default(false) bool wifiOnlySync,
    @Default(true) bool cacheImages,
    @Default(true) bool offlineMode,
    @Default(7) int cacheRetentionDays,
    @Default(100) int maxCacheSize,
    @Default(true) bool preloadUpcoming,
    @Default(false) bool reducedDataMode,
    @Default([]) List<String> syncPreferences,
  }) = _DataPreferences;

  factory DataPreferences.fromJson(Map<String, dynamic> json) =>
      _$DataPreferencesFromJson(json);
}

@freezed
class PrivacyPreferences with _$PrivacyPreferences {
  const factory PrivacyPreferences({
    @Default(false) bool shareUsageData,
    @Default(false) bool shareLocation,
    @Default(true) bool personalizedContent,
    @Default(false) bool marketingEmails,
    @Default(true) bool cookieConsent,
    @Default(false) bool profileVisibility,
    @Default([]) List<String> dataExportRequests,
    DateTime? lastDataExport,
  }) = _PrivacyPreferences;

  factory PrivacyPreferences.fromJson(Map<String, dynamic> json) =>
      _$PrivacyPreferencesFromJson(json);
}

@freezed
class UserLocation with _$UserLocation {
  const factory UserLocation({
    String? country,
    String? city,
    String? region,
    String? timezone,
    @Default(0.0) double latitude,
    @Default(0.0) double longitude,
    @Default(0.0) double accuracy,
    DateTime? timestamp,
  }) = _UserLocation;

  factory UserLocation.fromJson(Map<String, dynamic> json) =>
      _$UserLocationFromJson(json);
}

@freezed
class ActivityContext with _$ActivityContext {
  const factory ActivityContext({
    String? screenName,
    String? previousScreen,
    String? referrer,
    String? searchQuery,
    String? filterApplied,
    String? sortOrder,
    Map<String, dynamic>? customData,
  }) = _ActivityContext;

  factory ActivityContext.fromJson(Map<String, dynamic> json) =>
      _$ActivityContextFromJson(json);
}

@freezed
class ActivitySummary with _$ActivitySummary {
  const factory ActivitySummary({
    @Default(0) int totalActivities,
    @Default(0) int uniqueScreens,
    @Default(0) int interactions,
    @Default(0) int sessionDuration,
    @Default([]) List<String> topActivities,
    @Default([]) List<String> topScreens,
    String? dominantActivity,
    @Default(0.0) double engagementScore,
  }) = _ActivitySummary;

  factory ActivitySummary.fromJson(Map<String, dynamic> json) =>
      _$ActivitySummaryFromJson(json);
}

@freezed
class EngagementMetric with _$EngagementMetric {
  const factory EngagementMetric({
    required String name,
    @Default(0.0) double value,
    @Default(0.0) double previousValue,
    @Default(0.0) double change,
    required MetricDirection direction,
    String? unit,
    String? description,
  }) = _EngagementMetric;

  factory EngagementMetric.fromJson(Map<String, dynamic> json) =>
      _$EngagementMetricFromJson(json);
}

@freezed
class EngagementTrend with _$EngagementTrend {
  const factory EngagementTrend({
    required TrendDirection direction,
    @Default(0.0) double score,
    @Default(0.0) double change,
    @Default([]) List<String> factors,
    String? summary,
  }) = _EngagementTrend;

  factory EngagementTrend.fromJson(Map<String, dynamic> json) =>
      _$EngagementTrendFromJson(json);
}

@freezed
class TimeRange with _$TimeRange {
  const factory TimeRange({
    required String startTime,
    required String endTime,
    @Default([]) List<String> days,
  }) = _TimeRange;

  factory TimeRange.fromJson(Map<String, dynamic> json) =>
      _$TimeRangeFromJson(json);
}

enum ActivityType {
  view,
  interaction,
  search,
  filter,
  sort,
  share,
  bookmark,
  login,
  logout,
  registration,
  settings,
  notification,
  error,
  performance,
  custom,
}

enum MetricDirection {
  up,
  down,
  stable,
}

enum TrendDirection {
  increasing,
  decreasing,
  stable,
  volatile,
}

extension ActivityTypeX on ActivityType {
  String get displayName {
    switch (this) {
      case ActivityType.view:
        return 'View';
      case ActivityType.interaction:
        return 'Interaction';
      case ActivityType.search:
        return 'Search';
      case ActivityType.filter:
        return 'Filter';
      case ActivityType.sort:
        return 'Sort';
      case ActivityType.share:
        return 'Share';
      case ActivityType.bookmark:
        return 'Bookmark';
      case ActivityType.login:
        return 'Login';
      case ActivityType.logout:
        return 'Logout';
      case ActivityType.registration:
        return 'Registration';
      case ActivityType.settings:
        return 'Settings';
      case ActivityType.notification:
        return 'Notification';
      case ActivityType.error:
        return 'Error';
      case ActivityType.performance:
        return 'Performance';
      case ActivityType.custom:
        return 'Custom';
    }
  }

  String get icon {
    switch (this) {
      case ActivityType.view:
        return '👁';
      case ActivityType.interaction:
        return '👆';
      case ActivityType.search:
        return '🔍';
      case ActivityType.filter:
        return '🔽';
      case ActivityType.sort:
        return '📊';
      case ActivityType.share:
        return '📤';
      case ActivityType.bookmark:
        return '🔖';
      case ActivityType.login:
        return '🔑';
      case ActivityType.logout:
        return '🚪';
      case ActivityType.registration:
        return '📝';
      case ActivityType.settings:
        return '⚙️';
      case ActivityType.notification:
        return '🔔';
      case ActivityType.error:
        return '❌';
      case ActivityType.performance:
        return '📈';
      case ActivityType.custom:
        return '🎯';
    }
  }
}

extension MetricDirectionX on MetricDirection {
  String get icon {
    switch (this) {
      case MetricDirection.up:
        return '↑';
      case MetricDirection.down:
        return '↓';
      case MetricDirection.stable:
        return '→';
    }
  }
}

extension TrendDirectionX on TrendDirection {
  String get displayName {
    switch (this) {
      case TrendDirection.increasing:
        return 'Increasing';
      case TrendDirection.decreasing:
        return 'Decreasing';
      case TrendDirection.stable:
        return 'Stable';
      case TrendDirection.volatile:
        return 'Volatile';
    }
  }

  String get icon {
    switch (this) {
      case TrendDirection.increasing:
        return '📈';
      case TrendDirection.decreasing:
        return '📉';
      case TrendDirection.stable:
        return '➡️';
      case TrendDirection.volatile:
        return '📊';
    }
  }
}

extension UserActivityModelX on UserActivityModel {
  bool get isRecent {
    if (timestamp == null) return false;
    return DateTime.now().difference(timestamp!).inHours < 1;
  }

  bool get isToday {
    if (timestamp == null) return false;
    final now = DateTime.now();
    final activityDate = timestamp!;
    return now.year == activityDate.year &&
           now.month == activityDate.month &&
           now.day == activityDate.day;
  }

  String get timeAgo {
    if (timestamp == null) return 'Unknown';
    final now = DateTime.now();
    final difference = now.difference(timestamp!);
    
    if (difference.inMinutes < 1) return 'Just now';
    if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
    if (difference.inHours < 24) return '${difference.inHours}h ago';
    if (difference.inDays < 7) return '${difference.inDays}d ago';
    return '${(difference.inDays / 7).floor()}w ago';
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'userId': userId,
      'type': type.name,
      'action': action,
      'description': description,
      'metadata': metadata,
      'timestamp': timestamp?.millisecondsSinceEpoch,
      'sessionId': sessionId,
      'deviceInfo': deviceInfo,
      'platform': platform,
      'appVersion': appVersion,
      'location': location?.toJson(),
      'isImportant': isImportant,
      'tags': tags,
      'context': context?.toJson(),
    };
  }

  static UserActivityModel fromFirestore(Map<String, dynamic> data) {
    return UserActivityModel(
      id: data['id'],
      userId: data['userId'],
      type: ActivityType.values.firstWhere(
        (t) => t.name == data['type'],
        orElse: () => ActivityType.custom,
      ),
      action: data['action'],
      description: data['description'],
      metadata: data['metadata'],
      timestamp: data['timestamp'] != null
          ? DateTime.fromMillisecondsSinceEpoch(data['timestamp'])
          : null,
      sessionId: data['sessionId'],
      deviceInfo: data['deviceInfo'],
      platform: data['platform'],
      appVersion: data['appVersion'],
      location: data['location'] != null
          ? UserLocation.fromJson(data['location'])
          : null,
      isImportant: data['isImportant'] ?? false,
      tags: List<String>.from(data['tags'] ?? []),
      context: data['context'] != null
          ? ActivityContext.fromJson(data['context'])
          : null,
    );
  }
}

extension UserEngagementModelX on UserEngagementModel {
  double get sessionsPerHour {
    if (totalSessionDuration == 0) return 0.0;
    return sessionCount / (totalSessionDuration / 3600);
  }

  double get interactionsPerSession {
    if (sessionCount == 0) return 0.0;
    return interactions / sessionCount;
  }

  double get screenViewsPerSession {
    if (sessionCount == 0) return 0.0;
    return screenViews / sessionCount;
  }

  String get engagementLevel {
    if (engagementScore >= 90) return 'Very High';
    if (engagementScore >= 70) return 'High';
    if (engagementScore >= 50) return 'Medium';
    if (engagementScore >= 30) return 'Low';
    return 'Very Low';
  }

  bool get isHighlyEngaged => engagementScore >= 70.0;
  bool get needsAttention => engagementScore < 30.0;

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'date': date.millisecondsSinceEpoch,
      'sessionCount': sessionCount,
      'totalSessionDuration': totalSessionDuration,
      'averageSessionDuration': averageSessionDuration,
      'screenViews': screenViews,
      'uniqueScreens': uniqueScreens,
      'interactions': interactions,
      'searches': searches,
      'shares': shares,
      'bookmarks': bookmarks,
      'engagementScore': engagementScore,
      'mostVisitedScreens': mostVisitedScreens,
      'searchTerms': searchTerms,
      'metrics': metrics.map((m) => m.toJson()).toList(),
      'trend': trend?.toJson(),
    };
  }

  static UserEngagementModel fromFirestore(Map<String, dynamic> data) {
    return UserEngagementModel(
      userId: data['userId'],
      date: DateTime.fromMillisecondsSinceEpoch(data['date']),
      sessionCount: data['sessionCount'] ?? 0,
      totalSessionDuration: data['totalSessionDuration'] ?? 0,
      averageSessionDuration: data['averageSessionDuration'] ?? 0,
      screenViews: data['screenViews'] ?? 0,
      uniqueScreens: data['uniqueScreens'] ?? 0,
      interactions: data['interactions'] ?? 0,
      searches: data['searches'] ?? 0,
      shares: data['shares'] ?? 0,
      bookmarks: data['bookmarks'] ?? 0,
      engagementScore: data['engagementScore']?.toDouble() ?? 0.0,
      mostVisitedScreens: List<String>.from(data['mostVisitedScreens'] ?? []),
      searchTerms: List<String>.from(data['searchTerms'] ?? []),
      metrics: (data['metrics'] as List<dynamic>?)
              ?.map((m) => EngagementMetric.fromJson(m))
              .toList() ??
          [],
      trend: data['trend'] != null
          ? EngagementTrend.fromJson(data['trend'])
          : null,
    );
  }
}