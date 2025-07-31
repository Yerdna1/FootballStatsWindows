import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:csv/csv.dart';

/// Production Database Browser Service - Exact port of Python database_manager.py
class DatabaseBrowserService {
  static const String databaseName = 'football_stats.db';
  static const int databaseVersion = 1;
  
  Database? _database;
  final Logger _logger = Logger();
  
  DatabaseBrowserService();
  
  /// Initialize database connection
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }
  
  /// Initialize SQLite database with football stats schema
  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, databaseName);
    
    _logger.i('Initializing database at: $path');
    
    return await openDatabase(
      path,
      version: databaseVersion,
      onCreate: _createDatabase,
      onUpgrade: _upgradeDatabase,
    );
  }
  
  /// Create database schema (matching Python structure)
  Future<void> _createDatabase(Database db, int version) async {
    _logger.i('Creating database schema v$version');
    
    // Teams table
    await db.execute('''
      CREATE TABLE teams (
        id INTEGER PRIMARY KEY,
        name TEXT NOT NULL,
        short_name TEXT NOT NULL,
        tla TEXT NOT NULL,
        crest TEXT,
        founded INTEGER,
        venue TEXT,
        website TEXT,
        country TEXT,
        area_name TEXT,
        area_flag TEXT,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
      )
    ''');
    
    // Leagues table
    await db.execute('''
      CREATE TABLE leagues (
        id INTEGER PRIMARY KEY,
        name TEXT NOT NULL,
        code TEXT NOT NULL,
        type TEXT NOT NULL,
        emblem TEXT,
        country_name TEXT,
        country_code TEXT,
        country_flag TEXT,
        season_start TEXT,
        season_end TEXT,
        current_season INTEGER DEFAULT 0,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
      )
    ''');
    
    // Fixtures table
    await db.execute('''
      CREATE TABLE fixtures (
        id INTEGER PRIMARY KEY,
        utc_date DATETIME NOT NULL,
        status TEXT NOT NULL,
        matchday INTEGER,
        stage TEXT,
        group_name TEXT,
        competition_id INTEGER,
        season_year INTEGER,
        home_team_id INTEGER NOT NULL,
        away_team_id INTEGER NOT NULL,
        home_score INTEGER,
        away_score INTEGER,
        winner TEXT,
        duration TEXT,
        half_time_home INTEGER,
        half_time_away INTEGER,
        full_time_home INTEGER,
        full_time_away INTEGER,
        extra_time_home INTEGER,
        extra_time_away INTEGER,
        penalties_home INTEGER,
        penalties_away INTEGER,
        referee_name TEXT,
        venue_name TEXT,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (home_team_id) REFERENCES teams (id),
        FOREIGN KEY (away_team_id) REFERENCES teams (id),
        FOREIGN KEY (competition_id) REFERENCES leagues (id)
      )
    ''');
    
    // Standings table
    await db.execute('''
      CREATE TABLE standings (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        league_id INTEGER NOT NULL,
        season INTEGER NOT NULL,
        team_id INTEGER NOT NULL,
        position INTEGER NOT NULL,
        points INTEGER NOT NULL,
        played INTEGER NOT NULL,
        won INTEGER NOT NULL,
        drawn INTEGER NOT NULL,
        lost INTEGER NOT NULL,
        goals_for INTEGER NOT NULL,
        goals_against INTEGER NOT NULL,
        goal_difference INTEGER NOT NULL,
        form TEXT,
        home_played INTEGER DEFAULT 0,
        home_won INTEGER DEFAULT 0,
        home_drawn INTEGER DEFAULT 0,
        home_lost INTEGER DEFAULT 0,
        home_goals_for INTEGER DEFAULT 0,
        home_goals_against INTEGER DEFAULT 0,
        away_played INTEGER DEFAULT 0,
        away_won INTEGER DEFAULT 0,
        away_drawn INTEGER DEFAULT 0,
        away_lost INTEGER DEFAULT 0,
        away_goals_for INTEGER DEFAULT 0,
        away_goals_against INTEGER DEFAULT 0,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (league_id) REFERENCES leagues (id),
        FOREIGN KEY (team_id) REFERENCES teams (id),
        UNIQUE(league_id, season, team_id)
      )
    ''');
    
    // User activity log table
    await db.execute('''
      CREATE TABLE user_activity (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id TEXT,
        action TEXT NOT NULL,
        entity_type TEXT NOT NULL,
        entity_id INTEGER,
        details TEXT,
        ip_address TEXT,
        user_agent TEXT,
        timestamp DATETIME DEFAULT CURRENT_TIMESTAMP
      )
    ''');
    
    // Predictions table
    await db.execute('''
      CREATE TABLE predictions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        fixture_id INTEGER NOT NULL,
        home_team_id INTEGER NOT NULL,
        away_team_id INTEGER NOT NULL,
        home_win_probability REAL NOT NULL,
        draw_probability REAL NOT NULL,
        away_win_probability REAL NOT NULL,
        home_expected_goals REAL NOT NULL,
        away_expected_goals REAL NOT NULL,
        confidence_score REAL NOT NULL,
        reliability REAL NOT NULL,
        most_likely_result TEXT NOT NULL,
        risk_level TEXT NOT NULL,
        prediction_date DATETIME NOT NULL,
        actual_result TEXT,
        accuracy_score REAL,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (fixture_id) REFERENCES fixtures (id),
        FOREIGN KEY (home_team_id) REFERENCES teams (id),
        FOREIGN KEY (away_team_id) REFERENCES teams (id)
      )
    ''');
    
    // Form analysis table
    await db.execute('''
      CREATE TABLE team_form_analysis (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        team_id INTEGER NOT NULL,
        analysis_date DATETIME NOT NULL,
        form_length INTEGER NOT NULL,
        form_string TEXT NOT NULL,
        form_percentage REAL NOT NULL,
        wins INTEGER NOT NULL,
        draws INTEGER NOT NULL,
        losses INTEGER NOT NULL,
        goals_for INTEGER NOT NULL,
        goals_against INTEGER NOT NULL,
        goal_difference INTEGER NOT NULL,
        average_goals_for REAL NOT NULL,
        average_goals_against REAL NOT NULL,
        current_streak TEXT NOT NULL,
        current_streak_length INTEGER NOT NULL,
        longest_win_streak INTEGER NOT NULL,
        longest_unbeaten_streak INTEGER NOT NULL,
        longest_lose_streak INTEGER NOT NULL,
        momentum REAL NOT NULL,
        consistency REAL NOT NULL,
        form_trend_direction TEXT NOT NULL,
        form_trend_strength REAL NOT NULL,
        performance_rating REAL NOT NULL,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (team_id) REFERENCES teams (id)
      )
    ''');
    
    // Create indexes for better performance
    await _createIndexes(db);
    
    _logger.i('Database schema created successfully');
  }
  
  /// Create database indexes
  Future<void> _createIndexes(Database db) async {
    final indexes = [
      'CREATE INDEX idx_fixtures_date ON fixtures (utc_date)',
      'CREATE INDEX idx_fixtures_home_team ON fixtures (home_team_id)',
      'CREATE INDEX idx_fixtures_away_team ON fixtures (away_team_id)',
      'CREATE INDEX idx_fixtures_competition ON fixtures (competition_id)',
      'CREATE INDEX idx_standings_league_season ON standings (league_id, season)',
      'CREATE INDEX idx_standings_team ON standings (team_id)',
      'CREATE INDEX idx_user_activity_timestamp ON user_activity (timestamp)',
      'CREATE INDEX idx_user_activity_user ON user_activity (user_id)',
      'CREATE INDEX idx_predictions_fixture ON predictions (fixture_id)',
      'CREATE INDEX idx_form_analysis_team ON team_form_analysis (team_id)',
      'CREATE INDEX idx_form_analysis_date ON team_form_analysis (analysis_date)',
    ];
    
    for (final index in indexes) {
      await db.execute(index);
    }
  }
  
  /// Upgrade database schema
  Future<void> _upgradeDatabase(Database db, int oldVersion, int newVersion) async {
    _logger.i('Upgrading database from v$oldVersion to v$newVersion');
    // Add migration logic here when needed
  }
  
  /// Get all table names in the database
  Future<List<String>> getTableNames() async {
    final db = await database;
    final result = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table' AND name != 'sqlite_sequence'"
    );
    
    return result.map((row) => row['name'] as String).toList();
  }
  
  /// Get table schema information
  Future<TableSchema> getTableSchema(String tableName) async {
    final db = await database;
    
    // Get column information
    final columnInfo = await db.rawQuery('PRAGMA table_info($tableName)');
    final columns = columnInfo.map((row) => ColumnInfo(
      name: row['name'] as String,
      type: row['type'] as String,
      notNull: (row['notnull'] as int) == 1,
      defaultValue: row['dflt_value'] as String?,
      primaryKey: (row['pk'] as int) > 0,
    )).toList();
    
    // Get row count
    final countResult = await db.rawQuery('SELECT COUNT(*) as count FROM $tableName');
    final rowCount = countResult.first['count'] as int;
    
    // Get indexes
    final indexInfo = await db.rawQuery('PRAGMA index_list($tableName)');
    final indexes = indexInfo.map((row) => IndexInfo(
      name: row['name'] as String,
      unique: (row['unique'] as int) == 1,
    )).toList();
    
    // Get foreign keys
    final foreignKeyInfo = await db.rawQuery('PRAGMA foreign_key_list($tableName)');
    final foreignKeys = foreignKeyInfo.map((row) => ForeignKeyInfo(
      from: row['from'] as String,
      table: row['table'] as String,
      to: row['to'] as String,
    )).toList();
    
    return TableSchema(
      name: tableName,
      columns: columns,
      rowCount: rowCount,
      indexes: indexes,
      foreignKeys: foreignKeys,
    );
  }
  
  /// Execute SQL query with parameters
  Future<QueryResult> executeQuery(
    String sql, {
    List<dynamic>? parameters,
    int? limit,
    int? offset,
  }) async {
    final db = await database;
    final startTime = DateTime.now();
    
    try {
      // Add LIMIT and OFFSET if specified
      String finalSql = sql;
      List<dynamic> finalParams = parameters ?? [];
      
      if (limit != null) {
        finalSql += ' LIMIT ?';
        finalParams.add(limit);
        
        if (offset != null) {
          finalSql += ' OFFSET ?';
          finalParams.add(offset);
        }
      }
      
      _logger.i('Executing query: $finalSql');
      
      final result = await db.rawQuery(finalSql, finalParams);
      final executionTime = DateTime.now().difference(startTime);
      
      return QueryResult(
        data: result,
        rowCount: result.length,
        columns: result.isNotEmpty ? result.first.keys.toList() : [],
        executionTime: executionTime,
        sql: finalSql,
        success: true,
      );
      
    } catch (e) {
      final executionTime = DateTime.now().difference(startTime);
      _logger.e('Query execution failed: $e');
      
      return QueryResult(
        data: [],
        rowCount: 0,
        columns: [],
        executionTime: executionTime,
        sql: sql,
        success: false,
        error: e.toString(),
      );
    }
  }
  
  /// Get table data with pagination
  Future<QueryResult> getTableData(
    String tableName, {
    int page = 1,
    int pageSize = 50,
    String? orderBy,
    String? where,
    List<dynamic>? whereArgs,
  }) async {
    final offset = (page - 1) * pageSize;
    
    String sql = 'SELECT * FROM $tableName';
    List<dynamic> params = [];
    
    if (where != null && where.isNotEmpty) {
      sql += ' WHERE $where';
      if (whereArgs != null) {
        params.addAll(whereArgs);
      }
    }
    
    if (orderBy != null && orderBy.isNotEmpty) {
      sql += ' ORDER BY $orderBy';
    }
    
    return await executeQuery(
      sql,
      parameters: params,
      limit: pageSize,
      offset: offset,
    );
  }
  
  /// Get database statistics
  Future<DatabaseStats> getDatabaseStats() async {
    final db = await database;
    
    // Get database file size
    final dbPath = db.path;
    final file = File(dbPath);
    final fileSize = await file.length();
    
    // Get table statistics
    final tableNames = await getTableNames();
    final tableStats = <TableStats>[];
    
    for (final tableName in tableNames) {
      final countResult = await db.rawQuery('SELECT COUNT(*) as count FROM $tableName');
      final rowCount = countResult.first['count'] as int;
      
      tableStats.add(TableStats(
        name: tableName,
        rowCount: rowCount,
      ));
    }
    
    // Get total row count
    final totalRows = tableStats.fold(0, (sum, stat) => sum + stat.rowCount);
    
    // Get database version
    final versionResult = await db.rawQuery('PRAGMA user_version');
    final version = versionResult.first['user_version'] as int;
    
    return DatabaseStats(
      filePath: dbPath,
      fileSize: fileSize,
      version: version,
      tableCount: tableNames.length,
      totalRows: totalRows,
      tableStats: tableStats,
      lastModified: await file.lastModified(),
    );
  }
  
  /// Export table data to CSV
  Future<String> exportTableToCsv(String tableName, {String? where, List<dynamic>? whereArgs}) async {
    final queryResult = await getTableData(
      tableName,
      pageSize: 10000, // Large page size for export
      where: where,
      whereArgs: whereArgs,
    );
    
    if (!queryResult.success) {
      throw Exception('Failed to export table: ${queryResult.error}');
    }
    
    // Convert to CSV format
    final csvData = <List<dynamic>>[];
    
    // Add headers
    csvData.add(queryResult.columns);
    
    // Add data rows
    for (final row in queryResult.data) {
      csvData.add(queryResult.columns.map((col) => row[col]).toList());
    }
    
    return const ListToCsvConverter().convert(csvData);
  }
  
  /// Export query result to CSV
  Future<String> exportQueryToCsv(String sql, {List<dynamic>? parameters}) async {
    final queryResult = await executeQuery(sql, parameters: parameters);
    
    if (!queryResult.success) {
      throw Exception('Failed to export query: ${queryResult.error}');
    }
    
    // Convert to CSV format
    final csvData = <List<dynamic>>[];
    
    // Add headers
    csvData.add(queryResult.columns);
    
    // Add data rows
    for (final row in queryResult.data) {
      csvData.add(queryResult.columns.map((col) => row[col]).toList());
    }
    
    return const ListToCsvConverter().convert(csvData);
  }
  
  /// Execute data modification queries (INSERT, UPDATE, DELETE)
  Future<ModificationResult> executeModification(String sql, [List<dynamic>? parameters]) async {
    final db = await database;
    final startTime = DateTime.now();
    
    try {
      _logger.i('Executing modification: $sql');
      
      final affectedRows = await db.rawUpdate(sql, parameters);
      final executionTime = DateTime.now().difference(startTime);
      
      return ModificationResult(
        affectedRows: affectedRows,
        executionTime: executionTime,
        sql: sql,
        success: true,
      );
      
    } catch (e) {
      final executionTime = DateTime.now().difference(startTime);
      _logger.e('Modification execution failed: $e');
      
      return ModificationResult(
        affectedRows: 0,
        executionTime: executionTime,
        sql: sql,
        success: false,
        error: e.toString(),
      );
    }
  }
  
  /// Vacuum database to optimize storage
  Future<void> vacuumDatabase() async {
    final db = await database;
    _logger.i('Vacuuming database...');
    await db.execute('VACUUM');
    _logger.i('Database vacuum completed');
  }
  
  /// Analyze database for query optimization
  Future<void> analyzeDatabase() async {
    final db = await database;
    _logger.i('Analyzing database...');
    await db.execute('ANALYZE');
    _logger.i('Database analysis completed');
  }
  
  /// Close database connection
  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
  
  /// Log user activity
  Future<void> logActivity({
    String? userId,
    required String action,
    required String entityType,
    int? entityId,
    String? details,
    String? ipAddress,
    String? userAgent,
  }) async {
    final db = await database;
    
    await db.insert('user_activity', {
      'user_id': userId,
      'action': action,
      'entity_type': entityType,
      'entity_id': entityId,
      'details': details,
      'ip_address': ipAddress,
      'user_agent': userAgent,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }
  
  /// Get recent user activity
  Future<List<Map<String, dynamic>>> getRecentActivity({int limit = 100}) async {
    final queryResult = await executeQuery(
      'SELECT * FROM user_activity ORDER BY timestamp DESC',
      limit: limit,
    );
    
    return queryResult.data;
  }
}

// Data classes for database browser
class TableSchema {
  final String name;
  final List<ColumnInfo> columns;
  final int rowCount;
  final List<IndexInfo> indexes;
  final List<ForeignKeyInfo> foreignKeys;
  
  TableSchema({
    required this.name,
    required this.columns,
    required this.rowCount,
    required this.indexes,
    required this.foreignKeys,
  });
}

class ColumnInfo {
  final String name;
  final String type;
  final bool notNull;
  final String? defaultValue;
  final bool primaryKey;
  
  ColumnInfo({
    required this.name,
    required this.type,
    required this.notNull,
    this.defaultValue,
    required this.primaryKey,
  });
}

class IndexInfo {
  final String name;
  final bool unique;
  
  IndexInfo({
    required this.name,
    required this.unique,
  });
}

class ForeignKeyInfo {
  final String from;
  final String table;
  final String to;
  
  ForeignKeyInfo({
    required this.from,
    required this.table,
    required this.to,
  });
}

class QueryResult {
  final List<Map<String, dynamic>> data;
  final int rowCount;
  final List<String> columns;
  final Duration executionTime;
  final String sql;
  final bool success;
  final String? error;
  
  QueryResult({
    required this.data,
    required this.rowCount,
    required this.columns,
    required this.executionTime,
    required this.sql,
    required this.success,
    this.error,
  });
}

class ModificationResult {
  final int affectedRows;
  final Duration executionTime;
  final String sql;
  final bool success;
  final String? error;
  
  ModificationResult({
    required this.affectedRows,
    required this.executionTime,
    required this.sql,
    required this.success,
    this.error,
  });
}

class DatabaseStats {
  final String filePath;
  final int fileSize;
  final int version;
  final int tableCount;
  final int totalRows;
  final List<TableStats> tableStats;
  final DateTime lastModified;
  
  DatabaseStats({
    required this.filePath,
    required this.fileSize,
    required this.version,
    required this.tableCount,
    required this.totalRows,
    required this.tableStats,
    required this.lastModified,
  });
  
  String get fileSizeFormatted {
    if (fileSize < 1024) return '$fileSize B';
    if (fileSize < 1024 * 1024) return '${(fileSize / 1024).toStringAsFixed(2)} KB';
    if (fileSize < 1024 * 1024 * 1024) return '${(fileSize / (1024 * 1024)).toStringAsFixed(2)} MB';
    return '${(fileSize / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }
}

class TableStats {
  final String name;
  final int rowCount;
  
  TableStats({
    required this.name,
    required this.rowCount,
  });
}

// Provider for database browser service
final databaseBrowserServiceProvider = Provider<DatabaseBrowserService>((ref) {
  return DatabaseBrowserService();
});