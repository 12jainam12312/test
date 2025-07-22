import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../models/user_model.dart';
import '../widgets/animated_card.dart';
import '../widgets/animated_button.dart';
import 'signup_screen.dart';

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  UserRole? selectedRole;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  void _selectRole(UserRole role) {
    setState(() {
      selectedRole = role;
    });
  }

  void _continueToSignup() {
    if (selectedRole != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SignUpScreen(selectedRole: selectedRole!),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return Scaffold(
      backgroundColor: themeProvider.backgroundColor,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                const SizedBox(height: 40),
                
                // Logo and Title
                Image.asset(
                  'assets/Luna.png',
                  width: 80,
                  height: 80,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 32),
                
                Text(
                  "Join Luna",
                  style: TextStyle(
                    color: themeProvider.primaryColor,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                
                Text(
                  "Choose your role to get started",
                  style: TextStyle(
                    color: themeProvider.secondaryTextColor,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 48),

                Expanded(
                  child: Column(
                    children: [
                      // Patient Role Card
                      _buildRoleCard(
                        role: UserRole.patient,
                        title: "I'm a Patient",
                        subtitle: "Seeking Ayurvedic guidance and consultation",
                        icon: Icons.person,
                        features: [
                          "Chat with AI assistant",
                          "Consult with verified doctors",
                          "Access Ayurvedic remedies",
                          "Track your health journey",
                        ],
                        themeProvider: themeProvider,
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Doctor Role Card
                      _buildRoleCard(
                        role: UserRole.doctor,
                        title: "I'm a Doctor",
                        subtitle: "Providing Ayurvedic consultation and care",
                        icon: Icons.medical_services,
                        features: [
                          "Consult with patients",
                          "Earn credits per consultation",
                          "Share your expertise",
                          "Build your practice",
                        ],
                        themeProvider: themeProvider,
                      ),
                    ],
                  ),
                ),

                // Continue Button
                if (selectedRole != null) ...[
                  const SizedBox(height: 32),
                  AnimatedButton(
                    text: "Continue",
                    onPressed: _continueToSignup,
                    icon: Icons.arrow_forward,
                  ),
                ],
                
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoleCard({
    required UserRole role,
    required String title,
    required String subtitle,
    required IconData icon,
    required List<String> features,
    required ThemeProvider themeProvider,
  }) {
    final isSelected = selectedRole == role;
    
    return AnimatedCard(
      onTap: () => _selectRole(role),
      padding: const EdgeInsets.all(24),
      child: Container(
        decoration: BoxDecoration(
          border: isSelected
              ? Border.all(color: themeProvider.primaryColor, width: 2)
              : null,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: themeProvider.primaryColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: themeProvider.primaryColor,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: themeProvider.textColor,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: themeProvider.secondaryTextColor,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  Icon(
                    Icons.check_circle,
                    color: themeProvider.primaryColor,
                    size: 24,
                  ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // Features list
            ...features.map((feature) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Icon(
                    Icons.check,
                    color: themeProvider.primaryColor,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    feature,
                    style: TextStyle(
                      color: themeProvider.textColor,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }
}