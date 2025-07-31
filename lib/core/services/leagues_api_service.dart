import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../network/football_api_client.dart';
import '../../shared/data/models/league_model.dart';

class LeaguesApiService {
  final FootballApiClient _apiClient;

  LeaguesApiService(this._apiClient);

  /// Get all available leagues
  Future<List<LeagueModel>> getLeagues({
    String? country,
    String? season,
    int? id,
    String? name,
    String? code,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      
      if (country != null) queryParams['country'] = country;
      if (season != null) queryParams['season'] = season;
      if (id != null) queryParams['id'] = id;
      if (name != null) queryParams['name'] = name;
      if (code != null) queryParams['code'] = code;

      final response = await _apiClient.get('/leagues', queryParameters: queryParams);
      
      final leagues = <LeagueModel>[];
      final responseData = response['response'] as List<dynamic>;
      
      for (final item in responseData) {
        final leagueData = item['league'];
        final countryData = item['country'];
        final seasonsData = item['seasons'] as List<dynamic>;
        
        leagues.add(LeagueModel.fromJson({
          ...leagueData,
          'country': countryData,
          'seasons': seasonsData,
        }));
      }
      
      return leagues;
    } catch (e) {
      throw Exception('Failed to fetch leagues: $e');
    }
  }

  /// Get leagues by country
  Future<List<LeagueModel>> getLeaguesByCountry(String country) async {
    return getLeagues(country: country);
  }

  /// Get popular leagues (Premier League, La Liga, etc.)
  Future<List<LeagueModel>> getPopularLeagues() async {
    final popularLeagueIds = [39, 140, 78, 135, 61]; // Premier League, La Liga, Bundesliga, Serie A, Ligue 1
    final leagues = <LeagueModel>[];
    
    for (final id in popularLeagueIds) {
      try {
        final leagueList = await getLeagues(id: id);
        if (leagueList.isNotEmpty) {
          leagues.add(leagueList.first);
        }
      } catch (e) {
        // Continue with other leagues if one fails
        continue;
      }
    }
    
    return leagues;
  }

  /// Get league seasons
  Future<List<String>> getLeagueSeasons(int leagueId) async {
    try {
      final leagues = await getLeagues(id: leagueId);
      if (leagues.isEmpty) return [];
      
      return leagues.first.seasons
          ?.map((season) => season.year.toString())
          .toList() ?? [];
    } catch (e) {
      throw Exception('Failed to fetch league seasons: $e');
    }
  }

  /// Search leagues by name
  Future<List<LeagueModel>> searchLeagues(String query) async {
    try {
      final allLeagues = await getLeagues();
      return allLeagues
          .where((league) => 
              league.name.toLowerCase().contains(query.toLowerCase()) ||
              (league.country?.name?.toLowerCase().contains(query.toLowerCase()) ?? false))
          .toList();
    } catch (e) {
      throw Exception('Failed to search leagues: $e');
    }
  }

  /// Get league by ID
  Future<LeagueModel?> getLeagueById(int id) async {
    try {
      final leagues = await getLeagues(id: id);
      return leagues.isNotEmpty ? leagues.first : null;
    } catch (e) {
      throw Exception('Failed to fetch league by ID: $e');
    }
  }

  /// Get current season for a league
  Future<String?> getCurrentSeason(int leagueId) async {
    try {
      final league = await getLeagueById(leagueId);
      if (league?.seasons == null || league!.seasons!.isEmpty) return null;
      
      // Find current season (the one that's currently active)
      final currentYear = DateTime.now().year;
      for (final season in league.seasons!) {
        if (season.current == true) {
          return season.year.toString();
        }
      }
      
      // If no current season found, return the latest year
      return league.seasons!.last.year.toString();
    } catch (e) {
      throw Exception('Failed to get current season: $e');
    }
  }

  /// Get leagues by multiple countries
  Future<List<LeagueModel>> getLeaguesByCountries(List<String> countries) async {
    final allLeagues = <LeagueModel>[];
    
    for (final country in countries) {
      try {
        final leagues = await getLeaguesByCountry(country);
        allLeagues.addAll(leagues);
      } catch (e) {
        // Continue with other countries if one fails
        continue;
      }
    }
    
    return allLeagues;
  }
}

// Provider for the leagues API service
final leaguesApiServiceProvider = Provider<LeaguesApiService>((ref) {
  final apiClient = ref.watch(footballApiClientProvider);
  return LeaguesApiService(apiClient);
});