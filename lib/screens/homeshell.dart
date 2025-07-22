import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:medical/screens/FAQ.dart';
import 'package:medical/screens/TermsConditions.dart';
import 'package:medical/screens/auth_screen.dart';
import 'package:medical/screens/chat_screen.dart';
import 'package:medical/screens/educational_lessons_app.dart';
import 'package:medical/screens/settings_page.dart';
import 'package:medical/widgets/typing_text_animation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';
import 'package:medical/screens/hospital_locator_page.dart';
import 'dart:convert';
import 'dart:io';
// Missing
import 'package:medical/screens/chat_screen.dart';
import 'Profile.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../locale_provider.dart';
import 'package:medical/screens/helpsupport.dart' as help;
import 'dart:math';
// Import the ads popup page
import 'package:medical/screens/ads_popup_page.dart';
import '../providers/theme_provider.dart';
import '../widgets/animated_background.dart';
import '../widgets/theme_toggle_button.dart';
import '../widgets/animated_card.dart';

class RemedyProvider extends ChangeNotifier {
  String _remedy = '';

  String get remedy => _remedy;

  void setRemedy(String remedy) {
    _remedy = remedy;
    notifyListeners();
  }
}

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  static final _pages = <Widget>[
    const MainPage(),
    ChatScreen(),
    HospitalLocatorPage(),
    const help.HelpAndSupportPage(),
  ];

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Check if user is authenticated first
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return;
    }

    // Small delay to ensure the widget tree is built
    await Future.delayed(const Duration(milliseconds: 500));

    // Check and show ads popup first
    await _checkAndShowAdsPopup();

    // Then check terms agreement
    await _checkTermsAgreement();
  }

  Future<void> _checkAndShowAdsPopup() async {
    if (!mounted) return;

    final shouldShow = await AdsPopupHelper.shouldShowAdsPopup();
    if (shouldShow) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          AdsPopupHelper.showAdsPopup(context);
        }
      });
    }
  }

  Future<void> _launchEmail() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'support@example.com',
      query: 'subject=App Support',
    );
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    }
  }

  Future<void> _checkTermsAgreement() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      // User is not signed in yet; skip checking
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final key = 'agreed_to_terms_${user.uid}';
    final agreed = prefs.getBool(key) ?? false;

    if (!agreed) {
      // Add a delay to ensure ads popup is shown first
      await Future.delayed(const Duration(milliseconds: 1000));

      if (mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder:
                (_) => TermsConditionsPage(
                  onAgree: () async {
                    await prefs.setBool(key, true);
                    Navigator.of(context).pop();
                  },
                ),
          );
        });
      }
    }
  }

  void handleSignOut(BuildContext context) async {
    try {
      final authService = AuthService();
      await authService.signOut();

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const AuthScreen()),
        (route) => false,
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Sign out failed: $e')));
    }
  }

  void _onNavTap(int newIdx) => setState(() => _index = newIdx);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final themeProvider = Provider.of<ThemeProvider>(context);

    return AnimatedBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        drawer: const _MainDrawer(),
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          leading: Builder(
            builder:
                (ctx) => IconButton(
                  icon: Icon(Icons.menu, color: themeProvider.primaryColor),
                  onPressed: () => Scaffold.of(ctx).openDrawer(),
                ),
          ),
          actions: [
            // Theme toggle button
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: const ThemeToggleButton(),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 14),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) =>
                          const ProfilePage(),
                      transitionsBuilder: (context, animation, secondaryAnimation, child) {
                        return SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(1.0, 0.0),
                            end: Offset.zero,
                          ).animate(CurvedAnimation(
                            parent: animation,
                            curve: Curves.easeInOut,
                          )),
                          child: child,
                        );
                      },
                    ),
                  );
                },
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: themeProvider.primaryColor,
                    boxShadow: [
                      BoxShadow(
                        color: themeProvider.primaryColor.withOpacity(0.3),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.account_circle_outlined,
                    size: 24,
                    color: themeProvider.backgroundColor,
                  ),
                ),
              ),
            ),
          ],
        ),
        body: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (Widget child, Animation<double> animation) {
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.1, 0.0),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              ),
            );
          },
          child: _pages[_index],
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: themeProvider.surfaceColor,
            border: Border(
              top: BorderSide(
                color: themeProvider.primaryColor.withOpacity(0.2),
                width: 0.5,
              ),
            ),
          ),
          child: NavigationBar(
            backgroundColor: Colors.transparent,
            selectedIndex: _index,
            onDestinationSelected: _onNavTap,
            indicatorColor: themeProvider.primaryColor.withOpacity(0.2),
            destinations: [
              NavigationDestination(
                icon: Icon(Icons.home_outlined, color: themeProvider.secondaryTextColor),
                selectedIcon: Icon(Icons.home, color: themeProvider.primaryColor),
                label: l10n.home,
              ),
              NavigationDestination(
                icon: Icon(Icons.chat_bubble_outline, color: themeProvider.secondaryTextColor),
                selectedIcon: Icon(Icons.chat, color: themeProvider.primaryColor),
                label: l10n.chatPage,
              ),
              NavigationDestination(
                icon: Icon(Icons.place_outlined, color: themeProvider.secondaryTextColor),
                selectedIcon: Icon(Icons.place, color: themeProvider.primaryColor),
                label: l10n.mapPage,
              ),
              NavigationDestination(
                icon: Icon(Icons.call_outlined, color: themeProvider.secondaryTextColor),
                selectedIcon: Icon(Icons.call, color: themeProvider.primaryColor),
                label: l10n.helpPage,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// ─────────────────────────
/// Drawer with both screens
/// ─────────────────────────
class _MainDrawer extends StatelessWidget {
  const _MainDrawer();

  //Mit Code
  void _showLanguageDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(l10n.changeLanguage),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _LanguageTile(
                title: 'English',
                flag: '🇺🇸',
                locale: const Locale('en'),
                onTap: () {
                  Provider.of<LocaleProvider>(
                    context,
                    listen: false,
                  ).setLocale(const Locale('en'));
                  Navigator.pop(context);
                },
              ),
              _LanguageTile(
                title: 'हिंदी',
                flag: '🇮🇳',
                locale: const Locale('hi'),
                onTap: () {
                  Provider.of<LocaleProvider>(
                    context,
                    listen: false,
                  ).setLocale(const Locale('hi'));
                  Navigator.pop(context);
                },
              ),
              _LanguageTile(
                title: 'ગુજરાતી',
                flag: '🇮🇳',
                locale: const Locale('gu'),
                onTap: () {
                  Provider.of<LocaleProvider>(
                    context,
                    listen: false,
                  ).setLocale(const Locale('gu'));
                  Navigator.pop(context);
                },
              ),
              _LanguageTile(
                title: 'मराठी',
                flag: '🇮🇳',
                locale: const Locale('mr'),
                onTap: () {
                  Provider.of<LocaleProvider>(
                    context,
                    listen: false,
                  ).setLocale(const Locale('mr'));
                  Navigator.pop(context);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('cancel'),
            ),
          ],
        );
      },
    );
  }

  //mit code end here

  @override
  Widget build(BuildContext context) {
    final parentState = context.findAncestorStateOfType<_HomeShellState>();
    final l10n = AppLocalizations.of(context)!;
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Drawer(
      backgroundColor: themeProvider.surfaceColor,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: themeProvider.surfaceColor),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: themeProvider.primaryColor,
                    boxShadow: [
                      BoxShadow(
                        color: themeProvider.primaryColor.withOpacity(0.3),
                        blurRadius: 12,
                        spreadRadius: 3,
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.person,
                    color: themeProvider.backgroundColor,
                    size: 24,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.title, //Luna menu
                  style: TextStyle(
                    color: themeProvider.primaryColor,
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: Icon(Icons.home, color: themeProvider.primaryColor),
            title: Text(
              l10n.home,
              style: TextStyle(color: themeProvider.textColor, fontSize: 16),
            ),
            onTap: () => Navigator.pop(context),
          ),

          ListTile(
            leading: Icon(Icons.school, color: themeProvider.primaryColor),
            title: Text(
              l10n.educationalLessons,
              style: TextStyle(color: themeProvider.textColor, fontSize: 16),
            ),
            onTap: () {
              Navigator.pop(context);
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const EducationalLessonsPage(),
                ),
              );
            },
          ),

          ListTile(
            leading: Icon(
              Icons.question_answer_outlined,
              color: themeProvider.primaryColor,
            ),
            title: Text(
              l10n.faq,
              style: TextStyle(color: themeProvider.textColor, fontSize: 16),
            ),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const FAQPage()),
              );
            },
          ),

          ListTile(
            leading: Icon(Icons.settings, color: themeProvider.primaryColor),
            title: Text(
              l10n.settings,
              style: TextStyle(color: themeProvider.textColor, fontSize: 16),
            ),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SettingsPage()),
              );
            },
          ),

          ListTile(
            leading: Icon(Icons.logout, color: themeProvider.primaryColor),
            title: Text(
              l10n.signOut,
              style: TextStyle(color: themeProvider.textColor, fontSize: 16),
            ),
            onTap: () {
              Navigator.pop(context);
              parentState?.handleSignOut(context);
            },
          ),

          ListTile(
            leading: Icon(Icons.language, color: themeProvider.primaryColor),
            title: Text(
              l10n.changeLanguage,
              style: TextStyle(color: themeProvider.textColor, fontSize: 16),
            ),
            onTap: () {
              Navigator.pop(context);
              Future.delayed(const Duration(milliseconds: 100), () {
                _showLanguageDialog(context);
              });
            },
          ),
        ],
      ),
    );
  }

  // Widget _buildDrawerItem(IconData icon, String title, VoidCallback onTap) {
  //   return ListTile(
  //     leading: Icon(icon, color: const Color(0xFF9AFF00)),
  //     title: Text(
  //       title,
  //       style: const TextStyle(color: Colors.white, fontSize: 16),
  //     ),
  //     onTap: onTap,
  //     hoverColor: const Color(0xFF9AFF00).withOpacity(0.1),
  //   );
  // }
}

