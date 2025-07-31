import 'package:freezed_annotation/freezed_annotation.dart';

part 'database_schema_model.freezed.dart';
part 'database_schema_model.g.dart';

@freezed
class DatabaseSchemaModel with _$DatabaseSchemaModel {
  const factory DatabaseSchemaModel({
    required String name,
    required int version,
    required List<TableSchema> tables,
    required List<IndexSchema> indexes,
    required List<ViewSchema> views,
    @Default([]) List<TriggerSchema> triggers,
    @Default([]) List<ForeignKeySchema> foreignKeys,
    DateTime? createdAt,
    DateTime? lastMigration,
    @Default({}) Map<String, String> metadata,
  }) = _DatabaseSchemaModel;

  factory DatabaseSchemaModel.fromJson(Map<String, dynamic> json) =>
      _$DatabaseSchemaModelFromJson(json);
}

@freezed
class TableSchema with _$TableSchema {
  const factory TableSchema({
    required String name,
    required List<ColumnSchema> columns,
    String? primaryKey,
    @Default([]) List<String> uniqueConstraints,
    @Default([]) List<String> checkConstraints,
    @Default(false) bool temporary,
    String? comment,
    DateTime? createdAt,
    DateTime? lastModified,
  }) = _TableSchema;

  factory TableSchema.fromJson(Map<String, dynamic> json) =>
      _$TableSchemaFromJson(json);
}

@freezed
class ColumnSchema with _$ColumnSchema {
  const factory ColumnSchema({
    required String name,
    required SqliteDataType type,
    @Default(false) bool nullable,
    String? defaultValue,
    @Default(false) bool primaryKey,
    @Default(false) bool autoIncrement,
    @Default(false) bool unique,
    String? foreignKeyTable,
    String? foreignKeyColumn,
    String? checkConstraint,
    String? comment,
    int? maxLength,
    int? precision,
    int? scale,
  }) = _ColumnSchema;

  factory ColumnSchema.fromJson(Map<String, dynamic> json) =>
      _$ColumnSchemaFromJson(json);
}

@freezed
class IndexSchema with _$IndexSchema {
  const factory IndexSchema({
    required String name,
    required String tableName,
    required List<String> columns,
    @Default(false) bool unique,
    @Default(false) bool partial,
    String? whereClause,
    String? comment,
  }) = _IndexSchema;

  factory IndexSchema.fromJson(Map<String, dynamic> json) =>
      _$IndexSchemaFromJson(json);
}

@freezed
class ViewSchema with _$ViewSchema {
  const factory ViewSchema({
    required String name,
    required String definition,
    @Default([]) List<String> dependencies,
    String? comment,
    DateTime? createdAt,
    DateTime? lastModified,
  }) = _ViewSchema;

  factory ViewSchema.fromJson(Map<String, dynamic> json) =>
      _$ViewSchemaFromJson(json);
}

@freezed
class TriggerSchema with _$TriggerSchema {
  const factory TriggerSchema({
    required String name,
    required String tableName,
    required TriggerEvent event,
    required TriggerTiming timing,
    required String definition,
    String? condition,
    String? comment,
  }) = _TriggerSchema;

  factory TriggerSchema.fromJson(Map<String, dynamic> json) =>
      _$TriggerSchemaFromJson(json);
}

@freezed
class ForeignKeySchema with _$ForeignKeySchema {
  const factory ForeignKeySchema({
    required String name,
    required String fromTable,
    required String fromColumn,
    required String toTable,
    required String toColumn,
    @Default(ForeignKeyAction.noAction) ForeignKeyAction onDelete,
    @Default(ForeignKeyAction.noAction) ForeignKeyAction onUpdate,
    @Default(false) bool deferrable,
  }) = _ForeignKeySchema;

  factory ForeignKeySchema.fromJson(Map<String, dynamic> json) =>
      _$ForeignKeySchemaFromJson(json);
}

@freezed
class DatabaseMigrationModel with _$DatabaseMigrationModel {
  const factory DatabaseMigrationModel({
    required int fromVersion,
    required int toVersion,
    required List<MigrationStep> steps,
    DateTime? executedAt,
    @Default(false) bool rollbackable,
    String? description,
  }) = _DatabaseMigrationModel;

  factory DatabaseMigrationModel.fromJson(Map<String, dynamic> json) =>
      _$DatabaseMigrationModelFromJson(json);
}

@freezed
class MigrationStep with _$MigrationStep {
  const factory MigrationStep({
    required MigrationOperation operation,
    required String sql,
    String? description,
    @Default(false) bool reversible,
    String? rollbackSql,
  }) = _MigrationStep;

  factory MigrationStep.fromJson(Map<String, dynamic> json) =>
      _$MigrationStepFromJson(json);
}

