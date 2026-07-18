import '../models/achievement_model.dart';
import '../models/user_progress_model.dart';
import '../utils/constants.dart';
import 'firestore_service.dart';

class AchievementService {
  static final AchievementService instance = AchievementService._();
  AchievementService._();

  List<Achievement> evaluateAchievements(UserProgress progress) {
    final achievements = Achievement.all;

    int totalCompleted = 0;
    int perfectCount = 0;
    int totalStars = 0;
    final Set<int> completedClasses = {};
    final Set<int> allStarClasses = {};
    final Set<int> unlockedClasses = {1};

    for (int k = 1; k <= 6; k++) {
      final topics = AppConstants.getTopicOrder(k);
      bool allCompleted = true;
      bool allThreeStars = true;

      for (final t in topics) {
        final tp = progress.getTopikProgress(t, k);
        if (tp != null && tp.lulus) {
          totalCompleted++;
          if (tp.skor == 100) perfectCount++;
          final stars = tp.skor >= 90 ? 3 : (tp.skor >= 70 ? 2 : 1);
          totalStars += stars;
        } else {
          allCompleted = false;
          allThreeStars = false;
        }
      }

      if (allCompleted) completedClasses.add(k);
      if (allThreeStars) allStarClasses.add(k);
      if (k > 1) {
        final prevReview = AppConstants.getTopicOrder(k - 1).last;
        final prevProgress = progress.getTopikProgress(prevReview, k - 1);
        if (prevProgress?.lulus == true) unlockedClasses.add(k);
      }
    }

    final checkConditions = {
      'first_topic': totalCompleted >= 1,
      'ten_topics': totalCompleted >= 10,
      'collector': completedClasses.isNotEmpty,
      'perfect_five': perfectCount >= 5,
      'all_stars': allStarClasses.isNotEmpty,
      'fifty_stars': totalStars >= 50,
      'explorer': unlockedClasses.length >= 6,
      'twenty_five': totalCompleted >= 25,
    };

    for (final a in achievements) {
      a.unlocked = checkConditions[a.id] == true;
    }

    return achievements;
  }

  Future<void> syncAchievements(UserProgress progress, String uid) async {
    final achievements = evaluateAchievements(progress);
    final unlockedIds = achievements
        .where((a) => a.unlocked)
        .map((a) => a.id)
        .toList();

    final firestore = FirestoreService.instance;
    await firestore.updateAchievements(uid, unlockedIds);
  }
}
