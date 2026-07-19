import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../services/sound_service.dart';

class DailyStreakDialog extends StatelessWidget {
  final int streakDay;
  final VoidCallback onClaim;

  const DailyStreakDialog({
    super.key,
    required this.streakDay,
    required this.onClaim,
  });

  int _getReward() {
    switch (streakDay) {
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
    int reward = _getReward();
    bool isSpecial = streakDay == 7;

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
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.local_fire_department_rounded, color: Colors.orange, size: 36),
                const SizedBox(width: 8),
                Text(
                  'Hari ke-$streakDay',
                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Colors.orange),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.local_fire_department_rounded, color: Colors.orange, size: 36),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              isSpecial ? 'HADIAH MISTERI 7 HARI!' : 'Bonus Login Harian',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isSpecial ? Colors.purple : Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isSpecial ? Colors.purple.shade50 : Colors.amber.shade50,
                shape: BoxShape.circle,
                border: Border.all(color: isSpecial ? Colors.purple : Colors.amber, width: 3),
              ),
              child: Icon(
                isSpecial ? Icons.redeem_rounded : Icons.monetization_on_rounded,
                size: 80,
                color: isSpecial ? Colors.purple : Colors.amber,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              '+$reward Koin',
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w900,
                color: Colors.amber,
                shadows: [Shadow(color: Colors.black26, offset: Offset(0, 2), blurRadius: 4)],
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Jangan lupa login besok untuk hadiah yang lebih besar!',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                  elevation: 4,
                ),
                onPressed: () {
                  SoundService.instance.playClick();
                  onClaim();
                },
                child: const Text(
                  'Ambil Hadiah',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
