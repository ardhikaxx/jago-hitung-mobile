import 'package:flutter/material.dart';
import '../services/sound_service.dart';
import '../utils/constants.dart';

class NumpadWidget extends StatelessWidget {
  final Function(String) onTap;
  final bool showDecimal;
  final Color color;

  const NumpadWidget({
    super.key,
    required this.onTap,
    this.showDecimal = false,
    this.color = AppColors.primary,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFF),
        border: Border(
          top: BorderSide(color: color.withValues(alpha: 0.15), width: 1.5),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Baris 1: 1 2 3 4 5 ──
          Row(
            children: [
              _buildKey('1'),
              _buildKey('2'),
              _buildKey('3'),
              _buildKey('4'),
              _buildKey('5'),
            ],
          ),
          const SizedBox(height: 8),
          // ── Baris 2: 6 7 8 9 0 ──
          Row(
            children: [
              _buildKey('6'),
              _buildKey('7'),
              _buildKey('8'),
              _buildKey('9'),
              _buildKey('0'),
            ],
          ),
          const SizedBox(height: 8),
          // ── Baris 3: CLR DEL . atau - + = ──
          Row(
            children: [
              _buildSpecialKey('CLR', Icons.delete_sweep_rounded, AppColors.warning),
              _buildSpecialKey('DEL', Icons.backspace_rounded, AppColors.danger),
              if (showDecimal) _buildKey('.') else _buildKey('-'),
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
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: _NumKey(
          label: value,
          onTap: () => onTap(value),
          color: color,
        ),
      ),
    );
  }

  Widget _buildSpecialKey(String label, IconData icon, Color keyColor) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: _NumKey(
          icon: icon,
          onTap: () => onTap(label),
          color: keyColor,
          isSpecial: true,
        ),
      ),
    );
  }
}

class _NumKey extends StatefulWidget {
  final String? label;
  final IconData? icon;
  final VoidCallback onTap;
  final Color color;
  final bool isSpecial;

  const _NumKey({
    this.label,
    this.icon,
    required this.onTap,
    required this.color,
    this.isSpecial = false,
  });

  @override
  State<_NumKey> createState() => _NumKeyState();
}

class _NumKeyState extends State<_NumKey>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scale = Tween<double>(begin: 1.0, end: 0.88).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _handleTap() async {
    SoundService.instance.playClick();
    await _ctrl.forward();
    await _ctrl.reverse();
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: AnimatedBuilder(
        animation: _scale,
        builder: (_, child) => Transform.scale(
          scale: _scale.value,
          child: child,
        ),
        child: Container(
          height: 46,
          decoration: BoxDecoration(
            color: widget.isSpecial
                ? widget.color.withValues(alpha: 0.1)
                : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: widget.isSpecial
                  ? widget.color.withValues(alpha: 0.3)
                  : const Color(0xFFE8EDF5),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: (widget.isSpecial ? widget.color : Colors.black)
                    .withValues(alpha: widget.isSpecial ? 0.1 : 0.06),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Center(
            child: widget.icon != null
                ? Icon(widget.icon, size: 20, color: widget.color)
                : Text(
                    widget.label!,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: widget.isSpecial
                          ? widget.color
                          : AppColors.textPrimary,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
