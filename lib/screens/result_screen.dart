import 'package:flutter/material.dart';
import '../models/question_model.dart';
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
  final List<Question>? questions;
  final List<String>? userAnswers;

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
    this.questions,
    this.userAnswers,
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
                const SizedBox(height: 24),
                _buildReviewSection(context, color),
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

  Widget _buildReviewSection(BuildContext context, Color color) {
    if (questions == null || userAnswers == null) return const SizedBox.shrink();

    final salahIndices = <int>[];
    for (int i = 0; i < results.length; i++) {
      if (!results[i]) salahIndices.add(i);
    }

    if (salahIndices.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.success.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.auto_awesome, color: AppColors.success, size: 22),
            SizedBox(width: 10),
            Text(
              'Semua jawaban benar! Luar biasa! 🎉',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.success,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
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
      child: ExpansionTile(
        initiallyExpanded: true,
        tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        shape: Border.all(color: Colors.transparent),
        collapsedShape: Border.all(color: Colors.transparent),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.danger.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.refresh_rounded, color: AppColors.danger, size: 20),
        ),
        title: Text(
          'Review Jawaban Salah (${salahIndices.length})',
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        children: salahIndices.map((i) {
          final q = questions![i];
          final userAns = userAnswers![i];
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.danger.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.danger.withValues(alpha: 0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.danger,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Soal ${i + 1}',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const Spacer(),
                    const Icon(Icons.close_rounded, color: AppColors.danger, size: 18),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  q.pertanyaan,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.person_rounded, size: 14, color: AppColors.danger),
                    const SizedBox(width: 4),
                    Text(
                      'Jawabanmu: $userAns',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.danger,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.check_circle_rounded, size: 14, color: AppColors.success),
                    const SizedBox(width: 4),
                    Text(
                      'Jawaban benar: ${q.jawaban}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.success,
                      ),
                    ),
                  ],
                ),
                if (q.penjelasan.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      q.penjelasan,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary.withValues(alpha: 0.8),
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
