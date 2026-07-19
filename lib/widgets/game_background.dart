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
            final double t = _controller.value * 2 * math.pi;
            
            final double dx1 = math.cos(t) * 15;
            final double dy1 = math.sin(t * 1.3) * 15;
            
            final double dx2 = math.sin(t * 1.1) * -15;
            final double dy2 = math.cos(t * 0.9) * 15;
            
            final double dx3 = math.cos(t * 1.5) * 15;
            final double dy3 = math.sin(t * 0.8) * -15;
            
            return Stack(
              children: [
                // --- Abstract Shapes (White & Colored) ---
                // Top Right Large Circle (Floating)
                Positioned(
                  top: -30 + dy1,
                  right: -40 + dx1,
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
                  top: 150 + dy2,
                  left: -60 + dx2,
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
                  bottom: -60 + dy3,
                  right: 20 + dx3,
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
                  top: 60 + dy1 * 0.5,
                  left: 120 + dx1 * 0.5,
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
                  top: 80 + dy2 * 0.8,
                  right: 50 + dx2 * 0.8,
                  child: Transform.rotate(
                    angle: 0.4 + rotationValue * 0.5,
                    child: Icon(Icons.star_rounded, color: Colors.white.withValues(alpha: 0.15), size: 42),
                  ),
                ),
                // Star 2
                Positioned(
                  top: 320 + dy3 * 0.9,
                  left: 30 + dx3 * 0.9,
                  child: Transform.rotate(
                    angle: -0.2 - rotationValue * 0.6,
                    child: Icon(Icons.star_rounded, color: Colors.white.withValues(alpha: 0.25), size: 28),
                  ),
                ),
                // Plus / Add Symbol
                Positioned(
                  top: 150 + dy1,
                  left: 60 + dx1,
                  child: Transform.rotate(
                    angle: 0.2 + rotationValue * 0.4,
                    child: Icon(Icons.add_rounded, color: Colors.white.withValues(alpha: 0.18), size: 48),
                  ),
                ),
                // Minus / Remove Symbol
                Positioned(
                  bottom: 120 + dy2 * 0.7,
                  right: 80 + dx2 * 0.7,
                  child: Transform.rotate(
                    angle: 0.8 - rotationValue * 0.4,
                    child: Icon(Icons.remove_rounded, color: Colors.white.withValues(alpha: 0.15), size: 50),
                  ),
                ),
                // Triangle
                Positioned(
                  bottom: 350 + dy3 * 1.1,
                  right: 20 + dx3 * 1.1,
                  child: Transform.rotate(
                    angle: -0.5 - rotationValue * 0.2,
                    child: Icon(Icons.change_history_rounded, color: Colors.white.withValues(alpha: 0.2), size: 44),
                  ),
                ),
                // Percent Symbol
                Positioned(
                  bottom: 250 + dy1 * 0.6,
                  left: 40 + dx1 * 0.6,
                  child: Transform.rotate(
                    angle: 0.1 + rotationValue * 0.3,
                    child: Icon(Icons.percent_rounded, color: Colors.white.withValues(alpha: 0.12), size: 38),
                  ),
                ),
                // Divide / Call Split (as division approximation) or close (multiply)
                Positioned(
                  top: 220 + dy2 * 1.2,
                  right: 30 + dx2 * 1.2,
                  child: Transform.rotate(
                    angle: 0.7 + rotationValue * 0.3,
                    child: Icon(Icons.close_rounded, color: Colors.white.withValues(alpha: 0.15), size: 40),
                  ),
                ),
                // Calculate / Calculator
                Positioned(
                  bottom: 180 + dy3,
                  left: 80 + dx3,
                  child: Transform.rotate(
                    angle: -0.3 - rotationValue * 0.5,
                    child: Icon(Icons.calculate_outlined, color: Colors.white.withValues(alpha: 0.1), size: 55),
                  ),
                ),
                // Functions / Math
                Positioned(
                  top: 50 + dy1 * 0.7,
                  right: 150 + dx1 * 0.7,
                  child: Transform.rotate(
                    angle: 0.1 + rotationValue * 0.2,
                    child: Icon(Icons.functions_rounded, color: Colors.white.withValues(alpha: 0.08), size: 46),
                  ),
                ),
                // Diamond / Crop Square (rotated)
                Positioned(
                  bottom: 70 + dy2 * 1.3,
                  left: 140 + dx2 * 1.3,
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

