import 'package:flutter/material.dart';

/// Comprehensive design system for the Football Stats application
/// Following Material Design 3 principles with football-specific customizations
class AppDesignSystem {
  // Spacing System (Based on 8px grid)
  static const double spacing4 = 4.0;
  static const double spacing8 = 8.0;
  static const double spacing12 = 12.0;
  static const double spacing16 = 16.0;
  static const double spacing20 = 20.0;
  static const double spacing24 = 24.0;
  static const double spacing32 = 32.0;
  static const double spacing40 = 40.0;
  static const double spacing48 = 48.0;
  static const double spacing56 = 56.0;
  static const double spacing64 = 64.0;
  static const double spacing72 = 72.0;
  static const double spacing80 = 80.0;
  
  // Border Radius System
  static const double radiusXSmall = 4.0;
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;
  static const double radiusXLarge = 20.0;
  static const double radiusXXLarge = 24.0;
  static const double radiusCircular = 100.0;
  
  // Icon Sizes
  static const double iconXSmall = 16.0;
  static const double iconSmall = 20.0;
  static const double iconMedium = 24.0;
  static const double iconLarge = 32.0;
  static const double iconXLarge = 40.0;
  static const double iconXXLarge = 48.0;
  static const double iconHero = 64.0;
  
  // Avatar Sizes
  static const double avatarSmall = 32.0;
  static const double avatarMedium = 40.0;
  static const double avatarLarge = 56.0;
  static const double avatarXLarge = 72.0;
  static const double avatarHero = 96.0;
  
  // Button Sizes
  static const double buttonHeightSmall = 32.0;
  static const double buttonHeightMedium = 40.0;
  static const double buttonHeightLarge = 48.0;
  static const double buttonHeightXLarge = 56.0;
  
  // Card Specifications
  static const double cardMinHeight = 120.0;
  static const double cardMaxWidth = 400.0;
  static const double cardElevation = 2.0;
  static const double cardElevationHover = 4.0;
  static const double cardElevationPressed = 1.0;
  
  // Elevation System
  static const double elevation0 = 0.0;
  static const double elevation1 = 1.0;
  static const double elevation2 = 2.0;
  static const double elevation3 = 3.0;
  static const double elevation4 = 4.0;
  static const double elevation6 = 6.0;
  static const double elevation8 = 8.0;
  static const double elevation12 = 12.0;
  static const double elevation16 = 16.0;
  static const double elevation24 = 24.0;
  
  // Animation Durations
  static const Duration animationFast = Duration(milliseconds: 150);
  static const Duration animationNormal = Duration(milliseconds: 300);
  static const Duration animationSlow = Duration(milliseconds: 500);
  static const Duration animationXSlow = Duration(milliseconds: 800);
  
  // Animation Curves
  static const Curve curveStandard = Curves.easeInOut;
  static const Curve curveAccelerate = Curves.easeIn;
  static const Curve curveDecelerate = Curves.easeOut;
  static const Curve curveEmphasized = Curves.easeInOutCubic;
  
  // Football-specific Dimensions
  static const double teamLogoSize = 32.0;
  static const double teamLogoLarge = 48.0;
  static const double teamLogoHero = 64.0;
  
  static const double matchCardHeight = 120.0;
  static const double matchCardCompactHeight = 80.0;
  static const double teamCardHeight = 140.0;
  static const double playerCardHeight = 160.0;
  
  static const double statisticsBarHeight = 8.0;
  static const double statisticsBarRadius = 4.0;
  
  static const double formIndicatorSize = 24.0;
  static const double formIndicatorSmall = 16.0;
  
  // Live Match Indicator
  static const double liveIndicatorSize = 8.0;
  static const double liveIndicatorPulseScale = 1.5;
  
  // Responsive Breakpoints
  static const double mobileBreakpoint = 480.0;
  static const double tabletBreakpoint = 768.0;
  static const double desktopBreakpoint = 1024.0;
  static const double largeDesktopBreakpoint = 1440.0;
  
