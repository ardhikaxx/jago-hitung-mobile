import 'dart:math';
import 'package:flutter/material.dart';

class CelebrationOverlay extends StatefulWidget {
  final bool isCorrect;
  final Widget child;

  const CelebrationOverlay({
    super.key,
    required this.isCorrect,
    required this.child,
  });

  @override
  State<CelebrationOverlay> createState() => _CelebrationOverlayState();
}

class _CelebrationOverlayState extends State<CelebrationOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  final List<_Particle> _particles = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    final color = widget.isCorrect ? const Color(0xFF4ADE80) : const Color(0xFFFF6B6B);
    for (int i = 0; i < (widget.isCorrect ? 16 : 8); i++) {
      final angle = _random.nextDouble() * 2 * pi;
      final distance = 40.0 + _random.nextDouble() * 80;
      _particles.add(_Particle(
        dx: cos(angle) * distance,
        dy: sin(angle) * distance,
        size: 4.0 + _random.nextDouble() * 8,
        color: widget.isCorrect
            ? [const Color(0xFFFFD700), const Color(0xFF4ADE80), const Color(0xFF22C55E), Colors.white][_random.nextInt(4)]
            : [color, const Color(0xFFEF4444), const Color(0xFF991B1B)][_random.nextInt(3)],
      ));
    }
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) {
        final progress = _ctrl.value;
        return Stack(
          clipBehavior: Clip.none,
          children: [
            widget.child,
            ..._particles.map((p) => Positioned(
              top: 20 + p.dy * progress,
              left: 40 + p.dx * progress,
              child: Opacity(
                opacity: (1.0 - progress).clamp(0.0, 1.0),
                child: Container(
                  width: p.size * (1.0 + progress * 0.5),
                  height: p.size * (1.0 + progress * 0.5),
                  decoration: BoxDecoration(
                    color: p.color.withValues(alpha: (1.0 - progress).clamp(0.0, 1.0)),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            )),
          ],
        );
      },
    );
  }
}

class _Particle {
  final double dx;
  final double dy;
  final double size;
  final Color color;

  const _Particle({
    required this.dx,
    required this.dy,
    required this.size,
    required this.color,
  });
}

class ShakeWidget extends StatefulWidget {
  final Widget child;
  final bool trigger;

  const ShakeWidget({
    super.key,
    required this.child,
    required this.trigger,
  });

  @override
  State<ShakeWidget> createState() => _ShakeWidgetState();
}

class _ShakeWidgetState extends State<ShakeWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _shake;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _shake = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.elasticIn),
    );
    if (widget.trigger) _ctrl.forward();
  }

  @override
  void didUpdateWidget(ShakeWidget old) {
    super.didUpdateWidget(old);
    if (widget.trigger && !old.trigger) {
      _ctrl.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _shake,
      builder: (context, child) {
        final offset = sin(_shake.value * 4 * pi) * 6;
        return Transform.translate(
          offset: Offset(offset, 0),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}
