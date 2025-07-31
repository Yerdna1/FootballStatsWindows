import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/fixture_entity.dart';
import '../repositories/fixtures_repository.dart';

class GetLiveFixturesUseCase implements UseCase<List<FixtureEntity>, NoParams> {
  final FixturesRepository repository;

  const GetLiveFixturesUseCase(this.repository);

  @override
  Future<Either<Failure, List<FixtureEntity>>> call(NoParams params) async {
    return await repository.getLiveFixtures();
  }
}