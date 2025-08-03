import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/data_collection_service.dart';
import '../../../core/network/production_football_api.dart';
import '../../../core/services/database_browser_service.dart';

export '../../../core/network/production_football_api.dart' show ApiUsageStats;

/// API Status Provider
final apiStatusProvider = StateNotifierProvider<ApiStatusNotifier, AsyncValue<ApiStatusData>>((ref) {
  final service = ref.watch(dataCollectionServiceProvider);
  return ApiStatusNotifier(service);
});

class ApiStatusNotifier extends StateNotifier<AsyncValue<ApiStatusData>> {
  final DataCollectionService _service;

  ApiStatusNotifier(this._service) : super(const AsyncValue.loading());

  Future<void> loadApiStatus() async {
    state = const AsyncValue.loading();
    try {
      final status = await _service.getApiStatus();
      state = AsyncValue.data(status);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}

/// Data Sync Status Provider
final dataSyncStatusProvider = StateNotifierProvider<DataSyncStatusNotifier, AsyncValue<DataSyncStatus>>((ref) {
  final service = ref.watch(dataCollectionServiceProvider);
  return DataSyncStatusNotifier(service);
});

class DataSyncStatusNotifier extends StateNotifier<AsyncValue<DataSyncStatus>> {
  final DataCollectionService _service;

  DataSyncStatusNotifier(this._service) : super(const AsyncValue.loading());

  Future<void> loadSyncStatus() async {
    state = const AsyncValue.loading();
    try {
      final status = await _service.getSyncStatus();
      state = AsyncValue.data(status);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}

/// API Usage Provider
final apiUsageProvider = StateNotifierProvider<ApiUsageNotifier, AsyncValue<ApiUsageStats>>((ref) {
  final apiService = ref.watch(productionFootballApiProvider);
  return ApiUsageNotifier(apiService);
});

class ApiUsageNotifier extends StateNotifier<AsyncValue<ApiUsageStats>> {
  final ProductionFootballApi _apiService;

  ApiUsageNotifier(this._apiService) : super(const AsyncValue.loading());

  Future<void> loadUsageStats() async {
    state = const AsyncValue.loading();
    try {
      final stats = _apiService.getUsageStats();
      state = AsyncValue.data(stats);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}

/// Data Collection Service Provider (simple provider, not state notifier)
final dataCollectionServiceProvider = Provider<DataCollectionService>((ref) {
  final api = ref.watch(productionFootballApiProvider);
  final database = ref.watch(databaseBrowserServiceProvider);
  return DataCollectionService(api, database);
});

/// Data Collection Service State Provider
final dataCollectionServiceStateProvider = StateNotifierProvider<DataCollectionServiceNotifier, DataCollectionServiceState>((ref) {
  final service = ref.watch(dataCollectionServiceProvider);
  return DataCollectionServiceNotifier(service);
});

class DataCollectionServiceNotifier extends StateNotifier<DataCollectionServiceState> {
  final DataCollectionService _service;

  DataCollectionServiceNotifier(this._service) : super(const DataCollectionServiceState.idle());

  Future<void> syncAllData() async {
    state = const DataCollectionServiceState.syncing('Starting full synchronization...');
    try {
      await _service.syncAllData();
      state = const DataCollectionServiceState.success('Full synchronization completed');
    } catch (error) {
      state = DataCollectionServiceState.error(error.toString());
    }
  }

  Future<void> syncLeagues() async {
    state = const DataCollectionServiceState.syncing('Syncing leagues...');
    try {
      await _service.syncLeagues();
      state = const DataCollectionServiceState.success('Leagues synchronized');
    } catch (error) {
      state = DataCollectionServiceState.error(error.toString());
    }
  }

  Future<void> syncTeams() async {
    state = const DataCollectionServiceState.syncing('Syncing teams...');
    try {
      await _service.syncTeams();
      state = const DataCollectionServiceState.success('Teams synchronized');
    } catch (error) {
      state = DataCollectionServiceState.error(error.toString());
    }
  }

  Future<void> syncFixtures() async {
    state = const DataCollectionServiceState.syncing('Syncing fixtures...');
    try {
      await _service.syncFixtures();
      state = const DataCollectionServiceState.success('Fixtures synchronized');
    } catch (error) {
      state = DataCollectionServiceState.error(error.toString());
    }
  }

  Future<void> syncStandings() async {
    state = const DataCollectionServiceState.syncing('Syncing standings...');
    try {
      await _service.syncStandings();
      state = const DataCollectionServiceState.success('Standings synchronized');
    } catch (error) {
      state = DataCollectionServiceState.error(error.toString());
    }
  }

  Future<void> generateStatistics() async {
    state = const DataCollectionServiceState.syncing('Generating statistics...');
    try {
      await _service.generateStatistics();
      state = const DataCollectionServiceState.success('Statistics generated');
    } catch (error) {
      state = DataCollectionServiceState.error(error.toString());
    }
  }

  Future<void> cleanData() async {
    state = const DataCollectionServiceState.syncing('Cleaning data...');
    try {
      await _service.cleanData();
      state = const DataCollectionServiceState.success('Data cleaned');
    } catch (error) {
      state = DataCollectionServiceState.error(error.toString());
    }
  }

  Future<void> resetCache() async {
    state = const DataCollectionServiceState.syncing('Resetting cache...');
    try {
      await _service.resetCache();
      state = const DataCollectionServiceState.success('Cache reset');
    } catch (error) {
      state = DataCollectionServiceState.error(error.toString());
    }
  }

  Future<void> exportLogs() async {
    state = const DataCollectionServiceState.syncing('Exporting logs...');
    try {
      await _service.exportLogs();
      state = const DataCollectionServiceState.success('Logs exported');
    } catch (error) {
      state = DataCollectionServiceState.error(error.toString());
    }
  }

  void reset() {
    state = const DataCollectionServiceState.idle();
  }
}

/// Data Collection Service State
sealed class DataCollectionServiceState {
  const DataCollectionServiceState();

  const factory DataCollectionServiceState.idle() = _Idle;
  const factory DataCollectionServiceState.syncing(String message) = _Syncing;
  const factory DataCollectionServiceState.success(String message) = _Success;
  const factory DataCollectionServiceState.error(String message) = _Error;
}

class _Idle extends DataCollectionServiceState {
  const _Idle();
}

class _Syncing extends DataCollectionServiceState {
  final String message;
  const _Syncing(this.message);
}

class _Success extends DataCollectionServiceState {
  final String message;
  const _Success(this.message);
}

class _Error extends DataCollectionServiceState {
  final String message;
  const _Error(this.message);
}

/// Data Quality Provider
final dataQualityProvider = StateNotifierProvider<DataQualityNotifier, AsyncValue<DataQualityReport>>((ref) {
  final service = ref.watch(dataCollectionServiceProvider);
  return DataQualityNotifier(service);
});

class DataQualityNotifier extends StateNotifier<AsyncValue<DataQualityReport>> {
  final DataCollectionService _service;

  DataQualityNotifier(this._service) : super(const AsyncValue.loading());

  Future<void> generateQualityReport() async {
    state = const AsyncValue.loading();
    try {
      final report = await _generateQualityReport();
      state = AsyncValue.data(report);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<DataQualityReport> _generateQualityReport() async {
    // This would implement actual data quality checks
    // For now, return a sample report
    return DataQualityReport(
      totalRecords: 1000,
      duplicateRecords: 5,
      incompleteRecords: 12,
      invalidRecords: 3,
      lastChecked: DateTime.now(),
      qualityScore: 97.0,
      issues: [
        DataQualityIssue(
          type: 'duplicate',
          description: '5 duplicate team records found',
          severity: 'medium',
          affectedRecords: 5,
        ),
        DataQualityIssue(
          type: 'incomplete',
          description: '12 fixtures missing venue information',
          severity: 'low',
          affectedRecords: 12,
        ),
      ],
    );
  }
}

/// Data Quality Report
class DataQualityReport {
  final int totalRecords;
  final int duplicateRecords;
  final int incompleteRecords;
  final int invalidRecords;
  final DateTime lastChecked;
  final double qualityScore;
  final List<DataQualityIssue> issues;

  DataQualityReport({
    required this.totalRecords,
    required this.duplicateRecords,
    required this.incompleteRecords,
    required this.invalidRecords,
    required this.lastChecked,
    required this.qualityScore,
    required this.issues,
  });

  int get validRecords => totalRecords - duplicateRecords - incompleteRecords - invalidRecords;
  double get validPercentage => totalRecords > 0 ? (validRecords / totalRecords) * 100 : 0;
}

class DataQualityIssue {
  final String type;
  final String description;
  final String severity;
  final int affectedRecords;

  DataQualityIssue({
    required this.type,
    required this.description,
    required this.severity,
    required this.affectedRecords,
  });
}

/// Sync Schedule Provider
final syncScheduleProvider = StateNotifierProvider<SyncScheduleNotifier, List<ScheduledSyncItem>>((ref) {
  return SyncScheduleNotifier();
});

class SyncScheduleNotifier extends StateNotifier<List<ScheduledSyncItem>> {
  SyncScheduleNotifier() : super(_defaultSchedule);

  static final List<ScheduledSyncItem> _defaultSchedule = [
    ScheduledSyncItem(
      id: 'leagues_hourly',
      name: 'Leagues Sync',
      type: 'leagues',
      interval: const Duration(hours: 6),
      isEnabled: true,
      lastRun: null,
      nextRun: DateTime.now().add(const Duration(hours: 6)),
    ),
    ScheduledSyncItem(
      id: 'teams_daily',
      name: 'Teams Sync',
      type: 'teams',
      interval: const Duration(hours: 24),
      isEnabled: true,
      lastRun: null,
      nextRun: DateTime.now().add(const Duration(hours: 24)),
    ),
    ScheduledSyncItem(
      id: 'fixtures_frequent',
      name: 'Fixtures Sync',
      type: 'fixtures',
      interval: const Duration(minutes: 30),
      isEnabled: true,
      lastRun: null,
      nextRun: DateTime.now().add(const Duration(minutes: 30)),
    ),
    ScheduledSyncItem(
      id: 'standings_daily',
      name: 'Standings Sync',
      type: 'standings',
      interval: const Duration(hours: 12),
      isEnabled: true,
      lastRun: null,
      nextRun: DateTime.now().add(const Duration(hours: 12)),
    ),
  ];

  void toggleSync(String id) {
    state = state.map((item) {
      if (item.id == id) {
        return item.copyWith(isEnabled: !item.isEnabled);
      }
      return item;
    }).toList();
  }

  void updateInterval(String id, Duration newInterval) {
    state = state.map((item) {
      if (item.id == id) {
        return item.copyWith(
          interval: newInterval,
          nextRun: DateTime.now().add(newInterval),
        );
      }
      return item;
    }).toList();
  }

  void markAsRun(String id) {
    state = state.map((item) {
      if (item.id == id) {
        final now = DateTime.now();
        return item.copyWith(
          lastRun: now,
          nextRun: now.add(item.interval),
        );
      }
      return item;
    }).toList();
  }
}

class ScheduledSyncItem {
  final String id;
  final String name;
  final String type;
  final Duration interval;
  final bool isEnabled;
  final DateTime? lastRun;
  final DateTime? nextRun;

  ScheduledSyncItem({
    required this.id,
    required this.name,
    required this.type,
    required this.interval,
    required this.isEnabled,
    this.lastRun,
    this.nextRun,
  });

  ScheduledSyncItem copyWith({
    String? id,
    String? name,
    String? type,
    Duration? interval,
    bool? isEnabled,
    DateTime? lastRun,
    DateTime? nextRun,
  }) {
    return ScheduledSyncItem(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      interval: interval ?? this.interval,
      isEnabled: isEnabled ?? this.isEnabled,
      lastRun: lastRun ?? this.lastRun,
      nextRun: nextRun ?? this.nextRun,
    );
  }

  String get intervalDisplay {
    if (interval.inDays > 0) {
      return '${interval.inDays} day${interval.inDays > 1 ? 's' : ''}';
    } else if (interval.inHours > 0) {
      return '${interval.inHours} hour${interval.inHours > 1 ? 's' : ''}';
    } else {
      return '${interval.inMinutes} minute${interval.inMinutes > 1 ? 's' : ''}';
    }
  }

  bool get isDue {
    if (!isEnabled || nextRun == null) return false;
    return DateTime.now().isAfter(nextRun!);
  }
}