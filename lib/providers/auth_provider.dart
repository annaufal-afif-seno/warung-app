import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

/// Provider untuk mengelola state autentikasi & data user yang sedang login.
class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  AuthStatus _status = AuthStatus.unknown;
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  AuthProvider() {
    _init();
  }

  AuthStatus get status => _status;
  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isLoggedIn => _status == AuthStatus.authenticated;

  void _init() {
    _authService.authStateChanges.listen((user) async {
      if (user == null) {
        _currentUser = null;
        _status = AuthStatus.unauthenticated;
      } else {
        _currentUser = await _authService.getCurrentUserModel();
        _status = _currentUser == null
            ? AuthStatus.unauthenticated
            : AuthStatus.authenticated;
      }
      notifyListeners();
    });
  }

  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      final user = await _authService.login(email, password);
      if (user == null) {
        _errorMessage = 'Email atau password salah';
        _setLoading(false);
        return false;
      }
      _currentUser = user;
      _status = AuthStatus.authenticated;
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = _mapErrorMessage(e);
      _setLoading(false);
      return false;
    }
  }

  Future<bool> register({
    required String email,
    required String password,
    required String nama,
    required String namaWarung,
    required String telepon,
  }) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      final user = await _authService.register(
        email: email,
        password: password,
        nama: nama,
        namaWarung: namaWarung,
        telepon: telepon,
      );
      _currentUser = user;
      _status = AuthStatus.authenticated;
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = _mapErrorMessage(e);
      _setLoading(false);
      return false;
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    _currentUser = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  Future<void> refreshUser() async {
    _currentUser = await _authService.getCurrentUserModel();
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  /// Mapping pesan error Firebase Auth ke Bahasa Indonesia yang ramah pengguna.
  String _mapErrorMessage(Object e) {
    final msg = e.toString();
    if (msg.contains('user-not-found') || msg.contains('wrong-password') ||
        msg.contains('invalid-credential')) {
      return 'Email atau password salah';
    }
    if (msg.contains('email-already-in-use')) {
      return 'Email sudah terdaftar';
    }
    if (msg.contains('weak-password')) {
      return 'Password terlalu lemah (minimal 6 karakter)';
    }
    if (msg.contains('invalid-email')) {
      return 'Format email tidak valid';
    }
    if (msg.contains('network-request-failed')) {
      return 'Tidak ada koneksi internet';
    }
    return 'Terjadi kesalahan, silakan coba lagi';
  }
}
