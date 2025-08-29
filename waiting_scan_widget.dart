import 'package:flutter/material.dart';
import 'dart:math' as math;

class WaitingScanWidget extends StatefulWidget {
  final VoidCallback? onScanPressed;
  final VoidCallback? onTestPressed;
  final bool showTestButton;

  const WaitingScanWidget({
    super.key,
    this.onScanPressed,
    this.onTestPressed,
    this.showTestButton = false,
  });

  @override
  State<WaitingScanWidget> createState() => _WaitingScanWidgetState();
}

class _WaitingScanWidgetState extends State<WaitingScanWidget>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _rotationController;
  late AnimationController _floatController;
  late AnimationController _shimmerController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _floatAnimation;
  late Animation<double> _shimmerAnimation;

  @override
  void initState() {
    super.initState();

    // Pulse animation for the main scanner icon
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 0.95,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    _pulseController.repeat(reverse: true);

    // Rotation animation for decorative elements
    _rotationController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    );
    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 2 * math.pi,
    ).animate(_rotationController);
    _rotationController.repeat();

    // Float animation for text
    _floatController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    _floatAnimation = Tween<double>(
      begin: -5,
      end: 5,
    ).animate(CurvedAnimation(
      parent: _floatController,
      curve: Curves.easeInOut,
    ));
    _floatController.repeat(reverse: true);

    // Shimmer animation for scan lines
    _shimmerController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _shimmerAnimation = Tween<double>(
      begin: -1,
      end: 2,
    ).animate(CurvedAnimation(
      parent: _shimmerController,
      curve: Curves.easeInOut,
    ));
    _shimmerController.repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rotationController.dispose();
    _floatController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Animated gradient background
        AnimatedBuilder(
          animation: _rotationAnimation,
          builder: (context, child) {
            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment(
                    math.cos(_rotationAnimation.value),
                    math.sin(_rotationAnimation.value),
                  ),
                  end: Alignment(
                    -math.cos(_rotationAnimation.value),
                    -math.sin(_rotationAnimation.value),
                  ),
                  colors: const [
                    Color(0xFF1E88E5),
                    Color(0xFF1565C0),
                    Color(0xFF0D47A1),
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
            );
          },
        ),

        // Subtle pattern overlay
        CustomPaint(
          painter: PatternPainter(animation: _rotationAnimation),
          child: Container(),
        ),

        // Main content
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 20),

              // Animated scanner icon with effects - made smaller
              SizedBox(
                width: 220,
                height: 220,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Outer rotating rings
                    AnimatedBuilder(
                      animation: _rotationAnimation,
                      builder: (context, child) {
                        return Transform.rotate(
                          angle: _rotationAnimation.value,
                          child: Container(
                            width: 200,
                            height: 200,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                width: 2,
                                color: Colors.white.withOpacity(0.1),
                              ),
                            ),
                          ),
                        );
                      },
                    ),

                    // Middle rotating ring
                    AnimatedBuilder(
                      animation: _rotationAnimation,
                      builder: (context, child) {
                        return Transform.rotate(
                          angle: -_rotationAnimation.value * 0.5,
                          child: Container(
                            width: 160,
                            height: 160,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                width: 1,
                                color: Colors.white.withOpacity(0.2),
                              ),
                            ),
                          ),
                        );
                      },
                    ),

                    // Pulsing glow effect
                    AnimatedBuilder(
                      animation: _pulseAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _pulseAnimation.value,
                          child: Container(
                            width: 130,
                            height: 130,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  Colors.white.withOpacity(0.3),
                                  Colors.white.withOpacity(0.1),
                                  Colors.transparent,
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.white.withOpacity(0.3),
                                  blurRadius: 40,
                                  spreadRadius: 10,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),

                    // Glass morphism container
                    Container(
                      width: 110,
                      height: 110,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(
                          width: 1,
                          color: Colors.white.withOpacity(0.2),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(25),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.white.withOpacity(0.2),
                                Colors.white.withOpacity(0.05),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    // QR Code icon with animation
                    AnimatedBuilder(
                      animation: _pulseAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _pulseAnimation.value,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Shadow
                              Icon(
                                Icons.qr_code_scanner_rounded,
                                size: 65,
                                color: Colors.black.withOpacity(0.2),
                              ),
                              // Main icon
                              const Icon(
                                Icons.qr_code_scanner_rounded,
                                size: 65,
                                color: Colors.white,
                              ),
                            ],
                          ),
                        );
                      },
                    ),

                    // Scanning line animation
                    AnimatedBuilder(
                      animation: _shimmerAnimation,
                      builder: (context, child) {
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(25),
                          child: SizedBox(
                            width: 110,
                            height: 110,
                            child: Stack(
                              children: [
                                Positioned(
                                  top: _shimmerAnimation.value * 110,
                                  left: 0,
                                  right: 0,
                                  child: Container(
                                    height: 2,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.transparent,
                                          Colors.white.withOpacity(0.6),
                                          Colors.transparent,
                                        ],
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.white.withOpacity(0.3),
                                          blurRadius: 10,
                                          spreadRadius: 5,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),

                    // Corner brackets
                    CustomPaint(
                      size: const Size(130, 130),
                      painter: CornerBracketsPainter(
                        animation: _pulseAnimation,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              // Animated title text - moved up and made smaller
              AnimatedBuilder(
                animation: _floatAnimation,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, _floatAnimation.value),
                    child: Column(
                      children: [
                        ShaderMask(
                          shaderCallback: (bounds) => const LinearGradient(
                            colors: [
                              Colors.white,
                              Color(0xFFE3F2FD),
                              Colors.white,
                            ],
                            stops: [0.0, 0.5, 1.0],
                          ).createShader(bounds),
                          child: const Text(
                            'Ready to Scan',
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              width: 1,
                              color: Colors.white.withOpacity(0.2),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: Colors.greenAccent,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.greenAccent.withOpacity(0.6),
                                      blurRadius: 6,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'Scanner Active',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),

              const SizedBox(height: 25),

              // Animated Scan Button - made smaller
              AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _pulseAnimation.value * 0.98,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.white.withOpacity(0.3),
                            blurRadius: 15,
                            spreadRadius: 0,
                          ),
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: widget.onScanPressed,
                          borderRadius: BorderRadius.circular(25),
                          child: Container(
                            width: 170,
                            height: 50,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(25),
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Colors.white,
                                  Color(0xFFF5F5F5),
                                ],
                              ),
                              border: Border.all(
                                width: 2,
                                color: Colors.white.withOpacity(0.5),
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(25),
                              child: Stack(
                                children: [
                                  // Shimmer effect
                                  AnimatedBuilder(
                                    animation: _shimmerAnimation,
                                    builder: (context, child) {
                                      return Positioned(
                                        left: _shimmerAnimation.value * 170 - 85,
                                        top: 0,
                                        bottom: 0,
                                        child: Container(
                                          width: 85,
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                Colors.transparent,
                                                Colors.white.withOpacity(0.3),
                                                Colors.transparent,
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                  // Button content
                                  const Center(
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.qr_code_scanner_rounded,
                                          color: Color(0xFF1565C0),
                                          size: 22,
                                        ),
                                        SizedBox(width: 8),
                                        Text(
                                          'START SCAN',
                                          style: TextStyle(
                                            color: Color(0xFF1565C0),
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 1.0,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 20),

              // Test mode button (if scanner not ready) - made smaller
              if (widget.showTestButton)
                AnimatedBuilder(
                  animation: _floatAnimation,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, -_floatAnimation.value * 0.3),
                      child: TextButton.icon(
                        onPressed: widget.onTestPressed,
                        icon: Icon(
                          Icons.play_circle_outline,
                          color: Colors.white.withOpacity(0.7),
                          size: 18,
                        ),
                        label: Text(
                          'Test Mode',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 12,
                          ),
                        ),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          backgroundColor: Colors.white.withOpacity(0.1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(
                              color: Colors.white.withOpacity(0.2),
                              width: 1,
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

        // Decorative floating particles
        ...List.generate(6, (index) {
          return FloatingParticle(
            delay: Duration(milliseconds: index * 500),
            duration: Duration(seconds: 10 + index * 2),
          );
        }),
      ],
    );
  }
}

// Corner brackets painter
class CornerBracketsPainter extends CustomPainter {
  final Animation<double> animation;

  CornerBracketsPainter({required this.animation}) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.5)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const cornerLength = 25.0;
    final offset = (size.width - 130) / 2;

    // Top-left corner
    canvas.drawLine(
      Offset(offset, offset),
      Offset(offset + cornerLength, offset),
      paint,
    );
    canvas.drawLine(
      Offset(offset, offset),
      Offset(offset, offset + cornerLength),
      paint,
    );

    // Top-right corner
    canvas.drawLine(
      Offset(size.width - offset, offset),
      Offset(size.width - offset - cornerLength, offset),
      paint,
    );
    canvas.drawLine(
      Offset(size.width - offset, offset),
      Offset(size.width - offset, offset + cornerLength),
      paint,
    );

    // Bottom-left corner
    canvas.drawLine(
      Offset(offset, size.height - offset),
      Offset(offset + cornerLength, size.height - offset),
      paint,
    );
    canvas.drawLine(
      Offset(offset, size.height - offset),
      Offset(offset, size.height - offset - cornerLength),
      paint,
    );

    // Bottom-right corner
    canvas.drawLine(
      Offset(size.width - offset, size.height - offset),
      Offset(size.width - offset - cornerLength, size.height - offset),
      paint,
    );
    canvas.drawLine(
      Offset(size.width - offset, size.height - offset),
      Offset(size.width - offset, size.height - offset - cornerLength),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Pattern painter for background
class PatternPainter extends CustomPainter {
  final Animation<double> animation;

  PatternPainter({required this.animation}) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.02)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    const spacing = 50.0;

    for (double i = 0; i < size.width; i += spacing) {
      for (double j = 0; j < size.height; j += spacing) {
        canvas.drawCircle(
          Offset(i, j),
          20,
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Floating particle widget
class FloatingParticle extends StatefulWidget {
  final Duration delay;
  final Duration duration;

  const FloatingParticle({
    super.key,
    required this.delay,
    required this.duration,
  });

  @override
  State<FloatingParticle> createState() => _FloatingParticleState();
}

class _FloatingParticleState extends State<FloatingParticle>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  final math.Random _random = math.Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _animation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.linear,
    ));

    Future.delayed(widget.delay, () {
      if (mounted) {
        _controller.repeat();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final startX = _random.nextDouble() * MediaQuery.of(context).size.width;
    final endX = startX + (_random.nextDouble() - 0.5) * 100;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Positioned(
          left: startX + (endX - startX) * _animation.value,
          bottom: MediaQuery.of(context).size.height * _animation.value,
          child: Opacity(
            opacity: (1 - _animation.value) * 0.3,
            child: Container(
              width: 4,
              height: 4,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
          ),
        );
      },
    );
  }
}