import 'dart:math' as math;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

import '../network/production_football_api.dart';

/// Production Form Analyzer - Exact port of Python form_analyzer.py
class ProductionFormAnalyzer {
  static const int defaultFormLength = 10;
  static const double homeAdvantage = 0.1;
  static const double significantStreakLength = 5.0;
  
  final ProductionFootballApi _api;
  final Logger _logger = Logger();
  
  ProductionFormAnalyzer(this._api);
  
  /// Main form analysis method - equivalent to Python analyze_team_form()
  Future<TeamFormAnalysis> analyzeTeamForm(
    int teamId, {
    int formLength = defaultFormLength,
    int? leagueId,
    int? season,
  }) async {
    _logger.i('Analyzing form for team $teamId (length: $formLength)');
    
    try {
      // Get recent fixtures for the team
      final fixtures = await _api.getFixtures(
        teamId: teamId,
        last: formLength * 2, // Get extra to filter finished games
      );
      
      // Filter to only finished fixtures
      final finishedFixtures = fixtures
          .where((f) => f.isFinished)
          .take(formLength)
          .toList();
      
      if (finishedFixtures.isEmpty) {
        _logger.w('No finished fixtures found for team $teamId');
        return TeamFormAnalysis.empty(teamId);
      }
      
      // Calculate all form metrics (matching Python logic)
      final basicForm = _calculateBasicForm(teamId, finishedFixtures);
      final streakData = _calculateStreaks(teamId, finishedFixtures);
      final goalStats = _calculateGoalStatistics(teamId, finishedFixtures);
      final homeAwayForm = _calculateHomeAwayForm(teamId, finishedFixtures);
      final momentum = _calculateMomentum(teamId, finishedFixtures);
      final consistency = _calculateConsistency(teamId, finishedFixtures);
      final formTrend = _calculateFormTrend(teamId, finishedFixtures);
      final difficultyAdjustment = await _calculateOpponentDifficulty(teamId, finishedFixtures);
      
      // Calculate advanced metrics
      final formPercentage = _calculateFormPercentage(basicForm);
      final xGDiff = _calculateExpectedGoalsDifference(goalStats);
      final performanceRating = _calculatePerformanceRating(
        formPercentage, momentum, consistency, difficultyAdjustment
      );
      
      return TeamFormAnalysis(
        teamId: teamId,
        analysisDate: DateTime.now(),
        formLength: finishedFixtures.length,
        
        // Basic form data
        form: basicForm.formString,
        formPercentage: formPercentage,
        wins: basicForm.wins,
        draws: basicForm.draws,
        losses: basicForm.losses,
        
        // Goal statistics
        goalsFor: goalStats.totalFor,
        goalsAgainst: goalStats.totalAgainst,
        goalDifference: goalStats.totalFor - goalStats.totalAgainst,
        averageGoalsFor: goalStats.averageFor,
        averageGoalsAgainst: goalStats.averageAgainst,
        
        // Streaks
        currentStreak: streakData.currentStreak,
        currentStreakLength: streakData.currentStreakLength,
        longestWinStreak: streakData.longestWinStreak,
        longestUnbeatenStreak: streakData.longestUnbeatenStreak,
        longestLoseStreak: streakData.longestLoseStreak,
        
        // Home/Away split
        homeForm: homeAwayForm.homeForm,
        awayForm: homeAwayForm.awayForm,
        
        // Advanced metrics
        momentum: momentum,
        consistency: consistency,
        formTrend: formTrend,
        opponentDifficulty: difficultyAdjustment,
        performanceRating: performanceRating,
        expectedGoalsDifference: xGDiff,
        
        // Additional data
        recentFixtures: finishedFixtures,
        lastUpdated: DateTime.now(),
      );
      
    } catch (e) {
      _logger.e('Error analyzing team form: $e');
      rethrow;
    }
  }
  
