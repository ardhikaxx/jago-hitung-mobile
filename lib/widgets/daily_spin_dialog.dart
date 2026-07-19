import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:confetti/confetti.dart';

import '../services/sound_service.dart';
import '../services/firestore_service.dart';
import '../models/user_progress_model.dart';
import '../utils/constants.dart';

class SpinPrize {
  final String label;
  final Color color;
  final int koin;

  SpinPrize(this.label, this.color, this.koin);
}

final List<SpinPrize> _prizes = [
  SpinPrize("50 KOIN", const Color(0xFFFFB300), 50),
  SpinPrize("10 KOIN", const Color(0xFF64B5F6), 10),
  SpinPrize("ZONK!", const Color(0xFF9E9E9E), 0),
  SpinPrize("100 KOIN", const Color(0xFFFF5252), 100),
  SpinPrize("20 KOIN", const Color(0xFF81C784), 20),
  SpinPrize("5 KOIN", const Color(0xFFBA68C8), 5),
];

class DailySpinDialog extends StatefulWidget {
  final UserProgress progress;
  final VoidCallback onSpinComplete;

  const DailySpinDialog({super.key, required this.progress, required this.onSpinComplete});

  @override
  State<DailySpinDialog> createState() => _DailySpinDialogState();
}

class _DailySpinDialogState extends State<DailySpinDialog> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _animation;
  late ConfettiController _confetti;
  
  bool _isSpinning = false;
  bool _hasSpun = false;
  SpinPrize? _wonPrize;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(seconds: 4));
    _confetti = ConfettiController(duration: const Duration(seconds: 2));
    _animation = Tween<double>(begin: 0, end: 0).animate(_ctrl);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _confetti.dispose();
    super.dispose();
  }

  void _spin() {
    if (_isSpinning || _hasSpun) return;
    
    SoundService.instance.playClick();
    setState(() => _isSpinning = true);

    final random = Random();
    final winnerIndex = random.nextInt(_prizes.length);
    
    final anglePerItem = 2 * pi / _prizes.length;
    // Roda berputar maju. Agar item winner berhenti di titik atas (0 / -pi/2)
    final targetAngle = (5 * 2 * pi) + (2 * pi - (winnerIndex * anglePerItem));
    final randomOffset = (random.nextDouble() - 0.5) * (anglePerItem * 0.7);
    
    _animation = Tween<double>(
      begin: _ctrl.value, 
      end: targetAngle + randomOffset
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.decelerate));

    _ctrl.forward(from: 0).then((_) {
      _finishSpin(winnerIndex);
    });
  }

  void _finishSpin(int winnerIndex) async {
    final prize = _prizes[winnerIndex];
    setState(() {
      _isSpinning = false;
      _hasSpun = true;
      _wonPrize = prize;
    });

    if (prize.koin > 0) {
      _confetti.play();
      SoundService.instance.playCorrect();
      await FirestoreService.instance.updateKoin(widget.progress.uid, prize.koin);
    } else {
      SoundService.instance.playWrong();
    }

    final today = "${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2,'0')}-${DateTime.now().day.toString().padLeft(2,'0')}";
    await FirestoreService.instance.updateLastSpinDate(widget.progress.uid, today);
    widget.onSpinComplete();
  }

  Widget _buildWheel() {
    final anglePerItem = 2 * pi / _prizes.length;
    final size = 260.0;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.rotate(
          angle: _animation.value,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(
                size: Size(size, size),
                painter: WheelPainter(),
              ),
              ...List.generate(_prizes.length, (index) {
                return Transform.rotate(
                  angle: index * anglePerItem,
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: Container(
                      height: size,
                      alignment: Alignment.topCenter,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 25),
                        child: Text(
                          _prizes[index].label,
                          style: GoogleFonts.lilitaOne(
                            color: Colors.white,
                            fontSize: 22,
                            shadows: const [Shadow(color: Colors.black45, blurRadius: 4, offset: Offset(2, 2))],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(32),
              border: Border.all(color: Colors.white, width: 4),
              boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 20)],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "RODA KEBERUNTUNGAN",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.lilitaOne(fontSize: 28, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Putar rodamu hari ini dan raih koin gratis!",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.black54, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 32),
                
                Stack(
                  alignment: Alignment.topCenter,
                  children: [
                    Container(
                      width: 280,
                      height: 280,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 15, spreadRadius: 2, offset: const Offset(0, 10))
                        ],
                      ),
                      child: Center(child: _buildWheel()),
                    ),
                    // Pointer
                    Positioned(
                      top: -15,
                      child: Transform.rotate(
                        angle: pi, // point downwards
                        child: const Icon(Icons.arrow_drop_down_circle_rounded, size: 50, color: AppColors.primary),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 32),
                
                if (_wonPrize != null) ...[
                  TweenAnimationBuilder(
                    duration: const Duration(milliseconds: 600),
                    tween: Tween<double>(begin: 0, end: 1),
                    curve: Curves.elasticOut,
                    builder: (context, val, child) {
                      return Transform.scale(
                        scale: val,
                        child: child,
                      );
                    },
                    child: Column(
                      children: [
                        Text(
                          _wonPrize!.koin > 0 ? "SELAMAT!" : "YAHHH...",
                          style: GoogleFonts.lilitaOne(
                            fontSize: 28, 
                            color: _wonPrize!.koin > 0 ? AppColors.success : Colors.redAccent
                          ),
                        ),
                        Text(
                          "Kamu mendapatkan ${_wonPrize!.label}",
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _hasSpun ? AppColors.locked : AppColors.secondary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: _hasSpun ? 0 : 4,
                    ),
                    onPressed: _hasSpun ? () => Navigator.pop(context) : _spin,
                    child: Text(
                      _hasSpun ? "TUTUP" : "PUTAR SEKARANG!",
                      style: GoogleFonts.lilitaOne(fontSize: 24, color: _hasSpun ? Colors.white : Colors.black87),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          ConfettiWidget(
            confettiController: _confetti,
            blastDirectionality: BlastDirectionality.explosive,
            maxBlastForce: 20,
            minBlastForce: 8,
            emissionFrequency: 0.05,
            numberOfParticles: 50,
            gravity: 0.1,
          ),
          
          if (!_isSpinning && !_hasSpun)
            Positioned(
              top: -10,
              right: -10,
              child: GestureDetector(
                onTap: () {
                  SoundService.instance.playClick();
                  Navigator.pop(context);
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Colors.redAccent,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close_rounded, color: Colors.white, size: 28),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class WheelPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final radius = size.width / 2;
    final center = Offset(radius, radius);
    final sweepAngle = 2 * pi / _prizes.length;

    for (int i = 0; i < _prizes.length; i++) {
      final paint = Paint()
        ..color = _prizes[i].color
        ..style = PaintingStyle.fill;
      
      final startAngle = -pi/2 + (i * sweepAngle) - (sweepAngle / 2);
      
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius), 
        startAngle, 
        sweepAngle, 
        true, 
        paint
      );
      
      final borderPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4;
        
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius), 
        startAngle, 
        sweepAngle, 
        true, 
        borderPaint
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
