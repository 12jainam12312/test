import 'package:flutter/material.dart';
import 'package:medical/screens/signup_screen.dart';
import '../services/auth_service.dart';
import '../widgets/auth_button.dart';
import '../widgets/auth_input_field.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// Import the SignUpScreen
import 'package:medical/screens/homeshell.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final AuthService _authService = AuthService();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Check if user is already signed in
    _checkAuthStatus();
  }

  void _checkAuthStatus() {
    final user = _authService.currentUser;
    if (user != null) {
      // User is already signed in, navigate to home
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => HomeShell(
            ),
          ),
        );
      });
    }
  }

  void handleGoogleSignIn() async {
    try {
      final user = await _authService.signInWithGoogle();
      if (user != null) {
        // Sign in successful, navigate to home
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => HomeShell(
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Google Sign-In Failed: $e')),
      );
    }
  }

  void handleEmailSignIn() {
    // You can implement this with Firebase Email/Password auth later
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Email/Password sign-in coming soon!')),
    );
  }

  void navigateToSignUp() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const SignUpScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 60),
                      
                      // Logo
                      Image.asset(
                        'assets/Luna.png',
                        width: 80,
                        height: 80,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(height: 32),
                      
                      // Title
                      const Text(
                        "Sign In To Luna",
                        style: TextStyle(
                          color: Color(0xFF7ED321),
                          fontSize: 28,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      
                      // Subtitle
                      const Text(
                        "Let's experience the joy of Luna AI",
                        style: TextStyle(
                          color: Color(0xFF8E8E8E),
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 48),

                      // Email Label
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Email Address",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Email Input
                      AuthInputField(
                        controller: emailController,
                        hintText: "Enter your Email...",
                        icon: Icons.email_outlined,
                      ),
                      const SizedBox(height: 24),

                      // Password Label
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Password",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Password Input
                      AuthInputField(
                        controller: passwordController,
                        hintText: "Enter your password...",
                        icon: Icons.lock_outline,
                        obscureText: true,
                      ),
                      const SizedBox(height: 32),

                      // Sign In Button
                      SizedBox(
                        width: double.infinity,
                        child: AuthButton(
                          label: "Sign In",
                          onPressed: handleEmailSignIn,
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Social Buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildSocialButton(
                            FontAwesomeIcons.facebookF,
                            () {},
                          ),
                          const SizedBox(width: 24),
                          _buildSocialButton(
                            FontAwesomeIcons.google,
                            handleGoogleSignIn,
                          ),
                          const SizedBox(width: 24),
                          _buildSocialButton(
                            FontAwesomeIcons.instagram,
                            () {},
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              
              // Bottom Sign up section
              Padding(
                padding: const EdgeInsets.only(bottom: 32),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Don't have an account? ",
                      style: TextStyle(
                        color: Color(0xFF8E8E8E),
                        fontSize: 16,
                      ),
                    ),
                    GestureDetector(
                      onTap: navigateToSignUp, // Now properly navigates to sign up
                      child: const Text(
                        "Sign up",
                        style: TextStyle(
                          color: Color(0xFF7ED321),
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.underline,
                          decorationColor: Color(0xFF7ED321),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSocialButton(IconData icon, VoidCallback onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: const Color(0xFF2A2A2A),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Icon(
            icon,
            color: Colors.white,
            size: 24,
          ),
        ),
      ),
    );
  }
}