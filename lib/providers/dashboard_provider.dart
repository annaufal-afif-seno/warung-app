import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import '../models/produk_model.dart';

/// Provider untuk data agregat Dashboard (F2) — algoritma §5.5.d
class DashboardProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  bool _isLoading = false;
  String? _errorMessage;

  double _totalPenjualanHariIni = 0;
  double _totalKeuntunganHariIni = 0;
  int _jumlahProdukTersedia = 0;
  List<ProdukModel> _produkHampirHabis = [];

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  double get totalPenjualanHariIni => _totalPenjualanHariIni;
  double get totalKeuntunganHariIni => _totalKeuntunganHariIni;
  int get jumlahProdukTersedia => _jumlahProdukTersedia;
  List<ProdukModel> get produkHampirHabis => _produkHampirHabis;

  Future<void> loadDashboard(String idUser, {int stokThreshold = 5}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final data = await _firestoreService.getDashboardData(
        idUser,
        stokThreshold: stokThreshold,
      );
      _totalPenjualanHariIni = (data['totalPenjualanHariIni'] as double);
      _totalKeuntunganHariIni = (data['totalKeuntunganHariIni'] as double);
      _jumlahProdukTersedia = data['jumlahProdukTersedia'] as int;
      _produkHampirHabis = data['produkHampirHabis'] as List<ProdukModel>;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
