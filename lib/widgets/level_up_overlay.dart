import 'dart:math';
import 'package:flutter/material.dart';

class LevelUpOverlay extends StatefulWidget {
  final String fromClassName;
  final String toClassName;
  final VoidCallback onContinue;

  const LevelUpOverlay({
    super.key,
    required this.fromClassName,
    required this.toClassName,
    required this.onContinue,
  });

  @override
  State<LevelUpOverlay> createState() => _LevelUpOverlayState();
}

class _LevelUpOverlayState extends State<LevelUpOverlay>
    with TickerProviderStateMixin {
  late AnimationController _bgCtrl;
  late AnimationController _particleCtrl;
  late AnimationController _contentCtrl;
  late Animation<double> _contentScale;
  late Animation<double> _contentFade;
  final Random _random = Random();
  final List<_LevelUpParticle> _particles = [];
  final List<_StarBurst> _starBursts = [];

  @override
  void initState() {
    super.initState();

    _bgCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);

    _particleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..forward();

    _contentCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();

    _contentScale = CurvedAnimation(
      parent: _contentCtrl,
      curve: Curves.elasticOut,
    );
    _contentFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _contentCtrl, curve: const Interval(0.0, 0.3)),
    );

    for (int i = 0; i < 40; i++) {
      final angle = _random.nextDouble() * 2 * pi;
      final dist = 60 + _random.nextDouble() * 200;
      _particles.add(_LevelUpParticle(
        id: i,
        dx: cos(angle) * dist,
        dy: sin(angle) * dist,
        size: 4 + _random.nextDouble() * 10,
        color: [
          const Color(0xFFFFD700),
          const Color(0xFFFF6B6B),
          const Color(0xFF4ADE80),
          const Color(0xFF6C63FF),
          const Color(0xFFFFB300),
          Colors.white,
        ][_random.nextInt(6)],
        delay: _random.nextDouble() * 1.5,
        rotation: _random.nextDouble() * 2 * pi,
      ));
    }

    for (int i = 0; i < 12; i++) {
      _starBursts.add(_StarBurst(
        angle: (i / 12) * 2 * pi + _random.nextDouble() * 0.3,
        distance: 80 + _random.nextDouble() * 60,
        delay: _random.nextDouble() * 0.4,
      ));
    }
  }

  @override
  void dispose() {
    _bgCtrl.dispose();
    _particleCtrl.dispose();
    _contentCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          AnimatedBuilder(
            animation: _bgCtrl,
            builder: (_, _) => Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF6C63FF).withValues(alpha: 0.95),
                    const Color(0xFF2D1B69).withValues(alpha: 0.98),
                    const Color(0xFF1A0A3E).withValues(alpha: 1.0),
                  ],
                  radius: 1.5 + _bgCtrl.value * 0.3,
                  focal: const Alignment(0.0, -0.3),
                  focalRadius: 0.5,
                ),
              ),
            ),
          ),
          AnimatedBuilder(
            animation: _particleCtrl,
            builder: (_, _) {
              final progress = _particleCtrl.value;
              return CustomPaint(
                size: MediaQuery.of(context).size,
                painter: _LevelUpParticlePainter(
                  particles: _particles,
                  progress: progress,
                ),
              );
            },
          ),
          Center(
            child: AnimatedBuilder(
              animation: _contentCtrl,
              builder: (_, _) => Opacity(
                opacity: _contentFade.value,
                child: Transform.scale(
                  scale: _contentScale.value,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Trophy
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFFFFD700).withValues(alpha: 0.2),
                          border: Border.all(
                            color: const Color(0xFFFFD700).withValues(alpha: 0.5),
                            width: 3,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFFFD700).withValues(alpha: 0.4),
                              blurRadius: 30,
                              spreadRadius: 10,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.auto_awesome_rounded,
                          size: 50,
                          color: Color(0xFFFFD700),
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        '🎉 SELAMAT! 🎉',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Pencapaian XP membawamu dari',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.fromClassName,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFFFFD700),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.3),
                          ),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.arrow_upward_rounded,
                                color: Color(0xFFFFD700), size: 20),
                            SizedBox(width: 8),
                            Text(
                              'NAIK LEVEL!',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFFFFD700),
                                letterSpacing: 3,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'menjadi',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withValues(alpha: 0.7),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.toClassName,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFD700).withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.monetization_on_rounded, color: Color(0xFFFFD700), size: 24),
                            SizedBox(width: 8),
                            Text(
                              '+100 Koin Bonus!',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFFFD700),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      GestureDetector(
                        onTap: () {
                          widget.onContinue();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 40,
                            vertical: 16,
                          ),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFFFFD700),
                                Color(0xFFFFB300),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: const Color(0xFF1D2030), width: 3),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0xFF1D2030),
                                offset: Offset(0, 6),
                              ),
                            ],
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'LANJUTKAN',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF2D1B69),
                                  letterSpacing: 2,
                                ),
                              ),
                              SizedBox(width: 8),
                              Icon(
                                Icons.arrow_forward_rounded,
                                color: Color(0xFF2D1B69),
                                size: 22,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LevelUpParticle {
  final int id;
  final double dx;
  final double dy;
  final double size;
  final Color color;
  final double delay;
  final double rotation;

  const _LevelUpParticle({
    required this.id,
    required this.dx,
    required this.dy,
    required this.size,
    required this.color,
    required this.delay,
    required this.rotation,
  });
}

class _StarBurst {
  final double angle;
  final double distance;
  final double delay;

  const _StarBurst({
    required this.angle,
    required this.distance,
    required this.delay,
  });
}

class _LevelUpParticlePainter extends CustomPainter {
  final List<_LevelUpParticle> particles;
  final double progress;

  _LevelUpParticlePainter({
    required this.particles,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    for (final p in particles) {
      final pProgress = ((progress - p.delay) / (1.0 - p.delay)).clamp(0.0, 1.0);
      if (pProgress <= 0) continue;

      final opacity = (1.0 - pProgress).clamp(0.0, 1.0);
      final scale = 1.0 + pProgress * 0.5;

      canvas.save();
      canvas.translate(
        center.dx + p.dx * pProgress,
        center.dy + p.dy * pProgress - 100 * pProgress * pProgress,
      );
      canvas.rotate(p.rotation + pProgress * 4 * pi);
      canvas.scale(scale);

      final paint = Paint()
        ..color = p.color.withValues(alpha: opacity)
        ..style = PaintingStyle.fill;

      if (_randomH(p.id) > 0.5) {
        canvas.drawCircle(Offset.zero, p.size / 2, paint);
      } else {
        final rect = Rect.fromCenter(
          center: Offset.zero,
          width: p.size,
          height: p.size,
        );
        canvas.drawRect(rect, paint);
      }

      canvas.restore();
    }
  }

  double _randomH(int hash) {
    return ((hash * 12345 + 67890) % 100) / 100;
  }

  @override
  bool shouldRepaint(covariant _LevelUpParticlePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
