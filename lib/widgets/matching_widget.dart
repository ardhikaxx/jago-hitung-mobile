import 'dart:math';
import 'package:flutter/material.dart';
import '../services/sound_service.dart';
import '../utils/constants.dart';

class MatchingWidget extends StatefulWidget {
  final List<String> leftItems;
  final List<String> rightItems;
  final String correctAnswer; // Format: "0-1,1-0,2-2" (leftIndex-rightIndex pairs)
  final Color color;
  final ValueChanged<bool> onSubmitted;

  const MatchingWidget({
    super.key,
    required this.leftItems,
    required this.rightItems,
    required this.correctAnswer,
    required this.color,
    required this.onSubmitted,
  });

  @override
  State<MatchingWidget> createState() => _MatchingWidgetState();
}

class _MatchingWidgetState extends State<MatchingWidget>
    with SingleTickerProviderStateMixin {
  int? _selectedLeft;
  final Map<int, int> _matches = {};
  bool _answered = false;
  late AnimationController _shakeCtrl;
  late Animation<double> _shake;

  @override
  void initState() {
    super.initState();
    _shakeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _shake = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _shakeCtrl, curve: Curves.elasticIn),
    );
  }

  @override
  void dispose() {
    _shakeCtrl.dispose();
    super.dispose();
  }

  void _onTapLeft(int index) {
    if (_answered) return;
    if (_matches.containsKey(index)) return;
    SoundService.instance.playClick();
    setState(() => _selectedLeft = index);
  }

  void _onTapRight(int index) {
    if (_answered) return;
    if (_selectedLeft == null) return;
    if (_matches.containsValue(index)) return;

    SoundService.instance.playClick();
    setState(() {
      _matches[_selectedLeft!] = index;
      _selectedLeft = null;
    });
  }

  void _removeMatch(int leftIdx) {
    if (_answered) return;
    setState(() => _matches.remove(leftIdx));
  }

  void _submit() {
    if (_answered) return;
    if (_matches.length < widget.leftItems.length) {
      _shakeCtrl.forward(from: 0);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.info_outline, color: Colors.white, size: 18),
              SizedBox(width: 8),
              Text('Pasangkan semua item dulu!'),
            ],
          ),
          backgroundColor: AppColors.warning,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    setState(() => _answered = true);

    final pairs = _matches.entries.map((e) => '${e.key}-${e.value}').toList()..sort();
    final correctPairs = widget.correctAnswer.split(',').map((s) => s.trim()).toList()..sort();
    final benar = pairs.join(',') == correctPairs.join(',');

    widget.onSubmitted(benar);
  }

  bool _isCorrectPair(int leftIdx, int rightIdx) {
    final correctPairs = widget.correctAnswer.split(',').map((s) => s.trim()).toList();
    return correctPairs.contains('$leftIdx-$rightIdx');
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AnimatedBuilder(
          animation: _shake,
          builder: (_, child) {
            final offset = sin(_shake.value * 4 * pi) * 6;
            return Transform.translate(offset: Offset(offset, 0), child: child);
          },
          child: Row(
            children: [
              // Kiri
              Expanded(
                child: Column(
                  children: List.generate(widget.leftItems.length, (i) {
                    final isMatched = _matches.containsKey(i);
                    final isSelected = _selectedLeft == i;
                    final matchedRight = isMatched ? _matches[i] : null;
                    final isCorrect = _answered && matchedRight != null
                        ? _isCorrectPair(i, matchedRight)
                        : null;

                    Color bg = Colors.white;
                    Color border = Colors.grey.shade200;
                    if (_answered && isCorrect == true) {
                      bg = const Color(0xFFE8FAF0);
                      border = const Color(0xFF4ADE80);
                    } else if (_answered && isCorrect == false) {
                      bg = const Color(0xFFFFF0F0);
                      border = const Color(0xFFFF6B6B);
                    } else if (isSelected) {
                      bg = widget.color.withValues(alpha: 0.15);
                      border = widget.color;
                    } else if (isMatched) {
                      bg = widget.color.withValues(alpha: 0.08);
                      border = widget.color.withValues(alpha: 0.3);
                    }

                    return GestureDetector(
                      onTap: isMatched ? () => _removeMatch(i) : () => _onTapLeft(i),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: bg,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: border == Colors.grey.shade200 ? const Color(0xFF1D2030) : border, width: 3),
                          boxShadow: [
                            BoxShadow(
                              color: isSelected
                                  ? widget.color.withValues(alpha: 0.8)
                                  : const Color(0xFF1D2030),
                              offset: Offset(0, isSelected ? 6 : 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 26,
                              height: 26,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? widget.color
                                    : Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: Text(
                                  '${i + 1}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w900,
                                    color: isSelected
                                        ? Colors.white
                                        : AppColors.textSecondary,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                widget.leftItems[i],
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                            if (isMatched && !_answered)
                              const Icon(Icons.edit, size: 14,
                                  color: AppColors.textSecondary),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(width: 16),
              // Kanan
              Expanded(
                child: Column(
                  children: List.generate(widget.rightItems.length, (i) {
                    final matchedBy = _matches.entries
                        .where((e) => e.value == i)
                        .map((e) => e.key)
                        .firstOrNull;
                    final isMatched = matchedBy != null;
                    final isCorrect = _answered && matchedBy != null
                        ? _isCorrectPair(matchedBy, i)
                        : null;

                    Color bg = Colors.white;
                    Color border = Colors.grey.shade200;
                    if (_answered && isCorrect == true) {
                      bg = const Color(0xFFE8FAF0);
                      border = const Color(0xFF4ADE80);
                    } else if (_answered && isCorrect == false) {
                      bg = const Color(0xFFFFF0F0);
                      border = const Color(0xFFFF6B6B);
                    } else if (isMatched) {
                      bg = widget.color.withValues(alpha: 0.08);
                      border = widget.color.withValues(alpha: 0.3);
                    } else if (_selectedLeft != null) {
                      bg = widget.color.withValues(alpha: 0.04);
                      border = widget.color.withValues(alpha: 0.5);
                    }

                    return GestureDetector(
                      onTap: isMatched ? null : () => _onTapRight(i),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: bg,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: border == Colors.grey.shade200 ? const Color(0xFF1D2030) : border, width: 3),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0xFF1D2030),
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                widget.rightItems[i],
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: isMatched
                                      ? AppColors.textPrimary
                                      : (_selectedLeft != null
                                          ? widget.color
                                          : AppColors.textPrimary),
                                ),
                              ),
                            ),
                            Container(
                              width: 26,
                              height: 26,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _answered && isCorrect == true
                                    ? const Color(0xFF4ADE80)
                                    : _answered && isCorrect == false
                                        ? const Color(0xFFFF6B6B)
                                        : isMatched
                                            ? widget.color.withValues(alpha: 0.5)
                                            : Colors.grey.shade100,
                              ),
                              child: Center(
                                child: Icon(
                                  _answered && isCorrect == true
                                      ? Icons.check
                                      : _answered && isCorrect == false
                                          ? Icons.close
                                          : isMatched
                                              ? Icons.link_rounded
                                              : null,
                                  size: 14,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        if (!_answered)
          GestureDetector(
            onTap: _submit,
            child: Container(
              width: double.infinity,
              height: 50,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [widget.color, Color.lerp(widget.color, Colors.black, 0.15)!],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF1D2030), width: 3),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0xFF1D2030),
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              child: const Center(
                child: Text(
                  'Cocokkan',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ),
        if (_answered)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: (_isAllCorrect())
                  ? const Color(0xFFE8FAF0)
                  : const Color(0xFFFFF0F0),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: (_isAllCorrect())
                    ? const Color(0xFF4ADE80)
                    : const Color(0xFFFF6B6B),
                width: 3,
              ),
              boxShadow: const [
                BoxShadow(color: Color(0xFF1D2030), offset: Offset(0, 4)),
              ],
            ),
            child: Row(
              children: [
                Icon(
                  (_isAllCorrect())
                      ? Icons.check_circle_rounded
                      : Icons.cancel_rounded,
                  color: (_isAllCorrect())
                      ? const Color(0xFF22C55E)
                      : const Color(0xFFEF4444),
                  size: 24,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    (_isAllCorrect())
                        ? 'Semua pasangan benar! Hebat!'
                        : 'Ada pasangan yang salah. Coba lagi!',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: (_isAllCorrect())
                          ? const Color(0xFF166534)
                          : const Color(0xFF991B1B),
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  bool _isAllCorrect() {
    if (_matches.isEmpty) return false;
    final pairs = _matches.entries.map((e) => '${e.key}-${e.value}').toList()..sort();
    final correctPairs = widget.correctAnswer.split(',').map((s) => s.trim()).toList()..sort();
    return pairs.join(',') == correctPairs.join(',');
  }
}
