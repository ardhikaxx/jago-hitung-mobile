import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF6C63FF);
  static const Color primaryDark = Color(0xFF4A42D4);
  static const Color secondary = Color(0xFFFF6584);
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFC107);
  static const Color danger = Color(0xFFF44336);
  static const Color background = Color(0xFFF5F7FF);
  static const Color cardBg = Colors.white;
  static const Color textPrimary = Color(0xFF2D3142);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color locked = Color(0xFFBDBDBD);
}

class AppConstants {
  static const int skorLulusMinimum = 60;
  static const int jumlahSoalPerTopik = 5;
  static const Map<int, String> namaKelas = {
    1: 'Kelas 1',
    2: 'Kelas 2',
    3: 'Kelas 3',
    4: 'Kelas 4',
    5: 'Kelas 5',
    6: 'Kelas 6',
  };
  static const Map<int, Color> warnaKelas = {
    1: Color(0xFF4FC3F7),
    2: Color(0xFF81C784),
    3: Color(0xFFFFB74D),
    4: Color(0xFFE57373),
    5: Color(0xFFBA68C8),
    6: Color(0xFF4DD0E1),
  };

  static const List<String> kelas1Topics = [
    'k1-mengenal-angka',
    'k1-penjumlahan-dasar',
    'k1-penjumlahan-pengurangan',
    'k1-bangun-datar',
    'k1-mengurutkan-angka',
    'k1-membandingkan-bilangan',
    'k1-menghitung-benda',
    'k1-pasangan-bilangan',
    'k1-pengurangan-dasar',
    'k1-cerita-penjumlahan',
    'k1-cerita-pengurangan',
    'k1-bilangan-loncat-2',
    'k1-bilangan-loncat-5',
    'k1-puluhan-satuan',
    'k1-nilai-tempat',
    'k1-pola-bentuk',
    'k1-pengukuran-panjang-nonbaku',
    'k1-membaca-jam-tepat',
    'k1-uang-koin',
    'k1-review-kelas-1',
  ];

  static List<String> getTopicOrder(int kelas) {
    switch (kelas) {
      case 1:
        return kelas1Topics;
      case 2:
        return _kelas2Topics;
      case 3:
        return _kelas3Topics;
      case 4:
        return _kelas4Topics;
      case 5:
        return _kelas5Topics;
      case 6:
        return _kelas6Topics;
      default:
        return kelas1Topics;
    }
  }

  static const List<String> _kelas2Topics = [
    'k2-penjumlahan-pengurangan-bersusun',
    'k2-mengenal-perkalian',
    'k2-bilangan-sampai-100',
    'k2-nilai-tempat-ratusan',
    'k2-membandingkan-bilangan',
    'k2-penjumlahan-tanpa-menyimpan',
    'k2-penjumlahan-dengan-menyimpan',
    'k2-pengurangan-tanpa-meminjam',
    'k2-pengurangan-dengan-meminjam',
    'k2-soal-cerita-campuran',
    'k2-tabel-perkalian-2',
    'k2-tabel-perkalian-5',
    'k2-tabel-perkalian-10',
    'k2-mengenal-pembagian',
    'k2-pecahan-setengah-seperempat',
    'k2-mengukur-panjang-cm',
    'k2-mengukur-berat',
    'k2-membaca-waktu',
    'k2-uang-rupiah',
    'k2-review-kelas-2',
  ];

  static const List<String> _kelas3Topics = [
    'k3-perkalian-pembagian',
    'k3-pecahan-sederhana',
    'k3-bilangan-sampai-1000',
    'k3-nilai-tempat-ribuan',
    'k3-penjumlahan-bersusun',
    'k3-pengurangan-bersusun',
    'k3-perkalian-6-9',
    'k3-perkalian-dua-angka',
    'k3-pembagian-bersisa',
    'k3-soal-cerita-perkalian',
    'k3-soal-cerita-pembagian',
    'k3-pecahan-senilai',
    'k3-membandingkan-pecahan',
    'k3-satuan-panjang',
    'k3-keliling-bangun-datar',
    'k3-luas-persegi-persegi-panjang',
    'k3-sudut-dasar',
    'k3-diagram-gambar',
    'k3-pola-bilangan',
    'k3-review-kelas-3',
  ];

  static const List<String> _kelas4Topics = [
    'k4-bilangan-bulat',
    'k4-keliling-luas',
    'k4-operasi-bilangan-besar',
    'k4-perkalian-bersusun',
    'k4-pembagian-bersusun',
    'k4-kpk',
    'k4-fpb',
    'k4-faktor-kelipatan',
    'k4-pecahan-senilai',
    'k4-menyederhanakan-pecahan',
    'k4-penjumlahan-pecahan',
    'k4-pengurangan-pecahan',
    'k4-desimal-dasar',
    'k4-pembulatan',
    'k4-sudut-dan-busur',
    'k4-bangun-datar-lanjut',
    'k4-simetri',
    'k4-diagram-batang',
    'k4-pola-bilangan-lanjut',
    'k4-review-kelas-4',
  ];

  static const List<String> _kelas5Topics = [
    'k5-perkalian-pembagian-pecahan',
    'k5-volume-bangun-ruang',
    'k5-operasi-hitung-campuran',
    'k5-bilangan-pangkat-dua',
    'k5-akar-pangkat-dua',
    'k5-fpb-kpk-lanjut',
    'k5-pecahan-campuran',
    'k5-penjumlahan-pecahan-beda-penyebut',
    'k5-pengurangan-pecahan-beda-penyebut',
    'k5-desimal-dan-pecahan',
    'k5-persen-dasar',
    'k5-perbandingan',
    'k5-skala-denah',
    'k5-kecepatan-jarak-waktu',
    'k5-luas-trapesium-layang',
    'k5-jaring-jaring-bangun-ruang',
    'k5-satuan-volume',
    'k5-pengolahan-data',
    'k5-peluang-sederhana',
    'k5-review-kelas-5',
  ];

  static const List<String> _kelas6Topics = [
    'k6-bilangan-bulat-negatif',
    'k6-statistika-dasar',
    'k6-operasi-pecahan-desimal-persen',
    'k6-rasio-dan-perbandingan',
    'k6-skala-peta',
    'k6-debit',
    'k6-luas-lingkaran',
    'k6-keliling-lingkaran',
    'k6-volume-prisma-tabung',
    'k6-luas-permukaan',
    'k6-koordinat-bidang',
    'k6-pola-bilangan-kompleks',
    'k6-persamaan-sederhana',
    'k6-operasi-hitung-campuran-lanjut',
    'k6-fpb-kpk-soal-cerita',
    'k6-peluang',
    'k6-diagram-lingkaran',
    'k6-satuan-campuran',
    'k6-tryout-ujian-sekolah',
    'k6-review-kelas-6',
  ];
}
