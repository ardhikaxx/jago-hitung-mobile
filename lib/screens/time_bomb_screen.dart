import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/question_model.dart';
import '../services/sound_service.dart';
import '../utils/constants.dart';
import '../widgets/game_background.dart';
import '../widgets/screen_shake_widget.dart';
import '../widgets/countdown_overlay_widget.dart';

class TimeBombScreen extends StatefulWidget {
  final List<Question> questions;

  const TimeBombScreen({super.key, required this.questions});

  @override
  State<TimeBombScreen> createState() => _TimeBombScreenState();
}

class _TimeBombScreenState extends State<TimeBombScreen> with TickerProviderStateMixin {
  int _score = 0;
  int _currentIndex = 0;
  bool _answered = false;
  
  Timer? _timer;
  int _timeLeft = 60; // 60 seconds start
  
  late Question _currentQuestion;
  List<String> _shuffledChoices = [];
  
  final TextEditingController _answerCtrl = TextEditingController();
  final GlobalKey<ScreenShakeWidgetState> _shakeKey = GlobalKey<ScreenShakeWidgetState>();
  
  late AnimationController _bombPulseController;
  late Animation<double> _bombPulse;
  
  bool _isRedFlash = false;
  bool _isGreenFlash = false;

  bool _isCountingDown = true;
  int _countdown = 3;
  bool _showGo = false;

