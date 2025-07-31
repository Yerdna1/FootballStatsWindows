import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

import '../../domain/entities/team_entity.dart';
import '../../../../shared/widgets/cards/team_card.dart';

class TeamsGridView extends StatelessWidget {
  final List<TeamEntity> teams;
  final ScrollController scrollController;
  final bool isLoading;
  final bool hasReachedMax;
  final Function(TeamEntity) onTeamTap;

  const TeamsGridView({
    super.key,
    required this.teams,
    required this.scrollController,
    required this.isLoading,
    required this.hasReachedMax,
    required this.onTeamTap,
  });

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      controller: scrollController,
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverGrid(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: _getCrossAxisCount(context),
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.8,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                return AnimationConfiguration.staggeredGrid(
                  position: index,
                  duration: const Duration(milliseconds: 375),
                  columnCount: _getCrossAxisCount(context),
                  child: ScaleAnimation(
                    child: FadeInAnimation(
                      child: TeamCard(
                        team: teams[index],
                        onTap: () => onTeamTap(teams[index]),
                      ),
                    ),
                  ),
                );
              },
              childCount: teams.length,
            ),
          ),
        ),
        
        // Loading indicator at bottom
        if (isLoading && teams.isNotEmpty)
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          ),
        
        // End of list indicator
        if (!isLoading && hasReachedMax && teams.isNotEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: Text(
                  'No more teams to load',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).hintColor,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  int _getCrossAxisCount(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 1200) return 4;
    if (width > 800) return 3;
    if (width > 600) return 2;
    return 1;
  }
}