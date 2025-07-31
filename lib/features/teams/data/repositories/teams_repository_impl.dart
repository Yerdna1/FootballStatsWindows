import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/team_entity.dart';
import '../../domain/repositories/teams_repository.dart';
import '../datasources/teams_local_datasource.dart';
import '../datasources/teams_remote_datasource.dart';
import '../mappers/team_mapper.dart';

class TeamsRepositoryImpl implements TeamsRepository {
  final TeamsRemoteDataSource remoteDataSource;
  final TeamsLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  TeamsRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<TeamEntity>>> getTeams({
    String? search,
    int? leagueId,
    String? country,
    int? limit,
    int? offset,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final teams = await remoteDataSource.getTeams(
          search: search,
          leagueId: leagueId,
          country: country,
          limit: limit,
          offset: offset,
        );
        
        // Cache the teams
        await localDataSource.cacheTeams(teams);
        
        return Right(teams.map((team) => TeamMapper.toEntity(team)).toList());
      } on DioException catch (e) {
        return Left(ServerFailure(
          message: e.message ?? 'Server error occurred',
          code: e.response?.statusCode,
        ));
      } on ServerException catch (e) {
        return Left(ServerFailure(
          message: e.message,
          code: e.statusCode,
        ));
      } catch (e) {
        return Left(UnknownFailure(message: 'Unknown error occurred: $e'));
      }
    } else {
      try {
        final cachedTeams = await localDataSource.getCachedTeams();
        return Right(cachedTeams.map((team) => TeamMapper.toEntity(team)).toList());
      } on CacheException catch (e) {
        return Left(CacheFailure(message: e.message));
      }
    }
  }

  @override
  Future<Either<Failure, TeamEntity>> getTeam(int teamId) async {
    if (await networkInfo.isConnected) {
      try {
        final team = await remoteDataSource.getTeam(teamId);
        await localDataSource.cacheTeam(team);
        return Right(TeamMapper.toEntity(team));
      } on DioException catch (e) {
        return Left(ServerFailure(
          message: e.message ?? 'Server error occurred',
          code: e.response?.statusCode,
        ));
      } on ServerException catch (e) {
        return Left(ServerFailure(
          message: e.message,
          code: e.statusCode,
        ));
      } catch (e) {
        return Left(UnknownFailure(message: 'Unknown error occurred: $e'));
      }
    } else {
      try {
        final cachedTeam = await localDataSource.getCachedTeam(teamId);
        if (cachedTeam != null) {
          return Right(TeamMapper.toEntity(cachedTeam));
        } else {
          return Left(CacheFailure(message: 'Team not found in cache'));
        }
      } on CacheException catch (e) {
        return Left(CacheFailure(message: e.message));
      }
    }
  }

  @override
  Future<Either<Failure, TeamEntity>> getTeamDetails(int teamId) async {
    if (await networkInfo.isConnected) {
      try {
        final team = await remoteDataSource.getTeamDetails(teamId);
        await localDataSource.cacheTeam(team);
        return Right(TeamMapper.toEntity(team));
      } on DioException catch (e) {
        return Left(ServerFailure(
          message: e.message ?? 'Server error occurred',
          code: e.response?.statusCode,
        ));
      } on ServerException catch (e) {
        return Left(ServerFailure(
          message: e.message,
          code: e.statusCode,
        ));
      } catch (e) {
        return Left(UnknownFailure(message: 'Unknown error occurred: $e'));
      }
    } else {
      try {
        final cachedTeam = await localDataSource.getCachedTeam(teamId);
        if (cachedTeam != null) {
          return Right(TeamMapper.toEntity(cachedTeam));
        } else {
          return Left(CacheFailure(message: 'Team details not found in cache'));
        }
      } on CacheException catch (e) {
        return Left(CacheFailure(message: e.message));
      }
    }
  }

  @override
  Future<Either<Failure, List<PlayerEntity>>> getTeamSquad(int teamId) async {
    if (await networkInfo.isConnected) {
      try {
        final players = await remoteDataSource.getTeamSquad(teamId);
        return Right(players.map((player) => TeamMapper.playerToEntity(player)).toList());
      } on DioException catch (e) {
        return Left(ServerFailure(
          message: e.message ?? 'Server error occurred',
          code: e.response?.statusCode,
        ));
      } on ServerException catch (e) {
        return Left(ServerFailure(
          message: e.message,
          code: e.statusCode,
        ));
      } catch (e) {
        return Left(UnknownFailure(message: 'Unknown error occurred: $e'));
      }
    } else {
      try {
        final cachedTeam = await localDataSource.getCachedTeam(teamId);
        if (cachedTeam?.squad != null) {
          return Right(cachedTeam!.squad!.map((player) => TeamMapper.playerToEntity(player)).toList());
        } else {
          return Left(CacheFailure(message: 'Team squad not found in cache'));
        }
      } on CacheException catch (e) {
        return Left(CacheFailure(message: e.message));
      }
    }
  }

  @override
  Future<Either<Failure, List<TeamEntity>>> getTeamsByLeague(int leagueId) async {
    if (await networkInfo.isConnected) {
      try {
        final teams = await remoteDataSource.getTeamsByLeague(leagueId);
        await localDataSource.cacheTeams(teams);
        return Right(teams.map((team) => TeamMapper.toEntity(team)).toList());
      } on DioException catch (e) {
        return Left(ServerFailure(
          message: e.message ?? 'Server error occurred',
          code: e.response?.statusCode,
        ));
      } on ServerException catch (e) {
        return Left(ServerFailure(
          message: e.message,
          code: e.statusCode,
        ));
      } catch (e) {
        return Left(UnknownFailure(message: 'Unknown error occurred: $e'));
      }
    } else {
      try {
        final cachedTeams = await localDataSource.getCachedTeams();
        // Filter by league if we have that information cached
        return Right(cachedTeams.map((team) => TeamMapper.toEntity(team)).toList());
      } on CacheException catch (e) {
        return Left(CacheFailure(message: e.message));
      }
    }
  }

  @override
  Future<Either<Failure, List<TeamEntity>>> searchTeams(String query) async {
    if (await networkInfo.isConnected) {
      try {
        final teams = await remoteDataSource.searchTeams(query);
        return Right(teams.map((team) => TeamMapper.toEntity(team)).toList());
      } on DioException catch (e) {
        return Left(ServerFailure(
          message: e.message ?? 'Server error occurred',
          code: e.response?.statusCode,
        ));
      } on ServerException catch (e) {
        return Left(ServerFailure(
          message: e.message,
          code: e.statusCode,
        ));
      } catch (e) {
        return Left(UnknownFailure(message: 'Unknown error occurred: $e'));
      }
    } else {
      try {
        final cachedTeams = await localDataSource.getCachedTeams();
        final filteredTeams = cachedTeams
            .where((team) =>
                team.name.toLowerCase().contains(query.toLowerCase()) ||
                team.shortName.toLowerCase().contains(query.toLowerCase()))
            .toList();
        return Right(filteredTeams.map((team) => TeamMapper.toEntity(team)).toList());
      } on CacheException catch (e) {
        return Left(CacheFailure(message: e.message));
      }
    }
  }

  @override
  Future<Either<Failure, List<TeamEntity>>> getFavoriteTeams() async {
    try {
      final favoriteIds = await localDataSource.getFavoriteTeamIds();
      final List<TeamEntity> favoriteTeams = [];

      for (final teamId in favoriteIds) {
        final teamResult = await getTeam(teamId);
        teamResult.fold(
          (failure) {
            // Skip teams that can't be loaded
          },
          (team) => favoriteTeams.add(team),
        );
      }

      return Right(favoriteTeams);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: 'Unknown error occurred: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> addToFavorites(int teamId) async {
    try {
      await localDataSource.addToFavorites(teamId);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: 'Unknown error occurred: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> removeFromFavorites(int teamId) async {
    try {
      await localDataSource.removeFromFavorites(teamId);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: 'Unknown error occurred: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> isTeamFavorite(int teamId) async {
    try {
      final isFavorite = await localDataSource.isTeamFavorite(teamId);
      return Right(isFavorite);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: 'Unknown error occurred: $e'));
    }
  }

  @override
  Future<Either<Failure, List<dynamic>>> getTeamFixtures(
    int teamId, {
    DateTime? from,
    DateTime? to,
    String? status,
    int? limit,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final fixtures = await remoteDataSource.getTeamFixtures(
          teamId,
          from: from,
          to: to,
          status: status,
          limit: limit,
        );
        return Right(fixtures);
      } on DioException catch (e) {
        return Left(ServerFailure(
          message: e.message ?? 'Server error occurred',
          code: e.response?.statusCode,
        ));
      } on ServerException catch (e) {
        return Left(ServerFailure(
          message: e.message,
          code: e.statusCode,
        ));
      } catch (e) {
        return Left(UnknownFailure(message: 'Unknown error occurred: $e'));
      }
    } else {
      return Left(NetworkFailure(message: 'No internet connection'));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getHeadToHead(
    int team1Id,
    int team2Id,
  ) async {
    if (await networkInfo.isConnected) {
      try {
        final headToHead = await remoteDataSource.getHeadToHead(team1Id, team2Id);
        return Right(headToHead);
      } on DioException catch (e) {
        return Left(ServerFailure(
          message: e.message ?? 'Server error occurred',
          code: e.response?.statusCode,
        ));
      } on ServerException catch (e) {
        return Left(ServerFailure(
          message: e.message,
          code: e.statusCode,
        ));
      } catch (e) {
        return Left(UnknownFailure(message: 'Unknown error occurred: $e'));
      }
    } else {
      return Left(NetworkFailure(message: 'No internet connection'));
    }
  }

  @override
  Future<Either<Failure, List<dynamic>>> getTeamForm(int teamId, {int? limit}) async {
    if (await networkInfo.isConnected) {
      try {
        final form = await remoteDataSource.getTeamForm(teamId, limit: limit);
        return Right(form);
      } on DioException catch (e) {
        return Left(ServerFailure(
          message: e.message ?? 'Server error occurred',
          code: e.response?.statusCode,
        ));
      } on ServerException catch (e) {
        return Left(ServerFailure(
          message: e.message,
          code: e.statusCode,
        ));
      } catch (e) {
        return Left(UnknownFailure(message: 'Unknown error occurred: $e'));
      }
    } else {
      return Left(NetworkFailure(message: 'No internet connection'));
    }
  }

  @override
  Future<Either<Failure, void>> cacheTeam(TeamEntity team) async {
    try {
      final teamModel = TeamMapper.fromEntity(team);
      await localDataSource.cacheTeam(teamModel);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: 'Unknown error occurred: $e'));
    }
  }

  @override
  Future<Either<Failure, List<TeamEntity>>> getCachedTeams() async {
    try {
      final cachedTeams = await localDataSource.getCachedTeams();
      return Right(cachedTeams.map((team) => TeamMapper.toEntity(team)).toList());
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, void>> clearCache() async {
    try {
      await localDataSource.clearCache();
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: 'Unknown error occurred: $e'));
    }
  }
}