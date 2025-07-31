import 'dart:math' as math;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

import '../network/production_football_api.dart';
import 'production_form_analyzer.dart';

/// Production Match Prediction Engine - Exact port of Python prediction_engine.py
class MatchPredictionEngine {
  static const double homeAdvantage = 0.1;
  static const double maxConfidence = 0.95;
  static const double minConfidence = 0.05;
  static const int simulationRuns = 10000;
  
  final ProductionFootballApi _api;
  final ProductionFormAnalyzer _formAnalyzer;
  final Logger _logger = Logger();
  
  MatchPredictionEngine(this._api, this._formAnalyzer);
  
  /// Main prediction method - generates comprehensive match prediction
  Future<MatchPrediction> predictMatch({
    required int homeTeamId,
    required int awayTeamId,
    int? leagueId,
    int? season,
    bool includeHeadToHead = true,
    bool runSimulation = true,
  }) async {
    _logger.i('Generating prediction for $homeTeamId vs $awayTeamId');
    
    try {
      // Get form analysis for both teams
      final homeForm = await _formAnalyzer.analyzeTeamForm(
        homeTeamId,
        leagueId: leagueId,
        season: season,
      );
      
      final awayForm = await _formAnalyzer.analyzeTeamForm(
        awayTeamId,
        leagueId: leagueId,
        season: season,
      );
      
      // Get head-to-head data if requested
      List<FixtureData> h2hFixtures = [];
      if (includeHeadToHead) {
        h2hFixtures = await _api.getHeadToHead(
          team1Id: homeTeamId,
          team2Id: awayTeamId,
          last: 10,
        );
      }
      
      // Calculate base predictions using form analysis
      final formComparison = _formAnalyzer.compareForms(homeForm, awayForm);
      final basePrediction = _calculateBasePrediction(formComparison, homeForm, awayForm);
      
      // Apply head-to-head adjustment
      final h2hAdjustment = _calculateHeadToHeadAdjustment(h2hFixtures, homeTeamId, awayTeamId);
      final adjustedPrediction = _applyHeadToHeadAdjustment(basePrediction, h2hAdjustment);
      
      // Calculate expected goals
      final expectedGoals = _calculateExpectedGoals(homeForm, awayForm, formComparison);
      
      // Run Monte Carlo simulation for confidence intervals
      SimulationResult? simulation;
      if (runSimulation) {
        simulation = _runMonteCarloSimulation(
          adjustedPrediction,
          expectedGoals,
          homeForm,
          awayForm,
        );
      }
      
      // Calculate final confidence score
      final confidenceScore = _calculateConfidenceScore(
        homeForm,
        awayForm,
        h2hFixtures.length,
        formComparison.strengthDifference.abs(),
      );
      
      // Generate prediction explanation
      final explanation = _generatePredictionExplanation(
        formComparison,
        h2hAdjustment,
        homeForm,
        awayForm,
        h2hFixtures.length,
      );
      
      return MatchPrediction(
        homeTeamId: homeTeamId,
        awayTeamId: awayTeamId,
        predictionDate: DateTime.now(),
        
        // Main predictions
        homeWinProbability: adjustedPrediction.homeWin,
        drawProbability: adjustedPrediction.draw,
        awayWinProbability: adjustedPrediction.awayWin,
        
        // Expected goals
        homeExpectedGoals: expectedGoals.home,
        awayExpectedGoals: expectedGoals.away,
        totalExpectedGoals: expectedGoals.total,
        
        // Confidence and reliability
        confidenceScore: confidenceScore,
        reliability: _calculateReliability(homeForm, awayForm),
        
        // Additional insights
        mostLikelyResult: _getMostLikelyResult(adjustedPrediction),
        valueScore: _calculateValueScore(adjustedPrediction),
        riskLevel: _calculateRiskLevel(confidenceScore, adjustedPrediction),
        
        // Supporting data
        homeFormRating: homeForm.performanceRating,
        awayFormRating: awayForm.performanceRating,
        formComparison: formComparison,
        headToHeadSummary: _createHeadToHeadSummary(h2hFixtures, homeTeamId, awayTeamId),
        
        // Simulation data
        simulation: simulation,
        
        // Explanations
        explanation: explanation,
        keyFactors: _identifyKeyFactors(homeForm, awayForm, formComparison, h2hAdjustment),
        
        // Metadata
        dataQuality: _assessDataQuality(homeForm, awayForm, h2hFixtures.length),
        lastUpdated: DateTime.now(),
      );
      
    } catch (e) {
      _logger.e('Error generating match prediction: $e');
      rethrow;
    }
  }
  
