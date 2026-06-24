/// Fungsi-fungsi murni (pure functions) yang bisa di-unit-test
/// tanpa koneksi Firebase. Sesuai Fase D §6.1

/// Hitung modal per unit dari 1 dus
/// Contoh: hargaDus=60000, isiPerDus=12 → modalPerUnit=5000
double hitungModalPerUnit(double hargaDus, int isiPerDus) {
  if (isiPerDus <= 0) throw ArgumentError('isiPerDus harus > 0');
  return hargaDus / isiPerDus;
}

/// Hitung total harga dari daftar item transaksi
/// [items] = List<{ 'hargaJual': double, 'jumlahUnit': int }>
double hitungTotalHarga(List<Map<String, dynamic>> items) {
  return items.fold(
    0.0,
    (sum, item) =>
        sum + (item['hargaJual'] as double) * (item['jumlahUnit'] as int),
  );
}

/// Hitung keuntungan per item
double hitungKeuntungan({
  required double hargaJual,
  required double hargaModal,
  required int jumlahUnit,
}) {
  return (hargaJual - hargaModal) * jumlahUnit;
}

/// Cek apakah stok cukup untuk transaksi
bool cekStokCukup(int stokTersedia, int jumlahDiminta) {
  return stokTersedia >= jumlahDiminta;
}

/// Hitung range tanggal dari periode
/// Returns (startDate, endDate)
(DateTime, DateTime) hitungRangeTanggal(String periode, DateTime ref) {
  switch (periode) {
    case 'harian':
      return (
        DateTime(ref.year, ref.month, ref.day),
        DateTime(ref.year, ref.month, ref.day, 23, 59, 59),
      );
    case 'mingguan':
      final start = ref.subtract(Duration(days: ref.weekday - 1));
      final startClean = DateTime(start.year, start.month, start.day);
      final end = startClean.add(const Duration(days: 6, hours: 23, minutes: 59, seconds: 59));
      return (startClean, end);
    case 'bulanan':
      return (
        DateTime(ref.year, ref.month, 1),
        DateTime(ref.year, ref.month + 1, 0, 23, 59, 59),
      );
    case 'tahunan':
      return (
        DateTime(ref.year, 1, 1),
        DateTime(ref.year, 12, 31, 23, 59, 59),
      );
    default:
      throw ArgumentError('Periode tidak valid: $periode');
  }
}

/// Format currency ke Rupiah
String formatRupiah(double amount) {
  final parts = amount.floor().toString().split('').reversed.toList();
  final buffer = StringBuffer();
  for (int i = 0; i < parts.length; i++) {
    if (i > 0 && i % 3 == 0) buffer.write('.');
    buffer.write(parts[i]);
  }
  return 'Rp ${buffer.toString().split('').reversed.join('')}';
}
