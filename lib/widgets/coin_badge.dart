import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CoinBadge extends StatelessWidget {
  final int coins;
  
  const CoinBadge({Key? key, required this.coins}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFFFD633),
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
          const Icon(Icons.monetization_on_rounded, color: Color(0xFF1D2030), size: 20),
          const SizedBox(width: 6),
          Text(
            coins.toString(),
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
