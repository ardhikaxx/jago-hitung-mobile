import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CountdownOverlayWidget extends StatelessWidget {
  final int countdown;
  final bool showGo;

  const CountdownOverlayWidget({
    super.key,
    required this.countdown,
    required this.showGo,
  });

  @override
  Widget build(BuildContext context) {
    Color getTextColor() {
      if (showGo) return const Color(0xFF00FFD1); // Cyan terang
      if (countdown == 3) return const Color(0xFFFF4B4B); // Merah
      if (countdown == 2) return const Color(0xFFFFB300); // Oranye
      return const Color(0xFFFFFF00); // Kuning
    }

    String getText() {
      if (showGo) return 'MULAI!';
      return '$countdown';
    }

    return Positioned.fill(
      child: Container(
        color: Colors.black.withValues(alpha: 0.75),
        child: Center(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return ScaleTransition(
                scale: CurvedAnimation(
                  parent: animation,
                  curve: Curves.elasticOut,
                ),
                child: child,
              );
            },
            child: Text(
              getText(),
              key: ValueKey<String>(getText()),
              textAlign: TextAlign.center,
              style: GoogleFonts.lilitaOne(
                fontSize: showGo ? 80 : 150,
                color: getTextColor(),
                height: 1.0,
                shadows: [
                  const Shadow(
                    color: Colors.black87,
                    offset: Offset(6, 6),
                    blurRadius: 10,
                  ),
                  const Shadow(
                    color: Colors.white30,
                    offset: Offset(-2, -2),
                    blurRadius: 0,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
