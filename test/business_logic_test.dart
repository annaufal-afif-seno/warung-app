// test/business_logic_test.dart
// Unit Test — Fase D §6.1
// Menguji semua pure functions di lib/utils/business_logic.dart
// tanpa koneksi Firebase maupun widget Flutter.
//
// Jalankan: flutter test
// Jalankan dengan coverage: flutter test --coverage

import 'package:flutter_test/flutter_test.dart';
import 'package:warung_app/utils/business_logic.dart';

void main() {
  // ══════════════════════════════════════════════════════════
  // UT-01 · hitungModalPerUnit
  // ══════════════════════════════════════════════════════════
  group('UT-01: hitungModalPerUnit', () {
    test('kasus normal: hargaDus=60000, isiPerDus=12 → 5000.0', () {
      expect(hitungModalPerUnit(60000, 12), equals(5000.0));
    });

    test('kasus normal: hargaDus=24000, isiPerDus=24 → 1000.0', () {
      expect(hitungModalPerUnit(24000, 24), equals(1000.0));
    });

    test('hasil bagi tidak bulat: hargaDus=10000, isiPerDus=3 → ~3333.33', () {
      final result = hitungModalPerUnit(10000, 3);
      expect(result, closeTo(3333.33, 0.01));
    });

    test('isiPerDus=1 → hasil = hargaDus', () {
      expect(hitungModalPerUnit(15000, 1), equals(15000.0));
    });

    test('isiPerDus=0 → ArgumentError', () {
      expect(() => hitungModalPerUnit(60000, 0), throwsArgumentError);
    });

    test('isiPerDus negatif → ArgumentError', () {
      expect(() => hitungModalPerUnit(60000, -5), throwsArgumentError);
    });

    test('hargaDus=0 → modalPerUnit=0', () {
      expect(hitungModalPerUnit(0, 12), equals(0.0));
    });
  });

  // ══════════════════════════════════════════════════════════
  // UT-02 · hitungTotalHarga
  // ══════════════════════════════════════════════════════════
  group('UT-02: hitungTotalHarga', () {
    test('1 item: harga=5000, jumlah=3 → 15000', () {
      final items = [
        {'hargaJual': 5000.0, 'jumlahUnit': 3},
      ];
      expect(hitungTotalHarga(items), equals(15000.0));
    });

    test('2 item berbeda: (5000×3) + (12000×2) → 39000', () {
      final items = [
        {'hargaJual': 5000.0, 'jumlahUnit': 3},
        {'hargaJual': 12000.0, 'jumlahUnit': 2},
      ];
      expect(hitungTotalHarga(items), equals(39000.0));
    });

    test('keranjang kosong → 0.0', () {
      expect(hitungTotalHarga([]), equals(0.0));
    });

    test('jumlah=0 untuk semua item → total 0.0', () {
      final items = [
        {'hargaJual': 5000.0, 'jumlahUnit': 0},
        {'hargaJual': 12000.0, 'jumlahUnit': 0},
      ];
      expect(hitungTotalHarga(items), equals(0.0));
    });

    test('banyak item: akumulasi presisi float', () {
      final items = List.generate(
        100,
        (_) => {'hargaJual': 1500.0, 'jumlahUnit': 2},
      );
      expect(hitungTotalHarga(items), equals(300000.0));
    });
  });

  // ══════════════════════════════════════════════════════════
  // UT-03 · hitungKeuntungan
  // ══════════════════════════════════════════════════════════
  group('UT-03: hitungKeuntungan', () {
    test('margin positif: jual=7000, modal=5000, qty=3 → 6000', () {
      expect(
        hitungKeuntungan(hargaJual: 7000, hargaModal: 5000, jumlahUnit: 3),
        equals(6000.0),
      );
    });

    test('jual == modal → keuntungan 0 (impas)', () {
      expect(
        hitungKeuntungan(hargaJual: 5000, hargaModal: 5000, jumlahUnit: 10),
        equals(0.0),
      );
    });

    test('jual < modal → keuntungan negatif (rugi)', () {
      expect(
        hitungKeuntungan(hargaJual: 4000, hargaModal: 5000, jumlahUnit: 2),
        equals(-2000.0),
      );
    });

    test('jumlah=0 → keuntungan 0', () {
      expect(
        hitungKeuntungan(hargaJual: 7000, hargaModal: 5000, jumlahUnit: 0),
        equals(0.0),
      );
    });

    test('margin besar: jual=50000, modal=20000, qty=5 → 150000', () {
      expect(
        hitungKeuntungan(hargaJual: 50000, hargaModal: 20000, jumlahUnit: 5),
        equals(150000.0),
      );
    });
  });

  // ══════════════════════════════════════════════════════════
  // UT-04 · cekStokCukup
  // ══════════════════════════════════════════════════════════
  group('UT-04: cekStokCukup', () {
    test('stok > diminta → true', () {
      expect(cekStokCukup(10, 5), isTrue);
    });

    test('stok == diminta (tepat) → true', () {
      expect(cekStokCukup(5, 5), isTrue);
    });

    test('stok < diminta → false', () {
      expect(cekStokCukup(3, 5), isFalse);
    });

    test('stok=0, diminta=1 → false', () {
      expect(cekStokCukup(0, 1), isFalse);
    });

    test('stok=0, diminta=0 → true (tidak butuh stok)', () {
      expect(cekStokCukup(0, 0), isTrue);
    });

    test('stok besar → true selalu', () {
      expect(cekStokCukup(9999, 1000), isTrue);
    });
  });

  // ══════════════════════════════════════════════════════════
  // UT-05 · hitungRangeTanggal
  // ══════════════════════════════════════════════════════════
  group('UT-05: hitungRangeTanggal', () {
    // Tanggal referensi tetap: Kamis, 18 Juni 2026
    final ref = DateTime(2026, 6, 18, 14, 30, 0);

    group('harian', () {
      test('start = 00:00:00, end = 23:59:59 hari yang sama', () {
        final (start, end) = hitungRangeTanggal('harian', ref);
        expect(start, equals(DateTime(2026, 6, 18, 0, 0, 0)));
        expect(end, equals(DateTime(2026, 6, 18, 23, 59, 59)));
      });

      test('start dan end pada hari yang sama', () {
        final (start, end) = hitungRangeTanggal('harian', ref);
        expect(start.day, equals(end.day));
        expect(start.month, equals(end.month));
      });
    });

    group('mingguan', () {
      test('start = Senin (16 Jun 2026), end = Minggu (22 Jun 2026)', () {
        final (start, end) = hitungRangeTanggal('mingguan', ref);
        expect(start, equals(DateTime(2026, 6, 15)));
        expect(end.day, equals(21));
        expect(end.hour, equals(23));
        expect(end.minute, equals(59));
      });

      test('durasi tepat 7 hari', () {
        final (start, end) = hitungRangeTanggal('mingguan', ref);
        final durasi = end.difference(start);
        expect(durasi.inDays, equals(6)); // 6 hari lebih 23:59:59
      });
    });

    group('bulanan', () {
      test('start = 1 Juni 2026, end = 30 Juni 2026 23:59:59', () {
        final (start, end) = hitungRangeTanggal('bulanan', ref);
        expect(start, equals(DateTime(2026, 6, 1)));
        expect(end.month, equals(6));
        expect(end.day, equals(30));
        expect(end.hour, equals(23));
      });

      test('bulan Februari tahun kabisat (2024): end = 29 Feb', () {
        final refFeb = DateTime(2024, 2, 15);
        final (_, end) = hitungRangeTanggal('bulanan', refFeb);
        expect(end.day, equals(29));
        expect(end.month, equals(2));
      });

      test('bulan Februari tahun non-kabisat (2025): end = 28 Feb', () {
        final refFeb = DateTime(2025, 2, 10);
        final (_, end) = hitungRangeTanggal('bulanan', refFeb);
        expect(end.day, equals(28));
      });
    });

    group('tahunan', () {
      test('start = 1 Jan, end = 31 Des tahun ref', () {
        final (start, end) = hitungRangeTanggal('tahunan', ref);
        expect(start, equals(DateTime(2026, 1, 1)));
        expect(end, equals(DateTime(2026, 12, 31, 23, 59, 59)));
      });

      test('start.year == end.year == ref.year', () {
        final (start, end) = hitungRangeTanggal('tahunan', ref);
        expect(start.year, equals(ref.year));
        expect(end.year, equals(ref.year));
      });
    });

    test('periode tidak valid → ArgumentError', () {
      expect(
        () => hitungRangeTanggal('semester', ref),
        throwsArgumentError,
      );
    });

    test('periode kosong → ArgumentError', () {
      expect(
        () => hitungRangeTanggal('', ref),
        throwsArgumentError,
      );
    });
  });

  // ══════════════════════════════════════════════════════════
  // UT-06 · formatRupiah
  // ══════════════════════════════════════════════════════════
  group('UT-06: formatRupiah', () {
    test('di bawah seribu: 500 → "Rp 500"', () {
      expect(formatRupiah(500), equals('Rp 500'));
    });

    test('tepat seribu: 1000 → "Rp 1.000"', () {
      expect(formatRupiah(1000), equals('Rp 1.000'));
    });

    test('ribuan: 15000 → "Rp 15.000"', () {
      expect(formatRupiah(15000), equals('Rp 15.000'));
    });

    test('ratusan ribu: 150000 → "Rp 150.000"', () {
      expect(formatRupiah(150000), equals('Rp 150.000'));
    });

    test('jutaan: 1500000 → "Rp 1.500.000"', () {
      expect(formatRupiah(1500000), equals('Rp 1.500.000'));
    });

    test('0 → "Rp 0"', () {
      expect(formatRupiah(0), equals('Rp 0'));
    });

    test('nilai pecahan dibulatkan: 5000.75 → "Rp 5.000"', () {
      expect(formatRupiah(5000.75), equals('Rp 5.000'));
    });

    test('prefix selalu "Rp "', () {
      expect(formatRupiah(7500).startsWith('Rp '), isTrue);
    });

    test('separator ribuan adalah titik (bukan koma)', () {
      final result = formatRupiah(1000000);
      expect(result.contains('.'), isTrue);
      expect(result.contains(','), isFalse);
    });
  });

  // ══════════════════════════════════════════════════════════
  // UT-07 · Skenario bisnis terintegrasi (alur end-to-end)
  // ══════════════════════════════════════════════════════════
  group('UT-07: Skenario bisnis (kombinasi fungsi)', () {
    test('alur tambah stok: modal per unit & total unit', () {
      // Beli 2 dus @ Rp 60.000, isi 12 unit/dus
      const hargaDus = 60000.0;
      const isiPerDus = 12;
      const jumlahDus = 2;

      final modalPerUnit = hitungModalPerUnit(hargaDus, isiPerDus);
      final totalUnit = jumlahDus * isiPerDus;

      expect(modalPerUnit, equals(5000.0));
      expect(totalUnit, equals(24));
    });

    test('alur transaksi: total harga + keuntungan + cek stok', () {
      // Produk A: stok=10, jual=7000, modal=5000, beli 3 unit
      // Produk B: stok=5, jual=12000, modal=9000, beli 2 unit
      const stokA = 10;
      const stokB = 5;
      const diintaA = 3;
      const dimintaB = 2;

      expect(cekStokCukup(stokA, diintaA), isTrue);
      expect(cekStokCukup(stokB, dimintaB), isTrue);

      final items = [
        {'hargaJual': 7000.0, 'jumlahUnit': diintaA},
        {'hargaJual': 12000.0, 'jumlahUnit': dimintaB},
      ];
      final total = hitungTotalHarga(items);
      expect(total, equals(45000.0)); // 21000 + 24000

      final kA = hitungKeuntungan(hargaJual: 7000, hargaModal: 5000, jumlahUnit: diintaA);
      final kB = hitungKeuntungan(hargaJual: 12000, hargaModal: 9000, jumlahUnit: dimintaB);
      expect(kA + kB, equals(12000.0)); // 6000 + 6000
    });

    test('stok tidak cukup: tolak transaksi', () {
      const stokTersedia = 2;
      const diminta = 5;
      expect(cekStokCukup(stokTersedia, diminta), isFalse);
    });

    test('range laporan harian mencakup transaksi pada hari yang sama', () {
      final now = DateTime(2026, 6, 18, 10, 30);
      final transaksiTime = DateTime(2026, 6, 18, 14, 15);
      final (start, end) = hitungRangeTanggal('harian', now);

      expect(
        transaksiTime.isAfter(start) && transaksiTime.isBefore(end),
        isTrue,
      );
    });

    test('transaksi kemarin tidak masuk laporan harian hari ini', () {
      final now = DateTime(2026, 6, 18, 10, 0);
      final kemarin = DateTime(2026, 6, 17, 23, 59, 59);
      final (start, _) = hitungRangeTanggal('harian', now);

      expect(kemarin.isBefore(start), isTrue);
    });
  });
}
