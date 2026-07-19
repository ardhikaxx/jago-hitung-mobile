import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/question_model.dart';
import '../models/topic_model.dart';
import '../models/user_progress_model.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../services/sound_service.dart';
import '../utils/constants.dart';
import '../widgets/numpad_widget.dart';
import '../widgets/smart_illustration_card.dart';
import '../widgets/celebration_widget.dart';
import '../widgets/matching_widget.dart';
import '../widgets/game_3d_button.dart';
import '../widgets/game_background.dart';
import '../widgets/combo_overlay.dart';
import '../widgets/screen_shake_widget.dart';
import '../widgets/countdown_overlay_widget.dart';
import 'result_screen.dart';

class QuizScreen extends StatefulWidget {
  final Topic topic;
  final int kelas;
  final String quizMode;
  const QuizScreen({super.key, required this.topic, required this.kelas, this.quizMode = 'biasa'});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen>
    with TickerProviderStateMixin {
  int _currentIndex = 0;
  int _benarCount = 0;
  int _currentCombo = 0;
  int _maxCombo = 0;
  final List<bool> _results = [];
  final List<String> _userAnswers = [];
  final TextEditingController _answerCtrl = TextEditingController();
  String? _selectedChoice;
  bool _answered = false;
  bool _showHint = false;
  int _hintIndex = 0;
  late List<Question> _questions;

  // Timer Mode Kilat
  Timer? _questionTimer;
  int _timeLeft = 30;
  bool get _isKilat => widget.quizMode == 'kilat';
  int get _timeLimit {
    if (widget.kelas <= 2) return 60;
    if (widget.kelas <= 4) return 45;
    return 30;
  }

  // Animasi
  late AnimationController _cardController;
  late AnimationController _feedbackController;
  late AnimationController _pulseController;
  late Animation<double> _cardScale;
  late Animation<double> _cardSlide;
  late Animation<double> _feedbackScale;
  late Animation<double> _pulse;

  final GlobalKey<ScreenShakeWidgetState> _shakeKey = GlobalKey<ScreenShakeWidgetState>();
  late ConfettiController _confettiController;

  bool _isCountingDown = true;
  int _countdown = 3;
  bool _showGo = false;

  User? get user => AuthService.instance.currentUser;
  Question get _currentQuestion => _questions[_currentIndex];

  @override
  void initState() {
    super.initState();

    _questions = widget.topic.soal.map((q) {
      List<String>? shuffledPilihan = q.pilihan != null ? List<String>.from(q.pilihan!) : null;
      if (shuffledPilihan != null) shuffledPilihan.shuffle();
      return Question(
        id: q.id,
        tipe: q.tipe,
        pertanyaan: q.pertanyaan,
        ilustrasi: q.ilustrasi,
        pilihan: shuffledPilihan,
        jawaban: q.jawaban,
        petunjuk: q.petunjuk,
        penjelasan: q.penjelasan,
        pasanganKiri: q.pasanganKiri,
        pasanganKanan: q.pasanganKanan,
      );
    }).toList()..shuffle();

    _cardController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    _feedbackController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    _confettiController = ConfettiController(duration: const Duration(seconds: 3));

    _cardScale = CurvedAnimation(
      parent: _cardController,
      curve: Curves.elasticOut,
    );
    _cardSlide = Tween<double>(begin: 60, end: 0).animate(
      CurvedAnimation(parent: _cardController, curve: Curves.easeOut),
    );
    _feedbackScale = CurvedAnimation(
      parent: _feedbackController,
      curve: Curves.elasticOut,
    );
    _pulse = Tween<double>(begin: 1.0, end: 1.06).animate(_pulseController);

    _cardController.forward();
    SoundService.instance.init();
    
    // Selalu hitung mundur di awal (untuk semua mode)
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
        if (_isKilat) _startTimer();
      });
    }
  }

  void _startTimer() {
    _timeLeft = _timeLimit;
    _questionTimer?.cancel();
    _questionTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        _timeLeft--;
      });
      if (_timeLeft <= 0) {
        _questionTimer?.cancel();
        if (!_answered) {
          _checkAnswer(autoSubmit: true);
        }
      }
    });
  }

  void _resetTimer() {
    if (_isKilat) _startTimer();
  }

  @override
  void dispose() {
    _questionTimer?.cancel();
    _answerCtrl.dispose();
    _cardController.dispose();
    _feedbackController.dispose();
    _pulseController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  void _checkAnswer({bool autoSubmit = false}) {
    if (_isCountingDown) return;
    if (_answered) return;

    final jawabanUser = _currentQuestion.isMultipleChoice
        ? (_selectedChoice ?? '')
        : _answerCtrl.text.trim();

    if (jawabanUser.isEmpty && !autoSubmit) {
      HapticFeedback.lightImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.info_outline, color: Colors.white, size: 18),
              SizedBox(width: 8),
              Text('Pilih atau isi jawaban dulu!'),
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

    final benar =
        jawabanUser.toLowerCase() == _currentQuestion.jawaban.toLowerCase();

    setState(() {
      _answered = true;
      _userAnswers.add(jawabanUser);
      if (benar) {
        _benarCount++;
        _currentCombo++;
        if (_currentCombo > _maxCombo) _maxCombo = _currentCombo;
      } else {
        _currentCombo = 0;
      }
      _results.add(benar);
    });

    if (benar) {
      if (_currentCombo >= 5 && _currentCombo % 5 == 0) {
        _confettiController.play();
      }
      SoundService.instance.playCorrect();
    } else {
      _shakeKey.currentState?.shake();
      SoundService.instance.playWrong();
    }

    _feedbackController.reset();
    _feedbackController.forward();
  }

  void _nextQuestion() {
    if (_currentIndex < _questions.length - 1) {
      setState(() {
        _currentIndex++;
        _answered = false;
        _selectedChoice = null;
        _answerCtrl.clear();
        _showHint = false;
        _hintIndex = 0;
      });
      _cardController.reset();
      _cardController.forward();
      _feedbackController.reset();
      _resetTimer();
    } else {
      _questionTimer?.cancel();
      _finishQuiz();
    }
  }

  void _showNextHint() {
    if (_hintIndex < _currentQuestion.petunjuk.length - 1) {
      setState(() {
        _showHint = true;
        _hintIndex++;
      });
    } else if (!_showHint) {
      setState(() => _showHint = true);
    }
  }

  Future<void> _finishQuiz() async {
    final jumlahSoal = _questions.length;
    final baseSkor = (_benarCount / jumlahSoal * 100).round();
    final bonusCombo = _maxCombo >= 3 ? (_maxCombo * 5) : 0;
    final skor = baseSkor + bonusCombo;
    final lulus = baseSkor >= AppConstants.skorLulusMinimum;

    final oldProgress = await FirestoreService.instance.getUserProgress(user!.uid);
    final oldTotalXP = oldProgress?.totalXP ?? 0;
    final oldLevel = (oldTotalXP ~/ 500) + 1;
    
    final oldTopikSkor = oldProgress?.getTopikProgress(widget.topic.id, widget.kelas)?.skor ?? 0;
    // Score only increases XP if the new score is higher.
    final finalSkor = skor > oldTopikSkor ? skor : oldTopikSkor;
    final newTotalXP = oldTotalXP - oldTopikSkor + finalSkor;
    final newLevel = (newTotalXP ~/ 500) + 1;
    
    final isLevelUp = newLevel > oldLevel;

    final progress = TopicProgress(
      topikId: widget.topic.id,
      skor: finalSkor,
      jumlahBenar: _benarCount,
      jumlahSoal: jumlahSoal,
      lulus: lulus,
      lastAttempt: DateTime.now(),
    );

    int earnedCoins = skor ~/ 10;
    if (_isKilat) {
      earnedCoins *= 5;
    }
    
    if (widget.quizMode == 'misteri') {
      earnedCoins *= 2;
    }
    
    if (isLevelUp) {
      earnedCoins += 100; // Bonus Koin Naik Level
    }

    if (oldProgress != null) {
      // The quest requires 10 consecutive correct answers, so we store the max combo achieved.
      // But actually, we just need to know if they ever reached 10.
      oldProgress.checkAndResetDailyQuests();
      int currentCombo = oldProgress.dailyQuests['combo_count'] ?? 0;
      if (_maxCombo > currentCombo) {
        oldProgress.dailyQuests['combo_count'] = _maxCombo;
      }
      if (widget.quizMode == 'misteri') {
        oldProgress.updateQuestProgress('misteri_count', 1);
      }
      await FirestoreService.instance.saveDailyQuests(user!.uid, oldProgress.dailyQuests);
    }

    await FirestoreService.instance.saveTopikProgress(
      user!.uid,
      widget.kelas,
      widget.topic.id,
      progress,
      coinReward: earnedCoins,
    );

    if (mounted) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (_, a, _) => ResultScreen(
            topicName: widget.topic.topik,
            topikId: widget.topic.id,
            kelas: widget.kelas,
            skor: finalSkor,
            benar: _benarCount,
            jumlahSoal: jumlahSoal,
            lulus: lulus,
            results: _results,
            questions: _questions,
            userAnswers: _userAnswers,
            isLevelUp: isLevelUp,
            newLevel: newLevel,
            oldLevel: oldLevel,
          ),
          transitionsBuilder: (_, a, anim, child) => FadeTransition(
            opacity: a,
            child: child,
          ),
        ),
      );
    }
  }

  void _onNumpadTap(String value) {
    if (_isCountingDown) return;
    if (_answered) return;
    setState(() {
      if (value == 'DEL') {
        if (_answerCtrl.text.isNotEmpty) {
          _answerCtrl.text =
              _answerCtrl.text.substring(0, _answerCtrl.text.length - 1);
        }
      } else if (value == 'CLR') {
        _answerCtrl.clear();
      } else {
        _answerCtrl.text += value;
      }
    });
    SoundService.instance.playClick();
  }

  @override
  Widget build(BuildContext context) {
    final q = _currentQuestion;
    final color = AppConstants.warnaKelas[widget.kelas] ?? AppColors.primary;
    final total = _questions.length;
    final progressVal = (_currentIndex + 1) / total;

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Background Image
          const Positioned.fill(
            child: GameBackground(child: SizedBox()),
          ),
          // Overlay
          Positioned.fill(
            child: Container(
              color: Colors.black.withValues(alpha: 0.3),
            ),
          ),
          ScreenShakeWidget(
            shakeKey: _shakeKey,
            shakeCount: 3,
            shakeOffset: 12.0,
            duration: const Duration(milliseconds: 400),
            child: Column(
              children: [
                // ── Game Header ──
                _buildGameHeader(color, progressVal, total),
  
            // ── Soal area ──
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                child: Column(
                  children: [
                    // ── Kartu soal ──
                    _buildQuestionCard(q, color),
                    const SizedBox(height: 16),

                    // ── Pilihan jawaban / fill in / matching ──
                    if (q.isMatching)
                      _buildMatching(q, color)
                    else if (q.isMultipleChoice)
                      _buildMultipleChoice(q, color)
                    else
                      _buildFillIn(q, color),

                    const SizedBox(height: 12),

                    // ── Hint ──
                    if (!_answered) _buildHintSection(q, color),

                    // ── Feedback benar/salah ──
                    if (_answered) _buildFeedback(q, color),

                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
          ),

          // ── Numpad (fill in) ──
          if (q.isFillIn && !_answered)
            NumpadWidget(onTap: _onNumpadTap, showDecimal: false, color: color),

          // ── Tombol aksi ──
          if (!_currentQuestion.isMatching || _answered)
            _buildActionButton(color),
              ],
            ),
          ),
          
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirection: pi / 2, 
              maxBlastForce: 15, 
              minBlastForce: 5, 
              emissionFrequency: 0.05,
              numberOfParticles: 40,
              gravity: 0.2,
            ),
          ),

          // ── Combo Overlay ──
          if (_currentCombo >= 3)
            Positioned.fill(
              child: IgnorePointer(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 100),
                    child: ComboOverlay(comboCount: _currentCombo),
                  ),
                ),
              ),
            ),
            
          if (_isCountingDown)
            CountdownOverlayWidget(countdown: _countdown, showGo: _showGo),
        ],
      ),
    );
  }

  // ── GAME HEADER ─────────────────────────────────────────────────────────
  Widget _buildGameHeader(Color color, double progressVal, int total) {
    final top = MediaQuery.of(context).padding.top;

    return Container(
      padding: EdgeInsets.fromLTRB(16, top + 8, 16, 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withValues(alpha: 0.92),
            color.withValues(alpha: 0.75),
            color.withValues(alpha: 0.0),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: const [0.0, 0.7, 1.0],
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Tombol back
              GestureDetector(
                onTap: () {
                  SoundService.instance.playClick();
                  _showQuitDialog(color);
                },
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: Colors.white.withValues(alpha: 0.4), width: 1.5),
                  ),
                  child: const Icon(Icons.close_rounded,
                      color: Colors.white, size: 20),
                ),
              ),
              const SizedBox(width: 12),

              // Progress + judul
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.topic.topik,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        shadows: [
                          Shadow(color: Colors.black26, blurRadius: 4)
                        ],
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Soal ${_currentIndex + 1} dari $total',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.8),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              // Timer Mode Kilat
              if (_isKilat)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: _timeLeft <= 5
                        ? Colors.red.withValues(alpha: 0.5)
                        : Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: Colors.white.withValues(alpha: 0.4), width: 1.5),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.timer_rounded,
                          color: Colors.white, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        '$_timeLeft',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              if (_isKilat) const SizedBox(width: 8),

              // Skor benar live
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: Colors.white.withValues(alpha: 0.4), width: 1.5),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star_rounded,
                        color: Color(0xFFFFD700), size: 16),
                    const SizedBox(width: 4),
                    Text(
                      '$_benarCount/$total',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // ── Progress bar + dot indikator ──
          Row(
            children: [
              // Progress bar
              Expanded(
                child: Container(
                  height: 10,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: progressVal,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.white.withValues(alpha: 0.7),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Dot hasil sebelumnya
              Row(
                children: List.generate(total, (i) {
                  if (i < _results.length) {
                    return Container(
                      margin: const EdgeInsets.only(left: 4),
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: _results[i]
                            ? const Color(0xFF4ADE80)
                            : const Color(0xFFFF6B6B),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: (_results[i]
                                    ? const Color(0xFF4ADE80)
                                    : const Color(0xFFFF6B6B))
                                .withValues(alpha: 0.6),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    );
                  } else if (i == _currentIndex) {
                    return AnimatedBuilder(
                      animation: _pulse,
                      builder: (context, _) => Container(
                        margin: const EdgeInsets.only(left: 4),
                        width: 10 * _pulse.value,
                        height: 10 * _pulse.value,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
                    );
                  } else {
                    return Container(
                      margin: const EdgeInsets.only(left: 4),
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.3),
                        shape: BoxShape.circle,
                      ),
                    );
                  }
                }),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── KARTU SOAL ──────────────────────────────────────────────────────────
  Widget _buildQuestionCard(Question q, Color color) {
    return AnimatedBuilder(
      animation: _cardController,
      builder: (_, child) => Transform.translate(
        offset: Offset(0, _cardSlide.value),
        child: ScaleTransition(scale: _cardScale, child: child),
      ),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFF1D2030), width: 3),
          boxShadow: const [
            BoxShadow(
              color: Color(0xFF1D2030),
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            // Header kartu dengan nomor soal
            Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    color.withValues(alpha: 0.12),
                    color.withValues(alpha: 0.04),
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Soal ${_currentIndex + 1}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Spacer(),
                  if (_currentQuestion.petunjuk.isNotEmpty && !_answered)
                    GestureDetector(
                      onTap: () {
                        SoundService.instance.playClick();
                        _showNextHint();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF3CD),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: const Color(0xFF1D2030), width: 2),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0xFF1D2030),
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.lightbulb_rounded,
                                color: Color(0xFFFFAA00), size: 14),
                            SizedBox(width: 4),
                            Text(
                              'Petunjuk',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFBB8800),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Ilustrasi + pertanyaan
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              child: Column(
                children: [
                  SmartIllustrationCard(
                    ilustrasi: q.ilustrasi,
                    pertanyaan: q.pertanyaan,
                    color: color,
                  ),
                  const SizedBox(height: 14),
                  Text(
                    q.pertanyaan,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),

            // Hint
            if (_showHint && !_answered)
              _buildHintSection(q, color),
          ],
        ),
      ),
    );
  }

  // ── HINT ────────────────────────────────────────────────────────────────
  Widget _buildHintSection(Question q, Color color) {
    if (!_showHint || q.petunjuk.isEmpty) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.fromLTRB(0, 0, 0, 4),
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        children: List.generate(
          (_hintIndex + 1).clamp(0, q.petunjuk.length),
          (i) => Container(
            margin: const EdgeInsets.only(top: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF8E1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF1D2030), width: 2),
              boxShadow: const [
                BoxShadow(
                  color: Color(0xFF1D2030),
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.lightbulb_rounded,
                    color: Color(0xFFFFAA00), size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    q.petunjuk[i],
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF7A5800),
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── MULTIPLE CHOICE ─────────────────────────────────────────────────────
  Widget _buildMultipleChoice(Question q, Color color) {
    final labels = ['A', 'B', 'C', 'D'];
    return Column(
      children: q.pilihan!.asMap().entries.map((entry) {
        final i = entry.key;
        final choice = entry.value;
        final isSelected = _selectedChoice == choice;
        final isCorrect = choice == q.jawaban;

        Color bgColor = Colors.white;
        Color borderColor = Colors.grey.shade200;
        Color textColor = AppColors.textPrimary;
        Color labelBg = Colors.grey.shade100;
        Color labelText = AppColors.textSecondary;
        IconData? trailingIcon;
        Color? trailingColor;

        if (_answered) {
          if (isCorrect) {
            bgColor = const Color(0xFFE8FAF0);
            borderColor = const Color(0xFF4ADE80);
            textColor = const Color(0xFF166534);
            labelBg = const Color(0xFF4ADE80);
            labelText = Colors.white;
            trailingIcon = Icons.check_circle_rounded;
            trailingColor = const Color(0xFF22C55E);
          } else if (isSelected && !isCorrect) {
            bgColor = const Color(0xFFFFF0F0);
            borderColor = const Color(0xFFFF6B6B);
            textColor = const Color(0xFF991B1B);
            labelBg = const Color(0xFFFF6B6B);
            labelText = Colors.white;
            trailingIcon = Icons.cancel_rounded;
            trailingColor = const Color(0xFFEF4444);
          }
        } else if (isSelected) {
          bgColor = Color.lerp(color, Colors.black, 0.15)!;
          borderColor = Color.lerp(color, Colors.black, 0.3)!;
          textColor = Colors.white;
          labelBg = Colors.white.withValues(alpha: 0.9);
          labelText = color;
        }

        return GestureDetector(
          onTap: _answered
              ? null
              : () {
                  SoundService.instance.playClick();
                  setState(() => _selectedChoice = choice);
                },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.only(bottom: 12),
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: borderColor == Colors.grey.shade200 ? const Color(0xFF1D2030) : borderColor, width: 3),
              boxShadow: [
                BoxShadow(
                  color: isSelected && !_answered 
                      ? color.withValues(alpha: 0.8) 
                      : const Color(0xFF1D2030),
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              children: [
                // Label A/B/C/D
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: labelBg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      i < labels.length ? labels[i] : '${i + 1}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: labelText,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Teks pilihan
                Expanded(
                  child: Text(
                    choice,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: isSelected || (_answered && isCorrect)
                          ? FontWeight.bold
                          : FontWeight.w500,
                      color: textColor,
                    ),
                  ),
                ),

                // Trailing icon
                if (trailingIcon != null)
                  Icon(trailingIcon, color: trailingColor, size: 22),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  // ── MATCHING ────────────────────────────────────────────────────────────
  Widget _buildMatching(Question q, Color color) {
    if (q.pasanganKiri == null || q.pasanganKanan == null) {
      return const SizedBox.shrink();
    }
    return MatchingWidget(
      leftItems: q.pasanganKiri!,
      rightItems: q.pasanganKanan!,
      correctAnswer: q.jawaban,
      color: color,
      onSubmitted: (benar) {
        setState(() {
          _answered = true;
          _userAnswers.add(benar ? 'benar' : 'salah');
          if (benar) _benarCount++;
          _results.add(benar);
        });
        if (benar) {
          SoundService.instance.playCorrect();
        } else {
          SoundService.instance.playWrong();
        }
        _feedbackController.reset();
        _feedbackController.forward();
      },
    );
  }

  // ── FILL IN ─────────────────────────────────────────────────────────────
  Widget _buildFillIn(Question q, Color color) {
    final isBenar = _answered && _results.isNotEmpty && _results.last;
    final borderColor = _answered
        ? (isBenar ? const Color(0xFF4ADE80) : const Color(0xFFFF6B6B))
        : color;
    final bgColor = _answered
        ? (isBenar
            ? const Color(0xFFE8FAF0)
            : const Color(0xFFFFF0F0))
        : Colors.white;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor, width: 2.5),
        boxShadow: [
          BoxShadow(
            color: borderColor.withValues(alpha: 0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Jawabanmu:',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_answered)
                Icon(
                  isBenar
                      ? Icons.check_circle_rounded
                      : Icons.cancel_rounded,
                  color: borderColor,
                  size: 28,
                ),
              if (_answered) const SizedBox(width: 10),
              Text(
                _answerCtrl.text.isEmpty ? '?' : _answerCtrl.text,
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w900,
                  color: _answered
                      ? borderColor
                      : (_answerCtrl.text.isEmpty
                          ? AppColors.locked
                          : AppColors.textPrimary),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── FEEDBACK ────────────────────────────────────────────────────────────
  Widget _buildFeedback(Question q, Color color) {
    if (!_answered) return const SizedBox.shrink();
    final benar = _results.last;

    final feedbackWidget = ScaleTransition(
      scale: _feedbackScale,
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(top: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: benar
                ? [const Color(0xFFD1FAE5), const Color(0xFFECFDF5)]
                : [const Color(0xFFFFE4E4), const Color(0xFFFFF5F5)],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: benar
                ? const Color(0xFF4ADE80)
                : const Color(0xFFFF6B6B),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: (benar
                      ? const Color(0xFF4ADE80)
                      : const Color(0xFFFF6B6B))
                  .withValues(alpha: 0.25),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: (benar
                            ? const Color(0xFF4ADE80)
                            : const Color(0xFFFF6B6B))
                        .withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    benar
                        ? Icons.check_circle_rounded
                        : Icons.cancel_rounded,
                    color: benar
                        ? const Color(0xFF22C55E)
                        : const Color(0xFFEF4444),
                    size: 26,
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      benar ? '🎉 Hebat! Benar!' : '😅 Belum tepat...',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: benar
                            ? const Color(0xFF166534)
                            : const Color(0xFF991B1B),
                      ),
                    ),
                    if (!benar)
                      Text(
                        'Jawaban: ${q.jawaban}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFDC2626),
                        ),
                      ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                q.penjelasan,
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textPrimary.withValues(alpha: 0.8),
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );

    if (benar) {
      return CelebrationOverlay(isCorrect: true, child: feedbackWidget);
    } else {
      return ShakeWidget(trigger: true, child: feedbackWidget);
    }
  }

  // ── TOMBOL AKSI ─────────────────────────────────────────────────────────
  Widget _buildActionButton(Color color) {
    final isLast = _currentIndex == _questions.length - 1;
    final label = _answered
        ? (isLast ? '🏆 Lihat Hasil' : 'Lanjut →')
        : 'Jawab';

    return Container(
      padding: EdgeInsets.fromLTRB(
          16, 12, 16, MediaQuery.of(context).padding.bottom + 12),
      child: GestureDetector(
        onTap: () {
          SoundService.instance.playClick();
          if (_answered) {
            _nextQuestion();
          } else {
            _checkAnswer();
          }
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 54,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: _answered
                  ? [const Color(0xFF22C55E), const Color(0xFF16A34A)]
                  : [color, Color.lerp(color, Colors.black, 0.15)!],
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
          child: Center(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── QUIT DIALOG ─────────────────────────────────────────────────────────
  void _showQuitDialog(Color color) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded,
                color: Color(0xFFFFAA00), size: 28),
            SizedBox(width: 8),
            Text('Keluar dari soal?',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        content: const Text(
          'Progresmu tidak akan tersimpan jika keluar sekarang.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          Game3DButton(
            onPressed: () {
              SoundService.instance.playClick();
              Navigator.pop(ctx);
            },
            color: Colors.grey.shade300,
            shadowColor: Colors.grey.shade400,
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text('Lanjutkan', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
            ),
          ),
          Game3DButton(
            onPressed: () {
              SoundService.instance.playClick();
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            color: color,
            shadowColor: Color.lerp(color, Colors.black, 0.4)!,
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text('Keluar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}
