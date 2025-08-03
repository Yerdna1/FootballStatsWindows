import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:data_table_2/data_table_2.dart';

import '../../providers/database_providers.dart';

/// SQL Query Executor Widget
class QueryExecutorWidget extends ConsumerStatefulWidget {
  const QueryExecutorWidget({super.key});

  @override
  ConsumerState<QueryExecutorWidget> createState() => _QueryExecutorWidgetState();
}

class _QueryExecutorWidgetState extends ConsumerState<QueryExecutorWidget> {
  final TextEditingController _queryController = TextEditingController();
  final TextEditingController _parametersController = TextEditingController();
  final ScrollController _resultsScrollController = ScrollController();
  
  final List<String> _queryHistory = [];
  int _historyIndex = -1;
  
  // Common SQL templates
  final Map<String, String> _sqlTemplates = {
    'Select All': 'SELECT * FROM table_name LIMIT 100;',
    'Count Rows': 'SELECT COUNT(*) FROM table_name;',
    'Recent Data': 'SELECT * FROM table_name WHERE created_at >= datetime(\'now\', \'-7 days\') ORDER BY created_at DESC;',
    'Insert Record': 'INSERT INTO table_name (column1, column2) VALUES (?, ?);',
    'Update Record': 'UPDATE table_name SET column1 = ? WHERE id = ?;',
    'Delete Record': 'DELETE FROM table_name WHERE id = ?;',
    'Create Index': 'CREATE INDEX idx_name ON table_name (column_name);',
    'Drop Index': 'DROP INDEX IF EXISTS idx_name;',
    'Table Info': 'PRAGMA table_info(table_name);',
    'Foreign Keys': 'PRAGMA foreign_key_list(table_name);',
  };

  @override
  void initState() {
    super.initState();
    _queryController.text = 'SELECT * FROM teams LIMIT 10;';
  }

