import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/data_collection_providers.dart';
import '../../services/data_collection_service.dart';

/// Data Sync Widget - manages data synchronization operations
class DataSyncWidget extends ConsumerStatefulWidget {
  const DataSyncWidget({super.key});

  @override
  ConsumerState<DataSyncWidget> createState() => _DataSyncWidgetState();
}

class _DataSyncWidgetState extends ConsumerState<DataSyncWidget> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(dataSyncStatusProvider.notifier).loadSyncStatus();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final syncStatusAsync = ref.watch(dataSyncStatusProvider);
    final serviceState = ref.watch(dataCollectionServiceProvider);
    
    return SingleChildScrollView(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sync controls
          _buildSyncControls(serviceState),
          
          const SizedBox(height: 24),
          
          // Sync status overview
          syncStatusAsync.when(
            data: (status) => Column(
              children: [
                _buildSyncOverview(status),
                const SizedBox(height: 24),
                _buildRecentOperations(status.recentOperations),
              ],
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => _buildErrorCard(error.toString()),
          ),
        ],
      ),
    );
  }

  /// Build sync controls section
  Widget _buildSyncControls(DataCollectionServiceState serviceState) {
    final theme = Theme.of(context);
    final isLoading = serviceState is _Syncing;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.sync, color: theme.primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Data Synchronization',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                if (isLoading) ...[
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  const SizedBox(width: 8),
                  if (serviceState is _Syncing)
                    Text(
                      serviceState.message,
                      style: theme.textTheme.bodySmall,
                    ),
                ],
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Status message
            if (serviceState is _Success)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.green, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      serviceState.message,
                      style: const TextStyle(color: Colors.green),
                    ),
                  ],
                ),
              )
            else if (serviceState is _Error)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error, color: Colors.red, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        serviceState.message,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ),
            
            if (serviceState is! _Idle) const SizedBox(height: 16),
            
            // Sync buttons
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: _getCrossAxisCount(context),
              childAspectRatio: 3,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              children: [
                _buildSyncButton(
                  icon: Icons.sync,
                  label: 'Sync All Data',
                  description: 'Full synchronization',
                  color: Colors.blue,
                  onPressed: isLoading ? null : () => _syncAllData(),
                ),
                _buildSyncButton(
                  icon: Icons.sports,
                  label: 'Sync Leagues',
                  description: 'Update league data',
                  color: Colors.green,
                  onPressed: isLoading ? null : () => _syncLeagues(),
                ),
                _buildSyncButton(
                  icon: Icons.groups,
                  label: 'Sync Teams',
                  description: 'Update team data',
                  color: Colors.orange,
                  onPressed: isLoading ? null : () => _syncTeams(),
                ),
                _buildSyncButton(
                  icon: Icons.event,
                  label: 'Sync Fixtures',
                  description: 'Update match data',
                  color: Colors.purple,
                  onPressed: isLoading ? null : () => _syncFixtures(),
                ),
                _buildSyncButton(
                  icon: Icons.leaderboard,
                  label: 'Sync Standings',
                  description: 'Update league tables',
                  color: Colors.teal,
                  onPressed: isLoading ? null : () => _syncStandings(),
                ),
                _buildSyncButton(
                  icon: Icons.refresh,
                  label: 'Reset Status',
                  description: 'Clear current status',
                  color: Colors.grey,
                  onPressed: isLoading ? null : () => _resetStatus(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Build sync overview section
  Widget _buildSyncOverview(DataSyncStatus status) {
    final theme = Theme.of(context);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sync Overview',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Statistics grid
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: _getCrossAxisCount(context),
              childAspectRatio: 2.5,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              children: [
                _buildStatCard(
                  'Auto Sync',
                  status.isAutoSyncEnabled ? 'Enabled' : 'Disabled',
                  status.isAutoSyncEnabled ? Icons.check_circle : Icons.cancel,
                  status.isAutoSyncEnabled ? Colors.green : Colors.red,
                ),
                _buildStatCard(
                  'Total Records',
                  _formatNumber(status.totalSyncedRecords),
                  Icons.storage,
                  Colors.blue,
                ),
                _buildStatCard(
                  'Failed Operations',
                  status.failedOperations.toString(),
                  Icons.error,
                  status.failedOperations > 0 ? Colors.red : Colors.green,
                ),
                _buildStatCard(
                  'Last Full Sync',
                  status.lastFullSync != null 
                      ? _formatDateTime(status.lastFullSync!)
                      : 'Never',
                  Icons.sync,
                  Colors.purple,
                ),
              ],
            ),
            
            if (status.nextScheduledSync != null) ...[
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.schedule,
                      size: 16,
                      color: theme.textTheme.bodySmall?.color,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Next scheduled sync: ${_formatDateTime(status.nextScheduledSync!)}',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Build recent operations section
  Widget _buildRecentOperations(List<SyncOperation> operations) {
    final theme = Theme.of(context);
    
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
                  'Recent Operations',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton.icon(
                  onPressed: _refreshStatus,
                  icon: const Icon(Icons.refresh, size: 16),
                  label: const Text('Refresh'),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            if (operations.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Column(
                    children: [
                      Icon(Icons.history, size: 48, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('No recent operations'),
                    ],
                  ),
                ),
              )
            else
              Column(
                children: operations.take(10).map((operation) {
                  return _buildOperationItem(operation);
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }

  /// Build operation item
  Widget _buildOperationItem(SyncOperation operation) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: _getOperationIcon(operation),
        title: Text(operation.description),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${operation.entityType.toUpperCase()} • ${_formatDateTime(operation.timestamp)}'),
            if (operation.recordsProcessed != null)
              Text(
                'Processed: ${operation.recordsProcessed} records',
                style: const TextStyle(fontSize: 12),
              ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _getStatusIcon(operation.status),
            if (operation.completedAt != null)
              Text(
                '${operation.completedAt!.difference(operation.timestamp).inSeconds}s',
                style: const TextStyle(fontSize: 10),
              ),
          ],
        ),
        onTap: () => _showOperationDetails(operation),
      ),
    );
  }

  /// Build sync button
  Widget _buildSyncButton({
    required IconData icon,
    required String label,
    required String description,
    required Color color,
    required VoidCallback? onPressed,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withOpacity(0.1),
        foregroundColor: color,
        elevation: 0,
        padding: const EdgeInsets.all(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 24),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: const TextStyle(fontSize: 11),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Build stat card
  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Build error card
  Widget _buildErrorCard(String error) {
    return Card(
      color: Colors.red.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Icon(Icons.error, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text(
              'Error Loading Sync Status',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 8),
            Text(error, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _refreshStatus,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  /// Get operation icon
  Widget _getOperationIcon(SyncOperation operation) {
    Color color;
    IconData icon;
    
    switch (operation.type.toLowerCase()) {
      case 'sync':
        icon = Icons.sync;
        color = Colors.blue;
        break;
      case 'generate':
        icon = Icons.auto_awesome;
        color = Colors.purple;
        break;
      case 'clean':
        icon = Icons.cleaning_services;
        color = Colors.orange;
        break;
      default:
        icon = Icons.circle;
        color = Colors.grey;
    }
    
    return CircleAvatar(
      backgroundColor: color.withOpacity(0.1),
      child: Icon(icon, color: color, size: 20),
    );
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
      default:
        return const Icon(Icons.circle, color: Colors.grey, size: 20);
    }
  }

  /// Get cross axis count based on screen width
  int _getCrossAxisCount(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 1200) return 3;
    if (width > 800) return 2;
    return 1;
  }

  /// Format number with abbreviations
  String _formatNumber(int number) {
    if (number < 1000) return number.toString();
    if (number < 1000000) return '${(number / 1000).toStringAsFixed(1)}K';
    return '${(number / 1000000).toStringAsFixed(1)}M';
  }

  /// Format date time
  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
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

  /// Show operation details dialog
  void _showOperationDetails(SyncOperation operation) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(operation.description),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Type', operation.type.toUpperCase()),
              _buildDetailRow('Entity', operation.entityType.toUpperCase()),
              _buildDetailRow('Status', operation.status.toUpperCase()),
              _buildDetailRow('Started', operation.timestamp.toString()),
              if (operation.completedAt != null)
                _buildDetailRow('Completed', operation.completedAt.toString()),
              if (operation.recordsProcessed != null)
                _buildDetailRow('Records Processed', operation.recordsProcessed.toString()),
              if (operation.recordsInserted != null)
                _buildDetailRow('Records Inserted', operation.recordsInserted.toString()),
              if (operation.recordsUpdated != null)
                _buildDetailRow('Records Updated', operation.recordsUpdated.toString()),
              if (operation.error != null) ...[
                const SizedBox(height: 8),
                const Text('Error:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(operation.error!, style: const TextStyle(color: Colors.red)),
              ],
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

  /// Build detail row
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  // Action methods
  void _syncAllData() {
    ref.read(dataCollectionServiceProvider.notifier).syncAllData();
  }

  void _syncLeagues() {
    ref.read(dataCollectionServiceProvider.notifier).syncLeagues();
  }

  void _syncTeams() {
    ref.read(dataCollectionServiceProvider.notifier).syncTeams();
  }

  void _syncFixtures() {
    ref.read(dataCollectionServiceProvider.notifier).syncFixtures();
  }

  void _syncStandings() {
    ref.read(dataCollectionServiceProvider.notifier).syncStandings();
  }

  void _resetStatus() {
    ref.read(dataCollectionServiceProvider.notifier).reset();
  }

  void _refreshStatus() {
    ref.refresh(dataSyncStatusProvider);
  }
}