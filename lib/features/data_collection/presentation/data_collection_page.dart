import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/data_collection_providers.dart';
import 'widgets/api_status_card.dart';
import 'widgets/data_sync_widget.dart';
import 'widgets/collection_scheduler_widget.dart';
import 'widgets/api_usage_monitor.dart';
import 'widgets/data_quality_widget.dart';

/// Data Collection Page - Exact port of Python data collection interface
class DataCollectionPage extends ConsumerStatefulWidget {
  const DataCollectionPage({super.key});

  @override
  ConsumerState<DataCollectionPage> createState() => _DataCollectionPageState();
}

class _DataCollectionPageState extends ConsumerState<DataCollectionPage>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    
    // Initialize data collection status
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(apiStatusProvider.notifier).loadApiStatus();
      ref.read(dataSyncStatusProvider.notifier).loadSyncStatus();
      ref.read(apiUsageProvider.notifier).loadUsageStats();
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
        title: const Text('Data Collection'),
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _refreshAllData(),
            tooltip: 'Refresh All Data',
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: _handleMenuAction,
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'sync_all', child: Text('Sync All Data')),
              const PopupMenuItem(value: 'reset_cache', child: Text('Reset Cache')),
              const PopupMenuItem(value: 'export_logs', child: Text('Export Logs')),
              const PopupMenuItem(value: 'settings', child: Text('Collection Settings')),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(icon: Icon(Icons.dashboard), text: 'Overview'),
            Tab(icon: Icon(Icons.sync), text: 'Data Sync'),
            Tab(icon: Icon(Icons.schedule), text: 'Scheduler'),
            Tab(icon: Icon(Icons.analytics), text: 'API Usage'),
            Tab(icon: Icon(Icons.verified), text: 'Data Quality'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(),
          _buildDataSyncTab(),
          _buildSchedulerTab(),
          _buildApiUsageTab(),
          _buildDataQualityTab(),
        ],
      ),
    );
  }

  /// Overview tab with API status and quick actions
  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // API Status Cards
          Consumer(
            builder: (context, ref, child) {
              final apiStatusAsync = ref.watch(apiStatusProvider);
              
              return apiStatusAsync.when(
                data: (status) => Column(
                  children: [
                    ApiStatusCard(status: status),
                    const SizedBox(height: 16),
                    _buildQuickActions(),
                    const SizedBox(height: 16),
                    _buildRecentActivity(),
                  ],
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => _buildErrorCard('API Status Error', error.toString()),
              );
            },
          ),
        ],
      ),
    );
  }

  /// Data sync tab
  Widget _buildDataSyncTab() {
    return const DataSyncWidget();
  }

  /// Scheduler tab
  Widget _buildSchedulerTab() {
    return const CollectionSchedulerWidget();
  }

  /// API usage tab
  Widget _buildApiUsageTab() {
    return const ApiUsageMonitor();
  }

  /// Data quality tab
  Widget _buildDataQualityTab() {
    return const DataQualityWidget();
  }

  /// Build quick actions section
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
            
            // Action buttons grid
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: _getCrossAxisCount(context),
              childAspectRatio: 2.5,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              children: [
                _buildActionButton(
                  icon: Icons.download,
                  label: 'Sync Leagues',
                  color: Colors.blue,
                  onPressed: () => _syncLeagues(),
                ),
                _buildActionButton(
                  icon: Icons.sports_soccer,
                  label: 'Sync Teams',
                  color: Colors.green,
                  onPressed: () => _syncTeams(),
                ),
                _buildActionButton(
                  icon: Icons.event,
                  label: 'Sync Fixtures',
                  color: Colors.orange,
                  onPressed: () => _syncFixtures(),
                ),
                _buildActionButton(
                  icon: Icons.leaderboard,
                  label: 'Sync Standings',
                  color: Colors.purple,
                  onPressed: () => _syncStandings(),
                ),
                _buildActionButton(
                  icon: Icons.analytics,
                  label: 'Generate Stats',
                  color: Colors.teal,
                  onPressed: () => _generateStatistics(),
                ),
                _buildActionButton(
                  icon: Icons.cleaning_services,
                  label: 'Clean Data',
                  color: Colors.red,
                  onPressed: () => _cleanData(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Build recent activity section
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
                  'Recent Collection Activity',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                TextButton(
                  onPressed: () => _tabController.animateTo(1),
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            
            Consumer(
              builder: (context, ref, child) {
                final syncStatusAsync = ref.watch(dataSyncStatusProvider);
                
                return syncStatusAsync.when(
                  data: (status) => Column(
                    children: status.recentOperations.take(5).map((operation) {
                      return ListTile(
                        dense: true,
                        leading: _getOperationIcon(operation.type),
                        title: Text(operation.description),
                        subtitle: Text(
                          '${operation.entityType} • ${_formatTimestamp(operation.timestamp)}',
                        ),
                        trailing: _getStatusIcon(operation.status),
                      );
                    }).toList(),
                  ),
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (error, _) => Text('Error: $error'),
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
    required Color color,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withOpacity(0.1),
        foregroundColor: color,
        elevation: 0,
        padding: const EdgeInsets.all(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 24),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Build error card
  Widget _buildErrorCard(String title, String error) {
    return Card(
      color: Colors.red.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.error, color: Colors.red),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: const TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _refreshAllData,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  /// Get cross axis count based on screen width
  int _getCrossAxisCount(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 1200) return 3;
    if (width > 800) return 2;
    return 1;
  }

  /// Get operation icon
  Widget _getOperationIcon(String operationType) {
    switch (operationType.toLowerCase()) {
      case 'sync':
        return const Icon(Icons.sync, color: Colors.blue);
      case 'download':
        return const Icon(Icons.download, color: Colors.green);
      case 'update':
        return const Icon(Icons.update, color: Colors.orange);
      case 'delete':
        return const Icon(Icons.delete, color: Colors.red);
      case 'export':
        return const Icon(Icons.upload, color: Colors.purple);
      default:
        return const Icon(Icons.circle, color: Colors.grey);
    }
  }

  /// Get status icon
  Widget _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
      case 'success':
        return const Icon(Icons.check_circle, color: Colors.green, size: 20);
      case 'failed':
      case 'error':
        return const Icon(Icons.error, color: Colors.red, size: 20);
      case 'running':
      case 'in_progress':
        return const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        );
      case 'warning':
        return const Icon(Icons.warning, color: Colors.orange, size: 20);
      default:
        return const Icon(Icons.circle, color: Colors.grey, size: 20);
    }
  }

  /// Format timestamp
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
  void _refreshAllData() {
    ref.refresh(apiStatusProvider);
    ref.refresh(dataSyncStatusProvider);
    ref.refresh(apiUsageProvider);
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Data refreshed')),
    );
  }

  /// Handle menu actions
  void _handleMenuAction(String action) {
    switch (action) {
      case 'sync_all':
        _syncAllData();
        break;
      case 'reset_cache':
        _resetCache();
        break;
      case 'export_logs':
        _exportLogs();
        break;
      case 'settings':
        _showSettingsDialog();
        break;
    }
  }

  /// Sync all data
  void _syncAllData() {
    ref.read(dataCollectionServiceStateProvider.notifier).syncAllData();
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Starting full data synchronization...')),
    );
  }

  /// Reset cache
  void _resetCache() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Cache'),
        content: const Text(
          'Are you sure you want to reset all cached data? '
          'This will force a fresh download on the next sync.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ref.read(dataCollectionServiceStateProvider.notifier).resetCache();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Cache reset successfully')),
              );
            },
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  /// Export logs
  void _exportLogs() {
    ref.read(dataCollectionServiceStateProvider.notifier).exportLogs();
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Exporting collection logs...')),
    );
  }

  /// Show settings dialog
  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Collection Settings'),
        content: const SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('API Configuration'),
              SizedBox(height: 8),
              Text('• Auto-sync: Enabled'),
              Text('• Sync interval: 1 hour'),
              Text('• Rate limiting: Active'),
              Text('• Cache duration: 15 minutes'),
              SizedBox(height: 16),
              Text('Data Sources'),
              SizedBox(height: 8),
              Text('• Leagues: Football-API'),
              Text('• Teams: Football-API'),
              Text('• Fixtures: Football-API'),
              Text('• Standings: Football-API'),
              SizedBox(height: 16),
              Text('Quality Controls'),
              SizedBox(height: 8),
              Text('• Data validation: Enabled'),
              Text('• Duplicate detection: Active'),
              Text('• Error reporting: Enabled'),
            ],
          ),
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

  /// Quick action methods
  void _syncLeagues() {
    ref.read(dataCollectionServiceStateProvider.notifier).syncLeagues();
    _showSyncMessage('Syncing leagues...');
  }

  void _syncTeams() {
    ref.read(dataCollectionServiceStateProvider.notifier).syncTeams();
    _showSyncMessage('Syncing teams...');
  }

  void _syncFixtures() {
    ref.read(dataCollectionServiceStateProvider.notifier).syncFixtures();
    _showSyncMessage('Syncing fixtures...');
  }

  void _syncStandings() {
    ref.read(dataCollectionServiceStateProvider.notifier).syncStandings();
    _showSyncMessage('Syncing standings...');
  }

  void _generateStatistics() {
    ref.read(dataCollectionServiceStateProvider.notifier).generateStatistics();
    _showSyncMessage('Generating statistics...');
  }

  void _cleanData() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clean Data'),
        content: const Text(
          'This will remove duplicate and invalid records. Continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ref.read(dataCollectionServiceStateProvider.notifier).cleanData();
              _showSyncMessage('Cleaning data...');
            },
            child: const Text('Clean'),
          ),
        ],
      ),
    );
  }

  /// Show sync message
  void _showSyncMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}