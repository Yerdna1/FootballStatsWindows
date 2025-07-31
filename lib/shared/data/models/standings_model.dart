import 'package:freezed_annotation/freezed_annotation.dart';

part 'standings_model.freezed.dart';
part 'standings_model.g.dart';

@freezed
class StandingsModel with _$StandingsModel {
  const factory StandingsModel({
    required String stage,
    required String type,
    String? group,
    required List<StandingTableModel> table,
  }) = _StandingsModel;

  factory StandingsModel.fromJson(Map<String, dynamic> json) =>
      _$StandingsModelFromJson(json);
}

@freezed
class StandingTableModel with _$StandingTableModel {
  const factory StandingTableModel({
    required int position,
    required TeamStandingModel team,
    required int playedGames,
    String? form,
    required int won,
    required int draw,
    required int lost,
    required int points,
    required int goalsFor,
    required int goalsAgainst,
    required int goalDifference,
  }) = _StandingTableModel;

  factory StandingTableModel.fromJson(Map<String, dynamic> json) =>
      _$StandingTableModelFromJson(json);
}

@freezed
class TeamStandingModel with _$TeamStandingModel {
  const factory TeamStandingModel({
    required int id,
    required String name,
    required String shortName,
    required String tla,
    required String crest,
  }) = _TeamStandingModel;

  factory TeamStandingModel.fromJson(Map<String, dynamic> json) =>
      _$TeamStandingModelFromJson(json);
}

@freezed
class LeagueStandingsModel with _$LeagueStandingsModel {
  const factory LeagueStandingsModel({
    required CompetitionModel competition,
    required SeasonModel season,
    required List<StandingsModel> standings,
    DateTime? lastUpdated,
  }) = _LeagueStandingsModel;

  factory LeagueStandingsModel.fromJson(Map<String, dynamic> json) =>
      _$LeagueStandingsModelFromJson(json);
}

enum TablePosition {
  champions,
  championsLeague,
  europaLeague,
  conferenceLeague,
  midTable,
  relegationPlayoff,
  relegation,
}

extension StandingTableModelX on StandingTableModel {
  double get winPercentage {
    if (playedGames == 0) return 0.0;
    return (won / playedGames) * 100;
  }

  double get drawPercentage {
    if (playedGames == 0) return 0.0;
    return (draw / playedGames) * 100;
  }

  double get lossPercentage {
    if (playedGames == 0) return 0.0;
    return (lost / playedGames) * 100;
  }

  double get pointsPerGame {
    if (playedGames == 0) return 0.0;
    return points / playedGames;
  }

  double get goalsPerGame {
    if (playedGames == 0) return 0.0;
    return goalsFor / playedGames;
  }

  double get goalsConcededPerGame {
    if (playedGames == 0) return 0.0;
    return goalsAgainst / playedGames;
  }

  String get formDisplay => form ?? 'N/A';

  List<String> get formResults {
    if (form == null || form!.isEmpty) return [];
    return form!.split('');
  }

  TablePosition getTablePosition(String competitionCode) {
    switch (competitionCode.toUpperCase()) {
      case 'PL': // Premier League
        if (position == 1) return TablePosition.champions;
        if (position <= 4) return TablePosition.championsLeague;
        if (position <= 6) return TablePosition.europaLeague;
        if (position == 7) return TablePosition.conferenceLeague;
        if (position >= 18) return TablePosition.relegation;
        return TablePosition.midTable;
      
      case 'PD': // La Liga
      case 'SA': // Serie A
      case 'BL1': // Bundesliga
        if (position == 1) return TablePosition.champions;
        if (position <= 4) return TablePosition.championsLeague;
        if (position <= 6) return TablePosition.europaLeague;
        if (position >= 18) return TablePosition.relegation;
        return TablePosition.midTable;
      
      case 'FL1': // Ligue 1
        if (position == 1) return TablePosition.champions;
        if (position <= 3) return TablePosition.championsLeague;
        if (position <= 5) return TablePosition.europaLeague;
        if (position >= 19) return TablePosition.relegation;
        return TablePosition.midTable;
      
      default:
        return TablePosition.midTable;
    }
  }

  String getPositionColor(String competitionCode) {
    final position = getTablePosition(competitionCode);
    switch (position) {
      case TablePosition.champions:
        return '#FFD700'; // Gold
      case TablePosition.championsLeague:
        return '#4CAF50'; // Green
      case TablePosition.europaLeague:
        return '#2196F3'; // Blue
      case TablePosition.conferenceLeague:
        return '#FF9800'; // Orange
      case TablePosition.relegationPlayoff:
        return '#FF5722'; // Deep Orange
      case TablePosition.relegation:
        return '#F44336'; // Red
      case TablePosition.midTable:
      default:
        return '#9E9E9E'; // Grey
    }
  }

  Map<String, dynamic> toFirestore() {
    return {
      'position': position,
      'team': team.toJson(),
      'playedGames': playedGames,
      'form': form,
      'won': won,
      'draw': draw,
      'lost': lost,
      'points': points,
      'goalsFor': goalsFor,
      'goalsAgainst': goalsAgainst,
      'goalDifference': goalDifference,
    };
  }

  static StandingTableModel fromFirestore(Map<String, dynamic> data) {
    return StandingTableModel(
      position: data['position'],
      team: TeamStandingModel.fromJson(data['team']),
      playedGames: data['playedGames'],
      form: data['form'],
      won: data['won'],
      draw: data['draw'],
      lost: data['lost'],
      points: data['points'],
      goalsFor: data['goalsFor'],
      goalsAgainst: data['goalsAgainst'],
      goalDifference: data['goalDifference'],
    );
  }
}

extension LeagueStandingsModelX on LeagueStandingsModel {
  List<StandingTableModel> get mainTable {
    final mainStanding = standings.firstWhere(
      (standing) => standing.type == 'TOTAL',
      orElse: () => standings.first,
    );
    return mainStanding.table;
  }

  StandingTableModel? getTeamStanding(int teamId) {
    try {
      return mainTable.firstWhere((team) => team.team.id == teamId);
    } catch (e) {
      return null;
    }
  }

  List<StandingTableModel> getTopTeams([int count = 5]) {
    return mainTable.take(count).toList();
  }

  List<StandingTableModel> getBottomTeams([int count = 5]) {
    return mainTable.reversed.take(count).toList().reversed.toList();
  }

  Map<String, dynamic> toFirestore() {
    return {
      'competition': competition.toJson(),
      'season': season.toJson(),
      'standings': standings.map((s) => s.toJson()).toList(),
      'lastUpdated': lastUpdated?.millisecondsSinceEpoch,
    };
  }

  static LeagueStandingsModel fromFirestore(Map<String, dynamic> data) {
    return LeagueStandingsModel(
      competition: CompetitionModel.fromJson(data['competition']),
      season: SeasonModel.fromJson(data['season']),
      standings: (data['standings'] as List<dynamic>)
          .map((s) => StandingsModel.fromJson(s))
          .toList(),
      lastUpdated: data['lastUpdated'] != null
          ? DateTime.fromMillisecondsSinceEpoch(data['lastUpdated'])
          : null,
    );
  }
}