  @override
  void initState() {
    super.initState();
    _bombPulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..repeat(reverse: true);
    
    _bombPulse = Tween<double>(begin: 1.0, end: 1.2).animate(_bombPulseController);
    
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
        _startTimer();
      });
    }
  }
  
  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        _timeLeft--;
        if (_timeLeft <= 0) {
          _timeLeft = 0;
          _endGame();
        } else if (_timeLeft <= 10) {
          _bombPulseController.duration = const Duration(milliseconds: 200);
          if (!_bombPulseController.isAnimating) _bombPulseController.repeat(reverse: true);
        } else {
          _bombPulseController.duration = const Duration(milliseconds: 500);
          if (!_bombPulseController.isAnimating) _bombPulseController.repeat(reverse: true);
        }
      });
    });
  }

  void _loadQuestion() {
    if (_currentIndex >= widget.questions.length) {
      _endGame();
      return;
    }
    _currentQuestion = widget.questions[_currentIndex];
    if (_currentQuestion.isMultipleChoice) {
      _shuffledChoices = List.from(_currentQuestion.pilihan ?? []);
      _shuffledChoices.shuffle();
    }
    _answerCtrl.clear();
    _answered = false;
  }

  void _checkAnswer(String answer) {
    if (_isCountingDown) return;
    if (_answered) return;
    
    if (answer.isEmpty) {
      HapticFeedback.lightImpact();
      return;
    }

    final isCorrect = answer.toLowerCase() == _currentQuestion.jawaban.toLowerCase();

    setState(() {
      _answered = true;
      if (isCorrect) {
        _score++;
        _timeLeft += 3;
        _isGreenFlash = true;
        SoundService.instance.playCorrect();
      } else {
        _timeLeft -= 5;
        if (_timeLeft < 0) _timeLeft = 0;
        _isRedFlash = true;
        _shakeKey.currentState?.shake();
        SoundService.instance.playWrong();
      }
    });

    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() {
          _isRedFlash = false;
          _isGreenFlash = false;
        });
      }
    });

    if (_timeLeft <= 0) {
      _endGame();
    } else {
      Future.delayed(const Duration(milliseconds: 600), () {
        if (!mounted) return;
        setState(() {
          _currentIndex++;
          _loadQuestion();
        });
      });
    }
  }

  void _endGame() {
    _timer?.cancel();
    _bombPulseController.stop();
    SoundService.instance.playWrong(); // or a bomb explosion sound if available
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Column(
          children: [
            Icon(Icons.timer_off_rounded, size: 48, color: Colors.red),
            SizedBox(height: 8),
            Text("WAKTU HABIS!", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Skormu di Mode Bom Waktu:", style: TextStyle(fontSize: 16)),
            const SizedBox(height: 12),
            Text("$_score Soal", style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w900, color: AppColors.primary)),
            const SizedBox(height: 16),
            const Text("Bagus sekali! Mode ini tidak memberikan XP/Koin, ini murni untuk latihan kecepatanmu.", textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              onPressed: () {
                SoundService.instance.playClick();
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: const Text("KEMBALI", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
            ),
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _bombPulseController.dispose();
    _answerCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () {
            SoundService.instance.playClick();
            Navigator.pop(context);
          },
        ),
      ),
      body: Stack(
        children: [
          const Positioned.fill(
            child: GameBackground(child: SizedBox()),
          ),
          Positioned.fill(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              color: _isRedFlash 
                  ? Colors.red.withValues(alpha: 0.3) 
                  : _isGreenFlash 
                      ? Colors.green.withValues(alpha: 0.3) 
                      : Colors.black.withValues(alpha: 0.4),
            ),
          ),
          ScreenShakeWidget(
            shakeKey: _shakeKey,
            shakeCount: 4,
            shakeOffset: 15.0,
            duration: const Duration(milliseconds: 300),
            child: SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  ScaleTransition(
                    scale: _bombPulse,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      decoration: BoxDecoration(
                        color: _timeLeft <= 10 ? Colors.red : const Color(0xFF1D2030),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: Colors.white, width: 3),
                        boxShadow: [
                          BoxShadow(color: _timeLeft <= 10 ? Colors.redAccent : Colors.black54, blurRadius: 10, spreadRadius: 2),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.timer_rounded, color: Colors.white, size: 28),
                          const SizedBox(width: 12),
                          Text(
                            "$_timeLeft",
                            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Colors.white),
                          ),
                          const SizedBox(width: 8),
                          const Text("dtk", style: TextStyle(fontSize: 16, color: Colors.white70, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text("Skor: $_score", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.amber)),
                  const SizedBox(height: 16),
                  
                  // Question Card
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          children: [
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(color: const Color(0xFF1D2030), width: 3),
                                boxShadow: const [BoxShadow(color: Color(0xFF1D2030), offset: Offset(0, 8))],
                              ),
                              child: Text(
                                _currentQuestion.pertanyaan,
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                              ),
                            ),
                            const SizedBox(height: 32),
                            if (_currentQuestion.isMultipleChoice)
                              ..._shuffledChoices.map((choice) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: SizedBox(
                                    width: double.infinity,
                                    height: 60,
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.white,
                                        foregroundColor: AppColors.primary,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(20),
                                          side: const BorderSide(color: AppColors.primary, width: 2),
                                        ),
                                        elevation: 4,
                                      ),
                                      onPressed: () => _checkAnswer(choice),
                                      child: Text(choice, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                                    ),
                                  ),
                                );
                              }).toList()
                            else
                              Column(
                                children: [
                                  TextField(
                                    controller: _answerCtrl,
                                    keyboardType: TextInputType.number,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                                    decoration: InputDecoration(
                                      hintText: '?',
                                      filled: true,
                                      fillColor: Colors.white,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(20),
                                        borderSide: const BorderSide(color: AppColors.primary, width: 3),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(20),
                                        borderSide: const BorderSide(color: AppColors.primary, width: 3),
                                      ),
                                    ),
                                    onSubmitted: (val) => _checkAnswer(val),
                                  ),
                                  const SizedBox(height: 16),
                                  SizedBox(
                                    width: double.infinity,
                                    height: 60,
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.primary,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                      ),
                                      onPressed: () => _checkAnswer(_answerCtrl.text.trim()),
                                      child: const Text("JAWAB", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                                    ),
                                  )
                                ],
                              )
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          if (_isCountingDown)
            CountdownOverlayWidget(countdown: _countdown, showGo: _showGo),
        ],
      ),
    );
  }
}