@freezed
class DatabaseStatisticsModel with _$DatabaseStatisticsModel {
  const factory DatabaseStatisticsModel({
    required String databaseName,
    @Default(0) int totalTables,
    @Default(0) int totalViews,
    @Default(0) int totalIndexes,
    @Default(0) int totalTriggers,
    @Default(0) int totalRecords,
    @Default(0) int databaseSize,
    @Default(0) int freeSpace,
    @Default(0) int pageSize,
    @Default(0) int pageCount,
    @Default([]) List<TableStatistics> tableStats,
    DateTime? lastAnalyzed,
    DatabaseHealth? health,
  }) = _DatabaseStatisticsModel;

  factory DatabaseStatisticsModel.fromJson(Map<String, dynamic> json) =>
      _$DatabaseStatisticsModelFromJson(json);
}

@freezed
class TableStatistics with _$TableStatistics {
  const factory TableStatistics({
    required String tableName,
    @Default(0) int rowCount,
    @Default(0) int sizeInBytes,
    @Default(0) int indexCount,
    @Default(0) int indexSizeInBytes,
    @Default(0.0) double averageRowSize,
    @Default(0.0) double fragmentationLevel,
    DateTime? lastUpdated,
  }) = _TableStatistics;

  factory TableStatistics.fromJson(Map<String, dynamic> json) =>
      _$TableStatisticsFromJson(json);
}

@freezed
class DatabaseHealth with _$DatabaseHealth {
  const factory DatabaseHealth({
    required HealthStatus status,
    @Default(0.0) double score,
    @Default([]) List<String> issues,
    @Default([]) List<String> recommendations,
    @Default([]) List<PerformanceMetric> performanceMetrics,
    DateTime? lastCheck,
  }) = _DatabaseHealth;

  factory DatabaseHealth.fromJson(Map<String, dynamic> json) =>
      _$DatabaseHealthFromJson(json);
}

@freezed
class PerformanceMetric with _$PerformanceMetric {
  const factory PerformanceMetric({
    required String name,
    @Default(0.0) double value,
    String? unit,
    required MetricStatus status,
    String? description,
  }) = _PerformanceMetric;

  factory PerformanceMetric.fromJson(Map<String, dynamic> json) =>
      _$PerformanceMetricFromJson(json);
}

@freezed
class DatabaseBackupModel with _$DatabaseBackupModel {
  const factory DatabaseBackupModel({
    required String id,
    required String databaseName,
    required String filePath,
    @Default(0) int sizeInBytes,
    required BackupType type,
    DateTime? createdAt,
    String? description,
    @Default(false) bool compressed,
    @Default(false) bool encrypted,
    String? checksum,
    @Default({}) Map<String, dynamic> metadata,
  }) = _DatabaseBackupModel;

  factory DatabaseBackupModel.fromJson(Map<String, dynamic> json) =>
      _$DatabaseBackupModelFromJson(json);
}

enum SqliteDataType {
  integer,
  real,
  text,
  blob,
  numeric,
}

enum TriggerEvent {
  insert,
  update,
  delete,
}

enum TriggerTiming {
  before,
  after,
  instead,
}

enum ForeignKeyAction {
  noAction,
  restrict,
  setNull,
  setDefault,
  cascade,
}

enum MigrationOperation {
  createTable,
  dropTable,
  alterTable,
  createIndex,
  dropIndex,
  createView,
  dropView,
  createTrigger,
  dropTrigger,
  insertData,
  updateData,
  deleteData,
  custom,
}

enum HealthStatus {
  excellent,
  good,
  fair,
  poor,
  critical,
}

enum MetricStatus {
  optimal,
  acceptable,
  warning,
  critical,
}

enum BackupType {
  full,
  incremental,
  schema,
}

extension SqliteDataTypeX on SqliteDataType {
  String get sqlName {
    switch (this) {
      case SqliteDataType.integer:
        return 'INTEGER';
      case SqliteDataType.real:
        return 'REAL';
      case SqliteDataType.text:
        return 'TEXT';
      case SqliteDataType.blob:
        return 'BLOB';
      case SqliteDataType.numeric:
        return 'NUMERIC';
    }
  }

  String get displayName {
    switch (this) {
      case SqliteDataType.integer:
        return 'Integer';
      case SqliteDataType.real:
        return 'Real';
      case SqliteDataType.text:
        return 'Text';
      case SqliteDataType.blob:
        return 'Blob';
      case SqliteDataType.numeric:
        return 'Numeric';
    }
  }
}

extension TriggerEventX on TriggerEvent {
  String get sqlName {
    switch (this) {
      case TriggerEvent.insert:
        return 'INSERT';
      case TriggerEvent.update:
        return 'UPDATE';
      case TriggerEvent.delete:
        return 'DELETE';
    }
  }
}