  @override
  void dispose() {
    _queryController.dispose();
    _parametersController.dispose();
    _resultsScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final queryState = ref.watch(queryExecutorProvider);
    
    return Column(
      children: [
        // Query input section
        Card(
          margin: const EdgeInsets.all(8),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.code, color: theme.primaryColor),
                    const SizedBox(width: 8),
                    Text(
                      'SQL Query Executor',
                      style: theme.textTheme.titleMedium,
                    ),
                    const Spacer(),
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.template_icon),
                      tooltip: 'SQL Templates',
                      onSelected: (template) {
                        _queryController.text = _sqlTemplates[template] ?? '';
                        _queryController.selection = TextSelection.fromPosition(
                          TextPosition(offset: _queryController.text.length),
                        );
                      },
                      itemBuilder: (context) => _sqlTemplates.entries
                          .map((entry) => PopupMenuItem(
                                value: entry.key,
                                child: Text(entry.key),
                              ))
                          .toList(),
                    ),
                    IconButton(
                      icon: const Icon(Icons.history),
                      tooltip: 'Query History',
                      onPressed: _showQueryHistory,
                    ),
                    IconButton(
                      icon: const Icon(Icons.clear),
                      tooltip: 'Clear Query',
                      onPressed: () {
                        _queryController.clear();
                        _parametersController.clear();
                        ref.read(queryExecutorProvider.notifier).reset();
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // SQL query input
                TextField(
                  controller: _queryController,
                  maxLines: 8,
                  style: const TextStyle(fontFamily: 'monospace'),
                  decoration: InputDecoration(
                    labelText: 'SQL Query',
                    hintText: 'Enter your SQL query here...',
                    border: const OutlineInputBorder(),
                    suffixIcon: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.keyboard_arrow_up),
                          onPressed: _navigateHistoryUp,
                          tooltip: 'Previous Query',
                        ),
                        IconButton(
                          icon: const Icon(Icons.keyboard_arrow_down),
                          onPressed: _navigateHistoryDown,
                          tooltip: 'Next Query',
                        ),
                      ],
                    ),
                  ),
                  onSubmitted: (_) => _executeQuery(),
                ),
                
                const SizedBox(height: 12),
                
                // Parameters input
                TextField(
                  controller: _parametersController,
                  decoration: const InputDecoration(
                    labelText: 'Parameters (JSON array)',
                    hintText: '["param1", "param2"]',
                    border: OutlineInputBorder(),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Action buttons
                Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: queryState is _Loading ? null : _executeQuery,
                      icon: queryState is _Loading
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.play_arrow),
                      label: const Text('Execute'),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton.icon(
                      onPressed: _formatQuery,
                      icon: const Icon(Icons.format_align_left),
                      label: const Text('Format'),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton.icon(
                      onPressed: _validateQuery,
                      icon: const Icon(Icons.check_circle_outline),
                      label: const Text('Validate'),
                    ),
                    const Spacer(),
                    _buildQueryInfo(queryState),
                  ],
                ),
              ],
            ),
          ),
        ),
        
        // Results section
        Expanded(
          child: Card(
            margin: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Icon(Icons.table_chart),
                      const SizedBox(width: 8),
                      const Text('Query Results'),
                      const Spacer(),
                      if (queryState is _Success && queryState.result.data.isNotEmpty) ...[
                        OutlinedButton.icon(
                          onPressed: () => _exportResults(queryState.result),
                          icon: const Icon(Icons.download),
                          label: const Text('Export CSV'),
                        ),
                        const SizedBox(width: 8),
                        OutlinedButton.icon(
                          onPressed: () => _copyResults(queryState.result),
                          icon: const Icon(Icons.copy),
                          label: const Text('Copy'),
                        ),
                      ],
                    ],
                  ),
                ),
                const Divider(),
                Expanded(child: _buildResultsContent(queryState)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Build query info widget
  Widget _buildQueryInfo(QueryExecutorState state) {
    return switch (state) {
      _Success(result: final result) => Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.green.withOpacity(0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 16),
              const SizedBox(width: 4),
              Text(
                '${result.rowCount} rows • ${result.executionTime.inMilliseconds}ms',
                style: TextStyle(color: Colors.green, fontSize: 12),
              ),
            ],
          ),
        ),
      _Modification(result: final result) => Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.blue.withOpacity(0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.edit, color: Colors.blue, size: 16),
              const SizedBox(width: 4),
              Text(
                '${result.affectedRows} affected • ${result.executionTime.inMilliseconds}ms',
                style: TextStyle(color: Colors.blue, fontSize: 12),
              ),
            ],
          ),
        ),
      _Error(message: final message) => Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.red.withOpacity(0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error, color: Colors.red, size: 16),
              const SizedBox(width: 4),
              Text(
                'Error',
                style: TextStyle(color: Colors.red, fontSize: 12),
              ),
            ],
          ),
        ),
      _ => const SizedBox.shrink(),
    };
  }

  /// Build results content
  Widget _buildResultsContent(QueryExecutorState state) {
    return switch (state) {
      _Initial() => const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.play_arrow, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text('Execute a query to see results'),
            ],
          ),
        ),
      _Loading() => const Center(child: CircularProgressIndicator()),
      _Success(result: final result) => _buildDataTable(result),
      _Modification(result: final result) => _buildModificationResult(result),
      _Error(message: final message) => _buildErrorDisplay(message),
    };
  }

  /// Build data table for query results
  Widget _buildDataTable(QueryResult result) {
    if (result.data.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.table_chart, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('No data returned'),
          ],
        ),
      );
    }

    return Scrollbar(
      controller: _resultsScrollController,
      child: DataTable2(
        scrollController: _resultsScrollController,
        columnSpacing: 12,
        horizontalMargin: 16,
        minWidth: 600,
        showCheckboxColumn: false,
        headingRowHeight: 48,
        dataRowHeight: 40,
        columns: result.columns
            .map((column) => DataColumn2(
                  label: Text(
                    column,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  size: ColumnSize.M,
                ))
            .toList(),
        rows: result.data
            .map((row) => DataRow2(
                  cells: result.columns
                      .map((column) => DataCell(
                            SelectableText(
                              _formatCellValue(row[column]),
                              style: const TextStyle(fontSize: 12),
                            ),
                          ))
                      .toList(),
                ))
            .toList(),
      ),
    );
  }

  /// Build modification result display
  Widget _buildModificationResult(ModificationResult result) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            result.success ? Icons.check_circle : Icons.error,
            size: 64,
            color: result.success ? Colors.green : Colors.red,
          ),
          const SizedBox(height: 16),
          Text(
            result.success
                ? 'Query executed successfully'
                : 'Query execution failed',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          if (result.success) ...[
            Text('Affected rows: ${result.affectedRows}'),
            Text('Execution time: ${result.executionTime.inMilliseconds}ms'),
          ] else if (result.error != null) ...[
            Text(
              result.error!,
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  /// Build error display
  Widget _buildErrorDisplay(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            const Text(
              'Query Error',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            SelectableText(
              message,
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref.read(queryExecutorProvider.notifier).reset(),
              child: const Text('Clear Error'),
            ),
          ],
        ),
      ),
    );
  }

  /// Format cell value for display
  String _formatCellValue(dynamic value) {
    if (value == null) return 'NULL';
    if (value is String && value.isEmpty) return '(empty)';
    return value.toString();
  }

  /// Execute SQL query
  void _executeQuery() {
    final query = _queryController.text.trim();
    if (query.isEmpty) return;

    // Add to history
    if (_queryHistory.isEmpty || _queryHistory.last != query) {
      _queryHistory.add(query);
      if (_queryHistory.length > 50) {
        _queryHistory.removeAt(0);
      }
    }
    _historyIndex = -1;

    // Parse parameters
    List<dynamic>? parameters;
    final paramText = _parametersController.text.trim();
    if (paramText.isNotEmpty) {
      try {
        // Simple JSON array parsing
        if (paramText.startsWith('[') && paramText.endsWith(']')) {
          parameters = paramText
              .substring(1, paramText.length - 1)
              .split(',')
              .map((s) => s.trim().replaceAll('"', ''))
              .toList();
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Invalid parameters format: $e')),
        );
        return;
      }
    }

    // Determine if it's a modification query
    final queryLower = query.toLowerCase().trim();
    final isModification = queryLower.startsWith('insert') ||
        queryLower.startsWith('update') ||
        queryLower.startsWith('delete') ||
        queryLower.startsWith('create') ||
        queryLower.startsWith('drop') ||
        queryLower.startsWith('alter');

    if (isModification) {
      ref.read(queryExecutorProvider.notifier).executeModification(
        query,
        parameters: parameters,
      );
    } else {
      ref.read(queryExecutorProvider.notifier).executeQuery(
        query,
        parameters: parameters,
      );
    }
  }

  /// Format SQL query
  void _formatQuery() {
    final query = _queryController.text;
    // Simple SQL formatting
    final formatted = query
        .replaceAllMapped(RegExp(r'\b(SELECT|FROM|WHERE|ORDER BY|GROUP BY|HAVING|INSERT|UPDATE|DELETE|CREATE|DROP|ALTER)\b', caseSensitive: false), 
          (match) => match.group(0)!.toUpperCase())
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    
    _queryController.text = formatted;
  }

  /// Validate SQL query
  void _validateQuery() {
    final query = _queryController.text.trim();
    if (query.isEmpty) {
      _showMessage('Query is empty', isError: true);
      return;
    }

    // Basic validation
    if (!query.endsWith(';')) {
      _showMessage('Query should end with semicolon (;)', isError: true);
      return;
    }

    final keywords = ['SELECT', 'INSERT', 'UPDATE', 'DELETE', 'CREATE', 'DROP', 'ALTER'];
    final hasValidKeyword = keywords.any((keyword) => 
      query.toUpperCase().contains(keyword));
    
    if (!hasValidKeyword) {
      _showMessage('Query must contain a valid SQL keyword', isError: true);
      return;
    }

    _showMessage('Query syntax appears valid', isError: false);
  }

  /// Navigate query history up
  void _navigateHistoryUp() {
    if (_queryHistory.isEmpty) return;
    
    if (_historyIndex < _queryHistory.length - 1) {
      _historyIndex++;
      _queryController.text = _queryHistory[_queryHistory.length - 1 - _historyIndex];
    }
  }

  /// Navigate query history down
  void _navigateHistoryDown() {
    if (_queryHistory.isEmpty) return;
    
    if (_historyIndex > 0) {
      _historyIndex--;
      _queryController.text = _queryHistory[_queryHistory.length - 1 - _historyIndex];
    } else if (_historyIndex == 0) {
      _historyIndex = -1;
      _queryController.clear();
    }
  }

  /// Show query history dialog
  void _showQueryHistory() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Query History'),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: _queryHistory.isEmpty
              ? const Center(child: Text('No query history'))
              : ListView.builder(
                  itemCount: _queryHistory.length,
                  itemBuilder: (context, index) {
                    final query = _queryHistory[_queryHistory.length - 1 - index];
                    return ListTile(
                      title: Text(
                        query,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontFamily: 'monospace'),
                      ),
                      onTap: () {
                        _queryController.text = query;
                        Navigator.of(context).pop();
                      },
                      trailing: IconButton(
                        icon: const Icon(Icons.copy),
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: query));
                          Navigator.of(context).pop();
                          _showMessage('Query copied to clipboard');
                        },
                      ),
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              _queryHistory.clear();
              Navigator.of(context).pop();
            },
            child: const Text('Clear History'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  /// Export results to CSV
  void _exportResults(QueryResult result) {
    // TODO: Implement CSV export
    _showMessage('Export functionality coming soon');
  }

  /// Copy results to clipboard
  void _copyResults(QueryResult result) {
    final buffer = StringBuffer();
    
    // Headers
    buffer.writeln(result.columns.join('\t'));
    
    // Data
    for (final row in result.data) {
      final values = result.columns.map((col) => _formatCellValue(row[col])).join('\t');
      buffer.writeln(values);
    }
    
    Clipboard.setData(ClipboardData(text: buffer.toString()));
    _showMessage('Results copied to clipboard');
  }

  /// Show message
  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : null,
      ),
    );
  }
}