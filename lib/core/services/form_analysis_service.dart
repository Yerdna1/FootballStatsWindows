import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

import '../../shared/data/models/fixture_model.dart';
import '../../shared/data/models/team_form_model.dart';
import '../../shared/data/models/prediction_model.dart';
import '../../shared/data/models/analysis_result_model.dart';
import '../../shared/data/models/performance_metrics_model.dart';
import '../network/football_api_client.dart';

class FormAnalysisService {
  final FootballApiClient _apiClient;
  final Logger _logger = Logger();

  FormAnalysisService(this._apiClient);

  /// Analyzes team form over a specified period
  Future<TeamFormModel?> analyzeTeamForm(
    int teamId, {
    int matchCount = 10,
    bool includeHomeAway = true,
  }) async {
    try {
      _logger.i('Analyzing form for team $teamId with $matchCount matches');

      // Get recent fixtures
      final fixtures = await _apiClient.getFixtures(teamId: teamId);
      final completedFixtures = fixtures
          .where((f) => f.fixture?.status?.short == 'FT')
          .take(matchCount)
          .toList();

      if (completedFixtures.isEmpty) {
        _logger.w('No completed fixtures found for team $teamId');
        return null;
      }

      // Calculate basic form statistics
      final formStats = _calculateBasicForm(teamId, completedFixtures);
      
      // Calculate advanced metrics
      final homeAwayForm = includeHomeAway 
          ? _calculateHomeAwayForm(teamId, completedFixtures)
          : null;
      
      final formStreaks = _calculateFormStreaks(teamId, completedFixtures);
      final attackingForm = _calculateAttackingForm(teamId, completedFixtures);
      final defensiveForm = _calculateDefensiveForm(teamId, completedFixtures);
      final formTrend = _calculateFormTrend(teamId, completedFixtures);

      return TeamFormModel(
        teamId: teamId,
        recentMatches: completedFixtures.length,
        wins: formStats['wins']!,
        draws: formStats['draws']!,
        losses: formStats['losses']!,
        goalsFor: formStats['goalsFor']!,
        goalsAgainst: formStats['goalsAgainst']!,
        form: formStats['formString'] as String,
        formPercentage: formStats['formPercentage']! as double,
        homeForm: homeAwayForm?['home'] as TeamFormStats?,
        awayForm: homeAwayForm?['away'] as TeamFormStats?,
        currentStreak: formStreaks['current'] as FormStreak?,
        longestWinStreak: formStreaks['longestWin'] as FormStreak?,
        longestUnbeatenStreak: formStreaks['longestUnbeaten'] as FormStreak?,
        attackingForm: attackingForm,
        defensiveForm: defensiveForm,
        formTrend: formTrend,
        lastUpdated: DateTime.now(),
      );
    } catch (e) {
      _logger.e('Error analyzing team form: $e');
      return null;
    }
  }

  /// Generates predictions based on team form analysis
  Future<PredictionModel?> generateFormPrediction(
    int fixture1Id,
    int homeTeamId,
    int awayTeamId, {
    int formDepth = 10,
  }) async {
    try {
      _logger.i('Generating prediction for fixture $fixture1Id');

      // Get form analysis for both teams
      final homeForm = await analyzeTeamForm(homeTeamId, matchCount: formDepth);
      final awayForm = await analyzeTeamForm(awayTeamId, matchCount: formDepth);

      if (homeForm == null || awayForm == null) {
        _logger.w('Could not get form data for both teams');
        return null;
      }

      // Calculate prediction probabilities
      final probabilities = _calculateMatchProbabilities(homeForm, awayForm);
      
      // Generate prediction scenarios
      final scenarios = _generatePredictionScenarios(homeForm, awayForm);
      
      // Calculate confidence metrics
      final confidence = _calculatePredictionConfidence(homeForm, awayForm);

      return PredictionModel(
        fixtureId: fixture1Id,
        homeTeamId: homeTeamId,
        awayTeamId: awayTeamId,
        homeWinProbability: probabilities['homeWin']!,
        drawProbability: probabilities['draw']!,
        awayWinProbability: probabilities['awayWin']!,
        predictedHomeGoals: probabilities['homeGoals']!,
        predictedAwayGoals: probabilities['awayGoals']!,
        confidence: confidence,
        predictionType: PredictionType.formBased,
        scenarios: scenarios,
        createdAt: DateTime.now(),
        lastUpdated: DateTime.now(),
      );
    } catch (e) {
      _logger.e('Error generating prediction: $e');
      return null;
    }
  }

