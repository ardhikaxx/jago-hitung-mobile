import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../models/user_progress_model.dart';
import '../utils/constants.dart';
import 'login_screen.dart';
import 'topic_selection_screen.dart';

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
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: IndexedStack(
              index: _currentIndex,
              children: [
                _KelasPage(progress: progress, user: user!),
                _ProfilPage(progress: progress, user: user!),
              ],
            ),
          ),
          bottomSheet: _buildFloatingNavBar(),
        );
      },
    );
  }

  Widget _buildFloatingNavBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
      height: 80,
      color: Colors.transparent,
      child: Container(
        height: 64,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: _buildNavItem(0, Icons.school_rounded, 'Kelas'),
            ),
            Expanded(
              child: _buildNavItem(1, Icons.person_rounded, 'Profil'),
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
        duration: const Duration(milliseconds: 250),
        margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(28),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 22,
              color: isSelected ? Colors.white : AppColors.textSecondary,
            ),
            if (isSelected) ...[
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
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
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: AppColors.primary,
                      child: Text(
                        nama.isNotEmpty ? nama[0].toUpperCase() : 'S',
                        style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Halo, $nama!',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const Text(
                            'Pilih kelas untuk belajar',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const Text(
                  'Pilih Kelas',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Selesaikan materi untuk membuka kelas berikutnya',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 16),
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
        const SliverToBoxAdapter(child: SizedBox(height: 20)),
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
    final double progressValue =
        totalTopics > 0 ? completedCount / totalTopics : 0;

    return GestureDetector(
      onTap: unlocked
          ? () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => TopicSelectionScreen(kelas: kelas),
                ),
              );
            }
          : null,
      child: Container(
        decoration: BoxDecoration(
          gradient: unlocked
              ? LinearGradient(
                  colors: [
                    color,
                    color.withValues(alpha: 0.75),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: unlocked ? null : AppColors.locked,
          borderRadius: BorderRadius.circular(20),
          boxShadow: unlocked
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.45),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  )
                ]
              : [],
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Baris atas: label kiri, icon kanan ──
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      'Kelas $kelas',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.white.withValues(alpha: 0.85),
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(9),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      unlocked ? Icons.school_rounded : Icons.lock_rounded,
                      size: 28,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),

              const Spacer(),

              // ── Nama kelas besar ──
              Text(
                namaKelas,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  height: 1.2,
                ),
              ),

              const SizedBox(height: 6),

              // ── Keterangan progress ──
              if (unlocked) ...[
                Text(
                  '$completedCount/$totalTopics Materi',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                ),
                const SizedBox(height: 6),
                // ── Progress bar ──
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: progressValue,
                    backgroundColor: Colors.white.withValues(alpha: 0.3),
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(Colors.white),
                    minHeight: 6,
                  ),
                ),
              ] else ...[
                Text(
                  'Selesaikan kelas\nsebelumnya dulu',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.white.withValues(alpha: 0.75),
                    height: 1.4,
                  ),
                ),
              ],
            ],
          ),
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
          const SizedBox(height: 20),
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
