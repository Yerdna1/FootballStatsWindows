import 'package:freezed_annotation/freezed_annotation.dart';

part 'export_data_model.freezed.dart';
part 'export_data_model.g.dart';

@freezed
class ExportDataModel with _$ExportDataModel {
  const factory ExportDataModel({
    required String id,
    required String title,
    required String description,
    required ExportType type,
    required ExportFormat format,
    required List<DataSource> dataSources,
    required ExportConfiguration configuration,
    @Default([]) List<ExportColumn> columns,
    @Default([]) List<FilterCriteria> filters,
    @Default([]) List<SortCriteria> sorting,
    DateTime? createdAt,
    DateTime? lastExported,
    String? filePath,
    @Default(0) int recordCount,
    @Default(0) int fileSizeBytes,
    ExportStatus? status,
    String? errorMessage,
    @Default({}) Map<String, dynamic> metadata,
  }) = _ExportDataModel;

  factory ExportDataModel.fromJson(Map<String, dynamic> json) =>
      _$ExportDataModelFromJson(json);
}

@freezed
class DataSource with _$DataSource {
  const factory DataSource({
    required String name,
    required String table,
    String? alias,
    @Default([]) List<String> fields,
    @Default([]) List<JoinDefinition> joins,
    String? whereClause,
    String? groupBy,
    String? having,
  }) = _DataSource;

  factory DataSource.fromJson(Map<String, dynamic> json) =>
      _$DataSourceFromJson(json);
}

@freezed
class ExportConfiguration with _$ExportConfiguration {
  const factory ExportConfiguration({
    @Default(true) bool includeHeaders,
    @Default(true) bool includeMetadata,
    @Default(false) bool includeTimestamp,
    @Default(1000) int maxRecords,
    String? dateFormat,
    String? numberFormat,
    String? delimiter,
    String? encoding,
    @Default(false) bool compressOutput,
    @Default(false) bool encryptOutput,
    String? password,
    @Default({}) Map<String, String> customSettings,
  }) = _ExportConfiguration;

  factory ExportConfiguration.fromJson(Map<String, dynamic> json) =>
      _$ExportConfigurationFromJson(json);
}

@freezed
class ExportColumn with _$ExportColumn {
  const factory ExportColumn({
    required String name,
    required String displayName,
    required ColumnDataType dataType,
    required String sourceField,
    @Default(true) bool visible,
    @Default(0) int order,
    String? format,
    String? aggregation,
    ColumnAlignment? alignment,
    @Default(0) int width,
    String? description,
    @Default(false) bool calculated,
    String? formula,
  }) = _ExportColumn;

  factory ExportColumn.fromJson(Map<String, dynamic> json) =>
      _$ExportColumnFromJson(json);
}

@freezed
class FilterCriteria with _$FilterCriteria {
  const factory FilterCriteria({
    required String field,
    required FilterOperator operator,
    required String value,
    String? value2,
    @Default(LogicalOperator.and) LogicalOperator logicalOperator,
    @Default(false) bool caseSensitive,
  }) = _FilterCriteria;

  factory FilterCriteria.fromJson(Map<String, dynamic> json) =>
      _$FilterCriteriaFromJson(json);
}

@freezed
class SortCriteria with _$SortCriteria {
  const factory SortCriteria({
    required String field,
    @Default(SortDirection.ascending) SortDirection direction,
    @Default(0) int priority,
  }) = _SortCriteria;

  factory SortCriteria.fromJson(Map<String, dynamic> json) =>
      _$SortCriteriaFromJson(json);
}

@freezed
class JoinDefinition with _$JoinDefinition {
  const factory JoinDefinition({
    required String table,
    required JoinType type,
    required String onClause,
    String? alias,
  }) = _JoinDefinition;

  factory JoinDefinition.fromJson(Map<String, dynamic> json) =>
      _$JoinDefinitionFromJson(json);
}

@freezed
class ExportTemplateModel with _$ExportTemplateModel {
  const factory ExportTemplateModel({
    required String id,
    required String name,
    required String description,
    required ExportType category,
    required ExportDataModel template,
    @Default(false) bool isDefault,
    @Default(false) bool isSystem,
    DateTime? createdAt,
    DateTime? lastModified,
    String? createdBy,
    @Default(0) int usageCount,
    @Default([]) List<String> tags,
  }) = _ExportTemplateModel;

