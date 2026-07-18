import 'package:flutter/material.dart';
import 'game_button.dart';
import '../theme/game_colors.dart';

class QuizAnswerButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isSelected;
  final bool? isCorrect;

  const QuizAnswerButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.isSelected = false,
    this.isCorrect,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color btnColor = GameColors.darkBluePanel;
    Color shadowColor = Colors.grey.shade300;
    
    if (isSelected) {
      btnColor = GameColors.btnBlueTop;
      shadowColor = GameColors.btnBlueBottom;
    }
    if (isCorrect == true) {
      btnColor = GameColors.btnGreenTop;
      shadowColor = GameColors.btnGreenBottom;
    } else if (isCorrect == false) {
      btnColor = GameColors.btnRedTop;
      shadowColor = GameColors.btnRedBottom;
    }

    return GameButton(
      text: text,
      onPressed: onPressed,
      topColor: btnColor,
      bottomColor: shadowColor,
    );
  }
}