  // Grid System
  static const int gridColumnsSmall = 1;
  static const int gridColumnsMedium = 2;
  static const int gridColumnsLarge = 3;
  static const int gridColumnsXLarge = 4;
  
  // Layout Constraints
  static const double maxContentWidth = 1200.0;
  static const double sidebarWidth = 280.0;
  static const double sidebarCollapsedWidth = 72.0;
  
  // Common EdgeInsets
  static const EdgeInsets paddingAll4 = EdgeInsets.all(spacing4);
  static const EdgeInsets paddingAll8 = EdgeInsets.all(spacing8);
  static const EdgeInsets paddingAll12 = EdgeInsets.all(spacing12);
  static const EdgeInsets paddingAll16 = EdgeInsets.all(spacing16);
  static const EdgeInsets paddingAll20 = EdgeInsets.all(spacing20);
  static const EdgeInsets paddingAll24 = EdgeInsets.all(spacing24);
  static const EdgeInsets paddingAll32 = EdgeInsets.all(spacing32);
  
  static const EdgeInsets paddingHorizontal8 = EdgeInsets.symmetric(horizontal: spacing8);
  static const EdgeInsets paddingHorizontal12 = EdgeInsets.symmetric(horizontal: spacing12);
  static const EdgeInsets paddingHorizontal16 = EdgeInsets.symmetric(horizontal: spacing16);
  static const EdgeInsets paddingHorizontal20 = EdgeInsets.symmetric(horizontal: spacing20);
  static const EdgeInsets paddingHorizontal24 = EdgeInsets.symmetric(horizontal: spacing24);
  
  static const EdgeInsets paddingVertical8 = EdgeInsets.symmetric(vertical: spacing8);
  static const EdgeInsets paddingVertical12 = EdgeInsets.symmetric(vertical: spacing12);
  static const EdgeInsets paddingVertical16 = EdgeInsets.symmetric(vertical: spacing16);
  static const EdgeInsets paddingVertical20 = EdgeInsets.symmetric(vertical: spacing20);
  static const EdgeInsets paddingVertical24 = EdgeInsets.symmetric(vertical: spacing24);
  
  // Common Border Radius
  static const BorderRadius borderRadiusSmall = BorderRadius.all(Radius.circular(radiusSmall));
  static const BorderRadius borderRadiusMedium = BorderRadius.all(Radius.circular(radiusMedium));
  static const BorderRadius borderRadiusLarge = BorderRadius.all(Radius.circular(radiusLarge));
  static const BorderRadius borderRadiusXLarge = BorderRadius.all(Radius.circular(radiusXLarge));
  
  // Card Border Radius
  static const BorderRadius cardBorderRadius = BorderRadius.all(Radius.circular(radiusMedium));
  static const BorderRadius heroCardBorderRadius = BorderRadius.all(Radius.circular(radiusLarge));
  
  // Button Border Radius
  static const BorderRadius buttonBorderRadius = BorderRadius.all(Radius.circular(radiusSmall));
  static const BorderRadius fabBorderRadius = BorderRadius.all(Radius.circular(radiusLarge));
  
  // Common SizedBox
  static const SizedBox gap4 = SizedBox(width: spacing4, height: spacing4);
  static const SizedBox gap8 = SizedBox(width: spacing8, height: spacing8);
  static const SizedBox gap12 = SizedBox(width: spacing12, height: spacing12);
  static const SizedBox gap16 = SizedBox(width: spacing16, height: spacing16);
  static const SizedBox gap20 = SizedBox(width: spacing20, height: spacing20);
  static const SizedBox gap24 = SizedBox(width: spacing24, height: spacing24);
  static const SizedBox gap32 = SizedBox(width: spacing32, height: spacing32);
  
  static const SizedBox gapHorizontal4 = SizedBox(width: spacing4);
  static const SizedBox gapHorizontal8 = SizedBox(width: spacing8);
  static const SizedBox gapHorizontal12 = SizedBox(width: spacing12);
  static const SizedBox gapHorizontal16 = SizedBox(width: spacing16);
  static const SizedBox gapHorizontal20 = SizedBox(width: spacing20);
  static const SizedBox gapHorizontal24 = SizedBox(width: spacing24);
  
