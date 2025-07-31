import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import '../../../../shared/data/models/advanced_statistics_model.dart';
import '../../../../shared/data/models/team_form_model.dart';
import '../../../../shared/data/models/standings_model.dart';
import '../../data/models/chart_data_model.dart';
import '../../data/models/statistics_filter_model.dart';
import 'statistics_provider.dart';

final logger = Logger();

// Standings Chart Data Provider
final standingsChartDataProvider = Provider<StandingsChartDataModel>((ref) {
  final standings = ref.watch(statisticsProvider).standings;
  final filter = ref.watch(statisticsFilterProvider);

  if (standings.isEmpty) {
    return const StandingsChartDataModel(teams: []);
  }

  // Sort standings by position
  final sortedStandings = [...standings];
  sortedStandings.sort((a, b) => a.rank.compareTo(b.rank));

  final teams = sortedStandings.take(20).map((standing) {
    return StandingsBarDataModel(
      teamName: standing.team.name,
      teamLogo: standing.team.logo ?? '',
      position: standing.rank,
      points: standing.points.toDouble(),
      wins: standing.all.win.toDouble(),
      draws: standing.all.draw.toDouble(),
      losses: standing.all.lose.toDouble(),
      goalsFor: standing.all.goals.goalsFor.toDouble(),
      goalsAgainst: standing.all.goals.against.toDouble(),
      color: _getTeamColor(standing.rank),
    );
  }).toList();

  return StandingsChartDataModel(
    teams: teams,
    title: 'League Standings',
    metric: 'Points',
    lastUpdated: DateTime.now(),
  );
});

// Form Chart Data Provider
final formChartDataProvider = Provider<FormChartDataModel>((ref) {
  final teamForms = ref.watch(statisticsProvider).teamForms;
  
  if (teamForms.isEmpty) {
    return const FormChartDataModel(teams: []);
  }

  final teams = teamForms.map((form) {
    // Generate form points over time
    final formPoints = _generateFormPoints(form);

    return FormLineDataModel(
      teamName: 'Team ${form.teamId}', // Would need team name from API
      formPoints: formPoints,
      color: _getRandomColor(),
      visible: true,
    );
  }).toList();

  return FormChartDataModel(
    teams: teams,
    title: 'Team Form Trends',
    yAxisLabel: 'Form Rating',
    lastUpdated: DateTime.now(),
  );
});

// Goal Distribution Chart Data Provider
final goalDistributionChartDataProvider = Provider<GoalDistributionDataModel>((ref) {
  final statistics = ref.watch(filteredTeamStatisticsProvider);
  
  if (statistics.isEmpty) {
    return const GoalDistributionDataModel(segments: []);
  }

  // Aggregate goal statistics
  final totalGoals = statistics.fold<int>(0, (sum, stat) => sum + stat.goalStats.goalsScored);
  final goals0to15 = statistics.fold<int>(0, (sum, stat) => sum + stat.goalStats.goals0to15);
  final goals16to30 = statistics.fold<int>(0, (sum, stat) => sum + stat.goalStats.goals16to30);
  final goals31to45 = statistics.fold<int>(0, (sum, stat) => sum + stat.goalStats.goals31to45);
  final goals46to60 = statistics.fold<int>(0, (sum, stat) => sum + stat.goalStats.goals46to60);
  final goals61to75 = statistics.fold<int>(0, (sum, stat) => sum + stat.goalStats.goals61to75);
  final goals76to90 = statistics.fold<int>(0, (sum, stat) => sum + stat.goalStats.goals76to90);

  final segments = [
    GoalDistributionSegmentModel(
      label: '0-15 min',
      value: goals0to15.toDouble(),
      percentage: totalGoals > 0 ? (goals0to15 / totalGoals) * 100 : 0,
      color: '#FF6B6B',
      description: 'Early goals (0-15 minutes)',
    ),
    GoalDistributionSegmentModel(
      label: '16-30 min',
      value: goals16to30.toDouble(),
      percentage: totalGoals > 0 ? (goals16to30 / totalGoals) * 100 : 0,
      color: '#4ECDC4',
      description: 'Goals in 16-30 minutes',
    ),
    GoalDistributionSegmentModel(
      label: '31-45 min',
      value: goals31to45.toDouble(),
      percentage: totalGoals > 0 ? (goals31to45 / totalGoals) * 100 : 0,
      color: '#45B7D1',
      description: 'Goals in 31-45 minutes',
    ),
    GoalDistributionSegmentModel(
      label: '46-60 min',
      value: goals46to60.toDouble(),
      percentage: totalGoals > 0 ? (goals46to60 / totalGoals) * 100 : 0,
      color: '#FFA726',
      description: 'Goals in 46-60 minutes',
    ),
    GoalDistributionSegmentModel(
      label: '61-75 min',
      value: goals61to75.toDouble(),
      percentage: totalGoals > 0 ? (goals61to75 / totalGoals) * 100 : 0,
      color: '#66BB6A',
      description: 'Goals in 61-75 minutes',
    ),
    GoalDistributionSegmentModel(
      label: '76-90 min',
      value: goals76to90.toDouble(),
      percentage: totalGoals > 0 ? (goals76to90 / totalGoals) * 100 : 0,
      color: '#AB47BC',
      description: 'Late goals (76-90 minutes)',
    ),
  ];

  return GoalDistributionDataModel(
    segments: segments,
    title: 'Goal Distribution by Time',
    totalGoals: totalGoals,
    lastUpdated: DateTime.now(),
  );
});

