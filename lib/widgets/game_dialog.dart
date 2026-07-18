import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'game_3d_button.dart';

class GameDialog extends StatelessWidget {
  final String title;
  final String content;
  final VoidCallback onConfirm;
  final String confirmText;

  const GameDialog({
    Key? key,
    required this.title,
    required this.content,
    required this.onConfirm,
    this.confirmText = 'OK',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: const Color(0xFF1D2030), width: 4),
          boxShadow: const [
            BoxShadow(
              color: Color(0xFF1D2030),
              offset: Offset(0, 10),
            ),
          ],
        ),
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title, 
              textAlign: TextAlign.center,
              style: GoogleFonts.fredoka(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: const Color(0xFF1D2030),
              )
            ),
            const SizedBox(height: 16),
            Text(
              content, 
              style: GoogleFonts.fredoka(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ), 
              textAlign: TextAlign.center
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: Game3DButton(
                onPressed: onConfirm,
                color: const Color(0xFF2979FF),
                shadowColor: const Color(0xFF104A9A),
                child: Center(
                  child: Text(
                    confirmText,
                    style: GoogleFonts.fredoka(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
