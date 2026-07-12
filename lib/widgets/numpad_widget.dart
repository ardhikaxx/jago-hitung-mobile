import 'package:flutter/material.dart';
import '../utils/constants.dart';

class NumpadWidget extends StatelessWidget {
  final Function(String) onTap;
  final bool showDecimal;

  const NumpadWidget({
    super.key,
    required this.onTap,
    this.showDecimal = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      color: Colors.grey.shade100,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              _buildKey('1'),
              _buildKey('2'),
              _buildKey('3'),
              _buildKey('4'),
              _buildKey('5'),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              _buildKey('6'),
              _buildKey('7'),
              _buildKey('8'),
              _buildKey('9'),
              _buildKey('0'),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              _buildSpecialKey('CLR', Icons.delete_sweep, AppColors.warning),
              _buildSpecialKey('DEL', Icons.backspace_outlined, AppColors.danger),
              if (showDecimal)
                _buildKey('.')
              else
                _buildKey('-'),
              _buildKey('+'),
              _buildKey('='),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildKey(String value) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 3),
        child: ElevatedButton(
          onPressed: () => onTap(value),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: AppColors.textPrimary,
            elevation: 1,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSpecialKey(String label, IconData icon, Color color) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 3),
        child: ElevatedButton(
          onPressed: () => onTap(label),
          style: ElevatedButton.styleFrom(
            backgroundColor: color.withValues(alpha: 0.1),
            foregroundColor: color,
            elevation: 0,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Icon(icon, size: 22),
        ),
      ),
    );
  }
}
