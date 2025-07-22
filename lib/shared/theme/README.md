# 🎨 Theme System Documentation

## 📖 Overview
This directory contains the centralized theme system for the Luna app. All colors, styling, and theme-related configurations are managed here.

## 🗂️ File Structure

### `app_theme.dart` - Main Theme File
**This is your one-stop shop for changing the app's color scheme!**

Contains:
- `LunaColorScheme` - All color definitions
- `LunaAppTheme` - Complete theme configurations
- `LunaColors` - Organized color sets for easy access
- `LunaStatusColors` - Status and feedback colors
- `LunaThemeConstants` - Spacing, sizing, and design constants

## 🎯 How to Change Color Scheme

### Quick Color Change
1. Open `medical/lib/shared/theme/app_theme.dart`
2. Modify colors in the `LunaColorScheme` class
3. Save the file - all app colors update automatically!

### Example: Changing Primary Color
```dart
// In LunaColorScheme class
static const Color primaryGreen = Color(0xFF9AFF00);  // Current
static const Color primaryGreen = Color(0xFF6366F1);  // Change to purple
```

### Example: Changing Dark Theme Background
```dart
// In LunaColorScheme class
static const Color darkBackground = Color(0xFF0A0A0A);  // Current
static const Color darkBackground = Color(0xFF1F2937);  // Change to blue-gray
```

## 🎨 Color Categories

### Brand Colors
- `primaryGreen` - Main brand color
- `secondaryGreen` - Secondary brand color  
- `tertiaryGreen` - Tertiary brand color

### Background Colors
- `darkBackground`, `lightBackground` - Main backgrounds
- `darkSurface`, `lightSurface` - Surface backgrounds
- `darkCard`, `lightCard` - Card backgrounds

### Text Colors
- `darkTextPrimary`, `lightTextPrimary` - Main text
- `darkTextSecondary`, `lightTextSecondary` - Secondary text
- `darkTextTertiary`, `lightTextTertiary` - Tertiary text

### Status Colors
- `successGreen` - Success states
- `errorRed` - Error states
- `warningOrange` - Warning states
- `infoBlue` - Info states
- `emergencyRed` - Emergency states

## 🔧 Usage in Widgets

### Method 1: Using LunaTheme Helper
```dart
Widget build(BuildContext context) {
  final colors = LunaTheme.of(context);
  
  return Container(
    color: colors.background,
    child: Text(
      'Hello',
      style: TextStyle(color: colors.textPrimary),
    ),
  );
}
```

### Method 2: Using Theme Provider
```dart
Widget build(BuildContext context) {
  final themeProvider = Provider.of<ThemeProvider>(context);
  
  return Container(
    color: themeProvider.backgroundColor,
    child: Text(
      'Hello',
      style: TextStyle(color: themeProvider.textColor),
    ),
  );
}
```

### Method 3: Direct Access
```dart
Widget build(BuildContext context) {
  return Container(
    color: LunaColorScheme.primaryGreen,
    child: Text(
      'Hello',
      style: TextStyle(color: LunaColorScheme.darkTextPrimary),
    ),
  );
}
```

## 🎯 Best Practices

### ✅ Do:
- Always use colors from `LunaColorScheme`
- Use `LunaTheme.of(context)` for theme-aware colors
- Use `LunaThemeConstants` for consistent spacing
- Document any new colors you add

### ❌ Don't:
- Hardcode colors in individual widgets
- Use `Colors.red` or other Material colors directly
- Create new color variables outside the theme system

## 🚀 Popular Color Schemes

### Scheme 1: Purple & Blue
```dart
static const Color primaryGreen = Color(0xFF6366F1);    // Purple
static const Color secondaryGreen = Color(0xFF3B82F6);  // Blue
static const Color tertiaryGreen = Color(0xFF8B5CF6);   // Light purple
```

### Scheme 2: Orange & Red
```dart
static const Color primaryGreen = Color(0xFFEF4444);    // Red
static const Color secondaryGreen = Color(0xFFF97316);  // Orange
static const Color tertiaryGreen = Color(0xFFEC4899);   // Pink
```

### Scheme 3: Teal & Cyan
```dart
static const Color primaryGreen = Color(0xFF14B8A6);    // Teal
static const Color secondaryGreen = Color(0xFF06B6D4);  // Cyan
static const Color tertiaryGreen = Color(0xFF10B981);   // Emerald
```

## 🔄 Migration Notes

All existing hardcoded colors have been moved to this centralized system. The `ThemeProvider` now uses `LunaAppTheme` instead of custom theme data.

## 🆘 Need Help?

If you want to change the color scheme but aren't sure which colors to modify, just:
1. Look at the color categories above
2. Find the color that matches what you want to change
3. Update the hex value in `LunaColorScheme`
4. Save and see the changes instantly!