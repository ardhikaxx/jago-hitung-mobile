import 'package:flutter/material.dart';

class GameCard extends StatelessWidget {
  final Widget child;
  final Color backgroundColor;
  final Color shadowColor;
  final Color borderColor;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final bool useGradient;

  const GameCard({
    Key? key,
    required this.child,
    this.backgroundColor = Colors.white,
    this.shadowColor = const Color(0xFF1D2030),
    this.borderColor = const Color(0xFF1D2030),
    this.padding = const EdgeInsets.all(24),
    this.borderRadius = 24.0,
    this.useGradient = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: borderColor, width: 3),
        gradient: useGradient
            ? LinearGradient(
                colors: [backgroundColor, backgroundColor.withValues(alpha: 0.8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: padding,
      child: child,
    );
  }
}
