import 'package:flutter/material.dart';

class GameBackground extends StatelessWidget {
  final Widget child;
  
  const GameBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Base Gradient (Cyan and Blue)
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF00E5FF), // Cyan
                Color(0xFF2979FF), // Vibrant Blue
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: [0.2, 1.0],
            ),
          ),
        ),
        
        // Decorative Shapes
        Positioned(
          top: -30,
          right: -40,
          child: Container(
            width: 250,
            height: 250,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.15),
            ),
          ),
        ),
        
        Positioned(
          top: 120,
          left: -60,
          child: Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.1),
            ),
          ),
        ),
        
        Positioned(
          bottom: -80,
          right: 30,
          child: Transform.rotate(
            angle: 0.5,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(40),
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
          ),
        ),

        // Small Stars
        Positioned(
          top: 90,
          right: 70,
          child: Icon(Icons.star_rounded, color: Colors.white.withValues(alpha: 0.2), size: 32),
        ),
        Positioned(
          top: 300,
          left: 50,
          child: Icon(Icons.star_rounded, color: Colors.white.withValues(alpha: 0.15), size: 24),
        ),
        Positioned(
          bottom: 200,
          left: 80,
          child: Icon(Icons.circle, color: Colors.white.withValues(alpha: 0.1), size: 40),
        ),
        
        Positioned(
          bottom: 300,
          right: 40,
          child: Icon(Icons.change_history_rounded, color: Colors.white.withValues(alpha: 0.1), size: 36),
        ),

        // Foreground content
        SafeArea(child: child),
      ],
    );
  }
}
