class FixtureModel {
  final int? id;
  final DateTime? date;
  final String? status;
  final int? matchday;
  final String? stage;
  final String? group;
  final DateTime? lastUpdated;
  final CompetitionInfo? competition;
  final SeasonInfo? season;
  final FixtureTeams? teams;
  final FixtureGoals? goals;
  final FixtureScore? score;
  final FixtureStatus? fixture;
  final List<dynamic>? events;

  const FixtureModel({
    this.id,
    this.date,
    this.status,
    this.matchday,
    this.stage,
    this.group,
    this.lastUpdated,
    this.competition,
    this.season,
    this.teams,
    this.goals,
    this.score,
    this.fixture,
    this.events,
  });

  factory FixtureModel.fromJson(Map<String, dynamic> json) {
    return FixtureModel(
      id: json['fixture']?['id'],
      date: json['fixture']?['date'] != null 
          ? DateTime.tryParse(json['fixture']['date'])
          : null,
      status: json['fixture']?['status']?['short'],
      teams: json['teams'] != null ? FixtureTeams.fromJson(json['teams']) : null,
      goals: json['goals'] != null ? FixtureGoals.fromJson(json['goals']) : null,
      score: json['score'] != null ? FixtureScore.fromJson(json['score']) : null,
      fixture: json['fixture'] != null ? FixtureStatus.fromJson(json['fixture']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date?.toIso8601String(),
      'status': status,
      'matchday': matchday,
      'stage': stage,
      'group': group,
      'teams': teams?.toJson(),
      'goals': goals?.toJson(),
      'score': score?.toJson(),
    };
  }
}

class FixtureTeams {
  final TeamInfo? home;
  final TeamInfo? away;

  const FixtureTeams({this.home, this.away});

  factory FixtureTeams.fromJson(Map<String, dynamic> json) {
    return FixtureTeams(
      home: json['home'] != null ? TeamInfo.fromJson(json['home']) : null,
      away: json['away'] != null ? TeamInfo.fromJson(json['away']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'home': home?.toJson(),
      'away': away?.toJson(),
    };
  }
}

class TeamInfo {
  final int? id;
  final String? name;
  final String? logo;

  const TeamInfo({this.id, this.name, this.logo});

  factory TeamInfo.fromJson(Map<String, dynamic> json) {
    return TeamInfo(
      id: json['id'],
      name: json['name'],
      logo: json['logo'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'logo': logo,
    };
  }
}

class FixtureGoals {
  final int? home;
  final int? away;

  const FixtureGoals({this.home, this.away});

  factory FixtureGoals.fromJson(Map<String, dynamic> json) {
    return FixtureGoals(
      home: json['home'],
      away: json['away'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'home': home,
      'away': away,
    };
  }
}

class FixtureScore {
  final FixtureGoals? halftime;
  final FixtureGoals? fulltime;
  final FixtureGoals? extratime;
  final FixtureGoals? penalty;

  const FixtureScore({
    this.halftime,
    this.fulltime,
    this.extratime,
    this.penalty,
  });

  factory FixtureScore.fromJson(Map<String, dynamic> json) {
    return FixtureScore(
      halftime: json['halftime'] != null ? FixtureGoals.fromJson(json['halftime']) : null,
      fulltime: json['fulltime'] != null ? FixtureGoals.fromJson(json['fulltime']) : null,
      extratime: json['extratime'] != null ? FixtureGoals.fromJson(json['extratime']) : null,
      penalty: json['penalty'] != null ? FixtureGoals.fromJson(json['penalty']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'halftime': halftime?.toJson(),
      'fulltime': fulltime?.toJson(),
      'extratime': extratime?.toJson(),
      'penalty': penalty?.toJson(),
    };
  }
}

class FixtureStatus {
  final int? elapsed;
  final String? short;
  final String? long;

  const FixtureStatus({this.elapsed, this.short, this.long});

  factory FixtureStatus.fromJson(Map<String, dynamic> json) {
    return FixtureStatus(
      elapsed: json['status']?['elapsed'],
      short: json['status']?['short'],
      long: json['status']?['long'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'elapsed': elapsed,
      'short': short,
      'long': long,
    };
  }
}

class CompetitionInfo {
  final int? id;
  final String? name;
  final String? logo;

  const CompetitionInfo({this.id, this.name, this.logo});

  factory CompetitionInfo.fromJson(Map<String, dynamic> json) {
    return CompetitionInfo(
      id: json['id'],
      name: json['name'],
      logo: json['logo'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'logo': logo,
    };
  }
}

class SeasonInfo {
  final int? year;
  final String? start;
  final String? end;

  const SeasonInfo({this.year, this.start, this.end});

  factory SeasonInfo.fromJson(Map<String, dynamic> json) {
    return SeasonInfo(
      year: json['year'],
      start: json['start'],
      end: json['end'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'year': year,
      'start': start,
      'end': end,
    };
  }
}