  factory ExportTemplateModel.fromJson(Map<String, dynamic> json) =>
      _$ExportTemplateModelFromJson(json);
}

@freezed
class ExportJobModel with _$ExportJobModel {
  const factory ExportJobModel({
    required String id,
    required String templateId,
    required String userId,
    required ExportJobStatus status,
    DateTime? startedAt,
    DateTime? completedAt,
    @Default(0) int progress,
    @Default(0) int totalRecords,
    @Default(0) int processedRecords,
    String? outputPath,
    @Default(0) int fileSizeBytes,
    String? errorMessage,
    @Default([]) List<String> warnings,
    @Default({}) Map<String, dynamic> parameters,
    Duration? duration,
  }) = _ExportJobModel;

  factory ExportJobModel.fromJson(Map<String, dynamic> json) =>
      _$ExportJobModelFromJson(json);
}

@freezed
class PdfExportOptions with _$PdfExportOptions {
  const factory PdfExportOptions({
    @Default(PdfPageSize.a4) PdfPageSize pageSize,
    @Default(PdfOrientation.portrait) PdfOrientation orientation,
    @Default(PdfMargins(20, 20, 20, 20)) PdfMargins margins,
    String? headerText,
    String? footerText,
    @Default(true) bool includePageNumbers,
    @Default(true) bool includeDate,
    String? logoPath,
    @Default(12.0) double fontSize,
    String? fontFamily,
    @Default(true) bool fitToPage,
    @Default(false) bool landscape,
    @Default({}) Map<String, String> customFields,
  }) = _PdfExportOptions;

  factory PdfExportOptions.fromJson(Map<String, dynamic> json) =>
      _$PdfExportOptionsFromJson(json);
}

@freezed
class PdfMargins with _$PdfMargins {
  const factory PdfMargins(
    double top,
    double right,
    double bottom,
    double left,
  ) = _PdfMargins;

  factory PdfMargins.fromJson(Map<String, dynamic> json) =>
      _$PdfMarginsFromJson(json);
}

@freezed
class CsvExportOptions with _$CsvExportOptions {
  const factory CsvExportOptions({
    @Default(',') String delimiter,
    @Default('"') String textQualifier,
    @Default('\n') String lineTerminator,
    @Default('UTF-8') String encoding,
    @Default(true) bool includeHeaders,
    @Default(false) bool includeBOM,
    @Default(false) bool escapeFormulas,
    @Default([]) List<String> nullValues,
  }) = _CsvExportOptions;

  factory CsvExportOptions.fromJson(Map<String, dynamic> json) =>
      _$CsvExportOptionsFromJson(json);
}

@freezed
class ExcelExportOptions with _$ExcelExportOptions {
  const factory ExcelExportOptions({
    required String sheetName,
    @Default(true) bool includeHeaders,
    @Default(true) bool autoFitColumns,
    @Default(true) bool freezeHeaders,
    @Default(false) bool includeFormulas,
    @Default(false) bool includeCharts,
    String? templatePath,
    @Default({}) Map<String, String> cellFormats,
    @Default([]) List<String> protectedSheets,
  }) = _ExcelExportOptions;

  factory ExcelExportOptions.fromJson(Map<String, dynamic> json) =>
      _$ExcelExportOptionsFromJson(json);
}

enum ExportType {
  fixtures,
  standings,
  statistics,
  teams,
  players,
  form,
  predictions,
  custom,
}

enum ExportFormat {
  csv,
  excel,
  pdf,
  json,
  xml,
}

enum ExportStatus {
  pending,
  inProgress,
  completed,
  failed,
  cancelled,
}

enum ExportJobStatus {
  queued,
  running,
  completed,
  failed,
  cancelled,
}

enum ColumnDataType {
  text,
  number,
  date,
  boolean,
  decimal,
}

enum ColumnAlignment {
  left,
  center,
  right,
}

