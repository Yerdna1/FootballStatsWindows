import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/date_formatter.dart';

class RecentMatchesCard extends StatelessWidget {
  const RecentMatchesCard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.sports_score_outlined,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Recent Matches',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    // TODO: Navigate to all fixtures
                  },
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Sample Matches List
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 3,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                return _buildMatchItem(context, index);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMatchItem(BuildContext context, int index) {
    final theme = Theme.of(context);
    
    // Sample data - replace with real data
    final matches = [
      {
        'homeTeam': 'Manchester United',
        'awayTeam': 'Liverpool',
        'homeScore': '2',
        'awayScore': '1',
        'status': 'FT',
        'time': '90+3\'',
        'league': 'Premier League',
      },
      {
        'homeTeam': 'Barcelona',
        'awayTeam': 'Real Madrid',
        'homeScore': '1',
        'awayScore': '3',
        'status': 'FT',
        'time': '90\'',
        'league': 'La Liga',
      },
      {
        'homeTeam': 'Bayern Munich',
        'awayTeam': 'Dortmund',
        'homeScore': '2',
        'awayScore': '2',
        'status': 'LIVE',
        'time': '67\'',
        'league': 'Bundesliga',
      },
    ];

    final match = matches[index];
    final isLive = match['status'] == 'LIVE';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          // League Badge Placeholder
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              Icons.sports_soccer,
              size: 16,
              color: AppColors.primary,
            ),
          ),
          
          const SizedBox(width: 12),
          
          // Match Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Teams and Score
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        match['homeTeam']!,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isLive 
                            ? AppColors.error.withOpacity(0.1)
                            : theme.colorScheme.surfaceVariant,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '${match['homeScore']} - ${match['awayScore']}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isLive ? AppColors.error : null,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        match['awayTeam']!,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.end,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 4),
                
                // League and Status
                Row(
                  children: [
                    Text(
                      match['league']!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: isLive 
                            ? AppColors.error
                            : AppColors.success,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        isLive ? match['time']! : match['status']!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}