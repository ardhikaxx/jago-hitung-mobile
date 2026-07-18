import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../models/user_progress_model.dart';
import '../utils/constants.dart';
import 'login_screen.dart';
import 'topic_selection_screen.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  User? get user => AuthService.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    if (user == null) return const LoginScreen();

    return StreamBuilder<UserProgress?>(
      stream: FirestoreService.instance.getUserProgressStream(user!.uid),
      builder: (context, snapshot) {
        final progress = snapshot.data;
        return Scaffold(
          extendBodyBehindAppBar: true,
          backgroundColor: AppColors.background,
          body: Stack(
            children: [
              Positioned.fill(
                child: Image.asset(
                  'assets/images/bg_home.jpg',
                  fit: BoxFit.cover,
                ),
              ),
              Positioned.fill(
                child: Container(
                  color: Colors.black.withValues(alpha: 0.3),
                ),
              ),
              SafeArea(
                child: IndexedStack(
                  index: _currentIndex,
                  children: [
                    _KelasPage(progress: progress, user: user!),
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
              child: _buildNavItem(1, Icons.face_retouching_natural_rounded, 'Profil'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: EdgeInsets.fromLTRB(6, isSelected ? 2 : 6, 6, isSelected ? 10 : 6),
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

  const _KelasPage({required this.progress, required this.user});

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
                    color: Colors.black.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 2),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 8, offset: const Offset(0, 4)),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
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
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('PEMAIN', style: TextStyle(fontSize: 10, color: Colors.white70, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                          Text(nama, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.white)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Stack(
                  children: [
                    Text(
                      'PILIH LEVEL',
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
                      'PILIH LEVEL',
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
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.95),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
        children: [
          const SizedBox(height: 20),
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
          const SizedBox(height: 8),
          Text(
            'Tap untuk ubah foto profil',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
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
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(20),
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
              children: [
                _buildProfileStat(
                  Icons.book_rounded,
                  '$totalSelesai',
                  'Materi Dikerjakan',
                  AppColors.primary,
                ),
                const Divider(height: 32),
                _buildProfileStat(
                  Icons.check_circle_rounded,
                  '$totalSoal',
                  'Total Soal Dijawab',
                  AppColors.success,
                ),
                const Divider(height: 32),
                _buildProfileStat(
                  Icons.school_rounded,
                  'Kelas $kelasAktif',
                  'Kelas Aktif',
                  AppColors.secondary,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: OutlinedButton.icon(
              onPressed: () async {
                await AuthService.instance.signOut();
                if (context.mounted) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  );
                }
              },
              icon: const Icon(Icons.logout, color: AppColors.danger),
              label: const Text(
                'Keluar',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.danger),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.danger),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 100),
        ],
      ),
    ));
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
                    itemCount: AuthService.profileImages.length,
                    itemBuilder: (context, index) {
                      final imgPath = AuthService.profileImages[index];
                      final currentImage = progress?.profileImage ?? '';
                      final isSelected = imgPath == currentImage;
                      return GestureDetector(
                        onTap: () async {
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

class Game3DButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final Color color;
  final Color shadowColor;

  const Game3DButton({
    super.key,
    required this.child,
    this.onPressed,
    required this.color,
    required this.shadowColor,
  });

  @override
  State<Game3DButton> createState() => _Game3DButtonState();
}

class _Game3DButtonState extends State<Game3DButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        if (widget.onPressed != null) setState(() => _isPressed = true);
      },
      onTapUp: (_) {
        if (widget.onPressed != null) {
          setState(() => _isPressed = false);
          widget.onPressed!();
        }
      },
      onTapCancel: () {
        if (widget.onPressed != null) setState(() => _isPressed = false);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        margin: EdgeInsets.only(top: _isPressed ? 6 : 0, bottom: _isPressed ? 0 : 6),
        decoration: BoxDecoration(
          color: widget.color,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withValues(alpha: 0.8), width: 3),
          boxShadow: [
            BoxShadow(
              color: widget.shadowColor,
              offset: Offset(0, _isPressed ? 0 : 8),
            ),
            if (!_isPressed)
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                offset: const Offset(0, 12),
                blurRadius: 10,
              ),
          ],
        ),
        child: widget.child,
      ),
    );
  }
}
