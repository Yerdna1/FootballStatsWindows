import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';

class FavoriteTeamsCard extends StatelessWidget {
  const FavoriteTeamsCard({super.key});

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
                  Icons.favorite_outlined,
                  color: AppColors.error,
                ),
                const SizedBox(width: 8),
                Text(
                  'Favorite Teams',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    // TODO: Navigate to favorites
                  },
                  child: const Text('Manage'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Favorite Teams Horizontal Scroll
            SizedBox(
              height: 100,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: 3, // Sample count
                separatorBuilder: (context, index) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  return _buildTeamCard(context, index);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTeamCard(BuildContext context, int index) {
    final theme = Theme.of(context);
    
    // Sample data - replace with real data
    final teams = [
      {
        'name': 'Manchester United',
        'position': '3rd',
        'league': 'Premier League',
        'form': 'WWLDW',
      },
      {
        'name': 'Barcelona',
        'position': '2nd',
        'league': 'La Liga',
        'form': 'WWWDL',
      },
      {
        'name': 'Bayern Munich',
        'position': '1st',
        'league': 'Bundesliga',
        'form': 'WWWWW',
      },
    ];

    final team = teams[index];

    return Container(
      width: 140,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Team Logo Placeholder
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              Icons.sports_soccer,
              size: 16,
              color: AppColors.primary,
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Team Name
          Text(
            team['name']!,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          
          const SizedBox(height: 4),
          
          // Position and League
          Text(
            '${team['position']} • ${team['league']}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}