import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

void main() {
  runApp(
    const ProviderScope(
      child: FootballStatsApiDemo(),
    ),
  );
}

class FootballStatsApiDemo extends StatelessWidget {
  const FootballStatsApiDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Football Stats API Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const ApiDemoPage(),
    );
  }
}

class ApiDemoPage extends ConsumerStatefulWidget {
  const ApiDemoPage({super.key});

  @override
  ConsumerState<ApiDemoPage> createState() => _ApiDemoPageState();
}

class _ApiDemoPageState extends ConsumerState<ApiDemoPage> {
  final Logger _logger = Logger();
  String _status = 'Ready to test APIs';
  bool _isLoading = false;
  Map<String, dynamic>? _lastResponse;

  // Simple API client for demo
  late final Dio _dio;

  @override
  void initState() {
    super.initState();
    _setupApiClient();
  }

  void _setupApiClient() {
    _dio = Dio();
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // Add headers for different API providers
          if (options.uri.host.contains('api-football')) {
            options.headers['X-RapidAPI-Key'] = 'YOUR_API_KEY_HERE';
            options.headers['X-RapidAPI-Host'] = 'api-football-v1.p.rapidapi.com';
          } else if (options.uri.host.contains('football-data.org')) {
            options.headers['X-Auth-Token'] = 'YOUR_FOOTBALL_DATA_TOKEN';
          }
          
          _logger.i('🌐 ${options.method} ${options.uri}');
          handler.next(options);
        },
        onResponse: (response, handler) {
          _logger.i('✅ ${response.statusCode} ${response.requestOptions.uri}');
          handler.next(response);
        },
        onError: (error, handler) {
          _logger.e('❌ ${error.response?.statusCode} ${error.requestOptions.uri}');
          handler.next(error);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Football APIs Demo'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Icon(
                      Icons.sports_soccer,
                      size: 60,
                      color: Colors.blue,
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Football Stats API Integration',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _isLoading ? Colors.orange.shade100 : Colors.green.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _status,
                        style: TextStyle(
                          color: _isLoading ? Colors.orange.shade800 : Colors.green.shade800,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Available API Endpoints:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildApiSection(
                      'Leagues API',
                      'Get football leagues and competitions',
                      Icons.emoji_events,
                      Colors.amber,
                      [
                        _buildApiButton(
                          'Get All Leagues',
                          () => _testLeaguesApi(),
                        ),
                        _buildApiButton(
                          'Get Popular Leagues',
                          () => _testPopularLeagues(),
                        ),
                        _buildApiButton(
                          'Search Leagues',
                          () => _testSearchLeagues(),
                        ),
                      ],
                    ),
                    _buildApiSection(
                      'Teams API',
                      'Get team information and statistics',
                      Icons.groups,
                      Colors.green,
                      [
                        _buildApiButton(
                          'Get Teams by League',
                          () => _testTeamsApi(),
                        ),
                        _buildApiButton(
                          'Get Team Details',
                          () => _testTeamDetails(),
                        ),
                        _buildApiButton(
                          'Search Teams',
                          () => _testSearchTeams(),
                        ),
                      ],
                    ),
                    _buildApiSection(
                      'Fixtures API',
                      'Get match fixtures and results',
                      Icons.sports_soccer,
                      Colors.blue,
                      [
                        _buildApiButton(
                          'Get Live Scores',
                          () => _testLiveScores(),
                        ),
                        _buildApiButton(
                          'Get Today\'s Fixtures',
                          () => _testTodayFixtures(),
                        ),
                        _buildApiButton(
                          'Get Match Details',
                          () => _testMatchDetails(),
                        ),
                      ],
                    ),
                    _buildApiSection(
                      'Standings API',
                      'Get league tables and standings',
                      Icons.leaderboard,
                      Colors.purple,
                      [
                        _buildApiButton(
                          'Get League Standings',
                          () => _testStandingsApi(),
                        ),
                        _buildApiButton(
                          'Get Top Teams',
                          () => _testTopTeams(),
                        ),
                        _buildApiButton(
                          'Compare Teams',
                          () => _testCompareTeams(),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            if (_lastResponse != null) ...[
              const SizedBox(height: 20),
              const Text(
                'Last API Response:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                height: 200,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    _formatResponse(_lastResponse!),
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildApiSection(
    String title,
    String description,
    IconData icon,
    Color color,
    List<Widget> buttons,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 5),
            Text(
              description,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 15),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: buttons,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildApiButton(String label, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: _isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 12),
      ),
    );
  }

  String _formatResponse(Map<String, dynamic> response) {
    return response.entries
        .take(10) // Limit to first 10 entries
        .map((entry) => '${entry.key}: ${_truncateValue(entry.value)}')
        .join('\n');
  }

  String _truncateValue(dynamic value) {
    final str = value.toString();
    return str.length > 100 ? '${str.substring(0, 100)}...' : str;
  }

  // API Test Methods
  Future<void> _testLeaguesApi() async {
    await _makeApiCall(
      'Testing Leagues API...',
      () async {
        // Demo response for leagues
        return {
          'endpoint': '/leagues',
          'status': 'success',
          'count': 5,
          'leagues': [
            {'id': 39, 'name': 'Premier League', 'country': 'England'},
            {'id': 140, 'name': 'La Liga', 'country': 'Spain'},
            {'id': 78, 'name': 'Bundesliga', 'country': 'Germany'},
            {'id': 135, 'name': 'Serie A', 'country': 'Italy'},
            {'id': 61, 'name': 'Ligue 1', 'country': 'France'},
          ],
          'timestamp': DateTime.now().toIso8601String(),
        };
      },
    );
  }

  Future<void> _testPopularLeagues() async {
    await _makeApiCall(
      'Getting Popular Leagues...',
      () async {
        return {
          'endpoint': '/leagues/popular',
          'status': 'success',
          'data': {
            'Premier League': {'teams': 20, 'current_season': '2024-25'},
            'La Liga': {'teams': 20, 'current_season': '2024-25'},
            'Champions League': {'teams': 32, 'current_season': '2024-25'},
          },
          'timestamp': DateTime.now().toIso8601String(),
        };
      },
    );
  }

  Future<void> _testSearchLeagues() async {
    await _makeApiCall(
      'Searching Leagues...',
      () async {
        return {
          'endpoint': '/leagues/search',
          'query': 'Premier',
          'results': [
            {'id': 39, 'name': 'Premier League', 'country': 'England'},
            {'id': 140, 'name': 'Premier Division', 'country': 'Ireland'},
          ],
          'total_results': 2,
          'timestamp': DateTime.now().toIso8601String(),
        };
      },
    );
  }

  Future<void> _testTeamsApi() async {
    await _makeApiCall(
      'Getting Teams by League...',
      () async {
        return {
          'endpoint': '/teams',
          'league_id': 39,
          'season': '2024',
          'teams': [
            {'id': 33, 'name': 'Manchester United', 'founded': 1878},
            {'id': 34, 'name': 'Newcastle United', 'founded': 1892},
            {'id': 40, 'name': 'Liverpool', 'founded': 1892},
            {'id': 50, 'name': 'Manchester City', 'founded': 1880},
          ],
          'count': 4,
          'timestamp': DateTime.now().toIso8601String(),
        };
      },
    );
  }

  Future<void> _testTeamDetails() async {
    await _makeApiCall(
      'Getting Team Details...',
      () async {
        return {
          'endpoint': '/teams/details',
          'team_id': 33,
          'name': 'Manchester United',
          'founded': 1878,
          'venue': 'Old Trafford',
          'capacity': 76000,
          'statistics': {
            'matches_played': 15,
            'wins': 8,
            'draws': 4,
            'losses': 3,
            'goals_for': 25,
            'goals_against': 18,
          },
          'timestamp': DateTime.now().toIso8601String(),
        };
      },
    );
  }

  Future<void> _testSearchTeams() async {
    await _makeApiCall(
      'Searching Teams...',
      () async {
        return {
          'endpoint': '/teams/search',
          'query': 'Manchester',
          'results': [
            {'id': 33, 'name': 'Manchester United', 'league': 'Premier League'},
            {'id': 50, 'name': 'Manchester City', 'league': 'Premier League'},
          ],
          'total_results': 2,
          'timestamp': DateTime.now().toIso8601String(),
        };
      },
    );
  }

  Future<void> _testLiveScores() async {
    await _makeApiCall(
      'Getting Live Scores...',
      () async {
        return {
          'endpoint': '/fixtures/live',
          'live_matches': [
            {
              'id': 12345,
              'home_team': 'Arsenal',
              'away_team': 'Chelsea',
              'score': '2-1',
              'minute': 67,
              'status': 'live'
            },
            {
              'id': 12346,
              'home_team': 'Liverpool',
              'away_team': 'Man City',
              'score': '1-1',
              'minute': 45,
              'status': 'half_time'
            }
          ],
          'count': 2,
          'timestamp': DateTime.now().toIso8601String(),
        };
      },
    );
  }

  Future<void> _testTodayFixtures() async {
    await _makeApiCall(
      'Getting Today\'s Fixtures...',
      () async {
        final today = DateTime.now();
        return {
          'endpoint': '/fixtures/today',
          'date': today.toIso8601String().split('T').first,
          'fixtures': [
            {'home': 'Tottenham', 'away': 'West Ham', 'time': '15:00'},
            {'home': 'Brighton', 'away': 'Everton', 'time': '17:30'},
            {'home': 'Wolves', 'away': 'Crystal Palace', 'time': '20:00'},
          ],
          'count': 3,
          'timestamp': DateTime.now().toIso8601String(),
        };
      },
    );
  }

  Future<void> _testMatchDetails() async {
    await _makeApiCall(
      'Getting Match Details...',
      () async {
        return {
          'endpoint': '/fixtures/details',
          'fixture_id': 12345,
          'home_team': 'Arsenal',
          'away_team': 'Chelsea',
          'final_score': '3-1',
          'events': [
            {'minute': 15, 'type': 'goal', 'player': 'Saka', 'team': 'Arsenal'},
            {'minute': 34, 'type': 'goal', 'player': 'Sterling', 'team': 'Chelsea'},
            {'minute': 67, 'type': 'goal', 'player': 'Odegaard', 'team': 'Arsenal'},
            {'minute': 89, 'type': 'goal', 'player': 'Martinelli', 'team': 'Arsenal'},
          ],
          'statistics': {
            'possession': {'Arsenal': 58, 'Chelsea': 42},
            'shots': {'Arsenal': 12, 'Chelsea': 8},
            'shots_on_target': {'Arsenal': 6, 'Chelsea': 3},
          },
          'timestamp': DateTime.now().toIso8601String(),
        };
      },
    );
  }

  Future<void> _testStandingsApi() async {
    await _makeApiCall(
      'Getting League Standings...',
      () async {
        return {
          'endpoint': '/standings',
          'league_id': 39,
          'season': '2024-25',
          'standings': [
            {'position': 1, 'team': 'Liverpool', 'points': 45, 'played': 17},
            {'position': 2, 'team': 'Arsenal', 'points': 40, 'played': 17},
            {'position': 3, 'team': 'Chelsea', 'points': 37, 'played': 17},
            {'position': 4, 'team': 'Man City', 'points': 35, 'played': 17},
          ],
          'last_updated': DateTime.now().toIso8601String(),
        };
      },
    );
  }

  Future<void> _testTopTeams() async {
    await _makeApiCall(
      'Getting Top Teams...',
      () async {
        return {
          'endpoint': '/standings/top',
          'league_id': 39,
          'top_teams': [
            {'team': 'Liverpool', 'points': 45, 'form': 'WWWWD'},
            {'team': 'Arsenal', 'points': 40, 'form': 'WDWWL'},
            {'team': 'Chelsea', 'points': 37, 'form': 'LWWWW'},
          ],
          'european_spots': {
            'champions_league': ['Liverpool', 'Arsenal', 'Chelsea', 'Man City'],
            'europa_league': ['Newcastle', 'Tottenham'],
          },
          'timestamp': DateTime.now().toIso8601String(),
        };
      },
    );
  }

  Future<void> _testCompareTeams() async {
    await _makeApiCall(
      'Comparing Teams...',
      () async {
        return {
          'endpoint': '/teams/compare',
          'team1': 'Arsenal',
          'team2': 'Chelsea',
          'comparison': {
            'position': {'Arsenal': 2, 'Chelsea': 3},
            'points': {'Arsenal': 40, 'Chelsea': 37},
            'goal_difference': {'Arsenal': '+18', 'Chelsea': '+12'},
            'head_to_head': {'Arsenal': 2, 'Chelsea': 1, 'draws': 1},
            'form_last_5': {'Arsenal': 'WDWWL', 'Chelsea': 'LWWWW'},
          },
          'timestamp': DateTime.now().toIso8601String(),
        };
      },
    );
  }

  Future<void> _makeApiCall(
    String statusMessage,
    Future<Map<String, dynamic>> Function() apiCall,
  ) async {
    setState(() {
      _isLoading = true;
      _status = statusMessage;
      _lastResponse = null;
    });

    try {
      await Future.delayed(const Duration(milliseconds: 1500)); // Simulate API delay
      final response = await apiCall();
      
      setState(() {
        _isLoading = false;
        _status = 'API call successful! ✅';
        _lastResponse = response;
      });

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${response['endpoint'] ?? 'API'} call successful!'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _status = 'API call failed: $e';
        _lastResponse = {
          'error': true,
          'message': e.toString(),
          'timestamp': DateTime.now().toIso8601String(),
        };
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('API call failed: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }
}