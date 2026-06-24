import 'package:flutter/material.dart';
import '../models/produk_model.dart';
import '../services/firestore_service.dart';

/// Provider untuk mengelola state daftar produk & operasi stok.
/// Digunakan oleh Dashboard (F2) dan Manajemen Stok (F3, F4).
class ProdukProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  List<ProdukModel> _produkList = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<ProdukModel> get produkList => _produkList;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Stok hampir habis (threshold default 5) — sesuai algoritma §5.5.d
  List<ProdukModel> get produkHampirHabis =>
      _produkList.where((p) => p.isStokHampirHabis()).toList();

  List<ProdukModel> get produkHabis =>
      _produkList.where((p) => p.stok == 0).toList();

  int get jumlahProdukTersedia => _produkList.length;

  /// Mulai mendengarkan stream produk milik [idUser].
  void listenProduk(String idUser) {
    _isLoading = true;
    notifyListeners();
    _firestoreService.streamProduk(idUser).listen(
      (data) {
        _produkList = data;
        _isLoading = false;
        notifyListeners();
      },
      onError: (e) {
        _errorMessage = e.toString();
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  /// Filter produk berdasarkan kata kunci nama (search bar Manajemen Stok)
  List<ProdukModel> searchProduk(String query) {
    if (query.trim().isEmpty) return _produkList;
    final q = query.toLowerCase();
    return _produkList
        .where((p) =>
            p.nama.toLowerCase().contains(q) || p.barcode.contains(q))
        .toList();
  }

  /// Cari satu produk berdasarkan barcode (untuk hasil scan)
  Future<ProdukModel?> getProdukByBarcode(String barcode, String idUser) {
    return _firestoreService.getProdukByBarcode(barcode, idUser);
  }

  /// Tambah/Update stok — algoritma sesuai pipeline §5.5.a
  Future<bool> tambahStok({
    required String idUser,
    required String barcode,
    required int jumlahDus,
    required double hargaDus,
    required int isiPerDus,
    required String namaProduk,
    double? hargaJualBaru,
  }) async {
    _errorMessage = null;
    try {
      await _firestoreService.tambahStok(
        idUser: idUser,
        barcode: barcode,
        jumlahDus: jumlahDus,
        hargaDus: hargaDus,
        isiPerDus: isiPerDus,
        namaProduk: namaProduk,
        hargaJualBaru: hargaJualBaru,
      );
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Update data produk (nama, harga jual, dll) tanpa mengubah stok
  Future<bool> updateProduk(ProdukModel produk) async {
    _errorMessage = null;
    try {
      await _firestoreService.updateProduk(produk);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Hapus produk
  Future<bool> hapusProduk(String idProduk) async {
    _errorMessage = null;
    try {
      await _firestoreService.hapusProduk(idProduk);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }
}
