import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../models/question_model.dart';
import '../services/sound_service.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../utils/constants.dart';
import '../widgets/countdown_overlay_widget.dart';

class DuelScreen extends StatefulWidget {
  final List<Question> questions;

  const DuelScreen({super.key, required this.questions});

  @override
  State<DuelScreen> createState() => _DuelScreenState();
}

class _DuelScreenState extends State<DuelScreen> {
  int _player1Score = 0;
  int _player2Score = 0;
  int _p1Combo = 0;
  int _p2Combo = 0;
  int _currentIndex = 0;
  bool _isAnswered = false;
  
  // 0 = none, 1 = player 1 won, 2 = player 2 won
  int _roundWinner = 0;

  bool _p1Frozen = false;
  bool _p2Frozen = false;

  late Question _currentQuestion;
  List<String> _shuffledChoices = [];

  bool _isCountingDown = true;
  int _countdown = 3;
  bool _showGo = false;

  @override
  void initState() {
    super.initState();
    _loadQuestion();
    _startCountdown();
  }

  void _startCountdown() {
    if (_countdown > 0) {
      Future.delayed(const Duration(seconds: 1), () {
        if (!mounted) return;
        setState(() {
          _countdown--;
        });
        _startCountdown();
      });
    } else {
      if (!mounted) return;
      setState(() {
        _showGo = true;
      });
      Future.delayed(const Duration(milliseconds: 800), () {
        if (!mounted) return;
        setState(() {
          _isCountingDown = false;
        });
      });
    }
  }

  void _loadQuestion() {
    if (_currentIndex >= widget.questions.length) {
      _showResultDialog();
      return;
    }
    _currentQuestion = widget.questions[_currentIndex];
    
    if (_currentQuestion.isMultipleChoice) {
      _shuffledChoices = List.from(_currentQuestion.pilihan ?? []);
      _shuffledChoices.shuffle(Random());
    } else {
      // If it's a fill in the blank, generate some dummy choices for duel
      _shuffledChoices = _generateDummyChoices(_currentQuestion.jawaban);
    }
    
    _isAnswered = false;
    _roundWinner = 0;
    _p1Frozen = false;
    _p2Frozen = false;
  }

  List<String> _generateDummyChoices(String correct) {
    int ans = int.tryParse(correct) ?? 0;
    Set<String> choices = {correct};
    final random = Random();
    while (choices.length < 4) {
      int offset = random.nextInt(10) - 5;
      if (offset == 0) offset = 1;
      choices.add((ans + offset).toString());
    }
    List<String> result = choices.toList();
    result.shuffle(random);
    return result;
  }

  void _handleAnswer(int player, String answer) {
    if (_isCountingDown) return;
    if (_isAnswered) return;
    if (player == 1 && _p1Frozen) return;
    if (player == 2 && _p2Frozen) return;

    final isCorrect = answer.toLowerCase() == _currentQuestion.jawaban.toLowerCase();

    setState(() {
      if (isCorrect) {
        SoundService.instance.playCorrect();
        _isAnswered = true;
        _roundWinner = player;
        if (player == 1) {
          _player1Score++;
          _p1Combo++;
          _p2Combo = 0;
        } else {
          _player2Score++;
          _p2Combo++;
          _p1Combo = 0;
        }

        Future.delayed(const Duration(seconds: 1), () {
          if (!mounted) return;
          setState(() {
            _currentIndex++;
            _loadQuestion();
          });
        });
      } else {
        SoundService.instance.playWrong();
        if (player == 1) {
          _p1Frozen = true;
          _p1Combo = 0;
        } else {
          _p2Frozen = true;
          _p2Combo = 0;
        }
        Future.delayed(const Duration(seconds: 1), () {
          if (!mounted) return;
          setState(() {
            if (player == 1) {
              _p1Frozen = false;
            } else {
              _p2Frozen = false;
            }
          });
        });
      }
    });
  }

