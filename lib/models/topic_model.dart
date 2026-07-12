import 'question_model.dart';

class Topic {
  final String id;
  final int kelas;
  final String topik;
  final String deskripsi;
  final int jumlahSoal;
  final String icon;
  final List<Question> soal;

  Topic({
    required this.id,
    required this.kelas,
    required this.topik,
    required this.deskripsi,
    required this.jumlahSoal,
    required this.icon,
    required this.soal,
  });

  factory Topic.fromJson(Map<String, dynamic> json) {
    return Topic(
      id: json['id'] ?? '',
      kelas: json['kelas'] ?? 1,
      topik: json['topik'] ?? '',
      deskripsi: json['deskripsi'] ?? '',
      jumlahSoal: json['jumlahSoal'] ?? 5,
      icon: json['icon'] ?? '📚',
      soal: (json['soal'] as List<dynamic>?)
              ?.map((s) => Question.fromJson(s))
              .toList() ??
          [],
    );
  }
}

class TopicIndex {
  final String id;
  final String topik;
  final String deskripsi;
  final int jumlahSoal;
  final String icon;

  TopicIndex({
    required this.id,
    required this.topik,
    required this.deskripsi,
    required this.jumlahSoal,
    required this.icon,
  });

  factory TopicIndex.fromJson(Map<String, dynamic> json) {
    return TopicIndex(
      id: json['id'] ?? '',
      topik: json['topik'] ?? '',
      deskripsi: json['deskripsi'] ?? '',
      jumlahSoal: json['jumlahSoal'] ?? 5,
      icon: json['icon'] ?? '📚',
    );
  }
}
