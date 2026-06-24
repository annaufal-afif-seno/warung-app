# Fase C — Urutan Running & Panduan Setup

## Bagian 1/3 yang Sudah Dikerjakan

### File yang Dibuat

| File | Keterangan |
|------|-----------|
| `pubspec.yaml` | Semua dependencies (Firebase, mobile_scanner, provider, fl_chart) |
| `.github/workflows/ci.yml` | CI/CD GitHub Actions |
| `lib/models/user_model.dart` | Model User |
| `lib/models/produk_model.dart` | Model Produk (dengan stok & margin) |
| `lib/models/detail_transaksi_model.dart` | Model detail item transaksi |
| `lib/models/transaksi_model.dart` | Model Transaksi + enum MetodePembayaran |
| `lib/models/pembelian_model.dart` | Model Pembelian/Restock |
| `lib/models/laporan_keuangan_model.dart` | Model agregat laporan |
| `lib/services/auth_service.dart` | Login, Register, Logout via Firebase Auth |
| `lib/services/firestore_service.dart` | Semua operasi Firestore (CRUD produk, transaksi atomik, laporan) |
| `lib/utils/business_logic.dart` | Pure functions (hitungModalPerUnit, dll) |
| `test/business_logic_test.dart` | Unit test lengkap untuk business logic |
| `README.md` | Panduan repo |

---

## Urutan Running (Setelah Semua Fase C Selesai)

### Step 1 — Clone & Install

```bash
git clone https://github.com/<org>/warung-app.git
cd warung-app
flutter pub get
```

### Step 2 — Setup Firebase

1. Buka [https://console.firebase.google.com](https://console.firebase.google.com)
2. Buat project baru → nama: `warung-app`
3. **Authentication** → Sign-in method → aktifkan **Email/Password**
4. **Firestore Database** → Create database → mode **Production**
5. **Project Settings** → Add app → Android:
   - Package name: `com.warungapp.app`
   - Download `google-services.json`
   - Letakkan di `android/app/google-services.json`

### Step 3 — Firestore Security Rules

Buka Firestore → Rules → paste ini:

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // User hanya bisa akses data miliknya sendiri
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    match /produk/{docId} {
      allow read, write: if request.auth != null
        && resource.data.idUser == request.auth.uid;
      allow create: if request.auth != null
        && request.resource.data.idUser == request.auth.uid;
    }
    match /transaksi/{docId} {
      allow read, write: if request.auth != null
        && resource.data.idUser == request.auth.uid;
      allow create: if request.auth != null
        && request.resource.data.idUser == request.auth.uid;
    }
    match /pembelian/{docId} {
      allow read, write: if request.auth != null
        && resource.data.idUser == request.auth.uid;
      allow create: if request.auth != null
        && request.resource.data.idUser == request.auth.uid;
    }
  }
}
```

### Step 4 — Run App

```bash
# Pastikan emulator/device terhubung
flutter devices

