import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../services/data_service.dart';
import '../services/firestore_service.dart';
import '../models/topic_model.dart';
import '../models/user_progress_model.dart';
import '../utils/constants.dart';
import 'quiz_screen.dart';
import '../services/sound_service.dart';
import '../widgets/game_background.dart';

// ── Icon mapping per topik ──────────────────────────────────────────────────
const Map<String, IconData> _topicIcons = {
  'k1-mengenal-angka': Icons.looks_one_rounded,
  'k1-penjumlahan-dasar': Icons.add_circle_outline,
  'k1-penjumlahan-pengurangan': Icons.calculate_rounded,
  'k1-bangun-datar': Icons.category_rounded,
  'k1-mengurutkan-angka': Icons.sort_rounded,
  'k1-membandingkan-bilangan': Icons.compare_arrows_rounded,
  'k1-menghitung-benda': Icons.widgets_rounded,
  'k1-pasangan-bilangan': Icons.join_inner_rounded,
  'k1-pengurangan-dasar': Icons.remove_circle_outline,
  'k1-cerita-penjumlahan': Icons.auto_stories_rounded,
  'k1-cerita-pengurangan': Icons.menu_book_rounded,
  'k1-bilangan-loncat-2': Icons.redo_rounded,
  'k1-bilangan-loncat-5': Icons.fast_forward_rounded,
  'k1-puluhan-satuan': Icons.layers_rounded,
  'k1-nilai-tempat': Icons.table_rows_rounded,
  'k1-pola-bentuk': Icons.interests_rounded,
  'k1-pengukuran-panjang-nonbaku': Icons.straighten_rounded,
  'k1-membaca-jam-tepat': Icons.access_time_rounded,
  'k1-uang-koin': Icons.monetization_on_rounded,
  'k1-review-kelas-1': Icons.emoji_events_rounded,
  'k2-penjumlahan-pengurangan-bersusun': Icons.format_list_numbered_rounded,
  'k2-mengenal-perkalian': Icons.close_rounded,
  'k2-bilangan-sampai-100': Icons.filter_9_plus_rounded,
  'k2-nilai-tempat-ratusan': Icons.stacked_bar_chart_rounded,
  'k2-membandingkan-bilangan': Icons.compare_arrows_rounded,
  'k2-penjumlahan-tanpa-menyimpan': Icons.add_rounded,
  'k2-penjumlahan-dengan-menyimpan': Icons.add_box_rounded,
  'k2-pengurangan-tanpa-meminjam': Icons.remove_rounded,
  'k2-pengurangan-dengan-meminjam': Icons.indeterminate_check_box_rounded,
  'k2-soal-cerita-campuran': Icons.auto_stories_rounded,
  'k2-tabel-perkalian-2': Icons.grid_3x3_rounded,
  'k2-tabel-perkalian-5': Icons.apps_rounded,
  'k2-tabel-perkalian-10': Icons.grid_4x4_rounded,
  'k2-mengenal-pembagian': Icons.call_split_rounded,
  'k2-pecahan-setengah-seperempat': Icons.pie_chart_rounded,
  'k2-mengukur-panjang-cm': Icons.straighten_rounded,
  'k2-mengukur-berat': Icons.scale_rounded,
  'k2-membaca-waktu': Icons.schedule_rounded,
  'k2-uang-rupiah': Icons.payments_rounded,
  'k2-review-kelas-2': Icons.emoji_events_rounded,
  'k3-perkalian-pembagian': Icons.calculate_rounded,
  'k3-pecahan-sederhana': Icons.donut_small_rounded,
  'k3-bilangan-sampai-1000': Icons.filter_9_plus_rounded,
  'k3-nilai-tempat-ribuan': Icons.stacked_bar_chart_rounded,
  'k3-penjumlahan-bersusun': Icons.add_box_rounded,
  'k3-pengurangan-bersusun': Icons.indeterminate_check_box_rounded,
  'k3-perkalian-6-9': Icons.close_rounded,
  'k3-perkalian-dua-angka': Icons.grid_3x3_rounded,
  'k3-pembagian-bersisa': Icons.call_split_rounded,
  'k3-soal-cerita-perkalian': Icons.auto_stories_rounded,
  'k3-soal-cerita-pembagian': Icons.menu_book_rounded,
  'k3-pecahan-senilai': Icons.pie_chart_outline_rounded,
  'k3-membandingkan-pecahan': Icons.compare_rounded,
  'k3-satuan-panjang': Icons.straighten_rounded,
  'k3-keliling-bangun-datar': Icons.crop_square_rounded,
  'k3-luas-persegi-persegi-panjang': Icons.square_rounded,
  'k3-sudut-dasar': Icons.change_history_rounded,
  'k3-diagram-gambar': Icons.bar_chart_rounded,
  'k3-pola-bilangan': Icons.pattern_rounded,
  'k3-review-kelas-3': Icons.emoji_events_rounded,
  'k4-bilangan-bulat': Icons.exposure_rounded,
  'k4-keliling-luas': Icons.fullscreen_rounded,
  'k4-operasi-bilangan-besar': Icons.calculate_rounded,
  'k4-perkalian-bersusun': Icons.grid_3x3_rounded,
  'k4-pembagian-bersusun': Icons.call_split_rounded,
  'k4-kpk': Icons.sync_rounded,
  'k4-fpb': Icons.hub_rounded,
  'k4-faktor-kelipatan': Icons.account_tree_rounded,
  'k4-pecahan-senilai': Icons.donut_small_rounded,
  'k4-menyederhanakan-pecahan': Icons.compress_rounded,
  'k4-penjumlahan-pecahan': Icons.add_rounded,
  'k4-pengurangan-pecahan': Icons.remove_rounded,
  'k4-desimal-dasar': Icons.numbers_rounded,
  'k4-pembulatan': Icons.adjust_rounded,
  'k4-sudut-dan-busur': Icons.architecture_rounded,
  'k4-bangun-datar-lanjut': Icons.hexagon_rounded,
  'k4-simetri': Icons.flip_rounded,
  'k4-diagram-batang': Icons.bar_chart_rounded,
  'k4-pola-bilangan-lanjut': Icons.trending_up_rounded,
  'k4-review-kelas-4': Icons.emoji_events_rounded,
  'k5-perkalian-pembagian-pecahan': Icons.pie_chart_rounded,
  'k5-volume-bangun-ruang': Icons.view_in_ar_rounded,
  'k5-operasi-hitung-campuran': Icons.functions_rounded,
  'k5-bilangan-pangkat-dua': Icons.superscript_rounded,
  'k5-akar-pangkat-dua': Icons.square_foot_rounded,
  'k5-fpb-kpk-lanjut': Icons.account_tree_rounded,
  'k5-pecahan-campuran': Icons.pie_chart_rounded,
  'k5-penjumlahan-pecahan-beda-penyebut': Icons.add_rounded,
  'k5-pengurangan-pecahan-beda-penyebut': Icons.remove_rounded,
  'k5-desimal-dan-pecahan': Icons.numbers_rounded,
  'k5-persen-dasar': Icons.percent_rounded,
  'k5-perbandingan': Icons.compare_arrows_rounded,
  'k5-skala-denah': Icons.map_rounded,
  'k5-kecepatan-jarak-waktu': Icons.speed_rounded,
  'k5-luas-trapesium-layang': Icons.change_history_rounded,
  'k5-jaring-jaring-bangun-ruang': Icons.view_in_ar_rounded,
  'k5-satuan-volume': Icons.water_drop_rounded,
  'k5-pengolahan-data': Icons.analytics_rounded,
  'k5-peluang-sederhana': Icons.casino_rounded,
  'k5-review-kelas-5': Icons.emoji_events_rounded,
  'k6-bilangan-bulat-negatif': Icons.exposure_neg_1_rounded,
  'k6-statistika-dasar': Icons.analytics_rounded,
  'k6-operasi-pecahan-desimal-persen': Icons.functions_rounded,
  'k6-rasio-dan-perbandingan': Icons.compare_arrows_rounded,
  'k6-skala-peta': Icons.map_rounded,
  'k6-debit': Icons.water_drop_rounded,
  'k6-luas-lingkaran': Icons.circle_rounded,
  'k6-keliling-lingkaran': Icons.radio_button_unchecked_rounded,
  'k6-volume-prisma-tabung': Icons.view_in_ar_rounded,
  'k6-luas-permukaan': Icons.layers_rounded,
  'k6-koordinat-bidang': Icons.grid_4x4_rounded,
  'k6-pola-bilangan-kompleks': Icons.trending_up_rounded,
  'k6-persamaan-sederhana': Icons.drag_handle_rounded,
  'k6-operasi-hitung-campuran-lanjut': Icons.calculate_rounded,
  'k6-fpb-kpk-soal-cerita': Icons.auto_stories_rounded,
  'k6-peluang': Icons.casino_rounded,
  'k6-diagram-lingkaran': Icons.pie_chart_rounded,
  'k6-satuan-campuran': Icons.straighten_rounded,
  'k6-tryout-ujian-sekolah': Icons.assignment_rounded,
  'k6-review-kelas-6': Icons.emoji_events_rounded,
};

