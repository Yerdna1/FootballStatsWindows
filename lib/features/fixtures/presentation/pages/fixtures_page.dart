import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/cards/match_card.dart';
import '../../../../shared/data/models/fixture_model.dart';
import '../providers/fixtures_provider.dart';
import '../widgets/fixtures_filter_sheet.dart';
import '../widgets/fixtures_calendar_view.dart';
import '../widgets/fixtures_list_view.dart';
import '../widgets/live_fixtures_banner.dart';

class FixturesPage extends ConsumerStatefulWidget {
  const FixturesPage({super.key});

  @override
  ConsumerState<FixturesPage> createState() => _FixturesPageState();
}

class _FixturesPageState extends ConsumerState<FixturesPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _selectedDay = DateTime.now();
    
    // Load fixtures on first build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(fixturesProvider.notifier).loadFixtures();
      ref.read(liveFixturesProvider.notifier).loadLiveFixtures();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fixturesState = ref.watch(fixturesProvider);
    final liveFixturesState = ref.watch(liveFixturesProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fixtures'),
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterSheet(context),
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _showSearchPage(context),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: Colors.grey,
          indicatorColor: AppColors.primary,
          tabs: const [
            Tab(text: 'Today'),
            Tab(text: 'Live'),
            Tab(text: 'Calendar'),
            Tab(text: 'All'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Live Fixtures Banner
          if (liveFixturesState.liveFixtures.isNotEmpty)
            LiveFixturesBanner(
              liveFixtures: liveFixturesState.liveFixtures,
              onTap: (fixture) => context.push('/fixtures/${fixture.id}'),
            ),
          
          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Today's Fixtures
                _buildTodayFixtures(fixturesState),
                
                // Live Fixtures
                _buildLiveFixtures(liveFixturesState),
                
                // Calendar View
                _buildCalendarView(fixturesState),
                
                // All Fixtures
                _buildAllFixtures(fixturesState),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodayFixtures(FixturesState state) {
    final today = DateTime.now();
    final todayFixtures = state.fixtures.where((fixture) {
      return _isSameDay(fixture.utcDate, today);
    }).toList();

    if (state.error != null) {
      return _buildErrorView(state.error!, () {
        ref.read(fixturesProvider.notifier).loadFixtures(refresh: true);
      });
    }

    if (state.isLoading && todayFixtures.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (todayFixtures.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.today,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'No fixtures today',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Check the calendar for upcoming matches',
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(fixturesProvider.notifier).loadFixtures(refresh: true);
      },
      child: FixturesListView(
        fixtures: todayFixtures,
        onFixtureTap: (fixture) => context.push('/fixtures/${fixture.id}'),
        groupByDate: false,
      ),
    );
  }

  Widget _buildLiveFixtures(LiveFixturesState state) {
    if (state.error != null) {
      return _buildErrorView(state.error!, () {
        ref.read(liveFixturesProvider.notifier).loadLiveFixtures();
      });
    }

    if (state.isLoading && state.liveFixtures.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.liveFixtures.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.live_tv,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'No live matches',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Live matches will appear here',
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(liveFixturesProvider.notifier).loadLiveFixtures();
      },
      child: FixturesListView(
        fixtures: state.liveFixtures,
        onFixtureTap: (fixture) => context.push('/fixtures/${fixture.id}'),
        groupByDate: false,
        showLiveIndicator: true,
      ),
    );
  }

  Widget _buildCalendarView(FixturesState state) {
    return Column(
      children: [
        // Calendar
        Container(
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TableCalendar<FixtureModel>(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            eventLoader: (day) {
              return state.fixtures.where((fixture) {
                return _isSameDay(fixture.utcDate, day);
              }).toList();
            },
            startingDayOfWeek: StartingDayOfWeek.monday,
            selectedDayPredicate: (day) {
              return _isSameDay(_selectedDay, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            onFormatChanged: (format) {
              setState(() {
                _calendarFormat = format;
              });
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
            calendarStyle: CalendarStyle(
              outsideDaysVisible: false,
              weekendTextStyle: TextStyle(color: AppColors.primary),
              holidayTextStyle: TextStyle(color: AppColors.primary),
              markerDecoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              todayDecoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
            ),
            headerStyle: const HeaderStyle(
              formatButtonVisible: true,
              titleCentered: true,
              formatButtonShowsNext: false,
            ),
          ),
        ),
        
        // Selected Day Fixtures
        Expanded(
          child: _buildSelectedDayFixtures(state),
        ),
      ],
    );
  }

  Widget _buildSelectedDayFixtures(FixturesState state) {
    if (_selectedDay == null) return const SizedBox.shrink();

    final selectedDayFixtures = state.fixtures.where((fixture) {
      return _isSameDay(fixture.utcDate, _selectedDay!);
    }).toList();

    if (selectedDayFixtures.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_busy,
              size: 48,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No fixtures on ${_formatDate(_selectedDay!)}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      );
    }

    return FixturesListView(
      fixtures: selectedDayFixtures,
      onFixtureTap: (fixture) => context.push('/fixtures/${fixture.id}'),
      groupByDate: false,
    );
  }

  Widget _buildAllFixtures(FixturesState state) {
    if (state.error != null) {
      return _buildErrorView(state.error!, () {
        ref.read(fixturesProvider.notifier).loadFixtures(refresh: true);
      });
    }

    if (state.isLoading && state.fixtures.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.fixtures.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.sports_soccer,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'No fixtures found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Try adjusting your filters',
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(fixturesProvider.notifier).loadFixtures(refresh: true);
      },
      child: FixturesListView(
        fixtures: state.fixtures,
        onFixtureTap: (fixture) => context.push('/fixtures/${fixture.id}'),
        groupByDate: true,
        enablePagination: true,
        onLoadMore: () {
          if (!state.hasReachedMax && !state.isLoading) {
            ref.read(fixturesProvider.notifier).loadMoreFixtures();
          }
        },
      ),
    );
  }

  Widget _buildErrorView(String error, VoidCallback onRetry) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red[300],
          ),
          const SizedBox(height: 16),
          Text(
            'Error loading fixtures',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onRetry,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FixturesFilterSheet(
        currentFilters: ref.read(fixturesProvider).filters,
        onApplyFilters: (filters) {
          ref.read(fixturesProvider.notifier).applyFilters(filters);
        },
      ),
    );
  }

  void _showSearchPage(BuildContext context) {
    // TODO: Implement search page
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Search functionality coming soon')),
    );
  }

  bool _isSameDay(DateTime? a, DateTime? b) {
    if (a == null || b == null) return false;
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}