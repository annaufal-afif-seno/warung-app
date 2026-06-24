// integration_test/app_flow_test.dart
// Integration Test — Fase D §6.1
// Mensimulasikan alur penuh: Login → Tambah Stok → Transaksi →
// Cek Stok Berkurang → Cek Laporan Harian Update
//
// Prasyarat:
//   - Firebase Emulator Suite berjalan secara lokal (Auth + Firestore)
//     atau akun test yang sudah disiapkan di Firebase project.
//   - Jalankan: flutter test integration_test/app_flow_test.dart
//     --dart-define=USE_EMULATOR=true
//
// Catatan: integration_test menjalankan app secara end-to-end di
// emulator/device sehingga seluruh widget dan navigasi ikut diuji.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:warung_app/main.dart' as app;

// ─── Konstanta test ───────────────────────────────────────────
const _testEmail    = 'test.warung@example.com';
const _testPassword = 'Test@12345';
const _testBarcode  = '8991234567890';
const _testNama     = 'Aqua Botol 600ml';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('IT-01 — IT-06: Alur End-to-End Warung App', () {

    // ══════════════════════════════════════════════════════════
    // IT-01: Login berhasil dengan kredensial valid
    // ══════════════════════════════════════════════════════════
    testWidgets('IT-01: Login dengan email & password valid', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Pastikan LoginScreen tampil
      expect(find.text('Masuk'), findsWidgets);

      // Isi email
      final emailField = find.byKey(const Key('login_email_field'));
      await tester.tap(emailField);
      await tester.enterText(emailField, _testEmail);

      // Isi password
      final passField = find.byKey(const Key('login_password_field'));
      await tester.tap(passField);
      await tester.enterText(passField, _testPassword);

      // Tekan tombol login
      await tester.tap(find.byKey(const Key('login_submit_button')));
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Verifikasi: Dashboard tampil setelah login
      expect(find.text('Dashboard'), findsOneWidget);
    });

    // ══════════════════════════════════════════════════════════
    // IT-02: Navigasi ke Manajemen Stok berhasil
    // ══════════════════════════════════════════════════════════
    testWidgets('IT-02: Navigasi ke halaman Manajemen Stok', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Login dulu
      await _doLogin(tester);

      // Tap menu Stok di bottom nav
      await tester.tap(find.byKey(const Key('nav_stok')));
      await tester.pumpAndSettle();

      // Verifikasi: halaman Manajemen Stok tampil
      expect(find.text('Manajemen Stok'), findsOneWidget);
    });

    // ══════════════════════════════════════════════════════════
    // IT-03: Tambah stok produk baru via form (simulasi scan barcode)
    // ══════════════════════════════════════════════════════════
    testWidgets('IT-03: Tambah stok produk baru — stok bertambah di list', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      await _doLogin(tester);
      await _navigateTo(tester, 'nav_stok');

      // Tap FAB tambah stok
      await tester.tap(find.byKey(const Key('fab_tambah_stok')));
      await tester.pumpAndSettle();

      // Form tambah stok tampil
      expect(find.byKey(const Key('tambah_stok_form')), findsOneWidget);

      // Isi barcode (simulasi input manual karena kamera tidak tersedia di test)
      await tester.enterText(
          find.byKey(const Key('field_barcode')), _testBarcode);

      // Isi nama produk
      await tester.enterText(
          find.byKey(const Key('field_nama_produk')), _testNama);

      // Isi jumlah dus
      await tester.enterText(find.byKey(const Key('field_jumlah_dus')), '2');

      // Isi harga dus
      await tester.enterText(
          find.byKey(const Key('field_harga_dus')), '24000');

      // Isi isi per dus
      await tester.enterText(
          find.byKey(const Key('field_isi_per_dus')), '24');

      // Isi harga jual
      await tester.enterText(
          find.byKey(const Key('field_harga_jual')), '2000');

      // Simpan
      await tester.tap(find.byKey(const Key('btn_simpan_stok')));
      await tester.pumpAndSettle(const Duration(seconds: 4));

      // Verifikasi: produk muncul di list dengan stok 48 (2 dus x 24)
      expect(find.text(_testNama), findsOneWidget);
      expect(find.text('48'), findsOneWidget); // stok = 2 * 24
    });

    // ══════════════════════════════════════════════════════════
    // IT-04: Buat transaksi penjualan — total harga terhitung benar
    // ══════════════════════════════════════════════════════════
    testWidgets('IT-04: Transaksi penjualan — total harga & metode bayar tersimpan',
        (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      await _doLogin(tester);
      await _navigateTo(tester, 'nav_transaksi');

      // Halaman transaksi tampil
      expect(find.text('Transaksi'), findsOneWidget);

      // Scan / input barcode
      await tester.tap(find.byKey(const Key('btn_scan_barcode_transaksi')));
      await tester.pumpAndSettle();

      // Simulasi input barcode manual
      await tester.enterText(
          find.byKey(const Key('field_barcode_transaksi')), _testBarcode);
      await tester.tap(find.byKey(const Key('btn_cari_produk')));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Produk ditemukan, masukkan jumlah unit = 3
      await tester.enterText(
          find.byKey(const Key('field_jumlah_unit')), '3');
      await tester.tap(find.byKey(const Key('btn_tambah_ke_cart')));
      await tester.pumpAndSettle();

      // Verifikasi total = 3 x Rp 2.000 = Rp 6.000
      expect(find.textContaining('6.000'), findsOneWidget);

      // Pilih metode pembayaran: Cash
      await tester.tap(find.byKey(const Key('btn_metode_cash')));
      await tester.pumpAndSettle();

      // Selesaikan transaksi
      await tester.tap(find.byKey(const Key('btn_selesaikan_transaksi')));
      await tester.pumpAndSettle(const Duration(seconds: 4));

      // Verifikasi: dialog konfirmasi/struk muncul
      expect(find.byKey(const Key('struk_transaksi')), findsOneWidget);
    });

    // ══════════════════════════════════════════════════════════
    // IT-05: Stok berkurang otomatis setelah transaksi
    // ══════════════════════════════════════════════════════════
    testWidgets('IT-05: Stok produk berkurang setelah transaksi selesai',
        (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      await _doLogin(tester);

      // Tutup struk jika masih muncul
      final struk = find.byKey(const Key('struk_transaksi'));
      if (tester.any(struk)) {
        await tester.tap(find.byKey(const Key('btn_tutup_struk')));
        await tester.pumpAndSettle();
      }

      // Navigasi ke Manajemen Stok
      await _navigateTo(tester, 'nav_stok');
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Cari produk test di list
      expect(find.text(_testNama), findsOneWidget);

      // Stok semula 48, dijual 3 → sekarang harus 45
      expect(find.text('45'), findsOneWidget);
    });

    // ══════════════════════════════════════════════════════════
    // IT-06: Laporan harian ter-update setelah transaksi
    // ══════════════════════════════════════════════════════════
    testWidgets('IT-06: Laporan harian menampilkan pemasukan dari transaksi',
        (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      await _doLogin(tester);
      await _navigateTo(tester, 'nav_laporan');
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Halaman laporan tampil
      expect(find.text('Laporan Keuangan'), findsOneWidget);

      // Pilih periode Harian (default)
      final harian = find.byKey(const Key('filter_harian'));
      if (tester.any(harian)) {
        await tester.tap(harian);
        await tester.pumpAndSettle(const Duration(seconds: 2));
      }

      // Verifikasi: total pemasukan hari ini minimal Rp 6.000
      // (hasil transaksi IT-04)
      expect(find.textContaining('6.000'), findsOneWidget);

      // Verifikasi: jumlah transaksi > 0
      expect(find.byKey(const Key('label_jumlah_transaksi')), findsOneWidget);
    });
  });
}

// ─── Helper: Login tanpa mengulang kode ──────────────────────
Future<void> _doLogin(WidgetTester tester) async {
  // Jika sudah login (dashboard tampil), skip
  if (tester.any(find.text('Dashboard'))) return;

  final emailField = find.byKey(const Key('login_email_field'));
  if (!tester.any(emailField)) return;

  await tester.tap(emailField);
  await tester.enterText(emailField, _testEmail);

  final passField = find.byKey(const Key('login_password_field'));
  await tester.tap(passField);
  await tester.enterText(passField, _testPassword);

  await tester.tap(find.byKey(const Key('login_submit_button')));
  await tester.pumpAndSettle(const Duration(seconds: 5));
}

// ─── Helper: Navigasi via bottom nav ─────────────────────────
Future<void> _navigateTo(WidgetTester tester, String navKey) async {
  await tester.tap(find.byKey(Key(navKey)));
  await tester.pumpAndSettle(const Duration(seconds: 2));
}
