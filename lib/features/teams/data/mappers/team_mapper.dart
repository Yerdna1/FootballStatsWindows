import '../../../../shared/data/models/team_model.dart';
import '../../../../shared/data/models/league_model.dart';
import '../../domain/entities/team_entity.dart';

class TeamMapper {
  static TeamEntity toEntity(TeamModel model) {
    return TeamEntity(
      id: model.id,
      name: model.name,
      shortName: model.shortName,
      tla: model.tla,
      crest: model.crest,
      address: model.address,
      website: model.website,
      founded: model.founded,
      clubColors: model.clubColors,
      venue: model.venue,
      countryName: model.area?.name,
      countryFlag: model.area?.flag,
      competitions: model.runningCompetitions
          ?.map((comp) => CompetitionEntity(
                id: comp.id,
                name: comp.name,
                code: comp.code,
                type: comp.type,
                emblem: comp.emblem,
              ))
          .toList(),
      coach: model.coach != null
          ? CoachEntity(
              id: model.coach!.id,
              firstName: model.coach!.firstName,
              lastName: model.coach!.lastName,
              name: model.coach!.name,
              dateOfBirth: model.coach!.dateOfBirth,
              nationality: model.coach!.nationality,
              contract: model.coach!.contract != null
                  ? ContractEntity(
                      start: model.coach!.contract!.start,
                      until: model.coach!.contract!.until,
                    )
                  : null,
            )
          : null,
      squad: model.squad
          ?.map((player) => PlayerEntity(
                id: player.id,
                name: player.name,
                position: player.position,
                dateOfBirth: player.dateOfBirth,
                nationality: player.nationality,
                contract: player.contract != null
                    ? ContractEntity(
                        start: player.contract!.start,
                        until: player.contract!.until,
                      )
                    : null,
              ))
          .toList(),
      statistics: model.statistics != null
          ? TeamStatisticsEntity(
              playedGames: model.statistics!.playedGames,
              form: model.statistics!.form,
              won: model.statistics!.won,
              draw: model.statistics!.draw,
              lost: model.statistics!.lost,
              points: model.statistics!.points,
              goalsFor: model.statistics!.goalsFor,
              goalsAgainst: model.statistics!.goalsAgainst,
              goalDifference: model.statistics!.goalDifference,
            )
          : null,
      lastUpdated: model.lastUpdated,
    );
  }

  static TeamModel fromEntity(TeamEntity entity) {
    return TeamModel(
      id: entity.id,
      name: entity.name,
      shortName: entity.shortName,
      tla: entity.tla,
      crest: entity.crest,
      address: entity.address,
      website: entity.website,
      founded: entity.founded,
      clubColors: entity.clubColors,
      venue: entity.venue,
      area: entity.countryName != null
          ? AreaModel(
              id: 0, // We don't have area ID in entity
              name: entity.countryName!,
              code: '', // We don't have area code in entity
              flag: entity.countryFlag,
            )
          : null,
      runningCompetitions: entity.competitions
          ?.map((comp) => RunningCompetitionModel(
                id: comp.id,
                name: comp.name,
                code: comp.code,
                type: comp.type,
                emblem: comp.emblem,
              ))
          .toList(),
      coach: entity.coach != null
          ? CoachModel(
              id: entity.coach!.id,
              firstName: entity.coach!.firstName,
              lastName: entity.coach!.lastName,
              name: entity.coach!.name,
              dateOfBirth: entity.coach!.dateOfBirth,
              nationality: entity.coach!.nationality,
              contract: entity.coach!.contract != null
                  ? ContractModel(
                      start: entity.coach!.contract!.start,
                      until: entity.coach!.contract!.until,
                    )
                  : null,
            )
          : null,
      squad: entity.squad
          ?.map((player) => PlayerModel(
                id: player.id,
                name: player.name,
                position: player.position,
                dateOfBirth: player.dateOfBirth,
                nationality: player.nationality,
                contract: player.contract != null
                    ? ContractModel(
                        start: player.contract!.start,
                        until: player.contract!.until,
                      )
                    : null,
              ))
          .toList(),
      statistics: entity.statistics != null
          ? TeamStatisticsModel(
              playedGames: entity.statistics!.playedGames,
              form: entity.statistics!.form,
              won: entity.statistics!.won,
              draw: entity.statistics!.draw,
              lost: entity.statistics!.lost,
              points: entity.statistics!.points,
              goalsFor: entity.statistics!.goalsFor,
              goalsAgainst: entity.statistics!.goalsAgainst,
              goalDifference: entity.statistics!.goalDifference,
            )
          : null,
      lastUpdated: entity.lastUpdated,
    );
  }

  static PlayerEntity playerToEntity(PlayerModel model) {
    return PlayerEntity(
      id: model.id,
      name: model.name,
      position: model.position,
      dateOfBirth: model.dateOfBirth,
      nationality: model.nationality,
      contract: model.contract != null
          ? ContractEntity(
              start: model.contract!.start,
              until: model.contract!.until,
            )
          : null,
    );
  }

  static CoachEntity coachToEntity(CoachModel model) {
    return CoachEntity(
      id: model.id,
      firstName: model.firstName,
      lastName: model.lastName,
      name: model.name,
      dateOfBirth: model.dateOfBirth,
      nationality: model.nationality,
      contract: model.contract != null
          ? ContractEntity(
              start: model.contract!.start,
              until: model.contract!.until,
            )
          : null,
    );
  }
}