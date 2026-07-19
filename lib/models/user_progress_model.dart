class UserProgress {
  final String uid;
  final String nama;
  final String email;
  final String profileImage;
  final int kelasAktif;
  final Map<String, TopicProgress> topikProgress;
  final DateTime createdAt;
  final List<String> achievements;
  final int koin;
  final List<String> purchasedAvatars;
  final Map<String, dynamic> dailyQuests;

  UserProgress({
    required this.uid,
    required this.nama,
    required this.email,
    this.profileImage = '',
    this.kelasAktif = 1,
    Map<String, TopicProgress>? topikProgress,
    DateTime? createdAt,
    List<String>? achievements,
    this.koin = 0,
    List<String>? purchasedAvatars,
    Map<String, dynamic>? dailyQuests,
  })  : topikProgress = topikProgress ?? {},
        createdAt = createdAt ?? DateTime.now(),
        achievements = achievements ?? [],
        purchasedAvatars = purchasedAvatars ?? [],
        dailyQuests = dailyQuests ?? {};

  int get totalKoin {
    int total = 0;
    for (var p in topikProgress.values) {
      total += p.skor ~/ 10;
    }
    return total;
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'nama': nama,
      'email': email,
      'profileImage': profileImage,
      'kelasAktif': kelasAktif,
      'topikProgress': topikProgress.map((key, value) => MapEntry(key, value.toMap())),
      'createdAt': createdAt.toIso8601String(),
      'achievements': achievements,
      'koin': koin,
      'purchasedAvatars': purchasedAvatars,
      'dailyQuests': dailyQuests,
    };
  }

  factory UserProgress.fromMap(Map<String, dynamic> map) {
    DateTime parsedCreatedAt = DateTime.now();
    if (map['createdAt'] != null) {
      final raw = map['createdAt'];
      if (raw is DateTime) {
        parsedCreatedAt = raw;
      } else if (raw is String) {
        parsedCreatedAt = DateTime.tryParse(raw) ?? DateTime.now();
      } else {
        try {
          parsedCreatedAt = raw.toDate();
        } catch (_) {
          parsedCreatedAt = DateTime.now();
        }
      }
    }

    final rawTopik = map['topikProgress'];
    Map<String, TopicProgress> parsedTopik = {};
    if (rawTopik is Map) {
      rawTopik.forEach((key, value) {
        if (value is Map) {
          try {
            parsedTopik[key.toString()] = TopicProgress.fromMap(Map<String, dynamic>.from(value));
          } catch (e) {
            print('Error parsing topic progress: $e');
          }
        }
      });
    }

    final rawKoin = map['koin'];
    int initialKoin = 0;
    if (rawKoin is int) {
      initialKoin = rawKoin;
    }

    return UserProgress(
      uid: map['uid'] ?? '',
      nama: map['nama'] ?? '',
      email: map['email'] ?? '',
      profileImage: map['profileImage'] ?? '',
      kelasAktif: map['kelasAktif'] ?? 1,
      topikProgress: parsedTopik,
      createdAt: parsedCreatedAt,
      achievements: map['achievements'] != null
          ? List<String>.from(map['achievements'])
          : [],
      koin: initialKoin,
      purchasedAvatars: map['purchasedAvatars'] != null
          ? List<String>.from(map['purchasedAvatars'])
          : [],
      dailyQuests: map['dailyQuests'] != null
          ? Map<String, dynamic>.from(map['dailyQuests'])
          : {},
    );
  }

  bool isTopikUnlocked(String topikId, int kelas, List<String> topikOrder) {
    if (topikId == topikOrder.first) return true;

    final idx = topikOrder.indexOf(topikId);
    if (idx <= 0) return true;

    final prevTopikId = topikOrder[idx - 1];
    final prevProgress = topikProgress['$kelas-$prevTopikId'];
    if (prevProgress == null) return false;

    return prevProgress.lulus;
  }

  TopicProgress? getTopikProgress(String topikId, int kelas) {
    return topikProgress['$kelas-$topikId'];
  }

  int get totalXP {
    int total = 0;
    for (var progress in topikProgress.values) {
      total += progress.skor;
    }
    return total;
  }

  int get currentLevel {
    return (totalXP ~/ 500) + 1;
  }

  void checkAndResetDailyQuests() {
    final today = "${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().day.toString().padLeft(2, '0')}";
    if (dailyQuests['date'] != today) {
      dailyQuests.clear();
      dailyQuests['date'] = today;
      dailyQuests['misteri_count'] = 0;
      dailyQuests['combo_count'] = 0;
      dailyQuests['duel_count'] = 0;
      dailyQuests['misteri_claimed'] = false;
      dailyQuests['combo_claimed'] = false;
      dailyQuests['duel_claimed'] = false;
      dailyQuests['chest_claimed'] = false;
    }
  }

  void updateQuestProgress(String questKey, int amount) {
    checkAndResetDailyQuests();
    int current = dailyQuests[questKey] ?? 0;
    dailyQuests[questKey] = current + amount;
  }
}

class TopicProgress {
  final String topikId;
  final int skor;
  final int jumlahBenar;
  final int jumlahSoal;
  final bool lulus;
  final DateTime? lastAttempt;

  TopicProgress({
    required this.topikId,
    required this.skor,
    required this.jumlahBenar,
    required this.jumlahSoal,
    required this.lulus,
    this.lastAttempt,
  });

  Map<String, dynamic> toMap() {
    return {
      'topikId': topikId,
      'skor': skor,
      'jumlahBenar': jumlahBenar,
      'jumlahSoal': jumlahSoal,
      'lulus': lulus,
      'lastAttempt': lastAttempt?.toIso8601String(),
    };
  }

  factory TopicProgress.fromMap(Map<String, dynamic> map) {
    DateTime? parsedLastAttempt;
    if (map['lastAttempt'] != null) {
      final raw = map['lastAttempt'];
      if (raw is DateTime) {
        parsedLastAttempt = raw;
      } else if (raw is String) {
        parsedLastAttempt = DateTime.tryParse(raw);
      } else {
        try {
          parsedLastAttempt = raw.toDate();
        } catch (_) {
          parsedLastAttempt = null;
        }
      }
    }

    return TopicProgress(
      topikId: map['topikId'] ?? '',
      skor: map['skor'] ?? 0,
      jumlahBenar: map['jumlahBenar'] ?? 0,
      jumlahSoal: map['jumlahSoal'] ?? 5,
      lulus: map['lulus'] ?? false,
      lastAttempt: parsedLastAttempt,
    );
  }
}
