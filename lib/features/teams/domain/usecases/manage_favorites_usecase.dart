import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/team_entity.dart';
import '../repositories/teams_repository.dart';

class GetFavoriteTeamsUseCase implements UseCase<List<TeamEntity>, NoParams> {
  final TeamsRepository repository;

  const GetFavoriteTeamsUseCase(this.repository);

  @override
  Future<Either<Failure, List<TeamEntity>>> call(NoParams params) async {
    return await repository.getFavoriteTeams();
  }
}

class AddTeamToFavoritesUseCase implements UseCase<void, AddToFavoritesParams> {
  final TeamsRepository repository;

  const AddTeamToFavoritesUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(AddToFavoritesParams params) async {
    return await repository.addToFavorites(params.teamId);
  }
}

class RemoveTeamFromFavoritesUseCase implements UseCase<void, RemoveFromFavoritesParams> {
  final TeamsRepository repository;

  const RemoveTeamFromFavoritesUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(RemoveFromFavoritesParams params) async {
    return await repository.removeFromFavorites(params.teamId);
  }
}

class IsTeamFavoriteUseCase implements UseCase<bool, IsTeamFavoriteParams> {
  final TeamsRepository repository;

  const IsTeamFavoriteUseCase(this.repository);

  @override
  Future<Either<Failure, bool>> call(IsTeamFavoriteParams params) async {
    return await repository.isTeamFavorite(params.teamId);
  }
}

class AddToFavoritesParams extends Equatable {
  final int teamId;

  const AddToFavoritesParams({required this.teamId});

  @override
  List<Object> get props => [teamId];
}

class RemoveFromFavoritesParams extends Equatable {
  final int teamId;

  const RemoveFromFavoritesParams({required this.teamId});

  @override
  List<Object> get props => [teamId];
}

class IsTeamFavoriteParams extends Equatable {
  final int teamId;

  const IsTeamFavoriteParams({required this.teamId});

  @override
  List<Object> get props => [teamId];
}