extension TriggerTimingX on TriggerTiming {
  String get sqlName {
    switch (this) {
      case TriggerTiming.before:
        return 'BEFORE';
      case TriggerTiming.after:
        return 'AFTER';
      case TriggerTiming.instead:
        return 'INSTEAD OF';
    }
  }
}

extension ForeignKeyActionX on ForeignKeyAction {
  String get sqlName {
    switch (this) {
      case ForeignKeyAction.noAction:
        return 'NO ACTION';
      case ForeignKeyAction.restrict:
        return 'RESTRICT';
      case ForeignKeyAction.setNull:
        return 'SET NULL';
      case ForeignKeyAction.setDefault:
        return 'SET DEFAULT';
      case ForeignKeyAction.cascade:
        return 'CASCADE';
    }
  }
}

extension HealthStatusX on HealthStatus {
  String get displayName {
    switch (this) {
      case HealthStatus.excellent:
        return 'Excellent';
      case HealthStatus.good:
        return 'Good';
      case HealthStatus.fair:
        return 'Fair';
      case HealthStatus.poor:
        return 'Poor';
      case HealthStatus.critical:
        return 'Critical';
    }
  }

  String get icon {
    switch (this) {
      case HealthStatus.excellent:
        return '🟢';
      case HealthStatus.good:
        return '🔵';
      case HealthStatus.fair:
        return '🟡';
      case HealthStatus.poor:
        return '🟠';
      case HealthStatus.critical:
        return '🔴';
    }
  }

  double get scoreThreshold {
    switch (this) {
      case HealthStatus.excellent:
        return 90.0;
      case HealthStatus.good:
        return 75.0;
      case HealthStatus.fair:
        return 60.0;
      case HealthStatus.poor:
        return 40.0;
      case HealthStatus.critical:
        return 0.0;
    }
  }
}

extension DatabaseSchemaModelX on DatabaseSchemaModel {
  int get totalColumns => tables.fold(0, (sum, table) => sum + table.columns.length);
  
  List<String> get tableNames => tables.map((table) => table.name).toList();
  
  List<String> get viewNames => views.map((view) => view.name).toList();
  
  TableSchema? getTable(String name) {
    try {
      return tables.firstWhere((table) => table.name == name);
    } catch (e) {
      return null;
    }
  }
  
  ViewSchema? getView(String name) {
    try {
      return views.firstWhere((view) => view.name == name);
    } catch (e) {
      return null;
    }
  }

  List<IndexSchema> getTableIndexes(String tableName) {
    return indexes.where((index) => index.tableName == tableName).toList();
  }

  List<ForeignKeySchema> getTableForeignKeys(String tableName) {
    return foreignKeys.where((fk) => fk.fromTable == tableName).toList();
  }

  bool hasTable(String name) => tables.any((table) => table.name == name);
  
  bool hasView(String name) => views.any((view) => view.name == name);

  String generateCreateTableSql(String tableName) {
    final table = getTable(tableName);
    if (table == null) return '';

    final buffer = StringBuffer();
    buffer.write('CREATE TABLE ${table.name} (\n');
    
    final columnDefs = table.columns.map((col) {
      final parts = <String>[
        '  ${col.name}',
        col.type.sqlName,
      ];
      
      if (col.primaryKey) parts.add('PRIMARY KEY');
      if (col.autoIncrement) parts.add('AUTOINCREMENT');
      if (!col.nullable) parts.add('NOT NULL');
      if (col.unique) parts.add('UNIQUE');
      if (col.defaultValue != null) parts.add('DEFAULT ${col.defaultValue}');
      
      return parts.join(' ');
    }).toList();
    
    buffer.write(columnDefs.join(',\n'));
    buffer.write('\n);');
    
    return buffer.toString();
  }