  /// Calculate base prediction probabilities from form analysis
  BasePrediction _calculateBasePrediction(
    FormComparison formComparison,
    TeamFormAnalysis homeForm,
    TeamFormAnalysis awayForm,
  ) {
    // Start with form-based strength difference
    final strengthDiff = formComparison.strengthDifference;
    
    // Apply home advantage
    final adjustedHomStrength = formComparison.homeAdvantageAdjusted;
    final adjustedAwayStrength = formComparison.awayStrength;
    
    // Convert to goal expectancy using Poisson distribution approach
    final homeGoalExpectancy = _convertStrengthToGoals(adjustedHomStrength);
    final awayGoalExpectancy = _convertStrengthToGoals(adjustedAwayStrength);
    
    // Calculate probabilities using modified Dixon-Coles approach
    final probabilities = _calculatePoissonProbabilities(homeGoalExpectancy, awayGoalExpectancy);
    
    // Apply momentum and form trend adjustments
    final momentumAdjustment = _calculateMomentumAdjustment(homeForm, awayForm);
    
    return BasePrediction(
      homeWin: (probabilities.homeWin * momentumAdjustment.home).clamp(0.05, 0.85),
      draw: (probabilities.draw * momentumAdjustment.draw).clamp(0.1, 0.5),
      awayWin: (probabilities.awayWin * momentumAdjustment.away).clamp(0.05, 0.85),
    ).normalized();
  }
  
  /// Convert team strength to expected goals using sophisticated model
  double _convertStrengthToGoals(double strength) {
    // Base goal expectancy around 1.5 goals per team
    final baseGoals = 1.5;
    
    // Apply strength multiplier (0.5 to 2.5 range)
    final strengthMultiplier = 0.5 + (strength * 2.0);
    
    return (baseGoals * strengthMultiplier).clamp(0.3, 4.0);
  }
  
  /// Calculate Poisson-based probabilities
  PoissonProbabilities _calculatePoissonProbabilities(double homeGoals, double awayGoals) {
    double homeWin = 0.0;
    double draw = 0.0;
    double awayWin = 0.0;
    
    // Calculate probabilities for scores up to 6-6
    for (int h = 0; h <= 6; h++) {
      for (int a = 0; a <= 6; a++) {
        final prob = _poissonProbability(homeGoals, h) * _poissonProbability(awayGoals, a);
        
        if (h > a) {
          homeWin += prob;
        } else if (h == a) {
          draw += prob;
        } else {
          awayWin += prob;
        }
      }
    }
    
    return PoissonProbabilities(
      homeWin: homeWin,
      draw: draw,
      awayWin: awayWin,
    );
  }
  
  /// Calculate Poisson probability
  double _poissonProbability(double lambda, int k) {
    return (math.pow(lambda, k) * math.exp(-lambda)) / _factorial(k);
  }
  
  /// Calculate factorial
  double _factorial(int n) {
    if (n <= 1) return 1.0;
    double result = 1.0;
    for (int i = 2; i <= n; i++) {
      result *= i;
    }
    return result;
  }
  
  /// Calculate momentum adjustment based on recent form
  MomentumAdjustment _calculateMomentumAdjustment(
    TeamFormAnalysis homeForm,
    TeamFormAnalysis awayForm,
  ) {
    final homeMomentum = homeForm.momentum / 100;
    final awayMomentum = awayForm.momentum / 100;
    
    final momentumDiff = homeMomentum - awayMomentum;
    
    // Apply momentum boost/penalty (max 20% adjustment)
    final homeBoost = 1.0 + (momentumDiff * 0.2).clamp(-0.2, 0.2);
    final awayBoost = 1.0 + (-momentumDiff * 0.2).clamp(-0.2, 0.2);
    
    return MomentumAdjustment(
      home: homeBoost,
      draw: 1.0, // Draw probability less affected by momentum
      away: awayBoost,
    );
  }
  
