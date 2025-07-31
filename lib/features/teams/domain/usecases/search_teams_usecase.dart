import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/team_entity.dart';
import '../repositories/teams_repository.dart';

class SearchTeamsUseCase implements UseCase<List<TeamEntity>, SearchTeamsParams> {
  final TeamsRepository repository;

  const SearchTeamsUseCase(this.repository);

  @override
  Future<Either<Failure, List<TeamEntity>>> call(SearchTeamsParams params) async {
    return await repository.searchTeams(params.query);
  }
}

class SearchTeamsParams extends Equatable {
  final String query;

  const SearchTeamsParams({required this.query});

  @override
  List<Object> get props => [query];
}