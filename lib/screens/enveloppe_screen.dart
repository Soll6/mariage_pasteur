import 'dart:math';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import '../widgets/wedding_bottom_nav.dart';

class EnveloppeScreen extends StatefulWidget {
  const EnveloppeScreen({super.key});

  @override
  State<EnveloppeScreen> createState() => _EnveloppeScreenState();
}

class _EnveloppeScreenState extends State<EnveloppeScreen>
    with TickerProviderStateMixin {
  late AnimationController _entryController;
  late AnimationController _floatController;

  late AnimationController _sealController;
  late AnimationController _ribbonController;
  late AnimationController _handController;

  late Animation<double> _fadeAnim;
  late Animation<double> _slideAnim;
  late Animation<double> _floatAnim;
  late Animation<double> _sealScaleAnim;
  late Animation<double> _ribbonAnim;
  late Animation<double> _handAnim;

  bool _isHovering = false;

  @override
  void initState() {
    super.initState();

    _entryController = AnimationController(
      duration: const Duration(milliseconds: 1600),
      vsync: this,
    );

    _floatController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    )..repeat(reverse: true);

    _sealController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _ribbonController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    _handController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat(reverse: true);

    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
          parent: _entryController,
          curve: const Interval(0, 0.6, curve: Curves.easeOut)),
    );

    _slideAnim = Tween<double>(begin: 60, end: 0).animate(
      CurvedAnimation(
          parent: _entryController,
          curve: const Interval(0.1, 0.7, curve: Curves.easeOutCubic)),
    );

    _floatAnim = Tween<double>(begin: -6, end: 6).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );

    _sealScaleAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _sealController, curve: Curves.elasticOut),
    );

    _ribbonAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _ribbonController, curve: Curves.easeInOut),
    );

    _handAnim = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _handController, curve: Curves.easeInOut),
    );

    _entryController.forward().then((_) {
      _sealController.forward();
    });
  }

  @override
  void dispose() {
    _entryController.dispose();
    _floatController.dispose();
    _sealController.dispose();
    _ribbonController.dispose();
    _handController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(
        children: [
          // Background satin image
          _buildSatinBackground(size),
          // Floating ribbon decorations
          _buildRibbons(size),
          // Main content
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: AnimatedBuilder(
                animation: _slideAnim,
                builder: (_, child) => Transform.translate(
                  offset: Offset(0, _slideAnim.value),
                  child: child,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(flex: 2),
                    _buildHeader(),
                    const SizedBox(height: 40),
                    _buildEnvelopeCard(),
                    const SizedBox(height: 48),
                    _buildCTAButtons(context),
                    const Spacer(flex: 3),
                    _buildFooter(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSatinBackground(Size size) {
    return Image.asset(
      'assets/images/satin.png',
      width: size.width,
      height: size.height,
      fit: BoxFit.cover,
    );
  }

  Widget _buildRibbons(Size size) {
    return AnimatedBuilder(
      animation: _ribbonAnim,
      builder: (_, __) {
        return CustomPaint(
          painter: _RibbonPainter(_ribbonAnim.value),
          size: size,
        );
      },
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        children: [
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [
                Color(0xFFB8860B),
                Color(0xFFDAA520),
                Color(0xFFFFD700),
                Color(0xFFDAA520)
              ],
              stops: [0.0, 0.3, 0.6, 1.0],
            ).createShader(bounds),
            child: Text(
              'Une invitation spéciale\nvous attend…',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'NotoSerif',
                fontSize: 26,
                fontWeight: FontWeight.w600,
                fontStyle: FontStyle.italic,
                color: Colors.white,
                height: 1.5,
                shadows: [
                  Shadow(
                    color: Colors.black.withValues(alpha: 0.5),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                  Shadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: Offset.zero,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'SONIA & AIMÉ FRANCIS',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 3.0,
              color: Color(0xFF914630),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnvelopeCard() {
    return AnimatedBuilder(
      animation: Listenable.merge([_floatAnim, _sealScaleAnim]),
      builder: (_, __) {
        return Transform.translate(
          offset: Offset(0, _floatAnim.value),
          child: MouseRegion(
            onEnter: (_) => setState(() => _isHovering = true),
            onExit: (_) => setState(() => _isHovering = false),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              transform: Matrix4.identity()
                ..translate(0.0, _isHovering ? -4.0 : 0.0),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Envelope shadow
                  Container(
                    width: 300,
                    height: 210,
                    margin: const EdgeInsets.only(top: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF914630).withOpacity(0.3),
                          blurRadius: 40,
                          spreadRadius: 5,
                          offset: const Offset(0, 20),
                        ),
                      ],
                    ),
                  ),
                  // Main envelope body
                  _buildEnvelopeBody(),
                  // Wax seal overlay
                  Positioned(
                    bottom: -2,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(
                              PageRouteBuilder(
                                pageBuilder: (ctx, anim, _) =>
                                    const WeddingBottomNav(),
                                transitionsBuilder: (ctx, anim, _, child) =>
                                    SplashToHomeTransition(
                                  animation: anim,
                                  child: child,
                                ),
                                transitionDuration:
                                    const Duration(milliseconds: 1000),
                              ),
                            );
                          },
                          child: Transform.scale(
                            scale: _sealScaleAnim.value,
                            child: _buildWaxSeal(),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Ouvrir l\'invitation',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                            color: const Color(0xFF914630).withOpacity(0.8),
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
      },
    );
  }

  Widget _buildEnvelopeBody() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: 300,
        height: 210,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFC87B5A),
              Color(0xFFB56B4A),
              Color(0xFFA85A38),
              Color(0xFF9E4E2C),
            ],
          ),
          border: Border.all(
            color: const Color(0xFFDAA520).withOpacity(0.3),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF5C2B15).withOpacity(0.25),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                gradient: RadialGradient(
                  center: const Alignment(-0.3, -0.5),
                  radius: 1.2,
                  colors: [
                    Colors.white.withOpacity(0.08),
                    Colors.transparent,
                    const Color(0xFF5C2B15).withOpacity(0.1),
                  ],
                ),
              ),
            ),
            Positioned.fill(
              child: Center(
                child: _build3DEnvelopeSimulation(),
              ),
            ),
            CustomPaint(
              painter: _EnvelopeFlapPainter(),
              size: const Size(300, 210),
            ),
            Positioned(
              top: 6,
              left: 0,
              right: 0,
              child: CustomPaint(
                painter: _FloralPainter(top: true),
                size: const Size(300, 70),
              ),
            ),
            Positioned(
              bottom: 28,
              left: 0,
              right: 0,
              child: CustomPaint(
                painter: _FloralPainter(top: false),
                size: const Size(300, 60),
              ),
            ),
            Positioned(
              left: 24,
              right: 24,
              bottom: 68,
              child: Container(
                height: 0.8,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      const Color(0xFFDAA520).withOpacity(0.6),
                      const Color(0xFFFFD700).withOpacity(0.8),
                      const Color(0xFFDAA520).withOpacity(0.6),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _build3DEnvelopeSimulation() {
    return SizedBox(
      width: 260,
      height: 190,
      child: ModelViewer(
        src: kIsWeb ? '/assets/assets/models/envelope.glb' : 'assets/models/envelope.glb',
        alt: 'Enveloppe mariage 3D',
        autoRotate: true,
        autoRotateDelay: 0,
        cameraControls: false,
        backgroundColor: Colors.transparent,
        rotationPerSecond: '20deg',
      ),
    );
  }

  Widget _buildWaxSeal() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const RadialGradient(
          center: Alignment(-0.3, -0.3),
          radius: 0.8,
          colors: [
            Color(0xFFD4845A),
            Color(0xFFB5582E),
            Color(0xFF8B3A1A),
            Color(0xFF6B2510),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6B2510).withOpacity(0.5),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.15),
            blurRadius: 4,
            offset: const Offset(-2, -2),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Decorative ring
          Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFFDAA520).withOpacity(0.4),
                width: 1.5,
              ),
            ),
          ),
          // Inner ring
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFFDAA520).withOpacity(0.3),
                width: 1,
              ),
            ),
          ),
          // S&A text
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [Color(0xFFDAA520), Color(0xFFFFD700), Color(0xFFDAA520)],
            ).createShader(bounds),
            child: const Text(
              'S&A',
              style: TextStyle(
                fontFamily: 'NotoSerif',
                fontSize: 20,
                fontWeight: FontWeight.w700,
                fontStyle: FontStyle.italic,
                color: Colors.white,
                letterSpacing: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCTAButtons(BuildContext context) {
    return AnimatedBuilder(
      animation: _handAnim,
      builder: (_, __) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Transform.scale(
              scale: _handAnim.value,
              child: const Icon(
                Icons.touch_app,
                size: 32,
                color: Color(0xFF914630),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Appuyez sur le sceau',
              style: TextStyle(
                fontSize: 11,
                fontStyle: FontStyle.italic,
                color: const Color(0xFF914630).withOpacity(0.5),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
                5,
                (i) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Container(
                        width: i == 2 ? 20 : 4,
                        height: 4,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(2),
                          color: i == 2
                              ? const Color(0xFF914630)
                              : const Color(0xFF914630).withOpacity(0.25),
                        ),
                      ),
                    )),
          ),
          const SizedBox(height: 12),
          const Text(
            '© 2026 Sonia & Aimé Francis · Fait avec amour',
            style: TextStyle(
              fontSize: 11,
              fontStyle: FontStyle.italic,
              color: Color(0xFF914630),
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Custom Painters ───────────────────────────────────────────────────────────

class _RibbonPainter extends CustomPainter {
  final double t;
  _RibbonPainter(this.t);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    // Left ribbon
    paint.color = const Color(0xFF914630).withOpacity(0.12 + t * 0.05);
    final leftPath = Path();
    leftPath.moveTo(-10, size.height * 0.1);
    leftPath.cubicTo(
      40 + t * 10,
      size.height * 0.25,
      -20 + t * 5,
      size.height * 0.45,
      60,
      size.height * 0.6,
    );
    leftPath.cubicTo(
      100 + t * 8,
      size.height * 0.75,
      20,
      size.height * 0.85,
      -10,
      size.height,
    );
    canvas.drawPath(leftPath, paint);

    // Right ribbon
    paint.color = const Color(0xFFDAA520).withOpacity(0.1 + t * 0.04);
    final rightPath = Path();
    rightPath.moveTo(size.width + 10, size.height * 0.05);
    rightPath.cubicTo(
      size.width - 50 - t * 8,
      size.height * 0.2,
      size.width + 15,
      size.height * 0.42,
      size.width - 60,
      size.height * 0.58,
    );
    rightPath.cubicTo(
      size.width - 100 - t * 6,
      size.height * 0.72,
      size.width - 20,
      size.height * 0.88,
      size.width + 10,
      size.height,
    );
    canvas.drawPath(rightPath, paint);

    // Top decorative arch ribbon
    paint
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = const Color(0xFFDAA520).withOpacity(0.15 + t * 0.06);
    final topRibbon = Path();
    topRibbon.moveTo(size.width * 0.1, -5);
    topRibbon.quadraticBezierTo(
        size.width * 0.5, 40 + t * 8, size.width * 0.9, -5);
    canvas.drawPath(topRibbon, paint);
  }

  @override
  bool shouldRepaint(_RibbonPainter old) => old.t != t;
}

class _EnvelopeFlapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..color = Colors.white.withOpacity(0.12);

    // Diagonal fold lines from corners to center bottom
    final centerX = size.width / 2;
    final sealY = size.height * 0.72;

    // Left fold
    canvas.drawLine(Offset(0, size.height), Offset(centerX, sealY), paint);
    // Right fold
    canvas.drawLine(
        Offset(size.width, size.height), Offset(centerX, sealY), paint);

    // Top flap fold line
    final flapPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8
      ..color = Colors.white.withOpacity(0.1);
    canvas.drawLine(Offset(0, size.height * 0.42),
        Offset(size.width, size.height * 0.42), flapPaint);

    // Top triangle flap shadow
    final flapPath = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2, size.height * 0.42)
      ..close();
    canvas.drawPath(
      flapPath,
      Paint()
        ..color = const Color(0xFF5C2B15).withOpacity(0.08)
        ..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(_EnvelopeFlapPainter old) => false;
}

class _FloralPainter extends CustomPainter {
  final bool top;
  _FloralPainter({required this.top});

  @override
  void paint(Canvas canvas, Size size) {
    _drawFlower(canvas, Offset(size.width * 0.12, size.height * 0.5), 18,
        const Color(0xFF8B3252), 0.7);
    _drawFlower(canvas, Offset(size.width * 0.88, size.height * 0.5), 16,
        const Color(0xFFAA4060), 0.6);
    _drawFlower(canvas, Offset(size.width * 0.5, size.height * 0.3), 12,
        const Color(0xFFDAA520), 0.5);
    _drawLeaf(canvas, Offset(size.width * 0.25, size.height * 0.6), 0.4);
    _drawLeaf(canvas, Offset(size.width * 0.75, size.height * 0.6), 0.4);
    _drawLeaf(canvas, Offset(size.width * 0.35, size.height * 0.35), 0.3);
    _drawLeaf(canvas, Offset(size.width * 0.65, size.height * 0.35), 0.3);
  }

  void _drawFlower(
      Canvas canvas, Offset center, double r, Color color, double opacity) {
    final paint = Paint()
      ..color = color.withOpacity(opacity)
      ..style = PaintingStyle.fill;
    for (int i = 0; i < 6; i++) {
      final angle = i * pi / 3;
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(center.dx + cos(angle) * r * 0.6,
              center.dy + sin(angle) * r * 0.6),
          width: r * 0.9,
          height: r * 1.3,
        ),
        paint,
      );
    }
    canvas.drawCircle(center, r * 0.3,
        Paint()..color = const Color(0xFFFFD700).withOpacity(opacity));
  }

  void _drawLeaf(Canvas canvas, Offset pos, double opacity) {
    final paint = Paint()
      ..color = const Color(0xFF4A6741).withOpacity(opacity)
      ..style = PaintingStyle.fill;
    final path = Path()
      ..moveTo(pos.dx, pos.dy - 10)
      ..quadraticBezierTo(pos.dx + 8, pos.dy, pos.dx, pos.dy + 10)
      ..quadraticBezierTo(pos.dx - 8, pos.dy, pos.dx, pos.dy - 10);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_FloralPainter old) => false;
}

// ─── Splash to Home Transition ───────────────────────────────────────────────

class SplashToHomeTransition extends StatelessWidget {
  final Animation<double> animation;
  final Widget child;

  const SplashToHomeTransition({
    super.key,
    required this.animation,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        final progress = Curves.easeOutCubic.transform(animation.value);
        final reveal = 1.0 - progress;
        final size = MediaQuery.of(context).size;
        final radius =
            lerpDouble(0, max(size.width, size.height) * 1.25, reveal)!;

        return Stack(
          children: [
            Transform.scale(
              scale: 0.94 + progress * 0.06,
              child: Opacity(
                opacity: progress,
                child: child,
              ),
            ),
            if (animation.value < 1.0)
              Positioned.fill(
                child: IgnorePointer(
                  child: Center(
                    child: ClipOval(
                      child: Container(
                        width: radius * 2,
                        height: radius * 2,
                        decoration: BoxDecoration(
                          gradient: RadialGradient(
                            colors: [
                              const Color(0xFFFFF3D6)
                                  .withOpacity(0.95 * reveal),
                              const Color(0xFFDAA520).withOpacity(0.5 * reveal),
                              Colors.transparent,
                            ],
                            stops: const [0.0, 0.35, 1.0],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
