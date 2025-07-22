import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:medical/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/animated_card.dart';
import '../widgets/animated_button.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  File? _profileImage;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    final authService = AuthService();

    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return Scaffold(
      backgroundColor: themeProvider.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: themeProvider.textColor),
        centerTitle: true,
        title: Text(
          l10n.profile,
          style: TextStyle(
            color: themeProvider.primaryColor,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          AnimatedCard(
            padding: EdgeInsets.zero,
            borderRadius: BorderRadius.circular(60),
            onTap: _pickImage,
            child: CircleAvatar(
              radius: 60,
              backgroundColor: themeProvider.cardColor,
              backgroundImage: _profileImage != null
                  ? FileImage(_profileImage!)
                  : null,
              child: _profileImage == null
                  ? Icon(
                      Icons.camera_alt, 
                      size: 40, 
                      color: themeProvider.secondaryTextColor,
                    )
                  : null,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            FirebaseAuth.instance.currentUser?.displayName ?? 'User',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: themeProvider.primaryColor,
            ),
          ),
          const SizedBox(height: 30),
          Divider(color: themeProvider.secondaryTextColor.withOpacity(0.3), thickness: 1),
          const SizedBox(height: 10),
          _buildInfoTile(Icons.email, l10n.email, 'haileyjons@example.com', themeProvider),
          _buildInfoTile(Icons.phone, l10n.phone, '+91 98765 43210', themeProvider),
          _buildInfoTile(Icons.location_on, l10n.location, 'Ronbinsville, New Jersey', themeProvider),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
            child: Row(
              children: [
                Expanded(
                  child: AnimatedButton(
                    text: l10n.edit,
                    icon: Icons.edit,
                    onPressed: () {
                      // Edit profile
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: AnimatedButton(
                    text: l10n.logout,
                    icon: Icons.logout,
                    onPressed: () {
                      // Logout
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile(IconData icon, String title, String subtitle, ThemeProvider themeProvider) {
    return AnimatedCard(
      child: ListTile(
        leading: Icon(icon, color: themeProvider.primaryColor),
        title: Text(
          title,
          style: TextStyle(
            color: themeProvider.primaryColor,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(color: themeProvider.secondaryTextColor),
        ),
      ),
    );
  }
}