  /// Calculate basic form metrics (W/D/L) - matches Python logic
  BasicFormData _calculateBasicForm(int teamId, List<FixtureData> fixtures) {
    int wins = 0, draws = 0, losses = 0;
    final formChars = <String>[];
    
    // Process fixtures in chronological order (oldest first)
    final chronologicalFixtures = fixtures.reversed.toList();
    
    for (final fixture in chronologicalFixtures) {
      if (fixture.isDraw) {
        draws++;
        formChars.add('D');
      } else if (fixture.isTeamWinner(teamId)) {
        wins++;
        formChars.add('W');
      } else {
        losses++;
        formChars.add('L');
      }
    }
    
    return BasicFormData(
      wins: wins,
      draws: draws,
      losses: losses,
      formString: formChars.join(),
    );
  }
  
  /// Calculate all streak data - matches Python streak calculations
  StreakData _calculateStreaks(int teamId, List<FixtureData> fixtures) {
    if (fixtures.isEmpty) {
      return StreakData.empty();
    }
    
    // Process in chronological order
    final chronologicalFixtures = fixtures.reversed.toList();
    
    String? currentStreakType;
    int currentStreakLength = 0;
    int longestWinStreak = 0;
    int longestUnbeatenStreak = 0;
    int longestLoseStreak = 0;
    
    int tempWinStreak = 0;
    int tempUnbeatenStreak = 0;
    int tempLoseStreak = 0;
    
    for (final fixture in chronologicalFixtures) {
      final isWin = fixture.isTeamWinner(teamId);
      final isDraw = fixture.isDraw;
      final isLoss = fixture.isTeamLoser(teamId);
      
      // Update current streak
      if (currentStreakType == null) {
        // First match sets the initial streak
        if (isWin) {
          currentStreakType = 'W';
          currentStreakLength = 1;
        } else if (isDraw) {
          currentStreakType = 'D';
          currentStreakLength = 1;
        } else {
          currentStreakType = 'L';
          currentStreakLength = 1;
        }
      } else {
        // Check if streak continues
        if ((currentStreakType == 'W' && isWin) ||
            (currentStreakType == 'D' && isDraw) ||
            (currentStreakType == 'L' && isLoss)) {
          currentStreakLength++;
        } else {
          // Streak broken - start new streak
          if (isWin) {
            currentStreakType = 'W';
            currentStreakLength = 1;
          } else if (isDraw) {
            currentStreakType = 'D';
            currentStreakLength = 1;
          } else {
            currentStreakType = 'L';
            currentStreakLength = 1;
          }
        }
      }
      
      // Track longest streaks
      if (isWin) {
        tempWinStreak++;
        tempUnbeatenStreak++;
        tempLoseStreak = 0;
        
        longestWinStreak = math.max(longestWinStreak, tempWinStreak);
        longestUnbeatenStreak = math.max(longestUnbeatenStreak, tempUnbeatenStreak);
      } else if (isDraw) {
        tempWinStreak = 0;
        tempUnbeatenStreak++;
        tempLoseStreak = 0;
        
        longestUnbeatenStreak = math.max(longestUnbeatenStreak, tempUnbeatenStreak);
      } else {
        tempWinStreak = 0;
        tempUnbeatenStreak = 0;
        tempLoseStreak++;
        
        longestLoseStreak = math.max(longestLoseStreak, tempLoseStreak);
      }
    }
    
    // For current streak, we want the most recent streak (from latest fixtures)
    final latestFixtures = fixtures.take(10).toList();
    final latestStreak = _getCurrentStreakFromLatest(teamId, latestFixtures);
    
    return StreakData(
      currentStreak: latestStreak.type,
      currentStreakLength: latestStreak.length,
      longestWinStreak: longestWinStreak,
      longestUnbeatenStreak: longestUnbeatenStreak,
      longestLoseStreak: longestLoseStreak,
    );
  }
  
