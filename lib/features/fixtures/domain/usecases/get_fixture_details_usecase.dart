import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/fixture_entity.dart';
import '../repositories/fixtures_repository.dart';

class GetFixtureDetailsUseCase implements UseCase<FixtureEntity, GetFixtureDetailsParams> {
  final FixturesRepository repository;

  const GetFixtureDetailsUseCase(this.repository);

  @override
  Future<Either<Failure, FixtureEntity>> call(GetFixtureDetailsParams params) async {
    return await repository.getFixtureDetails(params.fixtureId);
  }
}

class GetFixtureDetailsParams extends Equatable {
  final int fixtureId;

  const GetFixtureDetailsParams({required this.fixtureId});

  @override
  List<Object> get props => [fixtureId];
}