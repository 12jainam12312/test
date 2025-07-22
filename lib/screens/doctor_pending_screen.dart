import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../services/doctor_service.dart';
import '../services/auth_service.dart';
import '../widgets/animated_card.dart';
import '../widgets/animated_button.dart';
import '../models/user_model.dart';
import 'homeshell.dart';
import 'auth_screen.dart';

class DoctorPendingScreen extends StatefulWidget {
  const DoctorPendingScreen({super.key});

  @override
  State<DoctorPendingScreen> createState() => _DoctorPendingScreenState();
}

class _DoctorPendingScreenState extends State<DoctorPendingScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  DoctorModel? doctorProfile;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    
    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    
    _checkDoctorStatus();
    _startStatusPolling();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _checkDoctorStatus() async {
    try {
      final user = AuthService().currentUser;
      if (user != null) {
        final profile = await DoctorService.getDoctorProfile(user.uid);
        setState(() {
          doctorProfile = profile;
          isLoading = false;
        });

        // If approved, navigate to home
        if (profile?.status == DoctorStatus.approved) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const HomeShell()),
          );
        }
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  void _startStatusPolling() {
    // Check status every 30 seconds
    Future.delayed(const Duration(seconds: 30), () {
      if (mounted) {
        _checkDoctorStatus();
        _startStatusPolling();
      }
    });
  }

  void _signOut() async {
    try {
      await AuthService().signOut();
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const AuthScreen()),
        (route) => false,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sign out failed: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    if (isLoading) {
      return Scaffold(
        backgroundColor: themeProvider.backgroundColor,
        body: Center(
          child: CircularProgressIndicator(color: themeProvider.primaryColor),
        ),
      );
    }

    return Scaffold(
      backgroundColor: themeProvider.backgroundColor,
      appBar: AppBar(
        backgroundColor: themeProvider.surfaceColor,
        title: Text(
          'Verification Status',
          style: TextStyle(color: themeProvider.primaryColor),
        ),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: themeProvider.primaryColor),
            onPressed: _signOut,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 40),
            
            // Status Animation
            AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _pulseAnimation.value,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _getStatusColor().withOpacity(0.2),
                      border: Border.all(
                        color: _getStatusColor(),
                        width: 3,
                      ),
                    ),
                    child: Icon(
                      _getStatusIcon(),
                      color: _getStatusColor(),
                      size: 48,
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 32),

            // Status Card
            AnimatedCard(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Text(
                    _getStatusTitle(),
                    style: TextStyle(
                      color: themeProvider.textColor,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _getStatusMessage(),
                    style: TextStyle(
                      color: themeProvider.secondaryTextColor,
                      fontSize: 16,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  if (doctorProfile?.status == DoctorStatus.rejected) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red.withOpacity(0.3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Rejection Reason:',
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            doctorProfile?.rejectionReason ?? 'No reason provided',
                            style: TextStyle(color: Colors.red),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const Spacer(),

            // Action Buttons
            if (doctorProfile?.status == DoctorStatus.pending) ...[
              AnimatedButton(
                text: 'Refresh Status',
                icon: Icons.refresh,
                onPressed: _checkDoctorStatus,
              ),
              const SizedBox(height: 16),
            ],

            if (doctorProfile?.status == DoctorStatus.rejected) ...[
              AnimatedButton(
                text: 'Reapply',
                icon: Icons.refresh,
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const DoctorVerificationScreen()),
                  );
                },
              ),
              const SizedBox(height: 16),
            ],

            // Sign Out Button
            AnimatedButton(
              text: 'Sign Out',
              icon: Icons.logout,
              onPressed: _signOut,
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor() {
    switch (doctorProfile?.status) {
      case DoctorStatus.approved:
        return Colors.green;
      case DoctorStatus.rejected:
        return Colors.red;
      case DoctorStatus.pending:
      default:
        return Colors.orange;
    }
  }

  IconData _getStatusIcon() {
    switch (doctorProfile?.status) {
      case DoctorStatus.approved:
        return Icons.check_circle;
      case DoctorStatus.rejected:
        return Icons.cancel;
      case DoctorStatus.pending:
      default:
        return Icons.hourglass_empty;
    }
  }

  String _getStatusTitle() {
    switch (doctorProfile?.status) {
      case DoctorStatus.approved:
        return 'Verification Complete!';
      case DoctorStatus.rejected:
        return 'Application Rejected';
      case DoctorStatus.pending:
      default:
        return 'Verification Pending';
    }
  }

  String _getStatusMessage() {
    switch (doctorProfile?.status) {
      case DoctorStatus.approved:
        return 'Congratulations! Your application has been approved. You can now start consulting with patients.';
      case DoctorStatus.rejected:
        return 'Your application has been rejected. Please review the reason below and consider reapplying with updated information.';
      case DoctorStatus.pending:
      default:
        return 'Your application is under review by our admin team. This usually takes 24-48 hours. We\'ll notify you once the review is complete.';
    }
  }
}