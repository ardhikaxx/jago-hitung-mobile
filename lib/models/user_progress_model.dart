class UserProgress {
  final String uid;
  final String nama;
  final String email;
  final String profileImage;
  final int kelasAktif;
  final Map<String, TopicProgress> topikProgress;
  final DateTime createdAt;

  UserProgress({
    required this.uid,
    required this.nama,
    required this.email,
    this.profileImage = '',
    this.kelasAktif = 1,
    Map<String, TopicProgress>? topikProgress,
    DateTime? createdAt,
  })  : topikProgress = topikProgress ?? {},
        createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'nama': nama,
      'email': email,
      'profileImage': profileImage,
      'kelasAktif': kelasAktif,
      'topikProgress': topikProgress.map((key, value) => MapEntry(key, value.toMap())),
      'createdAt': createdAt.toIso8601String(),
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
        if (value is Map<String, dynamic>) {
          parsedTopik[key] = TopicProgress.fromMap(value);
        }
      });
    }

    return UserProgress(
      uid: map['uid'] ?? '',
      nama: map['nama'] ?? '',
      email: map['email'] ?? '',
      profileImage: map['profileImage'] ?? '',
      kelasAktif: map['kelasAktif'] ?? 1,
      topikProgress: parsedTopik,
      createdAt: parsedCreatedAt,
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
