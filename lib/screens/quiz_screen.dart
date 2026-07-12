import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/question_model.dart';
import '../models/topic_model.dart';
import '../models/user_progress_model.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../utils/constants.dart';
import '../widgets/numpad_widget.dart';
import 'result_screen.dart';

class QuizScreen extends StatefulWidget {
  final Topic topic;
  final int kelas;
  const QuizScreen({super.key, required this.topic, required this.kelas});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  int _benarCount = 0;
  final List<bool> _results = [];
  final TextEditingController _answerCtrl = TextEditingController();
  String? _selectedChoice;
  bool _answered = false;
  bool _showHint = false;
  int _hintIndex = 0;
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;

  User? get user => AuthService.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.elasticOut),
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _answerCtrl.dispose();
    _animController.dispose();
    super.dispose();
  }

  Question get _currentQuestion => widget.topic.soal[_currentIndex];

  void _checkAnswer() {
    if (_answered) return;

    final jawabanUser = _currentQuestion.isMultipleChoice
        ? (_selectedChoice ?? '')
        : _answerCtrl.text.trim();

    if (jawabanUser.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Masukkan jawaban terlebih dahulu'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    final benar = jawabanUser.toLowerCase() ==
        _currentQuestion.jawaban.toLowerCase();

    setState(() {
      _answered = true;
      if (benar) _benarCount++;
      _results.add(benar);
    });

    _animController.reset();
    _animController.forward();
  }

  void _nextQuestion() {
    if (_currentIndex < widget.topic.soal.length - 1) {
      setState(() {
        _currentIndex++;
        _answered = false;
        _selectedChoice = null;
        _answerCtrl.clear();
        _showHint = false;
        _hintIndex = 0;
      });
      _animController.reset();
      _animController.forward();
    } else {
      _finishQuiz();
    }
  }

  void _showNextHint() {
    if (_hintIndex < _currentQuestion.petunjuk.length - 1) {
      setState(() {
        _showHint = true;
        _hintIndex++;
      });
    }
  }

  Future<void> _finishQuiz() async {
    final jumlahSoal = widget.topic.soal.length;
    final skor = (_benarCount / jumlahSoal * 100).round();
    final lulus = skor >= AppConstants.skorLulusMinimum;

    final progress = TopicProgress(
      topikId: widget.topic.id,
      skor: skor,
      jumlahBenar: _benarCount,
      jumlahSoal: jumlahSoal,
      lulus: lulus,
      lastAttempt: DateTime.now(),
    );

    await FirestoreService.instance.saveTopikProgress(
      user!.uid,
      widget.kelas,
      widget.topic.id,
      progress,
    );

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ResultScreen(
            topicName: widget.topic.topik,
            topikId: widget.topic.id,
            kelas: widget.kelas,
            skor: skor,
            benar: _benarCount,
            jumlahSoal: jumlahSoal,
            lulus: lulus,
            results: _results,
          ),
        ),
      );
    }
  }

  void _onNumpadTap(String value) {
    setState(() {
      if (value == 'DEL') {
        if (_answerCtrl.text.isNotEmpty) {
          _answerCtrl.text = _answerCtrl.text
              .substring(0, _answerCtrl.text.length - 1);
        }
      } else if (value == 'CLR') {
        _answerCtrl.clear();
      } else {
        _answerCtrl.text += value;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final q = _currentQuestion;
    final progress = (_currentIndex + 1) / widget.topic.soal.length;
    final color = AppConstants.warnaKelas[widget.kelas] ?? AppColors.primary;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: color,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(widget.topic.topik),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                '${_currentIndex + 1}/${widget.topic.soal.length}',
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            color: color,
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.white.withValues(alpha: 0.3),
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(Colors.white),
                    minHeight: 8,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Soal ${_currentIndex + 1} dari ${widget.topic.soal.length}',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12),
                    ),
                    Row(
                      children: List.generate(
                        _results.length,
                        (i) => Container(
                          margin: const EdgeInsets.only(left: 4),
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: _results[i]
                                ? AppColors.success
                                : AppColors.danger,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: color.withValues(alpha: 0.3)),
                    ),
                    child: Column(
                      children: [
                        Text(
                          q.ilustrasi,
                          style: const TextStyle(fontSize: 32),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          q.pertanyaan,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (q.isMultipleChoice)
                    _buildMultipleChoice(q, color)
                  else
                    _buildFillIn(q, color),
                  const SizedBox(height: 16),
                  if (!_answered)
                    Center(
                      child: TextButton.icon(
                        onPressed: _showNextHint,
                        icon: const Icon(Icons.lightbulb_outline, size: 18),
                        label: const Text('Petunjuk'),
                      ),
                    ),
                  if (_showHint && !_answered)
                    ...List.generate(_hintIndex + 1, (i) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.warning.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.lightbulb,
                                color: AppColors.warning, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                q.petunjuk[i],
                                style: const TextStyle(
                                    fontSize: 13,
                                    color: AppColors.textPrimary),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  if (_answered)
                    ScaleTransition(
                      scale: _scaleAnimation,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: _results.last
                              ? AppColors.success.withValues(alpha: 0.1)
                              : AppColors.danger.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _results.last
                                ? AppColors.success
                                : AppColors.danger,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  _results.last
                                      ? Icons.check_circle
                                      : Icons.cancel,
                                  color: _results.last
                                      ? AppColors.success
                                      : AppColors.danger,
                                  size: 24,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _results.last ? 'Benar! 🎉' : 'Salah 😅',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: _results.last
                                        ? AppColors.success
                                        : AppColors.danger,
                                  ),
                                ),
                              ],
                            ),
                            if (!_results.last) ...[
                              const SizedBox(height: 8),
                              Text(
                                'Jawaban: ${q.jawaban}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                            const SizedBox(height: 8),
                            Text(
                              q.penjelasan,
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          if (q.isFillIn && !_answered)
            NumpadWidget(
              onTap: _onNumpadTap,
              showDecimal: false,
            ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _answered ? _nextQuestion : _checkAnswer,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      _answered ? AppColors.success : color,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  _answered
                      ? (_currentIndex < widget.topic.soal.length - 1
                          ? 'Soal Berikutnya'
                          : 'Lihat Hasil')
                      : 'Jawab',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMultipleChoice(Question q, Color color) {
    return Column(
      children: q.pilihan!.map((choice) {
        final isSelected = _selectedChoice == choice;
        final isCorrect = choice == q.jawaban;
        Color bgColor = Colors.white;
        Color borderColor = Colors.grey.shade300;
        Color textColor = AppColors.textPrimary;

        if (_answered) {
          if (isCorrect) {
            bgColor = AppColors.success.withValues(alpha: 0.1);
            borderColor = AppColors.success;
            textColor = AppColors.success;
          } else if (isSelected && !isCorrect) {
            bgColor = AppColors.danger.withValues(alpha: 0.1);
            borderColor = AppColors.danger;
            textColor = AppColors.danger;
          }
        } else if (isSelected) {
          bgColor = color.withValues(alpha: 0.1);
          borderColor = color;
          textColor = color;
        }

        return GestureDetector(
          onTap: _answered
              ? null
              : () => setState(() => _selectedChoice = choice),
          child: Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderColor, width: 1.5),
            ),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: borderColor.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: _answered && isCorrect
                        ? const Icon(Icons.check,
                            size: 18, color: AppColors.success)
                        : _answered && isSelected && !isCorrect
                            ? const Icon(Icons.close,
                                size: 18, color: AppColors.danger)
                            : Text(
                                String.fromCharCode(
                                    65 + q.pilihan!.indexOf(choice)),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: textColor,
                                ),
                              ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    choice,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: textColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildFillIn(Question q, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _answered
              ? (_results.isNotEmpty && _results.last
                  ? AppColors.success
                  : AppColors.danger)
              : color,
          width: 2,
        ),
      ),
      child: Row(
        children: [
          const Text(
            'Jawaban: ',
            style: TextStyle(
                fontSize: 16, color: AppColors.textSecondary),
          ),
          Expanded(
            child: TextField(
              controller: _answerCtrl,
              enabled: !_answered,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: _answered
                    ? (_results.isNotEmpty && _results.last
                        ? AppColors.success
                        : AppColors.danger)
                    : AppColors.textPrimary,
              ),
              decoration: const InputDecoration(
                hintText: '?',
                border: InputBorder.none,
                hintStyle: TextStyle(color: AppColors.locked),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
