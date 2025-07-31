import 'package:flutter/material.dart';

import '../../domain/entities/team_entity.dart';
import '../../../../shared/widgets/indicators/statistics_bar.dart';

class TeamStatisticsSection extends StatelessWidget {
  final TeamEntity team;

  const TeamStatisticsSection({super.key, required this.team});

  @override
  Widget build(BuildContext context) {
    if (team.statistics == null) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bar_chart,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'No statistics available',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    final stats = team.statistics!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Overall Performance Card
          _buildStatisticsCard(
            context,
            'Overall Performance',
            [
              _buildStatRow(
                context,
                'Games Played',
                stats.playedGames.toString(),
                null,
              ),
              _buildStatRow(
                context,
                'Points',
                stats.points.toString(),
                stats.pointsPerGame > 0 ? '${stats.pointsPerGame.toStringAsFixed(1)} per game' : null,
              ),
              _buildStatRow(
                context,
                'Points per Game',
                stats.pointsPerGame.toStringAsFixed(2),
                null,
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Match Results Card
          _buildStatisticsCard(
            context,
            'Match Results',
            [
              _buildResultBar(context, 'Wins', stats.won, stats.playedGames, Colors.green),
              _buildResultBar(context, 'Draws', stats.draw, stats.playedGames, Colors.orange),
              _buildResultBar(context, 'Losses', stats.lost, stats.playedGames, Colors.red),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Win Percentages Card
          _buildStatisticsCard(
            context,
            'Performance Breakdown',
            [
              _buildPercentageRow(context, 'Win Rate', team.winPercentage, Colors.green),
              _buildPercentageRow(context, 'Draw Rate', team.drawPercentage, Colors.orange),
              _buildPercentageRow(context, 'Loss Rate', team.lossPercentage, Colors.red),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Goals Statistics Card
          _buildStatisticsCard(
            context,
            'Goals Statistics',
            [
              _buildStatRow(
                context,
                'Goals For',
                stats.goalsFor.toString(),
                stats.averageGoalsFor > 0 ? '${stats.averageGoalsFor.toStringAsFixed(1)} per game' : null,
              ),
              _buildStatRow(
                context,
                'Goals Against',
                stats.goalsAgainst.toString(),
                stats.averageGoalsAgainst > 0 ? '${stats.averageGoalsAgainst.toStringAsFixed(1)} per game' : null,
              ),
              _buildStatRow(
                context,
                'Goal Difference',
                stats.goalDifference >= 0 ? '+${stats.goalDifference}' : stats.goalDifference.toString(),
                null,
                valueColor: stats.goalDifference > 0 
                    ? Colors.green 
                    : stats.goalDifference < 0 
                        ? Colors.red 
                        : null,
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Form Card
          _buildStatisticsCard(
            context,
            'Current Form',
            [
              _buildStatRow(
                context,
                'Form',
                team.formDisplay,
                null,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsCard(BuildContext context, String title, List<Widget> children) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(
    BuildContext context,
    String label,
    String value,
    String? subtitle, {
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: valueColor ?? Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultBar(BuildContext context, String label, int value, int total, Color color) {
    final percentage = total > 0 ? (value / total) : 0.0;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '$value (${(percentage * 100).toStringAsFixed(1)}%)',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          StatisticsBar(
            value: percentage,
            color: color,
            height: 8,
          ),
        ],
      ),
    );
  }

  Widget _buildPercentageRow(BuildContext context, String label, double percentage, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: color.withOpacity(0.3)),
            ),
            child: Text(
              '${percentage.toStringAsFixed(1)}%',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color[700],
              ),
            ),
          ),
        ],
      ),
    );
  }
}