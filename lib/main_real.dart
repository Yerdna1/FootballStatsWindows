import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

void main() {
  runApp(const FootballStatsRealApp());
}

class FootballStatsRealApp extends StatelessWidget {
  const FootballStatsRealApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Football Stats',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
      ),
      home: const MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;
  Map<String, dynamic> _leagueData = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLeagueData();
  }

  Future<void> _loadLeagueData() async {
    try {
      // Try to read the league data from the local JSON file
      final file = File('league_names.json');
      if (await file.exists()) {
        final contents = await file.readAsString();
        setState(() {
          _leagueData = json.decode(contents);
          _isLoading = false;
        });
      } else {
        // Fallback to hardcoded data if file doesn't exist
        setState(() {
          _leagueData = _getFallbackLeagueData();
          _isLoading = false;
        });
      }
    } catch (e) {
      // Use fallback data on error
      setState(() {
        _leagueData = _getFallbackLeagueData();
        _isLoading = false;
      });
    }
  }

  Map<String, dynamic> _getFallbackLeagueData() {
    return {
      "39": {"name": "Premier League", "country": "England", "flag": "🏴󠁧󠁢󠁥󠁮󠁧󠁿"},
      "140": {"name": "La Liga", "country": "Spain", "flag": "🇪🇸"},
      "78": {"name": "Bundesliga", "country": "Germany", "flag": "🇩🇪"},
      "135": {"name": "Serie A", "country": "Italy", "flag": "🇮🇹"},
      "61": {"name": "Ligue 1", "country": "France", "flag": "🇫🇷"},
      "2": {"name": "Champions League", "country": "Europe", "flag": "🏆"},
      "3": {"name": "Europa League", "country": "Europe", "flag": "🥈"},
    };
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue, Colors.blueAccent],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.sports_soccer,
                  size: 80,
                  color: Colors.white,
                ),
                SizedBox(height: 24),
                CircularProgressIndicator(color: Colors.white),
                SizedBox(height: 16),
                Text(
                  'Loading Football Stats...',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Football Stats', style: TextStyle(fontWeight: FontWeight.bold)),
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
        children: [
          DashboardPage(leagueData: _leagueData),
          LeaguesPage(leagueData: _leagueData),
          const TeamsPage(),
          const FixturesPage(),
          const StandingsPage(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
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
      builder: (context) => AlertDialog(
        title: const Text('Search Football Data'),
        content: const TextField(
          decoration: InputDecoration(
            hintText: 'Search teams, leagues, players...',
            prefixIcon: Icon(Icons.search),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Search functionality coming soon!')),
              );
            },
            child: const Text('Search'),
          ),
        ],
      ),
    );
  }

  void _refreshData() {
    setState(() {
      _isLoading = true;
    });
    _loadLeagueData();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Data refreshed successfully!'),
        backgroundColor: Colors.green,
      ),
    );
  }
}

class DashboardPage extends StatelessWidget {
  final Map<String, dynamic> leagueData;

