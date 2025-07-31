import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/database_browser_service.dart';

/// Database statistics provider
final databaseStatsProvider = StateNotifierProvider<DatabaseStatsNotifier, AsyncValue<DatabaseStats>>((ref) {
  final service = ref.watch(databaseBrowserServiceProvider);
  return DatabaseStatsNotifier(service);
});

class DatabaseStatsNotifier extends StateNotifier<AsyncValue<DatabaseStats>> {
  final DatabaseBrowserService _service;

  DatabaseStatsNotifier(this._service) : super(const AsyncValue.loading());

  Future<void> loadStats() async {
    state = const AsyncValue.loading();
    try {
      final stats = await _service.getDatabaseStats();
      state = AsyncValue.data(stats);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}

/// Table names provider
final tableNamesProvider = StateNotifierProvider<TableNamesNotifier, AsyncValue<List<String>>>((ref) {
  final service = ref.watch(databaseBrowserServiceProvider);
  return TableNamesNotifier(service);
});

class TableNamesNotifier extends StateNotifier<AsyncValue<List<String>>> {
  final DatabaseBrowserService _service;

  TableNamesNotifier(this._service) : super(const AsyncValue.loading());

  Future<void> loadTableNames() async {
    state = const AsyncValue.loading();
    try {
      final tableNames = await _service.getTableNames();
      state = AsyncValue.data(tableNames);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}

/// Table schema provider
final tableSchemaProvider = StateNotifierProvider.family<TableSchemaNotifier, AsyncValue<TableSchema>, String>((ref, tableName) {
  final service = ref.watch(databaseBrowserServiceProvider);
  return TableSchemaNotifier(service, tableName);
});

class TableSchemaNotifier extends StateNotifier<AsyncValue<TableSchema>> {
  final DatabaseBrowserService _service;
  final String _tableName;

  TableSchemaNotifier(this._service, this._tableName) : super(const AsyncValue.loading()) {
    loadSchema();
  }

  Future<void> loadSchema() async {
    state = const AsyncValue.loading();
    try {
      final schema = await _service.getTableSchema(_tableName);
      state = AsyncValue.data(schema);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}

/// Table data provider with pagination
final tableDataProvider = StateNotifierProvider.family<TableDataNotifier, AsyncValue<QueryResult>, TableDataParams>((ref, params) {
  final service = ref.watch(databaseBrowserServiceProvider);
  return TableDataNotifier(service, params);
});

class TableDataNotifier extends StateNotifier<AsyncValue<QueryResult>> {
  final DatabaseBrowserService _service;
  final TableDataParams _params;

  TableDataNotifier(this._service, this._params) : super(const AsyncValue.loading()) {
    loadData();
  }

  Future<void> loadData() async {
    state = const AsyncValue.loading();
    try {
      final result = await _service.getTableData(
        _params.tableName,
        page: _params.page,
        pageSize: _params.pageSize,
        orderBy: _params.orderBy,
        where: _params.where,
        whereArgs: _params.whereArgs,
      );
      state = AsyncValue.data(result);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> nextPage() async {
    final newParams = _params.copyWith(page: _params.page + 1);
    final notifier = TableDataNotifier(_service, newParams);
    await notifier.loadData();
    state = notifier.state;
  }

  Future<void> previousPage() async {
    if (_params.page > 1) {
      final newParams = _params.copyWith(page: _params.page - 1);
      final notifier = TableDataNotifier(_service, newParams);
      await notifier.loadData();
      state = notifier.state;
    }
  }
}

class TableDataParams {
  final String tableName;
  final int page;
  final int pageSize;
  final String? orderBy;
  final String? where;
  final List<dynamic>? whereArgs;

  const TableDataParams({
    required this.tableName,
    this.page = 1,
    this.pageSize = 50,
    this.orderBy,
    this.where,
    this.whereArgs,
  });

  TableDataParams copyWith({
    String? tableName,
    int? page,
    int? pageSize,
    String? orderBy,
    String? where,
    List<dynamic>? whereArgs,
  }) {
    return TableDataParams(
      tableName: tableName ?? this.tableName,
      page: page ?? this.page,
      pageSize: pageSize ?? this.pageSize,
      orderBy: orderBy ?? this.orderBy,
      where: where ?? this.where,
      whereArgs: whereArgs ?? this.whereArgs,
    );
  }
}

/// Query executor provider
final queryExecutorProvider = StateNotifierProvider<QueryExecutorNotifier, QueryExecutorState>((ref) {
  final service = ref.watch(databaseBrowserServiceProvider);
  return QueryExecutorNotifier(service);
});

class QueryExecutorNotifier extends StateNotifier<QueryExecutorState> {
  final DatabaseBrowserService _service;

  QueryExecutorNotifier(this._service) : super(const QueryExecutorState.initial());

  Future<void> executeQuery(String sql, {List<dynamic>? parameters}) async {
    state = const QueryExecutorState.loading();
    try {
      final result = await _service.executeQuery(sql, parameters: parameters);
      
      // Log the query execution
      await _service.logActivity(
        action: 'query',
        entityType: 'sql',
        details: sql,
      );
      
      state = QueryExecutorState.success(result);
    } catch (error, stackTrace) {
      state = QueryExecutorState.error(error.toString());
    }
  }

  Future<void> executeModification(String sql, {List<dynamic>? parameters}) async {
    state = const QueryExecutorState.loading();
    try {
      final result = await _service.executeModification(sql, parameters);
      
      // Log the modification
      await _service.logActivity(
        action: result.sql.trim().split(' ').first.toLowerCase(),
        entityType: 'sql',
        details: sql,
      );
      
      state = QueryExecutorState.modification(result);
    } catch (error, stackTrace) {
      state = QueryExecutorState.error(error.toString());
    }
  }

  void reset() {
    state = const QueryExecutorState.initial();
  }
}

/// Query executor state
sealed class QueryExecutorState {
  const QueryExecutorState();

  const factory QueryExecutorState.initial() = _Initial;
  const factory QueryExecutorState.loading() = _Loading;
  const factory QueryExecutorState.success(QueryResult result) = _Success;
  const factory QueryExecutorState.modification(ModificationResult result) = _Modification;
  const factory QueryExecutorState.error(String message) = _Error;
}

class _Initial extends QueryExecutorState {
  const _Initial();
}

class _Loading extends QueryExecutorState {
  const _Loading();
}

class _Success extends QueryExecutorState {
  final QueryResult result;
  const _Success(this.result);
}

class _Modification extends QueryExecutorState {
  final ModificationResult result;
  const _Modification(this.result);
}

class _Error extends QueryExecutorState {
  final String message;
  const _Error(this.message);
}

/// Recent activity provider
final recentActivityProvider = StateNotifierProvider<RecentActivityNotifier, AsyncValue<List<Map<String, dynamic>>>>((ref) {
  final service = ref.watch(databaseBrowserServiceProvider);
  return RecentActivityNotifier(service);
});

class RecentActivityNotifier extends StateNotifier<AsyncValue<List<Map<String, dynamic>>>> {
  final DatabaseBrowserService _service;

  RecentActivityNotifier(this._service) : super(const AsyncValue.loading()) {
    loadActivity();
  }

  Future<void> loadActivity({int limit = 100}) async {
    state = const AsyncValue.loading();
    try {
      final activities = await _service.getRecentActivity(limit: limit);
      state = AsyncValue.data(activities);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}

/// Database export provider
final databaseExportProvider = StateNotifierProvider<DatabaseExportNotifier, DatabaseExportState>((ref) {
  final service = ref.watch(databaseBrowserServiceProvider);
  return DatabaseExportNotifier(service);
});

class DatabaseExportNotifier extends StateNotifier<DatabaseExportState> {
  final DatabaseBrowserService _service;

  DatabaseExportNotifier(this._service) : super(const DatabaseExportState.initial());

  Future<void> exportTable(String tableName, {String? where, List<dynamic>? whereArgs}) async {
    state = const DatabaseExportState.loading();
    try {
      final csvData = await _service.exportTableToCsv(tableName, where: where, whereArgs: whereArgs);
      
      // Log the export
      await _service.logActivity(
        action: 'export',
        entityType: 'table',
        entityId: null,
        details: 'Exported table: $tableName',
      );
      
      state = DatabaseExportState.success(csvData, '$tableName.csv');
    } catch (error, stackTrace) {
      state = DatabaseExportState.error(error.toString());
    }
  }

  Future<void> exportQuery(String sql, {List<dynamic>? parameters}) async {
    state = const DatabaseExportState.loading();
    try {
      final csvData = await _service.exportQueryToCsv(sql, parameters: parameters);
      
      // Log the export
      await _service.logActivity(
        action: 'export',
        entityType: 'query',
        details: 'Exported query result',
      );
      
      state = DatabaseExportState.success(csvData, 'query_result.csv');
    } catch (error, stackTrace) {
      state = DatabaseExportState.error(error.toString());
    }
  }

  void reset() {
    state = const DatabaseExportState.initial();
  }
}

/// Database export state
sealed class DatabaseExportState {
  const DatabaseExportState();

  const factory DatabaseExportState.initial() = _ExportInitial;
  const factory DatabaseExportState.loading() = _ExportLoading;
  const factory DatabaseExportState.success(String csvData, String filename) = _ExportSuccess;
  const factory DatabaseExportState.error(String message) = _ExportError;
}

class _ExportInitial extends DatabaseExportState {
  const _ExportInitial();
}

class _ExportLoading extends DatabaseExportState {
  const _ExportLoading();
}

class _ExportSuccess extends DatabaseExportState {
  final String csvData;
  final String filename;
  const _ExportSuccess(this.csvData, this.filename);
}

class _ExportError extends DatabaseExportState {
  final String message;
  const _ExportError(this.message);
}