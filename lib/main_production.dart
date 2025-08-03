import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:go_router/go_router.dart';

// Import all the features we've built
import 'features/database/presentation/database_browser_page.dart';
import 'features/data_collection/presentation/data_collection_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive
  await Hive.initFlutter();
  
  runApp(
    const ProviderScope(
      child: FootballStatsApp(),
    ),
  );
}

class FootballStatsApp extends ConsumerWidget {
  const FootballStatsApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        ShellRoute(
          builder: (context, state, child) => MainShell(child: child),
          routes: [
            GoRoute(
              path: '/',
              name: 'dashboard',
              pageBuilder: (context, state) => const MaterialPage(
                child: DashboardPage(),
              ),
            ),
            GoRoute(
              path: '/form-analysis',
              name: 'form-analysis',
              pageBuilder: (context, state) => const MaterialPage(
                child: FormAnalysisPage(),
              ),
            ),
            GoRoute(
              path: '/data-collection',
              name: 'data-collection',
              pageBuilder: (context, state) => const MaterialPage(
                child: DataCollectionPage(),
              ),
            ),
            GoRoute(
              path: '/database',
              name: 'database',
              pageBuilder: (context, state) => const MaterialPage(
                child: DatabaseBrowserPage(),
              ),
            ),
            GoRoute(
              path: '/statistics',
              name: 'statistics',
              pageBuilder: (context, state) => const MaterialPage(
                child: StatisticsPage(),
              ),
            ),
            GoRoute(
              path: '/predictions',
              name: 'predictions',
              pageBuilder: (context, state) => const MaterialPage(
                child: PredictionsPage(),
              ),
            ),
            GoRoute(
              path: '/settings',
              name: 'settings',
              pageBuilder: (context, state) => const MaterialPage(
                child: SettingsPage(),
              ),
            ),
          ],
        ),
      ],
    );

    return MaterialApp.router(
      title: 'Football Stats',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
        ),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.green,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
        ),
      ),
      themeMode: ThemeMode.system,
      routerConfig: router,
    );
  }
}

/// Main shell with navigation
class MainShell extends StatelessWidget {
  final Widget child;

  const MainShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            extended: MediaQuery.of(context).size.width > 800,
            selectedIndex: _getSelectedIndex(location),
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.dashboard),
                label: Text('Dashboard'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.analytics),
                label: Text('Form Analysis'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.cloud_download),
                label: Text('Data Collection'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.storage),
                label: Text('Database'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.bar_chart),
                label: Text('Statistics'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.psychology),
                label: Text('Predictions'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.settings),
                label: Text('Settings'),
              ),
            ],
            onDestinationSelected: (index) {
              switch (index) {
                case 0:
                  context.go('/');
                  break;
                case 1:
                  context.go('/form-analysis');
                  break;
                case 2:
                  context.go('/data-collection');
                  break;
                case 3:
                  context.go('/database');
                  break;
                case 4:
                  context.go('/statistics');
                  break;
                case 5:
                  context.go('/predictions');
                  break;
                case 6:
                  context.go('/settings');
                  break;
              }
            },
          ),
          const VerticalDivider(width: 1),
          Expanded(child: child),
        ],
      ),
    );
  }

  int _getSelectedIndex(String location) {
    switch (location) {
      case '/':
        return 0;
      case '/form-analysis':
        return 1;
      case '/data-collection':
        return 2;
      case '/database':
        return 3;
      case '/statistics':
        return 4;
      case '/predictions':
        return 5;
      case '/settings':
        return 6;
      default:
        return 0;
    }
  }
}

/// Dashboard Page
class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Football Stats Dashboard'),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.sports_soccer, size: 100, color: Colors.green),
            SizedBox(height: 24),
            Text(
              'Welcome to Football Stats',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              'Navigate using the sidebar to access different features',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}

/// Form Analysis Page (placeholder)
class FormAnalysisPage extends StatelessWidget {
  const FormAnalysisPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Form Analysis'),
      ),
      body: const Center(
        child: Text('Form Analysis - Coming Soon'),
      ),
    );
  }
}

/// Statistics Page (placeholder)
class StatisticsPage extends StatelessWidget {
  const StatisticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistics'),
      ),
      body: const Center(
        child: Text('Advanced Statistics - Coming Soon'),
      ),
    );
  }
}

/// Predictions Page (placeholder)
class PredictionsPage extends StatelessWidget {
  const PredictionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Match Predictions'),
      ),
      body: const Center(
        child: Text('Match Predictions - Coming Soon'),
      ),
    );
  }
}

/// Settings Page (placeholder)
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: const Center(
        child: Text('Settings - Coming Soon'),
      ),
    );
  }
}