  /// Get current streak from latest fixtures (most recent first)
  CurrentStreak _getCurrentStreakFromLatest(int teamId, List<FixtureData> fixtures) {
    if (fixtures.isEmpty) return CurrentStreak('', 0);
    
    final latestFixture = fixtures.first;
    String streakType;
    
    if (latestFixture.isTeamWinner(teamId)) {
      streakType = 'W';
    } else if (latestFixture.isDraw) {
      streakType = 'D';
    } else {
      streakType = 'L';
    }
    
    int streakLength = 1;
    
    // Count how many consecutive fixtures have the same result
    for (int i = 1; i < fixtures.length; i++) {
      final fixture = fixtures[i];
      bool sameResult = false;
      
      switch (streakType) {
        case 'W':
          sameResult = fixture.isTeamWinner(teamId);
          break;
        case 'D':
          sameResult = fixture.isDraw;
          break;
        case 'L':
          sameResult = fixture.isTeamLoser(teamId);
          break;
      }
      
      if (sameResult) {
        streakLength++;
      } else {
        break;
      }
    }
    
    return CurrentStreak(streakType, streakLength);
  }
  
  /// Calculate goal statistics
  GoalStatistics _calculateGoalStatistics(int teamId, List<FixtureData> fixtures) {
    int totalFor = 0, totalAgainst = 0;
    final goalsForList = <int>[];
    final goalsAgainstList = <int>[];
    
    for (final fixture in fixtures) {
      int goalsFor, goalsAgainst;
      
      if (fixture.homeTeam.id == teamId) {
        goalsFor = fixture.goals?.home ?? 0;
        goalsAgainst = fixture.goals?.away ?? 0;
      } else {
        goalsFor = fixture.goals?.away ?? 0;
        goalsAgainst = fixture.goals?.home ?? 0;
      }
      
      totalFor += goalsFor;
      totalAgainst += goalsAgainst;
      goalsForList.add(goalsFor);
      goalsAgainstList.add(goalsAgainst);
    }
    
    final matchCount = fixtures.length;
    
    return GoalStatistics(
      totalFor: totalFor,
      totalAgainst: totalAgainst,
      averageFor: matchCount > 0 ? totalFor / matchCount : 0.0,
      averageAgainst: matchCount > 0 ? totalAgainst / matchCount : 0.0,
      goalsForList: goalsForList,
      goalsAgainstList: goalsAgainstList,
    );
  }
  
  /// Calculate home/away form split
  HomeAwayFormSplit _calculateHomeAwayForm(int teamId, List<FixtureData> fixtures) {
    final homeFixtures = fixtures.where((f) => f.homeTeam.id == teamId).toList();
    final awayFixtures = fixtures.where((f) => f.awayTeam.id == teamId).toList();
    
    final homeForm = homeFixtures.isNotEmpty 
        ? _calculateFormForFixtures(teamId, homeFixtures, true)
        : null;
    
    final awayForm = awayFixtures.isNotEmpty
        ? _calculateFormForFixtures(teamId, awayFixtures, false)
        : null;
    
    return HomeAwayFormSplit(
      homeForm: homeForm,
      awayForm: awayForm,
    );
  }
  
  /// Calculate form for specific fixtures (home or away)
  FormSummary _calculateFormForFixtures(int teamId, List<FixtureData> fixtures, bool isHome) {
    final basicForm = _calculateBasicForm(teamId, fixtures);
    final goalStats = _calculateGoalStatistics(teamId, fixtures);
    
    return FormSummary(
      matches: fixtures.length,
      wins: basicForm.wins,
      draws: basicForm.draws,
      losses: basicForm.losses,
      form: basicForm.formString,
      formPercentage: _calculateFormPercentage(basicForm),
      goalsFor: goalStats.totalFor,
      goalsAgainst: goalStats.totalAgainst,
      averageGoalsFor: goalStats.averageFor,
      averageGoalsAgainst: goalStats.averageAgainst,
      isHome: isHome,
    );
  }
  
  /// Calculate form percentage (points percentage)
  double _calculateFormPercentage(BasicFormData form) {
    final totalMatches = form.wins + form.draws + form.losses;
    if (totalMatches == 0) return 0.0;
    
    final totalPoints = (form.wins * 3) + form.draws;
    final maxPoints = totalMatches * 3;
    
    return (totalPoints / maxPoints) * 100;
  }
  
