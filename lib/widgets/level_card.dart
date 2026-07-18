import 'package:flutter/material.dart';
import '../theme/game_colors.dart';
import '../theme/game_text_styles.dart';
import 'game_card.dart';

class LevelCard extends StatelessWidget {
  final int level;
  final bool isLocked;
  final VoidCallback onTap;
  
  const LevelCard({
    Key? key,
    required this.level,
    required this.isLocked,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLocked ? null : onTap,
      child: GameCard(
        backgroundColor: isLocked ? Colors.grey.shade400 : GameColors.btnBlueTop,
        shadowColor: isLocked ? Colors.grey.shade600 : GameColors.btnBlueBottom,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isLocked ? Icons.lock : Icons.star,
                color: Colors.white,
                size: 32,
              ),
              const SizedBox(height: 8),
              Text(
                'Level \$level',
                style: GameTextStyles.titleMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
