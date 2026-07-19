import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../services/achievement_service.dart';
import '../services/data_service.dart';
import '../models/user_progress_model.dart';
import '../models/achievement_model.dart';
import '../models/topic_model.dart';
import '../models/question_model.dart';
import '../utils/constants.dart';
import 'login_screen.dart';
import 'topic_selection_screen.dart';
import 'leaderboard_page.dart';
import 'quiz_screen.dart';
import 'duel_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/sound_service.dart';
import '../widgets/game_3d_button.dart';
import '../widgets/daily_quest_dialog.dart';
import '../widgets/game_background.dart';
import '../widgets/daily_streak_dialog.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  bool _streakChecked = false;
  
  final GlobalKey _kelasKey = GlobalKey();
  final GlobalKey _misteriKey = GlobalKey();
  final GlobalKey _duelKey = GlobalKey();
  final GlobalKey _questKey = GlobalKey();
  
  late TutorialCoachMark tutorialCoachMark;

  User? get user => AuthService.instance.currentUser;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      SoundService.instance.playBgm();
    });
  }

  @override
  void dispose() {
    SoundService.instance.stopBgm();
    super.dispose();
  }

  void _checkAndShowStreak(UserProgress progress) async {
    final now = DateTime.now();
    final todayStr = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
    
    if (progress.lastLoginDate == todayStr && progress.streakClaimedToday) {
      return;
    }
    
    int newStreak = progress.currentStreak;
    if (progress.lastLoginDate.isNotEmpty && progress.lastLoginDate != todayStr) {
      final lastLogin = DateTime.parse(progress.lastLoginDate);
      final difference = DateTime(now.year, now.month, now.day).difference(DateTime(lastLogin.year, lastLogin.month, lastLogin.day)).inDays;
      
      if (difference == 1) {
        newStreak++;
      } else {
        newStreak = 1;
      }
    } else if (progress.lastLoginDate.isEmpty) {
      newStreak = 1;
    }
    
    if (newStreak > 7) {
       newStreak = 1;
    }
    
    await FirestoreService.instance.updateDailyStreak(
      user!.uid,
      todayStr,
      newStreak,
      false,
    );
    
    if (mounted && !progress.streakClaimedToday) {
       showDialog(
         context: context,
         barrierDismissible: false,
         builder: (_) => DailyStreakDialog(
            streakDay: newStreak,
            onClaim: () {
               int reward = _getStreakReward(newStreak);
               FirestoreService.instance.updateKoin(user!.uid, reward);
               FirestoreService.instance.updateDailyStreak(
                 user!.uid,
                 todayStr,
                 newStreak,
                 true,
               );
               Navigator.pop(context);
            }
         )
       );
    }
  }

  void _showTutorial(UserProgress progress) {
    tutorialCoachMark = TutorialCoachMark(
      targets: _createTargets(),
      colorShadow: AppColors.primary,
      textSkip: "LEWATI",
      paddingFocus: 10,
      opacityShadow: 0.8,
      onFinish: () {
        FirestoreService.instance.updateHasSeenTutorial(user!.uid);
        _checkAndShowStreak(progress);
      },
      onSkip: () {
        FirestoreService.instance.updateHasSeenTutorial(user!.uid);
        _checkAndShowStreak(progress);
        return true;
      },
    )..show(context: context);
  }

  List<TargetFocus> _createTargets() {
    return [
      TargetFocus(
        identify: "kelas-target",
        keyTarget: _kelasKey,
        alignSkip: Alignment.topRight,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder: (context, controller) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text("Pilih Kelasmu!", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 24)),
                  SizedBox(height: 10),
                  Text("Pilih kelas yang sesuai dengan kemampuanmu untuk mulai belajar matematika.", style: TextStyle(color: Colors.white, fontSize: 16)),
                ],
              );
            },
          ),
        ],
      ),
      TargetFocus(
        identify: "misteri-target",
        keyTarget: _misteriKey,
        alignSkip: Alignment.topRight,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            builder: (context, controller) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text("Kuis Misteri", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 24)),
                  SizedBox(height: 10),
                  Text("Selesaikan topik untuk membuka Kuis Misteri dan dapatkan Koin 2x lipat!", style: TextStyle(color: Colors.white, fontSize: 16)),
                ],
              );
            },
          ),
        ],
      ),
      TargetFocus(
        identify: "quest-target",
        keyTarget: _questKey,
        alignSkip: Alignment.bottomLeft,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            builder: (context, controller) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text("Misi Harian", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 24)),
                  SizedBox(height: 10),
                  Text("Selesaikan misimu setiap hari untuk membuka Peti Harta Karun berisi koin melimpah!", style: TextStyle(color: Colors.white, fontSize: 16)),
                ],
              );
            },
          ),
        ],
      ),
    ];
  }

  int _getStreakReward(int day) {
     switch(day) {
       case 1: return 50;
       case 2: return 100;
       case 3: return 150;
       case 4: return 200;
       case 5: return 250;
       case 6: return 300;
       case 7: return 1000;
       default: return 50;
     }
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) return const LoginScreen();

    return StreamBuilder<UserProgress?>(
      stream: FirestoreService.instance.getUserProgressStream(user!.uid),
      builder: (context, snapshot) {
        final progress = snapshot.data;
        if (progress != null && user != null) {
          if (!_streakChecked) {
             _streakChecked = true;
             WidgetsBinding.instance.addPostFrameCallback((_) {
               final isNewUser = progress.koin == 0 && progress.totalKoin == 0 && progress.purchasedAvatars.isEmpty;
               if (!progress.hasSeenTutorial && isNewUser) {
                 _showTutorial(progress);
               } else {
                 _checkAndShowStreak(progress);
               }
             });
          }
          AchievementService.instance.syncAchievements(progress, user!.uid);
          if (progress.koin == 0 && progress.totalKoin > 0 && progress.purchasedAvatars.isEmpty) {
            FirestoreService.instance.updateKoin(user!.uid, progress.totalKoin);
          }
        }
        return Scaffold(
          extendBodyBehindAppBar: true,
          backgroundColor: Colors.transparent,
          body: Stack(
            children: [
              const Positioned.fill(
                child: GameBackground(child: SizedBox()),
              ),
              SafeArea(
                child: IndexedStack(
                  index: _currentIndex,
                  children: [
                    _KelasPage(
                      progress: progress, 
                      user: user!,
                      kelasKey: _kelasKey,
                      misteriKey: _misteriKey,
                      duelKey: _duelKey,
                      questKey: _questKey,
                    ),
                    LeaderboardPage(currentProgress: progress),
                    _ShopPage(progress: progress, user: user!),
                    _ProfilPage(progress: progress, user: user!),
                  ],
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: _buildFloatingNavBar(),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFloatingNavBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
      height: 90,
      color: Colors.transparent,
      child: Container(
        height: 70,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(35),
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: _buildNavItem(0, Icons.videogame_asset_rounded, 'Main'),
            ),
            Expanded(
              child: _buildNavItem(1, Icons.leaderboard_rounded, 'Peringkat'),
            ),
            Expanded(
              child: _buildNavItem(2, Icons.storefront_rounded, 'Toko'),
            ),
            Expanded(
              child: _buildNavItem(3, Icons.face_retouching_natural_rounded, 'Profil'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () {
        SoundService.instance.playClick();
        setState(() => _currentIndex = index);
      },
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: EdgeInsets.fromLTRB(6, isSelected ? 5 : 6, 6, isSelected ? 7 : 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFFB300) : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
          boxShadow: isSelected ? [
            const BoxShadow(color: Color(0xFFF57C00), offset: Offset(0, 4)),
          ] : [],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: isSelected ? 26 : 24,
              color: isSelected ? Colors.white : AppColors.textSecondary,
              shadows: isSelected ? const [Shadow(color: Colors.black26, blurRadius: 4)] : [],
            ),
            if (isSelected)
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  shadows: [Shadow(color: Colors.black26, blurRadius: 2)],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _KelasPage extends StatelessWidget {
  final UserProgress? progress;
  final User user;
  final GlobalKey kelasKey;
  final GlobalKey misteriKey;
  final GlobalKey duelKey;
  final GlobalKey questKey;

  const _KelasPage({
    required this.progress, 
    required this.user,
    required this.kelasKey,
    required this.misteriKey,
    required this.duelKey,
    required this.questKey,
  });

  Future<void> _startDailyChallenge(BuildContext context, UserProgress? progress) async {
    if (progress == null) return;
    
    List<TopicProgress> passedTopicProgresses = progress.topikProgress.values.where((p) => p.lulus).toList();
    
    if (passedTopicProgresses.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selesaikan minimal 1 topik dulu untuk membuka Kuis Misteri!'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );
    
    try {
      List<Question> allQuestions = [];
      passedTopicProgresses.shuffle();
      final topicsToLoad = passedTopicProgresses.take(5).toList();
      
      for (var tp in topicsToLoad) {
        final topicObj = await DataService.instance.getTopic(tp.topikId);
        allQuestions.addAll(topicObj.soal);
      }
      
      allQuestions.shuffle();
      final selectedQuestions = allQuestions.take(5).toList();
      
      if (context.mounted) Navigator.pop(context);
      
      if (selectedQuestions.isEmpty) return;
      
      final challengeTopic = Topic(
        id: 'daily-challenge',
        kelas: progress.kelasAktif,
        topik: 'Kuis Misteri Harian',
        deskripsi: 'Tantangan Harian',
        jumlahSoal: 5,
        icon: '🎁',
        soal: selectedQuestions,
      );
      
      if (context.mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => QuizScreen(
              topic: challengeTopic,
              kelas: progress.kelasAktif,
              quizMode: 'misteri',
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) Navigator.pop(context);
    }
  }

  Future<void> _startDuelMode(BuildContext context, UserProgress? progress) async {
    if (progress == null) return;
    
    List<TopicProgress> passedTopicProgresses = progress.topikProgress.values.where((p) => p.lulus).toList();
    
    if (passedTopicProgresses.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selesaikan minimal 1 topik dulu untuk membuka Mode Duel!'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );
    
    try {
      List<Question> allQuestions = [];
      passedTopicProgresses.shuffle();
      final topicsToLoad = passedTopicProgresses.take(5).toList();
      
      for (var tp in topicsToLoad) {
        final topicObj = await DataService.instance.getTopic(tp.topikId);
        allQuestions.addAll(topicObj.soal);
      }
      
      allQuestions.shuffle();
      final selectedQuestions = allQuestions.take(10).toList(); // 10 questions for duel
      
      if (context.mounted) Navigator.pop(context);
      
      if (selectedQuestions.isEmpty) return;
      
      if (context.mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DuelScreen(
              questions: selectedQuestions,
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final nama = progress?.nama ?? user.displayName ?? 'Siswa';
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: const Color(0xFF1D2030), width: 3),
                    boxShadow: const [
                      BoxShadow(color: Color(0xFF1D2030), offset: Offset(0, 6)),
                    ],
                  ),
                  child: StatefulBuilder(
                    builder: (context, setInnerState) {
                      final bgmOn = SoundService.instance.isBgmEnabled;
                      return Row(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: AppColors.primary,
                            backgroundImage: progress?.profileImage.isNotEmpty == true
                                ? AssetImage(progress!.profileImage)
                                : null,
                            child: progress?.profileImage.isEmpty != false
                                ? Text(
                                    nama.isNotEmpty ? nama[0].toUpperCase() : 'S',
                                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                                  )
                                : null,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('PEMAIN', style: TextStyle(fontSize: 10, color: AppColors.textSecondary, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                                Text(nama, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(Icons.auto_awesome_rounded, size: 14, color: AppColors.secondary),
                                    const SizedBox(width: 4),
                                    Text('${progress?.totalXP ?? 0} XP', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
                                    const SizedBox(width: 12),
                                    Icon(Icons.star_rounded, size: 14, color: AppColors.secondary),
                                    const SizedBox(width: 4),
                                    Text('${_totalBintang(progress)}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
                                    const SizedBox(width: 12),
                                    Icon(Icons.monetization_on_rounded, size: 14, color: AppColors.secondary),
                                    const SizedBox(width: 4),
                                    Text('${progress?.koin ?? 0}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          GestureDetector(
                            key: questKey,
                            onTap: () {
                              if (progress != null) {
                                showDialog(
                                  context: context,
                                  builder: (_) => DailyQuestDialog(progress: progress!),
                                );
                              }
                            },
                            child: Container(
                              width: 40,
                              height: 40,
                              margin: const EdgeInsets.only(right: 8),
                              decoration: BoxDecoration(
                                color: Colors.amber.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.assignment_rounded,
                                color: Colors.amber,
                                size: 22,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              SoundService.instance.toggleBgm();
                              setInnerState(() {});
                            },
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                bgmOn ? Icons.volume_up_rounded : Icons.volume_off_rounded,
                                color: AppColors.primary,
                                size: 22,
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      key: misteriKey,
                      child: Game3DButton(
                        onPressed: () => _startDailyChallenge(context, progress),
                        color: AppColors.secondary,
                        shadowColor: Color.lerp(AppColors.secondary, Colors.black, 0.4)!,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.stars_rounded, color: Colors.white, size: 28),
                              const SizedBox(width: 6),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Text(
                                    'Kuis Misteri',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                  Text(
                                    'Dapat 2x Koin!',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      key: duelKey,
                      child: Game3DButton(
                        onPressed: () => _startDuelMode(context, progress),
                        color: const Color(0xFFFF6B6B), // Red/Pinkish for duel
                        shadowColor: const Color(0xFFB93333),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.sports_esports_rounded, color: Colors.white, size: 28),
                              const SizedBox(width: 6),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Text(
                                    'Duel 1v1',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                  Text(
                                    'Main Bareng!',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Stack(
                  key: kelasKey,
                  children: [
                    Text(
                      'PILIH KELAS',
                      style: GoogleFonts.fredoka(
                        fontSize: 44,
                        fontWeight: FontWeight.w900,
                        foreground: Paint()
                          ..style = PaintingStyle.stroke
                          ..strokeWidth = 10
                          ..color = const Color(0xFFFFB300), // Yellow
                      ),
                    ),
                    Text(
                      'PILIH KELAS',
                      style: GoogleFonts.fredoka(
                        fontSize: 44,
                        fontWeight: FontWeight.w900,
                        color: Colors.white, // Back to white
                        shadows: const [Shadow(color: Colors.black45, blurRadius: 8, offset: Offset(0, 4))],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFB300),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: const [BoxShadow(color: Color(0xFFF57C00), offset: Offset(0, 4))],
                  ),
                  child: const Text(
                    'Siap untuk petualangan baru?',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 4),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.0,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final kelas = index + 1;
                final unlocked = _isKelasUnlocked(kelas, progress);
                return _buildKelasCard(context, kelas, unlocked, progress);
              },
              childCount: 6,
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 120)),
      ],
    );
  }

  bool _isKelasUnlocked(int kelas, UserProgress? progress) {
    if (kelas == 1) return true;
    final prevTopics = AppConstants.getTopicOrder(kelas - 1);
    final reviewId = prevTopics.last;
    final prevProgress = progress?.getTopikProgress(reviewId, kelas - 1);
    return prevProgress?.lulus ?? false;
  }

  int _totalBintang(UserProgress? progress) {
    if (progress == null) return 0;
    int total = 0;
    for (final p in progress.topikProgress.values) {
      if (p.skor >= 90) {
        total += 3;
      } else if (p.skor >= 70) {
        total += 2;
      } else if (p.skor >= AppConstants.skorLulusMinimum) {
        total += 1;
      }
    }
    return total;
  }

  Widget _buildKelasCard(
      BuildContext context, int kelas, bool unlocked, UserProgress? progress) {
    final color = AppConstants.warnaKelas[kelas] ?? AppColors.primary;
    final shadowColor = Color.lerp(color, Colors.black, 0.4)!;
    final namaKelas = AppConstants.namaKelas[kelas] ?? 'Kelas $kelas';

    int completedCount = 0;
    if (progress != null) {
      final topics = AppConstants.getTopicOrder(kelas);
      for (final t in topics) {
        final p = progress.getTopikProgress(t, kelas);
        if (p?.lulus == true) completedCount++;
      }
    }
    final totalTopics = AppConstants.getTopicOrder(kelas).length;
    final double progressValue = totalTopics > 0 ? completedCount / totalTopics : 0;

    return Game3DButton(
      onPressed: unlocked
          ? () {
              SoundService.instance.playClick();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => TopicSelectionScreen(kelas: kelas),
                ),
              );
            }
          : null,
      color: unlocked ? color : Colors.grey.shade400,
      shadowColor: unlocked ? shadowColor : Colors.grey.shade600,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      'Kelas $kelas',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                Icon(
                  unlocked ? Icons.play_circle_fill_rounded : Icons.lock_rounded,
                  color: Colors.white,
                  size: 28,
                  shadows: const [Shadow(color: Colors.black26, blurRadius: 4)],
                ),
              ],
            ),
            const Spacer(),
            Text(
              namaKelas,
              maxLines: 2,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                height: 1.1,
                shadows: [Shadow(color: Colors.black45, blurRadius: 6, offset: Offset(0, 2))],
              ),
            ),
            const SizedBox(height: 8),
            if (unlocked) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Stack(
                  children: [
                    Container(height: 10, color: Colors.black.withValues(alpha: 0.2)),
                    FractionallySizedBox(
                      widthFactor: progressValue,
                      child: Container(
                        height: 10,
                        decoration: BoxDecoration(
                          color: const Color(0xFF4ADE80),
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: const [BoxShadow(color: Colors.white54, blurRadius: 2, offset: Offset(0, 1))],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '$completedCount/$totalTopics Selesai',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ] else
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Terkunci',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ProfilPage extends StatelessWidget {
  final UserProgress? progress;
  final User user;

  const _ProfilPage({required this.progress, required this.user});

  @override
  Widget build(BuildContext context) {
    final nama = progress?.nama ?? user.displayName ?? 'Siswa';
    final email = progress?.email ?? user.email ?? '';
    final kelasAktif = progress?.kelasAktif ?? 1;
    final profileImage = progress?.profileImage ?? '';

    int totalSelesai = 0;
    int totalSoal = 0;
    final p = progress;
    if (p != null) {
      for (int k = 1; k <= 6; k++) {
        final topics = AppConstants.getTopicOrder(k);
        for (final t in topics) {
          final tp = p.getTopikProgress(t, k);
          if (tp != null) {
            totalSelesai++;
            totalSoal += tp.jumlahSoal;
          }
        }
      }
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFF1D2030), width: 3),
          boxShadow: const [
            BoxShadow(
              color: Color(0xFF1D2030),
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () => _showProfileImagePicker(context),
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: AppColors.primary,
                  backgroundImage: profileImage.isNotEmpty
                      ? AssetImage(profileImage)
                      : null,
                  child: profileImage.isEmpty
                      ? Text(
                          nama.isNotEmpty ? nama[0].toUpperCase() : 'S',
                          style: const TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        )
                      : null,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      size: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Tap untuk ubah foto profil',
            style: TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            nama,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            email,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF1D2030), width: 3),
              boxShadow: const [
                BoxShadow(
                  color: Color(0xFF1D2030),
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              children: [
                _buildProfileStat(
                  Icons.book_rounded,
                  '$totalSelesai',
                  'Materi Dikerjakan',
                  AppColors.primary,
                ),
                const Divider(height: 16),
                _buildProfileStat(
                  Icons.check_circle_rounded,
                  '$totalSoal',
                  'Total Soal Dijawab',
                  AppColors.success,
                ),
                const Divider(height: 16),
                _buildProfileStat(
                  Icons.school_rounded,
                  'Kelas $kelasAktif',
                  'Kelas Aktif',
                  AppColors.secondary,
                ),
              ],
            ),
          ),
          // ── Achievements ──
          const SizedBox(height: 16),
          _AchievementsSection(progress: p),
          // ── Settings ──
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF1D2030), width: 3),
              boxShadow: const [
                BoxShadow(
                  color: Color(0xFF1D2030),
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Pengaturan',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                StatefulBuilder(
                  builder: (context, setInnerState) {
                    final bgmOn = SoundService.instance.isBgmEnabled;
                    return Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            bgmOn ? Icons.music_note_rounded : Icons.music_off_rounded,
                            color: AppColors.primary,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 14),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Musik Latar',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              Text(
                                'Suara latar saat bermain',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Switch(
                          value: bgmOn,
                          activeThumbColor: AppColors.primary,
                          activeTrackColor: AppColors.primary.withValues(alpha: 0.5),
                          onChanged: (v) {
                            SoundService.instance.setBgmEnabled(v);
                            setInnerState(() {});
                          },
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: Game3DButton(
              onPressed: () async {
                SoundService.instance.playClick();
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                      side: const BorderSide(color: Color(0xFF1D2030), width: 3),
                    ),
                    title: const Text(
                      'Yakin ingin keluar?',
                      style: TextStyle(fontWeight: FontWeight.w900, color: AppColors.textPrimary),
                    ),
                    content: const Text(
                      'Kamu akan kembali ke halaman login.',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                    actions: [
                      Game3DButton(
                        onPressed: () {
                          SoundService.instance.playClick();
                          Navigator.pop(ctx, false);
                        },
                        color: Colors.white,
                        shadowColor: Colors.grey.shade400,
                        child: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Text(
                            'Batal',
                            style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textSecondary),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Game3DButton(
                        onPressed: () {
                          SoundService.instance.playClick();
                          Navigator.pop(ctx, true);
                        },
                        color: AppColors.danger,
                        shadowColor: AppColors.danger.withValues(alpha: 0.6),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Text(
                            'Keluar',
                            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
                if (confirm != true) return;
                await AuthService.instance.signOut();
                if (context.mounted) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  );
                }
              },
              color: AppColors.danger,
              shadowColor: AppColors.danger.withValues(alpha: 0.6),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.logout, color: Colors.white),
                  SizedBox(width: 8),
                  Text(
                    'Keluar',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
    const SizedBox(height: 90),
      ],
    ),
  );
  }

  Widget _buildProfileStat(
      IconData icon, String value, String label, Color color) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showProfileImagePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.85,
          expand: false,
          builder: (context, scrollController) {
            return Column(
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'Pilih Foto Profil',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  child: GridView.builder(
                    controller: scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemCount: AuthService.profileImages.where((path) => AuthService.isFreeAvatar(path) || progress?.purchasedAvatars.contains(path) == true).length,
                    itemBuilder: (context, index) {
                      final availableAvatars = AuthService.profileImages.where((path) => AuthService.isFreeAvatar(path) || progress?.purchasedAvatars.contains(path) == true).toList();
                      final imgPath = availableAvatars[index];
                      final currentImage = progress?.profileImage ?? '';
                      final isSelected = imgPath == currentImage;
                      return GestureDetector(
                        onTap: () async {
                          SoundService.instance.playClick();
                          await FirestoreService.instance
                              .updateProfileImage(user.uid, imgPath);
                          if (context.mounted) Navigator.pop(context);
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.primary
                                  : Colors.transparent,
                              width: 3,
                            ),
                          ),
                          child: ClipOval(
                            child: Image.asset(
                              imgPath,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _AchievementsSection extends StatelessWidget {
  final UserProgress? progress;

  const _AchievementsSection({required this.progress});

  @override
  Widget build(BuildContext context) {
    if (progress == null) return const SizedBox.shrink();
    final achievements = AchievementService.instance.evaluateAchievements(progress!);
    final unlockedCount = achievements.where((a) => a.unlocked).length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.emoji_events_rounded, color: Color(0xFFFFD700), size: 20),
              const SizedBox(width: 8),
              const Text(
                'Lencana',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$unlockedCount/${achievements.length}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: achievements.map((a) => _buildBadge(a)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(Achievement a) {
    return Tooltip(
      message: '${a.title}\n${a.description}',
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: a.unlocked
              ? a.color.withValues(alpha: 0.15)
              : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: a.unlocked
                ? a.color.withValues(alpha: 0.4)
                : Colors.grey.shade200,
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              a.icon,
              size: 22,
              color: a.unlocked ? a.color : Colors.grey.shade400,
            ),
            Text(
              a.title,
              style: TextStyle(
                fontSize: 8,
                fontWeight: FontWeight.bold,
                color: a.unlocked ? a.color : Colors.grey.shade400,
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _ShopPage extends StatelessWidget {
  final UserProgress? progress;
  final User user;

  const _ShopPage({required this.progress, required this.user});

  @override
  Widget build(BuildContext context) {
    final koin = progress?.koin ?? 0;
    final purchased = progress?.purchasedAvatars ?? [];
    final purchasable = AuthService.purchasableAvatars;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: const Color(0xFF1D2030), width: 3),
              boxShadow: const [
                BoxShadow(color: Color(0xFF1D2030), offset: Offset(0, 6)),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.monetization_on_rounded, color: AppColors.secondary, size: 28),
                const SizedBox(width: 8),
                Text(
                  '$koin Koin',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.textPrimary),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.75,
            ),
            itemCount: purchasable.length,
            itemBuilder: (context, index) {
              final avatarPath = purchasable[index];
              final price = AuthService.getAvatarPrice(avatarPath);
              final isPurchased = purchased.contains(avatarPath);
              
              return GestureDetector(
                onTap: isPurchased ? null : () => _buyAvatar(context, avatarPath, price, koin),
                child: Container(
                  decoration: BoxDecoration(
                    color: isPurchased ? AppColors.success.withValues(alpha: 0.1) : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isPurchased ? AppColors.success : const Color(0xFF1D2030),
                      width: 2,
                    ),
                    boxShadow: isPurchased ? [] : const [
                      BoxShadow(color: Color(0xFF1D2030), offset: Offset(0, 4)),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Image.asset(avatarPath),
                        ),
                      ),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        decoration: BoxDecoration(
                          color: isPurchased ? AppColors.success : AppColors.secondary,
                          borderRadius: const BorderRadius.vertical(bottom: Radius.circular(14)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (!isPurchased) ...[
                              const Icon(Icons.monetization_on_rounded, size: 14, color: Colors.white),
                              const SizedBox(width: 4),
                            ],
                            Text(
                              isPurchased ? 'Dimiliki' : '$price',
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _buyAvatar(BuildContext context, String avatarPath, int price, int currentKoin) {
    if (currentKoin < price) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.warning_rounded, color: Colors.white),
              SizedBox(width: 12),
              Text('Koin kamu tidak mencukupi!', style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          backgroundColor: AppColors.danger,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }
    SoundService.instance.playClick();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: Color(0xFF1D2030), width: 3),
        ),
        title: const Text('Beli Avatar', style: TextStyle(fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(avatarPath, width: 80, height: 80),
            const SizedBox(height: 16),
            Text('Apakah kamu ingin membeli avatar ini seharga $price koin?', 
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary)
            ),
          ],
        ),
        actions: [
          Game3DButton(
            onPressed: () {
              SoundService.instance.playClick();
              Navigator.pop(ctx);
            },
            color: Colors.white,
            shadowColor: Colors.grey.shade400,
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text('Batal', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
            ),
          ),
          const SizedBox(width: 8),
          Game3DButton(
            onPressed: () async {
              SoundService.instance.playClick();
              Navigator.pop(ctx);
              await FirestoreService.instance.buyAvatar(user.uid, avatarPath, price);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Avatar berhasil dibeli!')),
                );
              }
            },
            color: AppColors.secondary,
            shadowColor: const Color(0xFFF57C00),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text('Beli', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}
