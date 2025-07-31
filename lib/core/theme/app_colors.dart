import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors (Football Green)
  static const Color primary = Color(0xFF00A86B);
  static const Color primaryLight = Color(0xFF4DD18A);
  static const Color primaryDark = Color(0xFF007A50);
  
  // Secondary Colors (Football Blue)
  static const Color secondary = Color(0xFF1E40AF);
  static const Color secondaryLight = Color(0xFF3B82F6);
  static const Color secondaryDark = Color(0xFF1E3A8A);
  
  // Accent Colors
  static const Color accent = Color(0xFFFFB800);
  static const Color accentLight = Color(0xFFFFC947);
  static const Color accentDark = Color(0xFFE5A500);
  
  // Background Colors
  static const Color background = Color(0xFFF8FAFC);
  static const Color darkBackground = Color(0xFF0A0E1A);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color darkSurface = Color(0xFF1A202C);
  static const Color surfaceVariant = Color(0xFFF1F5F9);
  static const Color darkSurfaceVariant = Color(0xFF2D3748);
  
  // Text Colors
  static const Color textPrimary = Color(0xFF1A202C);
  static const Color textSecondary = Color(0xFF4A5568);
  static const Color textTertiary = Color(0xFF718096);
  static const Color textDisabled = Color(0xFFA0AEC0);
  static const Color textOnPrimary = Colors.white;
  static const Color textOnDark = Color(0xFFF7FAFC);
  
  // Status Colors
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFEAB308);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);
  
  // Football Match Result Colors
  static const Color win = Color(0xFF10B981);
  static const Color draw = Color(0xFFEAB308);
  static const Color loss = Color(0xFFEF4444);
  static const Color homeTeam = Color(0xFF3B82F6);
  static const Color awayTeam = Color(0xFF6366F1);
  
  // Live Match Colors
  static const Color live = Color(0xFFEC4899);
  static const Color liveBackground = Color(0xFFFDF2F8);
  static const Color livePulse = Color(0xFFF472B6);
  
  // Card Colors
  static const Color cardBackground = Colors.white;
  static const Color cardShadow = Color(0x0A000000);
  static const Color darkCardBackground = Color(0xFF2D3748);
  static const Color cardBorder = Color(0xFFE2E8F0);
  static const Color darkCardBorder = Color(0xFF4A5568);
  
  // Elevated Card Colors
  static const Color elevatedCard = Color(0xFFFFFFFF);
  static const Color darkElevatedCard = Color(0xFF374151);
  static const Color elevatedCardShadow = Color(0x14000000);
  
  // Border Colors
  static const Color border = Color(0xFFE2E8F0);
  static const Color borderHover = Color(0xFFCBD5E0);
  static const Color darkBorder = Color(0xFF4A5568);
  static const Color darkBorderHover = Color(0xFF718096);
  
  // League Position Colors
  static const Color champions = Color(0xFF10B981);
  static const Color championsBackground = Color(0xFFECFDF5);
  static const Color europaLeague = Color(0xFF3B82F6);
  static const Color europaLeagueBackground = Color(0xFFEFF6FF);
  static const Color conferenceLeague = Color(0xFF8B5CF6);
  static const Color conferenceLeagueBackground = Color(0xFFF3E8FF);
  static const Color relegation = Color(0xFFEF4444);
  static const Color relegationBackground = Color(0xFFFEF2F2);
  static const Color playoffs = Color(0xFFEAB308);
  static const Color playoffsBackground = Color(0xFFFEFCE8);
  
  // Form Colors (Recent Match Results)
  static const Color formWin = Color(0xFF10B981);
  static const Color formDraw = Color(0xFFEAB308);
  static const Color formLoss = Color(0xFFEF4444);
  
  // Statistics Colors
  static const Color statisticsPositive = Color(0xFF10B981);
  static const Color statisticsNeutral = Color(0xFF6B7280);
  static const Color statisticsNegative = Color(0xFFEF4444);
  
  // Team Colors (Popular Football Teams)
  static const Map<String, Color> teamColors = {
    'arsenal': Color(0xFFEF0107),
    'chelsea': Color(0xFF034694),
    'liverpool': Color(0xFFC8102E),
    'manchester_united': Color(0xFFDA020E),
    'manchester_city': Color(0xFF6CABDD),
    'tottenham': Color(0xFF132257),
    'barcelona': Color(0xFFA50044),
    'real_madrid': Color(0xFFFBBE00),
    'bayern_munich': Color(0xFFDC052D),
    'juventus': Color(0xFF000000),
    'default': Color(0xFF6B7280),
  };
  
  // Gradient Colors
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [secondary, secondaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient accentGradient = LinearGradient(
    colors: [accent, accentLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient winGradient = LinearGradient(
    colors: [win, Color(0xFF34D399)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient drawGradient = LinearGradient(
    colors: [draw, Color(0xFFFBBF24)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient lossGradient = LinearGradient(
    colors: [loss, Color(0xFFF87171)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient liveGradient = LinearGradient(
    colors: [live, livePulse],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient darkGradient = LinearGradient(
    colors: [darkBackground, darkSurface],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
  
  // Shadow Colors
  static const List<BoxShadow> cardShadow = [
    BoxShadow(
      color: cardShadow,
      blurRadius: 10,
      offset: Offset(0, 4),
    ),
  ];
  
  static const List<BoxShadow> elevatedCardShadow = [
    BoxShadow(
      color: elevatedCardShadow,
      blurRadius: 20,
      offset: Offset(0, 8),
    ),
  ];
  
  static const List<BoxShadow> heroShadow = [
    BoxShadow(
      color: Color(0x1A000000),
      blurRadius: 30,
      offset: Offset(0, 12),
    ),
  ];
  
  // Opacity Levels
  static const double opacityHigh = 0.87;
  static const double opacityMedium = 0.60;
  static const double opacityLow = 0.38;
  static const double opacityDisabled = 0.12;
  
  // Helper Methods
  static Color getTeamColor(String teamName) {
    final key = teamName.toLowerCase().replaceAll(' ', '_');
    return teamColors[key] ?? teamColors['default']!;
  }
  
  static Color getFormColor(String result) {
    switch (result.toLowerCase()) {
      case 'w':
      case 'win':
        return formWin;
      case 'd':
      case 'draw':
        return formDraw;
      case 'l':
      case 'loss':
        return formLoss;
      default:
        return statisticsNeutral;
    }
  }
  
  static Color getPositionColor(int position, int totalTeams) {
    if (position <= 4) return champions;
    if (position <= 6) return europaLeague;
    if (position <= 7) return conferenceLeague;
    if (position > totalTeams - 3) return relegation;
    return statisticsNeutral;
  }
}