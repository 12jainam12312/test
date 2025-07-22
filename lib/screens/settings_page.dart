import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/animated_card.dart';
import '../widgets/animated_button.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return Scaffold(
      backgroundColor: themeProvider.backgroundColor,
      appBar: AppBar(
        backgroundColor: themeProvider.surfaceColor,
        title: Text(
          'Settings',
          style: TextStyle(color: themeProvider.primaryColor),
        ),
        centerTitle: true,
        elevation: 0,
        iconTheme: IconThemeData(color: themeProvider.primaryColor),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            const SizedBox(height: 20),

            // Theme Section
            _sectionLabel('Theme', themeProvider),
            AnimatedCard(
              child: SwitchListTile(
                activeColor: themeProvider.primaryColor,
                inactiveTrackColor: themeProvider.secondaryTextColor.withOpacity(0.3),
                value: themeProvider.isDarkMode,
                onChanged: (_) => themeProvider.toggleTheme(),
                title: Text(
                  'Dark Mode',
                  style: TextStyle(color: themeProvider.textColor),
                ),
                subtitle: Text(
                  'Toggle between light and dark themes',
                  style: TextStyle(color: themeProvider.secondaryTextColor),
                ),
              ),
            ),
            const SizedBox(height: 30),

            // Notifications Section
            _sectionLabel('Notifications', themeProvider),
            _switchTile('Enable reminders', themeProvider),
            _switchTile('Daily health tips', themeProvider),
            const SizedBox(height: 30),

            // Appearance Section
            _sectionLabel('Appearance', themeProvider),
            _fakeDropDownTile(context, 'Accent Color', 'Primary Green', themeProvider),
            const SizedBox(height: 30),

            // Account Section
            _sectionLabel('Account', themeProvider),
            _standardTile('Privacy Settings', themeProvider),
            _standardTile('Delete Account', themeProvider),
            const SizedBox(height: 30),

            // App Info Section
            _sectionLabel('About App', themeProvider),
            _standardTile('Terms of Service', themeProvider),
            _standardTile('Privacy Policy', themeProvider),
            _standardTile('Version 1.0.0', themeProvider),
          ],
        ),
      ),
    );
  }

  // Section label
  Widget _sectionLabel(String label, ThemeProvider themeProvider) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        label,
        style: TextStyle(
          color: themeProvider.secondaryTextColor,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // Standard tappable tile
  Widget _standardTile(String title, ThemeProvider themeProvider) {
    return AnimatedCard(
      child: ListTile(
        title: Text(title, style: TextStyle(color: themeProvider.textColor)),
        trailing: Icon(Icons.chevron_right, color: themeProvider.primaryColor),
        onTap: () {
          // You can add routing or snackbars here
        },
      ),
    );
  }

  // Switch tile
  Widget _switchTile(String title, ThemeProvider themeProvider, {bool initialValue = false}) {
    return AnimatedCard(
      child: SwitchListTile(
        activeColor: themeProvider.primaryColor,
        inactiveTrackColor: themeProvider.secondaryTextColor.withOpacity(0.3),
        value: initialValue,
        onChanged: (_) {},
        title: Text(title, style: TextStyle(color: themeProvider.textColor)),
      ),
    );
  }

  // Fake dropdown tile for demo (non-functional)
  Widget _fakeDropDownTile(BuildContext context, title, String value, ThemeProvider themeProvider) {
    return AnimatedCard(
      child: ListTile(
        title: Text(
          value,
          style: TextStyle(color: themeProvider.primaryColor),
        ),
        subtitle: Text(
          title,
          style: TextStyle(color: themeProvider.secondaryTextColor, fontSize: 12),
        ),
        trailing: Icon(Icons.arrow_drop_down, color: themeProvider.primaryColor),
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('This is a demo. Options are not changeable yet.'),
              backgroundColor: Colors.black87,
            ),
          );
        },
      ),
    );
  }
}
