import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:data_table_2/data_table_2.dart';

import '../../providers/database_providers.dart';

/// Table Browser Widget with pagination and search
class TableBrowserWidget extends ConsumerStatefulWidget {
  final String tableName;

  const TableBrowserWidget({
    super.key,
    required this.tableName,
  });

  @override
  ConsumerState<TableBrowserWidget> createState() => _TableBrowserWidgetState();
}

class _TableBrowserWidgetState extends ConsumerState<TableBrowserWidget> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  int _currentPage = 1;
  int _pageSize = 50;
  String? _orderBy;
  String? _searchWhere;
  List<dynamic>? _searchArgs;
  
  // Page size options
  final List<int> _pageSizeOptions = [25, 50, 100, 200];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void didUpdateWidget(TableBrowserWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.tableName != widget.tableName) {
      _currentPage = 1;
      _searchController.clear();
      _searchWhere = null;
      _searchArgs = null;
      _orderBy = null;
      _loadData();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _loadData() {
    final params = TableDataParams(
      tableName: widget.tableName,
      page: _currentPage,
      pageSize: _pageSize,
      orderBy: _orderBy,
      where: _searchWhere,
      whereArgs: _searchArgs,
    );
    
    // This will automatically trigger a rebuild
    ref.refresh(tableDataProvider(params));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    final params = TableDataParams(
      tableName: widget.tableName,
      page: _currentPage,
      pageSize: _pageSize,
      orderBy: _orderBy,
      where: _searchWhere,
      whereArgs: _searchArgs,
    );
    
    final tableDataAsync = ref.watch(tableDataProvider(params));
    final tableSchemaAsync = ref.watch(tableSchemaProvider(widget.tableName));

    return Card(
      margin: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with table info and controls
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.table_chart, color: theme.primaryColor),
                    const SizedBox(width: 8),
                    Text(
                      widget.tableName,
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(width: 8),
                    tableSchemaAsync.when(
                      data: (schema) => Chip(
                        label: Text('${schema.rowCount} rows'),
                        backgroundColor: theme.colorScheme.surfaceVariant,
                      ),
                      loading: () => const SizedBox.shrink(),
                      error: (_, __) => const SizedBox.shrink(),
                    ),
                    const Spacer(),
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert),
                      onSelected: _handleMenuAction,
                      itemBuilder: (context) => [
                        const PopupMenuItem(value: 'refresh', child: Text('Refresh')),
                        const PopupMenuItem(value: 'export', child: Text('Export CSV')),
                        const PopupMenuItem(value: 'schema', child: Text('View Schema')),
                        const PopupMenuItem(value: 'truncate', child: Text('Truncate Table')),
                      ],
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Search and filter controls
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          labelText: 'Search',
                          hintText: 'Search in all columns...',
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: _clearSearch,
                                )
                              : null,
                          border: const OutlineInputBorder(),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        onSubmitted: _performSearch,
                      ),
                    ),
                    
                    const SizedBox(width: 12),
                    
                    // Page size selector
                    DropdownButton<int>(
                      value: _pageSize,
                      items: _pageSizeOptions.map((size) => DropdownMenuItem(
                        value: size,
                        child: Text('$size per page'),
                      )).toList(),
                      onChanged: (newSize) {
                        if (newSize != null) {
                          setState(() {
                            _pageSize = newSize;
                            _currentPage = 1;
                          });
                          _loadData();
                        }
                      },
                    ),
                    
                    const SizedBox(width: 12),
                    
                    // Refresh button
                    IconButton(
                      icon: const Icon(Icons.refresh),
                      onPressed: _loadData,
                      tooltip: 'Refresh Data',
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          const Divider(),
          
          // Data table
          Expanded(
            child: tableDataAsync.when(
              data: (result) => _buildDataTable(result),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => _buildErrorWidget(error.toString()),
            ),
          ),
          
          // Pagination controls
          tableDataAsync.when(
            data: (result) => _buildPaginationControls(result),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  /// Build data table
  Widget _buildDataTable(QueryResult result) {
    if (result.data.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('No data found'),
            SizedBox(height: 8),
            Text('Try adjusting your search or filters'),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Column headers with sort controls
        Container(
          height: 50,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
            border: Border(
              bottom: BorderSide(color: Theme.of(context).dividerColor),
            ),
          ),
          child: Row(
            children: result.columns
                .map((column) => Expanded(
                      child: InkWell(
                        onTap: () => _sortByColumn(column),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  column,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (_orderBy?.contains(column) == true)
                                Icon(
                                  _orderBy!.contains('DESC') 
                                      ? Icons.arrow_downward 
                                      : Icons.arrow_upward,
                                  size: 16,
                                ),
                            ],
                          ),
                        ),
                      ),
                    ))
                .toList(),
          ),
        ),
        
        // Data rows
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            itemCount: result.data.length,
            itemBuilder: (context, index) {
              final row = result.data[index];
              final isEven = index % 2 == 0;
              
              return Container(
                decoration: BoxDecoration(
                  color: isEven 
                      ? null 
                      : Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                ),
                child: Row(
                  children: result.columns
                      .map((column) => Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              child: SelectableText(
                                _formatCellValue(row[column]),
                                style: const TextStyle(fontSize: 12),
                                maxLines: 3,
                              ),
                            ),
                          ))
                      .toList(),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  /// Build pagination controls
  Widget _buildPaginationControls(QueryResult result) {
    final totalPages = (_getTotalRows() / _pageSize).ceil();
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Theme.of(context).dividerColor),
        ),
      ),
      child: Row(
        children: [
          Text(
            'Page $_currentPage of $totalPages',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          
          const SizedBox(width: 16),
          
          Text(
            'Showing ${result.data.length} of ${_getTotalRows()} rows',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          
          const Spacer(),
          
          // Pagination buttons
          IconButton(
            onPressed: _currentPage > 1 ? _goToFirstPage : null,
            icon: const Icon(Icons.first_page),
            tooltip: 'First Page',
          ),
          
          IconButton(
            onPressed: _currentPage > 1 ? _goToPreviousPage : null,
            icon: const Icon(Icons.chevron_left),
            tooltip: 'Previous Page',
          ),
          
          Container(
            constraints: const BoxConstraints(minWidth: 60),
            child: TextField(
              controller: TextEditingController(text: _currentPage.toString()),
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                isDense: true,
              ),
              onSubmitted: (value) {
                final page = int.tryParse(value);
                if (page != null && page >= 1 && page <= totalPages) {
                  _goToPage(page);
                }
              },
            ),
          ),
          
          IconButton(
            onPressed: _currentPage < totalPages ? _goToNextPage : null,
            icon: const Icon(Icons.chevron_right),
            tooltip: 'Next Page',
          ),
          
          IconButton(
            onPressed: _currentPage < totalPages ? _goToLastPage : null,
            icon: const Icon(Icons.last_page),
            tooltip: 'Last Page',
          ),
        ],
      ),
    );
  }

  /// Build error widget
  Widget _buildErrorWidget(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            const Text(
              'Error Loading Data',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            SelectableText(
              error,
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadData,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  /// Format cell value for display
  String _formatCellValue(dynamic value) {
    if (value == null) return 'NULL';
    if (value is String) {
      if (value.isEmpty) return '(empty)';
      if (value.length > 100) return '${value.substring(0, 100)}...';
    }
    return value.toString();
  }

  /// Get total rows (placeholder - would need API enhancement)
  int _getTotalRows() {
    // This is a simplified approach - in reality, we'd need a separate count query
    final schema = ref.read(tableSchemaProvider(widget.tableName)).value;
    return schema?.rowCount ?? 0;
  }

  /// Sort by column
  void _sortByColumn(String column) {
    setState(() {
      if (_orderBy == '$column ASC') {
        _orderBy = '$column DESC';
      } else {
        _orderBy = '$column ASC';
      }
      _currentPage = 1;
    });
    _loadData();
  }

  /// Perform search
  void _performSearch(String query) {
    if (query.trim().isEmpty) {
      _clearSearch();
      return;
    }

    // Simple search implementation - searches all text columns
    final tableSchemaAsync = ref.read(tableSchemaProvider(widget.tableName));
    tableSchemaAsync.whenData((schema) {
      final textColumns = schema.columns
          .where((col) => col.type.toLowerCase().contains('text') || 
                         col.type.toLowerCase().contains('varchar'))
          .map((col) => col.name)
          .toList();

      if (textColumns.isNotEmpty) {
        final whereClause = textColumns
            .map((col) => '$col LIKE ?')
            .join(' OR ');
        
        setState(() {
          _searchWhere = whereClause;
          _searchArgs = textColumns.map((_) => '%${query.trim()}%').toList();
          _currentPage = 1;
        });
        _loadData();
      }
    });
  }

  /// Clear search
  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _searchWhere = null;
      _searchArgs = null;
      _currentPage = 1;
    });
    _loadData();
  }

  /// Navigate to page
  void _goToPage(int page) {
    setState(() {
      _currentPage = page;
    });
    _loadData();
  }

  /// Go to first page
  void _goToFirstPage() => _goToPage(1);

  /// Go to previous page
  void _goToPreviousPage() => _goToPage(_currentPage - 1);

  /// Go to next page
  void _goToNextPage() => _goToPage(_currentPage + 1);

  /// Go to last page
  void _goToLastPage() {
    final totalPages = (_getTotalRows() / _pageSize).ceil();
    _goToPage(totalPages);
  }

  /// Handle menu actions
  void _handleMenuAction(String action) {
    switch (action) {
      case 'refresh':
        _loadData();
        break;
      case 'export':
        _exportTable();
        break;
      case 'schema':
        _showSchemaDialog();
        break;
      case 'truncate':
        _showTruncateDialog();
        break;
    }
  }

  /// Export table data
  void _exportTable() {
    ref.read(databaseExportProvider.notifier).exportTable(
      widget.tableName,
      where: _searchWhere,
      whereArgs: _searchArgs,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Export started...')),
    );
  }

  /// Show schema dialog
  void _showSchemaDialog() {
    final schemaAsync = ref.read(tableSchemaProvider(widget.tableName));
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${widget.tableName} Schema'),
        content: schemaAsync.when(
          data: (schema) => SizedBox(
            width: double.maxFinite,
            height: 400,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Columns (${schema.columns.length}):'),
                  const SizedBox(height: 8),
                  ...schema.columns.map((col) => ListTile(
                    dense: true,
                    leading: Icon(
                      col.primaryKey ? Icons.key : Icons.table_chart,
                      color: col.primaryKey ? Colors.amber : null,
                    ),
                    title: Text(col.name),
                    subtitle: Text('${col.type}${col.notNull ? ' NOT NULL' : ''}'),
                    trailing: col.defaultValue != null 
                        ? Tooltip(
                            message: 'Default: ${col.defaultValue}',
                            child: const Icon(Icons.info_outline, size: 16),
                          )
                        : null,
                  )),
                ],
              ),
            ),
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Text('Error: $error'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  /// Show truncate confirmation dialog
  void _showTruncateDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Truncate Table'),
        content: Text(
          'Are you sure you want to delete all data from "${widget.tableName}"? '
          'This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _truncateTable();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Truncate'),
          ),
        ],
      ),
    );
  }

  /// Truncate table
  void _truncateTable() {
    ref.read(queryExecutorProvider.notifier).executeModification(
      'DELETE FROM ${widget.tableName}',
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Table truncated')),
    );

    _loadData();
  }
}