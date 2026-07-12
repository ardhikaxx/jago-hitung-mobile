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
  User? get user => AuthService.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return const LoginScreen();
    }
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: StreamBuilder<UserProgress?>(
          stream: FirestoreService.instance.getUserProgressStream(user!.uid),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            final progress = snapshot.data;
            return _buildContent(progress);
          },
        ),
      ),
    );
  }

  Widget _buildContent(UserProgress? progress) {
    final nama = progress?.nama ?? user!.displayName ?? 'Siswa';
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
                    IconButton(
                      onPressed: () async {
                        await AuthService.instance.signOut();
                        if (mounted) {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const LoginScreen()),
                          );
                        }
                      },
                      icon: const Icon(Icons.logout,
                          color: AppColors.textSecondary),
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
                return _buildKelasCard(kelas, unlocked, progress);
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

  Widget _buildKelasCard(int kelas, bool unlocked, UserProgress? progress) {
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
          color: unlocked ? color : AppColors.locked,
          borderRadius: BorderRadius.circular(16),
          boxShadow: unlocked
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  )
                ]
              : [],
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      unlocked
                          ? Icons.school_rounded
                          : Icons.lock_rounded,
                      size: 40,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      namaKelas,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    if (unlocked) ...[
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: totalTopics > 0
                              ? completedCount / totalTopics
                              : 0,
                          backgroundColor: Colors.white.withValues(alpha: 0.3),
                          valueColor:
                              const AlwaysStoppedAnimation<Color>(Colors.white),
                          minHeight: 6,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$completedCount/$totalTopics materi',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
