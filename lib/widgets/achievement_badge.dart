import 'package:flutter/material.dart';
import '../theme/game_colors.dart';

class AchievementBadge extends StatelessWidget {
  final String iconUrl;
  final bool isUnlocked;
  
  const AchievementBadge({
    Key? key,
    required this.iconUrl,
    this.isUnlocked = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: isUnlocked ? 1.0 : 0.5,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isUnlocked ? const Color(0xFFFFD633) : Colors.grey.shade400,
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFF1D2030), width: 3),
          boxShadow: [
            BoxShadow(
              color: isUnlocked ? const Color(0xFF1D2030) : Colors.grey.shade600,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(Icons.emoji_events_rounded, color: Colors.white, size: 36),
      ),
    );
  }
}
