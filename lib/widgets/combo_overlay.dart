import 'dart:math';
import 'package:flutter/material.dart';

class ComboOverlay extends StatefulWidget {
  final int comboCount;

  const ComboOverlay({
    super.key,
    required this.comboCount,
  });

  @override
  State<ComboOverlay> createState() => _ComboOverlayState();
}

class _ComboOverlayState extends State<ComboOverlay> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  final List<_ComboParticle> _particles = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _generateParticles();
    _ctrl.forward();
  }

  @override
  void didUpdateWidget(ComboOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.comboCount != oldWidget.comboCount && widget.comboCount >= 3) {
      _generateParticles();
      _ctrl.forward(from: 0);
    }
  }

  void _generateParticles() {
    _particles.clear();
    for (int i = 0; i < 24; i++) {
      final angle = _random.nextDouble() * 2 * pi;
      final distance = 60.0 + _random.nextDouble() * 140;
      _particles.add(_ComboParticle(
        dx: cos(angle) * distance,
        dy: sin(angle) * distance,
        size: 8.0 + _random.nextDouble() * 12,
        color: [
          const Color(0xFFFF5252),
          const Color(0xFFFFD740),
          const Color(0xFFFF9800),
          Colors.white
        ][_random.nextInt(4)],
      ));
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.comboCount < 3) return const SizedBox.shrink();

    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, child) {
        final progress = _ctrl.value;
        final scale = Curves.elasticOut.transform(progress);
        final opacity = progress > 0.8 ? (1.0 - (progress - 0.8) * 5).clamp(0.0, 1.0) : 1.0;

        return IgnorePointer(
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              ..._particles.map((p) => Positioned(
                child: Transform.translate(
                  offset: Offset(p.dx * Curves.easeOutCubic.transform(progress), p.dy * Curves.easeOutCubic.transform(progress)),
                  child: Opacity(
                    opacity: (1.0 - progress).clamp(0.0, 1.0),
                    child: Container(
                      width: p.size,
                      height: p.size,
                      decoration: BoxDecoration(
                        color: p.color,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: p.color.withValues(alpha: 0.5),
                            blurRadius: 8,
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              )),
              Opacity(
                opacity: opacity,
                child: Transform.scale(
                  scale: scale,
                  child: Transform.rotate(
                    angle: -0.15,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFF5252), Color(0xFFFF9800)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white, width: 4),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0xFF1D2030),
                            offset: Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Text(
                        'COMBO x${widget.comboCount}!',
                        style: const TextStyle(
                          fontFamily: 'Fredoka',
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          shadows: [
                            Shadow(color: Color(0xFF1D2030), offset: Offset(0, 3)),
                          ],
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

class _ComboParticle {
  final double dx;
  final double dy;
  final double size;
  final Color color;

  const _ComboParticle({
    required this.dx,
    required this.dy,
    required this.size,
    required this.color,
  });
}