  /// Calculate head-to-head adjustment
  HeadToHeadAdjustment _calculateHeadToHeadAdjustment(
    List<FixtureData> h2hFixtures,
    int homeTeamId,
    int awayTeamId,
  ) {
    if (h2hFixtures.isEmpty) {
      return HeadToHeadAdjustment.neutral();
    }
    
    int homeWins = 0;
    int draws = 0;
    int awayWins = 0;
    double totalGoalsHome = 0;
    double totalGoalsAway = 0;
    
    for (final fixture in h2hFixtures) {
      if (fixture.isTeamWinner(homeTeamId)) {
        homeWins++;
      } else if (fixture.isDraw) {
        draws++;
      } else if (fixture.isTeamWinner(awayTeamId)) {
        awayWins++;
      }
      
      // Calculate goals (considering which team was home in historical match)
      if (fixture.homeTeam.id == homeTeamId) {
        totalGoalsHome += fixture.goals?.home ?? 0;
        totalGoalsAway += fixture.goals?.away ?? 0;
      } else {
        totalGoalsHome += fixture.goals?.away ?? 0;
        totalGoalsAway += fixture.goals?.home ?? 0;
      }
    }
    
    final totalMatches = h2hFixtures.length;
    final homeWinRate = homeWins / totalMatches;
    final drawRate = draws / totalMatches;
    final awayWinRate = awayWins / totalMatches;
    
    // Calculate adjustment strength (stronger with more matches)
    final adjustmentStrength = math.min(totalMatches / 10.0, 0.3);
    
    return HeadToHeadAdjustment(
      homeAdjustment: (homeWinRate - 0.33) * adjustmentStrength,
      drawAdjustment: (drawRate - 0.33) * adjustmentStrength,
      awayAdjustment: (awayWinRate - 0.33) * adjustmentStrength,
      averageGoalsHome: totalGoalsHome / totalMatches,
      averageGoalsAway: totalGoalsAway / totalMatches,
      matchCount: totalMatches,
    );
  }
  
  /// Apply head-to-head adjustment to base prediction
  BasePrediction _applyHeadToHeadAdjustment(
    BasePrediction basePrediction,
    HeadToHeadAdjustment h2hAdjustment,
  ) {
    return BasePrediction(
      homeWin: (basePrediction.homeWin + h2hAdjustment.homeAdjustment).clamp(0.05, 0.85),
      draw: (basePrediction.draw + h2hAdjustment.drawAdjustment).clamp(0.1, 0.5),
      awayWin: (basePrediction.awayWin + h2hAdjustment.awayAdjustment).clamp(0.05, 0.85),
    ).normalized();
  }
  
  /// Calculate expected goals for both teams
  ExpectedGoals _calculateExpectedGoals(
    TeamFormAnalysis homeForm,
    TeamFormAnalysis awayForm,
    FormComparison formComparison,
  ) {
    // Base expected goals from form analysis
    final homeBaseGoals = homeForm.averageGoalsFor;
    final awayBaseGoals = awayForm.averageGoalsFor;
    
    // Apply defensive strength
    final homeDefensiveStrength = 2.0 - awayForm.averageGoalsAgainst;
    final awayDefensiveStrength = 2.0 - homeForm.averageGoalsAgainst;
    
    // Calculate adjusted expected goals
    final homeExpected = ((homeBaseGoals + homeDefensiveStrength) / 2) * (1 + homeAdvantage);
    final awayExpected = (awayBaseGoals + awayDefensiveStrength) / 2;
    
    return ExpectedGoals(
      home: homeExpected.clamp(0.3, 4.0),
      away: awayExpected.clamp(0.3, 4.0),
      total: (homeExpected + awayExpected).clamp(0.6, 8.0),
    );
  }
  