enum FilterOperator {
  equals,
  notEquals,
  contains,
  notContains,
  startsWith,
  endsWith,
  greaterThan,
  greaterThanOrEqual,
  lessThan,
  lessThanOrEqual,
  between,
  in_,
  notIn,
  isNull,
  isNotNull,
}

enum LogicalOperator {
  and,
  or,
}

enum SortDirection {
  ascending,
  descending,
}

enum JoinType {
  inner,
  left,
  right,
  full,
}

enum PdfPageSize {
  a3,
  a4,
  a5,
  letter,
  legal,
  tabloid,
}

enum PdfOrientation {
  portrait,
  landscape,
}

extension ExportTypeX on ExportType {
  String get displayName {
    switch (this) {
      case ExportType.fixtures:
        return 'Fixtures';
      case ExportType.standings:
        return 'Standings';
      case ExportType.statistics:
        return 'Statistics';
      case ExportType.teams:
        return 'Teams';
      case ExportType.players:
        return 'Players';
      case ExportType.form:
        return 'Form Analysis';
      case ExportType.predictions:
        return 'Predictions';
      case ExportType.custom:
        return 'Custom';
    }
  }

  String get icon {
    switch (this) {
      case ExportType.fixtures:
        return '📅';
      case ExportType.standings:
        return '🏆';
      case ExportType.statistics:
        return '📊';
      case ExportType.teams:
        return '👥';
      case ExportType.players:
        return '⚽';
      case ExportType.form:
        return '📈';
      case ExportType.predictions:
        return '🔮';
      case ExportType.custom:
        return '🎯';
    }
  }
}

extension ExportFormatX on ExportFormat {
  String get displayName {
    switch (this) {
      case ExportFormat.csv:
        return 'CSV';
      case ExportFormat.excel:
        return 'Excel';
      case ExportFormat.pdf:
        return 'PDF';
      case ExportFormat.json:
        return 'JSON';
      case ExportFormat.xml:
        return 'XML';
    }
  }

  String get fileExtension {
    switch (this) {
      case ExportFormat.csv:
        return '.csv';
      case ExportFormat.excel:
        return '.xlsx';
      case ExportFormat.pdf:
        return '.pdf';
      case ExportFormat.json:
        return '.json';
      case ExportFormat.xml:
        return '.xml';
    }
  }

  String get mimeType {
    switch (this) {
      case ExportFormat.csv:
        return 'text/csv';
      case ExportFormat.excel:
        return 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
      case ExportFormat.pdf:
        return 'application/pdf';
      case ExportFormat.json:
        return 'application/json';
      case ExportFormat.xml:
        return 'application/xml';
    }
  }
}

extension ExportStatusX on ExportStatus {
  String get displayName {
    switch (this) {
      case ExportStatus.pending:
        return 'Pending';
      case ExportStatus.inProgress:
        return 'In Progress';
      case ExportStatus.completed:
        return 'Completed';
      case ExportStatus.failed:
        return 'Failed';
      case ExportStatus.cancelled:
        return 'Cancelled';
    }
  }

  String get icon {
    switch (this) {
      case ExportStatus.pending:
        return '⏳';
      case ExportStatus.inProgress:
        return '🔄';
      case ExportStatus.completed:
        return '✅';
      case ExportStatus.failed:
        return '❌';
      case ExportStatus.cancelled:
        return '🚫';
    }
  }
}

extension FilterOperatorX on FilterOperator {
  String get displayName {
    switch (this) {
      case FilterOperator.equals:
        return 'Equals';
      case FilterOperator.notEquals:
        return 'Not Equals';
      case FilterOperator.contains:
        return 'Contains';
      case FilterOperator.notContains:
        return 'Not Contains';
      case FilterOperator.startsWith:
        return 'Starts With';
      case FilterOperator.endsWith:
        return 'Ends With';
      case FilterOperator.greaterThan:
        return 'Greater Than';
      case FilterOperator.greaterThanOrEqual:
        return 'Greater Than or Equal';
      case FilterOperator.lessThan:
        return 'Less Than';
      case FilterOperator.lessThanOrEqual:
        return 'Less Than or Equal';
      case FilterOperator.between:
        return 'Between';
      case FilterOperator.in_:
        return 'In';
      case FilterOperator.notIn:
        return 'Not In';
      case FilterOperator.isNull:
        return 'Is Null';
      case FilterOperator.isNotNull:
        return 'Is Not Null';
    }
  }

