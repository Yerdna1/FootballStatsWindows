import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../shared/data/models/team_model.dart';

abstract class TeamsLocalDataSource {
  Future<List<TeamModel>> getCachedTeams();
  Future<void> cacheTeams(List<TeamModel> teams);
  Future<TeamModel?> getCachedTeam(int teamId);
  Future<void> cacheTeam(TeamModel team);
  Future<void> clearCache();
  
  Future<List<int>> getFavoriteTeamIds();
  Future<void> addToFavorites(int teamId);
  Future<void> removeFromFavorites(int teamId);
  Future<bool> isTeamFavorite(int teamId);
  Future<void> clearFavorites();
}

class TeamsLocalDataSourceImpl implements TeamsLocalDataSource {
  static const String _teamsBoxName = 'teams_cache';
  static const String _favoritesKey = 'favorite_teams';
  
  final SharedPreferences sharedPreferences;
  late Box<Map<dynamic, dynamic>> _teamsBox;

  TeamsLocalDataSourceImpl({required this.sharedPreferences});

  Future<void> _initializeBox() async {
    if (!Hive.isBoxOpen(_teamsBoxName)) {
      _teamsBox = await Hive.openBox<Map<dynamic, dynamic>>(_teamsBoxName);
    } else {
      _teamsBox = Hive.box<Map<dynamic, dynamic>>(_teamsBoxName);
    }
  }

  @override
  Future<List<TeamModel>> getCachedTeams() async {
    try {
      await _initializeBox();
      
      final teamsData = _teamsBox.values.toList();
      if (teamsData.isEmpty) {
        throw CacheException('No cached teams found');
      }

      return teamsData
          .map((data) => TeamModel.fromJson(Map<String, dynamic>.from(data)))
          .toList();
    } catch (e) {
      throw CacheException('Failed to get cached teams: $e');
    }
  }

  @override
  Future<void> cacheTeams(List<TeamModel> teams) async {
    try {
      await _initializeBox();
      
      // Clear existing cache
      await _teamsBox.clear();
      
      // Cache new teams
      for (final team in teams) {
        await _teamsBox.put(team.id.toString(), team.toJson());
      }
    } catch (e) {
      throw CacheException('Failed to cache teams: $e');
    }
  }

  @override
  Future<TeamModel?> getCachedTeam(int teamId) async {
    try {
      await _initializeBox();
      
      final teamData = _teamsBox.get(teamId.toString());
      if (teamData == null) {
        return null;
      }

      return TeamModel.fromJson(Map<String, dynamic>.from(teamData));
    } catch (e) {
      throw CacheException('Failed to get cached team: $e');
    }
  }

  @override
  Future<void> cacheTeam(TeamModel team) async {
    try {
      await _initializeBox();
      await _teamsBox.put(team.id.toString(), team.toJson());
    } catch (e) {
      throw CacheException('Failed to cache team: $e');
    }
  }

  @override
  Future<void> clearCache() async {
    try {
      await _initializeBox();
      await _teamsBox.clear();
    } catch (e) {
      throw CacheException('Failed to clear cache: $e');
    }
  }

  @override
  Future<List<int>> getFavoriteTeamIds() async {
    try {
      final favoriteTeamsString = sharedPreferences.getStringList(_favoritesKey);
      if (favoriteTeamsString == null) {
        return [];
      }
      return favoriteTeamsString.map((id) => int.parse(id)).toList();
    } catch (e) {
      throw CacheException('Failed to get favorite team IDs: $e');
    }
  }

  @override
  Future<void> addToFavorites(int teamId) async {
    try {
      final currentFavorites = await getFavoriteTeamIds();
      if (!currentFavorites.contains(teamId)) {
        currentFavorites.add(teamId);
        await sharedPreferences.setStringList(
          _favoritesKey,
          currentFavorites.map((id) => id.toString()).toList(),
        );
      }
    } catch (e) {
      throw CacheException('Failed to add team to favorites: $e');
    }
  }

  @override
  Future<void> removeFromFavorites(int teamId) async {
    try {
      final currentFavorites = await getFavoriteTeamIds();
      currentFavorites.remove(teamId);
      await sharedPreferences.setStringList(
        _favoritesKey,
        currentFavorites.map((id) => id.toString()).toList(),
      );
    } catch (e) {
      throw CacheException('Failed to remove team from favorites: $e');
    }
  }

  @override
  Future<bool> isTeamFavorite(int teamId) async {
    try {
      final favorites = await getFavoriteTeamIds();
      return favorites.contains(teamId);
    } catch (e) {
      throw CacheException('Failed to check if team is favorite: $e');
    }
  }

  @override
  Future<void> clearFavorites() async {
    try {
      await sharedPreferences.remove(_favoritesKey);
    } catch (e) {
      throw CacheException('Failed to clear favorites: $e');
    }
  }
}