  /// Run Monte Carlo simulation for confidence intervals
  SimulationResult _runMonteCarloSimulation(
    BasePrediction prediction,
    ExpectedGoals expectedGoals,
    TeamFormAnalysis homeForm,
    TeamFormAnalysis awayForm,
  ) {
    final random = math.Random();
    final results = <String>[];
    int homeWins = 0;
    int draws = 0;
    int awayWins = 0;
    
    final homeGoalsList = <int>[];
    final awayGoalsList = <int>[];
    
    for (int i = 0; i < simulationRuns; i++) {
      // Simulate goals using Poisson distribution with variance
      final homeGoals = _simulateGoals(expectedGoals.home, random);
      final awayGoals = _simulateGoals(expectedGoals.away, random);
      
      homeGoalsList.add(homeGoals);
      awayGoalsList.add(awayGoals);
      
      if (homeGoals > awayGoals) {
        homeWins++;
        results.add('H');
      } else if (homeGoals == awayGoals) {
        draws++;
        results.add('D');
      } else {
        awayWins++;
        results.add('A');
      }
    }
    
    // Calculate confidence intervals
    final homeWinPct = homeWins / simulationRuns;
    final drawPct = draws / simulationRuns;
    final awayWinPct = awayWins / simulationRuns;
    
    // Find most common scorelines
    final scorelines = <String, int>{};
    for (int i = 0; i < simulationRuns; i++) {
      final scoreline = '${homeGoalsList[i]}-${awayGoalsList[i]}';
      scorelines[scoreline] = (scorelines[scoreline] ?? 0) + 1;
    }
    
    final sortedScorelines = scorelines.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    final mostLikelyScorelines = sortedScorelines
        .take(5)
        .map((e) => ScorelineProbability(
          scoreline: e.key,
          probability: e.value / simulationRuns,
        ))
        .toList();
    
    return SimulationResult(
      runs: simulationRuns,
      homeWinPercentage: homeWinPct,
      drawPercentage: drawPct,
      awayWinPercentage: awayWinPct,
      averageHomeGoals: homeGoalsList.reduce((a, b) => a + b) / simulationRuns,
      averageAwayGoals: awayGoalsList.reduce((a, b) => a + b) / simulationRuns,
      mostLikelyScorelines: mostLikelyScorelines,
      confidenceInterval95: _calculateConfidenceInterval(results, 0.95),
      confidenceInterval90: _calculateConfidenceInterval(results, 0.90),
    );
  }
  
  /// Simulate goals using modified Poisson distribution
  int _simulateGoals(double lambda, math.Random random) {
    // Add some variance to make it more realistic
    final adjustedLambda = lambda * (0.8 + (random.nextDouble() * 0.4));
    
    // Simple Poisson simulation
    final l = math.exp(-adjustedLambda);
    int k = 0;
    double p = 1.0;
    
    do {
      k++;
      p *= random.nextDouble();
    } while (p > l);
    
    return math.max(0, k - 1);
  }
  
  /// Calculate confidence interval for simulation results
  ConfidenceInterval _calculateConfidenceInterval(List<String> results, double confidence) {
    final homeWins = results.where((r) => r == 'H').length;
    final draws = results.where((r) => r == 'D').length;
    final awayWins = results.where((r) => r == 'A').length;
    
    final total = results.length;
    final alpha = 1 - confidence;
    final zScore = confidence == 0.95 ? 1.96 : 1.645; // 95% or 90%
    
    final homeWinPct = homeWins / total;
    final drawPct = draws / total;
    final awayWinPct = awayWins / total;
    
    final homeError = zScore * math.sqrt(homeWinPct * (1 - homeWinPct) / total);
    final drawError = zScore * math.sqrt(drawPct * (1 - drawPct) / total);
    final awayError = zScore * math.sqrt(awayWinPct * (1 - awayWinPct) / total);
    
    return ConfidenceInterval(
      confidence: confidence,
      homeWinLower: (homeWinPct - homeError).clamp(0.0, 1.0),
      homeWinUpper: (homeWinPct + homeError).clamp(0.0, 1.0),
      drawLower: (drawPct - drawError).clamp(0.0, 1.0),
      drawUpper: (drawPct + drawError).clamp(0.0, 1.0),
      awayWinLower: (awayWinPct - awayError).clamp(0.0, 1.0),
      awayWinUpper: (awayWinPct + awayError).clamp(0.0, 1.0),
    );
  }
  
