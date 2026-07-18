import 'package:flutter/material.dart';
import '../theme/game_colors.dart';
import '../theme/game_text_styles.dart';

class TopBarPill extends StatelessWidget {
  final String value;
  final IconData icon;
  final Color iconColor;

  const TopBarPill({
    Key? key,
    required this.value,
    required this.icon,
    required this.iconColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: GameColors.pillBackground.withOpacity(0.8),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: iconColor, size: 20),
          const SizedBox(width: 8),
          Text(
            value,
            style: GameTextStyles.buttonTextWhite.copyWith(fontSize: 18),
          ),
        ],
      ),
    );
  }
}