IconData _getTopicIcon(String id) =>
    _topicIcons[id] ?? Icons.school_rounded;

// ── Screen ──────────────────────────────────────────────────────────────────
class TopicSelectionScreen extends StatefulWidget {
  final int kelas;
  const TopicSelectionScreen({super.key, required this.kelas});

  @override
  State<TopicSelectionScreen> createState() => _TopicSelectionScreenState();
}

class _TopicSelectionScreenState extends State<TopicSelectionScreen>
    with TickerProviderStateMixin {
  List<TopicIndex> _topics = [];
  bool _loading = true;
  User? get user => AuthService.instance.currentUser;

  late AnimationController _pathController;
  late List<AnimationController> _nodeControllers;


  @override
  void initState() {
    super.initState();
    _pathController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _nodeControllers = [];
    _loadTopics();
  }

  @override
  void dispose() {
    _pathController.dispose();
    for (final c in _nodeControllers) { c.dispose(); }
    super.dispose();
  }

  Future<void> _loadTopics() async {
    final topics = await DataService.instance.getTopicIndex(widget.kelas);
    _nodeControllers = List.generate(
      topics.length,
      (i) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 500),
      ),
    );
    setState(() {
      _topics = topics;
      _loading = false;
    });

    // Animasi path, lalu node satu per satu
    await _pathController.forward();
    for (int i = 0; i < _nodeControllers.length; i++) {
      await Future.delayed(Duration(milliseconds: i == 0 ? 0 : 60));
      _nodeControllers[i].forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = AppConstants.warnaKelas[widget.kelas] ?? AppColors.primary;

    return Scaffold(
      extendBodyBehindAppBar: false,
      body: _loading
          ? _buildLoading(color)
          : StreamBuilder<UserProgress?>(
              stream: FirestoreService.instance.getUserProgressStream(user!.uid),
              builder: (context, snapshot) {
                return Stack(
                  children: [
                    // Background
                    const Positioned.fill(
                      child: GameBackground(child: SizedBox()),
                    ),
                    // Overlay gelap tipis biar node keliatan
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.black.withValues(alpha: 0.15),
                              Colors.black.withValues(alpha: 0.05),
                              Colors.black.withValues(alpha: 0.15),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),
                    ),
                    _buildLevelPath(snapshot.data, color),
                    // ── Custom Game Header ──
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: _buildGameHeader(context, color, snapshot.data),
                    ),
                  ],
                );
              },
            ),
    );
  }

  Widget _buildLoading(Color color) {
    return Stack(
      children: [
        const Positioned.fill(
          child: GameBackground(child: SizedBox()),
        ),
        Center(
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: color, strokeWidth: 3),
                const SizedBox(height: 12),
                Text('Memuat materi...',
                    style: TextStyle(color: color, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGameHeader(
      BuildContext context, Color color, UserProgress? progress) {
    final namaKelas = AppConstants.namaKelas[widget.kelas] ?? 'Kelas ${widget.kelas}';
    final top = MediaQuery.of(context).padding.top;

    // Hitung progress
    int selesai = 0;
    int totalBintang = 0;
    for (final t in _topics) {
      final tp = progress?.getTopikProgress(t.id, widget.kelas);
      if (tp?.lulus == true) {
        selesai++;
        final s = tp?.skor ?? 0;
        totalBintang += s >= 90 ? 3 : s >= 70 ? 2 : 1;
      }
    }
    final total = _topics.length;
    final maxBintang = total * 3;
    final progressVal = total > 0 ? selesai / total : 0.0;

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Baris atas: tombol back + judul ──
          Row(
            children: [
              // Tombol back bergaya game
              GestureDetector(
                onTap: () {
                  SoundService.instance.playClick();
                  Navigator.pop(context);
                },
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.5),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Nama kelas + subjudul
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      namaKelas,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 0.5,
                        shadows: [
                          Shadow(
                            color: Colors.black38,
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '$selesai dari $total materi selesai',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.85),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              // Badge total bintang
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.4),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.star_rounded,
                      color: Color(0xFFFFD700),
                      size: 18,
                      shadows: [
                        Shadow(color: Color(0xFFFF8C00), blurRadius: 6),
                      ],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$totalBintang/$maxBintang',
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

          const SizedBox(height: 10),

          // ── Progress bar ──
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Stack(
              children: [
                // Track
                Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                // Fill
                FractionallySizedBox(
                  widthFactor: progressVal,
                  child: Container(
                    height: 8,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.white.withValues(alpha: 0.6),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLevelPath(UserProgress? progress, Color color) {
    final topicOrder = _topics.map((t) => t.id).toList();
    final size = MediaQuery.of(context).size;
    final width = size.width;

    // Posisi X zig-zag: kiri / tengah / kanan
    final double left = width * 0.22;
    final double center = width * 0.50;
    final double right = width * 0.78;
    final xPattern = [center, right, center, left, center, right, center, left];

    const double nodeH = 150.0; // jarak vertikal antar node
    const double nodeR = 38.0;  // radius node diperkecil sedikit agar tidak overflow
    final double totalH = _topics.length * nodeH + 160;

    // Kumpulkan posisi tiap node (dari atas ke bawah = index terbalik)
    final positions = List.generate(_topics.length, (i) {
      final ri = _topics.length - 1 - i; // reversed
      return Offset(xPattern[i % xPattern.length], ri * nodeH + 100 + nodeR);
    });

    return SingleChildScrollView(
      reverse: true,
      padding: const EdgeInsets.only(
        top: 130, // tinggi custom game header
        bottom: 40,
      ),
      child: SizedBox(
        width: width,
        height: totalH,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // ── Path ──
            AnimatedBuilder(
              animation: _pathController,
              builder: (context, _) => CustomPaint(
                size: Size(width, totalH),
                painter: _GamePathPainter(
                  positions: positions,
                  color: color,
                  progress: _pathController.value,
                ),
              ),
            ),

            // ── Nodes ──
            ...List.generate(_topics.length, (i) {
              final topic = _topics[i];
              final unlocked = progress?.isTopikUnlocked(
                      topic.id, widget.kelas, topicOrder) ??
                  (i == 0);
              final tp = progress?.getTopikProgress(topic.id, widget.kelas);
              final isSelesai = tp?.lulus == true;
              final skor = tp?.skor ?? 0;
              final pos = positions[i];

              return Positioned(
                left: pos.dx - nodeR - 30,
                top: pos.dy - nodeR - 28,
                child: _buildNode(
                  index: i,
                  topic: topic,
                  unlocked: unlocked,
                  isSelesai: isSelesai,
                  skor: skor,
                  color: color,
                  nodeR: nodeR,
                  progress: progress,
                  topicOrder: topicOrder,
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildNode({
    required int index,
    required TopicIndex topic,
    required bool unlocked,
    required bool isSelesai,
    required int skor,
    required Color color,
    required double nodeR,
    required UserProgress? progress,
    required List<String> topicOrder,
  }) {
    final ctrl = index < _nodeControllers.length
        ? _nodeControllers[index]
        : AnimationController(vsync: this);

    final scaleAnim = CurvedAnimation(parent: ctrl, curve: Curves.elasticOut);

    final int stars = isSelesai
        ? (skor >= 90 ? 3 : skor >= 70 ? 2 : 1)
        : 0;

    // Warna node
    Color nodeColor;
    Color iconColor;
    if (!unlocked) {
      nodeColor = Colors.grey.shade500;
      iconColor = Colors.white60;
    } else if (isSelesai) {
      nodeColor = color;
      iconColor = Colors.white;
    } else {
      nodeColor = Colors.white;
      iconColor = color;
    }

    final double diameter = nodeR * 2;

    return ScaleTransition(
      scale: scaleAnim,
      child: GestureDetector(
        onTap: unlocked
            ? () async {
                SoundService.instance.playClick();
                final mode = await showDialog<String>(
                  context: context,
                  builder: (ctx) => _ModePickerDialog(
                    topicName: topic.topik,
                    color: color,
                    kelas: widget.kelas,
                  ),
                );
                if (mode == null || !mounted) return;
                final topicData = await DataService.instance.getTopic(topic.id);
                if (mounted) {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (_, a, _) => QuizScreen(
                        topic: topicData,
                        kelas: widget.kelas,
                        quizMode: mode,
                      ),
                      transitionsBuilder: (_, a, anim, child) => SlideTransition(
                        position: Tween(
                          begin: const Offset(1, 0),
                          end: Offset.zero,
                        ).animate(CurvedAnimation(parent: a, curve: Curves.easeOut)),
                        child: child,
                      ),
                    ),
                  );
                }
              }
            : () {
                SoundService.instance.playClick();
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: const Row(
                    children: [
                      Icon(Icons.lock_rounded, color: Colors.white, size: 18),
                      SizedBox(width: 8),
                      Text('Selesaikan materi sebelumnya dulu!'),
                    ],
                  ),
                  backgroundColor: Colors.black87,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  duration: const Duration(seconds: 2),
                  margin: const EdgeInsets.all(16),
                ));
              },
        child: SizedBox(
          width: diameter + 60,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Lingkaran node (sekarang menjadi square ala game) ──
              Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  // Main box
                  Container(
                    width: diameter,
                    height: diameter,
                    decoration: BoxDecoration(
                      color: nodeColor,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelesai ? Colors.white : const Color(0xFF1D2030), 
                        width: 4
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF1D2030),
                          offset: const Offset(0, 6),
                        ),
                        if (unlocked)
                          BoxShadow(
                            color: isSelesai ? color : Colors.white54,
                            offset: const Offset(0, 3),
                          ),
                      ],
                    ),
                    child: Center(
                      child: unlocked
                          ? (isSelesai
                              ? const Icon(Icons.star_rounded,
                                  color: Colors.white, size: 40)
                              : Icon(_getTopicIcon(topic.id),
                                  color: iconColor, size: 32))
                          : const Icon(Icons.lock_rounded,
                              color: Colors.white60, size: 28),
                    ),
                  ),
                  // Nomor urut (pojok kanan atas)
                  Positioned(
                    top: -10,
                    right: -10,
                    child: Transform.rotate(
                      angle: 0.15, // Sedikit dimiringkan (tilted) ala stiker game
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: unlocked ? const Color(0xFFFFD633) : Colors.grey.shade500,
                          borderRadius: BorderRadius.circular(8), // Bentuk rounded square
                          border: Border.all(color: const Color(0xFF1D2030), width: 2),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0xFF1D2030),
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            '${index + 1}',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w900,
                              color: unlocked ? const Color(0xFF1D2030) : Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Bintang ditaruh di bawah lingkaran (overlapping)
                  if (stars > 0)
                    Positioned(
                      bottom: -12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFFFD633), width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.3),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: _buildStars(stars),
                      ),
                    ),
                ],
              ),

              // Beri jarak ekstra karena bintang sekarang di bottom: -12
              const SizedBox(height: 16),

              // ── Label nama materi ──
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: unlocked
                      ? Colors.white.withValues(alpha: 0.92)
                      : Colors.black.withValues(alpha: 0.45),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  topic.topik,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: unlocked ? AppColors.textPrimary : Colors.white70,
                    height: 1.3,
                  ),
                ),
              ),

              // ── Skor jika selesai ──
              if (isSelesai) ...[
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Skor $skor',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStars(int count) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (i) {
        final filled = i < count;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 1),
          child: Icon(
            filled ? Icons.star_rounded : Icons.star_outline_rounded,
            size: 18,
            color: filled ? const Color(0xFFFFD700) : Colors.white38,
            shadows: filled
                ? [
                    const Shadow(
                      color: Color(0xFFFFAA00),
                      blurRadius: 6,
                    ),
                  ]
                : null,
          ),
        );
      }),
    );
  }
}

// ── Custom Painter untuk jalur ───────────────────────────────────────────────
class _GamePathPainter extends CustomPainter {
  final List<Offset> positions;
  final Color color;
  final double progress;

  _GamePathPainter({
    required this.positions,
    required this.color,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (positions.length < 2) return;

    final path = _buildPath();
    final totalLength = _pathLength(path);
    final drawn = totalLength * progress;

    // ── Layer 1: Shadow path ──
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.25)
      ..strokeWidth = 18
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    _drawPathUpTo(canvas, path, drawn + 2, shadowPaint, offset: const Offset(0, 4));

    // ── Layer 2: Main path (putih tebal) ──
    final mainPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.7)
      ..strokeWidth = 16
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    _drawPathUpTo(canvas, path, drawn, mainPaint);

    // ── Layer 3: Warna kelas (tipis di tengah) ──
    final colorPaint = Paint()
      ..color = color.withValues(alpha: 0.85)
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    _drawPathUpTo(canvas, path, drawn, colorPaint);

    // ── Layer 4: Garis putus-putus putih ──
    final dashPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.6)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    _drawDashed(canvas, path, drawn, dashPaint, dash: 10, gap: 12);
  }

  Path _buildPath() {
    final path = Path();
    path.moveTo(positions[0].dx, positions[0].dy);

    for (int i = 1; i < positions.length; i++) {
      final prev = positions[i - 1];
      final curr = positions[i];
      // Bezier halus
      final cp1 = Offset(prev.dx, (prev.dy + curr.dy) / 2);
      final cp2 = Offset(curr.dx, (prev.dy + curr.dy) / 2);
      path.cubicTo(cp1.dx, cp1.dy, cp2.dx, cp2.dy, curr.dx, curr.dy);
    }
    return path;
  }

  double _pathLength(Path path) {
    double len = 0;
    for (final m in path.computeMetrics()) {
      len += m.length;
    }
    return len;
  }

  void _drawPathUpTo(Canvas canvas, Path path, double upTo, Paint paint,
      {Offset offset = Offset.zero}) {
    double remaining = upTo;
    for (final m in path.computeMetrics()) {
      if (remaining <= 0) break;
      final extract = m.extractPath(0, math.min(remaining, m.length));
      if (offset != Offset.zero) {
        canvas.save();
        canvas.translate(offset.dx, offset.dy);
      }
      canvas.drawPath(extract, paint);
      if (offset != Offset.zero) canvas.restore();
      remaining -= m.length;
    }
  }

  void _drawDashed(Canvas canvas, Path path, double upTo, Paint paint,
      {double dash = 10, double gap = 12}) {
    double remaining = upTo;
    for (final m in path.computeMetrics()) {
      if (remaining <= 0) break;
      double pos = 0;
      final end = math.min(remaining, m.length);
      while (pos < end) {
        final d = math.min(dash, end - pos);
        canvas.drawPath(m.extractPath(pos, pos + d), paint);
        pos += dash + gap;
      }
      remaining -= m.length;
    }
  }

  @override
  bool shouldRepaint(_GamePathPainter old) =>
      old.progress != progress || old.color != color;
}

class _ModePickerDialog extends StatelessWidget {
  final String topicName;
  final Color color;
  final int kelas;

  const _ModePickerDialog({required this.topicName, required this.color, required this.kelas});

  String get _timerDesc {
    if (kelas <= 2) return '60 detik per soal';
    if (kelas <= 4) return '45 detik per soal';
    return '30 detik per soal';
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: const Color(0xFF1D2030), width: 3),
          boxShadow: const [
            BoxShadow(color: Color(0xFF1D2030), offset: Offset(0, 6)),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                topicName,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Pilih Mode',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: Color(0xFF1D2030),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Cara kamu mau main?',
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFF6B7280),
              ),
            ),
            const SizedBox(height: 20),
            _ModeButton(
              icon: Icons.sentiment_satisfied_rounded,
              label: 'Mode Biasa',
              desc: 'Santai, tidak ada batas waktu',
              color: color,
              onTap: () => Navigator.pop(context, 'biasa'),
            ),
            const SizedBox(height: 12),
            _ModeButton(
              icon: Icons.bolt_rounded,
              label: 'Mode Kilat',
              desc: '$_timerDesc, kejar waktu!',
              color: color,
              onTap: () => Navigator.pop(context, 'kilat'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ModeButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final String desc;
  final Color color;
  final VoidCallback onTap;

  const _ModeButton({
    required this.icon,
    required this.label,
    required this.desc,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        SoundService.instance.playClick();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.3), width: 2),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: color, size: 26),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF1D2030),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    desc,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, color: color, size: 16),
          ],
        ),
      ),
    );
  }
}