  String get sqlOperator {
    switch (this) {
      case FilterOperator.equals:
        return '=';
      case FilterOperator.notEquals:
        return '!=';
      case FilterOperator.contains:
        return 'LIKE';
      case FilterOperator.notContains:
        return 'NOT LIKE';
      case FilterOperator.startsWith:
        return 'LIKE';
      case FilterOperator.endsWith:
        return 'LIKE';
      case FilterOperator.greaterThan:
        return '>';
      case FilterOperator.greaterThanOrEqual:
        return '>=';
      case FilterOperator.lessThan:
        return '<';
      case FilterOperator.lessThanOrEqual:
        return '<=';
      case FilterOperator.between:
        return 'BETWEEN';
      case FilterOperator.in_:
        return 'IN';
      case FilterOperator.notIn:
        return 'NOT IN';
      case FilterOperator.isNull:
        return 'IS NULL';
      case FilterOperator.isNotNull:
        return 'IS NOT NULL';
    }
  }
}

extension ExportDataModelX on ExportDataModel {
  String get fileName {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final extension = format.fileExtension;
    return '${title.replaceAll(' ', '_')}_$timestamp$extension';
  }

  String get fileSizeDisplay {
    if (fileSizeBytes < 1024) return '${fileSizeBytes}B';
    if (fileSizeBytes < 1024 * 1024) return '${(fileSizeBytes / 1024).toStringAsFixed(1)}KB';
    if (fileSizeBytes < 1024 * 1024 * 1024) return '${(fileSizeBytes / (1024 * 1024)).toStringAsFixed(1)}MB';
    return '${(fileSizeBytes / (1024 * 1024 * 1024)).toStringAsFixed(1)}GB';
  }

  bool get isReady => status == ExportStatus.completed && filePath != null;
  bool get hasError => status == ExportStatus.failed && errorMessage != null;
  bool get isProcessing => status == ExportStatus.inProgress;

  List<ExportColumn> get visibleColumns => columns.where((c) => c.visible).toList()
    ..sort((a, b) => a.order.compareTo(b.order));

  Duration? get exportDuration {
    if (createdAt != null && lastExported != null) {
      return lastExported!.difference(createdAt!);
    }
    return null;
  }

  String generateSql() {
    final buffer = StringBuffer();
    
    // SELECT clause
    buffer.write('SELECT ');
    final fields = visibleColumns.map((col) {
      if (col.calculated && col.formula != null) {
        return '${col.formula} AS ${col.name}';
      }
      return col.sourceField.contains('.') ? col.sourceField : '${dataSources.first.table}.${col.sourceField}';
    }).join(', ');
    buffer.write(fields);
    
    // FROM clause
    buffer.write(' FROM ${dataSources.first.table}');
    if (dataSources.first.alias != null) {
      buffer.write(' AS ${dataSources.first.alias}');
    }
    
    // JOIN clauses
    for (final join in dataSources.first.joins) {
      buffer.write(' ${join.type.name.toUpperCase()} JOIN ${join.table}');
      if (join.alias != null) {
        buffer.write(' AS ${join.alias}');
      }
      buffer.write(' ON ${join.onClause}');
    }
    
    // WHERE clause
    if (filters.isNotEmpty || dataSources.first.whereClause != null) {
      buffer.write(' WHERE ');
      final conditions = <String>[];
      
      if (dataSources.first.whereClause != null) {
        conditions.add(dataSources.first.whereClause!);
      }
      
      for (int i = 0; i < filters.length; i++) {
        final filter = filters[i];
        if (i > 0) {
          conditions.add(filter.logicalOperator.name.toUpperCase());
        }
        conditions.add(_buildFilterCondition(filter));
      }
      
      buffer.write(conditions.join(' '));
    }
    
    // GROUP BY clause
    if (dataSources.first.groupBy != null) {
      buffer.write(' GROUP BY ${dataSources.first.groupBy}');
    }
    
    // HAVING clause
    if (dataSources.first.having != null) {
      buffer.write(' HAVING ${dataSources.first.having}');
    }
    
    // ORDER BY clause
    if (sorting.isNotEmpty) {
      buffer.write(' ORDER BY ');
      final sortFields = sorting.map((sort) => 
        '${sort.field} ${sort.direction.name.toUpperCase()}'
      ).join(', ');
      buffer.write(sortFields);
    }
    
    // LIMIT clause
    if (configuration.maxRecords > 0) {
      buffer.write(' LIMIT ${configuration.maxRecords}');
    }
    
    return buffer.toString();
  }

