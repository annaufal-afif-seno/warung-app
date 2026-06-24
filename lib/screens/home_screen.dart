import 'package:flutter/material.dart';
import 'package:warung_app/widgets/app_bottom_nav_bar.dart';
import 'package:warung_app/screens/dashboard/dashboard_screen.dart';
import 'package:warung_app/screens/stok/manajemen_stok_screen.dart';
import 'package:warung_app/screens/transaksi/transaksi_screen.dart';
import 'package:warung_app/screens/laporan/laporan_screen.dart';
import 'package:warung_app/screens/profil/profil_screen.dart';

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