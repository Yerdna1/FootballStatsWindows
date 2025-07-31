import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Import core functionality
import '../lib/shared/data/models/team_form_model.dart';
import '../lib/shared/data/models/advanced_statistics_model.dart';
import '../lib/shared/data/models/prediction_model.dart';
import '../lib/shared/data/models/user_activity_model.dart';
import '../lib/core/network/football_api_client.dart';
import '../lib/core/services/form_analysis_service.dart';

void main() {
  group('Core Functionality Tests', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('TeamFormModel should be created correctly', () {
      final form = TeamFormModel(
        teamId: 1,
        recentMatches: 10,
        wins: 6,
        draws: 2,
        losses: 2,
        goalsFor: 18,
        goalsAgainst: 8,
        form: 'WWLDDWWLWW',
        formPercentage: 70.0,
        lastUpdated: DateTime.now(),
      );

      expect(form.teamId, 1);
      expect(form.wins, 6);
      expect(form.formPercentage, 70.0);
      expect(form.goalDifference, 10);
    });

    test('UserActivityLog should serialize correctly', () {
      final activity = UserActivityLog(
        id: 'test-id',
        userId: 'user-123',
        action: UserAction.viewFixtures,
        timestamp: DateTime.now(),
        context: 'Navigation test',
        metadata: {'test': 'data'},
      );

      final json = activity.toJson();
      final fromJson = UserActivityLog.fromJson(json);

      expect(fromJson.userId, activity.userId);
      expect(fromJson.action, activity.action);
      expect(fromJson.context, activity.context);
    });

    test('FormStreak should calculate correctly', () {
      final streak = FormStreak(
        type: StreakType.winning,
        length: 5,
        isActive: true,
      );

      expect(streak.type, StreakType.winning);
      expect(streak.length, 5);
      expect(streak.isActive, true);
    });

    test('UserRole enum should have correct display names', () {
      expect(UserRole.admin.displayName, 'Administrator');
      expect(UserRole.moderator.displayName, 'Moderator');
      expect(UserRole.user.displayName, 'User');
    });

    test('PredictionModel should validate probabilities', () {
      final prediction = PredictionModel(
        fixtureId: 123,
        homeTeamId: 1,
        awayTeamId: 2,
        homeWinProbability: 0.5,
        drawProbability: 0.3,
        awayWinProbability: 0.2,
        predictedHomeGoals: 2.1,
        predictedAwayGoals: 1.3,
        confidence: PredictionConfidence(
          overall: 0.8,
          dataQuality: 0.9,
          modelReliability: 0.7,
          factors: {'form': 0.8},
        ),
        predictionType: PredictionType.formBased,
        scenarios: [],
        createdAt: DateTime.now(),
        lastUpdated: DateTime.now(),
      );

      expect(prediction.totalProbability, closeTo(1.0, 0.01));
      expect(prediction.mostLikelyOutcome, 'Home Win');
    });

    test('AdvancedStatisticsModel should initialize with defaults', () {
      final stats = AdvancedStatisticsModel(
        entityId: 'team-1',
        entityType: StatisticsEntityType.team,
        matchStats: MatchStatistics(
          played: 10,
          wins: 6,
          draws: 2,
          losses: 2,
        ),
        goalStats: GoalStatistics(
          goalsFor: 18,
          goalsAgainst: 8,
          averageGoalsFor: 1.8,
          averageGoalsAgainst: 0.8,
        ),
        period: StatisticsPeriod.season,
        lastUpdated: DateTime.now(),
      );

      expect(stats.entityId, 'team-1');
      expect(stats.matchStats.winPercentage, closeTo(60.0, 0.1));
      expect(stats.goalStats.goalDifference, 10);
    });

    test('UserEngagementMetrics should calculate correctly', () {
      final metrics = UserEngagementMetrics(
        userId: 'user-123',
        activeDays: 15,
        totalSessions: 30,
        totalActions: 150,
        averageSessionsPerDay: 2.0,
        averageActionsPerSession: 5.0,
        engagementScore: 75.0,
        periodStart: DateTime.now().subtract(const Duration(days: 30)),
        periodEnd: DateTime.now(),
      );

      expect(metrics.activeDays, 15);
      expect(metrics.engagementLevel, EngagementLevel.high);
      expect(metrics.isHighlyEngaged, true);
    });

    test('StatisticsFilterModel should validate correctly', () {
      final filter = StatisticsFilterModel(
        leagues: [1, 2, 3],
        teams: [10, 20, 30],
        timePeriod: TimePeriod.lastMonth,
        viewType: ViewType.detailed,
        sortBy: SortBy.formPercentage,
        sortOrder: SortOrder.descending,
      );

      expect(filter.isValid, true);
      expect(filter.hasLeagueFilter, true);
      expect(filter.hasTeamFilter, true);
    });
  });

  group('Extension Tests', () {
    test('UserRole extensions should work correctly', () {
      expect(UserRole.admin.isAdmin, true);
      expect(UserRole.user.isAdmin, false);
      expect(UserRole.moderator.canModerate, true);
      expect(UserRole.user.canModerate, false);
    });

    test('UserAction extensions should work correctly', () {
      expect(UserAction.login.isAuthAction, true);
      expect(UserAction.viewFixtures.isAuthAction, false);
      expect(UserAction.exportData.isDataAction, true);
      expect(UserAction.login.isDataAction, false);
    });

    test('FormStreak extensions should work correctly', () {
      final winStreak = FormStreak(
        type: StreakType.winning,
        length: 5,
        isActive: true,
      );

      expect(winStreak.isPositive, true);
      expect(winStreak.isSignificant, true);
      expect(winStreak.description, contains('5-game winning'));
    });

    test('TeamFormModel extensions should work correctly', () {
      final form = TeamFormModel(
        teamId: 1,
        recentMatches: 10,
        wins: 7,
        draws: 2,
        losses: 1,
        goalsFor: 20,
        goalsAgainst: 5,
        form: 'WWWLDDWWWW',
        formPercentage: 80.0,
        lastUpdated: DateTime.now(),
      );

      expect(form.isExcellentForm, true);
      expect(form.isGoodForm, true);
      expect(form.isPoorForm, false);
      expect(form.goalDifference, 15);
      expect(form.pointsPerGame, closeTo(2.3, 0.1));
    });

    test('AdvancedStatisticsModel extensions should work correctly', () {
      final stats = AdvancedStatisticsModel(
        entityId: 'team-1',
        entityType: StatisticsEntityType.team,
        matchStats: MatchStatistics(
          played: 20,
          wins: 15,
          draws: 3,
          losses: 2,
        ),
        goalStats: GoalStatistics(
          goalsFor: 45,
          goalsAgainst: 15,
          averageGoalsFor: 2.25,
          averageGoalsAgainst: 0.75,
        ),
        period: StatisticsPeriod.season,
        lastUpdated: DateTime.now(),
      );

      expect(stats.isHighPerforming, true);
      expect(stats.overallRating, greaterThan(8.0));
    });
  });

  group('Validation Tests', () {
    test('StatisticsFilterModel validation should work', () {
      // Valid filter
      final validFilter = StatisticsFilterModel(
        leagues: [1, 2],
        teams: [10],
        timePeriod: TimePeriod.lastMonth,
        viewType: ViewType.overview,
        sortBy: SortBy.formPercentage,
        sortOrder: SortOrder.descending,
      );

      expect(validFilter.isValid, true);

      // Invalid filter (no data)
      final invalidFilter = StatisticsFilterModel(
        leagues: [],
        teams: [],
        timePeriod: TimePeriod.lastMonth,
        viewType: ViewType.overview,
        sortBy: SortBy.formPercentage,
        sortOrder: SortOrder.descending,
      );

      expect(invalidFilter.isValid, false);
    });

    test('PredictionModel validation should work', () {
      // Valid prediction
      final validPrediction = PredictionModel(
        fixtureId: 123,
        homeTeamId: 1,
        awayTeamId: 2,
        homeWinProbability: 0.4,
        drawProbability: 0.3,
        awayWinProbability: 0.3,
        predictedHomeGoals: 2.0,
        predictedAwayGoals: 1.5,
        confidence: PredictionConfidence(
          overall: 0.8,
          dataQuality: 0.9,
          modelReliability: 0.7,
          factors: {},
        ),
        predictionType: PredictionType.formBased,
        scenarios: [],
        createdAt: DateTime.now(),
        lastUpdated: DateTime.now(),
      );

      expect(validPrediction.totalProbability, closeTo(1.0, 0.01));
      expect(validPrediction.isValid, true);
    });
  });
}