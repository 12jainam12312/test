import 'package:flutter/material.dart';
import 'package:medical/shared/theme/app_theme.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import 'dart:math' as math;

class AnimatedBackground extends StatefulWidget {
  final Widget child;

  const AnimatedBackground({Key? key, required this.child}) : super(key: key);

  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground>
    with TickerProviderStateMixin {
  late AnimationController _gradientController;
  late AnimationController _particleController;
  late Animation<double> _gradientAnimation;

  @override
  void initState() {
    super.initState();
    
    _gradientController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    )..repeat();
    
    _particleController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();

    _gradientAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _gradientController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _gradientController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return AnimatedBuilder(
          animation: Listenable.merge([_gradientAnimation, _particleController]),
          builder: (context, child) {
            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: themeProvider.isDarkMode
                      ? [
                          BackgroundAnimate.darkBackgroundStart,
                          BackgroundAnimate.darkBackgroundMid.withOpacity(
                            0.8 + (math.sin(_gradientAnimation.value * 2 * math.pi) * 0.2),
                          ),
                          const Color(0xFF0A0A0A),
                        ]
                      : [
                          BackgroundAnimate.lightBackgroundStart,
                          BackgroundAnimate.lightBackgroundMid.withOpacity(
                            0.8 + (math.sin(_gradientAnimation.value * 2 * math.pi) * 0.2),
                          ),
                          const Color(0xFFFAFAFA),
                        ],
                  stops: [
                    0.0,
                    0.5 + (math.sin(_gradientAnimation.value * math.pi) * 0.3),
                    1.0,
                  ],
                ),
              ),
              child: Stack(
                children: [
                  // Floating particles
                  CustomPaint(
                    painter: ParticlePainter(
                      animation: _particleController,
                      isDarkMode: themeProvider.isDarkMode,
                      primaryColor: themeProvider.primaryColor,
                    ),
                    size: Size.infinite,
                  ),
                  widget.child,
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class ParticlePainter extends CustomPainter {
  final Animation<double> animation;
  final bool isDarkMode;
  final Color primaryColor;

  ParticlePainter({
    required this.animation,
    required this.isDarkMode,
    required this.primaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = primaryColor.withOpacity(isDarkMode ? 0.1 : 0.05)
      ..style = PaintingStyle.fill;

    // Create floating particles
    for (int i = 0; i < 15; i++) {
      final progress = (animation.value + (i * 0.1)) % 1.0;
      final x = (size.width * 0.1) + 
                (size.width * 0.8 * math.sin(progress * 2 * math.pi + i));
      final y = size.height * progress;
      final radius = 2 + (math.sin(progress * 4 * math.pi) * 3);

      canvas.drawCircle(
        Offset(x, y),
        radius,
        paint..color = primaryColor.withOpacity(
          (isDarkMode ? 0.1 : 0.05) * (1 - progress),
        ),
      );
    }

    // Create geometric shapes
    final shapePaint = Paint()
      ..color = primaryColor.withOpacity(isDarkMode ? 0.05 : 0.02)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    for (int i = 0; i < 5; i++) {
      final progress = (animation.value * 0.5 + (i * 0.2)) % 1.0;
      final centerX = size.width * (0.2 + (i * 0.15));
      final centerY = size.height * (0.3 + (progress * 0.4));
      final radius = 30 + (progress * 50);

      // Draw hexagon
      final path = Path();
      for (int j = 0; j < 6; j++) {
        final angle = (j * 60) * (math.pi / 180);
        final x = centerX + radius * math.cos(angle);
        final y = centerY + radius * math.sin(angle);
        
        if (j == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      path.close();
      
      canvas.drawPath(path, shapePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}