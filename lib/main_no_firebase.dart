import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
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
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Settings clicked!')),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.brightness_6),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Theme toggle clicked!')),
              );
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
          Row(
            children: [
              Icon(
                Icons.sports_soccer,
                size: 32,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 12),
              Text(
                'Welcome to Football Stats',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Quick Stats Grid
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            children: [
              _buildStatCard(
                context,
                'Live Matches',
                '5',
                Icons.live_tv,
                Colors.red,
              ),
              _buildStatCard(
                context,
                'Today\'s Fixtures',
                '12',
                Icons.event,
                Colors.blue,
              ),
              _buildStatCard(
                context,
                'Active Leagues',
                '8',
                Icons.emoji_events,
                Colors.orange,
              ),
              _buildStatCard(
                context,
                'Favorite Teams',
                '3',
                Icons.favorite,
                Colors.pink,
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Recent Activity
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.history,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Recent Activity',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildActivityTile(
                    context,
                    'Premier League',
                    'Manchester City vs Arsenal',
                    'FT 2:1',
                    Colors.green,
                  ),
                  const Divider(),
                  _buildActivityTile(
                    context,
                    'La Liga',
                    'Real Madrid vs Barcelona',
                    'Live 1:0',
                    Colors.red,
                  ),
                  const Divider(),
                  _buildActivityTile(
                    context,
                    'Serie A',
                    'Juventus vs Inter Milan',
                    '15:00',
                    Colors.blue,
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Top Teams Performance
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.trending_up,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Top Teams This Week',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildTeamPerformanceTile(
                    context,
                    'Manchester City',
                    'WWWWW',
                    '15 pts',
                    95,
                  ),
                  _buildTeamPerformanceTile(
                    context,
                    'Real Madrid',
                    'WWWDW',
                    '13 pts',
                    87,
                  ),
                  _buildTeamPerformanceTile(
                    context,
                    'Bayern Munich',
                    'WDWWW',
                    '13 pts',
                    85,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 32,
              color: color,
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityTile(
    BuildContext context,
    String league,
    String match,
    String status,
    Color statusColor,
  ) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: statusColor.withOpacity(0.2),
        child: Icon(
          Icons.sports_soccer,
          color: statusColor,
        ),
      ),
      title: Text(league),
      subtitle: Text(match),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: statusColor.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          status,
          style: TextStyle(
            color: statusColor,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildTeamPerformanceTile(
    BuildContext context,
    String teamName,
    String form,
    String points,
    double percentage,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          CircleAvatar(
            child: Text(
              teamName[0],
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  teamName,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Form: $form',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                points,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${percentage.toInt()}%',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.green,
                ),
              ),
            ],
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
    final leagues = [
      {'name': 'Premier League', 'country': 'England', 'teams': 20, 'icon': '🏴󠁧󠁢󠁥󠁮󠁧󠁿'},
      {'name': 'La Liga', 'country': 'Spain', 'teams': 20, 'icon': '🇪🇸'},
      {'name': 'Serie A', 'country': 'Italy', 'teams': 20, 'icon': '🇮🇹'},
      {'name': 'Bundesliga', 'country': 'Germany', 'teams': 18, 'icon': '🇩🇪'},
      {'name': 'Ligue 1', 'country': 'France', 'teams': 20, 'icon': '🇫🇷'},
      {'name': 'Champions League', 'country': 'Europe', 'teams': 32, 'icon': '🏆'},
      {'name': 'Europa League', 'country': 'Europe', 'teams': 48, 'icon': '🥈'},
      {'name': 'World Cup', 'country': 'International', 'teams': 32, 'icon': '🌍'},
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: leagues.length,
      itemBuilder: (context, index) {
        final league = leagues[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: CircleAvatar(
              radius: 25,
              child: Text(
                league['icon']! as String,
                style: const TextStyle(fontSize: 20),
              ),
            ),
            title: Text(
              league['name']! as String,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Text('${league['country']} • ${league['teams']} teams'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Viewing ${league['name']}')),
              );
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
    final teams = [
      {'name': 'Manchester City', 'league': 'Premier League', 'form': 'WWWWW', 'points': 45},
      {'name': 'Real Madrid', 'league': 'La Liga', 'form': 'WWWDW', 'points': 42},
      {'name': 'Barcelona', 'league': 'La Liga', 'form': 'WDWWW', 'points': 41},
      {'name': 'Bayern Munich', 'league': 'Bundesliga', 'form': 'WWWWL', 'points': 40},
      {'name': 'Liverpool', 'league': 'Premier League', 'form': 'WDWDW', 'points': 38},
      {'name': 'PSG', 'league': 'Ligue 1', 'form': 'WWLWW', 'points': 37},
      {'name': 'Juventus', 'league': 'Serie A', 'form': 'WDWWW', 'points': 36},
      {'name': 'Chelsea', 'league': 'Premier League', 'form': 'DWWLW', 'points': 35},
    ];

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.85,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: teams.length,
      itemBuilder: (context, index) {
        final team = teams[index];
        
        return Card(
          child: InkWell(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Viewing ${team['name']}')),
              );
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                    child: Text(
                      (team['name']! as String).split(' ').map((word) => word[0]).join(''),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    team['name']! as String,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    team['league']! as String,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Form: ${team['form']}',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSecondaryContainer,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${team['points']} pts',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
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
    final fixtures = [
      {
        'home': 'Manchester City',
        'away': 'Arsenal',
        'homeScore': '2',
        'awayScore': '1',
        'status': 'FT',
        'time': '90+3\'',
        'league': 'Premier League'
      },
      {
        'home': 'Liverpool',
        'away': 'Chelsea',
        'homeScore': '-',
        'awayScore': '-',
        'status': 'Scheduled',
        'time': '15:00',
        'league': 'Premier League'
      },
      {
        'home': 'Real Madrid',
        'away': 'Barcelona',
        'homeScore': '1',
        'awayScore': '0',
        'status': 'Live',
        'time': '67\'',
        'league': 'La Liga'
      },
      {
        'home': 'Bayern Munich',
        'away': 'Dortmund',
        'homeScore': '-',
        'awayScore': '-',
        'status': 'Scheduled',
        'time': '18:30',
        'league': 'Bundesliga'
      },
      {
        'home': 'PSG',
        'away': 'Lyon',
        'homeScore': '3',
        'awayScore': '2',
        'status': 'FT',
        'time': '90\'',
        'league': 'Ligue 1'
      },
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: fixtures.length,
      itemBuilder: (context, index) {
        final fixture = fixtures[index];
        final isLive = fixture['status'] == 'Live';
        final isFinished = fixture['status'] == 'FT';
        
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // League name
                Row(
                  children: [
                    Icon(
                      Icons.sports_soccer,
                      size: 16,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      fixture['league']!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: isLive
                            ? Colors.red.withOpacity(0.2)
                            : isFinished
                                ? Colors.green.withOpacity(0.2)
                                : Colors.blue.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (isLive)
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                            ),
                          if (isLive) const SizedBox(width: 4),
                          Text(
                            fixture['time']!,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: isLive
                                  ? Colors.red
                                  : isFinished
                                      ? Colors.green
                                      : Colors.blue,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Match details
                Row(
                  children: [
                    // Home team
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            fixture['home']!,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.right,
                          ),
                        ],
                      ),
                    ),
                    
                    // Score
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${fixture['homeScore']} : ${fixture['awayScore']}',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                    
                    // Away team
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            fixture['away']!,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
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
          // Top Scorers
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.sports_soccer,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Top Scorers',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildScorerTile(context, '1', 'Erling Haaland', 'Manchester City', '23', Colors.amber),
                  _buildScorerTile(context, '2', 'Harry Kane', 'Bayern Munich', '21', Colors.grey[400]!),
                  _buildScorerTile(context, '3', 'Kylian Mbappé', 'PSG', '19', Colors.brown),
                  _buildScorerTile(context, '4', 'Robert Lewandowski', 'Barcelona', '18', null),
                  _buildScorerTile(context, '5', 'Victor Osimhen', 'Napoli', '16', null),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // League Performance Chart
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.trending_up,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Goals per Match Average',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.bar_chart,
                            size: 48,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Interactive Chart',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ),
                          Text(
                            'Coming Soon',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // League Statistics
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.analytics,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'League Statistics',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildStatRow(context, 'Total Matches Played', '1,247'),
                  _buildStatRow(context, 'Total Goals Scored', '3,156'),
                  _buildStatRow(context, 'Average Goals per Match', '2.53'),
                  _buildStatRow(context, 'Clean Sheets', '423'),
                  _buildStatRow(context, 'Yellow Cards', '4,521'),
                  _buildStatRow(context, 'Red Cards', '156'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScorerTile(
    BuildContext context,
    String position,
    String playerName,
    String teamName,
    String goals,
    Color? medalColor,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: medalColor ?? Theme.of(context).colorScheme.surfaceVariant,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                position,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: medalColor != null ? Colors.white : Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  playerName,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  teamName,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              '$goals goals',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}