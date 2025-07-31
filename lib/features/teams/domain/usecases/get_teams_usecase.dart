import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/team_entity.dart';
import '../repositories/teams_repository.dart';

class GetTeamsUseCase implements UseCase<List<TeamEntity>, GetTeamsParams> {
  final TeamsRepository repository;

  const GetTeamsUseCase(this.repository);

  @override
  Future<Either<Failure, List<TeamEntity>>> call(GetTeamsParams params) async {
    return await repository.getTeams(
      search: params.search,
      leagueId: params.leagueId,
      country: params.country,
      limit: params.limit,
      offset: params.offset,
    );
  }
}

class GetTeamsParams extends Equatable {
  final String? search;
  final int? leagueId;
  final String? country;
  final int? limit;
  final int? offset;

  const GetTeamsParams({
    this.search,
    this.leagueId,
    this.country,
    this.limit,
    this.offset,
  });

  @override
  List<Object?> get props => [search, leagueId, country, limit, offset];

  GetTeamsParams copyWith({
    String? search,
    int? leagueId,
    String? country,
    int? limit,
    int? offset,
  }) {
    return GetTeamsParams(
      search: search ?? this.search,
      leagueId: leagueId ?? this.leagueId,
      country: country ?? this.country,
      limit: limit ?? this.limit,
      offset: offset ?? this.offset,
    );
  }
}