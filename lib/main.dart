import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

import 'providers/auth_provider.dart';
import 'providers/produk_provider.dart';
import 'providers/dashboard_provider.dart';
import 'providers/laporan_provider.dart';
import 'screens/auth_gate.dart';
import 'utils/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  // Inisialisasi locale Indonesia untuk intl (format tanggal laporan)
  await initializeDateFormatting('id_ID', null);
  runApp(const WarungApp());
}

class WarungApp extends StatelessWidget {
  const WarungApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ProdukProvider()),
        ChangeNotifierProvider(create: (_) => DashboardProvider()),
        // Fase C Bagian 3/3 — provider baru
        ChangeNotifierProvider(create: (_) => LaporanProvider()),
        // TransaksiProvider dibuat per-screen via ChangeNotifierProvider
        // di dalam TransaksiScreen agar state keranjang di-reset tiap kali
        // tab Transaksi dibuka kembali.
      ],
      child: MaterialApp(
        title: 'Warung App',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        home: const AuthGate(),
      ),
    );
  }
}
