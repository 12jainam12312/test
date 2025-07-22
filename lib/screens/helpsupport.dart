import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:medical/l10n/app_localizations.dart';
import 'package:medical/theme/theme.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/animated_card.dart';
import '../widgets/animated_button.dart';

class HelpAndSupportPage extends StatefulWidget {
  const HelpAndSupportPage({super.key});

  @override
  State<HelpAndSupportPage> createState() => _HelpAndSupportPageState();
}

class _HelpAndSupportPageState extends State<HelpAndSupportPage>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  void _showSnackBar(BuildContext context, String message, {bool isSuccess = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isSuccess ? Icons.check_circle : Icons.info,
              color: isSuccess ? neonGreen : Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: backgroundMid,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: neonGreen.withOpacity(0.3)),
        ),
      ),
    );
  }

  void _copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    _showSnackBar(context, '$label copied to clipboard!', isSuccess: true);
  }

  void _launchEmail() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'support@yourapp.com',
      queryParameters: {
        'subject': 'Support Request - YourApp',
        'body': 'Hi,\n\nI need help with:\n\n',
      },
    );
    
    try {
      if (await canLaunchUrl(emailUri)) {
        await launchUrl(emailUri);
      } else {
        _copyToClipboard('support@yourapp.com', 'Email address');
      }
    } catch (e) {
      _copyToClipboard('support@yourapp.com', 'Email address');
    }
  }

  void _showFeedbackDialog() {
    final TextEditingController feedbackController = TextEditingController();
    int selectedRating = 5;
    final l10n=AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: backgroundMid,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: neonGreen.withOpacity(0.3)),
              ),
              title: Text(
                l10n.sendFeedback,
                style: TextStyle(color: neonGreen, fontWeight: FontWeight.bold),
              ),
              content: SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.rateUrExp,
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedRating = index + 1;
                            });
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Icon(
                              Icons.star,
                              color: index < selectedRating ? neonGreen : subtitleGray,
                              size: 32,
                            ),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      l10n.tellMore,
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: feedbackController,
                      maxLines: 4,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: l10n.shareThoughtsHint,
                        hintStyle: TextStyle(color: subtitleGray),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: subtitleGray),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: neonGreen),
                        ),
                        filled: true,
                        fillColor: backgroundDark,
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    l10n.cancel,
                    style: TextStyle(color: subtitleGray),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _showSnackBar(
                      context,
                      'Thank you for your ${selectedRating}-star feedback!',
                      isSuccess: true,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: neonGreen,
                    foregroundColor: backgroundDark,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(l10n.submit, style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showBugReportDialog() {
    final TextEditingController bugController = TextEditingController();
    String selectedSeverity = 'Medium';
    String selectedCategory = 'UI/UX';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: backgroundMid,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: neonGreen.withOpacity(0.3)),
              ),
              title: const Text(
                'Report a Bug',
                style: TextStyle(color: neonGreen, fontWeight: FontWeight.bold),
              ),
              content: SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Severity:', style: TextStyle(color: Colors.white)),
                              const SizedBox(height: 4),
                              DropdownButtonFormField<String>(
                                value: selectedSeverity,
                                dropdownColor: backgroundMid,
                                style: const TextStyle(color: Colors.white),
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(color: subtitleGray),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                ),
                                items: ['Low', 'Medium', 'High', 'Critical']
                                    .map((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList(),
                                onChanged: (String? newValue) {
                                  setState(() {
                                    selectedSeverity = newValue!;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Category:', style: TextStyle(color: Colors.white)),
                              const SizedBox(height: 4),
                              DropdownButtonFormField<String>(
                                value: selectedCategory,
                                dropdownColor: backgroundMid,
                                style: const TextStyle(color: Colors.white),
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(color: subtitleGray),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                ),
                                items: ['UI/UX', 'Performance', 'Functionality', 'Crash', 'Other']
                                    .map((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList(),
                                onChanged: (String? newValue) {
                                  setState(() {
                                    selectedCategory = newValue!;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text('Describe the issue:', style: TextStyle(color: Colors.white)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: bugController,
                      maxLines: 4,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'What happened? Steps to reproduce?',
                        hintStyle: TextStyle(color: subtitleGray),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: subtitleGray),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: neonGreen),
                        ),
                        filled: true,
                        fillColor: backgroundDark,
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('Cancel', style: TextStyle(color: subtitleGray)),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _showSnackBar(
                      context,
                      'Bug report submitted! Ticket #${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}',
                      isSuccess: true,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: neonGreen,
                    foregroundColor: backgroundDark,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Submit Report', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n=AppLocalizations.of(context)!;
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return Scaffold(
      backgroundColor: themeProvider.backgroundColor,
      appBar: AppBar(
        backgroundColor: themeProvider.surfaceColor,
        title: Text(
          l10n.helpSupport, 
          style: TextStyle(color: themeProvider.primaryColor, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        iconTheme: IconThemeData(color: themeProvider.primaryColor),
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // Welcome Section
              AnimatedCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.support_agent, color: themeProvider.primaryColor, size: 28),
                        const SizedBox(width: 12),
                        Text(
                          'We\'re here to help!',
                          style: TextStyle(
                            color: themeProvider.textColor,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Get quick answers to your questions or reach out to our support team.',
                      style: TextStyle(color: themeProvider.secondaryTextColor, fontSize: 16),
                    ),
                  ],
                ),
              ),

              // Quick Actions Section
              _sectionLabel(l10n.quickActions, themeProvider),
              Row(
                children: [
                  Expanded(
                    child: _quickActionCard(
                      icon: Icons.chat_bubble_outline,
                      label: l10n.liveChat,
                      themeProvider: themeProvider,
                      onTap: () => _showSnackBar(context, 'Live chat coming soon!'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _quickActionCard(
                      icon: Icons.call,
                      label: l10n.callUs,
                      themeProvider: themeProvider,
                      onTap: () => _copyToClipboard('+1-800-SUPPORT', 'Phone number'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Support Options Section
              _sectionLabel(l10n.supportOptions, themeProvider),
              _supportTile(
                context,
                icon: Icons.help_outline,
                title: l10n.faqTroubleshoot,
                subtitle: 'Find answers to common questions',
                badge: 'Popular',
                themeProvider: themeProvider,
                onTap: () => _showSnackBar(context, 'FAQ section opening...'),
              ),
              _supportTile(
                context,
                icon: Icons.email_outlined,
                title: l10n.contactSupport,
                subtitle: 'Get personalized help via email',
                themeProvider: themeProvider,
                onTap: _launchEmail,
              ),
              _supportTile(
                context,
                icon: Icons.feedback_outlined,
                title: l10n.sendFeedback,
                subtitle: 'Help us improve your experience',
                themeProvider: themeProvider,
                onTap: _showFeedbackDialog,
              ),
              _supportTile(
                context,
                icon: Icons.bug_report_outlined,
                title: l10n.reportBug,
                subtitle: 'Something not working correctly?',
                themeProvider: themeProvider,
                onTap: _showBugReportDialog,
              ),

              const SizedBox(height: 24),

              // Resources Section
              _sectionLabel(l10n.resources, themeProvider),
              _supportTile(
                context,
                icon: Icons.book_outlined,
                title: l10n.userGuide,
                subtitle: 'Complete documentation and tutorials',
                themeProvider: themeProvider,
                onTap: () => _showSnackBar(context, 'User guide opening...'),
              ),
              _supportTile(
                context,
                icon: Icons.video_library_outlined,
                title: l10n.videoTutorials,
                subtitle: 'Step-by-step video guides',
                themeProvider: themeProvider,
                onTap: () => _showSnackBar(context, 'Video tutorials opening...'),
              ),
              _supportTile(
                context,
                icon: Icons.people_outline,
                title: l10n.communityForum,
                subtitle: 'Connect with other users',
                badge: 'New',
                themeProvider: themeProvider,
                onTap: () => _showSnackBar(context, 'Community forum opening...'),
              ),

              const SizedBox(height: 32),

              // Contact Info Footer
              AnimatedCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(
                      l10n.immediateAssistance,
                      style: TextStyle(
                        color: themeProvider.textColor,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.responseTime,
                      style: TextStyle(color: themeProvider.secondaryTextColor, fontSize: 14),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.access_time, color: themeProvider.primaryColor, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          l10n.supportHours,
                          style: TextStyle(color: themeProvider.secondaryTextColor, fontSize: 12),
                        ),
                      ],
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

  Widget _sectionLabel(String text, ThemeProvider themeProvider) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, top: 8),
      child: Text(
        text,
        style: TextStyle(
          color: themeProvider.primaryColor,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _quickActionCard({
    required IconData icon,
    required String label,
    required ThemeProvider themeProvider,
    required VoidCallback onTap,
  }) {
    return AnimatedCard(
      onTap: onTap,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Icon(icon, color: themeProvider.primaryColor, size: 32),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: themeProvider.textColor,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _supportTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required ThemeProvider themeProvider,
    required VoidCallback onTap,
    String? badge,
  }) {
    return AnimatedCard(
      onTap: onTap,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: themeProvider.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: themeProvider.primaryColor, size: 24),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: themeProvider.textColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (badge != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: themeProvider.primaryColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  badge,
                  style: TextStyle(
                    color: themeProvider.backgroundColor,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(color: themeProvider.secondaryTextColor, fontSize: 14),
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: themeProvider.primaryColor.withOpacity(0.7),
          size: 24,
        ),
      ),
    );
  }
}