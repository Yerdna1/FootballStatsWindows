import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/team_entity.dart';

abstract class TeamsRepository {
  /// Get all teams with optional filters
  Future<Either<Failure, List<TeamEntity>>> getTeams({
    String? search,
    int? leagueId,
    String? country,
    int? limit,
    int? offset,
  });

  /// Get a specific team by ID
  Future<Either<Failure, TeamEntity>> getTeam(int teamId);

  /// Get team statistics and detailed information
  Future<Either<Failure, TeamEntity>> getTeamDetails(int teamId);

  /// Get teams squad/players
  Future<Either<Failure, List<PlayerEntity>>> getTeamSquad(int teamId);

  /// Get teams in a specific league
  Future<Either<Failure, List<TeamEntity>>> getTeamsByLeague(int leagueId);

  /// Search teams by name
  Future<Either<Failure, List<TeamEntity>>> searchTeams(String query);

  /// Get favorite teams for current user
  Future<Either<Failure, List<TeamEntity>>> getFavoriteTeams();

  /// Add team to favorites
  Future<Either<Failure, void>> addToFavorites(int teamId);

  /// Remove team from favorites
  Future<Either<Failure, void>> removeFromFavorites(int teamId);

  /// Check if team is in favorites
  Future<Either<Failure, bool>> isTeamFavorite(int teamId);

  /// Get team fixtures/matches
  Future<Either<Failure, List<dynamic>>> getTeamFixtures(
    int teamId, {
    DateTime? from,
    DateTime? to,
    String? status,
    int? limit,
  });

  /// Get team head-to-head statistics against another team
  Future<Either<Failure, Map<String, dynamic>>> getHeadToHead(
    int team1Id,
    int team2Id,
  );

  /// Get team form (recent match results)
  Future<Either<Failure, List<dynamic>>> getTeamForm(int teamId, {int? limit});

  /// Cache team data locally
  Future<Either<Failure, void>> cacheTeam(TeamEntity team);

  /// Get cached teams
  Future<Either<Failure, List<TeamEntity>>> getCachedTeams();

  /// Clear team cache
  Future<Either<Failure, void>> clearCache();
}