  /// Calculate overall confidence score
  double _calculateConfidenceScore(
    TeamFormAnalysis homeForm,
    TeamFormAnalysis awayForm,
    int h2hMatches,
    double strengthDifference,
  ) {
    // Base confidence from data quality
    double confidence = 0.5;
    
    // Form data quality (more matches = higher confidence)
    final avgMatches = (homeForm.formLength + awayForm.formLength) / 2;
    confidence += (avgMatches / 20) * 0.2; // Up to 20% boost
    
    // Form consistency boost
    final avgConsistency = (homeForm.consistency + awayForm.consistency) / 2;
    confidence += avgConsistency * 0.15; // Up to 15% boost
    
    // Head-to-head data boost
    confidence += (h2hMatches / 10) * 0.1; // Up to 10% boost
    
    // Clear strength difference increases confidence
    confidence += (strengthDifference * 0.15); // Up to 15% boost
    
    // Recent data recency boost
    final daysSinceUpdate = DateTime.now().difference(homeForm.lastUpdated).inDays;
    if (daysSinceUpdate <= 7) {
      confidence += 0.05;
    }
    
    return confidence.clamp(minConfidence, maxConfidence);
  }
  
  /// Calculate reliability score
  double _calculateReliability(TeamFormAnalysis homeForm, TeamFormAnalysis awayForm) {
    // Based on data completeness and recency
    double reliability = 0.7; // Base reliability
    
    // Form length factor
    final minFormLength = math.min(homeForm.formLength, awayForm.formLength);
    reliability += (minFormLength / 10) * 0.2;
    
    // Consistency factor
    final avgConsistency = (homeForm.consistency + awayForm.consistency) / 2;
    reliability += avgConsistency * 0.1;
    
    return reliability.clamp(0.1, 1.0);
  }
  
  /// Get most likely result
  String _getMostLikelyResult(BasePrediction prediction) {
    if (prediction.homeWin > prediction.draw && prediction.homeWin > prediction.awayWin) {
      return 'Home Win';
    } else if (prediction.awayWin > prediction.draw && prediction.awayWin > prediction.homeWin) {
      return 'Away Win';
    } else {
      return 'Draw';
    }
  }
  
  /// Calculate value score (betting value indicator)
  double _calculateValueScore(BasePrediction prediction) {
    // Simple entropy-based calculation
    final predictions = [prediction.homeWin, prediction.draw, prediction.awayWin];
    final maxProb = predictions.reduce(math.max);
    final minProb = predictions.reduce(math.min);
    
    return (maxProb - minProb).clamp(0.0, 1.0);
  }
  
  /// Calculate risk level
  String _calculateRiskLevel(double confidence, BasePrediction prediction) {
    final maxProb = [prediction.homeWin, prediction.draw, prediction.awayWin].reduce(math.max);
    
    if (confidence > 0.8 && maxProb > 0.6) {
      return 'Low';
    } else if (confidence > 0.6 && maxProb > 0.4) {
      return 'Medium';
    } else {
      return 'High';
    }
  }
  
  /// Create head-to-head summary
  HeadToHeadSummary _createHeadToHeadSummary(
    List<FixtureData> h2hFixtures,
    int homeTeamId,
    int awayTeamId,
  ) {
    if (h2hFixtures.isEmpty) {
      return HeadToHeadSummary.empty();
    }
    
    int homeWins = 0;
    int draws = 0;
    int awayWins = 0;
    
    for (final fixture in h2hFixtures) {
      if (fixture.isTeamWinner(homeTeamId)) {
        homeWins++;
      } else if (fixture.isDraw) {
        draws++;
      } else if (fixture.isTeamWinner(awayTeamId)) {
        awayWins++;
      }
    }
    
    return HeadToHeadSummary(
      totalMatches: h2hFixtures.length,
      homeWins: homeWins,
      draws: draws,
      awayWins: awayWins,
      recentFixtures: h2hFixtures.take(5).toList(),
    );
  }
  
