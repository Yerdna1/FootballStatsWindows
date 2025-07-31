import 'package:flutter/material.dart';

import '../../services/data_collection_service.dart';

/// API Status Card - displays current API connection and usage status
class ApiStatusCard extends StatelessWidget {
  final ApiStatusData status;

  const ApiStatusCard({
    super.key,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with connection status
            Row(
              children: [
                Icon(
                  status.isConnected ? Icons.cloud_done : Icons.cloud_off,
                  color: status.isConnected ? Colors.green : Colors.red,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Football API Status',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      status.isConnected ? 'Connected' : 'Disconnected',
                      style: TextStyle(
                        color: status.isConnected ? Colors.green : Colors.red,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                if (status.connectionLatency >= 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getLatencyColor(status.connectionLatency).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _getLatencyColor(status.connectionLatency).withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      '${status.connectionLatency}ms',
                      style: TextStyle(
                        color: _getLatencyColor(status.connectionLatency),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // Usage statistics
            Row(
              children: [
                Expanded(
                  child: _buildUsageCard(
                    context,
                    title: 'Daily Usage',
                    current: status.requestsToday,
                    limit: status.dailyLimit,
                    percentage: status.dailyUsagePercentage,
                    isWarning: status.isNearDailyLimit,
                    icon: Icons.today,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildUsageCard(
                    context,
                    title: 'Per Minute',
                    current: status.requestsThisMinute,
                    limit: status.minuteLimit,
                    percentage: status.minuteUsagePercentage,
                    isWarning: status.isNearMinuteLimit,
                    icon: Icons.timer,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // Last sync times
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Last Synchronization',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                
                Row(
                  children: [
                    Expanded(
                      child: _buildSyncInfo(
                        context,
                        'Leagues',
                        status.lastLeagueSync,
                        Icons.sports,
                        Colors.blue,
                      ),
                    ),
                    Expanded(
                      child: _buildSyncInfo(
                        context,
                        'Teams',
                        status.lastTeamSync,
                        Icons.groups,
                        Colors.green,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 8),
                
                Row(
                  children: [
                    Expanded(
                      child: _buildSyncInfo(
                        context,
                        'Fixtures',
                        status.lastFixtureSync,
                        Icons.event,
                        Colors.orange,
                      ),
                    ),
                    Expanded(
                      child: _buildSyncInfo(
                        context,
                        'Standings',
                        status.lastStandingSync,
                        Icons.leaderboard,
                        Colors.purple,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Reset time info
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
                    Icons.refresh,
                    size: 16,
                    color: theme.textTheme.bodySmall?.color,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Rate limit resets: ${_formatDateTime(status.nextResetTime)}',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build usage statistics card
  Widget _buildUsageCard(
    BuildContext context, {
    required String title,
    required int current,
    required int limit,
    required double percentage,
    required bool isWarning,
    required IconData icon,
  }) {
    final theme = Theme.of(context);
    final color = isWarning ? Colors.orange : Colors.blue;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: isWarning ? 2 : 1,
        ),
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
          
          const SizedBox(height: 8),
          
          Text(
            '$current / $limit',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          
          const SizedBox(height: 4),
          
          LinearProgressIndicator(
            value: limit > 0 ? current / limit : 0,
            backgroundColor: color.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
          
          const SizedBox(height: 4),
          
          Text(
            '${percentage.toStringAsFixed(1)}%',
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  /// Build sync info item
  Widget _buildSyncInfo(
    BuildContext context,
    String label,
    DateTime? lastSync,
    IconData icon,
    Color color,
  ) {
    final theme = Theme.of(context);
    
    return Container(
      margin: const EdgeInsets.only(right: 8),
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
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
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
            lastSync != null ? _formatLastSync(lastSync) : 'Never',
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  /// Get latency color based on response time
  Color _getLatencyColor(int latency) {
    if (latency < 100) return Colors.green;
    if (latency < 500) return Colors.orange;
    return Colors.red;
  }

  /// Format last sync time
  String _formatLastSync(DateTime lastSync) {
    final now = DateTime.now();
    final difference = now.difference(lastSync);
    
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

  /// Format date and time
  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = dateTime.difference(now);
    
    if (difference.inHours < 24) {
      return 'in ${difference.inHours}h ${difference.inMinutes % 60}m';
    } else {
      return 'in ${difference.inDays}d';
    }
  }
}