// Performance Radar Chart Data Provider
final performanceRadarChartDataProvider = Provider<RadarChartDataModel>((ref) {
  final statistics = ref.watch(filteredTeamStatisticsProvider);
  
  if (statistics.isEmpty) {
    return const RadarChartDataModel(dataSets: [], labels: []);
  }

  final labels = [
    'Attack',
    'Defense',
    'Possession',
    'Passing',
    'Set Pieces',
    'Discipline',
  ];

  final dataSets = statistics.take(5).map((stat) { // Limit to 5 teams for readability
    final values = [
      _normalizeValue(stat.goalStats.goalsPerGame, 0, 3), // Attack
      _normalizeValue((stat.matchStats.cleanSheetPercentage), 0, 100), // Defense
      _normalizeValue(stat.possessionStats.possessionPercentage, 0, 100), // Possession
      _normalizeValue(stat.passingStats.passAccuracy, 0, 100), // Passing
      _normalizeValue(stat.setPieceStats.setPieceEfficiency, 0, 100), // Set Pieces
      _normalizeValue(100 - stat.disciplinaryStats.cardsPerGame * 10, 0, 100), // Discipline (inverted)
    ];

    return RadarDataSetModel(
      name: stat.entityName,
      values: values,
      color: _getRandomColor(),
      fillOpacity: 0.2,
      borderWidth: 2.0,
    );
  }).toList();

  return RadarChartDataModel(
    dataSets: dataSets,
    labels: labels,
    title: 'Team Performance Comparison',
    maxValue: 100,
    lastUpdated: DateTime.now(),
  );
});

