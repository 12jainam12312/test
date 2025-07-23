import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../services/doctor_service.dart';
import '../services/auth_service.dart';
import '../widgets/animated_card.dart';
import '../widgets/animated_button.dart';
import '../widgets/auth_input_field.dart';
import 'doctor_pending_screen.dart';

class DoctorVerificationScreen extends StatefulWidget {
  const DoctorVerificationScreen({super.key});

  @override
  State<DoctorVerificationScreen> createState() => _DoctorVerificationScreenState();
}

class _DoctorVerificationScreenState extends State<DoctorVerificationScreen> {
  final _formKey = GlobalKey<FormState>();
  final specializationController = TextEditingController();
  final experienceController = TextEditingController();
  final medicalLicenseController = TextEditingController();
  final certificatesController = TextEditingController();
  
  bool isSubmitting = false;


  Future<void> _submitApplication() async {
    if (!_formKey.currentState!.validate()) return;
    

    setState(() => isSubmitting = true);

    try {
      final user = AuthService().currentUser;
      if (user == null) throw Exception('User not authenticated');

      final certificates = certificatesController.text
          .split(',')
          .map((cert) => cert.trim())
          .where((cert) => cert.isNotEmpty)
          .toList();

      await DoctorService.submitDoctorApplication(
        uid: user.uid,
        specialization: specializationController.text.trim(),
        experience: experienceController.text.trim(),
        medicalLicense: medicalLicenseController.text.trim(),
        certificates: certificates,
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const DoctorPendingScreen()),
      );
    } catch (e) {
      _showSnackBar('Failed to submit application: $e');
    } finally {
      setState(() => isSubmitting = false);
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return Scaffold(
      backgroundColor: themeProvider.backgroundColor,
      appBar: AppBar(
        backgroundColor: themeProvider.surfaceColor,
        title: Text(
          'Doctor Verification',
          style: TextStyle(color: themeProvider.primaryColor),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            // Header
            AnimatedCard(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Icon(
                    Icons.verified_user,
                    color: themeProvider.primaryColor,
                    size: 48,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Verification Required',
                    style: TextStyle(
                      color: themeProvider.textColor,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Please provide your credentials for verification. This helps us ensure quality care for our patients.',
                    style: TextStyle(
                      color: themeProvider.secondaryTextColor,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Specialization
            _buildLabel('Specialization'),
            _buildTextField(
              controller: specializationController,
              hintText: 'e.g., Ayurvedic Medicine, Panchakarma',
              icon: Icons.medical_services,
            ),

            const SizedBox(height: 24),

            // Experience
            _buildLabel('Years of Experience'),
            _buildTextField(
              controller: experienceController,
              hintText: 'e.g., 5 years',
              icon: Icons.work_history,
            ),

            const SizedBox(height: 24),

            // Medical License
            _buildLabel('Medical License Number'),
            _buildTextField(
              controller: medicalLicenseController,
              hintText: 'Enter your license number',
              icon: Icons.badge,
            ),

            const SizedBox(height: 24),

            // Certificates
            _buildLabel('Certificates (comma separated)'),
            _buildTextField(
              controller: certificatesController,
              hintText: 'BAMS, MD Ayurveda, etc.',
              icon: Icons.school,
              maxLines: 2,
            ),

            const SizedBox(height: 32),

            // Note Section (replacing document upload for now)
            AnimatedCard(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Document Verification',
                    style: TextStyle(
                      color: themeProvider.textColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Document upload feature will be available soon. For now, please ensure all information above is accurate.',
                    style: TextStyle(
                      color: themeProvider.secondaryTextColor,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // Submit Button
            AnimatedButton(
              text: 'Submit for Verification',
              onPressed: isSubmitting ? () {} : _submitApplication,
              isLoading: isSubmitting,
              icon: Icons.send,
            ),

            const SizedBox(height: 20),

            // Note
            AnimatedCard(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: themeProvider.primaryColor,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Your application will be reviewed by our admin team. You\'ll be notified once approved.',
                      style: TextStyle(
                        color: themeProvider.secondaryTextColor,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: TextStyle(
          color: themeProvider.textColor,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: AuthInputField(
        controller: controller,
        hintText: hintText,
        icon: icon,
      ),
    );
  }
}