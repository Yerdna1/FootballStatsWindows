import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/authentication/presentation/pages/login_page.dart';
import '../features/authentication/presentation/pages/register_page.dart';
import '../features/authentication/presentation/pages/profile_page.dart';
import '../features/authentication/presentation/providers/auth_provider.dart';
import '../features/dashboard/presentation/pages/dashboard_page.dart';
import '../features/leagues/presentation/pages/leagues_page.dart';
import '../features/standings/presentation/pages/standings_page.dart';
import '../features/settings/presentation/pages/settings_page.dart';
import '../features/teams/presentation/pages/teams_page.dart';
import '../features/teams/presentation/pages/team_details_page.dart';
import '../navigation/main_navigation.dart';
import '../core/widgets/splash_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);
  
  return GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final isAuthenticating = authState.isLoading;
      final isAuthenticated = authState.hasValue && authState.value != null;
      final isOnAuthPage = state.location.startsWith('/auth');
      
      // Show splash while authenticating
      if (isAuthenticating) {
        return '/splash';
      }
      
      // Redirect to auth if not authenticated and not on auth page
      if (!isAuthenticated && !isOnAuthPage && state.location != '/splash') {
        return '/auth/login';
      }
      
      // Redirect to home if authenticated and on auth page
      if (isAuthenticated && isOnAuthPage) {
        return '/';
      }
      
      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/auth/login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/auth/register',
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: '/auth/profile',
        builder: (context, state) => const ProfilePage(),
      ),
      ShellRoute(
        builder: (context, state, child) => MainNavigation(child: child),
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const DashboardPage(),
          ),
          GoRoute(
            path: '/leagues',
            builder: (context, state) => const LeaguesPage(),
            routes: [
              GoRoute(
                path: '/:leagueId',
                builder: (context, state) {
                  final leagueId = int.parse(state.pathParameters['leagueId']!);
                  return LeagueDetailsPage(leagueId: leagueId);
                },
                routes: [
                  GoRoute(
                    path: '/standings',
                    builder: (context, state) {
                      final leagueId = int.parse(state.pathParameters['leagueId']!);
                      return StandingsPage(leagueId: leagueId);
                    },
                  ),
                  GoRoute(
                    path: '/fixtures',
                    builder: (context, state) {
                      final leagueId = int.parse(state.pathParameters['leagueId']!);
                      return FixturesPage(leagueId: leagueId);
                    },
                  ),
                ],
              ),
            ],
          ),
          GoRoute(
            path: '/teams',
            builder: (context, state) => const TeamsPage(),
            routes: [
              GoRoute(
                path: '/:teamId',
                builder: (context, state) {
                  final teamId = int.parse(state.pathParameters['teamId']!);
                  return TeamDetailsPage(teamId: teamId);
                },
              ),
            ],
          ),
          GoRoute(
            path: '/fixtures',
            builder: (context, state) => const AllFixturesPage(),
            routes: [
              GoRoute(
                path: '/:fixtureId',
                builder: (context, state) {
                  final fixtureId = int.parse(state.pathParameters['fixtureId']!);
                  return FixtureDetailsPage(fixtureId: fixtureId);
                },
              ),
            ],
          ),
          GoRoute(
            path: '/favorites',
            builder: (context, state) => const FavoritesPage(),
          ),
          GoRoute(
            path: '/analytics',
            builder: (context, state) => const AnalyticsPage(),
          ),
          GoRoute(
            path: '/settings',
            builder: (context, state) => const SettingsPage(),
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'Page not found',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'The page you are looking for does not exist.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go('/'),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
  );
});

// Navigation extensions for easier navigation
extension AppRouterExtension on GoRouter {
  void pushLogin() => push('/auth/login');
  void pushRegister() => push('/auth/register');
  void pushProfile() => push('/auth/profile');
  void pushLeagueDetails(int leagueId) => push('/leagues/$leagueId');
  void pushStandings(int leagueId) => push('/leagues/$leagueId/standings');
  void pushFixtures(int leagueId) => push('/leagues/$leagueId/fixtures');
  void pushTeamDetails(int teamId) => push('/teams/$teamId');
  void pushFixtureDetails(int fixtureId) => push('/fixtures/$fixtureId');
}

// Placeholder pages - these will be implemented in the next steps

class LeagueDetailsPage extends StatelessWidget {
  final int leagueId;
  const LeagueDetailsPage({super.key, required this.leagueId});
  @override
  Widget build(BuildContext context) => Scaffold(body: Center(child: Text('League $leagueId')));
}

class FixturesPage extends StatelessWidget {
  final int leagueId;
  const FixturesPage({super.key, required this.leagueId});
  @override
  Widget build(BuildContext context) => Scaffold(body: Center(child: Text('Fixtures $leagueId')));
}

class AllFixturesPage extends StatelessWidget {
  const AllFixturesPage({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(body: Center(child: Text('All Fixtures')));
}

class FixtureDetailsPage extends StatelessWidget {
  final int fixtureId;
  const FixtureDetailsPage({super.key, required this.fixtureId});
  @override
  Widget build(BuildContext context) => Scaffold(body: Center(child: Text('Fixture $fixtureId')));
}

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(body: Center(child: Text('Favorites')));
}

class AnalyticsPage extends StatelessWidget {
  const AnalyticsPage({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(body: Center(child: Text('Analytics')));
}

