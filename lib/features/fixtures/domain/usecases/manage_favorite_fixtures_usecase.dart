import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/fixture_entity.dart';
import '../repositories/fixtures_repository.dart';

class GetFavoriteFixturesUseCase implements UseCase<List<FixtureEntity>, NoParams> {
  final FixturesRepository repository;

  const GetFavoriteFixturesUseCase(this.repository);

  @override
  Future<Either<Failure, List<FixtureEntity>>> call(NoParams params) async {
    return await repository.getFavoriteFixtures();
  }
}

class AddFixtureToFavoritesUseCase implements UseCase<void, AddFixtureToFavoritesParams> {
  final FixturesRepository repository;

  const AddFixtureToFavoritesUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(AddFixtureToFavoritesParams params) async {
    return await repository.addToFavorites(params.fixtureId);
  }
}

class RemoveFixtureFromFavoritesUseCase implements UseCase<void, RemoveFixtureFromFavoritesParams> {
  final FixturesRepository repository;

  const RemoveFixtureFromFavoritesUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(RemoveFixtureFromFavoritesParams params) async {
    return await repository.removeFromFavorites(params.fixtureId);
  }
}

class IsFixtureFavoriteUseCase implements UseCase<bool, IsFixtureFavoriteParams> {
  final FixturesRepository repository;

  const IsFixtureFavoriteUseCase(this.repository);

  @override
  Future<Either<Failure, bool>> call(IsFixtureFavoriteParams params) async {
    return await repository.isFixtureFavorite(params.fixtureId);
  }
}

class AddFixtureToFavoritesParams extends Equatable {
  final int fixtureId;

  const AddFixtureToFavoritesParams({required this.fixtureId});

  @override
  List<Object> get props => [fixtureId];
}

class RemoveFixtureFromFavoritesParams extends Equatable {
  final int fixtureId;

  const RemoveFixtureFromFavoritesParams({required this.fixtureId});

  @override
  List<Object> get props => [fixtureId];
}

class IsFixtureFavoriteParams extends Equatable {
  final int fixtureId;

  const IsFixtureFavoriteParams({required this.fixtureId});

  @override
  List<Object> get props => [fixtureId];
}