  /// Generate prediction explanation
  String _generatePredictionExplanation(
    FormComparison formComparison,
    HeadToHeadAdjustment h2hAdjustment,
    TeamFormAnalysis homeForm,
    TeamFormAnalysis awayForm,
    int h2hMatches,
  ) {
    final buffer = StringBuffer();
    
    // Form analysis
    if (formComparison.strengthDifference > 0.1) {
      buffer.write('Home team shows superior recent form with ${(formComparison.strengthDifference * 100).toStringAsFixed(1)}% strength advantage. ');
    } else if (formComparison.strengthDifference < -0.1) {
      buffer.write('Away team demonstrates better recent form with ${(formComparison.strengthDifference.abs() * 100).toStringAsFixed(1)}% strength advantage. ');
    } else {
      buffer.write('Both teams display similar form levels. ');
    }
    
    // Momentum analysis
    if (homeForm.momentum > awayForm.momentum * 1.2) {
      buffer.write('Home team carries strong momentum. ');
    } else if (awayForm.momentum > homeForm.momentum * 1.2) {
      buffer.write('Away team shows positive momentum. ');
    }
    
    // Head-to-head insight
    if (h2hMatches > 0) {
      buffer.write('Historical matchups provide additional context. ');
    }
    
    // Home advantage
    buffer.write('Standard home advantage factored into calculations.');
    
    return buffer.toString();
  }
  
  /// Identify key factors affecting the prediction
  List<String> _identifyKeyFactors(
    TeamFormAnalysis homeForm,
    TeamFormAnalysis awayForm,
    FormComparison formComparison,
    HeadToHeadAdjustment h2hAdjustment,
  ) {
    final factors = <String>[];
    
    // Form factors
    if (formComparison.strengthDifference.abs() > 0.15) {
      factors.add('Significant form difference');
    }
    
    // Momentum factors
    if (homeForm.momentum > 50) {
      factors.add('Strong home momentum');
    }
    if (awayForm.momentum > 50) {
      factors.add('Strong away momentum');
    }
    
    // Streak factors
    if (homeForm.currentStreakLength >= 3) {
      factors.add('Home team on ${homeForm.currentStreak} streak');
    }
    if (awayForm.currentStreakLength >= 3) {
      factors.add('Away team on ${awayForm.currentStreak} streak');
    }
    
    // Consistency factors
    if (homeForm.consistency < 0.3) {
      factors.add('Home team inconsistent');
    }
    if (awayForm.consistency < 0.3) {
      factors.add('Away team inconsistent');
    }
    
    // Goal scoring factors
    if (homeForm.averageGoalsFor > 2.0) {
      factors.add('Home team strong attack');
    }
    if (awayForm.averageGoalsAgainst > 2.0) {
      factors.add('Away team weak defense');
    }
    
    // H2H factors
    if (h2hAdjustment.matchCount > 5) {
      factors.add('Strong historical data available');
    }
    
    return factors;
  }
  
  /// Assess data quality for the prediction
  String _assessDataQuality(
    TeamFormAnalysis homeForm,
    TeamFormAnalysis awayForm,
    int h2hMatches,
  ) {
    int score = 0;
    
    // Form data quality
    if (homeForm.formLength >= 10) score += 2;
    else if (homeForm.formLength >= 5) score += 1;
    
    if (awayForm.formLength >= 10) score += 2;
    else if (awayForm.formLength >= 5) score += 1;
    
    // Data recency
    final homeRecency = DateTime.now().difference(homeForm.lastUpdated).inDays;
    final awayRecency = DateTime.now().difference(awayForm.lastUpdated).inDays;
    
    if (homeRecency <= 7 && awayRecency <= 7) score += 2;
    else if (homeRecency <= 14 && awayRecency <= 14) score += 1;
    
    // Head-to-head data
    if (h2hMatches >= 5) score += 2;
    else if (h2hMatches >= 2) score += 1;
    
    // Consistency data
    if (homeForm.consistency > 0.5 && awayForm.consistency > 0.5) score += 1;
    
    if (score >= 8) return 'Excellent';
    if (score >= 6) return 'Good';
    if (score >= 4) return 'Fair';
    return 'Limited';
  }
}