// Trend Analysis Chart Data Provider
final trendAnalysisChartDataProvider = Provider<TrendAnalysisDataModel>((ref) {
  final statistics = ref.watch(filteredTeamStatisticsProvider);
  final filter = ref.watch(statisticsFilterProvider);
  
  if (statistics.isEmpty) {
    return const TrendAnalysisDataModel(series: [], timePoints: []);
  }

  // Generate time points for the last 30 days
  final now = DateTime.now();
  final timePoints = List.generate(30, (index) => 
    now.subtract(Duration(days: 29 - index))
  );

  final series = statistics.take(3).map((stat) { // Limit to 3 teams
    final dataPoints = timePoints.map((date) {
      // Simulate trend data based on form rating
      final baseValue = stat.formRating;
      final variance = (date.millisecondsSinceEpoch % 1000) / 1000 * 10 - 5;
      final value = (baseValue + variance).clamp(0.0, 100.0);

      return TrendDataPointModel(
        date: date,
        value: value,
        tooltip: '${stat.entityName}: ${value.toStringAsFixed(1)}',
        isProjected: false,
      );
    }).toList();

    final trend = _calculateTrend(dataPoints);

    return TrendSeriesModel(
      name: stat.entityName,
      dataPoints: dataPoints,
      color: _getRandomColor(),
      showTrendLine: true,
      trend: trend,
    );
  }).toList();

  return TrendAnalysisDataModel(
    series: series,
    timePoints: timePoints,
    title: 'Performance Trends',
    yAxisLabel: 'Performance Rating',
    lastUpdated: DateTime.now(),
  );
});

// Generic Chart Data Provider
final chartDataProvider = Provider.family<ChartDataModel, ChartDataType>((ref, type) {
  switch (type) {
    case ChartDataType.standings:
      return _convertStandingsToChartData(ref.watch(standingsChartDataProvider));
    case ChartDataType.form:
      return _convertFormToChartData(ref.watch(formChartDataProvider));
    case ChartDataType.goals:
      return _convertGoalDistributionToChartData(ref.watch(goalDistributionChartDataProvider));
    case ChartDataType.radar:
      return _convertRadarToChartData(ref.watch(performanceRadarChartDataProvider));
    case ChartDataType.trend:
      return _convertTrendToChartData(ref.watch(trendAnalysisChartDataProvider));
    default:
      return const ChartDataModel(
        id: 'empty',
        title: 'No Data',
        type: ChartDataType.distribution,
        series: [],
      );
  }
});

// Helper functions
String _getTeamColor(int position) {
  if (position <= 4) return '#4CAF50'; // Champions League - Green
  if (position <= 6) return '#FF9800'; // Europa League - Orange
  if (position >= 18) return '#F44336'; // Relegation - Red
  return '#2196F3'; // Mid-table - Blue
}

String _getRandomColor() {
  final colors = [
    '#FF6B6B', '#4ECDC4', '#45B7D1', '#FFA726',
    '#66BB6A', '#AB47BC', '#FF7043', '#26A69A',
    '#42A5F5', '#78909C'
  ];
  return colors[DateTime.now().millisecondsSinceEpoch % colors.length];
}

List<FormPointModel> _generateFormPoints(TeamFormModel form) {
  // Generate sample form points based on form string
  final points = <FormPointModel>[];
  final formChars = form.form.split('');
  final now = DateTime.now();

  for (int i = 0; i < formChars.length; i++) {
    final char = formChars[i];
    final date = now.subtract(Duration(days: formChars.length - i - 1));
    
    double pointValue;
    switch (char) {
      case 'W':
        pointValue = 3.0;
        break;
      case 'D':
        pointValue = 1.0;
        break;
      case 'L':
        pointValue = 0.0;
        break;
      default:
        pointValue = 1.0;
    }

    points.add(FormPointModel(
      date: date,
      points: pointValue,
      result: char,
      opponent: 'Opponent ${i + 1}',
      isHome: i % 2 == 0,
    ));
  }

  return points;
}

double _normalizeValue(double value, double min, double max) {
  if (max == min) return 0;
  return ((value - min) / (max - min) * 100).clamp(0, 100);
}

TrendDirection _calculateTrend(List<TrendDataPointModel> dataPoints) {
  if (dataPoints.length < 2) return TrendDirection.stable;

  final firstHalf = dataPoints.take(dataPoints.length ~/ 2);
  final secondHalf = dataPoints.skip(dataPoints.length ~/ 2);

  final firstAvg = firstHalf.fold<double>(0, (sum, point) => sum + point.value) / firstHalf.length;
  final secondAvg = secondHalf.fold<double>(0, (sum, point) => sum + point.value) / secondHalf.length;

  final difference = secondAvg - firstAvg;
  
  if (difference > 5) return TrendDirection.improving;
  if (difference < -5) return TrendDirection.declining;
  return TrendDirection.stable;
}

