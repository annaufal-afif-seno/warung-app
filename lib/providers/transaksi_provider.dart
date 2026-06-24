import 'package:flutter/material.dart';
import '../models/produk_model.dart';
import '../models/transaksi_model.dart';
import '../services/firestore_service.dart';

/// Item di keranjang belanja kasir
class CartItem {
  final ProdukModel produk;
  int jumlahUnit;

  CartItem({required this.produk, this.jumlahUnit = 1});

  double get subtotal => produk.hargaJual * jumlahUnit;
  double get keuntungan => (produk.hargaJual - produk.hargaModal) * jumlahUnit;
}

/// Provider untuk mengelola state Transaksi (F5/F6/F7)
class TransaksiProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  // ─── State Keranjang ───────────────────────────────────────
  final List<CartItem> _cart = [];
  MetodePembayaran _metodePembayaran = MetodePembayaran.cash;

  // ─── State Proses ──────────────────────────────────────────
  bool _isLoading = false;
  String? _errorMessage;
  String? _lastTransaksiId;

  // ─── Getters ───────────────────────────────────────────────
  List<CartItem> get cart => List.unmodifiable(_cart);
  MetodePembayaran get metodePembayaran => _metodePembayaran;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get lastTransaksiId => _lastTransaksiId;
  bool get cartEmpty => _cart.isEmpty;

  double get totalHarga =>
      _cart.fold(0, (sum, item) => sum + item.subtotal);

  double get totalKeuntungan =>
      _cart.fold(0, (sum, item) => sum + item.keuntungan);

  int get totalItem =>
      _cart.fold(0, (sum, item) => sum + item.jumlahUnit);

  // ─── Operasi Keranjang ─────────────────────────────────────

  /// Tambah produk ke keranjang (jika sudah ada, increment jumlah)
  void tambahKeKeranjang(ProdukModel produk) {
    _errorMessage = null;
    final index = _cart.indexWhere((c) => c.produk.id == produk.id);
    if (index >= 0) {
      final existing = _cart[index];
      if (existing.jumlahUnit >= produk.stok) {
        _errorMessage = 'Stok ${produk.nama} hanya tersisa ${produk.stok} unit';
        notifyListeners();
        return;
      }
      _cart[index] = CartItem(
        produk: produk,
        jumlahUnit: existing.jumlahUnit + 1,
      );
    } else {
      if (produk.stok <= 0) {
        _errorMessage = 'Stok ${produk.nama} habis';
        notifyListeners();
        return;
      }
      _cart.add(CartItem(produk: produk));
    }
    notifyListeners();
  }

  /// Ubah jumlah item di keranjang (min 1, max stok tersedia)
  void ubahJumlah(String idProduk, int jumlahBaru) {
    _errorMessage = null;
    final index = _cart.indexWhere((c) => c.produk.id == idProduk);
    if (index < 0) return;
    final item = _cart[index];
    if (jumlahBaru <= 0) {
      _cart.removeAt(index);
    } else if (jumlahBaru > item.produk.stok) {
      _errorMessage =
          'Stok ${item.produk.nama} hanya tersisa ${item.produk.stok} unit';
    } else {
      _cart[index] = CartItem(produk: item.produk, jumlahUnit: jumlahBaru);
    }
    notifyListeners();
  }

  /// Hapus item dari keranjang
  void hapusDariKeranjang(String idProduk) {
    _cart.removeWhere((c) => c.produk.id == idProduk);
    notifyListeners();
  }

  /// Kosongkan keranjang
  void kosongkanKeranjang() {
    _cart.clear();
    _metodePembayaran = MetodePembayaran.cash;
    _errorMessage = null;
    _lastTransaksiId = null;
    notifyListeners();
  }

  void setMetodePembayaran(MetodePembayaran metode) {
    _metodePembayaran = metode;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // ─── Proses Transaksi ──────────────────────────────────────

  /// Simpan transaksi ke Firestore secara atomik (F5+F6+F7)
  Future<bool> prosesTransaksi(String idUser) async {
    if (_cart.isEmpty) {
      _errorMessage = 'Keranjang masih kosong';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final cartItems = _cart
          .map((c) => {
                'barcode': c.produk.barcode,
                'jumlahUnit': c.jumlahUnit,
              })
          .toList();

      _lastTransaksiId = await _firestoreService.buatTransaksi(
        idUser: idUser,
        cartItems: cartItems,
        metodePembayaran: _metodePembayaran,
      );

      _cart.clear();
      _metodePembayaran = MetodePembayaran.cash;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
