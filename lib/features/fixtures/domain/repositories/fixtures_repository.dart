import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/fixture_entity.dart';

abstract class FixturesRepository {
  /// Get all fixtures with optional filters
  Future<Either<Failure, List<FixtureEntity>>> getFixtures({
    int? leagueId,
    int? teamId,
    DateTime? from,
    DateTime? to,
    String? status,
    int? matchday,
    String? venue,
    int? limit,
    int? offset,
  });

  /// Get a specific fixture by ID
  Future<Either<Failure, FixtureEntity>> getFixture(int fixtureId);

  /// Get fixture details with events, statistics, etc.
  Future<Either<Failure, FixtureEntity>> getFixtureDetails(int fixtureId);

  /// Get fixtures by league
  Future<Either<Failure, List<FixtureEntity>>> getFixturesByLeague(
    int leagueId, {
    DateTime? from,
    DateTime? to,
    String? status,
    int? matchday,
    int? limit,
    int? offset,
  });

  /// Get fixtures by team
  Future<Either<Failure, List<FixtureEntity>>> getFixturesByTeam(
    int teamId, {
    DateTime? from,
    DateTime? to,
    String? status,
    int? limit,
    int? offset,
  });

  /// Get live fixtures
  Future<Either<Failure, List<FixtureEntity>>> getLiveFixtures();

  /// Get upcoming fixtures
  Future<Either<Failure, List<FixtureEntity>>> getUpcomingFixtures({
    int? leagueId,
    int? teamId,
    int? limit,
  });

  /// Get recent fixtures (finished)
  Future<Either<Failure, List<FixtureEntity>>> getRecentFixtures({
    int? leagueId,
    int? teamId,
    int? limit,
  });

  /// Get fixtures by date range
  Future<Either<Failure, List<FixtureEntity>>> getFixturesByDateRange(
    DateTime from,
    DateTime to, {
    int? leagueId,
    int? teamId,
  });

  /// Get fixtures for a specific matchday
  Future<Either<Failure, List<FixtureEntity>>> getFixturesByMatchday(
    int leagueId,
    int matchday,
  );

  /// Search fixtures
  Future<Either<Failure, List<FixtureEntity>>> searchFixtures(String query);

  /// Get favorite fixtures for current user
  Future<Either<Failure, List<FixtureEntity>>> getFavoriteFixtures();

  /// Add fixture to favorites
  Future<Either<Failure, void>> addToFavorites(int fixtureId);

  /// Remove fixture from favorites
  Future<Either<Failure, void>> removeFromFavorites(int fixtureId);

  /// Check if fixture is in favorites
  Future<Either<Failure, bool>> isFixtureFavorite(int fixtureId);

  /// Get head-to-head statistics between two teams
  Future<Either<Failure, Map<String, dynamic>>> getHeadToHead(
    int team1Id,
    int team2Id, {
    int? limit,
  });

  /// Get match statistics
  Future<Either<Failure, Map<String, dynamic>>> getMatchStatistics(int fixtureId);

  /// Get match timeline/events
  Future<Either<Failure, List<Map<String, dynamic>>> getMatchEvents(int fixtureId);

  /// Get match lineups
  Future<Either<Failure, Map<String, dynamic>>> getMatchLineups(int fixtureId);

  /// Cache fixture data locally
  Future<Either<Failure, void>> cacheFixture(FixtureEntity fixture);

  /// Get cached fixtures
  Future<Either<Failure, List<FixtureEntity>>> getCachedFixtures();

  /// Clear fixture cache
  Future<Either<Failure, void>> clearCache();

  /// Subscribe to live fixture updates
  Stream<Either<Failure, FixtureEntity>> subscribeToFixtureUpdates(int fixtureId);
}