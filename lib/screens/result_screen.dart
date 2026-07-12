import 'package:flutter/material.dart';
import '../services/data_service.dart';
import '../utils/constants.dart';
import 'home_screen.dart';
import 'quiz_screen.dart';

class ResultScreen extends StatelessWidget {
  final String topicName;
  final String topikId;
  final int kelas;
  final int skor;
  final int benar;
  final int jumlahSoal;
  final bool lulus;
  final List<bool> results;

  const ResultScreen({
    super.key,
    required this.topicName,
    required this.topikId,
    required this.kelas,
    required this.skor,
    required this.benar,
    required this.jumlahSoal,
    required this.lulus,
    required this.results,
  });

  String? _getNextTopicId() {
    final topicOrder = AppConstants.getTopicOrder(kelas);
    final idx = topicOrder.indexOf(topikId);
    if (idx < 0 || idx >= topicOrder.length - 1) return null;
    return topicOrder[idx + 1];
  }

  @override
  Widget build(BuildContext context) {
    final color = AppConstants.warnaKelas[kelas] ?? AppColors.primary;
    final nextTopicId = _getNextTopicId();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(30),
                  decoration: BoxDecoration(
                    color: lulus
                        ? AppColors.success.withValues(alpha: 0.1)
                        : AppColors.danger.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    lulus
                        ? Icons.emoji_events_rounded
                        : Icons.replay_rounded,
                    size: 80,
                    color: lulus ? AppColors.success : AppColors.warning,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  lulus ? 'Selamat!' : 'Hampir Bisa!',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  topicName,
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(24),
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
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 120,
                            height: 120,
                            child: CircularProgressIndicator(
                              value: skor / 100,
                              strokeWidth: 10,
                              backgroundColor:
                                  AppColors.locked.withValues(alpha: 0.2),
                              valueColor: AlwaysStoppedAnimation<Color>(
                                lulus ? AppColors.success : AppColors.warning,
                              ),
                            ),
                          ),
                          Column(
                            children: [
                              Text(
                                '$skor',
                                style: TextStyle(
                                  fontSize: 36,
                                  fontWeight: FontWeight.bold,
                                  color: lulus
                                      ? AppColors.success
                                      : AppColors.warning,
                                ),
                              ),
                              const Text(
                                'Skor',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildStat(
                            Icons.check_circle,
                            '$benar',
                            'Benar',
                            AppColors.success,
                          ),
                          _buildStat(
                            Icons.cancel,
                            '${jumlahSoal - benar}',
                            'Salah',
                            AppColors.danger,
                          ),
                          _buildStat(
                            Icons.quiz,
                            '$jumlahSoal',
                            'Total',
                            AppColors.primary,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        alignment: WrapAlignment.center,
                        children: results.map((r) {
                          return Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: r
                                  ? AppColors.success
                                  : AppColors.danger,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              r ? Icons.check : Icons.close,
                              size: 16,
                              color: Colors.white,
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                if (lulus)
                  Text(
                    'Kamu berhasil membuka materi berikutnya!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  )
                else
                  Text(
                    'Nilai minimal lulus: ${AppConstants.skorLulusMinimum}',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                const SizedBox(height: 32),
                if (!lulus)
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.replay),
                      label: const Text('Ulangi Materi',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.warning,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                if (!lulus) const SizedBox(height: 12),
                if (lulus && nextTopicId != null)
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        final nextTopic =
                            await DataService.instance.getTopic(nextTopicId);
                        if (context.mounted) {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => QuizScreen(
                                topic: nextTopic,
                                kelas: kelas,
                              ),
                            ),
                          );
                        }
                      },
                      icon: const Icon(Icons.arrow_forward),
                      label: const Text('Materi Selanjutnya',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: color,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                if (lulus && nextTopicId != null) const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const HomeScreen()),
                        (route) => false,
                      );
                    },
                    icon: const Icon(Icons.home),
                    label: const Text('Kembali ke Beranda',
                        style: TextStyle(fontSize: 16)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: color,
                      side: BorderSide(color: color),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
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

  Widget _buildStat(
      IconData icon, String value, String label, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