  /// Performs comprehensive analysis comparing multiple teams
  Future<AnalysisResultModel> performComprehensiveAnalysis(
    List<int> teamIds, {
    int matchDepth = 15,
    AnalysisType analysisType = AnalysisType.form,
  }) async {
    try {
      _logger.i('Performing comprehensive analysis for ${teamIds.length} teams');

      final teamAnalyses = <int, TeamFormModel>{};
      final insights = <AnalysisInsight>[];
      final recommendations = <AnalysisRecommendation>[];

      // Analyze each team
      for (final teamId in teamIds) {
        final form = await analyzeTeamForm(teamId, matchCount: matchDepth);
        if (form != null) {
          teamAnalyses[teamId] = form;
        }
      }

      // Generate comparative insights
      insights.addAll(_generateFormInsights(teamAnalyses));
      
      // Generate recommendations
      recommendations.addAll(_generateFormRecommendations(teamAnalyses));

      return AnalysisResultModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        analysisType: analysisType,
        title: 'Team Form Analysis',
        description: 'Comprehensive form analysis for ${teamIds.length} teams',
        insights: insights,
        recommendations: recommendations,
        metadata: {
          'teamCount': teamIds.length,
          'matchDepth': matchDepth,
          'analysisDate': DateTime.now().toIso8601String(),
        },
        createdAt: DateTime.now(),
        lastUpdated: DateTime.now(),
      );
    } catch (e) {
      _logger.e('Error performing comprehensive analysis: $e');
      rethrow;
    }
  }

  // Private helper methods

  Map<String, dynamic> _calculateBasicForm(int teamId, List<FixtureModel> fixtures) {
    int wins = 0, draws = 0, losses = 0;
    int goalsFor = 0, goalsAgainst = 0;
    final formString = StringBuffer();

    for (final fixture in fixtures) {
      final isHome = fixture.teams?.home?.id == teamId;
      final homeGoals = fixture.goals?.home ?? 0;
      final awayGoals = fixture.goals?.away ?? 0;
      
      final teamGoals = isHome ? homeGoals : awayGoals;
      final opponentGoals = isHome ? awayGoals : homeGoals;
      
      goalsFor += teamGoals;
      goalsAgainst += opponentGoals;

      if (teamGoals > opponentGoals) {
        wins++;
        formString.write('W');
      } else if (teamGoals == opponentGoals) {
        draws++;
        formString.write('D');
      } else {
        losses++;
        formString.write('L');
      }
    }

    final totalMatches = fixtures.length;
    final points = wins * 3 + draws;
    final formPercentage = totalMatches > 0 ? (points / (totalMatches * 3)) * 100 : 0.0;

    return {
      'wins': wins,
      'draws': draws,
      'losses': losses,
      'goalsFor': goalsFor,
      'goalsAgainst': goalsAgainst,
      'formString': formString.toString(),
      'formPercentage': formPercentage,
    };
  }

  Map<String, TeamFormStats> _calculateHomeAwayForm(int teamId, List<FixtureModel> fixtures) {
    final homeFixtures = fixtures.where((f) => f.teams?.home?.id == teamId).toList();
    final awayFixtures = fixtures.where((f) => f.teams?.away?.id == teamId).toList();

    final homeStats = _calculateFormStats(teamId, homeFixtures, true);
    final awayStats = _calculateFormStats(teamId, awayFixtures, false);

    return {
      'home': homeStats,
      'away': awayStats,
    };
  }

  TeamFormStats _calculateFormStats(int teamId, List<FixtureModel> fixtures, bool isHome) {
    final basicForm = _calculateBasicForm(teamId, fixtures);
    
    return TeamFormStats(
      matches: fixtures.length,
      wins: basicForm['wins'],
      draws: basicForm['draws'],
      losses: basicForm['losses'],
      goalsFor: basicForm['goalsFor'],
      goalsAgainst: basicForm['goalsAgainst'],
      formPercentage: basicForm['formPercentage'],
    );
  }

  Map<String, FormStreak?> _calculateFormStreaks(int teamId, List<FixtureModel> fixtures) {
    if (fixtures.isEmpty) return {'current': null, 'longestWin': null, 'longestUnbeaten': null};

    final results = fixtures.map((f) {
      final isHome = f.teams?.home?.id == teamId;
      final homeGoals = f.goals?.home ?? 0;
      final awayGoals = f.goals?.away ?? 0;
      
      if (isHome) {
        if (homeGoals > awayGoals) return 'W';
        if (homeGoals == awayGoals) return 'D';
        return 'L';
      } else {
        if (awayGoals > homeGoals) return 'W';
        if (awayGoals == homeGoals) return 'D';
        return 'L';
      }
    }).toList();

    return {
      'current': _getCurrentStreak(results),
      'longestWin': _getLongestStreak(results, 'W'),
      'longestUnbeaten': _getLongestUnbeatenStreak(results),
    };
  }

  FormStreak? _getCurrentStreak(List<String> results) {
    if (results.isEmpty) return null;
    
    final currentResult = results.first;
    int count = 1;
    
    for (int i = 1; i < results.length; i++) {
      if (results[i] == currentResult) {
        count++;
      } else {
        break;
      }
    }
    
    return FormStreak(
      type: _getStreakType(currentResult),
      length: count,
      isActive: true,
    );
  }

  FormStreak? _getLongestStreak(List<String> results, String resultType) {
    if (results.isEmpty) return null;
    
    int maxLength = 0;
    int currentLength = 0;
    
    for (final result in results) {
      if (result == resultType) {
        currentLength++;
        maxLength = max(maxLength, currentLength);
      } else {
        currentLength = 0;
      }
    }
    
    return maxLength > 0 ? FormStreak(
      type: _getStreakType(resultType),
      length: maxLength,
      isActive: false,
    ) : null;
  }

  FormStreak? _getLongestUnbeatenStreak(List<String> results) {
    if (results.isEmpty) return null;
    
    int maxLength = 0;
    int currentLength = 0;
    
    for (final result in results) {
      if (result == 'W' || result == 'D') {
        currentLength++;
        maxLength = max(maxLength, currentLength);
      } else {
        currentLength = 0;
      }
    }
    
    return maxLength > 0 ? FormStreak(
      type: StreakType.unbeaten,
      length: maxLength,
      isActive: false,
    ) : null;
  }

  StreakType _getStreakType(String result) {
    switch (result) {
      case 'W': return StreakType.winning;
      case 'D': return StreakType.drawing;
      case 'L': return StreakType.losing;
      default: return StreakType.winning;
    }
  }

  AttackingForm _calculateAttackingForm(int teamId, List<FixtureModel> fixtures) {
    final goals = <int>[];
    int totalGoals = 0;
    int matches = 0;

    for (final fixture in fixtures) {
      final isHome = fixture.teams?.home?.id == teamId;
      final teamGoals = isHome ? (fixture.goals?.home ?? 0) : (fixture.goals?.away ?? 0);
      
      goals.add(teamGoals);
      totalGoals += teamGoals;
      matches++;
    }

    final averageGoals = matches > 0 ? totalGoals / matches : 0.0;
    final goalsVariance = _calculateVariance(goals.map((g) => g.toDouble()).toList());
    
    return AttackingForm(
      averageGoals: averageGoals,
      totalGoals: totalGoals,
      goalsPerMatch: averageGoals,
      consistency: _calculateConsistency(goalsVariance),
      trend: _calculateTrend(goals.map((g) => g.toDouble()).toList()),
    );
  }

  DefensiveForm _calculateDefensiveForm(int teamId, List<FixtureModel> fixtures) {
    final goalsConceded = <int>[];
    int totalConceded = 0;
    int cleanSheets = 0;
    int matches = 0;

    for (final fixture in fixtures) {
      final isHome = fixture.teams?.home?.id == teamId;
      final conceded = isHome ? (fixture.goals?.away ?? 0) : (fixture.goals?.home ?? 0);
      
      goalsConceded.add(conceded);
      totalConceded += conceded;
      if (conceded == 0) cleanSheets++;
      matches++;
    }

    final averageConceded = matches > 0 ? totalConceded / matches : 0.0;
    final cleanSheetPercentage = matches > 0 ? (cleanSheets / matches) * 100 : 0.0;
    
    return DefensiveForm(
      averageGoalsConceded: averageConceded,
      totalGoalsConceded: totalConceded,
      cleanSheets: cleanSheets,
      cleanSheetPercentage: cleanSheetPercentage,
      consistency: _calculateConsistency(_calculateVariance(goalsConceded.map((g) => g.toDouble()).toList())),
      trend: _calculateTrend(goalsConceded.map((g) => g.toDouble()).toList()),
    );
  }

  FormTrend _calculateFormTrend(int teamId, List<FixtureModel> fixtures) {
    if (fixtures.length < 2) {
      return FormTrend(
        direction: TrendDirection.stable,
        strength: 0.0,
        description: 'Insufficient data',
      );
    }

    // Calculate points for each match (W=3, D=1, L=0)
    final points = <double>[];
    for (final fixture in fixtures.reversed) {
      final isHome = fixture.teams?.home?.id == teamId;
      final homeGoals = fixture.goals?.home ?? 0;
      final awayGoals = fixture.goals?.away ?? 0;
      
      if (isHome) {
        if (homeGoals > awayGoals) points.add(3.0);
        else if (homeGoals == awayGoals) points.add(1.0);
        else points.add(0.0);
      } else {
        if (awayGoals > homeGoals) points.add(3.0);
        else if (awayGoals == homeGoals) points.add(1.0);
        else points.add(0.0);
      }
    }

    final trend = _calculateTrend(points);
    final direction = trend > 0.1 ? TrendDirection.improving 
                    : trend < -0.1 ? TrendDirection.declining 
                    : TrendDirection.stable;

    return FormTrend(
      direction: direction,
      strength: trend.abs(),
      description: _getTrendDescription(direction, trend.abs()),
    );
  }

  double _calculateTrend(List<double> values) {
    if (values.length < 2) return 0.0;
    
    final n = values.length;
    final xMean = (n - 1) / 2.0;
    final yMean = values.reduce((a, b) => a + b) / n;
    
    double numerator = 0.0;
    double denominator = 0.0;
    
    for (int i = 0; i < n; i++) {
      final xDiff = i - xMean;
      final yDiff = values[i] - yMean;
      numerator += xDiff * yDiff;
      denominator += xDiff * xDiff;
    }
    
    return denominator != 0 ? numerator / denominator : 0.0;
  }

  double _calculateVariance(List<double> values) {
    if (values.isEmpty) return 0.0;
    
    final mean = values.reduce((a, b) => a + b) / values.length;
    final squaredDiffs = values.map((v) => pow(v - mean, 2));
    return squaredDiffs.reduce((a, b) => a + b) / values.length;
  }

  double _calculateConsistency(double variance) {
    // Inverse relationship: lower variance = higher consistency
    return 1.0 / (1.0 + variance);
  }

  String _getTrendDescription(TrendDirection direction, double strength) {
    final intensityMap = {
      0.0: 'stable',
      0.3: 'slight',
      0.6: 'moderate',
      0.9: 'strong',
      1.2: 'very strong',
    };
    
    String intensity = 'stable';
    for (final entry in intensityMap.entries) {
      if (strength >= entry.key) {
        intensity = entry.value;
      }
    }
    
    switch (direction) {
      case TrendDirection.improving:
        return '$intensity improvement';
      case TrendDirection.declining:
        return '$intensity decline';
      case TrendDirection.stable:
        return 'stable form';
    }
  }

  Map<String, double> _calculateMatchProbabilities(TeamFormModel homeForm, TeamFormModel awayForm) {
    // Basic probability calculation based on form percentages and home advantage
    final homeFormScore = homeForm.formPercentage + (homeForm.homeForm?.formPercentage ?? 0) * 0.5;
    final awayFormScore = awayForm.formPercentage + (awayForm.awayForm?.formPercentage ?? 0) * 0.5;
    
    // Home advantage factor (typically 5-10%)
    final homeAdvantage = 7.5;
    final adjustedHomeScore = homeFormScore + homeAdvantage;
    
    // Calculate basic probabilities
    final totalScore = adjustedHomeScore + awayFormScore;
    var homeWin = totalScore > 0 ? adjustedHomeScore / totalScore * 0.6 : 0.33;
    var awayWin = totalScore > 0 ? awayFormScore / totalScore * 0.6 : 0.33;
    var draw = 1.0 - homeWin - awayWin;
    
    // Ensure probabilities are reasonable
    homeWin = homeWin.clamp(0.15, 0.70);
    awayWin = awayWin.clamp(0.15, 0.70);
    draw = draw.clamp(0.15, 0.40);
    
    // Normalize to sum to 1.0
    final sum = homeWin + draw + awayWin;
    homeWin /= sum;
    draw /= sum;
    awayWin /= sum;
    
    // Calculate expected goals based on attacking/defensive form
    final homeExpectedGoals = (homeForm.attackingForm?.averageGoals ?? 1.5) * 
                             (1.0 - (awayForm.defensiveForm?.averageGoalsConceded ?? 1.0) / 3.0);
    final awayExpectedGoals = (awayForm.attackingForm?.averageGoals ?? 1.5) * 
                             (1.0 - (homeForm.defensiveForm?.averageGoalsConceded ?? 1.0) / 3.0);
    
    return {
      'homeWin': homeWin,
      'draw': draw,
      'awayWin': awayWin,
      'homeGoals': homeExpectedGoals.clamp(0.0, 5.0),
      'awayGoals': awayExpectedGoals.clamp(0.0, 5.0),
    };
  }

  List<PredictionScenario> _generatePredictionScenarios(TeamFormModel homeForm, TeamFormModel awayForm) {
    return [
      PredictionScenario(
        name: 'Most Likely',
        description: 'Based on current form and historical performance',
        probability: 0.65,
        conditions: ['Current form maintained', 'No major injuries'],
      ),
      PredictionScenario(
        name: 'Home Dominance',
        description: 'Home team takes advantage of venue and form',
        probability: 0.25,
        conditions: ['Home advantage maximized', 'Away team struggles'],
      ),
      PredictionScenario(
        name: 'Upset Result',
        description: 'Underdog performs beyond expectations',
        probability: 0.10,
        conditions: ['Form reversal', 'Tactical surprise'],
      ),
    ];
  }

  PredictionConfidence _calculatePredictionConfidence(TeamFormModel homeForm, TeamFormModel awayForm) {
    // Calculate confidence based on form consistency and data quality
    final homeConsistency = homeForm.attackingForm?.consistency ?? 0.5;
    final awayConsistency = awayForm.attackingForm?.consistency ?? 0.5;
    final avgConsistency = (homeConsistency + awayConsistency) / 2;
    
    final dataQuality = min(homeForm.recentMatches, awayForm.recentMatches) / 10.0;
    final overallConfidence = (avgConsistency * 0.6 + dataQuality * 0.4).clamp(0.0, 1.0);
    
    return PredictionConfidence(
      overall: overallConfidence,
      dataQuality: dataQuality,
      modelReliability: avgConsistency,
      factors: {
        'form_consistency': avgConsistency,
        'data_availability': dataQuality,
        'historical_accuracy': 0.75, // Placeholder - would be calculated from past predictions
      },
    );
  }

  List<AnalysisInsight> _generateFormInsights(Map<int, TeamFormModel> teamAnalyses) {
    final insights = <AnalysisInsight>[];
    
    if (teamAnalyses.isEmpty) return insights;
    
    // Find best and worst performing teams
    final sortedTeams = teamAnalyses.entries.toList()
      ..sort((a, b) => b.value.formPercentage.compareTo(a.value.formPercentage));
    
    final bestTeam = sortedTeams.first;
    final worstTeam = sortedTeams.last;
    
    insights.add(AnalysisInsight(
      title: 'Best Form',
      description: 'Team ${bestTeam.key} has the best current form with ${bestTeam.value.formPercentage.toStringAsFixed(1)}%',
      significance: 0.9,
      category: 'Performance',
      impact: InsightImpact.high,
    ));
    
    insights.add(AnalysisInsight(
      title: 'Worst Form',
      description: 'Team ${worstTeam.key} needs improvement with ${worstTeam.value.formPercentage.toStringAsFixed(1)}% form',
      significance: 0.8,
      category: 'Performance',
      impact: InsightImpact.medium,
    ));
    
    return insights;
  }

  List<AnalysisRecommendation> _generateFormRecommendations(Map<int, TeamFormModel> teamAnalyses) {
    final recommendations = <AnalysisRecommendation>[];
    
    for (final entry in teamAnalyses.entries) {
      final form = entry.value;
      
      if (form.formPercentage < 30) {
        recommendations.add(AnalysisRecommendation(
          title: 'Form Recovery',
          description: 'Team ${entry.key} should focus on defensive stability and confidence building',
          priority: RecommendationPriority.high,
          feasibility: 0.7,
          expectedImpact: 0.8,
          actions: ['Strengthen defense', 'Build team confidence', 'Analyze recent losses'],
        ));
      }
    }
    
    return recommendations;
  }
}

// Provider for the form analysis service
final formAnalysisServiceProvider = Provider<FormAnalysisService>((ref) {
  final apiClient = ref.watch(footballApiClientProvider);
  return FormAnalysisService(apiClient);
});