  static const SizedBox gapVertical4 = SizedBox(height: spacing4);
  static const SizedBox gapVertical8 = SizedBox(height: spacing8);
  static const SizedBox gapVertical12 = SizedBox(height: spacing12);
  static const SizedBox gapVertical16 = SizedBox(height: spacing16);
  static const SizedBox gapVertical20 = SizedBox(height: spacing20);
  static const SizedBox gapVertical24 = SizedBox(height: spacing24);
  static const SizedBox gapVertical32 = SizedBox(height: spacing32);
  
  // Responsive Helper Methods
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < mobileBreakpoint;
  }
  
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= mobileBreakpoint && width < desktopBreakpoint;
  }
  
  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= desktopBreakpoint;
  }
  
  static bool isLargeDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= largeDesktopBreakpoint;
  }
  
  static int getGridColumns(BuildContext context) {
    if (isLargeDesktop(context)) return gridColumnsXLarge;
    if (isDesktop(context)) return gridColumnsLarge;
    if (isTablet(context)) return gridColumnsMedium;
    return gridColumnsSmall;
  }
  
  static double getHorizontalPadding(BuildContext context) {
    if (isDesktop(context)) return spacing32;
    if (isTablet(context)) return spacing24;
    return spacing16;
  }
  
  // Common Decorations
  static BoxDecoration get cardDecoration => BoxDecoration(
    borderRadius: cardBorderRadius,
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.08),
        blurRadius: 8,
        offset: const Offset(0, 2),
      ),
    ],
  );
  
  static BoxDecoration get elevatedCardDecoration => BoxDecoration(
    borderRadius: heroCardBorderRadius,
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.12),
        blurRadius: 16,
        offset: const Offset(0, 4),
      ),
    ],
  );
  
  static BoxDecoration liveIndicatorDecoration(Color color) => BoxDecoration(
    shape: BoxShape.circle,
    color: color,
    boxShadow: [
      BoxShadow(
        color: color.withOpacity(0.4),
        blurRadius: 8,
        spreadRadius: 2,
      ),
    ],
  );
  
  static BoxDecoration statisticsBarDecoration(Color color) => BoxDecoration(
    color: color,
    borderRadius: BorderRadius.circular(statisticsBarRadius),
  );
  
  // Text Styles Extensions (Football-specific)
  static TextStyle get scoreLarge => const TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
  );
  
  static TextStyle get scoreMedium => const TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.25,
  );
  
  static TextStyle get teamName => const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
  );
  
  static TextStyle get teamNameSmall => const TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
  );
  
  static TextStyle get matchTime => const TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
  );
  
  static TextStyle get statLabel => const TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.25,
  );
  
  static TextStyle get statValue => const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.1,
  );
  
  // Button Styles
  static ButtonStyle get primaryButtonStyle => ElevatedButton.styleFrom(
    elevation: elevation2,
    padding: paddingHorizontal24.add(paddingVertical12),
    shape: const RoundedRectangleBorder(
      borderRadius: buttonBorderRadius,
    ),
  );
  
  static ButtonStyle get secondaryButtonStyle => OutlinedButton.styleFrom(
    padding: paddingHorizontal24.add(paddingVertical12),
    shape: const RoundedRectangleBorder(
      borderRadius: buttonBorderRadius,
    ),
  );
  
  static ButtonStyle get textButtonStyle => TextButton.styleFrom(
    padding: paddingHorizontal16.add(paddingVertical8),
    shape: const RoundedRectangleBorder(
      borderRadius: buttonBorderRadius,
    ),
  );
  
  // Input Decoration
  static InputDecoration getInputDecoration({
    required String labelText,
    String? hintText,
    Widget? prefixIcon,
    Widget? suffixIcon,
  }) => InputDecoration(
    labelText: labelText,
    hintText: hintText,
    prefixIcon: prefixIcon,
    suffixIcon: suffixIcon,
    border: OutlineInputBorder(
      borderRadius: borderRadiusSmall,
    ),
    contentPadding: paddingHorizontal16.add(paddingVertical12),
  );
}