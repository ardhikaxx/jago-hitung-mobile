import 'package:flutter/material.dart';

class ProgressBar extends StatelessWidget {
  final double value;
  final Color color;
  final Color backgroundColor;
  final double height;
  
  const ProgressBar({
    Key? key,
    required this.value,
    this.color = const Color(0xFF5CE62E),
    this.backgroundColor = Colors.white,
    this.height = 24.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(height / 2),
        border: Border.all(color: const Color(0xFF1D2030), width: 3),
        boxShadow: const [
          BoxShadow(
            color: Color(0xFF1D2030),
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(height / 2),
        child: FractionallySizedBox(
          alignment: Alignment.centerLeft,
          widthFactor: value.clamp(0.0, 1.0),
          child: Container(
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(height / 2),
              border: const Border(
                right: BorderSide(color: Color(0xFF1D2030), width: 2),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
