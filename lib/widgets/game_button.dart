import 'package:flutter/material.dart';
import '../theme/game_colors.dart';
import '../theme/game_text_styles.dart';

class GameButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;
  final Color topColor;
  final Color bottomColor;
  final Widget? icon;
  final TextStyle? textStyle;
  final double width;
  final double height;

  const GameButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.topColor = GameColors.btnYellowTop,
    this.bottomColor = GameColors.btnYellowBottom,
    this.icon,
    this.textStyle,
    this.width = double.infinity,
    this.height = 64.0,
  }) : super(key: key);

  @override
  _GameButtonState createState() => _GameButtonState();
}

class _GameButtonState extends State<GameButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 50),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        setState(() => _isPressed = true);
        _controller.forward();
      },
      onTapUp: (_) {
        setState(() => _isPressed = false);
        _controller.reverse();
        widget.onPressed();
      },
      onTapCancel: () {
        setState(() => _isPressed = false);
        _controller.reverse();
      },
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) => Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            width: widget.width,
            height: widget.height,
            decoration: BoxDecoration(
              color: widget.bottomColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: GameColors.outlineDark, width: 3),
            ),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 50),
              margin: EdgeInsets.only(bottom: _isPressed ? 0 : 8),
              decoration: BoxDecoration(
                color: widget.topColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (widget.icon != null) ...[
                    widget.icon!,
                    const SizedBox(width: 8),
                  ],
                  Text(
                    widget.text,
                    style: widget.textStyle ?? GameTextStyles.buttonTextBlack,
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