  String _buildFilterCondition(FilterCriteria filter) {
    switch (filter.operator) {
      case FilterOperator.contains:
        return "${filter.field} LIKE '%${filter.value}%'";
      case FilterOperator.notContains:
        return "${filter.field} NOT LIKE '%${filter.value}%'";
      case FilterOperator.startsWith:
        return "${filter.field} LIKE '${filter.value}%'";
      case FilterOperator.endsWith:
        return "${filter.field} LIKE '%${filter.value}'";
      case FilterOperator.between:
        return "${filter.field} BETWEEN '${filter.value}' AND '${filter.value2}'";
      case FilterOperator.in_:
        return "${filter.field} IN (${filter.value})";
      case FilterOperator.notIn:
        return "${filter.field} NOT IN (${filter.value})";
      case FilterOperator.isNull:
        return "${filter.field} IS NULL";
      case FilterOperator.isNotNull:
        return "${filter.field} IS NOT NULL";
      default:
        return "${filter.field} ${filter.operator.sqlOperator} '${filter.value}'";
    }
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type.name,
      'format': format.name,
      'dataSources': dataSources.map((ds) => ds.toJson()).toList(),
      'configuration': configuration.toJson(),
      'columns': columns.map((c) => c.toJson()).toList(),
      'filters': filters.map((f) => f.toJson()).toList(),
      'sorting': sorting.map((s) => s.toJson()).toList(),
      'createdAt': createdAt?.millisecondsSinceEpoch,
      'lastExported': lastExported?.millisecondsSinceEpoch,
      'filePath': filePath,
      'recordCount': recordCount,
      'fileSizeBytes': fileSizeBytes,
      'status': status?.name,
      'errorMessage': errorMessage,
      'metadata': metadata,
    };
  }

  static ExportDataModel fromFirestore(Map<String, dynamic> data) {
    return ExportDataModel(
      id: data['id'],
      title: data['title'],
      description: data['description'],
      type: ExportType.values.firstWhere(
        (t) => t.name == data['type'],
        orElse: () => ExportType.custom,
      ),
      format: ExportFormat.values.firstWhere(
        (f) => f.name == data['format'],
        orElse: () => ExportFormat.csv,
      ),
      dataSources: (data['dataSources'] as List<dynamic>)
          .map((ds) => DataSource.fromJson(ds))
          .toList(),
      configuration: ExportConfiguration.fromJson(data['configuration']),
      columns: (data['columns'] as List<dynamic>?)
              ?.map((c) => ExportColumn.fromJson(c))
              .toList() ??
          [],
      filters: (data['filters'] as List<dynamic>?)
              ?.map((f) => FilterCriteria.fromJson(f))
              .toList() ??
          [],
      sorting: (data['sorting'] as List<dynamic>?)
              ?.map((s) => SortCriteria.fromJson(s))
              .toList() ??
          [],
      createdAt: data['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(data['createdAt'])
          : null,
      lastExported: data['lastExported'] != null
          ? DateTime.fromMillisecondsSinceEpoch(data['lastExported'])
          : null,
      filePath: data['filePath'],
      recordCount: data['recordCount'] ?? 0,
      fileSizeBytes: data['fileSizeBytes'] ?? 0,
      status: data['status'] != null
          ? ExportStatus.values.firstWhere(
              (s) => s.name == data['status'],
              orElse: () => ExportStatus.pending,
            )
          : null,
      errorMessage: data['errorMessage'],
      metadata: Map<String, dynamic>.from(data['metadata'] ?? {}),
    );
  }
}