# Jalankan
flutter run
```

### Step 5 — Run Tests

```bash
flutter test
# Atau dengan coverage:
flutter test --coverage
```

### Step 6 — Build APK (untuk demo)

```bash
flutter build apk --debug
# APK ada di: build/app/outputs/flutter-apk/app-debug.apk
```

---

## Bagian 2/3 yang Sudah Dikerjakan

### File yang Dibuat

| File | Keterangan |
|------|-----------|
| `lib/utils/app_theme.dart` | Design tokens (AppColors, AppTextStyles) + ThemeData sesuai UIUX_Design_System.md §2 |
| `lib/providers/auth_provider.dart` | State management autentikasi (login, register, logout, auto-listen authStateChanges) |
| `lib/providers/produk_provider.dart` | State management produk/stok (stream Firestore, search, tambahStok, updateProduk, hapusProduk) |
| `lib/providers/dashboard_provider.dart` | State management data agregat Dashboard (F2 §5.5.d) |
| `lib/widgets/summary_card.dart` | Komponen `SummaryCard` reusable |
| `lib/widgets/stock_badge.dart` | Komponen `StockBadge` reusable (warning/danger threshold) |
| `lib/widgets/product_list_item.dart` | Komponen `ProductListItem` reusable |
| `lib/widgets/app_bottom_nav_bar.dart` | Komponen `BottomNavBar` 5 menu |
| `lib/screens/auth/login_screen.dart` | F1 — Login Screen (email/password, validasi, link ke Register) |
| `lib/screens/auth/register_screen.dart` | F1 — Register Screen (buat akun pemilik warung baru) |
| `lib/screens/auth_gate.dart` | Routing otomatis: belum login → Login, sudah login → Home |
| `lib/screens/dashboard/dashboard_screen.dart` | F2 — Dashboard dengan data real (4 SummaryCard grid 2x2 + list horizontal stok hampir habis) |
| `lib/screens/stok/manajemen_stok_screen.dart` | F3 — Manajemen Stok: search bar, list produk, FAB scan (placeholder input manual) |
| `lib/screens/stok/tambah_stok_form.dart` | F3+F4 — Form Tambah Stok dengan live calculation "Modal per Unit" (US-05 AC1) |
| `lib/screens/stok/edit_produk_form.dart` | Edit nama/harga jual produk + hapus produk (dengan dialog konfirmasi) |
| `lib/screens/transaksi/transaksi_screen.dart` | Placeholder navigasi F5/F6/F7 (diisi penuh di Bagian 3/3) |
| `lib/screens/laporan/laporan_screen.dart` | Placeholder navigasi F8 (diisi penuh di Bagian 3/3) |
| `lib/screens/profil/profil_screen.dart` | F9 — Tampilan profil dasar + Logout berfungsi (form edit lengkap di Bagian 3/3) |
| `lib/screens/home_screen.dart` | Kontainer utama: `IndexedStack` 5 tab + `AppBottomNavBar` |
| `lib/main.dart` | Entry point: `Firebase.initializeApp()`, `MultiProvider`, `MaterialApp` dengan `AppTheme.light` |

### Catatan Penting untuk Bagian 3/3
- FAB di `ManajemenStokScreen` memanggil `_inputBarcodeManual()` (dialog input teks) sebagai placeholder.
  Saat integrasi `mobile_scanner`, ganti dengan hasil scan kamera lalu panggil `_handleBarcodeResult(barcode)` —
  alur cek produk lama/baru dan navigasi ke `TambahStokForm` sudah siap.
- `AuthProvider`, `ProdukProvider`, `DashboardProvider` sudah didaftarkan via `MultiProvider` di `main.dart`.
- `ProdukProvider.getProdukByBarcode(barcode, idUser)` siap dipakai di alur Transaksi (cek stok sebelum checkout).
- `FirestoreService.buatTransaksi(...)` dan `FirestoreService.getLaporan(...)` (bagian 1/3) tinggal dihubungkan ke UI.

---

## Apa yang Dikerjakan di Bagian 3/3

- `lib/screens/transaksi/` — Scan Barcode + Kasir (hubungkan ke `FirestoreService.buatTransaksi`)
- `lib/screens/laporan/` — Chart & filter periode (hubungkan ke `FirestoreService.getLaporan`, gunakan `fl_chart`)
- `lib/screens/profil/` — Edit profil lengkap (form nama/namaWarung/telepon)
- Integrasi `mobile_scanner` ke `ManajemenStokScreen` dan `TransaksiScreen`
- Firestore Security Rules finalisasi (pasang ke Firebase Console)
- Setup `android/app/google-services.json` & build APK demo

---

## Bagian 3/3 — SELESAI ✅

### File yang Dibuat / Diperbarui

| File | Keterangan |
|------|-----------|
| `lib/providers/transaksi_provider.dart` | State management keranjang belanja + proses checkout atomik |
| `lib/providers/laporan_provider.dart` | State management filter periode + trigger getLaporan |
| `lib/screens/transaksi/transaksi_screen.dart` | F5/F6/F7 — kasir lengkap: Tab Scan (MobileScanner) + Tab Keranjang + Checkout + Struk dialog |
| `lib/screens/laporan/laporan_screen.dart` | F8 — grafik batang fl_chart, filter periode, navigasi maju-mundur, statistik ringkasan |
| `lib/screens/profil/profil_screen.dart` | F9 — tampil profil + form edit nama/namaWarung/telepon + logout |
| `lib/screens/stok/manajemen_stok_screen.dart` | F3/F4 — integrasi mobile_scanner (full-screen scanner page) + FAB fallback input manual |
| `lib/main.dart` | Tambah `LaporanProvider` ke `MultiProvider` + `initializeDateFormatting('id_ID')` |
| `pubspec.yaml` | Dependencies lengkap: firebase, provider, mobile_scanner, fl_chart, intl |
| `README.md` | Panduan lengkap: setup Firebase, Firestore rules, cara run, struktur folder |

### Catatan Integrasi Penting
- `TransaksiProvider` di-create per-screen (bukan di `main.dart`) → keranjang otomatis reset saat tab dibuka ulang.
- `LaporanScreen` membutuhkan `intl` package dan `initializeDateFormatting('id_ID')` di `main()` agar format tanggal Bahasa Indonesia berjalan.
- `ManajemenStokScreen` kini punya dua FAB: FAB utama (scan kamera) + FAB kecil (input manual) sebagai fallback jika kamera tidak tersedia/izin ditolak.
- `TransaksiScreen` mengambil daftar produk dari `ProdukProvider.produkList` yang sudah di-stream dari Firestore — pastikan `ProdukProvider.listenProduk(idUser)` sudah dipanggil sebelum tab Transaksi dibuka (sudah dilakukan di `ManajemenStokScreen.didChangeDependencies` dan `DashboardProvider`).
