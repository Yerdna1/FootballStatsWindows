import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase initialization failed: $e');
  }
  
  runApp(
    const ProviderScope(
      child: FootballStatsApp(),
    ),
  );
}

class FootballStatsApp extends StatelessWidget {
  const FootballStatsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Football Stats',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.green,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const MainPage(),
    );
  }
}

class MainPage extends ConsumerStatefulWidget {
  const MainPage({super.key});

  @override
  ConsumerState<MainPage> createState() => _MainPageState();
}

class _MainPageState extends ConsumerState<MainPage> {
  int _selectedIndex = 0;

  static const List<Widget> _pages = [
    DashboardPage(),
    LeaguesPage(),
    TeamsPage(),
    FixturesPage(),
    StatisticsPage(),
  ];

  static const List<String> _titles = [
    'Dashboard',
    'Leagues',
    'Teams',
    'Fixtures',
    'Statistics',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_selectedIndex]),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // Navigate to settings
            },
          ),
        ],
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
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
            icon: Icon(Icons.groups_outlined),
            selectedIcon: Icon(Icons.groups),
            label: 'Teams',
          ),
          NavigationDestination(
            icon: Icon(Icons.event_outlined),
            selectedIcon: Icon(Icons.event),
            label: 'Fixtures',
          ),
          NavigationDestination(
            icon: Icon(Icons.analytics_outlined),
            selectedIcon: Icon(Icons.analytics),
            label: 'Statistics',
          ),
        ],
      ),
    );
  }
}

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome to Football Stats',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Quick Stats',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  const Text('Live matches: 5'),
                  const Text('Today\'s fixtures: 12'),
                  const Text('Active leagues: 8'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Recent Activity',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  const ListTile(
                    leading: Icon(Icons.sports_soccer),
                    title: Text('Premier League'),
                    subtitle: Text('Manchester City vs Arsenal - FT 2:1'),
                  ),
                  const ListTile(
                    leading: Icon(Icons.sports_soccer),
                    title: Text('La Liga'),
                    subtitle: Text('Real Madrid vs Barcelona - Live 1:0'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class LeaguesPage extends StatelessWidget {
  const LeaguesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 10,
      itemBuilder: (context, index) {
        final leagues = [
          'Premier League',
          'La Liga', 
          'Serie A',
          'Bundesliga',
          'Ligue 1',
          'Champions League',
          'Europa League',
          'World Cup',
          'Euros',
          'Copa America',
        ];
        
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: const CircleAvatar(
              child: Icon(Icons.emoji_events),
            ),
            title: Text(leagues[index]),
            subtitle: Text('Season 2024/25 • ${20 + index} teams'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              // Navigate to league details
            },
          ),
        );
      },
    );
  }
}

class TeamsPage extends StatelessWidget {
  const TeamsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: 20,
      itemBuilder: (context, index) {
        final teams = [
          'Manchester City',
          'Real Madrid',
          'Barcelona',
          'Bayern Munich',
          'Liverpool',
          'Paris Saint-Germain',
          'Juventus',
          'Chelsea',
          'Manchester United',
          'Arsenal',
        ];
        
        return Card(
          child: InkWell(
            onTap: () {
              // Navigate to team details
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircleAvatar(
                    radius: 30,
                    child: Icon(Icons.sports_soccer, size: 30),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    teams[index % teams.length],
                    style: Theme.of(context).textTheme.titleMedium,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Form: WWDLW',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class FixturesPage extends StatelessWidget {
  const FixturesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 15,
      itemBuilder: (context, index) {
        final matches = [
          {'home': 'Manchester City', 'away': 'Arsenal', 'score': '2 - 1', 'status': 'FT'},
          {'home': 'Liverpool', 'away': 'Chelsea', 'score': '- : -', 'status': '15:00'},
          {'home': 'Real Madrid', 'away': 'Barcelona', 'score': '1 - 0', 'status': '67\''},
          {'home': 'Bayern Munich', 'away': 'Dortmund', 'score': '- : -', 'status': '18:30'},
          {'home': 'PSG', 'away': 'Lyon', 'score': '3 - 2', 'status': 'FT'},
        ];
        
        final match = matches[index % matches.length];
        
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    match['home']!,
                    textAlign: TextAlign.right,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                const SizedBox(width: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    match['score']!,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: Text(
                    match['away']!,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: match['status'] == 'FT' 
                        ? Colors.green.withOpacity(0.2)
                        : match['status']!.contains(':') 
                            ? Colors.blue.withOpacity(0.2)
                            : Colors.orange.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    match['status']!,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class StatisticsPage extends StatelessWidget {
  const StatisticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'League Statistics',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Top Scorers',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  const ListTile(
                    leading: CircleAvatar(child: Text('1')),
                    title: Text('Erling Haaland'),
                    subtitle: Text('Manchester City'),
                    trailing: Text('15 goals'),
                  ),
                  const ListTile(
                    leading: CircleAvatar(child: Text('2')),
                    title: Text('Harry Kane'),
                    subtitle: Text('Bayern Munich'),
                    trailing: Text('13 goals'),
                  ),
                  const ListTile(
                    leading: CircleAvatar(child: Text('3')),
                    title: Text('Kylian Mbappé'),
                    subtitle: Text('PSG'),
                    trailing: Text('12 goals'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Team Performance',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceVariant,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(
                      child: Text('Chart Placeholder\n(Goals per Match)'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}