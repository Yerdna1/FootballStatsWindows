import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';

import '../../../../shared/data/models/user_model.dart';
import '../../../../shared/data/models/user_activity_model.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/error/exceptions.dart';
import 'auth_provider.dart';

class UserManagementService {
  final FirebaseFirestore _firestore;
  final Logger _logger = Logger();

  UserManagementService({FirebaseFirestore? firestore}) 
      : _firestore = firestore ?? FirebaseFirestore.instance;

  // User management methods
  Future<List<UserModel>> getAllUsers({
    int limit = 20,
    DocumentSnapshot? startAfter,
  }) async {
    try {
      Query query = _firestore
          .collection('users')
          .orderBy('createdAt', descending: true)
          .limit(limit);

      if (startAfter != null) {
        query = query.startAfterDocument(startAfter);
      }

      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) => UserModel.fromJson({
                ...doc.data() as Map<String, dynamic>,
                'id': doc.id,
              }))
          .toList();
    } catch (e) {
      _logger.e('Error getting all users: $e');
      throw const DatabaseFailure(message: 'Failed to fetch users');
    }
  }

  Future<UserModel?> getUserById(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        return UserModel.fromJson({
          ...doc.data()!,
          'id': doc.id,
        });
      }
      return null;
    } catch (e) {
      _logger.e('Error getting user by ID: $e');
      throw const DatabaseFailure(message: 'Failed to fetch user');
    }
  }

  Future<List<UserModel>> searchUsers(String query) async {
    try {
      // Search by email and display name
      final emailResults = await _firestore
          .collection('users')
          .where('email', isGreaterThanOrEqualTo: query.toLowerCase())
          .where('email', isLessThan: '${query.toLowerCase()}z')
          .limit(10)
          .get();

      final nameResults = await _firestore
          .collection('users')
          .where('displayName', isGreaterThanOrEqualTo: query)
          .where('displayName', isLessThan: '${query}z')
          .limit(10)
          .get();

      final users = <UserModel>[];
      final seenIds = <String>{};

      // Combine results and remove duplicates
      for (final doc in [...emailResults.docs, ...nameResults.docs]) {
        if (!seenIds.contains(doc.id)) {
          seenIds.add(doc.id);
          users.add(UserModel.fromJson({
            ...doc.data(),
            'id': doc.id,
          }));
        }
      }

      return users;
    } catch (e) {
      _logger.e('Error searching users: $e');
      throw const DatabaseFailure(message: 'Failed to search users');
    }
  }

  Future<void> updateUserRole(String userId, UserRole newRole) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'role': newRole.name,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      _logger.i('Updated user $userId role to $newRole');
    } catch (e) {
      _logger.e('Error updating user role: $e');
      throw const DatabaseFailure(message: 'Failed to update user role');
    }
  }

  Future<void> updateUserStatus(String userId, UserStatus newStatus) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'status': newStatus.name,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      _logger.i('Updated user $userId status to $newStatus');
    } catch (e) {
      _logger.e('Error updating user status: $e');
      throw const DatabaseFailure(message: 'Failed to update user status');
    }
  }

  Future<void> banUser(String userId, String reason) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'status': UserStatus.banned.name,
        'bannedAt': FieldValue.serverTimestamp(),
        'banReason': reason,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      _logger.i('Banned user $userId for: $reason');
    } catch (e) {
      _logger.e('Error banning user: $e');
      throw const DatabaseFailure(message: 'Failed to ban user');
    }
  }

  Future<void> unbanUser(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'status': UserStatus.active.name,
        'bannedAt': FieldValue.delete(),
        'banReason': FieldValue.delete(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      _logger.i('Unbanned user $userId');
    } catch (e) {
      _logger.e('Error unbanning user: $e');
      throw const DatabaseFailure(message: 'Failed to unban user');
    }
  }

  Future<void> deleteUser(String userId) async {
    try {
      // Delete user document
      await _firestore.collection('users').doc(userId).delete();
      
      // Delete user activities
      final activitiesBatch = _firestore.batch();
      final activities = await _firestore
          .collection('user_activities')
          .where('userId', isEqualTo: userId)
          .get();
      
      for (final doc in activities.docs) {
        activitiesBatch.delete(doc.reference);
      }
      
      await activitiesBatch.commit();
      _logger.i('Deleted user $userId and their activities');
    } catch (e) {
      _logger.e('Error deleting user: $e');
      throw const DatabaseFailure(message: 'Failed to delete user');
    }
  }

  // User activity tracking
  Future<void> logUserActivity(UserActivityLog activity) async {
    try {
      await _firestore
          .collection('user_activities')
          .add(activity.toJson());
    } catch (e) {
      _logger.e('Error logging user activity: $e');
      // Don't throw error for activity logging to avoid disrupting user flow
    }
  }

  Future<List<UserActivityLog>> getUserActivities(
    String userId, {
    int limit = 50,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      Query query = _firestore
          .collection('user_activities')
          .where('userId', isEqualTo: userId)
          .orderBy('timestamp', descending: true);

      if (startDate != null) {
        query = query.where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate));
      }

      if (endDate != null) {
        query = query.where('timestamp', isLessThanOrEqualTo: Timestamp.fromDate(endDate));
      }

      query = query.limit(limit);

      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) => UserActivityLog.fromJson({
                ...doc.data() as Map<String, dynamic>,
                'id': doc.id,
              }))
          .toList();
    } catch (e) {
      _logger.e('Error getting user activities: $e');
      throw const DatabaseFailure(message: 'Failed to fetch user activities');
    }
  }

  Future<Map<String, int>> getUserActivityStats(String userId) async {
    try {
      final activities = await getUserActivities(userId, limit: 1000);
      final stats = <String, int>{};
      
      for (final activity in activities) {
        final action = activity.action.name;
        stats[action] = (stats[action] ?? 0) + 1;
      }
      
      return stats;
    } catch (e) {
      _logger.e('Error getting user activity stats: $e');
      return {};
    }
  }

  Future<UserEngagementMetrics> getUserEngagementMetrics(String userId) async {
    try {
      final now = DateTime.now();
      final thirtyDaysAgo = now.subtract(const Duration(days: 30));
      
      final activities = await getUserActivities(
        userId,
        startDate: thirtyDaysAgo,
        endDate: now,
      );

      // Calculate various engagement metrics
      final uniqueDays = <String>{};
      final sessionStarts = <DateTime>[];
      var totalActions = 0;
      final actionTypes = <UserAction, int>{};

      for (final activity in activities) {
        final day = activity.timestamp.toIso8601String().substring(0, 10);
        uniqueDays.add(day);
        
        if (activity.action == UserAction.login) {
          sessionStarts.add(activity.timestamp);
        }
        
        totalActions++;
        actionTypes[activity.action] = (actionTypes[activity.action] ?? 0) + 1;
      }

      final averageSessionsPerDay = sessionStarts.length / 30.0;
      final averageActionsPerSession = sessionStarts.isNotEmpty 
          ? totalActions / sessionStarts.length 
          : 0.0;

      return UserEngagementMetrics(
        userId: userId,
        activeDays: uniqueDays.length,
        totalSessions: sessionStarts.length,
        totalActions: totalActions,
        averageSessionsPerDay: averageSessionsPerDay,
        averageActionsPerSession: averageActionsPerSession,
        lastActiveAt: activities.isNotEmpty ? activities.first.timestamp : null,
        engagementScore: _calculateEngagementScore(
          uniqueDays.length,
          sessionStarts.length,
          totalActions,
        ),
        periodStart: thirtyDaysAgo,
        periodEnd: now,
      );
    } catch (e) {
      _logger.e('Error getting user engagement metrics: $e');
      throw const DatabaseFailure(message: 'Failed to calculate engagement metrics');
    }
  }

  double _calculateEngagementScore(int activeDays, int sessions, int actions) {
    // Simple engagement score calculation (0-100)
    // Can be made more sophisticated based on requirements
    final daysScore = (activeDays / 30.0) * 40; // 40% weight for active days
    final sessionScore = (sessions / 60.0).clamp(0, 1) * 30; // 30% weight for sessions
    final actionScore = (actions / 300.0).clamp(0, 1) * 30; // 30% weight for actions
    
    return (daysScore + sessionScore + actionScore).clamp(0, 100);
  }

  // Bulk operations
  Future<void> bulkUpdateUserRoles(List<String> userIds, UserRole newRole) async {
    try {
      final batch = _firestore.batch();
      
      for (final userId in userIds) {
        final userRef = _firestore.collection('users').doc(userId);
        batch.update(userRef, {
          'role': newRole.name,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
      
      await batch.commit();
      _logger.i('Bulk updated ${userIds.length} users to role $newRole');
    } catch (e) {
      _logger.e('Error in bulk update user roles: $e');
      throw const DatabaseFailure(message: 'Failed to bulk update user roles');
    }
  }

  Future<void> bulkBanUsers(List<String> userIds, String reason) async {
    try {
      final batch = _firestore.batch();
      
      for (final userId in userIds) {
        final userRef = _firestore.collection('users').doc(userId);
        batch.update(userRef, {
          'status': UserStatus.banned.name,
          'bannedAt': FieldValue.serverTimestamp(),
          'banReason': reason,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
      
      await batch.commit();
      _logger.i('Bulk banned ${userIds.length} users for: $reason');
    } catch (e) {
      _logger.e('Error in bulk ban users: $e');
      throw const DatabaseFailure(message: 'Failed to bulk ban users');
    }
  }

  // Statistics
  Future<Map<String, int>> getUserRoleDistribution() async {
    try {
      final users = await getAllUsers(limit: 1000); // Adjust as needed
      final distribution = <String, int>{};
      
      for (final user in users) {
        final role = user.role?.name ?? 'unknown';
        distribution[role] = (distribution[role] ?? 0) + 1;
      }
      
      return distribution;
    } catch (e) {
      _logger.e('Error getting user role distribution: $e');
      return {};
    }
  }

  Future<Map<String, int>> getUserStatusDistribution() async {
    try {
      final users = await getAllUsers(limit: 1000); // Adjust as needed
      final distribution = <String, int>{};
      
      for (final user in users) {
        final status = user.status?.name ?? 'unknown';
        distribution[status] = (distribution[status] ?? 0) + 1;
      }
      
      return distribution;
    } catch (e) {
      _logger.e('Error getting user status distribution: $e');
      return {};
    }
  }
}

// Service provider
final userManagementServiceProvider = Provider<UserManagementService>((ref) {
  return UserManagementService();
});

// User list provider with pagination
final userListProvider = StateNotifierProvider<UserListNotifier, AsyncValue<List<UserModel>>>((ref) {
  final service = ref.watch(userManagementServiceProvider);
  return UserListNotifier(service);
});

class UserListNotifier extends StateNotifier<AsyncValue<List<UserModel>>> {
  final UserManagementService _service;
  final List<UserModel> _users = [];
  DocumentSnapshot? _lastDocument;
  bool _hasMore = true;

  UserListNotifier(this._service) : super(const AsyncValue.loading()) {
    loadUsers();
  }

  Future<void> loadUsers({bool refresh = false}) async {
    if (refresh) {
      _users.clear();
      _lastDocument = null;
      _hasMore = true;
    }

    if (!_hasMore) return;

    try {
      if (_users.isEmpty) {
        state = const AsyncValue.loading();
      }

      final newUsers = await _service.getAllUsers(
        startAfter: _lastDocument,
      );

      if (newUsers.isNotEmpty) {
        _users.addAll(newUsers);
        // Note: You'll need to implement a way to get the last document
        // This is a simplified version
        _hasMore = newUsers.length == 20; // Assuming limit is 20
      } else {
        _hasMore = false;
      }

      state = AsyncValue.data(List.from(_users));
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> updateUserRole(String userId, UserRole newRole) async {
    try {
      await _service.updateUserRole(userId, newRole);
      
      // Update local state
      final index = _users.indexWhere((user) => user.id == userId);
      if (index != -1) {
        _users[index] = _users[index].copyWith(
          role: newRole,
          updatedAt: DateTime.now(),
        );
        state = AsyncValue.data(List.from(_users));
      }
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> banUser(String userId, String reason) async {
    try {
      await _service.banUser(userId, reason);
      
      // Update local state
      final index = _users.indexWhere((user) => user.id == userId);
      if (index != -1) {
        _users[index] = _users[index].copyWith(
          status: UserStatus.banned,
          updatedAt: DateTime.now(),
        );
        state = AsyncValue.data(List.from(_users));
      }
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> deleteUser(String userId) async {
    try {
      await _service.deleteUser(userId);
      
      // Remove from local state
      _users.removeWhere((user) => user.id == userId);
      state = AsyncValue.data(List.from(_users));
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }
}

// Search users provider
final userSearchProvider = StateNotifierProvider.family<UserSearchNotifier, AsyncValue<List<UserModel>>, String>((ref, query) {
  final service = ref.watch(userManagementServiceProvider);
  return UserSearchNotifier(service, query);
});

class UserSearchNotifier extends StateNotifier<AsyncValue<List<UserModel>>> {
  final UserManagementService _service;
  final String _query;

  UserSearchNotifier(this._service, this._query) : super(const AsyncValue.loading()) {
    search();
  }

  Future<void> search() async {
    if (_query.isEmpty) {
      state = const AsyncValue.data([]);
      return;
    }

    try {
      state = const AsyncValue.loading();
      final results = await _service.searchUsers(_query);
      state = AsyncValue.data(results);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }
}

// User activities provider
final userActivitiesProvider = StateNotifierProvider.family<UserActivitiesNotifier, AsyncValue<List<UserActivityLog>>, String>((ref, userId) {
  final service = ref.watch(userManagementServiceProvider);
  return UserActivitiesNotifier(service, userId);
});

class UserActivitiesNotifier extends StateNotifier<AsyncValue<List<UserActivityLog>>> {
  final UserManagementService _service;
  final String _userId;

  UserActivitiesNotifier(this._service, this._userId) : super(const AsyncValue.loading()) {
    loadActivities();
  }

  Future<void> loadActivities({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      state = const AsyncValue.loading();
      final activities = await _service.getUserActivities(
        _userId,
        startDate: startDate,
        endDate: endDate,
      );
      state = AsyncValue.data(activities);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }
}

// User engagement metrics provider
final userEngagementProvider = FutureProvider.family<UserEngagementMetrics, String>((ref, userId) {
  final service = ref.watch(userManagementServiceProvider);
  return service.getUserEngagementMetrics(userId);
});

// Activity logger provider - used throughout the app to log user actions
final activityLoggerProvider = Provider<ActivityLogger>((ref) {
  final service = ref.watch(userManagementServiceProvider);
  final currentUser = ref.watch(currentUserProvider);
  return ActivityLogger(service, currentUser);
});

class ActivityLogger {
  final UserManagementService _service;
  final UserModel? _currentUser;

  ActivityLogger(this._service, this._currentUser);

  Future<void> log(UserAction action, {
    String? context,
    Map<String, dynamic>? metadata,
  }) async {
    if (_currentUser == null) return;

    final activity = UserActivityLog(
      id: '',
      userId: _currentUser!.id,
      action: action,
      timestamp: DateTime.now(),
      context: context,
      metadata: metadata,
    );

    await _service.logUserActivity(activity);
  }
}

// Role distribution provider
final userRoleDistributionProvider = FutureProvider<Map<String, int>>((ref) {
  final service = ref.watch(userManagementServiceProvider);
  return service.getUserRoleDistribution();
});

// Status distribution provider
final userStatusDistributionProvider = FutureProvider<Map<String, int>>((ref) {
  final service = ref.watch(userManagementServiceProvider);
  return service.getUserStatusDistribution();
});