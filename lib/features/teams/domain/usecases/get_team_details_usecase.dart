import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/team_entity.dart';
import '../repositories/teams_repository.dart';

class GetTeamDetailsUseCase implements UseCase<TeamEntity, GetTeamDetailsParams> {
  final TeamsRepository repository;

  const GetTeamDetailsUseCase(this.repository);

  @override
  Future<Either<Failure, TeamEntity>> call(GetTeamDetailsParams params) async {
    return await repository.getTeamDetails(params.teamId);
  }
}

class GetTeamDetailsParams extends Equatable {
  final int teamId;

  const GetTeamDetailsParams({required this.teamId});

  @override
  List<Object> get props => [teamId];
}