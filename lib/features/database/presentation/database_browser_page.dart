import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:data_table_2/data_table_2.dart';

import '../../../core/services/database_browser_service.dart';
import '../providers/database_providers.dart';
import 'widgets/database_stats_card.dart';
import 'widgets/query_executor_widget.dart';
import 'widgets/table_browser_widget.dart';
import 'widgets/schema_viewer_widget.dart';
import 'widgets/activity_log_widget.dart';

/// Database Browser Page - Exact port of Python database browser interface
class DatabaseBrowserPage extends ConsumerStatefulWidget {
  const DatabaseBrowserPage({super.key});

  @override
  ConsumerState<DatabaseBrowserPage> createState() => _DatabaseBrowserPageState();
}

class _DatabaseBrowserPageState extends ConsumerState<DatabaseBrowserPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  String? _selectedTable;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    
    // Initialize database and load initial data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(databaseStatsProvider.notifier).loadStats();
      ref.read(tableNamesProvider.notifier).loadTableNames();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Database Browser'),
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _refreshData(),
            tooltip: 'Refresh Data',
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: _handleMenuAction,
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'vacuum', child: Text('Vacuum Database')),
              const PopupMenuItem(value: 'analyze', child: Text('Analyze Database')),
              const PopupMenuItem(value: 'export', child: Text('Export Database')),
              const PopupMenuItem(value: 'settings', child: Text('Settings')),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(icon: Icon(Icons.dashboard), text: 'Overview'),
            Tab(icon: Icon(Icons.table_chart), text: 'Tables'),
            Tab(icon: Icon(Icons.code), text: 'Query'),
            Tab(icon: Icon(Icons.schema), text: 'Schema'),
            Tab(icon: Icon(Icons.history), text: 'Activity'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(),
          _buildTablesTab(),
          _buildQueryTab(),
          _buildSchemaTab(),
          _buildActivityTab(),
        ],
      ),
    );
  }

  /// Overview tab with database statistics
  Widget _buildOverviewTab() {
    return Consumer(
      builder: (context, ref, child) {
        final statsAsync = ref.watch(databaseStatsProvider);
        
        return statsAsync.when(
          data: (stats) => SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DatabaseStatsCard(stats: stats),
                const SizedBox(height: 24),
                _buildQuickActions(),
                const SizedBox(height: 24),
                _buildRecentActivity(),
              ],
            ),
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error, size: 64, color: Theme.of(context).colorScheme.error),
                const SizedBox(height: 16),
                Text('Error loading database stats'),
                const SizedBox(height: 8),
                Text(error.toString(), style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => ref.refresh(databaseStatsProvider),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Tables tab with table browser
  Widget _buildTablesTab() {
    return Consumer(
      builder: (context, ref, child) {
        final tableNamesAsync = ref.watch(tableNamesProvider);
        
        return tableNamesAsync.when(
          data: (tableNames) => Row(
            children: [
              // Table list sidebar
              SizedBox(
                width: 250,
                child: Card(
                  margin: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          'Tables (${tableNames.length})',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      const Divider(),
                      Expanded(
                        child: ListView.builder(
                          itemCount: tableNames.length,
                          itemBuilder: (context, index) {
                            final tableName = tableNames[index];
                            final isSelected = _selectedTable == tableName;
                            
                            return ListTile(
                              dense: true,
                              selected: isSelected,
                              leading: const Icon(Icons.table_chart),
                              title: Text(tableName),
                              onTap: () => setState(() => _selectedTable = tableName),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Table data view
              Expanded(
                child: _selectedTable != null
                    ? TableBrowserWidget(tableName: _selectedTable!)
                    : const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.table_chart, size: 64, color: Colors.grey),
                            SizedBox(height: 16),
                            Text('Select a table to view its data'),
                          ],
                        ),
                      ),
              ),
            ],
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error, size: 64, color: Theme.of(context).colorScheme.error),
                const SizedBox(height: 16),
                Text('Error loading tables'),
                const SizedBox(height: 8),
                Text(error.toString(), style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Query tab with SQL executor
  Widget _buildQueryTab() {
    return const QueryExecutorWidget();
  }

  /// Schema tab with database schema viewer
  Widget _buildSchemaTab() {
    return Consumer(
      builder: (context, ref, child) {
        final tableNamesAsync = ref.watch(tableNamesProvider);
        
        return tableNamesAsync.when(
          data: (tableNames) => Row(
            children: [
              // Table list sidebar
              SizedBox(
                width: 250,
                child: Card(
                  margin: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          'Schema',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      const Divider(),
                      Expanded(
                        child: ListView.builder(
                          itemCount: tableNames.length,
                          itemBuilder: (context, index) {
                            final tableName = tableNames[index];
                            final isSelected = _selectedTable == tableName;
                            
                            return ListTile(
                              dense: true,
                              selected: isSelected,
                              leading: const Icon(Icons.schema),
                              title: Text(tableName),
                              onTap: () => setState(() => _selectedTable = tableName),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Schema details view
              Expanded(
                child: _selectedTable != null
                    ? SchemaViewerWidget(tableName: _selectedTable!)
                    : const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.schema, size: 64, color: Colors.grey),
                            SizedBox(height: 16),
                            Text('Select a table to view its schema'),
                          ],
                        ),
                      ),
              ),
            ],
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(
            child: Text('Error loading schema: $error'),
          ),
        );
      },
    );
  }

  /// Activity tab with user activity log
  Widget _buildActivityTab() {
    return const ActivityLogWidget();
  }

  /// Quick actions section
  Widget _buildQuickActions() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quick Actions',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildActionButton(
                  icon: Icons.add,
                  label: 'New Query',
                  onPressed: () => _tabController.animateTo(2),
                ),
                _buildActionButton(
                  icon: Icons.download,
                  label: 'Export Data',
                  onPressed: () => _showExportDialog(),
                ),
                _buildActionButton(
                  icon: Icons.cleaning_services,
                  label: 'Vacuum DB',
                  onPressed: () => _vacuumDatabase(),
                ),
                _buildActionButton(
                  icon: Icons.analytics,
                  label: 'Analyze DB',
                  onPressed: () => _analyzeDatabase(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Recent activity section
  Widget _buildRecentActivity() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Activity',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                TextButton(
                  onPressed: () => _tabController.animateTo(4),
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Consumer(
              builder: (context, ref, child) {
                final activityAsync = ref.watch(recentActivityProvider);
                
                return activityAsync.when(
                  data: (activities) => activities.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.all(16),
                          child: Text('No recent activity'),
                        )
                      : Column(
                          children: activities.take(5).map((activity) {
                            final timestamp = DateTime.parse(activity['timestamp']);
                            return ListTile(
                              dense: true,
                              leading: _getActivityIcon(activity['action']),
                              title: Text(activity['action'] ?? ''),
                              subtitle: Text(
                                '${activity['entity_type']} • ${_formatTimestamp(timestamp)}',
                              ),
                              trailing: activity['details'] != null
                                  ? Tooltip(
                                      message: activity['details'],
                                      child: const Icon(Icons.info_outline, size: 16),
                                    )
                                  : null,
                            );
                          }).toList(),
                        ),
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (error, stack) => Text('Error: $error'),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Build action button
  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }

  /// Get activity icon
  Widget _getActivityIcon(String? action) {
    switch (action?.toLowerCase()) {
      case 'query':
        return const Icon(Icons.search, color: Colors.blue);
      case 'export':
        return const Icon(Icons.download, color: Colors.green);
      case 'import':
        return const Icon(Icons.upload, color: Colors.orange);
      case 'delete':
        return const Icon(Icons.delete, color: Colors.red);
      case 'update':
        return const Icon(Icons.edit, color: Colors.purple);
      case 'insert':
        return const Icon(Icons.add, color: Colors.teal);
      default:
        return const Icon(Icons.circle, color: Colors.grey);
    }
  }

  /// Format timestamp for display
  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  /// Refresh all data
  void _refreshData() {
    ref.refresh(databaseStatsProvider);
    ref.refresh(tableNamesProvider);
    ref.refresh(recentActivityProvider);
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Data refreshed')),
    );
  }

  /// Handle menu actions
  void _handleMenuAction(String action) {
    switch (action) {
      case 'vacuum':
        _vacuumDatabase();
        break;
      case 'analyze':
        _analyzeDatabase();
        break;
      case 'export':
        _showExportDialog();
        break;
      case 'settings':
        _showSettingsDialog();
        break;
    }
  }

  /// Vacuum database
  void _vacuumDatabase() async {
    try {
      final service = ref.read(databaseBrowserServiceProvider);
      await service.vacuumDatabase();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Database vacuumed successfully')),
      );
      
      _refreshData();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error vacuuming database: $e')),
      );
    }
  }

  /// Analyze database
  void _analyzeDatabase() async {
    try {
      final service = ref.read(databaseBrowserServiceProvider);
      await service.analyzeDatabase();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Database analyzed successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error analyzing database: $e')),
      );
    }
  }

  /// Show export dialog
  void _showExportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export Database'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.file_copy),
              title: Text('Export All Tables'),
              subtitle: Text('Export all data as CSV files'),
            ),
            ListTile(
              leading: Icon(Icons.table_chart),
              title: Text('Export Selected Table'),
              subtitle: Text('Export specific table data'),
            ),
            ListTile(
              leading: Icon(Icons.code),
              title: Text('Export Query Result'),
              subtitle: Text('Export custom query results'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: Implement export functionality
            },
            child: const Text('Export'),
          ),
        ],
      ),
    );
  }

  /// Show settings dialog
  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Database Settings'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Database Configuration'),
            SizedBox(height: 16),
            // TODO: Add database settings options
            Text('• Auto-vacuum: Enabled'),
            Text('• WAL mode: Enabled'),
            Text('• Cache size: 2MB'),
            Text('• Synchronous: NORMAL'),
          ],
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
}