// Conversion functions
ChartDataModel _convertStandingsToChartData(StandingsChartDataModel standings) {
  final series = [
    ChartSeriesModel(
      name: 'Points',
      data: standings.teams.map((team) => ChartDataPointModel(
        label: team.teamName,
        value: team.points,
        tooltip: '${team.teamName}: ${team.points.toInt()} pts',
      )).toList(),
      color: '#2196F3',
    ),
  ];

  return ChartDataModel(
    id: 'standings',
    title: standings.title,
    type: ChartDataType.standings,
    series: series,
    labels: standings.teams.map((t) => t.teamName).toList(),
    lastUpdated: standings.lastUpdated,
  );
}

ChartDataModel _convertFormToChartData(FormChartDataModel form) {
  final series = form.teams.map((team) {
    return ChartSeriesModel(
      name: team.teamName,
      data: team.formPoints.asMap().entries.map((entry) {
        final index = entry.key;
        final point = entry.value;
        return ChartDataPointModel(
          label: 'Match ${index + 1}',
          value: point.points,
          x: index.toDouble(),
          y: point.points,
          tooltip: '${team.teamName}: ${point.result} (${point.points} pts)',
        );
      }).toList(),
      color: team.color,
      visible: team.visible,
    );
  }).toList();

  return ChartDataModel(
    id: 'form',
    title: form.title,
    type: ChartDataType.form,
    series: series,
    lastUpdated: form.lastUpdated,
  );
}

ChartDataModel _convertGoalDistributionToChartData(GoalDistributionDataModel goals) {
  final series = [
    ChartSeriesModel(
      name: 'Goals',
      data: goals.segments.map((segment) => ChartDataPointModel(
        label: segment.label,
        value: segment.value,
        color: segment.color,
        tooltip: '${segment.label}: ${segment.value.toInt()} goals (${segment.percentage.toStringAsFixed(1)}%)',
      )).toList(),
    ),
  ];

  return ChartDataModel(
    id: 'goals',
    title: goals.title,
    type: ChartDataType.goals,
    series: series,
    labels: goals.segments.map((s) => s.label).toList(),
    lastUpdated: goals.lastUpdated,
  );
}

ChartDataModel _convertRadarToChartData(RadarChartDataModel radar) {
  final series = radar.dataSets.map((dataSet) {
    return ChartSeriesModel(
      name: dataSet.name,
      data: dataSet.values.asMap().entries.map((entry) {
        final index = entry.key;
        final value = entry.value;
        final label = index < radar.labels.length ? radar.labels[index] : 'Metric $index';
        
        return ChartDataPointModel(
          label: label,
          value: value,
          tooltip: '${dataSet.name} - $label: ${value.toStringAsFixed(1)}',
        );
      }).toList(),
      color: dataSet.color,
    );
  }).toList();

  return ChartDataModel(
    id: 'radar',
    title: radar.title,
    type: ChartDataType.radar,
    series: series,
    labels: radar.labels,
    lastUpdated: radar.lastUpdated,
  );
}

ChartDataModel _convertTrendToChartData(TrendAnalysisDataModel trend) {
  final series = trend.series.map((trendSeries) {
    return ChartSeriesModel(
      name: trendSeries.name,
      data: trendSeries.dataPoints.map((point) => ChartDataPointModel(
        label: point.date.toString().split(' ')[0],
        value: point.value,
        x: point.date.millisecondsSinceEpoch.toDouble(),
        y: point.value,
        tooltip: point.tooltip ?? '${trendSeries.name}: ${point.value.toStringAsFixed(1)}',
      )).toList(),
      color: trendSeries.color,
    );
  }).toList();

  return ChartDataModel(
    id: 'trend',
    title: trend.title,
    type: ChartDataType.trend,
    series: series,
    lastUpdated: trend.lastUpdated,
  );
}