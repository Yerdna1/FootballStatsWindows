import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../shared/data/models/fixture_model.dart';

abstract class FixturesLocalDataSource {
  Future<List<FixtureModel>> getCachedFixtures();
  Future<void> cacheFixtures(List<FixtureModel> fixtures);
  Future<FixtureModel?> getCachedFixture(int fixtureId);
  Future<void> cacheFixture(FixtureModel fixture);
  Future<void> clearCache();
  
  Future<List<int>> getFavoriteFixtureIds();
  Future<void> addToFavorites(int fixtureId);
  Future<void> removeFromFavorites(int fixtureId);
  Future<bool> isFixtureFavorite(int fixtureId);
  Future<void> clearFavorites();
  
  Future<List<FixtureModel>> getCachedFixturesByDate(DateTime date);
  Future<List<FixtureModel>> getCachedLiveFixtures();
  Future<List<FixtureModel>> getCachedUpcomingFixtures();
  Future<List<FixtureModel>> getCachedRecentFixtures();
  Future<void> cacheFixturesByCategory(String category, List<FixtureModel> fixtures);
}

class FixturesLocalDataSourceImpl implements FixturesLocalDataSource {
  static const String _fixturesBoxName = 'fixtures_cache';
  static const String _favoritesKey = 'favorite_fixtures';
  static const String _liveFixturesKey = 'live_fixtures';
  static const String _upcomingFixturesKey = 'upcoming_fixtures';
  static const String _recentFixturesKey = 'recent_fixtures';
  
  final SharedPreferences sharedPreferences;
  late Box<Map<dynamic, dynamic>> _fixturesBox;

  FixturesLocalDataSourceImpl({required this.sharedPreferences});

  Future<void> _initializeBox() async {
    if (!Hive.isBoxOpen(_fixturesBoxName)) {
      _fixturesBox = await Hive.openBox<Map<dynamic, dynamic>>(_fixturesBoxName);
    } else {
      _fixturesBox = Hive.box<Map<dynamic, dynamic>>(_fixturesBoxName);
    }
  }

  @override
  Future<List<FixtureModel>> getCachedFixtures() async {
    try {
      await _initializeBox();
      
      final fixturesData = _fixturesBox.values
          .where((data) => !data.containsKey('category'))
          .toList();
      
      if (fixturesData.isEmpty) {
        throw CacheException('No cached fixtures found');
      }

      return fixturesData
          .map((data) => FixtureModel.fromJson(Map<String, dynamic>.from(data)))
          .toList();
    } catch (e) {
      throw CacheException('Failed to get cached fixtures: $e');
    }
  }

  @override
  Future<void> cacheFixtures(List<FixtureModel> fixtures) async {
    try {
      await _initializeBox();
      
      // Cache individual fixtures
      for (final fixture in fixtures) {
        await _fixturesBox.put(fixture.id.toString(), fixture.toJson());
      }
    } catch (e) {
      throw CacheException('Failed to cache fixtures: $e');
    }
  }

  @override
  Future<FixtureModel?> getCachedFixture(int fixtureId) async {
    try {
      await _initializeBox();
      
      final fixtureData = _fixturesBox.get(fixtureId.toString());
      if (fixtureData == null) {
        return null;
      }

      return FixtureModel.fromJson(Map<String, dynamic>.from(fixtureData));
    } catch (e) {
      throw CacheException('Failed to get cached fixture: $e');
    }
  }

  @override
  Future<void> cacheFixture(FixtureModel fixture) async {
    try {
      await _initializeBox();
      await _fixturesBox.put(fixture.id.toString(), fixture.toJson());
    } catch (e) {
      throw CacheException('Failed to cache fixture: $e');
    }
  }

  @override
  Future<void> clearCache() async {
    try {
      await _initializeBox();
      await _fixturesBox.clear();
    } catch (e) {
      throw CacheException('Failed to clear cache: $e');
    }
  }

  @override
  Future<List<int>> getFavoriteFixtureIds() async {
    try {
      final favoriteFixturesString = sharedPreferences.getStringList(_favoritesKey);
      if (favoriteFixturesString == null) {
        return [];
      }
      return favoriteFixturesString.map((id) => int.parse(id)).toList();
    } catch (e) {
      throw CacheException('Failed to get favorite fixture IDs: $e');
    }
  }

  @override
  Future<void> addToFavorites(int fixtureId) async {
    try {
      final currentFavorites = await getFavoriteFixtureIds();
      if (!currentFavorites.contains(fixtureId)) {
        currentFavorites.add(fixtureId);
        await sharedPreferences.setStringList(
          _favoritesKey,
          currentFavorites.map((id) => id.toString()).toList(),
        );
      }
    } catch (e) {
      throw CacheException('Failed to add fixture to favorites: $e');
    }
  }

  @override
  Future<void> removeFromFavorites(int fixtureId) async {
    try {
      final currentFavorites = await getFavoriteFixtureIds();
      currentFavorites.remove(fixtureId);
      await sharedPreferences.setStringList(
        _favoritesKey,
        currentFavorites.map((id) => id.toString()).toList(),
      );
    } catch (e) {
      throw CacheException('Failed to remove fixture from favorites: $e');
    }
  }

  @override
  Future<bool> isFixtureFavorite(int fixtureId) async {
    try {
      final favorites = await getFavoriteFixtureIds();
      return favorites.contains(fixtureId);
    } catch (e) {
      throw CacheException('Failed to check if fixture is favorite: $e');
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

  @override
  Future<List<FixtureModel>> getCachedFixturesByDate(DateTime date) async {
    try {
      await _initializeBox();
      
      final dateKey = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      final fixturesData = _fixturesBox.get('date_$dateKey');
      
      if (fixturesData == null) {
        return [];
      }

      final List<dynamic> fixturesList = fixturesData['fixtures'];
      return fixturesList
          .map((data) => FixtureModel.fromJson(Map<String, dynamic>.from(data)))
          .toList();
    } catch (e) {
      throw CacheException('Failed to get cached fixtures by date: $e');
    }
  }

  @override
  Future<List<FixtureModel>> getCachedLiveFixtures() async {
    return await _getCachedFixturesByCategory(_liveFixturesKey);
  }

  @override
  Future<List<FixtureModel>> getCachedUpcomingFixtures() async {
    return await _getCachedFixturesByCategory(_upcomingFixturesKey);
  }

  @override
  Future<List<FixtureModel>> getCachedRecentFixtures() async {
    return await _getCachedFixturesByCategory(_recentFixturesKey);
  }

  @override
  Future<void> cacheFixturesByCategory(String category, List<FixtureModel> fixtures) async {
    try {
      await _initializeBox();
      
      final categoryData = {
        'category': category,
        'fixtures': fixtures.map((f) => f.toJson()).toList(),
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };
      
      await _fixturesBox.put(category, categoryData);
    } catch (e) {
      throw CacheException('Failed to cache fixtures by category: $e');
    }
  }

  Future<List<FixtureModel>> _getCachedFixturesByCategory(String category) async {
    try {
      await _initializeBox();
      
      final categoryData = _fixturesBox.get(category);
      if (categoryData == null) {
        return [];
      }

      final List<dynamic> fixturesList = categoryData['fixtures'];
      return fixturesList
          .map((data) => FixtureModel.fromJson(Map<String, dynamic>.from(data)))
          .toList();
    } catch (e) {
      throw CacheException('Failed to get cached fixtures by category: $e');
    }
  }
}