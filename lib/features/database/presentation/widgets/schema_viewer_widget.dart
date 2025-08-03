import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/database_providers.dart';
import '../../../../core/services/database_browser_service.dart';

/// Schema Viewer Widget - displays detailed table schema information
class SchemaViewerWidget extends ConsumerWidget {
  final String tableName;

  const SchemaViewerWidget({
    super.key,
    required this.tableName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final schemaAsync = ref.watch(tableSchemaProvider(tableName));
    
    return Card(
      margin: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.schema, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Text(
                  '$tableName Schema',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Spacer(),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert),
                  onSelected: (action) => _handleMenuAction(context, ref, action),
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 'refresh', child: Text('Refresh Schema')),
                    const PopupMenuItem(value: 'copy_ddl', child: Text('Copy CREATE Statement')),
                    const PopupMenuItem(value: 'export_schema', child: Text('Export Schema')),
                  ],
                ),
              ],
            ),
          ),
          
          const Divider(),
          
          // Schema content
          Expanded(
            child: schemaAsync.when(
              data: (schema) => _buildSchemaContent(context, schema),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => _buildErrorWidget(context, error.toString()),
            ),
          ),
        ],
      ),
    );
  }

  /// Build schema content
  Widget _buildSchemaContent(BuildContext context, TableSchema schema) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Table overview
          _buildTableOverview(context, schema),
          
          const SizedBox(height: 24),
          
          // Columns section
          _buildColumnsSection(context, schema),
          
          const SizedBox(height: 24),
          
          // Indexes section
          if (schema.indexes.isNotEmpty) ...[
            _buildIndexesSection(context, schema),
            const SizedBox(height: 24),
          ],
          
          // Foreign keys section
          if (schema.foreignKeys.isNotEmpty) ...[
            _buildForeignKeysSection(context, schema),
            const SizedBox(height: 24),
          ],
          
          // SQL DDL section
          _buildDDLSection(context, schema),
        ],
      ),
    );
  }

  /// Build table overview
  Widget _buildTableOverview(BuildContext context, TableSchema schema) {
    final theme = Theme.of(context);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Table Overview',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            
            Row(
              children: [
                Expanded(
                  child: _buildInfoTile(
                    context,
                    icon: Icons.table_chart,
                    title: 'Table Name',
                    value: schema.name,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildInfoTile(
                    context,
                    icon: Icons.data_array,
                    title: 'Row Count',
                    value: _formatNumber(schema.rowCount),
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            Row(
              children: [
                Expanded(
                  child: _buildInfoTile(
                    context,
                    icon: Icons.view_column,
                    title: 'Columns',
                    value: schema.columns.length.toString(),
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildInfoTile(
                    context,
                    icon: Icons.key,
                    title: 'Primary Keys',
                    value: schema.columns.where((c) => c.primaryKey).length.toString(),
                    color: Colors.purple,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Build info tile
  Widget _buildInfoTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  /// Build columns section
  Widget _buildColumnsSection(BuildContext context, TableSchema schema) {
    final theme = Theme.of(context);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Columns',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                Chip(
                  label: Text(schema.columns.length.toString()),
                  backgroundColor: theme.colorScheme.surfaceVariant,
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.copy),
                  onPressed: () => _copyColumnsInfo(context, schema),
                  tooltip: 'Copy Columns Info',
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // Column headers
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Row(
                children: [
                  SizedBox(width: 40), // Icon space
                  Expanded(flex: 2, child: Text('Name', style: TextStyle(fontWeight: FontWeight.bold))),
                  Expanded(flex: 2, child: Text('Type', style: TextStyle(fontWeight: FontWeight.bold))),
                  Expanded(flex: 1, child: Text('Null', style: TextStyle(fontWeight: FontWeight.bold))),
                  Expanded(flex: 2, child: Text('Default', style: TextStyle(fontWeight: FontWeight.bold))),
                ],
              ),
            ),
            
            const SizedBox(height: 8),
            
            // Column rows
            ...schema.columns.map((column) => Container(
              margin: const EdgeInsets.symmetric(vertical: 2),
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              decoration: BoxDecoration(
                color: column.primaryKey 
                    ? Colors.amber.withOpacity(0.1)
                    : theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(4),
                border: column.primaryKey 
                    ? Border.all(color: Colors.amber.withOpacity(0.3))
                    : null,
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 40,
                    child: Icon(
                      column.primaryKey ? Icons.key : Icons.table_chart,
                      color: column.primaryKey ? Colors.amber : Colors.grey,
                      size: 20,
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      column.name,
                      style: TextStyle(
                        fontWeight: column.primaryKey ? FontWeight.bold : FontWeight.normal,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: _getTypeColor(column.type).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        column.type,
                        style: TextStyle(
                          color: _getTypeColor(column.type),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Icon(
                      column.notNull ? Icons.close : Icons.check,
                      color: column.notNull ? Colors.red : Colors.green,
                      size: 16,
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      column.defaultValue ?? 'NULL',
                      style: TextStyle(
                        color: column.defaultValue != null ? null : Colors.grey,
                        fontStyle: column.defaultValue != null ? FontStyle.normal : FontStyle.italic,
                        fontSize: 12,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  /// Build indexes section
  Widget _buildIndexesSection(BuildContext context, TableSchema schema) {
    final theme = Theme.of(context);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Indexes',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                Chip(
                  label: Text(schema.indexes.length.toString()),
                  backgroundColor: theme.colorScheme.surfaceVariant,
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            ...schema.indexes.map((index) => ListTile(
              dense: true,
              leading: Icon(
                index.unique ? Icons.fingerprint : Icons.list,
                color: index.unique ? Colors.purple : Colors.blue,
              ),
              title: Text(
                index.name,
                style: const TextStyle(fontFamily: 'monospace'),
              ),
              subtitle: Text(index.unique ? 'UNIQUE INDEX' : 'INDEX'),
              trailing: index.unique
                  ? const Chip(
                      label: Text('UNIQUE'),
                      backgroundColor: Colors.purple,
                      labelStyle: TextStyle(color: Colors.white, fontSize: 10),
                    )
                  : null,
            )),
          ],
        ),
      ),
    );
  }

  /// Build foreign keys section
  Widget _buildForeignKeysSection(BuildContext context, TableSchema schema) {
    final theme = Theme.of(context);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Foreign Keys',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                Chip(
                  label: Text(schema.foreignKeys.length.toString()),
                  backgroundColor: theme.colorScheme.surfaceVariant,
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            ...schema.foreignKeys.map((fk) => ListTile(
              dense: true,
              leading: const Icon(Icons.link, color: Colors.green),
              title: Text(
                '${fk.from} → ${fk.table}.${fk.to}',
                style: const TextStyle(fontFamily: 'monospace'),
              ),
              subtitle: Text('References ${fk.table}'),
            )),
          ],
        ),
      ),
    );
  }

  /// Build DDL section
  Widget _buildDDLSection(BuildContext context, TableSchema schema) {
    final theme = Theme.of(context);
    final ddl = _generateDDL(schema);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'CREATE Statement',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.copy),
                  onPressed: () => _copyToClipboard(context, ddl, 'DDL copied to clipboard'),
                  tooltip: 'Copy DDL',
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: theme.dividerColor),
              ),
              child: SelectableText(
                ddl,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build error widget
  Widget _buildErrorWidget(BuildContext context, String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            const Text(
              'Error Loading Schema',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            SelectableText(
              error,
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// Get color for data type
  Color _getTypeColor(String type) {
    final lowerType = type.toLowerCase();
    if (lowerType.contains('int') || lowerType.contains('number')) {
      return Colors.blue;
    } else if (lowerType.contains('text') || lowerType.contains('varchar') || lowerType.contains('char')) {
      return Colors.green;
    } else if (lowerType.contains('real') || lowerType.contains('float') || lowerType.contains('double')) {
      return Colors.orange;
    } else if (lowerType.contains('date') || lowerType.contains('time')) {
      return Colors.purple;
    } else if (lowerType.contains('bool')) {
      return Colors.teal;
    } else {
      return Colors.grey;
    }
  }

  /// Format number with commas
  String _formatNumber(int number) {
    if (number < 1000) return number.toString();
    if (number < 1000000) return '${(number / 1000).toStringAsFixed(1)}K';
    return '${(number / 1000000).toStringAsFixed(1)}M';
  }

  /// Generate DDL statement
  String _generateDDL(TableSchema schema) {
    final buffer = StringBuffer();
    buffer.writeln('CREATE TABLE ${schema.name} (');
    
    // Columns
    for (int i = 0; i < schema.columns.length; i++) {
      final column = schema.columns[i];
      buffer.write('  ${column.name} ${column.type}');
      
      if (column.primaryKey) {
        buffer.write(' PRIMARY KEY');
      }
      
      if (column.notNull && !column.primaryKey) {
        buffer.write(' NOT NULL');
      }
      
      if (column.defaultValue != null) {
        buffer.write(' DEFAULT ${column.defaultValue}');
      }
      
      if (i < schema.columns.length - 1) {
        buffer.writeln(',');
      } else {
        buffer.writeln();
      }
    }
    
    buffer.writeln(');');
    
    // Indexes
    for (final index in schema.indexes) {
      buffer.writeln();
      if (index.unique) {
        buffer.writeln('CREATE UNIQUE INDEX ${index.name} ON ${schema.name} (...);');
      } else {
        buffer.writeln('CREATE INDEX ${index.name} ON ${schema.name} (...);');
      }
    }
    
    return buffer.toString();
  }

  /// Copy to clipboard
  void _copyToClipboard(BuildContext context, String text, String message) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  /// Copy columns info
  void _copyColumnsInfo(BuildContext context, TableSchema schema) {
    final buffer = StringBuffer();
    buffer.writeln('Table: ${schema.name}');
    buffer.writeln('Columns: ${schema.columns.length}');
    buffer.writeln('Rows: ${schema.rowCount}');
    buffer.writeln();
    buffer.writeln('Column\tType\tNull\tDefault\tPK');
    
    for (final column in schema.columns) {
      buffer.writeln('${column.name}\t${column.type}\t${column.notNull ? 'NO' : 'YES'}\t${column.defaultValue ?? 'NULL'}\t${column.primaryKey ? 'YES' : 'NO'}');
    }
    
    _copyToClipboard(context, buffer.toString(), 'Schema info copied to clipboard');
  }

  /// Handle menu actions
  void _handleMenuAction(BuildContext context, WidgetRef ref, String action) {
    switch (action) {
      case 'refresh':
        ref.refresh(tableSchemaProvider(tableName));
        break;
      case 'copy_ddl':
        final schemaAsync = ref.read(tableSchemaProvider(tableName));
        schemaAsync.whenData((schema) {
          _copyToClipboard(context, _generateDDL(schema), 'DDL copied to clipboard');
        });
        break;
      case 'export_schema':
        _exportSchema(context, ref);
        break;
    }
  }

  /// Export schema
  void _exportSchema(BuildContext context, WidgetRef ref) {
    final schemaAsync = ref.read(tableSchemaProvider(tableName));
    schemaAsync.whenData((schema) {
      final csvData = _generateSchemaCsv(schema);
      _copyToClipboard(context, csvData, 'Schema exported to clipboard');
    });
  }

  /// Generate schema CSV
  String _generateSchemaCsv(TableSchema schema) {
    final buffer = StringBuffer();
    buffer.writeln('Column,Type,NotNull,Default,PrimaryKey');
    
    for (final column in schema.columns) {
      buffer.writeln('${column.name},${column.type},${column.notNull},${column.defaultValue ?? ''},${column.primaryKey}');
    }
    
    return buffer.toString();
  }
}