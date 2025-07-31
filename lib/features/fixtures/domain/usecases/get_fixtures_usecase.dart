import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/fixture_entity.dart';
import '../repositories/fixtures_repository.dart';

class GetFixturesUseCase implements UseCase<List<FixtureEntity>, GetFixturesParams> {
  final FixturesRepository repository;

  const GetFixturesUseCase(this.repository);

  @override
  Future<Either<Failure, List<FixtureEntity>>> call(GetFixturesParams params) async {
    return await repository.getFixtures(
      leagueId: params.leagueId,
      teamId: params.teamId,
      from: params.from,
      to: params.to,
      status: params.status,
      matchday: params.matchday,
      venue: params.venue,
      limit: params.limit,
      offset: params.offset,
    );
  }
}

class GetFixturesParams extends Equatable {
  final int? leagueId;
  final int? teamId;
  final DateTime? from;
  final DateTime? to;
  final String? status;
  final int? matchday;
  final String? venue;
  final int? limit;
  final int? offset;

  const GetFixturesParams({
    this.leagueId,
    this.teamId,
    this.from,
    this.to,
    this.status,
    this.matchday,
    this.venue,
    this.limit,
    this.offset,
  });

  @override
  List<Object?> get props => [
        leagueId,
        teamId,
        from,
        to,
        status,
        matchday,
        venue,
        limit,
        offset,
      ];

  GetFixturesParams copyWith({
    int? leagueId,
    int? teamId,
    DateTime? from,
    DateTime? to,
    String? status,
    int? matchday,
    String? venue,
    int? limit,
    int? offset,
  }) {
    return GetFixturesParams(
      leagueId: leagueId ?? this.leagueId,
      teamId: teamId ?? this.teamId,
      from: from ?? this.from,
      to: to ?? this.to,
      status: status ?? this.status,
      matchday: matchday ?? this.matchday,
      venue: venue ?? this.venue,
      limit: limit ?? this.limit,
      offset: offset ?? this.offset,
    );
  }
}