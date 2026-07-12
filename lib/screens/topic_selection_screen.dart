import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../services/data_service.dart';
import '../services/firestore_service.dart';
import '../models/topic_model.dart';
import '../models/user_progress_model.dart';
import '../utils/constants.dart';
import 'quiz_screen.dart';

class TopicSelectionScreen extends StatefulWidget {
  final int kelas;
  const TopicSelectionScreen({super.key, required this.kelas});

  @override
  State<TopicSelectionScreen> createState() => _TopicSelectionScreenState();
}

class _TopicSelectionScreenState extends State<TopicSelectionScreen> {
  List<TopicIndex> _topics = [];
  bool _loading = true;
  User? get user => AuthService.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _loadTopics();
  }

  Future<void> _loadTopics() async {
    final topics = await DataService.instance.getTopicIndex(widget.kelas);
    setState(() {
      _topics = topics;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final color = AppConstants.warnaKelas[widget.kelas] ?? AppColors.primary;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: color,
        foregroundColor: Colors.white,
        title: Text(AppConstants.namaKelas[widget.kelas] ?? ''),
        elevation: 0,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : StreamBuilder<UserProgress?>(
              stream: FirestoreService.instance
                  .getUserProgressStream(user!.uid),
              builder: (context, snapshot) {
                final progress = snapshot.data;
                return _buildTopicList(progress);
              },
            ),
    );
  }

  Widget _buildTopicList(UserProgress? progress) {
    final topicOrder =
        _topics.map((t) => t.id).toList();
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _topics.length,
      itemBuilder: (context, index) {
        final topic = _topics[index];
        final unlocked = progress?.isTopikUnlocked(
                topic.id, widget.kelas, topicOrder) ??
            (index == 0);
        final topicProgress =
            progress?.getTopikProgress(topic.id, widget.kelas);
        return _buildTopicCard(topic, unlocked, topicProgress, index);
      },
    );
  }

  Widget _buildTopicCard(
      TopicIndex topic, bool unlocked, TopicProgress? tp, int index) {
    final color = AppConstants.warnaKelas[widget.kelas] ?? AppColors.primary;
    final isSelesai = tp?.lulus == true;
    final skor = tp?.skor ?? 0;

    return GestureDetector(
      onTap: unlocked
          ? () async {
              final topicData =
                  await DataService.instance.getTopic(topic.id);
              if (mounted) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => QuizScreen(
                      topic: topicData,
                      kelas: widget.kelas,
                    ),
                  ),
                );
              }
            }
          : null,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: unlocked
                    ? (isSelesai ? AppColors.success : color)
                    : AppColors.locked,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: unlocked
                    ? (isSelesai
                        ? const Icon(Icons.check, color: Colors.white, size: 24)
                        : Text(
                            topic.icon,
                            style: const TextStyle(fontSize: 22),
                          ))
                    : const Icon(Icons.lock, color: Colors.white, size: 20),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    topic.topik,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: unlocked
                          ? AppColors.textPrimary
                          : AppColors.locked,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    unlocked
                        ? '${topic.jumlahSoal} soal${isSelesai ? ' • Skor: $skor' : ''}'
                        : 'Selesaikan materi sebelumnya',
                    style: TextStyle(
                      fontSize: 12,
                      color: unlocked
                          ? AppColors.textSecondary
                          : AppColors.locked,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelesai)
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$skor',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.success,
                  ),
                ),
              )
            else if (unlocked)
              Icon(Icons.arrow_forward_ios,
                  size: 16, color: color)
            else
              const Icon(Icons.lock_outline,
                  size: 16, color: AppColors.locked),
          ],
        ),
      ),
    );
  }
}
