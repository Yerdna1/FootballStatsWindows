import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';

class TrendingLeaguesCard extends StatelessWidget {
  const TrendingLeaguesCard({super.key});

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
                  Icons.trending_up_outlined,
                  color: AppColors.success,
                ),
                const SizedBox(width: 8),
                Text(
                  'Trending Leagues',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    // TODO: Navigate to leagues
                  },
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Trending Leagues List
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 4,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                return _buildLeagueItem(context, index);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeagueItem(BuildContext context, int index) {
    final theme = Theme.of(context);
    
    // Sample data - replace with real data
    final leagues = [
      {
        'name': 'Premier League',
        'country': 'England',
        'matches': '10 matches today',
        'trend': '+15%',
      },
      {
        'name': 'La Liga',
        'country': 'Spain',
        'matches': '6 matches today',
        'trend': '+12%',
      },
      {
        'name': 'Bundesliga',
        'country': 'Germany',
        'matches': '4 matches today',
        'trend': '+8%',
      },
      {
        'name': 'Serie A',
        'country': 'Italy',
        'matches': '5 matches today',
        'trend': '+6%',
      },
    ];

    final league = leagues[index];

    return InkWell(
      onTap: () {
        // TODO: Navigate to league details
      },
      borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
          border: Border.all(
            color: theme.colorScheme.outline.withOpacity(0.1),
          ),
        ),
        child: Row(
          children: [
            // League Logo Placeholder
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.sports_soccer,
                size: 20,
                color: AppColors.primary,
              ),
            ),
            
            const SizedBox(width: 12),
            
            // League Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    league['name']!,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${league['country']} • ${league['matches']}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            
            // Trend Indicator
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.trending_up,
                    size: 12,
                    color: AppColors.success,
                  ),
                  const SizedBox(width: 2),
                  Text(
                    league['trend']!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.success,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}