  List<String> generateAllCreateSql() {
    final sqlStatements = <String>[];
    
    // Create tables
    for (final table in tables) {
      sqlStatements.add(generateCreateTableSql(table.name));
    }
    
    // Create indexes
    for (final index in indexes) {
      final uniqueClause = index.unique ? 'UNIQUE ' : '';
      final columnsClause = index.columns.join(', ');
      final whereClause = index.whereClause != null ? ' WHERE ${index.whereClause}' : '';
      
      sqlStatements.add(
        'CREATE ${uniqueClause}INDEX ${index.name} ON ${index.tableName} ($columnsClause)$whereClause;'
      );
    }
    
    // Create views
    for (final view in views) {
      sqlStatements.add('CREATE VIEW ${view.name} AS ${view.definition};');
    }
    
    // Create triggers
    for (final trigger in triggers) {
      final conditionClause = trigger.condition != null ? ' WHEN ${trigger.condition}' : '';
      sqlStatements.add(
        'CREATE TRIGGER ${trigger.name} ${trigger.timing.sqlName} ${trigger.event.sqlName} ON ${trigger.tableName}$conditionClause BEGIN ${trigger.definition} END;'
      );
    }
    
    return sqlStatements;
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'version': version,
      'tables': tables.map((t) => t.toJson()).toList(),
      'indexes': indexes.map((i) => i.toJson()).toList(),
      'views': views.map((v) => v.toJson()).toList(),
      'triggers': triggers.map((t) => t.toJson()).toList(),
      'foreignKeys': foreignKeys.map((fk) => fk.toJson()).toList(),
      'createdAt': createdAt?.millisecondsSinceEpoch,
      'lastMigration': lastMigration?.millisecondsSinceEpoch,
      'metadata': metadata,
    };
  }

  static DatabaseSchemaModel fromFirestore(Map<String, dynamic> data) {
    return DatabaseSchemaModel(
      name: data['name'],
      version: data['version'],
      tables: (data['tables'] as List<dynamic>)
          .map((t) => TableSchema.fromJson(t))
          .toList(),
      indexes: (data['indexes'] as List<dynamic>)
          .map((i) => IndexSchema.fromJson(i))
          .toList(),
      views: (data['views'] as List<dynamic>)
          .map((v) => ViewSchema.fromJson(v))
          .toList(),
      triggers: (data['triggers'] as List<dynamic>?)
              ?.map((t) => TriggerSchema.fromJson(t))
              .toList() ??
          [],
      foreignKeys: (data['foreignKeys'] as List<dynamic>?)
              ?.map((fk) => ForeignKeySchema.fromJson(fk))
              .toList() ??
          [],
      createdAt: data['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(data['createdAt'])
          : null,
      lastMigration: data['lastMigration'] != null
          ? DateTime.fromMillisecondsSinceEpoch(data['lastMigration'])
          : null,
      metadata: Map<String, String>.from(data['metadata'] ?? {}),
    );
  }
}

extension DatabaseStatisticsModelX on DatabaseStatisticsModel {
  double get utilizationPercentage {
    if (databaseSize == 0) return 0.0;
    return ((databaseSize - freeSpace) / databaseSize) * 100;
  }

  double get averageTableSize {
    if (totalTables == 0) return 0.0;
    final totalTableSize = tableStats.fold<int>(0, (sum, stat) => sum + stat.sizeInBytes);
    return totalTableSize / totalTables;
  }

  String get sizeDisplay {
    if (databaseSize < 1024) return '${databaseSize}B';
    if (databaseSize < 1024 * 1024) return '${(databaseSize / 1024).toStringAsFixed(1)}KB';
    if (databaseSize < 1024 * 1024 * 1024) return '${(databaseSize / (1024 * 1024)).toStringAsFixed(1)}MB';
    return '${(databaseSize / (1024 * 1024 * 1024)).toStringAsFixed(1)}GB';
  }

  bool get needsOptimization => 
      health?.status == HealthStatus.poor || 
      health?.status == HealthStatus.critical ||
      utilizationPercentage > 90.0;

  Map<String, dynamic> toFirestore() {
    return {
      'databaseName': databaseName,
      'totalTables': totalTables,
      'totalViews': totalViews,
      'totalIndexes': totalIndexes,
      'totalTriggers': totalTriggers,
      'totalRecords': totalRecords,
      'databaseSize': databaseSize,
      'freeSpace': freeSpace,
      'pageSize': pageSize,
      'pageCount': pageCount,
      'tableStats': tableStats.map((ts) => ts.toJson()).toList(),
      'lastAnalyzed': lastAnalyzed?.millisecondsSinceEpoch,
      'health': health?.toJson(),
    };
  }

  static DatabaseStatisticsModel fromFirestore(Map<String, dynamic> data) {
    return DatabaseStatisticsModel(
      databaseName: data['databaseName'],
      totalTables: data['totalTables'] ?? 0,
      totalViews: data['totalViews'] ?? 0,
      totalIndexes: data['totalIndexes'] ?? 0,
      totalTriggers: data['totalTriggers'] ?? 0,
      totalRecords: data['totalRecords'] ?? 0,
      databaseSize: data['databaseSize'] ?? 0,
      freeSpace: data['freeSpace'] ?? 0,
      pageSize: data['pageSize'] ?? 0,
      pageCount: data['pageCount'] ?? 0,
      tableStats: (data['tableStats'] as List<dynamic>?)
              ?.map((ts) => TableStatistics.fromJson(ts))
              .toList() ??
          [],
      lastAnalyzed: data['lastAnalyzed'] != null
          ? DateTime.fromMillisecondsSinceEpoch(data['lastAnalyzed'])
          : null,
      health: data['health'] != null
          ? DatabaseHealth.fromJson(data['health'])
          : null,
    );
  }
}