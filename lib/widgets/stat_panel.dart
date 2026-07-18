import 'package:flutter/material.dart';
import '../theme/game_colors.dart';
import '../theme/game_text_styles.dart';

class StatPanel extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String baseValue;
  final String bonusValue;

  const StatPanel({
    Key? key,
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.baseValue,
    required this.bonusValue,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: GameColors.darkBluePanel,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 28),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(label, style: GameTextStyles.labelSmall),
              Row(
                children: [
                  Text(baseValue, style: GameTextStyles.statValue),
                  const SizedBox(width: 4),
                  Text('+\$bonusValue', style: GameTextStyles.statBonus),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
