import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/message.dart';
import '../services/chat_service.dart';
import 'package:provider/provider.dart';
import '../locale_provider.dart';
import '../providers/theme_provider.dart';
import '../shared/theme/app_theme.dart';
import 'dart:math' as math;

class VoiceScreen extends StatefulWidget {
  const VoiceScreen({Key? key}) : super(key: key);

  @override
  State<VoiceScreen> createState() => _VoiceScreenState();
}

class _VoiceScreenState extends State<VoiceScreen>
    with TickerProviderStateMixin {
  // Speech Recognition
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _recognizedText = '';
  String _botResponse = '';
  double _confidence = 1.0;
  bool _isProcessing = false;

  // Text to Speech
  late FlutterTts _flutterTts;
  bool _isSpeaking = false;
  
  // Audio level detection
  double _currentSoundLevel = 0.0;
  bool _hasAudioActivity = false;

  // Simplified Animation Controllers
  late AnimationController _pulseController;
  late AnimationController _breathingController;
  late AnimationController _gradientController;
  late AnimationController _textController;
  late AnimationController _rippleController;
  
  // Animations
  late Animation<double> _pulseAnimation;
  late Animation<double> _breathingAnimation;
  late Animation<double> _fadeInAnimation;
  late Animation<double> _gradientAnimation;
  late Animation<double> _rippleAnimation;

  // Language mapping from locale codes to speech recognition codes
  final Map<String, String> _localeToSpeechCode = {
    'en': 'en-US',
    'hi': 'hi-IN',
    'gu': 'gu-IN',
    'mr': 'mr-IN',
    'ta': 'ta-IN',
    'te': 'te-IN',
    'ml': 'ml-IN',
    'bn': 'bn-IN',
    'kn': 'kn-IN',
    'pa': 'pa-IN',
    'or': 'or-IN',
    'as': 'as-IN',
  };

  // Language names mapping
  final Map<String, String> _localeToLanguage = {
    'en': 'English',
    'hi': 'Hindi',
    'gu': 'Gujarati',
    'mr': 'Marathi',
    'ta': 'Tamil',
    'te': 'Telugu',
    'ml': 'Malayalam',
    'bn': 'Bengali',
    'kn': 'Kannada',
    'pa': 'Punjabi',
    'or': 'Odia',
    'as': 'Assamese',
  };

  // Quick action suggestions
  final List<String> _quickActions = [
    'Turn off the light',
    'Turn on the air conditioner',
    'What\'s the weather?',
    'Set a timer for 5 minutes',
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeSpeech();
    _initializeTts();
  }

  void _initializeAnimations() {
    // Simplified pulse animation for listening state
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _textController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // Gentle breathing animation for idle state
    _breathingController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat(reverse: true);

    // Background animations
    _gradientController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    )..repeat();

    // Ripple effect animation
    _rippleController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // Smoother pulse animation - scales from 1.0 to 1.15
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.15,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _fadeInAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _textController,
      curve: Curves.easeOut,
    ));

    // Gentle breathing animation for idle state
    _breathingAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _breathingController,
      curve: Curves.easeInOut,
    ));

    _gradientAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _gradientController, curve: Curves.easeInOut),
    );

    _rippleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _rippleController, curve: Curves.easeOut),
    );

    _textController.forward();
  }

  void _initializeSpeech() async {
    _speech = stt.SpeechToText();
    bool available = await _speech.initialize(
      onStatus: (val) {
        setState(() {
          _isListening = val == 'listening';
        });
        if (val == 'listening') {
          _pulseController.repeat(reverse: true);
          _rippleController.repeat();
          _breathingController.stop();
        } else {
          _pulseController.stop();
          _pulseController.reset();
          _rippleController.stop();
          _rippleController.reset();
          if (!_isSpeaking && !_isProcessing) {
            _breathingController.repeat(reverse: true);
          }
        }
      },
      onError: (val) {
        setState(() {
          _isListening = false;
          _isProcessing = false;
        });
        _pulseController.stop();
        _pulseController.reset();
        _rippleController.stop();
        _rippleController.reset();
        _breathingController.repeat(reverse: true);
        _showSnackBar('Speech recognition error: ${val.errorMsg}');
      },
    );
    
    if (!available) {
      _showSnackBar('Speech recognition not available');
    }
  }

  void _initializeTts() async {
    _flutterTts = FlutterTts();
    
    final currentLocale = Provider.of<LocaleProvider>(context, listen: false).locale;
    final speechCode = _localeToSpeechCode[currentLocale.languageCode] ?? 'en-US';
    
    await _flutterTts.setLanguage(speechCode);
    await _flutterTts.setPitch(1.0);
    await _flutterTts.setSpeechRate(0.5);
    
    _flutterTts.setStartHandler(() {
      setState(() {
        _isSpeaking = true;
        _hasAudioActivity = true;
      });
      _breathingController.stop();
      _pulseController.repeat(reverse: true);
      _rippleController.repeat();
    });
    
    _flutterTts.setCompletionHandler(() {
      setState(() {
        _isSpeaking = false;
        _hasAudioActivity = false;
      });
      _pulseController.stop();
      _pulseController.reset();
      _rippleController.stop();
      _rippleController.reset();
      _breathingController.repeat(reverse: true);
    });
    
    _flutterTts.setErrorHandler((msg) {
      setState(() {
        _isSpeaking = false;
        _hasAudioActivity = false;
      });
      _pulseController.stop();
      _pulseController.reset();
      _rippleController.stop();
      _rippleController.reset();
      _breathingController.repeat(reverse: true);
    });
  }

  String _getCurrentLanguage() {
    final currentLocale = Provider.of<LocaleProvider>(context, listen: false).locale;
    return _localeToLanguage[currentLocale.languageCode] ?? 'English';
  }

  Future<void> _processVoiceInput(String text) async {
    if (text.trim().isEmpty) return;

    setState(() {
      _isProcessing = true;
      _isListening = false;
    });

    _pulseController.stop();
    _pulseController.reset();
    _rippleController.stop();
    _rippleController.reset();
    _breathingController.stop();

    try {
      final currentLanguage = _getCurrentLanguage();
      final botResponse = await ChatService.sendMessage(text.trim(), currentLanguage);
      
      setState(() {
        _recognizedText = text;
        _botResponse = botResponse.text;
      });

      // Speak the response
      await _speak(botResponse.text);

    } catch (e) {
      _showSnackBar('Error: ${e.toString().replaceFirst('Exception: ', '')}');
      await _speak('Sorry, I encountered an error processing your request.');
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  Future<void> _speak(String text) async {
    if (text.isNotEmpty) {
      final currentLocale = Provider.of<LocaleProvider>(context, listen: false).locale;
      final speechCode = _localeToSpeechCode[currentLocale.languageCode] ?? 'en-US';
      
      await _flutterTts.setLanguage(speechCode);
      await _flutterTts.speak(text);
    }
  }

  void _showSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(seconds: 2),
          backgroundColor: Colors.black87,
        ),
      );
    }
  }

  void _startListening() async {
    if (!_isListening && !_isProcessing && !_isSpeaking) {
      bool available = await _speech.initialize();
      if (available) {
        final currentLocale = Provider.of<LocaleProvider>(context, listen: false).locale;
        final speechCode = _localeToSpeechCode[currentLocale.languageCode] ?? 'en-US';
        
        _speech.listen(
          onResult: (val) {
            setState(() {
              _recognizedText = val.recognizedWords;
              if (val.hasConfidenceRating && val.confidence > 0) {
                _confidence = val.confidence;
              }
            });
            if (val.finalResult) {
              _processVoiceInput(val.recognizedWords);
            }
          },
          onSoundLevelChange: (level) {
            setState(() {
              _currentSoundLevel = level.clamp(0.0, 1.0);
              _hasAudioActivity = level > 0.1;
            });
          },
          localeId: speechCode,
        );
      }
    } else if (_isListening) {
      _speech.stop();
    }
  }

  void _handleQuickAction(String action) {
    _processVoiceInput(action);
  }

  // Helper method to get the current theme-aware primary color
  Color _getThemeAwarePrimaryColor(ThemeProvider themeProvider) {
    return themeProvider.isDarkMode 
        ? LunaColorScheme.primaryGreen 
        : const Color(0xFF2B2B2B);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _textController.dispose();
    _breathingController.dispose();
    _gradientController.dispose();
    _rippleController.dispose();
    _speech.cancel();
    _flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final isDark = themeProvider.isDarkMode;
        final colors = isDark ? LunaColors.dark : LunaColors.light;
        final primaryColor = _getThemeAwarePrimaryColor(themeProvider);
        
        return Scaffold(
          body: AnimatedBuilder(
            animation: _gradientAnimation,
            builder: (context, child) {
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isDark
                        ? [
                            BackgroundAnimate.darkBackgroundStart,
                            BackgroundAnimate.darkBackgroundMid.withOpacity(
                              0.8 + (math.sin(_gradientAnimation.value * 2 * math.pi) * 0.1),
                            ),
                            const Color(0xFF0A0A0A),
                          ]
                        : [
                            BackgroundAnimate.lightBackgroundStart,
                            BackgroundAnimate.lightBackgroundMid.withOpacity(
                              0.8 + (math.sin(_gradientAnimation.value * 2 * math.pi) * 0.1),
                            ),
                            const Color(0xFFFAFAFA),
                          ],
                    stops: [
                      0.0,
                      0.5,
                      1.0,
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    children: [
                      // Header with back button
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Row(
                          children: [
                            IconButton(
                              icon: Icon(Icons.arrow_back, color: colors.textPrimary),
                              onPressed: () => Navigator.pop(context),
                            ),
                            Expanded(
                              child: Text(
                                'Voice Assistant',
                                style: TextStyle(
                                  color: colors.textPrimary,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            SizedBox(width: 48), // Balance the back button
                          ],
                        ),
                      ),

                      // Quick action chips
                      if (!_isListening && !_isProcessing && !_isSpeaking)
                        Container(
                          height: 50,
                          margin: EdgeInsets.symmetric(vertical: 16),
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            itemCount: _quickActions.length,
                            itemBuilder: (context, index) {
                              return Container(
                                margin: EdgeInsets.only(right: 12),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: () => _handleQuickAction(_quickActions[index]),
                                    borderRadius: BorderRadius.circular(25),
                                    child: Container(
                                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                      decoration: BoxDecoration(
                                        color: colors.primary.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(25),
                                        border: Border.all(
                                          color: colors.primary.withOpacity(0.3),
                                          width: 1,
                                        ),
                                      ),
                                      child: Text(
                                        _quickActions[index],
                                        style: TextStyle(
                                          color: colors.textPrimary,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),

                      // Greeting
                      FadeTransition(
                        opacity: _fadeInAnimation,
                        child: Column(
                          children: [
                            Text(
                              'Hi, Anastasia',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w400,
                                color: colors.textSecondary,
                              ),
                            ),
                            SizedBox(height: 16),
                            Text(
                              'SAY SOMETHING',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w600,
                                color: colors.textPrimary,
                                letterSpacing: 2.0,
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 40),

                      // Elegant Luna Logo Orb with Ripple Effects
                      Expanded(
                        flex: 2,
                        child: Center(
                          child: GestureDetector(
                            onTap: _startListening,
                            child: Container(
                              width: 280,
                              height: 280,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  // Elegant ripple effects when listening/speaking
                                  if (_hasAudioActivity && (_isListening || _isSpeaking))
                                    CustomPaint(
                                      size: Size(280, 280),
                                      painter: RippleEffectPainter(
                                        animation: _rippleController,
                                        color: primaryColor,
                                        isListening: _isListening,
                                        isSpeaking: _isSpeaking,
                                      ),
                                    ),

                                  // Main orb with clean scaling
                                  AnimatedBuilder(
                                    animation: Listenable.merge([
                                      _pulseAnimation,
                                      _breathingAnimation,
                                    ]),
                                    builder: (context, child) {
                                      double scale = 1.0;
                                      
                                      if (_isListening || _isSpeaking) {
                                        scale = _pulseAnimation.value;
                                      } else if (!_isProcessing) {
                                        scale = _breathingAnimation.value;
                                      }

                                      return Transform.scale(
                                        scale: scale,
                                        child: Container(
                                          width: 180,
                                          height: 180,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: primaryColor.withOpacity(
                                                _isListening || _isSpeaking ? 0.8 : 0.4
                                              ),
                                              width: 3,
                                            ),
                                            color: colors.surface.withOpacity(0.9),
                                            boxShadow: [
                                              BoxShadow(
                                                color: primaryColor.withOpacity(
                                                  _isListening || _isSpeaking ? 0.3 : 0.1
                                                ),
                                                blurRadius: 20,
                                                spreadRadius: 5,
                                              ),
                                            ],
                                          ),
                                          child: Center(
                                            child: Container(
                                              width: 120,
                                              height: 120,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: colors.background.withOpacity(0.1),
                                              ),
                                              child: Center(
                                                child: _buildLunaLogo(primaryColor),
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Status text
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 32),
                        child: Text(
                          _getDisplayText(),
                          style: TextStyle(
                            color: colors.textSecondary,
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),

                      SizedBox(height: 20),

                      // Bot response area
                      if (_botResponse.isNotEmpty)
                        Expanded(
                          flex: 1,
                          child: Container(
                            margin: EdgeInsets.symmetric(horizontal: 32),
                            padding: EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: colors.surface.withOpacity(0.8),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: colors.primary.withOpacity(0.2),
                              ),
                            ),
                            child: SingleChildScrollView(
                              child: Text(
                                _botResponse,
                                style: TextStyle(
                                  color: colors.textPrimary,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                  height: 1.4,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),

                      // Bottom controls
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            // Chat button
                            _buildBottomButton(
                              icon: Icons.chat_bubble_outline,
                              onTap: () {},
                              colors: colors,
                            ),

                            // Center microphone button
                            GestureDetector(
                              onTap: _startListening,
                              child: Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: isDark 
                                        ? [
                                            LunaColorScheme.primaryGreen,
                                            LunaColorScheme.secondaryGreen
                                          ]
                                        : [
                                            const Color(0xFF2B2B2B),
                                            const Color(0xFF404040),
                                          ],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: primaryColor.withOpacity(0.4),
                                      blurRadius: 20,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  _getButtonIcon(),
                                  color: Colors.white,
                                  size: 32,
                                ),
                              ),
                            ),

                            // Close button
                            _buildBottomButton(
                              icon: Icons.close,
                              onTap: () => Navigator.pop(context),
                              colors: colors,
                            ),
                          ],
                        ),
                      ),

                      // Language indicator
                      Container(
                        margin: EdgeInsets.only(bottom: 20),
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: colors.surface.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: colors.primary.withOpacity(0.2),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.language,
                              color: colors.textSecondary,
                              size: 14,
                            ),
                            SizedBox(width: 6),
                            Text(
                              _getCurrentLanguage(),
                              style: TextStyle(
                                color: colors.textPrimary,
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildLunaLogo(Color primaryColor) {
    // Try to load the asset, fallback to text if not available
    return FutureBuilder(
      future: _checkAssetExists('assets/Luna.png'),
      builder: (context, snapshot) {
        if (snapshot.data == true) {
          return Image.asset(
            'assets/Luna.png',
            width: 60,
            height: 60,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return _buildFallbackLogo(primaryColor);
            },
          );
        } else {
          return _buildFallbackLogo(primaryColor);
        }
      },
    );
  }

  Widget _buildFallbackLogo(Color primaryColor) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: primaryColor,
      ),
      child: Center(
        child: Text(
          'L',
          style: TextStyle(
            color: Colors.white,
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Future<bool> _checkAssetExists(String path) async {
    try {
      await DefaultAssetBundle.of(context).load(path);
      return true;
    } catch (e) {
      return false;
    }
  }

  Widget _buildBottomButton({
    required IconData icon,
    required VoidCallback onTap,
    required LunaColors colors,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: colors.surface.withOpacity(0.8),
          border: Border.all(
            color: colors.primary.withOpacity(0.3),
          ),
        ),
        child: Icon(
          icon,
          color: colors.textSecondary,
          size: 24,
        ),
      ),
    );
  }

  String _getDisplayText() {
    if (_isListening) {
      return 'Listening...';
    } else if (_isProcessing) {
      return 'Processing your request...';
    } else if (_isSpeaking) {
      return 'Speaking response...';
    } else {
      return 'Tap the Luna logo to speak with your AI assistant';
    }
  }

  IconData _getButtonIcon() {
    if (_isListening) {
      return Icons.mic;
    } else if (_isProcessing) {
      return Icons.psychology;
    } else if (_isSpeaking) {
      return Icons.volume_up;
    } else {
      return Icons.mic;
    }
  }
}

// Elegant ripple effect painter
class RippleEffectPainter extends CustomPainter {
  final AnimationController animation;
  final Color color;
  final bool isListening;
  final bool isSpeaking;

  RippleEffectPainter({
    required this.animation,
    required this.color,
    required this.isListening,
    required this.isSpeaking,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.width / 2 - 10;
    
    // Create multiple ripple rings
    for (int i = 0; i < 3; i++) {
      final progress = (animation.value + (i * 0.3)) % 1.0;
      final radius = maxRadius * progress;
      final opacity = (1.0 - progress) * 0.4;
      
      // Different colors for listening vs speaking
      final rippleColor = isListening 
          ? color.withOpacity(opacity)
          : color.withOpacity(opacity * 0.7);
      
      final paint = Paint()
        ..color = rippleColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;
      
      canvas.drawCircle(center, radius, paint);
    }
    
    // Add subtle glow effect
    if (isListening || isSpeaking) {
      final glowPaint = Paint()
        ..color = color.withOpacity(0.1)
        ..style = PaintingStyle.fill
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 10);
      
      canvas.drawCircle(center, 100, glowPaint);
    }
    
    // Add pulsing dots around the orb for extra elegance
    if (isListening) {
      final dotPaint = Paint()
        ..color = color
        ..style = PaintingStyle.fill;
      
      for (int i = 0; i < 8; i++) {
        final angle = (i / 8) * 2 * math.pi;
        final dotRadius = 110 + (math.sin(animation.value * 2 * math.pi + i) * 5);
        final dotSize = 3 + (math.sin(animation.value * 3 * math.pi + i) * 1);
        final opacity = 0.6 + (math.sin(animation.value * 4 * math.pi + i) * 0.4);
        
        final dotX = center.dx + dotRadius * math.cos(angle);
        final dotY = center.dy + dotRadius * math.sin(angle);
        
        dotPaint.color = color.withOpacity(opacity);
        canvas.drawCircle(Offset(dotX, dotY), dotSize, dotPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}