import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../data/models/statistics_filter_model.dart';
import '../../../../shared/data/models/league_model.dart';
import '../../../../shared/data/models/team_model.dart';
import '../providers/filter_provider.dart';

class StatisticsFilter extends ConsumerStatefulWidget {
  final VoidCallback? onFiltersChanged;
  final bool isCompact;
  final bool showPresets;

  const StatisticsFilter({
    super.key,
    this.onFiltersChanged,
    this.isCompact = false,
    this.showPresets = true,
  });

  @override
  ConsumerState<StatisticsFilter> createState() => _StatisticsFilterState();
}

class _StatisticsFilterState extends ConsumerState<StatisticsFilter>
    with TickerProviderStateMixin {
  late TabController _tabController;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final filter = ref.watch(statisticsFilterProvider);
    final validation = ref.watch(filterValidationProvider);

    if (widget.isCompact) {
      return _buildCompactFilter(context, filter, validation);
    }

    return Container(
      margin: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: validation.hasErrors 
            ? colorScheme.error.withOpacity(0.3)
            : colorScheme.outline.withOpacity(0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          _buildHeader(context, filter, validation),
          
          // Validation Messages
          if (validation.hasIssues)
            _buildValidationMessages(context, validation),
          
          // Quick Presets
          if (widget.showPresets && !_isExpanded)
            _buildQuickPresets(context),
          
          // Expanded Filters
          if (_isExpanded)
            _buildExpandedFilters(context, filter),
        ],
      ),
    );
  }

  Widget _buildCompactFilter(
    BuildContext context,
    StatisticsFilterModel filter,
    FilterValidationResult validation,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final summary = ref.watch(filterSummaryProvider);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(
          color: validation.hasErrors 
            ? colorScheme.error.withOpacity(0.3)
            : colorScheme.outline.withOpacity(0.1),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.filter_list,
            size: 16.sp,
            color: colorScheme.primary,
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              summary.isNotEmpty ? summary : 'No filters applied',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.8),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            onPressed: () => _showFilterBottomSheet(context),
            icon: Icon(
              Icons.tune,
              size: 16.sp,
              color: colorScheme.primary,
            ),
            padding: EdgeInsets.zero,
            constraints: BoxConstraints(
              minWidth: 24.w,
              minHeight: 24.w,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    StatisticsFilterModel filter,
    FilterValidationResult validation,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final summary = ref.watch(filterSummaryProvider);

    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Row(
        children: [
          Icon(
            Icons.filter_list,
            color: colorScheme.primary,
            size: 20.sp,
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Statistics Filters',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (summary.isNotEmpty) ...[
                  SizedBox(height: 2.h),
                  Text(
                    summary,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ],
            ),
          ),
          
          // Clear button
          if (_hasActiveFilters(filter))
            TextButton.icon(
              onPressed: () {
                ref.read(statisticsFilterProvider.notifier).clearFilters();
                widget.onFiltersChanged?.call();
              },
              icon: Icon(Icons.clear, size: 16.sp),
              label: const Text('Clear'),
              style: TextButton.styleFrom(
                foregroundColor: colorScheme.error,
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              ),
            ),
          
          // Expand/Collapse button
          IconButton(
            onPressed: () => setState(() => _isExpanded = !_isExpanded),
            icon: Icon(
              _isExpanded ? Icons.expand_less : Icons.expand_more,
              color: colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildValidationMessages(
    BuildContext context,
    FilterValidationResult validation,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: validation.hasErrors 
          ? colorScheme.error.withOpacity(0.05)
          : colorScheme.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(
          color: validation.hasErrors 
            ? colorScheme.error.withOpacity(0.2)
            : colorScheme.primary.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Errors
          ...validation.errors.map((error) => Padding(
            padding: EdgeInsets.only(bottom: 4.h),
            child: Row(
              children: [
                Icon(
                  Icons.error_outline,
                  size: 16.sp,
                  color: colorScheme.error,
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    error,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.error,
                    ),
                  ),
                ),
              ],
            ),
          )),
          
          // Warnings
          ...validation.warnings.map((warning) => Padding(
            padding: EdgeInsets.only(bottom: 4.h),
            child: Row(
              children: [
                Icon(
                  Icons.warning_outlined,
                  size: 16.sp,
                  color: Colors.orange,
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    warning,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.orange,
                    ),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildQuickPresets(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Filters',
            style: theme.textTheme.labelMedium?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.6),
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: FilterPreset.values.map((preset) {
              return ActionChip(
                label: Text(preset.displayName),
                onPressed: () {
                  ref.read(statisticsFilterProvider.notifier).applyPreset(preset);
                  widget.onFiltersChanged?.call();
                },
                backgroundColor: colorScheme.primaryContainer.withOpacity(0.3),
                labelStyle: theme.textTheme.labelMedium?.copyWith(
                  color: colorScheme.primary,
                ),
                side: BorderSide(
                  color: colorScheme.primary.withOpacity(0.3),
                ),
              );
            }).toList(),
          ),
          SizedBox(height: 8.h),
        ],
      ),
    );
  }

  Widget _buildExpandedFilters(
    BuildContext context,
    StatisticsFilterModel filter,
  ) {
    final theme = Theme.of(context);
    
    return Column(
      children: [
        // Tab Bar
        TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Leagues & Teams'),
            Tab(text: 'Time Period'),
            Tab(text: 'Metrics'),
            Tab(text: 'Display'),
          ],
          labelStyle: theme.textTheme.labelMedium,
          unselectedLabelStyle: theme.textTheme.labelMedium,
        ),
        
        // Tab Bar View
        SizedBox(
          height: 300.h,
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildLeaguesTeamsTab(context, filter),
              _buildTimePeriodTab(context, filter),
              _buildMetricsTab(context, filter),
              _buildDisplayTab(context, filter),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLeaguesTeamsTab(
    BuildContext context,
    StatisticsFilterModel filter,
  ) {
    final availableLeagues = ref.watch(availableLeaguesProvider);
    final availableTeams = ref.watch(availableTeamsProvider);

    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Leagues Section
          _buildSectionHeader(context, 'Leagues'),
          SizedBox(height: 8.h),
          availableLeagues.when(
            data: (leagues) => _buildLeaguesList(context, leagues, filter),
            loading: () => const CircularProgressIndicator(),
            error: (error, stack) => Text('Error loading leagues: $error'),
          ),
          
          SizedBox(height: 16.h),
          
          // Teams Section
          _buildSectionHeader(context, 'Teams'),
          SizedBox(height: 8.h),
          availableTeams.when(
            data: (teams) => _buildTeamsList(context, teams, filter),
            loading: () => const CircularProgressIndicator(),
            error: (error, stack) => Text('Error loading teams: $error'),
          ),
        ],
      ),
    );
  }

  Widget _buildTimePeriodTab(
    BuildContext context,
    StatisticsFilterModel filter,
  ) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(context, 'Time Frame'),
          SizedBox(height: 8.h),
          
          // Timeframe options
          ...StatisticsTimeframe.values.map((timeframe) {
            return RadioListTile<StatisticsTimeframe>(
              title: Text(timeframe.displayName),
              value: timeframe,
              groupValue: filter.timeframe,
              onChanged: (value) {
                if (value != null) {
                  ref.read(statisticsFilterProvider.notifier).updateTimeframe(value);
                  widget.onFiltersChanged?.call();
                }
              },
              dense: true,
            );
          }),
          
          if (filter.timeframe == StatisticsTimeframe.custom) ...[
            SizedBox(height: 16.h),
            _buildDateRangePicker(context, filter),
          ],
        ],
      ),
    );
  }

  Widget _buildMetricsTab(
    BuildContext context,
    StatisticsFilterModel filter,
  ) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(context, 'Metrics to Display'),
          SizedBox(height: 8.h),
          
          ...StatisticsMetric.values.map((metric) {
            final isSelected = filter.selectedMetrics.contains(metric);
            return CheckboxListTile(
              title: Text(metric.displayName),
              subtitle: Text('Unit: ${metric.unit.isEmpty ? 'Count' : metric.unit}'),
              value: isSelected,
              onChanged: (value) {
                ref.read(statisticsFilterProvider.notifier).toggleMetric(metric);
                widget.onFiltersChanged?.call();
              },
              dense: true,
            );
          }),
        ],
      ),
    );
  }

  Widget _buildDisplayTab(
    BuildContext context,
    StatisticsFilterModel filter,
  ) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(context, 'View Type'),
          SizedBox(height: 8.h),
          
          ...StatisticsViewType.values.map((viewType) {
            return RadioListTile<StatisticsViewType>(
              title: Text(viewType.displayName),
              subtitle: Text(viewType.description),
              value: viewType,
              groupValue: filter.viewType,
              onChanged: (value) {
                if (value != null) {
                  ref.read(statisticsFilterProvider.notifier).updateViewType(value);
                  widget.onFiltersChanged?.call();
                }
              },
              dense: true,
            );
          }),
          
          SizedBox(height: 16.h),
          
          _buildSectionHeader(context, 'Sorting'),
          SizedBox(height: 8.h),
          
          DropdownButtonFormField<StatisticsSortBy>(
            value: filter.sortBy,
            decoration: const InputDecoration(
              labelText: 'Sort By',
              border: OutlineInputBorder(),
            ),
            items: StatisticsSortBy.values.map((sortBy) {
              return DropdownMenuItem(
                value: sortBy,
                child: Text(sortBy.name.replaceAll('_', ' ').toUpperCase()),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                ref.read(statisticsFilterProvider.notifier).updateSorting(
                  value,
                  filter.sortDescending,
                );
                widget.onFiltersChanged?.call();
              }
            },
          ),
          
          SizedBox(height: 8.h),
          
          SwitchListTile(
            title: const Text('Descending Order'),
            value: filter.sortDescending,
            onChanged: (value) {
              ref.read(statisticsFilterProvider.notifier).updateSorting(
                filter.sortBy,
                value,
              );
              widget.onFiltersChanged?.call();
            },
          ),
          
          SizedBox(height: 16.h),
          
          _buildSectionHeader(context, 'Additional Options'),
          SizedBox(height: 8.h),
          
          SwitchListTile(
            title: const Text('Include Home/Away Split'),
            value: filter.includeHomeAway,
            onChanged: (value) {
              ref.read(statisticsFilterProvider.notifier).updateIncludeFlags(
                includeHomeAway: value,
              );
              widget.onFiltersChanged?.call();
            },
          ),
          
          SwitchListTile(
            title: const Text('Include Form Analysis'),
            value: filter.includeForm,
            onChanged: (value) {
              ref.read(statisticsFilterProvider.notifier).updateIncludeFlags(
                includeForm: value,
              );
              widget.onFiltersChanged?.call();
            },
          ),
          
          SwitchListTile(
            title: const Text('Include Comparisons'),
            value: filter.includeComparisons,
            onChanged: (value) {
              ref.read(statisticsFilterProvider.notifier).updateIncludeFlags(
                includeComparisons: value,
              );
              widget.onFiltersChanged?.call();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Text(
      title,
      style: theme.textTheme.titleSmall?.copyWith(
        color: colorScheme.primary,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildLeaguesList(
    BuildContext context,
    List<LeagueModel> leagues,
    StatisticsFilterModel filter,
  ) {
    return Wrap(
      spacing: 8.w,
      runSpacing: 8.h,
      children: leagues.map((league) {
        final isSelected = filter.selectedLeagues.contains(league.id);
        return FilterChip(
          label: Text(league.name),
          selected: isSelected,
          onSelected: (selected) {
            ref.read(statisticsFilterProvider.notifier).toggleLeague(league.id);
            widget.onFiltersChanged?.call();
          },
        );
      }).toList(),
    );
  }

  Widget _buildTeamsList(
    BuildContext context,
    List<TeamModel> teams,
    StatisticsFilterModel filter,
  ) {
    if (teams.isEmpty) {
      return const Text('Select leagues first to see available teams');
    }

    return Wrap(
      spacing: 8.w,
      runSpacing: 8.h,
      children: teams.take(20).map((team) { // Limit display
        final isSelected = filter.selectedTeams.contains(team.id);
        return FilterChip(
          label: Text(team.name),
          selected: isSelected,
          onSelected: (selected) {
            ref.read(statisticsFilterProvider.notifier).toggleTeam(team.id);
            widget.onFiltersChanged?.call();
          },
        );
      }).toList(),
    );
  }

  Widget _buildDateRangePicker(
    BuildContext context,
    StatisticsFilterModel filter,
  ) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _selectDate(context, true, filter.startDate),
            icon: const Icon(Icons.calendar_today),
            label: Text(
              filter.startDate != null
                ? '${filter.startDate!.day}/${filter.startDate!.month}/${filter.startDate!.year}'
                : 'Start Date',
            ),
          ),
        ),
        SizedBox(width: 16.w),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _selectDate(context, false, filter.endDate),
            icon: const Icon(Icons.calendar_today),
            label: Text(
              filter.endDate != null
                ? '${filter.endDate!.day}/${filter.endDate!.month}/${filter.endDate!.year}'
                : 'End Date',
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _selectDate(
    BuildContext context,
    bool isStartDate,
    DateTime? currentDate,
  ) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: currentDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365 * 5)),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      final filter = ref.read(statisticsFilterProvider);
      if (isStartDate) {
        ref.read(statisticsFilterProvider.notifier).updateCustomDateRange(
          picked,
          filter.endDate,
        );
      } else {
        ref.read(statisticsFilterProvider.notifier).updateCustomDateRange(
          filter.startDate,
          picked,
        );
      }
      widget.onFiltersChanged?.call();
    }
  }

  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        builder: (context, scrollController) => StatisticsFilter(
          onFiltersChanged: widget.onFiltersChanged,
          isCompact: false,
        ),
      ),
    );
  }

  bool _hasActiveFilters(StatisticsFilterModel filter) {
    return filter.selectedLeagues.isNotEmpty ||
        filter.selectedTeams.isNotEmpty ||
        filter.selectedMetrics.isNotEmpty ||
        filter.timeframe != StatisticsTimeframe.season ||
        filter.viewType != StatisticsViewType.overview;
  }
}