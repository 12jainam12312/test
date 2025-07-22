import 'package:flutter/material.dart';

class AppColors {
  // Primary palette - Healing & Trust
  static const Color primaryGreen = Color(0xFF2E7D4F); // Deep forest green
  static const Color secondaryGreen = Color(0xFF4CAF50); // Vibrant green
  static const Color lightGreen = Color(0xFFE8F5E8); // Very light green
  
  // Emergency & Alert colors
  static const Color emergencyRed = Color(0xFFD32F2F); // Deep red
  static const Color warningAmber = Color(0xFFFF8F00); // Warm amber
  static const Color emergencyLight = Color(0xFFFFEBEE); // Light red background
  
  // Natural & Calming
  static const Color earthBrown = Color(0xFF8D6E63); // Warm earth tone
  static const Color creamWhite = Color(0xFFFFFBF0); // Warm white
  static const Color softBeige = Color(0xFFF5F5DC); // Gentle beige
  
  // Text colors
  static const Color textPrimary = Color(0xFF1B1B1B); // Almost black
  static const Color textSecondary = Color(0xFF666666); // Medium gray
  static const Color textLight = Color(0xFF999999); // Light gray
  
  // Background gradients
  static const List<Color> backgroundGradient = [
    Color(0xFFE8F5E8), // Light green
    Color(0xFFFFFBF0), // Cream white
  ];
  
  // Chat bubble colors
  static const Color userBubble = Color(0xFF2E7D4F); // Primary green
  static const Color botBubble = Color(0xFFFFFFFF); // White
  static const Color botBubbleBorder = Color(0xFFE0E0E0); // Light gray border
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      primarySwatch: Colors.green,
      primaryColor: AppColors.primaryGreen,
      scaffoldBackgroundColor: AppColors.creamWhite,
      fontFamily: 'Inter', // Add Inter font to pubspec.yaml
      
      // AppBar theme
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primaryGreen,
        elevation: 0,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      
      // Elevated button theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryGreen,
          foregroundColor: Colors.white,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      
      // Input decoration theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.lightGreen),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.lightGreen),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.primaryGreen, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      
      // Card theme
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        color: Colors.white,
      ),
    );
  }
}