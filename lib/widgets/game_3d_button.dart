import 'package:flutter/material.dart';

class Game3DButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final Color color;
  final Color shadowColor;

  const Game3DButton({
    super.key,
    required this.child,
    this.onPressed,
    required this.color,
    required this.shadowColor,
  });

  @override
  State<Game3DButton> createState() => _Game3DButtonState();
}

class _Game3DButtonState extends State<Game3DButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        if (widget.onPressed != null) setState(() => _isPressed = true);
      },
      onTapUp: (_) {
        if (widget.onPressed != null) {
          setState(() => _isPressed = false);
          widget.onPressed!();
        }
      },
      onTapCancel: () {
        if (widget.onPressed != null) setState(() => _isPressed = false);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        margin: EdgeInsets.only(top: _isPressed ? 6 : 0, bottom: _isPressed ? 0 : 6),
        decoration: BoxDecoration(
          color: widget.color,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withValues(alpha: 0.8), width: 3),
          boxShadow: [
            BoxShadow(
              color: widget.shadowColor,
              offset: Offset(0, _isPressed ? 0 : 8),
            ),
          ],
        ),
        child: widget.child,
      ),
    );
  }
}
