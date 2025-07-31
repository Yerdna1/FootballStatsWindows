import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../database/providers/database_providers.dart';

/// Activity Log Widget - displays user activity and database operations
class ActivityLogWidget extends ConsumerStatefulWidget {
  const ActivityLogWidget({super.key});

  @override
  ConsumerState<ActivityLogWidget> createState() => _ActivityLogWidgetState();
}

class _ActivityLogWidgetState extends ConsumerState<ActivityLogWidget> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  
  String? _selectedAction;
  String? _selectedEntityType;
  DateTimeRange? _dateRange;
  int _limit = 100;
  
  // Filter options
  final List<String> _actionTypes = [
    'query', 'insert', 'update', 'delete', 'export', 'import', 'create', 'drop', 'alter'
  ];
  
  final List<String> _entityTypes = [
    'sql', 'table', 'query', 'schema', 'data'
  ];
  
  final List<int> _limitOptions = [50, 100, 200, 500, 1000];

  @override
  void initState() {
    super.initState();
    // Load initial activity data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(recentActivityProvider.notifier).loadActivity(limit: _limit);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final activityAsync = ref.watch(recentActivityProvider);
    
    return Card(
      margin: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with title and controls
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.history, color: theme.primaryColor),
                    const SizedBox(width: 8),
                    Text(
                      'Activity Log',
                      style: theme.textTheme.titleMedium,
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.refresh),
                      onPressed: _refreshActivity,
                      tooltip: 'Refresh Activity',
                    ),
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert),
                      onSelected: _handleMenuAction,
                      itemBuilder: (context) => [
                        const PopupMenuItem(value: 'export', child: Text('Export Activity')),
                        const PopupMenuItem(value: 'clear', child: Text('Clear Activity')),
                        const PopupMenuItem(value: 'settings', child: Text('Log Settings')),
                      ],
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Filter controls
                _buildFilterControls(),
              ],
            ),
          ),
          
          const Divider(),
          
          // Activity list
          Expanded(
            child: activityAsync.when(
              data: (activities) => _buildActivityList(activities),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => _buildErrorWidget(error.toString()),
            ),
          ),
          
          // Status bar
          _buildStatusBar(activityAsync),
        ],
      ),
    );
  }

  /// Build filter controls
  Widget _buildFilterControls() {
    return Column(
      children: [
        // Search and action filters
        Row(
          children: [
            Expanded(
              flex: 3,
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  labelText: 'Search activity',
                  hintText: 'Search by action, entity, or details...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            _applyFilters();
                          },
                        )
                      : null,
                  border: const OutlineInputBorder(),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                onSubmitted: (_) => _applyFilters(),
              ),
            ),
            
            const SizedBox(width: 12),
            
            // Action filter dropdown
            DropdownButton<String?>(
              value: _selectedAction,
              hint: const Text('Action'),
              items: [
                const DropdownMenuItem<String?>(
                  value: null,
                  child: Text('All Actions'),
                ),
                ..._actionTypes.map((action) => DropdownMenuItem(
                  value: action,
                  child: Text(action.toUpperCase()),
                )),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedAction = value;
                });
                _applyFilters();
              },
            ),
            
            const SizedBox(width: 12),
            
            // Entity type filter dropdown
            DropdownButton<String?>(
              value: _selectedEntityType,
              hint: const Text('Entity'),
              items: [
                const DropdownMenuItem<String?>(
                  value: null,
                  child: Text('All Entities'),
                ),
                ..._entityTypes.map((entity) => DropdownMenuItem(
                  value: entity,
                  child: Text(entity.toUpperCase()),
                )),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedEntityType = value;
                });
                _applyFilters();
              },
            ),
          ],
        ),
        
        const SizedBox(height: 12),
        
        // Date range and limit controls
        Row(
          children: [
            // Date range picker
            OutlinedButton.icon(
              onPressed: _selectDateRange,
              icon: const Icon(Icons.date_range),
              label: Text(_dateRange != null 
                  ? '${_formatDate(_dateRange!.start)} - ${_formatDate(_dateRange!.end)}'
                  : 'Date Range'),
            ),
            
            if (_dateRange != null) ...[
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  setState(() {
                    _dateRange = null;
                  });
                  _applyFilters();
                },
                tooltip: 'Clear Date Filter',
              ),
            ],
            
            const Spacer(),
            
            // Limit selector
            DropdownButton<int>(
              value: _limit,
              items: _limitOptions.map((limit) => DropdownMenuItem(
                value: limit,
                child: Text('$limit entries'),
              )).toList(),
              onChanged: (newLimit) {
                if (newLimit != null) {
                  setState(() {
                    _limit = newLimit;
                  });
                  _applyFilters();
                }
              },
            ),
          ],
        ),
      ],
    );
  }

  /// Build activity list
  Widget _buildActivityList(List<Map<String, dynamic>> activities) {
    final filteredActivities = _filterActivities(activities);
    
    if (filteredActivities.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('No activity records found'),
            SizedBox(height: 8),
            Text('Try adjusting your filters or date range'),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      itemCount: filteredActivities.length,
      itemBuilder: (context, index) {
        final activity = filteredActivities[index];
        return _buildActivityItem(activity, index);
      },
    );
  }

  /// Build activity item
  Widget _buildActivityItem(Map<String, dynamic> activity, int index) {
    final timestamp = DateTime.parse(activity['timestamp']);
    final action = activity['action'] ?? '';
    final entityType = activity['entity_type'] ?? '';
    final details = activity['details'] ?? '';
    final userId = activity['user_id'] ?? 'System';
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ExpansionTile(
        leading: _getActivityIcon(action),
        title: Row(
          children: [
            Expanded(
              child: Text(
                _getActivityTitle(action, entityType),
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
            Text(
              _formatTimestamp(timestamp),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        subtitle: details.isNotEmpty 
            ? Text(
                details,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
              )
            : null,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildActivityDetail('User ID', userId),
                _buildActivityDetail('Action', action.toUpperCase()),
                _buildActivityDetail('Entity Type', entityType.toUpperCase()),
                if (activity['entity_id'] != null)
                  _buildActivityDetail('Entity ID', activity['entity_id'].toString()),
                _buildActivityDetail('Timestamp', timestamp.toString()),
                if (activity['ip_address'] != null)
                  _buildActivityDetail('IP Address', activity['ip_address']),
                if (activity['user_agent'] != null)
                  _buildActivityDetail('User Agent', activity['user_agent']),
                if (details.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  const Text(
                    'Details:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: SelectableText(
                      details,
                      style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: () => _copyActivityDetails(activity),
                      icon: const Icon(Icons.copy, size: 16),
                      label: const Text('Copy'),
                    ),
                    if (details.contains('SELECT') || details.contains('INSERT') || 
                        details.contains('UPDATE') || details.contains('DELETE')) ...[
                      const SizedBox(width: 8),
                      TextButton.icon(
                        onPressed: () => _rerunQuery(details),
                        icon: const Icon(Icons.play_arrow, size: 16),
                        label: const Text('Re-run'),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build activity detail row
  Widget _buildActivityDetail(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
            ),
          ),
          Expanded(
            child: SelectableText(
              value,
              style: const TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  /// Build status bar
  Widget _buildStatusBar(AsyncValue<List<Map<String, dynamic>>> activityAsync) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Theme.of(context).dividerColor),
        ),
      ),
      child: Row(
        children: [
          activityAsync.when(
            data: (activities) {
              final filteredCount = _filterActivities(activities).length;
              final totalCount = activities.length;
              return Text(
                'Showing $filteredCount of $totalCount activities',
                style: Theme.of(context).textTheme.bodySmall,
              );
            },
            loading: () => const Text('Loading...'),
            error: (_, __) => const Text('Error loading activities'),
          ),
          const Spacer(),
          Text(
            'Limit: $_limit entries',
            style: Theme.of(context).textTheme.bodySmall,
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
              'Error Loading Activity',
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
              onPressed: _refreshActivity,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  /// Get activity icon
  Widget _getActivityIcon(String action) {
    switch (action.toLowerCase()) {
      case 'query':
      case 'select':
        return const Icon(Icons.search, color: Colors.blue);
      case 'insert':
        return const Icon(Icons.add_circle, color: Colors.green);
      case 'update':
        return const Icon(Icons.edit, color: Colors.orange);
      case 'delete':
        return const Icon(Icons.delete, color: Colors.red);
      case 'export':
        return const Icon(Icons.download, color: Colors.purple);
      case 'import':
        return const Icon(Icons.upload, color: Colors.teal);
      case 'create':
        return const Icon(Icons.create_new_folder, color: Colors.indigo);
      case 'drop':
      case 'alter':
        return const Icon(Icons.build, color: Colors.brown);
      default:
        return const Icon(Icons.circle, color: Colors.grey);
    }
  }

  /// Get activity title
  String _getActivityTitle(String action, String entityType) {
    final actionText = action.isNotEmpty ? action.toUpperCase() : 'ACTIVITY';
    final entityText = entityType.isNotEmpty ? entityType.toUpperCase() : '';
    return entityText.isNotEmpty ? '$actionText $entityText' : actionText;
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
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }

  /// Format date
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  /// Filter activities based on current filters
  List<Map<String, dynamic>> _filterActivities(List<Map<String, dynamic>> activities) {
    var filtered = activities;
    
    // Filter by search term
    final searchTerm = _searchController.text.toLowerCase().trim();
    if (searchTerm.isNotEmpty) {
      filtered = filtered.where((activity) {
        final action = (activity['action'] ?? '').toLowerCase();
        final entityType = (activity['entity_type'] ?? '').toLowerCase();
        final details = (activity['details'] ?? '').toLowerCase();
        
        return action.contains(searchTerm) ||
               entityType.contains(searchTerm) ||
               details.contains(searchTerm);
      }).toList();
    }
    
    // Filter by action
    if (_selectedAction != null) {
      filtered = filtered.where((activity) => 
          activity['action']?.toLowerCase() == _selectedAction!.toLowerCase()).toList();
    }
    
    // Filter by entity type
    if (_selectedEntityType != null) {
      filtered = filtered.where((activity) => 
          activity['entity_type']?.toLowerCase() == _selectedEntityType!.toLowerCase()).toList();
    }
    
    // Filter by date range
    if (_dateRange != null) {
      filtered = filtered.where((activity) {
        final timestamp = DateTime.parse(activity['timestamp']);
        return timestamp.isAfter(_dateRange!.start.subtract(const Duration(days: 1))) &&
               timestamp.isBefore(_dateRange!.end.add(const Duration(days: 1)));
      }).toList();
    }
    
    return filtered;
  }

  /// Select date range
  void _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
      initialDateRange: _dateRange,
    );
    
    if (picked != null) {
      setState(() {
        _dateRange = picked;
      });
      _applyFilters();
    }
  }

  /// Apply current filters
  void _applyFilters() {
    // Trigger rebuild with current filters
    setState(() {});
  }

  /// Refresh activity data
  void _refreshActivity() {
    ref.read(recentActivityProvider.notifier).loadActivity(limit: _limit);
  }

  /// Handle menu actions
  void _handleMenuAction(String action) {
    switch (action) {
      case 'export':
        _exportActivity();
        break;
      case 'clear':
        _showClearActivityDialog();
        break;
      case 'settings':
        _showActivitySettings();
        break;
    }
  }

  /// Export activity data
  void _exportActivity() {
    final activities = ref.read(recentActivityProvider).value ?? [];
    final filteredActivities = _filterActivities(activities);
    
    final csvBuffer = StringBuffer();
    csvBuffer.writeln('Timestamp,User ID,Action,Entity Type,Entity ID,Details,IP Address');
    
    for (final activity in filteredActivities) {
      csvBuffer.writeln(
        '${activity['timestamp']},${activity['user_id'] ?? ''},${activity['action'] ?? ''},'
        '${activity['entity_type'] ?? ''},${activity['entity_id'] ?? ''},${activity['details'] ?? ''},'
        '${activity['ip_address'] ?? ''}',
      );
    }
    
    Clipboard.setData(ClipboardData(text: csvBuffer.toString()));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Activity log exported to clipboard')),
    );
  }

  /// Show clear activity dialog
  void _showClearActivityDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Activity Log'),
        content: const Text(
          'Are you sure you want to clear all activity records? '
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
              _clearActivity();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }

  /// Clear activity log
  void _clearActivity() {
    ref.read(queryExecutorProvider.notifier).executeModification(
      'DELETE FROM user_activity',
    );
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Activity log cleared')),
    );
    
    _refreshActivity();
  }

  /// Show activity settings dialog
  void _showActivitySettings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Activity Log Settings'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Activity Logging'),
            SizedBox(height: 16),
            Text('• Log all database operations'),
            Text('• Track user sessions'),
            Text('• Record query execution'),
            Text('• Monitor data exports'),
            SizedBox(height: 16),
            Text('Auto-cleanup: Disabled'),
            Text('Max entries: Unlimited'),
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

  /// Copy activity details
  void _copyActivityDetails(Map<String, dynamic> activity) {
    final buffer = StringBuffer();
    buffer.writeln('Activity Details:');
    buffer.writeln('Timestamp: ${activity['timestamp']}');
    buffer.writeln('User ID: ${activity['user_id'] ?? 'N/A'}');
    buffer.writeln('Action: ${activity['action'] ?? 'N/A'}');
    buffer.writeln('Entity Type: ${activity['entity_type'] ?? 'N/A'}');
    buffer.writeln('Entity ID: ${activity['entity_id'] ?? 'N/A'}');
    buffer.writeln('IP Address: ${activity['ip_address'] ?? 'N/A'}');
    buffer.writeln('Details: ${activity['details'] ?? 'N/A'}');
    
    Clipboard.setData(ClipboardData(text: buffer.toString()));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Activity details copied to clipboard')),
    );
  }

  /// Re-run query from activity
  void _rerunQuery(String query) {
    // Navigate to query tab and set the query
    // This would need to be implemented based on the navigation structure
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Query copied - switch to Query tab to execute')),
    );
    
    Clipboard.setData(ClipboardData(text: query));
  }
}