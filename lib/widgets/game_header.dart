import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'coin_badge.dart';
import 'xp_badge.dart';

class GameHeader extends StatelessWidget {
  final String title;
  final int coins;
  final int xp;
  
  const GameHeader({
    Key? key,
    required this.title,
    this.coins = 0,
    this.xp = 0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
        border: const Border(
          bottom: BorderSide(color: Color(0xFF1D2030), width: 3),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0xFF1D2030),
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title, 
              style: GoogleFonts.fredoka(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: const Color(0xFF1D2030),
              )
            ),
            Row(
              children: [
                CoinBadge(coins: coins),
                const SizedBox(width: 8),
                XPBadge(xp: xp),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
