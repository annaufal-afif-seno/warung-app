import 'package:flutter/material.dart';
import '../models/laporan_keuangan_model.dart';
import '../services/firestore_service.dart';

class LaporanProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  String _periode = 'harian';
  DateTime _tanggalReferensi = DateTime.now();
  LaporanKeuanganModel? _laporan;
  bool _isLoading = false;
  String? _errorMessage;

  String get periode => _periode;
  DateTime get tanggalReferensi => _tanggalReferensi;
  LaporanKeuanganModel? get laporan => _laporan;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  static const periodeOptions = ['harian', 'mingguan', 'bulanan', 'tahunan'];

  Future<void> muat(String idUser) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _laporan = await _firestoreService.getLaporan(
        idUser: idUser,
        periode: _periode,
        tanggalReferensi: _tanggalReferensi,
      );
    } catch (e) {
      _errorMessage = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  void setPeriode(String periode, String idUser) {
    _periode = periode;
    notifyListeners();
    muat(idUser);
  }

  void navigasiPeriode(int delta, String idUser) {
    switch (_periode) {
      case 'harian':
        _tanggalReferensi =
            _tanggalReferensi.add(Duration(days: delta));
        break;
      case 'mingguan':
        _tanggalReferensi =
            _tanggalReferensi.add(Duration(days: delta * 7));
        break;
      case 'bulanan':
        _tanggalReferensi = DateTime(
          _tanggalReferensi.year,
          _tanggalReferensi.month + delta,
          1,
        );
        break;
      case 'tahunan':
        _tanggalReferensi = DateTime(
          _tanggalReferensi.year + delta,
          1,
          1,
        );
        break;
    }
    notifyListeners();
    muat(idUser);
  }

  void resetKeHariIni(String idUser) {
    _tanggalReferensi = DateTime.now();
    notifyListeners();
    muat(idUser);
  }
}
