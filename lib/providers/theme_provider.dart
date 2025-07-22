import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../shared/theme/app_theme.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = true;
  late AnimationController _themeAnimationController;

  bool get isDarkMode => _isDarkMode;
  AnimationController get themeAnimationController => _themeAnimationController;

  void setAnimationController(AnimationController controller) {
    _themeAnimationController = controller;
  }

  Future<void> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('isDarkMode') ?? true;
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', _isDarkMode);
    
    // Trigger theme transition animation
    _themeAnimationController.forward().then((_) {
      _themeAnimationController.reverse();
    });
    
    notifyListeners();
  }

  // Get current theme colors from centralized theme
  LunaColors get colors => _isDarkMode ? LunaColors.dark : LunaColors.light;
  
  // Convenient getters for commonly used colors
  Color get primaryColor => colors.primary;
  Color get backgroundColor => colors.background;
  Color get surfaceColor => colors.surface;
  Color get cardColor => colors.card;
  Color get textColor => colors.textPrimary;
  Color get secondaryTextColor => colors.textSecondary;

  ThemeData get themeData {
    return _isDarkMode ? LunaAppTheme.darkTheme : LunaAppTheme.lightTheme;
  }
}