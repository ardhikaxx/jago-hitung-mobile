import 'dart:math' as math;
import 'package:flutter/material.dart';

class GameBackground extends StatefulWidget {
  final Widget child;
  
  const GameBackground({super.key, required this.child});

  @override
  State<GameBackground> createState() => _GameBackgroundState();
}

class _GameBackgroundState extends State<GameBackground> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

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
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              stops: [0.2, 1.0],
            ),
          ),
        ),
        
        AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            final double rotationValue = _controller.value * 2 * math.pi;
            final double floatValue = math.sin(_controller.value * 2 * math.pi) * 15;
            final double floatValueInverse = math.cos(_controller.value * 2 * math.pi) * 15;
            
            return Stack(
              children: [
                // --- Abstract Shapes (White & Colored) ---
                // Top Right Large Circle (Floating)
                Positioned(
                  top: -30 + floatValue,
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
                
                // Mid Left Medium Circle (Floating inverse)
                Positioned(
                  top: 150 + floatValueInverse,
                  left: -60,
                  child: Container(
                    width: 180,
                    height: 180,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.12),
                    ),
                  ),
                ),
                
                // Bottom Right Rounded Square (Rotating)
                Positioned(
                  bottom: -60,
                  right: 20,
                  child: Transform.rotate(
                    angle: 0.5 + rotationValue * 0.2, // Slowly rotating
                    child: Container(
                      width: 220,
                      height: 220,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50),
                        color: Colors.white.withValues(alpha: 0.1),
                      ),
                    ),
                  ),
                ),

                // Top Center Small Rounded Square (Rotating opposite)
                Positioned(
                  top: 60,
                  left: 120,
                  child: Transform.rotate(
                    angle: -0.3 - rotationValue * 0.3,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.white.withValues(alpha: 0.1),
                      ),
                    ),
                  ),
                ),

                // --- Icons (Stars, Math Symbols, Geometrics) ---
                // Star 1
                Positioned(
                  top: 80 + floatValue * 0.5,
                  right: 50,
                  child: Transform.rotate(
                    angle: 0.4 + rotationValue * 0.5,
                    child: Icon(Icons.star_rounded, color: Colors.white.withValues(alpha: 0.15), size: 42),
                  ),
                ),
                // Star 2
                Positioned(
                  top: 320 + floatValueInverse * 0.8,
                  left: 30,
                  child: Transform.rotate(
                    angle: -0.2 - rotationValue * 0.6,
                    child: Icon(Icons.star_rounded, color: Colors.white.withValues(alpha: 0.25), size: 28),
                  ),
                ),
                // Plus / Add Symbol
                Positioned(
                  top: 150 + floatValue,
                  left: 60,
                  child: Transform.rotate(
                    angle: 0.2 + rotationValue * 0.4,
                    child: Icon(Icons.add_rounded, color: Colors.white.withValues(alpha: 0.18), size: 48),
                  ),
                ),
                // Minus / Remove Symbol
                Positioned(
                  bottom: 120 + floatValue * 0.7,
                  right: 80,
                  child: Transform.rotate(
                    angle: 0.8 - rotationValue * 0.4,
                    child: Icon(Icons.remove_rounded, color: Colors.white.withValues(alpha: 0.15), size: 50),
                  ),
                ),
                // Triangle
                Positioned(
                  bottom: 350 + floatValue,
                  right: 20,
                  child: Transform.rotate(
                    angle: -0.5 - rotationValue * 0.2,
                    child: Icon(Icons.change_history_rounded, color: Colors.white.withValues(alpha: 0.2), size: 44),
                  ),
                ),
                // Percent Symbol
                Positioned(
                  bottom: 250 + floatValueInverse * 0.5,
                  left: 40,
                  child: Transform.rotate(
                    angle: 0.1 + rotationValue * 0.3,
                    child: Icon(Icons.percent_rounded, color: Colors.white.withValues(alpha: 0.12), size: 38),
                  ),
                ),
                // Divide / Call Split (as division approximation) or close (multiply)
                Positioned(
                  top: 220 + floatValueInverse,
                  right: 30,
                  child: Transform.rotate(
                    angle: 0.7 + rotationValue * 0.3,
                    child: Icon(Icons.close_rounded, color: Colors.white.withValues(alpha: 0.15), size: 40),
                  ),
                ),
                // Calculate / Calculator
                Positioned(
                  bottom: 180 + floatValue * 1.1,
                  left: 80,
                  child: Transform.rotate(
                    angle: -0.3 - rotationValue * 0.5,
                    child: Icon(Icons.calculate_outlined, color: Colors.white.withValues(alpha: 0.1), size: 55),
                  ),
                ),
                // Functions / Math
                Positioned(
                  top: 50 + floatValueInverse * 0.7,
                  right: 150,
                  child: Transform.rotate(
                    angle: 0.1 + rotationValue * 0.2,
                    child: Icon(Icons.functions_rounded, color: Colors.white.withValues(alpha: 0.08), size: 46),
                  ),
                ),
                // Diamond / Crop Square (rotated)
                Positioned(
                  bottom: 70 + floatValue * 1.2,
                  left: 140,
                  child: Transform.rotate(
                    angle: 0.78 - rotationValue * 0.4,
                    child: Icon(Icons.crop_square_rounded, color: Colors.white.withValues(alpha: 0.12), size: 32),
                  ),
                ),
              ],
            );
          },
        ),

        // Foreground content
        SafeArea(child: widget.child),
      ],
    );
  }
}

