import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_progress_model.dart';

class FirestoreService {
  static final FirestoreService instance = FirestoreService._();
  FirestoreService._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  DocumentReference _userDoc(String uid) =>
      _firestore.collection('users').doc(uid);

  Future<UserProgress?> getUserProgress(String uid) async {
    final doc = await _userDoc(uid).get();
    if (!doc.exists) return null;
    return UserProgress.fromMap(doc.data() as Map<String, dynamic>);
  }

  Stream<UserProgress?> getUserProgressStream(String uid) {
    return _userDoc(uid).snapshots().map((doc) {
      if (!doc.exists) return null;
      return UserProgress.fromMap(doc.data() as Map<String, dynamic>);
    });
  }

  Future<void> saveTopikProgress(
      String uid, int kelas, String topikId, TopicProgress progress, {int? coinReward}) async {
    final key = '$kelas-$topikId';
    final finalCoinReward = coinReward ?? (progress.skor ~/ 10);
    await _userDoc(uid).update({
      'topikProgress.$key': progress.toMap(),
      'koin': FieldValue.increment(finalCoinReward),
    });
  }

  Future<void> updateKelasAktif(String uid, int kelas) async {
    await _userDoc(uid).update({'kelasAktif': kelas});
  }

  Future<void> saveDailyQuests(String uid, Map<String, dynamic> dailyQuests) async {
    await _userDoc(uid).update({'dailyQuests': dailyQuests});
  }

  Future<void> initUserProgress(String uid, String nama, String email) async {
    final doc = await _userDoc(uid).get();
    if (!doc.exists) {
      await _userDoc(uid).set({
        'uid': uid,
        'nama': nama,
        'email': email,
        'profileImage': '',
        'kelasAktif': 1,
        'topikProgress': {},
        'achievements': [],
        'koin': 0,
        'purchasedAvatars': [],
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }

  Future<void> updateProfileImage(String uid, String imagePath) async {
    await _userDoc(uid).update({'profileImage': imagePath});
  }

  Future<void> updateAchievements(String uid, List<String> achievementIds) async {
    await _userDoc(uid).update({'achievements': achievementIds});
  }

  Future<void> buyAvatar(String uid, String avatarPath, int price) async {
    await _userDoc(uid).update({
      'koin': FieldValue.increment(-price),
      'purchasedAvatars': FieldValue.arrayUnion([avatarPath]),
    });
  }

  Future<void> updateKoin(String uid, int amount) async {
    await _userDoc(uid).update({
      'koin': FieldValue.increment(amount),
    });
  }

  Future<List<UserProgress>> getLeaderboard() async {
    try {
      final snapshot = await _firestore.collection('users').get();
      final users = snapshot.docs.map((doc) => UserProgress.fromMap(doc.data())).toList();
      users.sort((a, b) => b.totalXP.compareTo(a.totalXP));
      return users.take(50).toList();
    } catch (e) {
      print('Error getting leaderboard: $e');
      return [];
    }
  }
}
