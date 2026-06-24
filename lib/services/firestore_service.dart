import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/produk_model.dart';
import '../models/transaksi_model.dart';
import '../models/laporan_keuangan_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ══════════════════════════════════════════════════════════
  //  PRODUK
  // ══════════════════════════════════════════════════════════

  CollectionReference get _produkRef => _db.collection('produk');

  /// Stream semua produk milik user
  Stream<List<ProdukModel>> streamProduk(String idUser) {
    return _produkRef
        .where('idUser', isEqualTo: idUser)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => ProdukModel.fromMap(
                d.data() as Map<String, dynamic>, d.id))
            .toList());
  }

  /// Cari produk berdasarkan barcode
  Future<ProdukModel?> getProdukByBarcode(
      String barcode, String idUser) async {
    final snap = await _produkRef
        .where('barcode', isEqualTo: barcode)
        .where('idUser', isEqualTo: idUser)
        .limit(1)
        .get();
    if (snap.docs.isEmpty) return null;
    return ProdukModel.fromMap(
        snap.docs.first.data() as Map<String, dynamic>, snap.docs.first.id);
  }

  /// Tambah produk baru
  Future<String> tambahProduk(ProdukModel produk, String idUser) async {
    final map = produk.toMap();
    map['idUser'] = idUser;
    final doc = await _produkRef.add(map);
    return doc.id;
  }

  /// Update produk
  Future<void> updateProduk(ProdukModel produk) async {
    await _produkRef.doc(produk.id).update(produk.toMap());
  }

  /// Hapus produk
  Future<void> hapusProduk(String idProduk) async {
    await _produkRef.doc(idProduk).delete();
  }

  // ══════════════════════════════════════════════════════════
  //  TAMBAH STOK (PEMBELIAN)
  //  Algoritma sesuai pipeline Fase C §5.5.a
  // ══════════════════════════════════════════════════════════

  Future<void> tambahStok({
    required String idUser,
    required String barcode,
    required int jumlahDus,
    required double hargaDus,
    required int isiPerDus,
    required String namaProduk,
    double? hargaJualBaru,
  }) async {
    // 1. Cek apakah produk sudah ada
    ProdukModel? produk = await getProdukByBarcode(barcode, idUser);

    final modalPerUnit = hargaDus / isiPerDus;
    final totalUnitBaru = jumlahDus * isiPerDus;

    await _db.runTransaction((txn) async {
      if (produk == null) {
        // 2. Produk baru — buat dokumen
        final newRef = _produkRef.doc();
        final map = {
          'idUser': idUser,
          'nama': namaProduk,
          'barcode': barcode,
          'hargaModal': modalPerUnit,
          'hargaJual': hargaJualBaru ?? 0,
          'isiPerDus': isiPerDus,
          'stok': totalUnitBaru,
          'fotoProdukUrl': null,
        };
        txn.set(newRef, map);
      } else {
        // 3. Produk lama — update stok & modal
        final ref = _produkRef.doc(produk.id);
        final updateMap = <String, dynamic>{
          'stok': FieldValue.increment(totalUnitBaru),
          'hargaModal': modalPerUnit,
        };
        if (hargaJualBaru != null) {
          updateMap['hargaJual'] = hargaJualBaru;
        }
        txn.update(ref, updateMap);
      }

      // 4. Simpan dokumen Pembelian
      final pembelianRef = _db.collection('pembelian').doc();
      final idProdukFinal = produk?.id ?? '';
      txn.set(pembelianRef, {
        'idUser': idUser,
        'idProduk': idProdukFinal,
        'namaProduk': namaProduk,
        'barcode': barcode,
        'jumlahDus': jumlahDus,
        'isiPerDus': isiPerDus,
        'hargaDus': hargaDus,
        'modalPerUnit': modalPerUnit,
        'totalUnit': totalUnitBaru,
        'totalModal': hargaDus * jumlahDus,
        'tanggal': Timestamp.fromDate(DateTime.now()),
      });
    });
  }

  // ══════════════════════════════════════════════════════════
  //  TRANSAKSI PENJUALAN
  //  Algoritma sesuai pipeline Fase C §5.5.b — Firestore atomic
  // ══════════════════════════════════════════════════════════

  /// [cartItems] = List of { 'barcode': String, 'jumlahUnit': int }
  Future<String> buatTransaksi({
    required String idUser,
    required List<Map<String, dynamic>> cartItems,
    required MetodePembayaran metodePembayaran,
  }) async {
    // Fetch semua produk dulu sebelum transaksi
    final List<Map<String, dynamic>> resolvedItems = [];
    for (final item in cartItems) {
      final produk = await getProdukByBarcode(item['barcode'], idUser);
      if (produk == null) throw Exception('Produk ${item["barcode"]} tidak ditemukan');
      if (produk.stok < (item['jumlahUnit'] as int)) {
        throw Exception('Stok ${produk.nama} tidak cukup (tersisa ${produk.stok})');
      }
      resolvedItems.add({'produk': produk, 'jumlahUnit': item['jumlahUnit']});
    }

    double totalHarga = 0;
    double totalKeuntungan = 0;
    final detailList = <Map<String, dynamic>>[];

    for (final item in resolvedItems) {
      final produk = item['produk'] as ProdukModel;
      final jumlah = item['jumlahUnit'] as int;
      final subtotal = produk.hargaJual * jumlah;
      final keuntungan = (produk.hargaJual - produk.hargaModal) * jumlah;
      totalHarga += subtotal;
      totalKeuntungan += keuntungan;
      detailList.add({
        'idProduk': produk.id,
        'namaProduk': produk.nama,
        'jumlahUnit': jumlah,
        'hargaJualSaatTransaksi': produk.hargaJual,
        'hargaModalSaatTransaksi': produk.hargaModal,
        'subtotal': subtotal,
        'keuntungan': keuntungan,
      });
    }

    late String transaksiId;

    await _db.runTransaction((txn) async {
      // Simpan transaksi
      final transaksiRef = _db.collection('transaksi').doc();
      transaksiId = transaksiRef.id;
      txn.set(transaksiRef, {
        'idUser': idUser,
        'tanggal': Timestamp.fromDate(DateTime.now()),
        'totalHarga': totalHarga,
        'totalKeuntungan': totalKeuntungan,
        'metodePembayaran': metodePembayaran.name,
        'detail': detailList,
      });

      // Kurangi stok tiap produk (atomik)
      for (final item in resolvedItems) {
        final produk = item['produk'] as ProdukModel;
        final jumlah = item['jumlahUnit'] as int;
        txn.update(_produkRef.doc(produk.id), {
          'stok': FieldValue.increment(-jumlah),
        });
      }
    });

    return transaksiId;
  }

  // ══════════════════════════════════════════════════════════
  //  LAPORAN KEUANGAN
  //  Algoritma sesuai pipeline Fase C §5.5.c
  // ══════════════════════════════════════════════════════════

  Future<LaporanKeuanganModel> getLaporan({
    required String idUser,
    required String periode, // 'harian' | 'mingguan' | 'bulanan' | 'tahunan'
    required DateTime tanggalReferensi,
  }) async {
    final (startDate, endDate) = _hitungRangeTanggal(periode, tanggalReferensi);

    final snap = await _db
        .collection('transaksi')
        .where('idUser', isEqualTo: idUser)
        .where('tanggal',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
        .where('tanggal',
            isLessThanOrEqualTo: Timestamp.fromDate(endDate))
        .get();

    double totalPemasukan = 0;
    double totalModal = 0;
    double totalKeuntungan = 0;
    final Map<String, ChartDataPoint> grouped = {};

    for (final doc in snap.docs) {
      final data = doc.data();
      final pemasukan = (data['totalHarga'] ?? 0).toDouble();
      final keuntungan = (data['totalKeuntungan'] ?? 0).toDouble();
      totalPemasukan += pemasukan;
      totalKeuntungan += keuntungan;
      totalModal += pemasukan - keuntungan;

      final tgl = (data['tanggal'] as Timestamp).toDate();
      final key =
          '${tgl.year}-${tgl.month.toString().padLeft(2, '0')}-${tgl.day.toString().padLeft(2, '0')}';

      if (grouped.containsKey(key)) {
        final existing = grouped[key]!;
        grouped[key] = ChartDataPoint(
          tanggal: existing.tanggal,
          totalPemasukan: existing.totalPemasukan + pemasukan,
          totalKeuntungan: existing.totalKeuntungan + keuntungan,
        );
      } else {
        grouped[key] = ChartDataPoint(
          tanggal: tgl,
          totalPemasukan: pemasukan,
          totalKeuntungan: keuntungan,
        );
      }
    }

    final chartData = grouped.values.toList()
      ..sort((a, b) => a.tanggal.compareTo(b.tanggal));

    return LaporanKeuanganModel(
      startDate: startDate,
      endDate: endDate,
      totalPemasukan: totalPemasukan,
      totalModal: totalModal,
      totalKeuntungan: totalKeuntungan,
      jumlahTransaksi: snap.docs.length,
      chartData: chartData,
    );
  }

  /// Hitung range tanggal berdasarkan periode & tanggal referensi
  (DateTime, DateTime) _hitungRangeTanggal(
      String periode, DateTime ref) {
    switch (periode) {
      case 'harian':
        final start = DateTime(ref.year, ref.month, ref.day, 0, 0, 0);
        final end = DateTime(ref.year, ref.month, ref.day, 23, 59, 59);
        return (start, end);
      case 'mingguan':
        final weekday = ref.weekday; // 1=Sen, 7=Min
        final start =
            DateTime(ref.year, ref.month, ref.day - (weekday - 1), 0, 0, 0);
        final end = start.add(const Duration(days: 6, hours: 23, minutes: 59, seconds: 59));
        return (start, end);
      case 'bulanan':
        final start = DateTime(ref.year, ref.month, 1);
        final end = DateTime(ref.year, ref.month + 1, 0, 23, 59, 59);
        return (start, end);
      case 'tahunan':
        final start = DateTime(ref.year, 1, 1);
        final end = DateTime(ref.year, 12, 31, 23, 59, 59);
        return (start, end);
      default:
        throw ArgumentError('Periode tidak valid: $periode');
    }
  }

  // ══════════════════════════════════════════════════════════
  //  DASHBOARD
  //  Algoritma sesuai pipeline Fase C §5.5.d
  // ══════════════════════════════════════════════════════════

  Future<Map<String, dynamic>> getDashboardData(
      String idUser, {int stokThreshold = 5}) async {
    final allProduk = await _produkRef
        .where('idUser', isEqualTo: idUser)
        .get()
        .then((snap) => snap.docs
            .map((d) => ProdukModel.fromMap(
                d.data() as Map<String, dynamic>, d.id))
            .toList());

    final produkHampirHabis =
        allProduk.where((p) => p.stok <= stokThreshold).toList();

    final laporanHarian = await getLaporan(
      idUser: idUser,
      periode: 'harian',
      tanggalReferensi: DateTime.now(),
    );

    return {
      'totalPenjualanHariIni': laporanHarian.totalPemasukan,
      'totalKeuntunganHariIni': laporanHarian.totalKeuntungan,
      'jumlahProdukTersedia': allProduk.length,
      'produkHampirHabis': produkHampirHabis,
    };
  }
}
