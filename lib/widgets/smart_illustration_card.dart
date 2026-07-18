import 'package:flutter/material.dart';

/// Sebuah widget canggih yang menampilkan ilustrasi bergambar untuk setiap butir soal matematika.
/// Jika `ilustrasi` adalah path file di `assets/images/soal/...`, widget ini akan menampilkan gambar tersebut.
/// Jika bukan (atau bila gambar gagal dimuat/belum ada), widget ini akan membaca seluruh kata kunci (keywords)
/// baik pada `ilustrasi` maupun `pertanyaan` (misal: "apel", "buku", "bola", "cm", "kg", "jam", "uang", "persegi",
/// "kubus", "fpb", "skala", "debit", dsb.) dan membuatkan kartu ilustrasi visual yang 100% pas (satu soal satu gambar)!
class SmartIllustrationCard extends StatelessWidget {
  final String ilustrasi;
  final String pertanyaan;
  final Color color;

  const SmartIllustrationCard({
    super.key,
    required this.ilustrasi,
    required this.pertanyaan,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final cleanIlustrasi = ilustrasi.trim();
    final isAssetImage = cleanIlustrasi.startsWith('assets/') ||
        cleanIlustrasi.endsWith('.png') ||
        cleanIlustrasi.endsWith('.jpg') ||
        cleanIlustrasi.endsWith('.jpeg');

    if (isAssetImage) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.asset(
            cleanIlustrasi,
            height: 180,
            width: double.infinity,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              // Jika file asset belum ada atau gagal load, langsung fallback ke ilustrasi pintar berdasar kata kunci
              return _buildKeywordIllustration(context);
            },
          ),
        ),
      );
    }

    return _buildKeywordIllustration(context);
  }

  Widget _buildKeywordIllustration(BuildContext context) {
    final text = '${ilustrasi.toLowerCase()} ${pertanyaan.toLowerCase()}';

    // 1. Apel / Buah / Berhitung benda
    if (text.contains('apel') ||
        text.contains('jeruk') ||
        text.contains('mangga') ||
        text.contains('buah') ||
        text.contains('pisang') ||
        text.contains('melon') ||
        text.contains('nanas') ||
        text.contains('stroberi') ||
        text.contains('semangka') ||
        text.contains('durian') ||
        text.contains('jambu') ||
        text.contains('kelapa') ||
        text.contains('rambutan') ||
        text.contains('belimbing') ||
        text.contains('salak') ||
        text.contains('anggur') ||
        text.contains('menghitung benda')) {
      return _buildVisualCard(
        context,
        icon: Icons.apple,
        title: 'Ilustrasi Buah & Berhitung',
        subtitle: 'Hitung jumlah buah dengan teliti sesuai cerita soal',
        badgeText: '🍎 Berhitung Buah',
        accentColor: Colors.redAccent,
        secondaryIcons: [Icons.apple, Icons.apple, Icons.apple],
      );
    }

    // 2. Buku / Alat Tulis / Sekolah / Tas
    if (text.contains('buku') ||
        text.contains('pensil') ||
        text.contains('penghapus') ||
        text.contains('tulis') ||
        text.contains('sekolah') ||
        text.contains('kertas') ||
        text.contains('meja') ||
        text.contains('rautan') ||
        text.contains('pulpen') ||
        text.contains('spidol') ||
        text.contains('tas') ||
        text.contains('kotak pensil') ||
        text.contains('rak buku') ||
        text.contains('perpustakaan')) {
      return _buildVisualCard(
        context,
        icon: Icons.menu_book,
        title: 'Ilustrasi Buku & Alat Tulis',
        subtitle: 'Perhatikan jumlah buku dan alat tulis dalam cerita',
        badgeText: '📚 Buku & Tulis',
        accentColor: Colors.blueAccent,
        secondaryIcons: [Icons.book, Icons.edit, Icons.school],
      );
    }

    // 3. Bola / Mainan / Olahraga / Kelereng / Boneka
    if (text.contains('bola') ||
        text.contains('kelereng') ||
        text.contains('layang') ||
        text.contains('mainan') ||
        text.contains('olahraga') ||
        text.contains('sepak') ||
        text.contains('basket') ||
        text.contains('bulu tangkis') ||
        text.contains('boneka') ||
        text.contains('robot') ||
        text.contains('voli') ||
        text.contains('tenis') ||
        text.contains('pingpong')) {
      return _buildVisualCard(
        context,
        icon: Icons.sports_soccer,
        title: 'Ilustrasi Bola & Mainan',
        subtitle: 'Hitung atau bandingkan mainan dan bola dalam soal',
        badgeText: '⚽ Bola & Mainan',
        accentColor: Colors.orangeAccent,
        secondaryIcons: [Icons.sports_soccer, Icons.sports_basketball, Icons.sports_tennis],
      );
    }

    // 4. Makanan / Permen / Kue / Pizza / Roti / Minuman / Gula / Susu
    if (text.contains('permen') ||
        text.contains('kue') ||
        text.contains('pizza') ||
        text.contains('roti') ||
        text.contains('makan') ||
        text.contains('cokelat') ||
        text.contains('gula') ||
        text.contains('sirup') ||
        text.contains('susu') ||
        text.contains('es krim') ||
        text.contains('donat') ||
        text.contains('piring') ||
        text.contains('gelas') ||
        text.contains('sendok') ||
        text.contains('minum') ||
        text.contains('teh') ||
        text.contains('kopi')) {
      return _buildVisualCard(
        context,
        icon: Icons.cake,
        title: 'Ilustrasi Makanan & Kue',
        subtitle: 'Kue dan makanan siap dibagikan atau dihitung',
        badgeText: '🧁 Makanan & Kue',
        accentColor: Colors.pinkAccent,
        secondaryIcons: [Icons.cake, Icons.fastfood, Icons.icecream],
      );
    }

    // 5. Hewan Peliharaan / Ternak / Liar
    if (text.contains('burung') ||
        text.contains('ikan') ||
        text.contains('kucing') ||
        text.contains('ayam') ||
        text.contains('ekor') ||
        text.contains('sapi') ||
        text.contains('bebek') ||
        text.contains('kambing') ||
        text.contains('hewan') ||
        text.contains('kelinci') ||
        text.contains('gajah') ||
        text.contains('jerapah') ||
        text.contains('harimau') ||
        text.contains('singa') ||
        text.contains('kuda') ||
        text.contains('domba') ||
        text.contains('kupu') ||
        text.contains('lebah') ||
        text.contains('semut') ||
        text.contains('katak')) {
      return _buildVisualCard(
        context,
        icon: Icons.pets,
        title: 'Ilustrasi Hewan Peliharaan & Alam',
        subtitle: 'Hitung atau perhatikan jumlah hewan pada soal cerita',
        badgeText: '🐾 Hewan Peliharaan',
        accentColor: Colors.teal,
        secondaryIcons: [Icons.pets, Icons.cruelty_free, Icons.egg],
      );
    }

    // 6. Kendaraan / Transportasi / Parkir / Jalan Raya
    if (text.contains('mobil') ||
        text.contains('sepeda') ||
        text.contains('motor') ||
        text.contains('bus') ||
        text.contains('kereta') ||
        text.contains('parkir') ||
        text.contains('kendaraan') ||
        text.contains('truk') ||
        text.contains('pesawat') ||
        text.contains('kapal') ||
        text.contains('perahu') ||
        text.contains('taksi') ||
        text.contains('becak') ||
        text.contains('jalan raya')) {
      return _buildVisualCard(
        context,
        icon: Icons.directions_car,
        title: 'Ilustrasi Kendaraan & Transportasi',
        subtitle: 'Hitung jarak tempuh atau jumlah kendaraan yang berjalan',
        badgeText: '🚗 Kendaraan & Jarak',
        accentColor: Colors.deepPurpleAccent,
        secondaryIcons: [Icons.directions_car, Icons.pedal_bike, Icons.directions_bus],
      );
    }

    // 7. Bahan Sembako & Belanja Pasar / Toko / Karung
    if (text.contains('beras') ||
        text.contains('telur') ||
        text.contains('minyak') ||
        text.contains('tepung') ||
        text.contains('garam') ||
        text.contains('pasar') ||
        text.contains('toko') ||
        text.contains('pedagang') ||
        text.contains('pembeli') ||
        text.contains('kantong') ||
        text.contains('karung') ||
        text.contains('kardus')) {
      return _buildVisualCard(
        context,
        icon: Icons.storefront,
        title: 'Ilustrasi Belanja Pasar & Sembako',
        subtitle: 'Perhatikan jumlah belanjaan atau berat sembako',
        badgeText: '🛒 Belanja Pasar & Toko',
        accentColor: Colors.brown.shade600,
        secondaryIcons: [Icons.storefront, Icons.shopping_basket, Icons.inventory_2],
      );
    }

    // 8. Pengukuran Panjang / Jarak / Penggaris / Pita / Kain (cm, m, km, mm)
    if (text.contains('penggaris') ||
        text.contains('cm') ||
        text.contains('meter') ||
        text.contains('km') ||
        text.contains('mm') ||
        text.contains('panjang') ||
        text.contains('tinggi') ||
        text.contains('lebar') ||
        text.contains('jarak') ||
        text.contains('pita') ||
        text.contains('kain') ||
        text.contains('tali') ||
        text.contains('kawat') ||
        text.contains('kayu') ||
        text.contains('satuan panjang') ||
        text.contains('mengukur panjang')) {
      return _buildRulerCard(context);
    }

    // 9. Timbangan / Berat / Neraca (kg, gram, pon, ton, ons)
    if (text.contains('timbangan') ||
        text.contains('berat') ||
        text.contains('kg') ||
        text.contains('gram') ||
        text.contains('pon') ||
        text.contains('kuintal') ||
        text.contains('ton') ||
        text.contains('ons') ||
        text.contains('neraca') ||
        text.contains('mengukur berat')) {
      return _buildVisualCard(
        context,
        icon: Icons.balance,
        title: 'Alat Ukur Berat (Timbangan)',
        subtitle: 'Perhatikan berat kilogram (kg) atau gram dalam soal',
        badgeText: '⚖️ Timbangan Berat',
        accentColor: Colors.amber.shade700,
        secondaryIcons: [Icons.balance, Icons.monitor_weight, Icons.scale],
      );
    }

    // 10. Volume / Takaran Cairan / Debit (Liter, Mililiter, ml, cc, kubik)
    if (text.contains('liter') ||
        text.contains('mililiter') ||
        text.contains('ml') ||
        text.contains('debit') ||
        text.contains('volume') ||
        text.contains('kapasitas') ||
        text.contains('ember') ||
        text.contains('bak') ||
        text.contains('tangki') ||
        text.contains('botol') ||
        text.contains('galon') ||
        text.contains('kubik') ||
        text.contains('m3') ||
        text.contains('cm3') ||
        ilustrasi.trim() == 'L') {
      return _buildVisualCard(
        context,
        icon: Icons.local_drink,
        title: 'Alat Ukur Volume & Takaran Cairan',
        subtitle: 'Perhatikan takaran liter (L), mililiter (ml) atau debit air',
        badgeText: '🥤 Takaran Volume (Liter / Debit)',
        accentColor: Colors.blue.shade600,
        secondaryIcons: [Icons.local_drink, Icons.water_drop, Icons.coffee],
      );
    }

    // 11. Uang Rupiah / Koin / Harga / Tabungan / Keuangan / Diskon / Bunga / Bruto-Tara-Neto
    if (text.contains('uang') ||
        text.contains('rupiah') ||
        text.contains('koin') ||
        text.contains('lembar') ||
        text.contains('harga') ||
        text.contains('membayar') ||
        text.contains('kembalian') ||
        text.contains('rp') ||
        text.contains('500') ||
        text.contains('1000') ||
        text.contains('2000') ||
        text.contains('5000') ||
        text.contains('10000') ||
        text.contains('20000') ||
        text.contains('50000') ||
        text.contains('100000') ||
        text.contains('tabungan') ||
        text.contains('diskon') ||
        text.contains('persen') ||
        text.contains('bunga') ||
        text.contains('modal') ||
        text.contains('untung') ||
        text.contains('rugi') ||
        text.contains('bruto') ||
        text.contains('tara') ||
        text.contains('neto')) {
      return _buildVisualCard(
        context,
        icon: Icons.monetization_on,
        title: 'Ilustrasi Uang & Perhitungan Keuangan',
        subtitle: 'Hitung jumlah nominal uang, harga, diskon, atau kembalian',
        badgeText: '💰 Uang Rupiah & Keuangan (Rp)',
        accentColor: Colors.green.shade600,
        secondaryIcons: [Icons.monetization_on, Icons.payments, Icons.savings],
      );
    }

    // 12. Jam / Waktu / Kecepatan / Durasi (jam, menit, detik, km/jam, m/s)
    if (text.contains('jam') ||
        text.contains('pukul') ||
        text.contains('menit') ||
        text.contains('detik') ||
        text.contains('waktu') ||
        text.contains('siang') ||
        text.contains('malam') ||
        text.contains('sore') ||
        text.contains('pagi') ||
        text.contains('durasi') ||
        text.contains('kecepatan') ||
        text.contains('km/jam') ||
        text.contains('m/s') ||
        text.contains('berangkat') ||
        text.contains('tiba') ||
        text.contains('perjalanan') ||
        text.contains('hari') ||
        text.contains('minggu') ||
        text.contains('bulan') ||
        text.contains('tahun') ||
        text.contains('abad') ||
        text.contains('windu') ||
        text.contains('lustrum') ||
        text.contains('03.00') ||
        text.contains('04.00') ||
        text.contains('06.00') ||
        text.contains('08.00')) {
      return _buildVisualCard(
        context,
        icon: Icons.access_time_filled,
        title: 'Ilustrasi Waktu, Jam & Kecepatan',
        subtitle: 'Lihat posisi jam, hitung durasi waktu atau kecepatan tempuh',
        badgeText: '⏰ Jam, Waktu & Kecepatan',
        accentColor: Colors.cyan.shade700,
        secondaryIcons: [Icons.access_time_filled, Icons.alarm, Icons.watch],
      );
    }

    // 13. Bangun Ruang 3D (Kubus / Balok / Tabung / Kerucut / Prisma / Limas / Bola 3D)
    if (text.contains('kubus') ||
        text.contains('balok') ||
        text.contains('tabung') ||
        text.contains('kerucut') ||
        text.contains('prisma') ||
        text.contains('limas') ||
        text.contains('rusuk') ||
        text.contains('titik sudut') ||
        text.contains('luas permukaan') ||
        text.contains('volume bangun ruang')) {
      return _buildVisualCard(
        context,
        icon: Icons.view_in_ar,
        title: 'Ilustrasi Bangun Ruang 3D',
        subtitle: 'Perhatikan rusuk, sisi, luas permukaan atau volume bangun ruang',
        badgeText: '📦 Bangun Ruang 3D',
        accentColor: Colors.deepPurple,
        secondaryIcons: [Icons.view_in_ar, Icons.category, Icons.widgets],
      );
    }

    // 14. Bangun Datar / Sudut / Geometri (Persegi / Segitiga / Lingkaran / Trapesium / Jajar Genjang)
    if (text.contains('persegi') ||
        text.contains('segitiga') ||
        text.contains('lingkaran') ||
        text.contains('sudut') ||
        text.contains('sisi') ||
        text.contains('keliling') ||
        text.contains('luas') ||
        text.contains('bangun') ||
        text.contains('jajar genjang') ||
        text.contains('trapesium') ||
        text.contains('belah ketupat') ||
        text.contains('layang-layang') ||
        text.contains('siku-siku') ||
        text.contains('lancip') ||
        text.contains('tumpul') ||
        text.contains('lurus') ||
        text.contains('derajat') ||
        text.contains('busur') ||
        text.contains('<)') ||
        text.contains('[]')) {
      return _buildVisualCard(
        context,
        icon: Icons.change_history,
        title: 'Ilustrasi Bangun Datar & Sudut',
        subtitle: 'Perhatikan jumlah sisi, sudut, keliling atau luas bangun datar',
        badgeText: '📐 Bangun Datar & Sudut Geometri',
        accentColor: Colors.indigo,
        secondaryIcons: [Icons.change_history, Icons.crop_square, Icons.circle],
      );
    }

    // 15. Suhu & Termometer (Celsius / Derajat / Kalor)
    if (text.contains('suhu') ||
        text.contains('celsius') ||
        text.contains('derajat') ||
        text.contains('panas') ||
        text.contains('dingin') ||
        text.contains('thermometer') ||
        text.contains('termometer')) {
      return _buildVisualCard(
        context,
        icon: Icons.thermostat,
        title: 'Alat Ukur Suhu (Termometer)',
        subtitle: 'Perhatikan derajat Celsius (°C) pada soal pengukuran suhu',
        badgeText: '🌡️ Suhu & Termometer (°C)',
        accentColor: Colors.deepOrangeAccent,
        secondaryIcons: [Icons.thermostat, Icons.wb_sunny, Icons.ac_unit],
      );
    }

    // 16. Diagram / Grafik / Statistik / Pengolahan Data (Rata-rata, Modus, Median)
    if (text.contains('diagram') ||
        text.contains('grafik') ||
        text.contains('rata-rata') ||
        text.contains('modus') ||
        text.contains('median') ||
        text.contains('tabel') ||
        text.contains('data') ||
        text.contains('pictogram') ||
        text.contains('mean') ||
        text == '|') {
      return _buildVisualCard(
        context,
        icon: Icons.bar_chart,
        title: 'Ilustrasi Diagram & Statistik Data',
        subtitle: 'Baca data pada tabel atau hitung nilai rata-rata, modus, median',
        badgeText: '📊 Diagram, Tabel & Statistik Data',
        accentColor: Colors.purple.shade600,
        secondaryIcons: [Icons.bar_chart, Icons.pie_chart, Icons.table_chart],
      );
    }

    // 17. Skala & Peta & Perbandingan / Rasio
    if (text.contains('skala') ||
        text.contains('peta') ||
        text.contains('rasio') ||
        text.contains('perbandingan') ||
        text.contains('jarak pada peta') ||
        text.contains('jarak sebenarnya')) {
      return _buildVisualCard(
        context,
        icon: Icons.map,
        title: 'Ilustrasi Skala & Perbandingan Peta',
        subtitle: 'Perhatikan rasio perbandingan skala dengan jarak sebenarnya',
        badgeText: '🗺️ Skala, Peta & Perbandingan',
        accentColor: Colors.teal.shade800,
        secondaryIcons: [Icons.map, Icons.explore, Icons.compare_arrows],
      );
    }

    // 18. Koordinat & Kartesius (Sumbu X & Y)
    if (text.contains('koordinat') ||
        text.contains('kartesius') ||
        text.contains('sumbu x') ||
        text.contains('sumbu y') ||
        text.contains('kuadran')) {
      return _buildVisualCard(
        context,
        icon: Icons.grid_on,
        title: 'Ilustrasi Bidang Koordinat Kartesius',
        subtitle: 'Perhatikan posisi titik (X, Y) pada sumbu mendatar dan tegak',
        badgeText: '📍 Koordinat Kartesius (X, Y)',
        accentColor: Colors.blueGrey.shade800,
        secondaryIcons: [Icons.grid_on, Icons.place, Icons.timeline],
      );
    }

    // 19. FPB & KPK / Faktorisasi Prima / Pangkat & Akar
    if (text.contains('fpb') ||
        text.contains('kpk') ||
        text.contains('faktorisasi') ||
        text.contains('prima') ||
        text.contains('pangkat') ||
        text.contains('akar') ||
        text.contains('kuadrat') ||
        text.contains('pohon faktor') ||
        text.contains('kelipatan persekutuan') ||
        text.contains('faktor persekutuan')) {
      return _buildVisualCard(
        context,
        icon: Icons.account_tree,
        title: 'Ilustrasi FPB, KPK & Faktorisasi',
        subtitle: 'Gunakan pohon faktor atau kelipatan untuk menemukan hasil',
        badgeText: '🌳 FPB, KPK & Pangkat/Akar',
        accentColor: Colors.green.shade800,
        secondaryIcons: [Icons.account_tree, Icons.calculate, Icons.functions],
      );
    }

    // 20. Bilangan Bulat / Positif & Negatif / Garis Bilangan
    if (text.contains('bilangan bulat') ||
        text.contains('negatif') ||
        text.contains('positif') ||
        text.contains('garis bilangan') ||
        text.contains('dibawah nol')) {
      return _buildVisualCard(
        context,
        icon: Icons.linear_scale,
        title: 'Ilustrasi Garis Bilangan Bulat (+/-)',
        subtitle: 'Perhatikan pergeseran ke kanan (positif) atau ke kiri (negatif)',
        badgeText: '➖/➕ Bilangan Bulat & Garis Bilangan',
        accentColor: Colors.deepOrange.shade800,
        secondaryIcons: [Icons.linear_scale, Icons.swap_horiz, Icons.compare],
      );
    }

    // 21. Pecahan Bagian & Desimal (1/2, 1/3, 1/4, 2/4, 3/4, 0,5)
    if (text.contains('pecahan') ||
        text.contains('seperempat') ||
        text.contains('1/2') ||
        text.contains('1/3') ||
        text.contains('1/4') ||
        text.contains('2/4') ||
        text.contains('3/4') ||
        text.contains('desimal') ||
        text.contains('penyebut') ||
        text.contains('pembilang')) {
      return _buildVisualCard(
        context,
        icon: Icons.pie_chart_outline,
        title: 'Ilustrasi Pecahan & Desimal',
        subtitle: 'Perhatikan bagian pembilang dan penyebut yang terbagi sama besar',
        badgeText: '🍕 Pecahan Bagian & Desimal',
        accentColor: Colors.red.shade400,
        secondaryIcons: [Icons.pie_chart_outline, Icons.donut_large, Icons.data_usage],
      );
    }

    // 22. Penjumlahan (+)
    if (text.contains('+') ||
        text.contains('tambah') ||
        text.contains('bertambah') ||
        text.contains('penjumlahan') ||
        text.contains('ditambah') ||
        text.contains('mendapat') ||
        ilustrasi.trim() == '+') {
      return _buildMathOpCard(
        context,
        symbol: '+',
        title: 'Operasi Penjumlahan (+)',
        description: 'Menambahkan atau menggabungkan jumlah benda menjadi lebih banyak.',
        accentColor: Colors.green,
      );
    }

    // 23. Pengurangan (-)
    if (text.contains('-') ||
        text.contains('kurang') ||
        text.contains('berkurang') ||
        text.contains('sisa') ||
        text.contains('selisih') ||
        text.contains('pengurangan') ||
        text.contains('dimakan') ||
        text.contains('dipinjam') ||
        text.contains('diambil') ||
        ilustrasi.trim() == '-') {
      return _buildMathOpCard(
        context,
        symbol: '-',
        title: 'Operasi Pengurangan (-)',
        description: 'Mengurangi sebagian benda atau mencari sisa dari jumlah awal.',
        accentColor: Colors.orange.shade800,
      );
    }

    // 24. Perkalian (x)
    if (text.contains('x') ||
        text.contains('*') ||
        text.contains('kali') ||
        text.contains('perkalian') ||
        text.contains('dikali') ||
        text.contains('kelipatan') ||
        text.contains('tabel perkalian') ||
        ilustrasi.trim() == 'x' ||
        ilustrasi.trim() == '*') {
      return _buildMathOpCard(
        context,
        symbol: '×',
        title: 'Operasi Perkalian (×)',
        description: 'Penjumlahan berulang dari kelompok angka yang sama besar.',
        accentColor: Colors.blue.shade700,
      );
    }

    // 25. Pembagian (:)
    if (text.contains(':') ||
        text.contains('/') ||
        text.contains('bagi') ||
        text.contains('pembagian') ||
        text.contains('dibagi') ||
        text.contains('dibagikan') ||
        ilustrasi.trim() == ':' ||
        ilustrasi.trim() == '/') {
      return _buildMathOpCard(
        context,
        symbol: '÷',
        title: 'Operasi Pembagian (÷)',
        description: 'Membagi sejumlah benda ke beberapa kelompok sama rata.',
        accentColor: Colors.purple.shade700,
      );
    }

    // 26. Membandingkan Bilangan (> / < / =)
    if (text.contains('membandingkan') ||
        text.contains('lebih besar') ||
        text.contains('lebih kecil') ||
        text.contains('paling besar') ||
        text.contains('paling kecil') ||
        text.contains('mana yang lebih') ||
        text.contains('>') ||
        text.contains('<')) {
      return _buildVisualCard(
        context,
        icon: Icons.compare_arrows,
        title: 'Ilustrasi Perbandingan Angka (> / <)',
        subtitle: 'Tentukan angka mana yang nilainya lebih besar atau lebih kecil',
        badgeText: '⚖️ Perbandingan Angka',
        accentColor: Colors.deepOrange,
        secondaryIcons: [Icons.compare_arrows, Icons.remove_circle_outline, Icons.add_circle_outline],
      );
    }

    // 27. Mengurutkan Bilangan
    if (text.contains('mengurutkan') ||
        text.contains('urutan') ||
        text.contains('terkecil') ||
        text.contains('terbesar') ||
        text.contains('dari yang kecil') ||
        text.contains('dari yang besar')) {
      return _buildVisualCard(
        context,
        icon: Icons.format_list_numbered,
        title: 'Ilustrasi Urutan Bilangan',
        subtitle: 'Perhatikan susunan angka dari yang terkecil hingga terbesar',
        badgeText: '📈 Urutan Bilangan',
        accentColor: Colors.blueGrey,
        secondaryIcons: [Icons.sort, Icons.format_list_numbered, Icons.leaderboard],
      );
    }

    // 28. Nilai Tempat Bilangan
    if (text.contains('nilai tempat') ||
        text.contains('ratusan') ||
        text.contains('puluhan') ||
        text.contains('satuan') ||
        text.contains('ribuan') ||
        text.contains('menempati tempat')) {
      return _buildVisualCard(
        context,
        icon: Icons.view_column,
        title: 'Ilustrasi Nilai Tempat Angka',
        subtitle: 'Setiap digit angka memiliki nilai tempat sesuai posisinya',
        badgeText: '🧮 Nilai Tempat Bilangan',
        accentColor: Colors.brown.shade700,
        secondaryIcons: [Icons.view_column, Icons.apps, Icons.grid_4x4],
      );
    }

    // 29. Pola & Loncatan Bilangan
    if (text.contains('loncat') ||
        text.contains('pola') ||
        text.contains('barisan') ||
        text.contains('berikutnya') ||
        text.contains('selanjutnya')) {
      return _buildVisualCard(
        context,
        icon: Icons.linear_scale,
        title: 'Ilustrasi Pola & Loncatan Angka',
        subtitle: 'Amati pola pertambahan atau pengurangan pada setiap langkah angka',
        badgeText: '🦘 Pola & Loncatan Angka',
        accentColor: Colors.pink.shade700,
        secondaryIcons: [Icons.linear_scale, Icons.timeline, Icons.trending_up],
      );
    }

    // 30. Default Visual Bilangan
    return _buildVisualCard(
      context,
      icon: Icons.numbers,
      title: 'Ilustrasi Bilangan & Angka Matematika',
      subtitle: 'Perhatikan angka dan informasi pada cerita soal dengan teliti',
      badgeText: '🔢 Bilangan Matematika',
      accentColor: color,
      secondaryIcons: [Icons.apps, Icons.linear_scale, Icons.format_list_numbered],
    );
  }

  Widget _buildVisualCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required String badgeText,
    required Color accentColor,
    required List<IconData> secondaryIcons,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8.0),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            accentColor.withValues(alpha: 0.15),
            accentColor.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1D2030), width: 3),
        boxShadow: const [
          BoxShadow(
            color: Color(0xFF1D2030),
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          // Badge atas
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              badgeText,
              style: TextStyle(
                color: accentColor.withValues(alpha: 1.0),
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Barisan Icon Ilustrasi
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (int i = 0; i < secondaryIcons.length; i++) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    secondaryIcons[i],
                    size: i == 1 ? 38 : 28,
                    color: accentColor,
                  ),
                ),
                if (i < secondaryIcons.length - 1) const SizedBox(width: 12),
              ]
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: accentColor.withValues(alpha: 1.0),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRulerCard(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8.0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blueGrey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1D2030), width: 3),
        boxShadow: const [
          BoxShadow(
            color: Color(0xFF1D2030),
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.blueGrey.shade200,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              '📏 Pengukuran Panjang (cm / m / km)',
              style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(height: 14),
          // Visual Penggaris
          Container(
            height: 54,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.amber.shade200,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.amber.shade800, width: 2),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(11, (index) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      width: 2,
                      height: index % 2 == 0 ? 18 : 10,
                      color: Colors.brown.shade800,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$index',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.brown.shade900,
                      ),
                    ),
                  ],
                );
              }),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Perhatikan angka ukuran sentimeter (cm), meter (m), atau kilometer (km) pada penggaris/pita.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: Colors.blueGrey.shade800),
          ),
        ],
      ),
    );
  }

  Widget _buildMathOpCard(
    BuildContext context, {
    required String symbol,
    required String title,
    required String description,
    required Color accentColor,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8.0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1D2030), width: 3),
        boxShadow: const [
          BoxShadow(
            color: Color(0xFF1D2030),
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: accentColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: accentColor.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Text(
              symbol,
              style: const TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: accentColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
