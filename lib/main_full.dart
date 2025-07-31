import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'firebase_options.dart';
import 'core/theme/app_theme.dart';
import 'core/services/football_data_service.dart';
import 'shared/providers/connectivity_provider.dart';
import 'shared/providers/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase initialization failed: $e');
    debugPrint('Running in demo mode...');
  }
  
  // Initialize Hive for local storage
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
    final themeMode = ref.watch(themeModeProvider);
    final connectivityStatus = ref.watch(connectivityProvider);

    return MaterialApp(
      title: 'Football Stats',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      home: const DashboardPage(),
      builder: (context, child) {
        return Scaffold(
          body: Stack(
            children: [
              child ?? const SizedBox.shrink(),
              if (connectivityStatus == ConnectivityStatus.disconnected)
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 30,
                    color: Colors.red,
                    child: const Center(
                      child: Text(
                        'No Internet Connection',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({super.key});

  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Football Stats'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _showSearchDialog(),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _refreshData(),
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: const [
          HomePage(),
          LeaguesPage(),
          TeamsPage(),
          FixturesPage(),
          StandingsPage(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.emoji_events),
            label: 'Leagues',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.groups),
            label: 'Teams',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.sports_soccer),
            label: 'Fixtures',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.leaderboard),
            label: 'Standings',
          ),
        ],
      ),
    );
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => const SearchDialog(),
    );
  }

  void _refreshData() {
    // Implement data refresh
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Refreshing data...'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossOrientation: CrossOrientation.start,
        children: [
          _buildWelcomeCard(),
          const SizedBox(height: 20),
          _buildLiveScoresSection(ref),
          const SizedBox(height: 20),
          _buildTodayFixturesSection(ref),
          const SizedBox(height: 20),
          _buildPopularLeaguesSection(ref),
        ],
      ),
    );
  }

  Widget _buildWelcomeCard() {
    return Card(
      elevation: 4,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: const LinearGradient(
            colors: [Colors.blue, Colors.blueAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: const Column(
          children: [
            Icon(
              Icons.sports_soccer,
              size: 60,
              color: Colors.white,
            ),
            SizedBox(height: 10),
            Text(
              'Welcome to Football Stats!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 5),
            Text(
              'Your comprehensive football statistics app',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLiveScoresSection(WidgetRef ref) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.live_tv, color: Colors.red),
                const SizedBox(width: 8),
                const Text(
                  'Live Scores',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => _loadLiveScores(ref),
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _buildAPITestButton(
              'Load Live Scores',
              () => _loadLiveScores(ref),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTodayFixturesSection(WidgetRef ref) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.today, color: Colors.orange),
                const SizedBox(width: 8),
                const Text(
                  'Today\'s Fixtures',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => _loadTodayFixtures(ref),
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _buildAPITestButton(
              'Load Today\'s Fixtures',
              () => _loadTodayFixtures(ref),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPopularLeaguesSection(WidgetRef ref) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.emoji_events, color: Colors.amber),
                const SizedBox(width: 8),
                const Text(
                  'Popular Leagues',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => _loadPopularLeagues(ref),
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _buildAPITestButton(
              'Load Popular Leagues',
              () => _loadPopularLeagues(ref),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAPITestButton(String label, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        child: Text(label),
      ),
    );
  }

  void _loadLiveScores(WidgetRef ref) async {
    try {
      final footballService = ref.read(footballDataServiceProvider);
      final liveScores = await footballService.getLiveScores();
      debugPrint('Live Scores: $liveScores');
    } catch (e) {
      debugPrint('Error loading live scores: $e');
    }
  }

  void _loadTodayFixtures(WidgetRef ref) async {
    try {
      final footballService = ref.read(footballDataServiceProvider);
      final todayFixtures = await footballService.getTodaysFixtures();
      debugPrint('Today\'s Fixtures: $todayFixtures');
    } catch (e) {
      debugPrint('Error loading today\'s fixtures: $e');
    }
  }

  void _loadPopularLeagues(WidgetRef ref) async {
    try {
      final footballService = ref.read(footballDataServiceProvider);
      final popularLeagues = await footballService.getPopularLeaguesOverview();
      debugPrint('Popular Leagues: $popularLeagues');
    } catch (e) {
      debugPrint('Error loading popular leagues: $e');
    }
  }
}

// Placeholder pages for other tabs
class LeaguesPage extends StatelessWidget {
  const LeaguesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Leagues Page',
        style: TextStyle(fontSize: 24),
      ),
    );
  }
}

class TeamsPage extends StatelessWidget {
  const TeamsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Teams Page',
        style: TextStyle(fontSize: 24),
      ),
    );
  }
}

class FixturesPage extends StatelessWidget {
  const FixturesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Fixtures Page',
        style: TextStyle(fontSize: 24),
      ),
    );
  }
}

class StandingsPage extends StatelessWidget {
  const StandingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Standings Page',
        style: TextStyle(fontSize: 24),
      ),
    );
  }
}

class SearchDialog extends ConsumerStatefulWidget {
  const SearchDialog({super.key});

  @override
  ConsumerState<SearchDialog> createState() => _SearchDialogState();
}

class _SearchDialogState extends ConsumerState<SearchDialog> {
  final _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Search Football Data'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _searchController,
            decoration: const InputDecoration(
              hintText: 'Search teams, leagues...',
              prefixIcon: Icon(Icons.search),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => _performSearch(),
            child: const Text('Search'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
      ],
    );
  }

  void _performSearch() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    try {
      final footballService = ref.read(footballDataServiceProvider);
      final searchResults = await footballService.globalSearch(query);
      debugPrint('Search Results: $searchResults');
      
      Navigator.of(context).pop();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Found ${searchResults['totalResults']} results for "$query"'),
        ),
      );
    } catch (e) {
      debugPrint('Error performing search: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Search failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}