import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/constants/app_constants.dart';
import '../core/theme/app_colors.dart';

class MainNavigation extends ConsumerWidget {
  final Widget child;

  const MainNavigation({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocation = GoRouterState.of(context).location;
    
    return Scaffold(
      body: child,
      bottomNavigationBar: _buildBottomNavigationBar(context, currentLocation),
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context, String currentLocation) {
    final selectedIndex = _getSelectedIndex(currentLocation);
    
    return NavigationBar(
      selectedIndex: selectedIndex,
      onDestinationSelected: (index) => _onDestinationSelected(context, index),
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.dashboard_outlined),
          selectedIcon: Icon(Icons.dashboard),
          label: 'Dashboard',
        ),
        NavigationDestination(
          icon: Icon(Icons.sports_soccer_outlined),
          selectedIcon: Icon(Icons.sports_soccer),
          label: 'Leagues',
        ),
        NavigationDestination(
          icon: Icon(Icons.group_outlined),
          selectedIcon: Icon(Icons.group),
          label: 'Teams',
        ),
        NavigationDestination(
          icon: Icon(Icons.calendar_today_outlined),
          selectedIcon: Icon(Icons.calendar_today),
          label: 'Fixtures',
        ),
        NavigationDestination(
          icon: Icon(Icons.favorite_outline),
          selectedIcon: Icon(Icons.favorite),
          label: 'Favorites',
        ),
      ],
    );
  }

  int _getSelectedIndex(String location) {
    if (location.startsWith('/leagues')) return 1;
    if (location.startsWith('/teams')) return 2;
    if (location.startsWith('/fixtures')) return 3;
    if (location.startsWith('/favorites')) return 4;
    return 0; // Dashboard
  }

  void _onDestinationSelected(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/');
        break;
      case 1:
        context.go('/leagues');
        break;
      case 2:
        context.go('/teams');
        break;
      case 3:
        context.go('/fixtures');
        break;
      case 4:
        context.go('/favorites');
        break;
    }
  }
}

// Custom Navigation Bar for Web/Desktop with side navigation
class SideNavigation extends ConsumerWidget {
  final Widget child;

  const SideNavigation({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocation = GoRouterState.of(context).location;
    final selectedIndex = _getSelectedIndex(currentLocation);
    
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: selectedIndex,
            onDestinationSelected: (index) => _onDestinationSelected(context, index),
            labelType: NavigationRailLabelType.all,
            backgroundColor: Theme.of(context).colorScheme.surface,
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.dashboard_outlined),
                selectedIcon: Icon(Icons.dashboard),
                label: Text('Dashboard'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.sports_soccer_outlined),
                selectedIcon: Icon(Icons.sports_soccer),
                label: Text('Leagues'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.group_outlined),
                selectedIcon: Icon(Icons.group),
                label: Text('Teams'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.calendar_today_outlined),
                selectedIcon: Icon(Icons.calendar_today),
                label: Text('Fixtures'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.favorite_outline),
                selectedIcon: Icon(Icons.favorite),
                label: Text('Favorites'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.analytics_outlined),
                selectedIcon: Icon(Icons.analytics),
                label: Text('Analytics'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.settings_outlined),
                selectedIcon: Icon(Icons.settings),
                label: Text('Settings'),
              ),
            ],
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(child: child),
        ],
      ),
    );
  }

  int _getSelectedIndex(String location) {
    if (location.startsWith('/leagues')) return 1;
    if (location.startsWith('/teams')) return 2;
    if (location.startsWith('/fixtures')) return 3;
    if (location.startsWith('/favorites')) return 4;
    if (location.startsWith('/analytics')) return 5;
    if (location.startsWith('/settings')) return 6;
    return 0; // Dashboard
  }

  void _onDestinationSelected(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/');
        break;
      case 1:
        context.go('/leagues');
        break;
      case 2:
        context.go('/teams');
        break;
      case 3:
        context.go('/fixtures');
        break;
      case 4:
        context.go('/favorites');
        break;
      case 5:
        context.go('/analytics');
        break;
      case 6:
        context.go('/settings');
        break;
    }
  }
}

// Responsive Navigation that switches between bottom and side navigation
class ResponsiveNavigation extends ConsumerWidget {
  final Widget child;

  const ResponsiveNavigation({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= AppConstants.tabletBreakpoint) {
          return SideNavigation(child: child);
        } else {
          return MainNavigation(child: child);
        }
      },
    );
  }
}