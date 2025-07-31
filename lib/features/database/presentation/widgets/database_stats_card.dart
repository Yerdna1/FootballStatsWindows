import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/services/database_browser_service.dart';

/// Database statistics overview card
class DatabaseStatsCard extends StatelessWidget {
  final DatabaseStats stats;

  const DatabaseStatsCard({
    super.key,
    required this.stats,
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
            Row(
              children: [
                Icon(
                  Icons.storage, 
                  color: theme.primaryColor,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Database Overview',
                  style: theme.textTheme.titleLarge,
                ),
                const Spacer(),
                Tooltip(
                  message: 'Database Path',
                  child: IconButton(
                    icon: const Icon(Icons.info_outline),
                    onPressed: () => _showDatabaseInfo(context),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Database metrics grid
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: _getCrossAxisCount(context),
              childAspectRatio: 2.5,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              children: [
                _buildMetricCard(
                  context,
                  icon: Icons.folder,
                  title: 'File Size',
                  value: stats.fileSizeFormatted,
                  color: Colors.blue,
                ),
                _buildMetricCard(
                  context,
                  icon: Icons.table_chart,
                  title: 'Tables',
                  value: stats.tableCount.toString(),
                  color: Colors.green,
                ),
                _buildMetricCard(
                  context,
                  icon: Icons.data_array,
                  title: 'Total Rows',
                  value: _formatNumber(stats.totalRows),
                  color: Colors.orange,
                ),
                _buildMetricCard(
                  context,
                  icon: Icons.numbers,
                  title: 'Version',
                  value: 'v${stats.version}',
                  color: Colors.purple,
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Table breakdown
            Text(
              'Table Breakdown',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            
            ...stats.tableStats.map((tableStat) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Text(
                      tableStat.name,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      _formatNumber(tableStat.rowCount),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ),
                  Expanded(
                    child: LinearProgressIndicator(
                      value: stats.totalRows > 0 ? tableStat.rowCount / stats.totalRows : 0,
                      backgroundColor: theme.colorScheme.surfaceVariant,
                    ),
                  ),
                ],
              ),
            )),
            
            const SizedBox(height: 16),
            
            // Last modified info
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 16,
                  color: theme.textTheme.bodySmall?.color,
                ),
                const SizedBox(width: 4),
                Text(
                  'Last modified: ${_formatDateTime(stats.lastModified)}',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Build metric card
  Widget _buildMetricCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  /// Get cross axis count based on screen width
  int _getCrossAxisCount(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 1200) return 4;
    if (width > 800) return 3;
    if (width > 600) return 2;
    return 1;
  }

  /// Format number with commas
  String _formatNumber(int number) {
    if (number < 1000) return number.toString();
    if (number < 1000000) return '${(number / 1000).toStringAsFixed(1)}K';
    return '${(number / 1000000).toStringAsFixed(1)}M';
  }

  /// Format date time
  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays > 7) {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }

  /// Show database info dialog
  void _showDatabaseInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Database Information'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildInfoRow('File Path:', stats.filePath),
              _buildInfoRow('File Size:', stats.fileSizeFormatted),
              _buildInfoRow('Version:', 'v${stats.version}'),
              _buildInfoRow('Tables:', stats.tableCount.toString()),
              _buildInfoRow('Total Rows:', stats.totalRows.toString()),
              _buildInfoRow('Last Modified:', _formatDateTime(stats.lastModified)),
              const SizedBox(height: 16),
              const Text(
                'Table Details:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...stats.tableStats.map((tableStat) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(tableStat.name),
                    Text('${tableStat.rowCount} rows'),
                  ],
                ),
              )),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: stats.filePath));
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Database path copied to clipboard')),
              );
            },
            child: const Text('Copy Path'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  /// Build info row
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: SelectableText(value),
          ),
        ],
      ),
    );
  }
}