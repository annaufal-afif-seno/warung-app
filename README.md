# Warung App 🏪

Sistem Pembukuan, Pembelian & Manajemen Stok Warung berbasis Android (Flutter + Firebase).

**Tim:** Annaufal Afif Seno (2023071054) · Qurratu Farrasah Siregar (2024071017) · Karine Olivia Permana (2023071025)

---

## Fitur (F1–F9)

| ID | Fitur | Status |
|----|-------|--------|
| F1 | Login & Register (Firebase Auth email/password) | ✅ |
| F2 | Dashboard — ringkasan penjualan harian + stok hampir habis | ✅ |
| F3 | Manajemen Produk — CRUD produk di Firestore | ✅ |
| F4 | Scan Barcode kamera (`mobile_scanner`) + input manual | ✅ |
| F5 | Transaksi Penjualan — kasir multi-item, scan barcode | ✅ |
| F6 | Pengurangan Stok Otomatis — Firestore atomic transaction | ✅ |
| F7 | Pembukuan — setiap transaksi tersimpan dengan detail keuntungan | ✅ |
| F8 | Laporan Keuangan — filter harian/mingguan/bulanan/tahunan + grafik | ✅ |
| F9 | Profil Pengguna — tampil & edit nama, nama warung, telepon | ✅ |

---

## Tech Stack

- **Frontend:** Flutter (Dart) — single codebase Android
- **Backend/DB:** Firebase (Firestore + Auth)
- **State Management:** Provider (`ChangeNotifier`)
- **Scanner:** `mobile_scanner` v3.5
- **Chart:** `fl_chart` v0.66
- **CI/CD:** GitHub Actions (`.github/workflows/ci.yml`)

---

## Cara Menjalankan

### 1. Clone & Install
```bash
git clone https://github.com/<org>/warung-app.git
cd warung-app
flutter pub get
```

### 2. Setup Firebase
1. Buat project di [console.firebase.google.com](https://console.firebase.google.com) → nama: `warung-app`
2. **Authentication** → Sign-in method → aktifkan **Email/Password**
3. **Firestore Database** → Create database → mode **Production**
4. **Project Settings** → Add app → Android → package: `com.warungapp.app`
5. Download `google-services.json` → letakkan di `android/app/google-services.json`

### 3. Firestore Security Rules
Buka Firestore Console → Rules → paste:
```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
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

### 4. Jalankan
```bash
flutter devices   # pastikan emulator/device aktif
flutter run
```

### 5. Build APK Debug
```bash
flutter build apk --debug
# APK: build/app/outputs/flutter-apk/app-debug.apk
```

### 6. Jalankan Unit Test
```bash
flutter test
```

---

## Struktur Folder

```
lib/
├── main.dart                      # Entry point
├── models/
│   ├── user_model.dart
│   ├── produk_model.dart
│   ├── transaksi_model.dart       # + enum MetodePembayaran
│   ├── detail_transaksi_model.dart
│   ├── pembelian_model.dart
│   └── laporan_keuangan_model.dart
├── services/
│   ├── auth_service.dart          # Firebase Auth
│   └── firestore_service.dart     # Semua operasi Firestore
├── providers/
│   ├── auth_provider.dart
│   ├── produk_provider.dart
│   ├── dashboard_provider.dart
│   ├── transaksi_provider.dart    # State keranjang & checkout
│   └── laporan_provider.dart      # State filter & data laporan
├── screens/
│   ├── auth_gate.dart
│   ├── home_screen.dart
│   ├── auth/
│   │   ├── login_screen.dart
│   │   └── register_screen.dart
│   ├── dashboard/dashboard_screen.dart
│   ├── stok/
│   │   ├── manajemen_stok_screen.dart  # + scanner kamera
│   │   ├── tambah_stok_form.dart
│   │   └── edit_produk_form.dart
│   ├── transaksi/transaksi_screen.dart # Kasir + scan + struk
│   ├── laporan/laporan_screen.dart     # fl_chart + filter periode
│   └── profil/profil_screen.dart      # Edit profil lengkap
├── widgets/
│   ├── app_bottom_nav_bar.dart
│   ├── product_list_item.dart
│   ├── stock_badge.dart
│   └── summary_card.dart
└── utils/
    ├── app_theme.dart
    └── business_logic.dart        # Pure functions (unit-tested)

test/
└── business_logic_test.dart

.github/workflows/ci.yml          # GitHub Actions CI
```

---

## Anggota Tim & Peran

| Nama | NIM | Peran Scrum |
|------|-----|-------------|
| Annaufal Afif Seno | 2023071054 | Lead Developer / Architect |
| Qurratu Farrasah Siregar | 2024071017 | Scrum Master |
| Karine Olivia Permana | 2023071025 | Product Owner |

---

## Branching Strategy (GitFlow Ringan)

- `main` — versi stabil, hanya merge via PR yang lolos CI + review
- `develop` — integrasi fitur
- `feature/<nama-fitur>` — contoh: `feature/laporan-keuangan`

CI wajib hijau (`flutter analyze` + `flutter test`) sebelum merge ke `develop` atau `main`.
