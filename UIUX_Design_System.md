# UI/UX Design System & Mapping Mockup
## Sistem Pembukuan, Pembelian, dan Manajemen Stok Warung Berbasis Mobile

Dokumen ini menjadi acuan saat membuat mockup hi-fi di Figma (berdasarkan wireframe low-fi yang sudah ada di proposal awal) dan acuan styling saat implementasi UI di Flutter (Fase C).

---

## 1. Prinsip Desain
Sesuai NFR Usability di SRS ("dapat digunakan tanpa pelatihan formal"), desain mengikuti prinsip:
- **Minim teks, banyak ikon** — istilah teknis dihindari, gunakan ikon yang familiar (uang, keranjang, kotak, profil).
- **Aksi utama selalu terlihat** — tombol "Scan Barcode" dan "Simpan Transaksi" harus prominent (warna kontras, ukuran besar, posisi mudah dijangkau jempol).
- **Konsistensi navigasi** — bottom navigation bar 5 menu tetap di semua halaman utama: Dashboard, Manajemen Stok, Transaksi, Laporan, Profil (sesuai wireframe proposal).
- **Feedback instan** — setiap aksi (simpan, hapus, error) memberi feedback visual (snackbar/toast) dalam < 1 detik.

---

## 2. Design Tokens

### 2.1 Palet Warna
| Token | Hex | Penggunaan |
|---|---|---|
| `primary` | #2E7D32 (hijau tua) | Tombol utama, AppBar, ikon aktif — asosiasi "uang/untung" |
| `primary-light` | #C8E6C9 | Background kartu dashboard, highlight ringan |
| `secondary` | #F9A825 (kuning/amber) | Aksi sekunder, badge "stok hampir habis" |
| `danger` | #D32F2F | Error, tombol hapus, badge "stok habis" |
| `neutral-dark` | #212121 | Teks utama |
| `neutral-grey` | #757575 | Teks sekunder, placeholder |
| `neutral-bg` | #FAFAFA | Background halaman |
| `surface` | #FFFFFF | Background kartu/komponen |

### 2.2 Tipografi
| Token | Font | Ukuran | Penggunaan |
|---|---|---|---|
| `heading-1` | Inter/Roboto, Bold | 22sp | Judul halaman (AppBar) |
| `heading-2` | Inter/Roboto, SemiBold | 18sp | Judul kartu/section |
| `body` | Inter/Roboto, Regular | 14sp | Teks umum |
| `caption` | Inter/Roboto, Regular | 12sp | Label kecil, timestamp |
| `numeric-highlight` | Inter/Roboto, Bold | 24sp | Angka penting (total keuntungan, total harga transaksi) |

### 2.3 Komponen Reusable
| Komponen | Spesifikasi |
|---|---|
| `SummaryCard` | Kartu dengan ikon + label + nilai (numeric-highlight); digunakan di Dashboard untuk total penjualan, pemasukan, pengeluaran, keuntungan |
| `ProductListItem` | List item dengan thumbnail/icon produk, nama, stok, harga jual, tombol edit |
| `StockBadge` | Badge warna `secondary` jika stok ≤ threshold (5), badge `danger` jika stok = 0 |
| `ScanButton` | Floating Action Button (FAB) dengan ikon barcode, warna `primary`, selalu ada di halaman Manajemen Stok & Transaksi |
| `PaymentMethodSelector` | Tiga opsi tombol (Cash/QRIS/Transfer) dalam bentuk segmented control |
| `PeriodFilterBar` | Bar horizontal dengan 4 tab: Harian/Mingguan/Bulanan/Tahunan, digunakan di Laporan Keuangan |
| `BottomNavBar` | 5 ikon: Dashboard, Manajemen Stok, Transaksi, Laporan, Profil |

---

## 3. Mapping Wireframe (Low-Fi, dari Proposal) → Mockup Hi-Fi (Figma)

### 3.1 Halaman Dashboard
- Wireframe proposal: 4 kotak ringkasan (ikon $, ikon kotak, ikon belanja, ikon profil) + grafik bar di bawah.
- Hi-fi: gunakan `SummaryCard` untuk total penjualan hari ini, total pemasukan, total pengeluaran, total keuntungan (4 kartu dalam grid 2x2, warna `primary-light`).
- Tambahkan section "Stok Hampir Habis" (US-15) berupa list horizontal scroll dengan `StockBadge`.
- Grafik tren keuntungan 7 hari terakhir (bar chart) — referensi ke US-13 untuk konsistensi data dengan halaman Laporan.

### 3.2 Halaman Manajemen Stok
- Wireframe proposal: search bar + list produk dengan ikon edit di kanan.
- Hi-fi: `ProductListItem` dengan `StockBadge` di setiap baris; FAB `ScanButton` di kanan bawah untuk "Tambah Stok" (US-04).
- Tambahkan modal/bottom sheet untuk form tambah stok hasil scan (US-04, US-05) dengan field: harga per dus, isi per dus, harga jual — tampilkan hasil hitung "Modal per unit" secara real-time saat user mengetik (live calculation, sesuai US-05 AC1).

### 3.3 Halaman Transaksi Penjualan
- Wireframe proposal: tombol scan besar di tengah + area kamera.
- Hi-fi: setelah scan, tampilkan daftar item transaksi (mirip keranjang belanja) dengan kemampuan edit jumlah unit (US-09 AC3); tampilkan `numeric-highlight` untuk total harga di bagian bawah (sticky); `PaymentMethodSelector` muncul saat user menekan "Lanjut ke Pembayaran".

### 3.4 Halaman Laporan Keuangan
- Wireframe proposal: 4 tombol filter periode + grafik garis (line chart) + ringkasan angka.
- Hi-fi: `PeriodFilterBar` di atas (sticky), diikuti 3 `SummaryCard` (Pemasukan, Modal, Keuntungan) dan grafik tren di bawahnya. Tampilkan empty-state ilustrasi sederhana untuk kasus US-13 AC3 (belum ada transaksi).

### 3.5 Halaman Profil
- Wireframe proposal: avatar + info pemilik + menu pengaturan + logout.
- Hi-fi: form edit (nama, nama warung, kontak) dengan tombol "Simpan" yang disabled jika tidak ada perubahan; tombol "Logout" warna `danger` dengan dialog konfirmasi.

---

## 4. Aksesibilitas & Responsivitas
- Kontras warna teks terhadap background minimal rasio 4.5:1 (WCAG AA) — palet di atas sudah memenuhi (hijau tua di atas putih, dsb).
- Ukuran target tap minimal 48x48 dp untuk semua tombol/ikon interaktif (terutama tombol scan dan simpan, sering ditekan dengan satu tangan).
- Desain diuji minimal pada 2 ukuran layar: small (≤ 5.5") dan large (≥ 6.5") sesuai NFR Compatibility.

---

## 5. Rencana Kerja di Figma
1. Buat 1 file Figma dengan halaman terpisah per fitur: `Dashboard`, `Manajemen Stok`, `Transaksi`, `Laporan`, `Profil`, `Login`.
2. Buat page khusus `Design System` berisi komponen reusable di atas (palet warna, tipografi, komponen) sebagai master component agar konsisten.
3. Setiap mockup hi-fi harus mereferensikan komponen dari page `Design System` (gunakan Figma Components/Variants, bukan duplikasi manual).
4. Setelah selesai, link Figma dicantumkan di README repo dan laporan akhir.
