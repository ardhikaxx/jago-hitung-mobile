import 'package:flutter/material.dart';
import '../models/user_progress_model.dart';
import '../services/firestore_service.dart';
import '../services/sound_service.dart';
import '../utils/constants.dart';

class DailyQuestDialog extends StatefulWidget {
  final UserProgress progress;

  const DailyQuestDialog({super.key, required this.progress});

  @override
  State<DailyQuestDialog> createState() => _DailyQuestDialogState();
}

class _DailyQuestDialogState extends State<DailyQuestDialog> {
  late UserProgress _progress;

  @override
  void initState() {
    super.initState();
    _progress = widget.progress;
    _progress.checkAndResetDailyQuests();
  }

  Future<void> _claimReward(String questKey, int coinReward) async {
    if (_progress.dailyQuests['${questKey}_claimed'] == true) return;

    setState(() {
      _progress.dailyQuests['${questKey}_claimed'] = true;
    });

    SoundService.instance.playCorrect();
    
    await FirestoreService.instance.updateKoin(_progress.uid, coinReward);
    await FirestoreService.instance.saveDailyQuests(_progress.uid, _progress.dailyQuests);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Selamat! Kamu mendapat $coinReward Koin!'),
          backgroundColor: AppColors.primary,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _claimChest() async {
    if (_progress.dailyQuests['chest_claimed'] == true) return;

    setState(() {
      _progress.dailyQuests['chest_claimed'] = true;
    });

    SoundService.instance.playCorrect();
    
    await FirestoreService.instance.updateKoin(_progress.uid, 200); // Bonus 200 coins
    await FirestoreService.instance.saveDailyQuests(_progress.uid, _progress.dailyQuests);
    
    if (mounted) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text(
            '🎁 PETI HARTA KARUN 🎁',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.monetization_on, color: Colors.amber, size: 80),
              SizedBox(height: 16),
              Text(
                'Luar Biasa! Kamu menyelesaikan semua misi hari ini!\n\n+200 Koin',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          actions: [
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondary,
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text('Tutup', style: TextStyle(color: Colors.black)),
              ),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildQuestItem(String title, String questKey, int target, int reward) {
    int current = _progress.dailyQuests['${questKey}_count'] ?? 0;
    bool isCompleted = current >= target;
    bool isClaimed = _progress.dailyQuests['${questKey}_claimed'] == true;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isClaimed ? Colors.grey.shade200 : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isClaimed ? Colors.grey.shade300 : AppColors.primary.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isClaimed ? Colors.grey.shade400 : AppColors.secondary,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.star_rounded, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isClaimed ? Colors.grey : Colors.black87,
                    decoration: isClaimed ? TextDecoration.lineThrough : null,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: (current / target).clamp(0.0, 1.0),
                          backgroundColor: Colors.grey.shade300,
                          color: AppColors.primary,
                          minHeight: 8,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${current > target ? target : current}/$target',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          if (isClaimed)
            const Icon(Icons.check_circle, color: Colors.green, size: 36)
          else if (isCompleted)
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                minimumSize: const Size(0, 36),
              ),
              onPressed: () => _claimReward(questKey, reward),
              child: const Text('Ambil', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            )
          else
            Row(
              children: [
                const Icon(Icons.monetization_on, color: Colors.amber, size: 20),
                const SizedBox(width: 4),
                Text('+$reward', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.amber)),
              ],
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool misteriClaimed = _progress.dailyQuests['misteri_claimed'] == true;
    bool comboClaimed = _progress.dailyQuests['combo_claimed'] == true;
    bool duelClaimed = _progress.dailyQuests['duel_claimed'] == true;
    bool allCompleted = misteriClaimed && comboClaimed && duelClaimed;
    bool chestClaimed = _progress.dailyQuests['chest_claimed'] == true;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.primary, width: 4),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '📋 Misi Hari Ini',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppColors.primary),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.grey),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildQuestItem('Main Kuis Misteri', 'misteri', 1, 50),
            _buildQuestItem('Jawab 10 Soal Beruntun (Combo)', 'combo', 10, 100),
            _buildQuestItem('Main Duel 1 Lawan 1', 'duel', 1, 50),
            const Divider(height: 32, thickness: 2),
            const Text(
              'Hadiah Utama',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: allCompleted && !chestClaimed ? _claimChest : null,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: chestClaimed 
                      ? Colors.grey.shade200 
                      : (allCompleted ? Colors.amber.shade200 : Colors.blue.shade50),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: chestClaimed 
                        ? Colors.grey 
                        : (allCompleted ? Colors.amber : AppColors.primary),
                    width: 2,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      chestClaimed ? Icons.lock_open : Icons.lock,
                      color: chestClaimed ? Colors.grey : (allCompleted ? Colors.amber : AppColors.primary),
                      size: 40,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Peti Harta Karun',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: chestClaimed ? Colors.grey : Colors.black87,
                            ),
                          ),
                          Text(
                            chestClaimed 
                                ? 'Sudah Diambil' 
                                : (allCompleted ? 'Ketuk untuk membuka!' : 'Selesaikan semua misi di atas'),
                            style: TextStyle(
                              color: chestClaimed ? Colors.grey : Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
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