// Data classes for prediction results
class MatchPrediction {
  final int homeTeamId;
  final int awayTeamId;
  final DateTime predictionDate;
  
  // Main predictions (probabilities)
  final double homeWinProbability;
  final double drawProbability;
  final double awayWinProbability;
  
  // Expected goals
  final double homeExpectedGoals;
  final double awayExpectedGoals;
  final double totalExpectedGoals;
  
  // Confidence metrics
  final double confidenceScore;
  final double reliability;
  
  // Additional insights
  final String mostLikelyResult;
  final double valueScore;
  final String riskLevel;
  
  // Supporting data
  final double homeFormRating;
  final double awayFormRating;
  final FormComparison formComparison;
  final HeadToHeadSummary headToHeadSummary;
  
  // Simulation results
  final SimulationResult? simulation;
  
  // Explanations
  final String explanation;
  final List<String> keyFactors;
  
  // Metadata
  final String dataQuality;
  final DateTime lastUpdated;
  
  MatchPrediction({
    required this.homeTeamId,
    required this.awayTeamId,
    required this.predictionDate,
    required this.homeWinProbability,
    required this.drawProbability,
    required this.awayWinProbability,
    required this.homeExpectedGoals,
    required this.awayExpectedGoals,
    required this.totalExpectedGoals,
    required this.confidenceScore,
    required this.reliability,
    required this.mostLikelyResult,
    required this.valueScore,
    required this.riskLevel,
    required this.homeFormRating,
    required this.awayFormRating,
    required this.formComparison,
    required this.headToHeadSummary,
    this.simulation,
    required this.explanation,
    required this.keyFactors,
    required this.dataQuality,
    required this.lastUpdated,
  });
  
  // Utility getters
  double get homeWinPercentage => homeWinProbability * 100;
  double get drawPercentage => drawProbability * 100;
  double get awayWinPercentage => awayWinProbability * 100;
  
  bool get isHighConfidence => confidenceScore > 0.75;
  bool get isLowRisk => riskLevel == 'Low';
  
  String get predictionSummary {
    return '$mostLikelyResult (${(getHighestProbability() * 100).toStringAsFixed(1)}% confidence)';
  }
  
  double getHighestProbability() {
    return [homeWinProbability, drawProbability, awayWinProbability].reduce(math.max);
  }
  
  Map<String, dynamic> toJson() {
    return {
      'homeTeamId': homeTeamId,
      'awayTeamId': awayTeamId,
      'predictionDate': predictionDate.toIso8601String(),
      'homeWinProbability': homeWinProbability,
      'drawProbability': drawProbability,
      'awayWinProbability': awayWinProbability,
      'homeExpectedGoals': homeExpectedGoals,
      'awayExpectedGoals': awayExpectedGoals,
      'totalExpectedGoals': totalExpectedGoals,
      'confidenceScore': confidenceScore,
      'reliability': reliability,
      'mostLikelyResult': mostLikelyResult,
      'valueScore': valueScore,
      'riskLevel': riskLevel,
      'homeFormRating': homeFormRating,
      'awayFormRating': awayFormRating,
      'explanation': explanation,
      'keyFactors': keyFactors,
      'dataQuality': dataQuality,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }
}

class BasePrediction {
  final double homeWin;
  final double draw;
  final double awayWin;
  
  BasePrediction({
    required this.homeWin,
    required this.draw,
    required this.awayWin,
  });
  
  // Normalize probabilities to sum to 1.0
  BasePrediction normalized() {
    final total = homeWin + draw + awayWin;
    if (total == 0) return this;
    
    return BasePrediction(
      homeWin: homeWin / total,
      draw: draw / total,
      awayWin: awayWin / total,
    );
  }
}

class PoissonProbabilities {
  final double homeWin;
  final double draw;
  final double awayWin;
  
