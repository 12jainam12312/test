/// 🎨 **CENTRALIZED APP THEME & COLOR SCHEME**
/// 
/// 🎯 **Purpose**: Single source of truth for all app colors, themes, and styling
/// 🏗️ **Architecture**: Shared Layer - Theme configuration
/// 🔗 **Dependencies**: Flutter Material Theme
/// 📝 **Usage**: Import this file to access all theme colors and configurations
/// 
/// 📅 **Created**: 2025
/// 👤 **Team**: Luna Development Team
/// 
/// 🌟 **How to Change Color Scheme**:
/// 1. Modify the color values in LunaColorScheme class below
/// 2. All app colors will automatically update throughout the app
/// 3. No need to change colors in individual files

import 'package:flutter/material.dart';

/// 🎨 **Luna Color Scheme**
/// 
/// Central definition of all colors used in the app.
/// Change these values to instantly update the entire app's color scheme.
class LunaColorScheme {
  
  // 🌟 **PRIMARY BRAND COLORS**
  /// Main brand color - used for primary actions, highlights, and branding
  static const Color primaryGreen = Color(0xFF9AFF00);  // Neon green
  
  /// Secondary brand color - used for accents and secondary actions
  static const Color secondaryGreen = Color(0xFF7CB342); // Darker green
  
  /// Tertiary brand color - used for subtle highlights
  static const Color tertiaryGreen = Color(0xFF4CAF50);  // Material green
  
  // 🌙 **DARK THEME COLORS**
  /// Dark theme background colors
  static const Color darkBackground = Color(0xFF0A0A0A);    // Almost black
  static const Color darkSurface = Color(0xFF1A1A1A);      // Dark gray
  static const Color darkCard = Color(0xFF252525);         // Card background
  static const Color darkBorder = Color(0xFF3A3A3A);       // Border color
  
  /// Dark theme text colors
  static const Color darkTextPrimary = Color(0xFFFFFFFF);   // White text
  static const Color darkTextSecondary = Color(0xFF888888); // Gray text
  static const Color darkTextTertiary = Color(0xFF666666);  // Darker gray text
  
  // ☀️ **LIGHT THEME COLORS**   
/// Light theme background colors   
static const Color lightBackground = Color(0xFFFFFFFF);   // #FFFFFF   
static const Color lightSurface = Color(0xFFFFFFFF);      // #FFFFFF   
static const Color lightCard = Color(0xFFFFFFFF);         // #FFFFFF   
static const Color lightBorder = Color(0xFFD4D4D4);       // #D4D4D4      

/// Light theme text colors   
static const Color lightTextPrimary = Color(0xFF2B2B2B);   // #2B2B2B   
static const Color lightTextSecondary = Color(0xFFB3B3B3); // #B3B3B3   
static const Color lightTextTertiary = Color(0xFFD4D4D4);  // #D4D4D4
  
  // 🚨 **STATUS & FEEDBACK COLORS**
  /// Success states
  static const Color successGreen = Color(0xFF4CAF50);
  static const Color successLight = Color(0xFFE8F5E8);
  
  /// Error states
  static const Color errorRed = Color(0xFFE53E3E);
  static const Color errorLight = Color(0xFFFFEBEE);
  
  /// Warning states
  static const Color warningOrange = Color(0xFFFF8F00);
  static const Color warningLight = Color(0xFFFFF3E0);
  
  /// Info states
  static const Color infoBlue = Color(0xFF2196F3);
  static const Color infoLight = Color(0xFFE3F2FD);
  
  // 🎯 **SPECIAL PURPOSE COLORS**
  /// Emergency and urgent states
  static const Color emergencyRed = Color(0xFFD32F2F);
  
  /// Transparent overlays
  static const Color overlay = Color(0x80000000);          // 50% black
  static const Color lightOverlay = Color(0x40000000);     // 25% black
  
  /// Gradient colors for backgrounds
  static const List<Color> darkGradient = [
    Color(0xFF0A0A0A),
    Color(0xFF1A1A1A),
    Color(0xFF0A0A0A),
  ];
  
  static const List<Color> lightGradient = [
    Color(0xFFFAFAFA),
    Color(0xFFF0F0F0),
    Color(0xFFFAFAFA),
  ];
}

/// 🎨 **Luna App Theme**
/// 
/// Main theme class that provides complete theme data for the app.
/// Uses LunaColorScheme for all color definitions.
class LunaAppTheme {
  
  // 🌙 **DARK THEME**
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: LunaColorScheme.primaryGreen,
      scaffoldBackgroundColor: LunaColorScheme.darkBackground,
      cardColor: LunaColorScheme.darkCard,
      
      // Color scheme
      colorScheme: ColorScheme.dark(
        primary: LunaColorScheme.primaryGreen,
        secondary: LunaColorScheme.secondaryGreen,
        surface: LunaColorScheme.darkSurface,
        background: LunaColorScheme.darkBackground,
        error: LunaColorScheme.errorRed,
        onPrimary: LunaColorScheme.darkBackground,
        onSecondary: LunaColorScheme.darkBackground,
        onSurface: LunaColorScheme.darkTextPrimary,
        onBackground: LunaColorScheme.darkTextPrimary,
        onError: Colors.white,
      ),
      
      // App bar theme
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: LunaColorScheme.darkTextPrimary,
        iconTheme: IconThemeData(color: LunaColorScheme.primaryGreen),
        titleTextStyle: TextStyle(
          color: LunaColorScheme.primaryGreen,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      
      // Card theme
      cardTheme: CardThemeData(
        color: LunaColorScheme.darkCard,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      
      // Elevated button theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: LunaColorScheme.primaryGreen,
          foregroundColor: LunaColorScheme.darkBackground,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      
      // Input decoration theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: LunaColorScheme.darkSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: LunaColorScheme.darkBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: LunaColorScheme.darkBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: LunaColorScheme.primaryGreen, width: 2),
        ),
      ),
    );
  }
  
  // ☀️ **LIGHT THEME**
