import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../models/user_model.dart';
import '../services/user_service.dart';
import '../widgets/auth_button.dart';
import '../widgets/auth_input_field.dart';
import 'auth_screen.dart';
import 'homeshell.dart';
import 'doctor_verification_screen.dart';

class SignUpScreen extends StatefulWidget {
  final UserRole selectedRole;
  
  const SignUpScreen({super.key, required this.selectedRole});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final nameController = TextEditingController();

  bool isLoading = false;

  void handleSignUp() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();
    final name = nameController.text.trim();

    if (email.isEmpty || password.isEmpty || confirmPassword.isEmpty || name.isEmpty) {
      showError('Please fill in all fields.');
      return;
    }

    if (password != confirmPassword) {
      showError('Passwords do not match.');
      return;
    }

    setState(() => isLoading = true);

    try {
      final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update display name
      await userCredential.user?.updateDisplayName(name);
      
      // Create user profile in Firestore
      await UserService.createUserProfile(
        uid: userCredential.user!.uid,
        email: email,
        displayName: name,
        role: widget.selectedRole,
      );

      // Navigate based on role
      if (widget.selectedRole == UserRole.doctor) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const DoctorVerificationScreen()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeShell()),
        );
      }
    } on FirebaseAuthException catch (e) {
      showError(e.message ?? 'Sign up failed. Please try again.');
    } finally {
      setState(() => isLoading = false);
    }
  }

  void showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return Scaffold(
      backgroundColor: themeProvider.backgroundColor,
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
                      Image.asset('assets/Luna.png', width: 80, height: 80),
                      const SizedBox(height: 32),
                      Text(
                        widget.selectedRole == UserRole.doctor 
                            ? "Join as Doctor" 
                            : "Sign Up For Free",
                        style: TextStyle(
                          color: themeProvider.primaryColor,
                          fontSize: 28,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.selectedRole == UserRole.doctor 
                            ? "Start your practice with Luna" 
                            : "Sign up in 1 minute for free!",
                        style: TextStyle(
                          color: themeProvider.secondaryTextColor,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 48),

                      // Name Label
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Full Name",
                          style: TextStyle(
                            color: themeProvider.textColor,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Name Input
                      AuthInputField(
                        controller: nameController,
                        hintText: "Enter your full name...",
                        icon: Icons.person_outline,
                      ),
                      const SizedBox(height: 24),

                      label("Email Address"),
                      AuthInputField(
                        controller: emailController,
                        hintText: "Enter your Email...",
                        icon: Icons.email_outlined,
                      ),
                      const SizedBox(height: 24),

                      label("Password"),
                      AuthInputField(
                        controller: passwordController,
                        hintText: "Enter your password...",
                        icon: Icons.lock_outline,
                        obscureText: true,
                      ),
                      const SizedBox(height: 24),

                      label("Password Confirmation"),
                      AuthInputField(
                        controller: confirmPasswordController,
                        hintText: "Confirm your password...",
                        icon: Icons.lock_outline,
                        obscureText: true,
                      ),
                      const SizedBox(height: 32),

                      SizedBox(
                        width: double.infinity,
                        child: isLoading
                            ? Center(child: CircularProgressIndicator(color: themeProvider.primaryColor))
                            : AuthButton(
                                label: "Sign Up",
                                onPressed: handleSignUp,
                              ),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),

              // Bottom text
              Padding(
                padding: const EdgeInsets.only(bottom: 32),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Already have an account? ",
                      style: TextStyle(
                        color: themeProvider.secondaryTextColor,
                        fontSize: 16,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (context) => const AuthScreen()),
                        );
                      },
                      child: const Text(
                        "Sign in",
                        style: TextStyle(
                          color: themeProvider.primaryColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.underline,
                          decorationColor: themeProvider.primaryColor,
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

  Widget label(String text) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: const TextStyle(
          color: themeProvider.textColor,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}