  /// Calculate momentum (recent form weighted more heavily)
  double _calculateMomentum(int teamId, List<FixtureData> fixtures) {
    if (fixtures.length < 3) return 0.0;
    
    double momentum = 0.0;
    
    // Weight recent games more heavily (exponential decay)
    for (int i = 0; i < fixtures.length; i++) {
      final fixture = fixtures[i];
      final weight = math.pow(0.85, i).toDouble(); // Recent games weighted higher
      
      if (fixture.isTeamWinner(teamId)) {
        momentum += 3.0 * weight;
      } else if (fixture.isDraw) {
        momentum += 1.0 * weight;
      }
      // Losses add 0 to momentum
    }
    
    return momentum;
  }
  
  /// Calculate consistency (standard deviation of points per game)
  double _calculateConsistency(int teamId, List<FixtureData> fixtures) {
    if (fixtures.length < 2) return 0.0;
    
    final points = <double>[];
    
    for (final fixture in fixtures) {
      if (fixture.isTeamWinner(teamId)) {
        points.add(3.0);
      } else if (fixture.isDraw) {
        points.add(1.0);
      } else {
        points.add(0.0);
      }
    }
    
    final mean = points.reduce((a, b) => a + b) / points.length;
    final variance = points.map((p) => math.pow(p - mean, 2)).reduce((a, b) => a + b) / points.length;
    final standardDeviation = math.sqrt(variance);
    
    // Convert to consistency score (inverse of standard deviation, normalized)
    return 1.0 / (1.0 + standardDeviation);
  }
  
  /// Calculate form trend (linear regression of points over time)
  FormTrend _calculateFormTrend(int teamId, List<FixtureData> fixtures) {
    if (fixtures.length < 3) {
      return FormTrend(
        direction: TrendDirection.stable,
        strength: 0.0,
        slope: 0.0,
        description: 'Insufficient data',
      );
    }
    
    // Convert fixtures to points (in chronological order)
    final points = <double>[];
    final chronologicalFixtures = fixtures.reversed.toList();
    
    for (final fixture in chronologicalFixtures) {
      if (fixture.isTeamWinner(teamId)) {
        points.add(3.0);
      } else if (fixture.isDraw) {
        points.add(1.0);
      } else {
        points.add(0.0);
      }
    }
    
    // Calculate linear regression
    final n = points.length;
    final xValues = List.generate(n, (i) => i.toDouble());
    
    final xMean = xValues.reduce((a, b) => a + b) / n;
    final yMean = points.reduce((a, b) => a + b) / n;
    
    double numerator = 0.0;
    double denominator = 0.0;
    
    for (int i = 0; i < n; i++) {
      final xDiff = xValues[i] - xMean;
      final yDiff = points[i] - yMean;
      numerator += xDiff * yDiff;
      denominator += xDiff * xDiff;
    }
    
    final slope = denominator != 0 ? numerator / denominator : 0.0;
    
    // Determine trend direction and strength
    TrendDirection direction;
    if (slope > 0.1) {
      direction = TrendDirection.improving;
    } else if (slope < -0.1) {
      direction = TrendDirection.declining;
    } else {
      direction = TrendDirection.stable;
    }
    
    return FormTrend(
      direction: direction,
      strength: slope.abs(),
      slope: slope,
      description: _getTrendDescription(direction, slope.abs()),
    );
  }
  