//mit code
class _LanguageTile extends StatelessWidget {
  final String title;
  final String flag;
  final Locale locale;
  final VoidCallback onTap;

  const _LanguageTile({
    required this.title,
    required this.flag,
    required this.locale,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      leading: Text(flag, style: const TextStyle(fontSize: 20)),
      onTap: onTap,
    );
  }
}
//mit code end here

/// ─────────────────────────
/// Page 1 – Home
/// ─────────────────────────

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const LocationBar(),
            const SizedBox(height: 40),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  // Luna Logo/Title with enhanced animations
                  _AnimatedLogo(),
                  const SizedBox(height: 16),
                  // Subtitle with typing animation
                  _AnimatedSubtitle(),
                  const SizedBox(height: 20),
                  // Health remedy box with enhanced styling
                  Consumer<RemedyProvider>(
                    builder: (context, remedyProvider, child) {
                      if (remedyProvider.remedy.isNotEmpty) {
                        return AnimatedCard(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 16,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.lightbulb_outline,
                                color: themeProvider.primaryColor,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  remedyProvider.remedy,
                                  style: TextStyle(
                                    color: themeProvider.primaryColor,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                    height: 1.4,
                                  ),
                                  textAlign: TextAlign.left,
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnimatedLogo extends StatefulWidget {
  @override
  State<_AnimatedLogo> createState() => _AnimatedLogoState();
}

class _AnimatedLogoState extends State<_AnimatedLogo>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _rotationController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    
    _pulseController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);
    
    _rotationController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _rotationAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _rotationController, curve: Curves.linear),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return AnimatedBuilder(
      animation: Listenable.merge([_pulseAnimation, _rotationAnimation]),
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Column(
            children: [
              // Luna text with gradient effect
              ShaderMask(
                shaderCallback: (bounds) => LinearGradient(
                  colors: [
                    themeProvider.primaryColor,
                    themeProvider.primaryColor.withOpacity(0.7),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ).createShader(bounds),
                child: const Text(
                  'Luna',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    letterSpacing: 3,
                    fontFamily: 'Roboto',
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Animated glow circle with rotation
              Transform.rotate(
                angle: _rotationAnimation.value * 2 * 3.14159,
                child: Container(
                  width: 240,
                  height: 240,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        themeProvider.primaryColor.withOpacity(0.3 * _pulseAnimation.value),
                        themeProvider.primaryColor.withOpacity(0.1 * _pulseAnimation.value),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: Center(
                    child: Container(
                      width: 160,
                      height: 160,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: themeProvider.primaryColor,
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: themeProvider.primaryColor.withOpacity(0.5),
                            blurRadius: 20 * _pulseAnimation.value,
                            spreadRadius: 5 * _pulseAnimation.value,
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          'assets/Luna.png',
                          height: 100,
                          width: 100,
                          color: themeProvider.primaryColor,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _AnimatedSubtitle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return TypingTextAnimation(
      text: 'Feeling Unwell or Just Curious',
      style: TextStyle(
        fontSize: 16,
        color: themeProvider.secondaryTextColor,
        fontStyle: FontStyle.italic,
      ),
      duration: const Duration(milliseconds: 100),
    );
  }
}

// Custom painter for modern background pattern
class BackgroundPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Create subtle geometric shapes and dots
    final paint =
        Paint()
          ..color = const Color(0xFF9AFF00).withOpacity(0.03)
          ..style = PaintingStyle.fill;

    final strokePaint =
        Paint()
          ..color = const Color(0xFF9AFF00).withOpacity(0.05)
          ..strokeWidth = 1
          ..style = PaintingStyle.stroke;

    // Draw floating circles
    final random = [0.2, 0.7, 0.3, 0.8, 0.1, 0.9, 0.4, 0.6];
    for (int i = 0; i < 8; i++) {
      final x = size.width * random[i];
      final y = size.height * random[(i + 2) % 8];
      final radius = 20 + (i * 10);

      canvas.drawCircle(Offset(x, y), radius.toDouble(), paint);
    }

    // Draw subtle wave patterns
    final path = Path();
    path.moveTo(0, size.height * 0.2);

    for (double x = 0; x <= size.width; x += 50) {
      final y = size.height * 0.2 + (sin(x / 100) * 30) + (sin(x / 200) * 20);
      path.lineTo(x, y);
    }
    canvas.drawPath(path, strokePaint);

    // Another wave at different position
    final path2 = Path();
    path2.moveTo(0, size.height * 0.8);

    for (double x = 0; x <= size.width; x += 50) {
      final y =
          size.height * 0.8 +
          (sin((x + 100) / 120) * 25) +
          (sin((x + 200) / 180) * 15);
      path2.lineTo(x, y);
    }
    canvas.drawPath(path2, strokePaint);

    // Add some hexagonal shapes
    final hexPaint =
        Paint()
          ..color = const Color(0xFF9AFF00).withOpacity(0.02)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1;

    // Draw a few hexagons
    drawHexagon(
      canvas,
      hexPaint,
      Offset(size.width * 0.1, size.height * 0.3),
      25,
    );
    drawHexagon(
      canvas,
      hexPaint,
      Offset(size.width * 0.9, size.height * 0.7),
      30,
    );
    drawHexagon(
      canvas,
      hexPaint,
      Offset(size.width * 0.7, size.height * 0.1),
      20,
    );
  }

  void drawHexagon(Canvas canvas, Paint paint, Offset center, double radius) {
    final path = Path();
    for (int i = 0; i < 6; i++) {
      final angle = (i * 60) * (pi / 180);
      final x = center.dx + radius * cos(angle);
      final y = center.dy + radius * sin(angle);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Location Bar Widget
class LocationBar extends StatefulWidget {
  const LocationBar({super.key});

  @override
  State<LocationBar> createState() => _LocationBarState();
}

class _LocationBarState extends State<LocationBar> {
  String _text = '';
  String _remedy = '';
  bool _busy = false;
  

  final Map<String, List<String>> _remedyMap = {
    'clear': [
      "Drink coconut water to stay cool.",
      "Apply aloe vera gel to soothe sun-exposed skin.",
      "Use rose water as a toner to refresh your face.",
      "Consume cucumber or watermelon slices to stay hydrated.",
      "Wear cotton clothes to allow skin to breathe.",
      "Use sandalwood paste to calm skin irritation.",
      "Practice sheetali pranayama (cooling breath).",
      "Avoid oily foods during hot weather.",
      "Drink coriander seed water for body heat control.",
      "Take amla juice to boost immunity and refreshment.",
      "Apply turmeric paste for minor sunburn relief.",
      "Soak feet in cool water with mint leaves.",
      "Use neem oil for heat rashes.",
      "Drink lemon-honey water every morning.",
      "Eat pomegranate to boost digestion in heat.",
      "Avoid caffeine in summer as it dehydrates.",
      "Take early morning walks instead of evening.",
      "Use vetiver (khus) root-infused water.",
      "Massage with cooling oils like coconut.",
      "Consume buttermilk for digestion and cooling.",
    ],
    'clouds': [
      "Do light yoga or stretching indoors.",
      "Drink warm ginger tea to uplift mood.",
      "Eat soups with turmeric and garlic.",
      "Practice pranayama to reduce lethargy.",
      "Take light meals to improve digestion.",
      "Use sesame oil for abhyanga (body massage).",
      "Stay active to combat sluggishness.",
      "Avoid heavy dairy during cloudy weather.",
      "Drink cinnamon tea to stay warm and alert.",
      "Use tulsi (holy basil) to reduce kapha buildup.",
      "Diffuse eucalyptus oil for mental clarity.",
      "Practice meditation to improve mood.",
      "Drink warm water with lemon in the morning.",
      "Consume triphala at night for detox.",
      "Add asafoetida (hing) to meals for digestion.",
      "Burn camphor or incense to energize your space.",
      "Avoid sleeping during the day.",
      "Do brisk walks in fresh air if not raining.",
      "Take golden milk (haldi + milk) at bedtime.",
      "Chew fennel seeds post meals to aid digestion.",
    ],
    'rain': [
      "Drink tulsi-ginger tea to prevent cold.",
      "Avoid raw foods to prevent indigestion.",
      "Use clove oil if you feel cold symptoms.",
      "Keep feet dry and warm to avoid infection.",
      "Drink ajwain (carom seed) water after meals.",
      "Use mustard oil for body massage in damp weather.",
      "Avoid street food during monsoons.",
      "Eat warm khichdi with ghee for balance.",
      "Apply eucalyptus balm for sinus relief.",
      "Take steam with mint and tulsi leaves.",
      "Dry clothes properly to avoid skin rashes.",
      "Drink warm cumin water to avoid bloating.",
      "Avoid curd at night.",
      "Eat more garlic and pepper in meals.",
      "Keep your surroundings dry and ventilated.",
      "Drink hot soups with spices.",
      "Avoid walking barefoot.",
      "Use ginger-honey paste for sore throat.",
      "Include cinnamon in your tea.",
      "Take a teaspoon of chawanprash daily.",
    ],
    'mist': [
      "Inhale eucalyptus or peppermint oil steam.",
      "Wear layers to maintain body warmth.",
      "Avoid early morning exposure.",
      "Drink warm golden milk before bed.",
      "Use mustard oil to massage chest for congestion.",
      "Do gentle indoor exercise to stay warm.",
      "Apply warm sesame oil to the chest.",
      "Practice kapalbhati for respiratory health.",
      "Avoid cold water; prefer warm sips.",
      "Add clove and cinnamon to your tea.",
      "Use a humidifier indoors if needed.",
      "Massage sinuses with warm ghee.",
      "Avoid dairy-heavy meals.",
      "Take warm showers to prevent stiffness.",
      "Burn camphor to purify air indoors.",
      "Eat ginger-based meals.",
      "Drink tulsi-infused tea.",
      "Practice anulom-vilom breathing.",
      "Use an oil lamp with ayurvedic oils.",
      "Take herbal kadha twice a week.",
    ],
    'thunderstorm': [
      "Stay indoors and sip warm ginger tea.",
      "Avoid heavy or oily foods during stormy weather.",
      "Do deep breathing to reduce anxiety.",
      "Eat light kichadi to calm vata dosha.",
      "Take warm water with ajwain.",
      "Use Brahmi oil on the forehead to stay calm.",
      "Diffuse lavender oil for nervous tension.",
      "Practice guided meditation to reduce stress.",
      "Avoid screen time during thunder to reduce sensory overload.",
      "Do foot massage with ghee before sleep.",
      "Use a weighted blanket for comfort.",
      "Chew cardamom after meals.",
      "Avoid caffeine; opt for herbal drinks.",
      "Eat ripe banana to calm nerves.",
      "Use jatamansi oil on temples for calm.",
      "Soak in warm bath with Epsom salt.",
      "Burn bay leaf for aroma therapy.",
      "Sleep early and wake with sunrise.",
      "Avoid sleeping during the day.",
      "Practice tratak (candle gazing) to calm the mind.",
    ],
    'snow': [
      "Drink hot ginger-turmeric decoction daily.",
      "Massage with warm sesame oil in the morning.",
      "Avoid refrigerated or cold food.",
      "Eat garlic-rich soups.",
      "Wear wool to retain body heat.",
      "Drink honey with warm water in morning.",
      "Consume jaggery and peanuts.",
      "Use ghee in meals to keep body lubricated.",
      "Drink basil tea to boost immunity.",
      "Take warm steam with tulsi.",
      "Avoid curd and buttermilk.",
      "Add nutmeg in warm milk at bedtime.",
      "Use dry ginger powder in meals.",
      "Avoid long exposure to cold wind.",
      "Eat dry fruits soaked in warm milk.",
      "Burn mustard seeds in ghee for aroma.",
      "Stay active indoors.",
      "Eat bajra (millet) roti for warmth.",
      "Consume saffron milk before bed.",
      "Keep feet and ears covered.",
    ],
    'drizzle': [
      "Take tulsi & ginger herbal decoction.",
      "Avoid ice-cold beverages.",
      "Drink warm fennel and ajwain tea.",
      "Apply warm mustard oil on chest.",
      "Eat soups with turmeric and pepper.",
      "Avoid raw leafy vegetables.",
      "Gargle with warm salt water.",
      "Use steam with eucalyptus oil.",
      "Take trikatu (ginger-pepper-long pepper) before meals.",
      "Drink cinnamon & clove tea.",
      "Apply camphor balm for congestion.",
      "Avoid curd at night.",
      "Add garlic and onion to your meals.",
      "Use ghee-based nasal drops (nasya).",
      "Keep your feet dry and warm.",
      "Take amla (Indian gooseberry) daily.",
      "Do gentle surya namaskar indoors.",
      "Drink warm water throughout the day.",
      "Avoid sleeping in damp places.",
      "Burn neem leaves for fumigation.",
    ],
    'fog': [
      "Avoid early morning walks.",
      "Drink warm water with lemon daily.",
      "Use turmeric and ginger in food.",
      "Take a hot water bath in morning.",
      "Wear full-sleeve warm clothes.",
      "Massage body with sesame oil.",
      "Avoid sleeping during the day.",
      "Drink tulsi-cardamom tea.",
      "Take deep nasal breaths indoors.",
      "Diffuse clove oil in room.",
      "Use nasal oil drops before going out.",
      "Stay active to avoid stiffness.",
      "Burn cow dung or dried herbs for aroma.",
      "Do gentle yoga indoors.",
      "Consume raisins soaked in warm water.",
      "Chew ajwain seeds post meals.",
      "Avoid oily and stale food.",
      "Take amrutarishta (immunity tonic).",
      "Use woolen caps to protect sinuses.",
      "Eat easily digestible foods.",
    ],
    'dust': [
      "Use nose masks when outdoors.",
      "Drink licorice tea for throat relief.",
      "Apply coconut oil inside nostrils.",
      "Gargle with alum water.",
      "Eat turmeric-honey paste.",
      "Avoid outdoor exercise.",
      "Use neem oil for face cleansing.",
      "Take warm water with ginger juice.",
      "Consume jaggery with ghee.",
      "Wash face with triphala decoction.",
      "Chew mulethi (licorice root) stick.",
      "Take sitopaladi churna for cough.",
      "Drink coriander seed decoction.",
      "Burn dried turmeric for smoke therapy.",
      "Eat amla candies for lungs.",
      "Use turmeric nasal drops.",
      "Drink basil-lemon herbal tea.",
      "Avoid fried food in dusty season.",
      "Stay hydrated and keep lips moist.",
      "Clean nostrils with saline spray.",
    ],
    'smoke': [
      "Avoid exposure to traffic fumes.",
      "Take turmeric milk at night.",
      "Use ayurvedic nasal oil (Anu taila).",
      "Eat fresh fruits rich in antioxidants.",
      "Drink tulsi-lemon tea.",
      "Do anulom-vilom breathing indoors.",
      "Eat pomegranate to cleanse lungs.",
      "Avoid grilling food indoors.",
      "Use air purifier if available.",
      "Keep tulsi plants indoors.",
      "Use sandalwood paste on forehead.",
      "Eat coriander chutney to reduce pitta.",
      "Consume ghee-laced khichdi.",
      "Take ashwagandha for energy.",
      "Burn camphor for air purification.",
      "Gargle with warm saline water.",
      "Wash face and hands regularly.",
      "Avoid strenuous activities outdoors.",
      "Do oil pulling with sesame oil.",
      "Avoid spicy and fermented foods.",
    ],
    'haze': [
      "Use steam inhalation daily.",
      "Drink warm herbal kadha.",
      "Use rose water for eye cooling.",
      "Apply almond oil inside nostrils.",
      "Chew clove to soothe throat.",
      "Take giloy (amrita) for immunity.",
      "Avoid excessive screen time.",
      "Use goggles and scarf when outdoors.",
      "Drink honey-lemon water each morning.",
      "Do kapalbhati pranayama indoors.",
      "Use neem decoction to cleanse skin.",
      "Avoid exposure to pollutants.",
      "Do neti kriya under guidance.",
      "Eat fresh guava or oranges.",
      "Take chawanprash in winter haze.",
      "Keep a bowl of water to humidify air.",
      "Inhale mint steam to open nostrils.",
      "Wash eyes with cold water.",
      "Drink tulsi-ginger tea daily.",
      "Avoid yogurt and cold foods.",
    ],
    'default': [
      "Drink warm water with lemon every morning.",
      "Avoid processed sugar & fried food.",
      "Do daily abhyanga with sesame oil.",
      "Use triphala powder before bed.",
      "Practice deep breathing daily.",
      "Take ginger-turmeric decoction.",
      "Sleep early and rise with sunrise.",
      "Eat seasonal and local food.",
      "Avoid skipping meals.",
      "Chew fennel seeds after meals.",
      "Massage feet with ghee before bed.",
      "Use cow ghee in food for nourishment.",
      "Do yoga 3 times a week.",
      "Avoid overeating.",
      "Stay hydrated throughout the day.",
      "Use copper vessel for drinking water.",
      "Spend time in nature or sunlight.",
      "Use rock salt instead of table salt.",
      "Take short walks after meals.",
      "Practice gratitude and silence daily.",
    ],
    'clear': [
      "Drink lemon water with honey in the morning.",
      "Apply aloe vera gel on exposed skin.",
      "Avoid spicy, oily, and fried food.",
      "Use rose water to cool your eyes.",
      "Eat fresh seasonal fruits like watermelon.",
      "Use sandalwood paste on forehead for heat.",
      "Soak feet in cold water after going out.",
      "Consume buttermilk after lunch.",
      "Use fennel tea for cooling digestion.",
      "Avoid going out during peak sunlight hours.",
      "Massage scalp with coconut oil weekly.",
      "Take coconut water for hydration.",
      "Eat cucumber with black salt.",
      "Use gulkand (rose petal jam) daily.",
      "Wear light, breathable cotton clothes.",
      "Take a cold shower twice a day.",
      "Add mint chutney to meals.",
      "Take amla juice in the morning.",
      "Avoid direct exposure to harsh sun.",
      "Use cooling herbs like coriander & vetiver.",
    ],
  };
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final l10n = AppLocalizations.of(context)!;
      setState(() => _text = l10n.locationFetching);
      _refreshLocation();
    });
  }

  Future<void> _refreshLocation() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() {
      _busy = true;
      _remedy = '';
    });

    LocationPermission perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
    }

    if (perm == LocationPermission.denied ||
        perm == LocationPermission.deniedForever) {
      setState(() {
        _text = l10n.locationDenied;
        _busy = false;
      });
      return;
    }

    try {
      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.bestForNavigation,
      );
      final placemarks = await placemarkFromCoordinates(
        pos.latitude,
        pos.longitude,
      );

      String? address;
      String? city;
      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        city = p.locality;
        address = [
          if (p.street?.isNotEmpty ?? false) p.street,
          if (p.subLocality?.isNotEmpty ?? false) p.subLocality,
          if (p.locality?.isNotEmpty ?? false) p.locality,
          if (p.administrativeArea?.isNotEmpty ?? false) p.administrativeArea,
          if (p.postalCode?.isNotEmpty ?? false) p.postalCode,
        ].where((s) => s != null && s!.trim().isNotEmpty).join(', ');
      }

      setState(() {
        _text =
            address?.isNotEmpty == true
                ? address!
                : 'Lat: ${pos.latitude.toStringAsFixed(6)}, Lon: ${pos.longitude.toStringAsFixed(6)}';
      });

      if (city != null) {
        await _fetchRemedy(city);
      }
    } catch (_) {
      setState(() => _text = l10n.locationUnavailable);
    } finally {
      setState(() => _busy = false);
    }
  }

  Future<void> _fetchRemedy(String city) async {
    final apiKey = '2da60aa52aed4523dbca6d31deb340c9';
    final url =
        'https://api.openweathermap.org/data/2.5/weather?q=$city&appid=$apiKey&units=metric';

    try {
      final client = HttpClient();
      final request = await client.getUrl(Uri.parse(url));
      final response = await request.close();

      if (response.statusCode == 200) {
        final responseBody = await response.transform(utf8.decoder).join();
        final data = jsonDecode(responseBody);
        final condition = data['weather'][0]['main'].toString().toLowerCase();

        final remedies = _remedyMap[condition] ?? _remedyMap['default']!;
        remedies.shuffle(); // shuffle for new remedy on every app open
        Provider.of<RemedyProvider>(
          context,
          listen: false,
        ).setRemedy(remedies.first);
      } else {
        setState(() => _remedy = '⚠️ Weather info unavailable.');
      }
    } catch (e) {
      setState(() => _remedy = '⚠️ Remedy info unavailable.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return Column(
      children: [
        AnimatedCard(
          padding: const EdgeInsets.only(right: 4),
          child: Row(
            children: [
              IconButton(
                onPressed: _busy ? null : _refreshLocation,
                icon:
                    _busy
                        ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Color(0xFF9AFF00),
                            ),
                          ),
                        )
                    : Icon(Icons.refresh, color: themeProvider.primaryColor),
              ),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.only(right: 8),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      _text,
                      style: TextStyle(fontSize: 15, color: themeProvider.textColor),
                      overflow: TextOverflow.visible,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// ─────────────────────────
/// Page stubs for the other tabs
/// ─────────────────────────
class ChatPage extends StatelessWidget {
  const ChatPage({super.key});
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Container(
      color: Colors.transparent,
      child: Center(
        child: Text(
          'Chat page', 
          style: TextStyle(color: themeProvider.textColor),
        ),
      ),
    );
  }
}

// class MapPage extends StatelessWidget {
//   const MapPage({super.key});
//   @override
//   Widget build(BuildContext context) => Container(
//     color: const Color(0xFF0A0A0A),
//     child: const Center(
//       child: Text('Map / Nearby', style: TextStyle(color: Colors.white)),
//     ),
//   );
// }