static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: Color(0xFF2B2B2B), // Changed to dark gray
      scaffoldBackgroundColor: LunaColorScheme.lightBackground,
      cardColor: LunaColorScheme.lightCard,
      
      // Color scheme
      colorScheme: ColorScheme.light(
        primary: Color(0xFF2B2B2B), // Changed to dark gray
        secondary: Color(0xFFB3B3B3), // Changed to medium gray
        surface: LunaColorScheme.lightSurface,
        background: LunaColorScheme.lightBackground,
        error: LunaColorScheme.errorRed,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: LunaColorScheme.lightTextPrimary,
        onBackground: LunaColorScheme.lightTextPrimary,
        onError: Colors.white,
      ),
      
      // App bar theme
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: LunaColorScheme.lightTextPrimary,
        iconTheme: IconThemeData(color: Color(0xFF2B2B2B)), // Changed to dark gray
        titleTextStyle: TextStyle(
          color: Color(0xFF2B2B2B), // Changed to dark gray
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      
      // Card theme
      cardTheme: CardThemeData(
        color: LunaColorScheme.lightCard,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      
      // Elevated button theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFF2B2B2B), // Changed to dark gray
          foregroundColor: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      
      // Input decoration theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: LunaColorScheme.lightSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: LunaColorScheme.lightBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: LunaColorScheme.lightBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Color(0xFF2B2B2B), width: 2), // Changed to dark gray
        ),
      ),
    );
  }
}

/// 🎨 **Theme-Specific Color Sets**
/// 
/// Organized color sets for easy access in widgets
class LunaColors {
  final Color primary;
  final Color secondary;
  final Color tertiary;
  final Color background;
  final Color surface;
  final Color card;
  final Color border;
  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;
  final List<Color> gradient;
  
  const LunaColors({
    required this.primary,
    required this.secondary,
    required this.tertiary,
    required this.background,
    required this.surface,
    required this.card,
    required this.border,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.gradient,
  });
  
  /// Dark theme colors
  static const LunaColors dark = LunaColors(
    primary: LunaColorScheme.primaryGreen,
    secondary: LunaColorScheme.secondaryGreen,
    tertiary: LunaColorScheme.tertiaryGreen,
    background: LunaColorScheme.darkBackground,
    surface: LunaColorScheme.darkSurface,
    card: LunaColorScheme.darkCard,
    border: LunaColorScheme.darkBorder,
    textPrimary: LunaColorScheme.darkTextPrimary,
    textSecondary: LunaColorScheme.darkTextSecondary,
    textTertiary: LunaColorScheme.darkTextTertiary,
    gradient: LunaColorScheme.darkGradient,
  );
  
  /// Light theme colors
  static const LunaColors light = LunaColors(
    primary: Color(0xFF2B2B2B),     // #2B2B2B
    secondary: Color(0xFFB3B3B3),   // #B3B3B3
    tertiary: Color(0xFFD4D4D4),    // #D4D4D4
    background: LunaColorScheme.lightBackground,
    surface: LunaColorScheme.lightSurface,
    card: LunaColorScheme.lightCard,
    border: LunaColorScheme.lightBorder,
    textPrimary: LunaColorScheme.lightTextPrimary,
    textSecondary: LunaColorScheme.lightTextSecondary,
    textTertiary: LunaColorScheme.lightTextTertiary,
    gradient: LunaColorScheme.lightGradient,
  );
}

/// 🎨 **Status Colors**
/// 
/// Colors for different states and feedback
class LunaStatusColors {
  static const Color success = LunaColorScheme.successGreen;
  static const Color successLight = LunaColorScheme.successLight;
  
  static const Color error = LunaColorScheme.errorRed;
  static const Color errorLight = LunaColorScheme.errorLight;
  
  static const Color warning = LunaColorScheme.warningOrange;
  static const Color warningLight = LunaColorScheme.warningLight;
  
  static const Color info = LunaColorScheme.infoBlue;
  static const Color infoLight = LunaColorScheme.infoLight;
  
  static const Color emergency = LunaColorScheme.emergencyRed;
}

/// 📏 **Theme Constants**
/// 
/// Consistent spacing, sizing, and other design constants
class LunaThemeConstants {
  // Spacing
  static const double spacingXS = 4.0;
  static const double spacingS = 8.0;
  static const double spacingM = 16.0;
  static const double spacingL = 24.0;
  static const double spacingXL = 32.0;
  static const double spacingXXL = 48.0;
  
  // Border radius
  static const double radiusS = 8.0;
  static const double radiusM = 12.0;
  static const double radiusL = 16.0;
  static const double radiusXL = 20.0;
  static const double radiusRound = 50.0;
  
  // Elevation
  static const double elevationS = 2.0;
  static const double elevationM = 4.0;
  static const double elevationL = 8.0;
  static const double elevationXL = 12.0;
  
  // Icon sizes
  static const double iconS = 16.0;
  static const double iconM = 24.0;
  static const double iconL = 32.0;
  static const double iconXL = 48.0;
  
  // Avatar sizes
  static const double avatarS = 32.0;
  static const double avatarM = 40.0;
  static const double avatarL = 56.0;
  static const double avatarXL = 80.0;
}

class BackgroundAnimate{
static const Color lightBackgroundStart = Color(0xFFFAFAFA);
static const Color lightBackgroundMid = Color(0xFFF0F0F0);
static const Color darkBackgroundStart = Color(0xFF0A0A0A);
static const Color darkBackgroundMid = Color(0xFF1A1A1A);

} 