  const DashboardPage({super.key, required this.leagueData});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWelcomeCard(),
          const SizedBox(height: 20),
          _buildQuickStatsRow(),
          const SizedBox(height: 20),
          _buildLiveMatchesCard(),
          const SizedBox(height: 20),
          _buildPopularLeaguesCard(),
          const SizedBox(height: 20),
          _buildRecentActivityCard(),
        ],
      ),
    );
  }

  Widget _buildWelcomeCard() {
    return Card(
      elevation: 8,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: const LinearGradient(
            colors: [Colors.blue, Colors.blueAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            const Icon(
              Icons.sports_soccer,
              size: 60,
              color: Colors.white,
            ),
            const SizedBox(height: 16),
            const Text(
              'Welcome to Football Stats',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Today is ${DateFormat('EEEE, MMMM d, y').format(DateTime.now())}',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStatsRow() {
    return Row(
      children: [
        Expanded(child: _buildStatCard('Leagues', '${leagueData.length}', Icons.emoji_events, Colors.amber)),
        const SizedBox(width: 12),
        Expanded(child: _buildStatCard('Live Matches', '12', Icons.live_tv, Colors.red)),
        const SizedBox(width: 12),
        Expanded(child: _buildStatCard('Today\'s Games', '45', Icons.today, Colors.green)),
        const SizedBox(width: 12),
        Expanded(child: _buildStatCard('Countries', '167', Icons.public, Colors.purple)),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLiveMatchesCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.live_tv, color: Colors.red, size: 24),
                const SizedBox(width: 8),
                const Text(
                  'Live Matches',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'LIVE',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildMatchTile('Arsenal', 'Chelsea', '2', '1', '67\'', true),
            _buildMatchTile('Liverpool', 'Man City', '1', '1', 'HT', false),
            _buildMatchTile('Barcelona', 'Real Madrid', '0', '0', '23\'', true),
          ],
        ),
      ),
    );
  }

  Widget _buildMatchTile(String homeTeam, String awayTeam, String homeScore, String awayScore, String time, bool isLive) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isLive ? Colors.red.shade50 : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isLive ? Colors.red.shade200 : Colors.grey.shade200,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              homeTeam,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              '$homeScore - $awayScore',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          Expanded(
            child: Text(
              awayTeam,
              textAlign: TextAlign.right,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            time,
            style: TextStyle(
              color: isLive ? Colors.red : Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPopularLeaguesCard() {
    final popularLeagues = leagueData.entries.take(6).toList();
    
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.emoji_events, color: Colors.amber, size: 24),
                SizedBox(width: 8),
                Text(
                  'Popular Leagues',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: popularLeagues.length,
              itemBuilder: (context, index) {
                final league = popularLeagues[index].value;
                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Row(
                    children: [
                      Text(
                        league['flag'] ?? '⚽',
                        style: const TextStyle(fontSize: 20),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              league['name'] ?? 'Unknown',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              league['country'] ?? 'Unknown',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivityCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.history, color: Colors.blue, size: 24),
                SizedBox(width: 8),
                Text(
                  'Recent Activity',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildActivityItem('⚽', 'Liverpool beat Manchester United 3-1', '2 hours ago'),
            _buildActivityItem('🏆', 'Champions League Round of 16 draw', '5 hours ago'),
            _buildActivityItem('📊', 'Premier League table updated', '1 day ago'),
            _buildActivityItem('🔄', 'Transfer window opens', '2 days ago'),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem(String icon, String title, String time) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                Text(
                  time,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class LeaguesPage extends StatelessWidget {
  final Map<String, dynamic> leagueData;

  const LeaguesPage({super.key, required this.leagueData});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'All Leagues',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: leagueData.length,
              itemBuilder: (context, index) {
                final entry = leagueData.entries.elementAt(index);
                final leagueId = entry.key;
                final league = entry.value;
                
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Text(
                        league['flag'] ?? '⚽',
                        style: const TextStyle(fontSize: 20),
                      ),
                    ),
                    title: Text(
                      league['name'] ?? 'Unknown League',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(league['country'] ?? 'Unknown Country'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Opening ${league['name']} details...'),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class TeamsPage extends StatelessWidget {
  const TeamsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.groups,
            size: 80,
            color: Colors.grey,
          ),
          SizedBox(height: 16),
          Text(
            'Teams Page',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Coming soon with team details, statistics, and squad information',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}

class FixturesPage extends StatelessWidget {
  const FixturesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.sports_soccer,
            size: 80,
            color: Colors.grey,
          ),
          SizedBox(height: 16),
          Text(
            'Fixtures & Results',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Coming soon with live scores, match schedules, and detailed results',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}

class StandingsPage extends StatelessWidget {
  const StandingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.leaderboard,
            size: 80,
            color: Colors.grey,
          ),
          SizedBox(height: 16),
          Text(
            'League Standings',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Coming soon with league tables, team positions, and statistics',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}