  void _showResultDialog() {
    String winnerText = "";
    Color winnerColor = Colors.white;
    if (_player1Score > _player2Score) {
      winnerText = "PEMAIN BAWAH MENANG!";
      winnerColor = AppColors.primary;
    } else if (_player2Score > _player1Score) {
      winnerText = "PEMAIN ATAS MENANG!";
      winnerColor = const Color(0xFFFF6B6B);
    } else {
      winnerText = "SERI!";
      winnerColor = AppColors.secondary;
    }

    _updateDuelQuest();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'KUIS SELESAI',
          textAlign: TextAlign.center,
          style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              winnerText,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: winnerColor),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Text(
              'Skor Atas: $_player2Score',
              style: const TextStyle(color: Colors.black87, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              'Skor Bawah: $_player1Score',
              style: const TextStyle(color: Colors.black87, fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          Center(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text('Kembali', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _updateDuelQuest() async {
    final uid = AuthService.instance.currentUser?.uid;
    if (uid == null) return;
    final progress = await FirestoreService.instance.getUserProgress(uid);
    if (progress != null) {
      progress.updateQuestProgress('duel_count', 1);
      await FirestoreService.instance.saveDailyQuests(uid, progress.dailyQuests);
    }
  }

  Widget _buildAnimatedText(String text, Color color, {double fontSize = 32}) {
    return TweenAnimationBuilder(
      key: ValueKey(text),
      duration: const Duration(milliseconds: 600),
      tween: Tween<double>(begin: 0.0, end: 1.0),
      curve: Curves.elasticOut,
      builder: (context, double value, child) {
        return Transform.scale(
          scale: value,
          child: Opacity(
            opacity: value.clamp(0.0, 1.0),
            child: Text(
              text,
              style: TextStyle(
                color: color,
                fontSize: fontSize,
                fontWeight: FontWeight.w900,
                shadows: const [Shadow(color: Colors.black45, offset: Offset(2, 2), blurRadius: 4)],
              ),
              textAlign: TextAlign.center,
            ),
          ),
        );
      },
    );
  }

  Widget _buildPlayerArea(int player, Color color, bool isReversed) {
    bool isFrozen = player == 1 ? _p1Frozen : _p2Frozen;
    
    Widget content = Container(
      color: color,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: SafeArea(
        top: false,
        bottom: true,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Score Display
            Row(
              mainAxisAlignment: isReversed ? MainAxisAlignment.start : MainAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Text(
                        'Skor: ${player == 1 ? _player1Score : _player2Score}',
                        style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      if ((player == 1 ? _p1Combo : _p2Combo) > 1) ...[
                        const SizedBox(width: 8),
                        Text(
                          '🔥 x${player == 1 ? _p1Combo : _p2Combo}',
                          style: const TextStyle(color: Colors.yellow, fontSize: 18, fontWeight: FontWeight.w900),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            const Spacer(),
            if (isFrozen)
              _buildAnimatedText('❌ WAKTU BEKU ❌', Colors.white, fontSize: 24)
            else if (_isAnswered && _roundWinner == player)
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildAnimatedText('🔥 BENAR! 🔥', Colors.yellow),
                  if ((player == 1 ? _p1Combo : _p2Combo) > 1)
                    _buildAnimatedText('COMBO x${player == 1 ? _p1Combo : _p2Combo}!', Colors.orangeAccent, fontSize: 24),
                ],
              )
            else if (_isAnswered && _roundWinner != player)
              _buildAnimatedText('Terlalu Lambat!', Colors.white70, fontSize: 24)
            else ...[
              // Question
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [BoxShadow(color: Colors.black26, offset: Offset(0, 4))],
                ),
                child: Text(
                  _currentQuestion.pertanyaan,
                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Colors.black87),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 24),
              // Choices
              Wrap(
                spacing: 12,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: _shuffledChoices.map((choice) {
                  return GestureDetector(
                    onTap: () => _handleAnswer(player, choice),
                    child: Container(
                      width: MediaQuery.of(context).size.width / 2.5,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.black12, width: 2),
                      ),
                      child: Center(
                        child: Text(
                          choice,
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
            const Spacer(),
          ],
        ),
      ),
    );

    if (isReversed) {
      return RotatedBox(quarterTurns: 2, child: content);
    }
    return content;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.questions.isEmpty) return const Scaffold();

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Column(
            children: [
              // Player 2 (Top - Rotated)
              Expanded(
                child: _buildPlayerArea(2, const Color(0xFFFF6B6B), true),
              ),
              // Divider
              Container(
                height: 10,
                color: const Color(0xFF1D2030),
                child: Center(
                  child: Container(
                    width: 60,
                    height: 4,
                    color: Colors.white54,
                  ),
                ),
              ),
              // Player 1 (Bottom - Normal)
              Expanded(
                child: _buildPlayerArea(1, AppColors.primary, false),
              ),
            ],
          ),

          // Countdown Overlay
          if (_isCountingDown)
            CountdownOverlayWidget(countdown: _countdown, showGo: _showGo),
        ],
      ),
    );
  }
}