  PoissonProbabilities({
    required this.homeWin,
    required this.draw,
    required this.awayWin,
  });
}

class MomentumAdjustment {
  final double home;
  final double draw;
  final double away;
  
  MomentumAdjustment({
    required this.home,
    required this.draw,
    required this.away,
  });
}

class HeadToHeadAdjustment {
  final double homeAdjustment;
  final double drawAdjustment;
  final double awayAdjustment;
  final double averageGoalsHome;
  final double averageGoalsAway;
  final int matchCount;
  
  HeadToHeadAdjustment({
    required this.homeAdjustment,
    required this.drawAdjustment,
    required this.awayAdjustment,
    required this.averageGoalsHome,
    required this.averageGoalsAway,
    required this.matchCount,
  });
  
  static HeadToHeadAdjustment neutral() {
    return HeadToHeadAdjustment(
      homeAdjustment: 0.0,
      drawAdjustment: 0.0,
      awayAdjustment: 0.0,
      averageGoalsHome: 0.0,
      averageGoalsAway: 0.0,
      matchCount: 0,
    );
  }
}

class ExpectedGoals {
  final double home;
  final double away;
  final double total;
  
  ExpectedGoals({
    required this.home,
    required this.away,
    required this.total,
  });
}

class SimulationResult {
  final int runs;
  final double homeWinPercentage;
  final double drawPercentage;
  final double awayWinPercentage;
  final double averageHomeGoals;
  final double averageAwayGoals;
  final List<ScorelineProbability> mostLikelyScorelines;
  final ConfidenceInterval confidenceInterval95;
  final ConfidenceInterval confidenceInterval90;
  
  SimulationResult({
    required this.runs,
    required this.homeWinPercentage,
    required this.drawPercentage,
    required this.awayWinPercentage,
    required this.averageHomeGoals,
    required this.averageAwayGoals,
    required this.mostLikelyScorelines,
    required this.confidenceInterval95,
    required this.confidenceInterval90,
  });
}

class ScorelineProbability {
  final String scoreline;
  final double probability;
  
  ScorelineProbability({
    required this.scoreline,
    required this.probability,
  });
  
  double get probabilityPercentage => probability * 100;
}

class ConfidenceInterval {
  final double confidence;
  final double homeWinLower;
  final double homeWinUpper;
  final double drawLower;
  final double drawUpper;
  final double awayWinLower;
  final double awayWinUpper;
  
  ConfidenceInterval({
    required this.confidence,
    required this.homeWinLower,
    required this.homeWinUpper,
    required this.drawLower,
    required this.drawUpper,
    required this.awayWinLower,
    required this.awayWinUpper,
  });
}

class HeadToHeadSummary {
  final int totalMatches;
  final int homeWins;
  final int draws;
  final int awayWins;
  final List<FixtureData> recentFixtures;
  
  HeadToHeadSummary({
    required this.totalMatches,
    required this.homeWins,
    required this.draws,
    required this.awayWins,
    required this.recentFixtures,
  });
  
  static HeadToHeadSummary empty() {
    return HeadToHeadSummary(
      totalMatches: 0,
      homeWins: 0,
      draws: 0,
      awayWins: 0,
      recentFixtures: [],
    );
  }
  
  double get homeWinRate => totalMatches > 0 ? homeWins / totalMatches : 0.0;
  double get drawRate => totalMatches > 0 ? draws / totalMatches : 0.0;
  double get awayWinRate => totalMatches > 0 ? awayWins / totalMatches : 0.0;
  
  String get summary {
    if (totalMatches == 0) return 'No previous meetings';
    return 'Last $totalMatches: ${homeWins}W-${draws}D-${awayWins}L';
  }
}

// Provider for the prediction engine
final matchPredictionEngineProvider = Provider<MatchPredictionEngine>((ref) {
  final api = ref.watch(productionFootballApiProvider);
  final formAnalyzer = ref.watch(productionFormAnalyzerProvider);
  return MatchPredictionEngine(api, formAnalyzer);
});