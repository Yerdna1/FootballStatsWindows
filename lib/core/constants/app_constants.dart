class AppConstants {
  // App Information
  static const String appName = 'Football Stats';
  static const String appVersion = '1.0.0';
  
  // API Configuration
  static const String baseUrl = 'https://api.football-data.org/v4';
  static const String firebaseBaseUrl = 'https://football-stats-app.firebaseapp.com';
  
  // Football API Configuration (API-Football via RapidAPI)
  static const String footballApiBaseUrl = 'https://api-football-v1.p.rapidapi.com/v3';
  static const String footballApiHost = 'api-football-v1.p.rapidapi.com';
  static const String footballApiKey = 'YOUR_RAPIDAPI_KEY_HERE'; // Replace with actual API key
  
  // Storage Keys
  static const String userTokenKey = 'user_token';
  static const String themeKey = 'theme_mode';
  static const String languageKey = 'language_code';
  static const String favoritesKey = 'favorites';
  static const String cacheKey = 'cache_data';
  
  // Hive Box Names
  static const String userBox = 'user_box';
  static const String leaguesBox = 'leagues_box';
  static const String teamsBox = 'teams_box';
  static const String fixturesBox = 'fixtures_box';
  static const String standingsBox = 'standings_box';
  static const String favoritesBox = 'favorites_box';
  
  // Cache Duration
  static const Duration defaultCacheDuration = Duration(hours: 1);
  static const Duration longCacheDuration = Duration(hours: 24);
  static const Duration shortCacheDuration = Duration(minutes: 15);
  
  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;
  
  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);
  
  // UI Constants
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double defaultBorderRadius = 8.0;
  static const double cardElevation = 2.0;
  
  // Breakpoints for Responsive Design
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 900;
  static const double desktopBreakpoint = 1200;
  
  // Network Timeouts
  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 10);
  static const Duration sendTimeout = Duration(seconds: 10);
  
  // Firebase Collections
  static const String usersCollection = 'users';
  static const String leaguesCollection = 'leagues';
  static const String teamsCollection = 'teams';
  static const String fixturesCollection = 'fixtures';
  static const String standingsCollection = 'standings';
  static const String favoritesCollection = 'favorites';
  static const String analyticsCollection = 'analytics';
  
  // Default Values
  static const String defaultLanguage = 'en';
  static const String defaultCountry = 'England';
  static const int defaultLeagueId = 2021; // Premier League
  
  // Error Messages
  static const String networkError = 'Network error occurred';
  static const String serverError = 'Server error occurred';
  static const String unknownError = 'An unknown error occurred';
  static const String authError = 'Authentication error';
  static const String permissionError = 'Permission denied';
  
  // Success Messages
  static const String loginSuccess = 'Successfully logged in';
  static const String logoutSuccess = 'Successfully logged out';
  static const String dataUpdated = 'Data updated successfully';
  static const String favoriteAdded = 'Added to favorites';
  static const String favoriteRemoved = 'Removed from favorites';
  
  // Validation
  static const int minPasswordLength = 6;
  static const int maxNameLength = 50;
  static const String emailPattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
  
  // Default Images/Icons
  static const String defaultTeamLogo = 'assets/images/default_team_logo.png';
  static const String defaultLeagueLogo = 'assets/images/default_league_logo.png';
  static const String defaultPlayerImage = 'assets/images/default_player.png';
  
  // League IDs (commonly used leagues)
  static const Map<String, int> popularLeagues = {
    'Premier League': 2021,
    'La Liga': 2014,
    'Bundesliga': 2002,
    'Serie A': 2019,
    'Ligue 1': 2015,
    'Champions League': 2001,
    'Europa League': 2018,
  };
  
  // Team Position Colors Map
  static const Map<String, String> positionColors = {
    'champions': '#4CAF50',
    'europaLeague': '#2196F3',
    'relegation': '#F44336',
    'playoffs': '#FF9800',
  };
}