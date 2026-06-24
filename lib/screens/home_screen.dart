import 'package:flutter/material.dart';
import '../../widgets/app_bottom_nav_bar.dart';
import '../dashboard/dashboard_screen.dart';
import '../stok/manajemen_stok_screen.dart';
import '../transaksi/transaksi_screen.dart';
import '../laporan/laporan_screen.dart';
import '../profil/profil_screen.dart';

/// HomeScreen — kontainer utama dengan BottomNavBar 5 menu
/// (Dashboard, Manajemen Stok, Transaksi, Laporan, Profil)
/// sesuai UIUX_Design_System.md §2.3
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final _screens = const [
    DashboardScreen(),
    ManajemenStokScreen(),
    TransaksiScreen(),
    LaporanScreen(),
    ProfilScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }
}