  String _getTrendDescription(TrendDirection direction, double strength) {
    String intensity;
    if (strength < 0.05) {
      intensity = 'stable';
    } else if (strength < 0.15) {
      intensity = 'slight';
    } else if (strength < 0.25) {
      intensity = 'moderate';
    } else {
      intensity = 'strong';
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
  
  /// Calculate opponent difficulty adjustment (requires additional API calls)
  Future<double> _calculateOpponentDifficulty(int teamId, List<FixtureData> fixtures) async {
    // This would require getting league standings or team ratings
    // For now, return neutral difficulty
    // TODO: Implement opponent strength calculation
    return 0.0;
  }
  
  /// Calculate expected goals difference (basic xG model)
  double _calculateExpectedGoalsDifference(GoalStatistics goalStats) {
    // Simple xG model based on average goals
    // More sophisticated xG would require shot data
    return goalStats.averageFor - goalStats.averageAgainst;
  }
  
  /// Calculate overall performance rating
  double _calculatePerformanceRating(
    double formPercentage,
    double momentum,
    double consistency,
    double difficultyAdjustment,
  ) {
    // Weighted combination of factors
    final baseRating = formPercentage / 100.0; // 0-1 scale
    final momentumFactor = math.log(momentum + 1) / 10; // Logarithmic scaling
    final consistencyFactor = consistency;
    final difficultyFactor = difficultyAdjustment;
    
    final rating = (baseRating * 0.4) + 
                   (momentumFactor * 0.3) + 
                   (consistencyFactor * 0.2) + 
                   (difficultyFactor * 0.1);
    
    return rating.clamp(0.0, 1.0);
  }
  
  /// Compare two teams' form (for predictions)
  FormComparison compareForms(TeamFormAnalysis homeForm, TeamFormAnalysis awayForm) {
    final homeStrength = _calculateTeamStrength(homeForm, true);
    final awayStrength = _calculateTeamStrength(awayForm, false);
    
    return FormComparison(
      homeStrength: homeStrength,
      awayStrength: awayStrength,
      strengthDifference: homeStrength - awayStrength,
      homeAdvantageAdjusted: homeStrength * (1 + homeAdvantage),
      recommendation: _getRecommendation(homeStrength, awayStrength),
    );
  }
  
  double _calculateTeamStrength(TeamFormAnalysis form, bool isHome) {
    double strength = form.performanceRating;
    
    // Adjust for home/away performance
    if (isHome && form.homeForm != null) {
      strength = (strength + (form.homeForm!.formPercentage / 100)) / 2;
    } else if (!isHome && form.awayForm != null) {
      strength = (strength + (form.awayForm!.formPercentage / 100)) / 2;
    }
    
    // Apply momentum and consistency adjustments
    strength += (form.momentum / 100) * 0.1;
    strength += form.consistency * 0.05;
    
    return strength.clamp(0.0, 1.0);
  }
  
  String _getRecommendation(double homeStrength, double awayStrength) {
    final diff = homeStrength - awayStrength;
    
    if (diff > 0.2) {
      return 'Strong Home Advantage';
    } else if (diff > 0.1) {
      return 'Home Advantage';
    } else if (diff < -0.2) {
      return 'Strong Away Advantage';
    } else if (diff < -0.1) {
      return 'Away Advantage';
    } else {
      return 'Evenly Matched';
    }
  }
}

// Data classes for form analysis
class TeamFormAnalysis {
  final int teamId;
  final DateTime analysisDate;
  final int formLength;
  
  // Basic form
  final String form;
  final double formPercentage;
  final int wins;
  final int draws;
  final int losses;
  
  // Goals
  final int goalsFor;
  final int goalsAgainst;
  final int goalDifference;
  final double averageGoalsFor;
  final double averageGoalsAgainst;
  
  // Streaks
  final String currentStreak;
  final int currentStreakLength;
  final int longestWinStreak;
  final int longestUnbeatenStreak;
  final int longestLoseStreak;
  
  // Home/Away
  final FormSummary? homeForm;
  final FormSummary? awayForm;
  
  // Advanced metrics
  final double momentum;
  final double consistency;
  final FormTrend formTrend;
  final double opponentDifficulty;
  final double performanceRating;
  final double expectedGoalsDifference;
  
  // Raw data
  final List<FixtureData> recentFixtures;
  final DateTime lastUpdated;
  
  TeamFormAnalysis({
    required this.teamId,
    required this.analysisDate,
    required this.formLength,
    required this.form,
    required this.formPercentage,
    required this.wins,
    required this.draws,
    required this.losses,
    required this.goalsFor,
    required this.goalsAgainst,
    required this.goalDifference,
    required this.averageGoalsFor,
    required this.averageGoalsAgainst,
    required this.currentStreak,
    required this.currentStreakLength,
    required this.longestWinStreak,
    required this.longestUnbeatenStreak,
    required this.longestLoseStreak,
    this.homeForm,
    this.awayForm,
    required this.momentum,
    required this.consistency,
    required this.formTrend,
    required this.opponentDifficulty,
    required this.performanceRating,
    required this.expectedGoalsDifference,
    required this.recentFixtures,
    required this.lastUpdated,
  });
  
  static TeamFormAnalysis empty(int teamId) {
    return TeamFormAnalysis(
      teamId: teamId,
      analysisDate: DateTime.now(),
      formLength: 0,
      form: '',
      formPercentage: 0.0,
      wins: 0,
      draws: 0,
      losses: 0,
      goalsFor: 0,
      goalsAgainst: 0,
      goalDifference: 0,
      averageGoalsFor: 0.0,
      averageGoalsAgainst: 0.0,
      currentStreak: '',
      currentStreakLength: 0,
      longestWinStreak: 0,
      longestUnbeatenStreak: 0,
      longestLoseStreak: 0,
      momentum: 0.0,
      consistency: 0.0,
      formTrend: FormTrend(
        direction: TrendDirection.stable,
        strength: 0.0,
        slope: 0.0,
        description: 'No data',
      ),
      opponentDifficulty: 0.0,
      performanceRating: 0.0,
      expectedGoalsDifference: 0.0,
      recentFixtures: [],
      lastUpdated: DateTime.now(),
    );
  }
}

class BasicFormData {
  final int wins;
  final int draws;
  final int losses;
  final String formString;
  
  BasicFormData({
    required this.wins,
    required this.draws,
    required this.losses,
    required this.formString,
  });
}

class StreakData {
  final String currentStreak;
  final int currentStreakLength;
  final int longestWinStreak;
  final int longestUnbeatenStreak;
  final int longestLoseStreak;
  
  StreakData({
    required this.currentStreak,
    required this.currentStreakLength,
    required this.longestWinStreak,
    required this.longestUnbeatenStreak,
    required this.longestLoseStreak,
  });
  
  static StreakData empty() {
    return StreakData(
      currentStreak: '',
      currentStreakLength: 0,
      longestWinStreak: 0,
      longestUnbeatenStreak: 0,
      longestLoseStreak: 0,
    );
  }
}

class CurrentStreak {
  final String type;
  final int length;
  
  CurrentStreak(this.type, this.length);
}

class GoalStatistics {
  final int totalFor;
  final int totalAgainst;
  final double averageFor;
  final double averageAgainst;
  final List<int> goalsForList;
  final List<int> goalsAgainstList;
  
  GoalStatistics({
    required this.totalFor,
    required this.totalAgainst,
    required this.averageFor,
    required this.averageAgainst,
    required this.goalsForList,
    required this.goalsAgainstList,
  });
}

class HomeAwayFormSplit {
  final FormSummary? homeForm;
  final FormSummary? awayForm;
  
  HomeAwayFormSplit({
    this.homeForm,
    this.awayForm,
  });
}

class FormSummary {
  final int matches;
  final int wins;
  final int draws;
  final int losses;
  final String form;
  final double formPercentage;
  final int goalsFor;
  final int goalsAgainst;
  final double averageGoalsFor;
  final double averageGoalsAgainst;
  final bool isHome;
  
  FormSummary({
    required this.matches,
    required this.wins,
    required this.draws,
    required this.losses,
    required this.form,
    required this.formPercentage,
    required this.goalsFor,
    required this.goalsAgainst,
    required this.averageGoalsFor,
    required this.averageGoalsAgainst,
    required this.isHome,
  });
}

class FormTrend {
  final TrendDirection direction;
  final double strength;
  final double slope;
  final String description;
  
  FormTrend({
    required this.direction,
    required this.strength,
    required this.slope,
    required this.description,
  });
}

enum TrendDirection {
  improving,
  declining,
  stable,
}

class FormComparison {
  final double homeStrength;
  final double awayStrength;
  final double strengthDifference;
  final double homeAdvantageAdjusted;
  final String recommendation;
  
  FormComparison({
    required this.homeStrength,
    required this.awayStrength,
    required this.strengthDifference,
    required this.homeAdvantageAdjusted,
    required this.recommendation,
  });
}

// Provider for the form analyzer
final productionFormAnalyzerProvider = Provider<ProductionFormAnalyzer>((ref) {
  final api = ref.watch(productionFootballApiProvider);
  return ProductionFormAnalyzer(api);
});