import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class XPBadge extends StatelessWidget {
  final int xp;
  
  const XPBadge({Key? key, required this.xp}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF33C0FF),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF1D2030), width: 3),
        boxShadow: const [
          BoxShadow(
            color: Color(0xFF1D2030),
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star_rounded, color: Color(0xFF1D2030), size: 20),
          const SizedBox(width: 6),
          Text(
            '$xp XP',
            style: GoogleFonts.fredoka(
              color: const Color(0xFF1D2030),
              fontWeight: FontWeight.w900,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
