class Question {
  final String id;
  final String tipe;
  final String pertanyaan;
  final String ilustrasi;
  final List<String>? pilihan;
  final String jawaban;
  final List<String> petunjuk;
  final String penjelasan;

  Question({
    required this.id,
    required this.tipe,
    required this.pertanyaan,
    required this.ilustrasi,
    this.pilihan,
    required this.jawaban,
    required this.petunjuk,
    required this.penjelasan,
  });

  bool get isMultipleChoice => tipe == 'multiple_choice';
  bool get isFillIn => tipe == 'fill_in';

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'] ?? '',
      tipe: json['tipe'] ?? 'multiple_choice',
      pertanyaan: json['pertanyaan'] ?? '',
      ilustrasi: json['ilustrasi'] ?? '',
      pilihan: json['pilihan'] != null
          ? List<String>.from(json['pilihan'])
          : null,
      jawaban: json['jawaban'] ?? '',
      petunjuk: List<String>.from(json['petunjuk'] ?? []),
      penjelasan: json['penjelasan'] ?? '',
    );
  }
}
