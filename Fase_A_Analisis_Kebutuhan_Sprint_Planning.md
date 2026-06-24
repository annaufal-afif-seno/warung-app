# FASE A — Analisis Kebutuhan & Sprint Planning (Detail Pengerjaan)

Proyek: Sistem Pembukuan, Pembelian & Manajemen Stok Warung (Mobile)
Tim: Annaufal Afif Seno (2023071054) — Lead Dev/Architect, Qurratu Farrasah Siregar (2024071017) — Scrum Master, Karine Olivia Permana (2023071025) — Product Owner

Durasi: Minggu 1 (7 hari kerja). Dokumen ini adalah hasil jadi yang bisa langsung dipakai/disesuaikan, sekaligus urutan kerja harian agar tim tahu siapa-ngerjain-apa-kapan.

---

## URUTAN RUNNING (Hari per Hari)

| Hari | Aktivitas | PIC | Output |
|---|---|---|---|
| H1 | Workshop identifikasi masalah & kebutuhan pengguna + tentukan stakeholder/aktor (lihat Bagian 1 & 2) | Semua tim (brainstorm bersama) | Daftar pain point, daftar stakeholder & aktor |
| H2 | Draft Project Charter + Studi Kelayakan (lihat Bagian 3 & 4) | Karine (PO) tulis draft, Ansen & Qurratu review | `project_charter.pdf`, `studi_kelayakan.pdf` (draft) |
| H3 | Breakdown kebutuhan → Epic → User Story (lihat Bagian 5) | Semua tim, dipandu Karine | Daftar epic + user story mentah |
| H4 | Prioritization (MoSCoW) + estimasi story point (Planning Poker) → finalisasi Product Backlog (Bagian 5) | Semua tim, difasilitasi Qurratu | `product_backlog.xlsx` final |
| H5 | Sprint Planning Meeting: pilih item untuk Sprint 1, hitung kapasitas tim, breakdown jadi task teknis (Bagian 6) | Semua tim, dipimpin Qurratu | `sprint_backlog_sprint1.xlsx` |
| H6 | Setup tools kolaborasi: board (GitHub Projects/Trello), repo kosong + README awal, channel komunikasi | Ansen (repo setup), Qurratu (board) | Repo GitHub awal, board siap |
| H7 | Review akhir semua dokumen Fase A, finalisasi & export ke PDF/Excel, briefing transisi ke Fase B | Semua tim | Semua deliverable Fase A siap kumpul |

Catatan urutan: Bagian 1–2 **harus** selesai dulu karena jadi dasar penulisan Project Charter (Bagian 3) dan Studi Kelayakan (Bagian 4). Product Backlog (Bagian 5) tidak bisa disusun sebelum daftar kebutuhan & fitur (F1–F9 dari proposal) dipetakan ke stakeholder/aktor di Bagian 1–2. Sprint Backlog (Bagian 6) baru bisa difinalisasi setelah Product Backlog selesai diprioritaskan.

---

## 1. Identifikasi Permasalahan & Kebutuhan Pengguna

### Pain Point (dari proposal, Latar Belakang)
| ID | Pain Point | Dampak |
|---|---|---|
| PP-01 | Pencatatan transaksi manual (buku tulis) | Rawan kesalahan pencatatan |
| PP-02 | Tidak ada pemantauan stok real-time | Kehabisan stok tanpa disadari, atau over-stock |
| PP-03 | Tidak ada laporan keuangan terstruktur | Pemilik tidak tahu untung/rugi usaha |
| PP-04 | Tidak ada perhitungan modal per unit otomatis | Salah hitung margin saat beli dalam jumlah besar (dus/karton) |
| PP-05 | Tidak ada rangkuman kondisi usaha cepat | Pemilik harus cek manual satu per satu |

### Kebutuhan Pengguna → Pemetaan ke Fitur
| Kebutuhan | Fitur Terkait (proposal) |
|---|---|
| Mencatat transaksi dengan mudah & cepat | F4, F5, F6 (Scan barcode, Transaksi, Pengurangan stok otomatis) |
| Mengelola stok otomatis | F3, F4, F6 |
| Mengelola pembelian dari supplier sebagai modal | F3 (Manajemen Produk — alur tambah stok) |
| Laporan untung/rugi | F7, F8 |
| Ringkasan cepat kondisi usaha | F2 (Dashboard) |
| Keamanan akses & identitas akun | F1, F9 |

---

## 2. Stakeholder & Aktor Sistem

### Aktor (di dalam sistem — sesuai Use Case Diagram proposal)
| Aktor | Peran |
|---|---|
| **Pemilik Warung** (primary actor) | Operator utama: login, dashboard, kelola stok, transaksi, pembukuan, profil |
| **Pembeli** (secondary actor) | Terlibat saat transaksi (memilih metode pembayaran: cash/QRIS/transfer), tidak punya akun di sistem |

### Stakeholder (di luar sistem, untuk konteks proyek tugas)
| Stakeholder | Kepentingan |
|---|---|
| Tim Developer (Ansen, Qurratu, Karine) | Membangun & memelihara sistem sesuai backlog |
| Dosen / Evaluator | Menilai kesesuaian proses SDLC, kualitas dokumen, dan hasil implementasi |
| Pemilik Warung (persona/end-user) | Target pengguna akhir — kebutuhan dijadikan acuan validasi acceptance criteria |

---

## 3. Project Charter

| Komponen | Isi |
|---|---|
| **Nama Proyek** | Sistem Pembukuan, Pembelian, dan Manajemen Stok Warung Berbasis Mobile |
| **Latar Belakang** | Usaha warung kecil masih mencatat transaksi, pembelian, dan stok secara manual sehingga rawan kesalahan, sulit memantau stok, dan tidak punya laporan keuangan yang jelas. |
| **Tujuan Proyek** | Membangun aplikasi mobile yang membantu pemilik warung mencatat transaksi penjualan, mengelola stok otomatis, mengelola pembelian dari supplier, menyediakan laporan keuangan per periode, dan dashboard ringkasan usaha. |
| **Scope (In)** | 5 fitur utama: Dashboard, Manajemen Stok Produk, Transaksi Penjualan, Pembukuan & Laporan Keuangan, Profil Pengguna — sesuai F1–F9. Platform Android. |
| **Scope (Out)** | Multi-cabang/multi-toko, integrasi pembayaran nyata (QRIS/transfer hanya disimulasikan), manajemen karyawan/multi-role, integrasi supplier eksternal otomatis. |
| **Stakeholder** | Lihat Bagian 2 |
| **Tim & Peran** | Ansen — Lead Developer/Architect (arsitektur, repo, CI/CD, security); Qurratu — Scrum Master (fasilitasi sprint, board, dokumentasi proses); Karine — Product Owner (backlog, acceptance criteria, validasi kebutuhan pengguna) |
| **Timeline** | 7 minggu total — Minggu 1: Fase A; Minggu 2: Fase B; Minggu 3–5: Fase C; Minggu 5–6: Fase D; Minggu 7: Finalisasi |
| **Risiko Awal & Mitigasi** | (1) Anggota belum familiar Flutter/Firebase → mitigasi: alokasikan H6–H7 minggu 1 untuk tutorial singkat & setup bersama. (2) Scope creep (fitur tambahan di luar F1–F9) → mitigasi: PO menolak request di luar backlog yang sudah disepakati, dicatat sebagai "future work". (3) Integrasi scan barcode bermasalah di device tertentu → mitigasi: sediakan fallback input manual kode produk. |
| **Kriteria Sukses** | Semua F1–F9 berfungsi sesuai acceptance criteria; CI/CD aktif; dokumen lengkap (SRS, UML, backlog, testing, threat modeling); demo end-to-end berhasil tanpa crash. |

---

## 4. Studi Kelayakan Awal

| Aspek | Analisis | Kesimpulan |
|---|---|---|
| **Kelayakan Teknis** | Flutter (cross-platform, paket `mobile_scanner` untuk barcode) + Firebase (Auth, Firestore) tersedia gratis untuk skala kecil, dokumentasi luas, cocok untuk tim mahasiswa dengan deadline ketat. | Layak |
| **Kelayakan Operasional** | UI dirancang sederhana (5 menu utama via bottom navigation), sesuai kebutuhan pemilik warung yang non-tech-savvy (NFR Usability). | Layak |
| **Kelayakan Jadwal** | 5 fitur inti + non-fungsional dapat diselesaikan dalam 4 minggu implementasi (Fase C) jika dipecah dalam 3 sprint dengan prioritas MoSCoW yang jelas. | Layak dengan syarat: scope tidak bertambah |
| **Kelayakan Ekonomi** | Biaya = Rp0 (semua tools/layanan dalam tier gratis: Firebase Spark plan, GitHub gratis, Figma gratis). | Layak |
| **Risiko Kelayakan** | Ketergantungan pada koneksi internet (Firestore real-time) — perlu disebutkan sebagai batasan non-fungsional, bukan blocker. | Diterima sebagai batasan |

**Kesimpulan umum:** Proyek layak dilanjutkan dengan pendekatan Agile/Scrum, MVP berfokus pada 5 fitur utama (F1–F9), tanpa fitur tambahan di luar scope.

---

## 5. Product Backlog

Format: `ID | Epic | User Story (sebagai ... saya ingin ... agar ...) | Priority (MoSCoW) | Story Point (Fibonacci: 1,2,3,5,8)`

| ID | Epic | User Story | Priority | SP |
|---|---|---|---|---|
| US-01 | EP-07 Infrastruktur | Sebagai tim developer, saya ingin repo GitHub + branching strategy + CI/CD siap agar kolaborasi kode terstruktur dari awal | Must | 3 |
| US-02 | EP-01 Autentikasi | Sebagai pemilik warung, saya ingin login dengan email & password agar data usaha saya aman dan personal | Must | 3 |
| US-03 | EP-01 Autentikasi | Sebagai pemilik warung, saya ingin logout dari aplikasi agar akun saya aman saat tidak digunakan | Must | 1 |
| US-04 | EP-03 Manajemen Stok | Sebagai pemilik warung, saya ingin menambahkan produk baru dengan scan barcode agar input data lebih cepat dan akurat | Must | 5 |
| US-05 | EP-03 Manajemen Stok | Sebagai pemilik warung, saya ingin sistem menghitung modal per unit otomatis dari harga dus & isi per dus agar saya tidak salah hitung margin | Must | 5 |
| US-06 | EP-03 Manajemen Stok | Sebagai pemilik warung, saya ingin melihat daftar produk beserta stoknya agar saya tahu kondisi persediaan | Must | 3 |
| US-07 | EP-03 Manajemen Stok | Sebagai pemilik warung, saya ingin mengedit & menghapus produk agar data tetap akurat | Should | 3 |
| US-08 | EP-04 Transaksi | Sebagai pemilik warung, saya ingin memindai barcode produk saat transaksi agar harga jual otomatis muncul | Must | 5 |
| US-09 | EP-04 Transaksi | Sebagai pemilik warung, saya ingin sistem menghitung total harga otomatis berdasarkan jumlah unit agar transaksi lebih cepat & akurat | Must | 5 |
| US-10 | EP-04 Transaksi | Sebagai pemilik warung, saya ingin memilih metode pembayaran (cash/QRIS/transfer) agar pencatatan sesuai cara bayar pembeli | Should | 2 |
| US-11 | EP-04 Transaksi | Sebagai pemilik warung, saya ingin stok produk berkurang otomatis setelah transaksi disimpan agar saya tidak perlu update manual | Must | 5 |
| US-12 | EP-05 Pembukuan | Sebagai pemilik warung, saya ingin setiap transaksi tercatat ke pembukuan otomatis agar saya punya riwayat lengkap | Must | 5 |
| US-13 | EP-05 Laporan | Sebagai pemilik warung, saya ingin melihat laporan keuntungan harian/mingguan/bulanan/tahunan agar saya tahu performa usaha per periode | Must | 8 |
| US-14 | EP-02 Dashboard | Sebagai pemilik warung, saya ingin melihat ringkasan penjualan, pengeluaran, dan keuntungan hari ini di dashboard agar saya dapat info cepat | Must | 5 |
| US-15 | EP-02 Dashboard | Sebagai pemilik warung, saya ingin melihat daftar produk yang stoknya hampir habis di dashboard agar saya bisa segera restock | Should | 3 |
| US-16 | EP-06 Profil | Sebagai pemilik warung, saya ingin melihat & mengubah data profil (nama, nama warung, kontak) agar informasi akun selalu update | Should | 2 |
| US-17 | EP-07 Infrastruktur | Sebagai tim developer, saya ingin Firestore Security Rules diterapkan agar data transaksi & pembukuan hanya dapat diakses pemiliknya | Must | 3 |
| US-18 | EP-07 Infrastruktur | Sebagai tim developer, saya ingin unit test untuk fungsi perhitungan (modal, total harga, keuntungan, laporan) agar logika bisnis terjamin benar | Must | 3 |

**Total Story Point seluruh backlog:** 61 SP

---

## 6. Sprint Backlog — Sprint 1 (Minggu 2–3)

**Kapasitas tim:** 3 orang x 2 minggu ≈ 22–25 SP (estimasi awal, akan dikalibrasi setelah Sprint 1 selesai — velocity actual jadi acuan Sprint 2 & 3).

**Sprint Goal:** "Tim memiliki fondasi teknis (repo, CI/CD, security rules) serta fitur Login, Dashboard skeleton, dan Manajemen Produk dasar (CRUD + scan barcode + hitung modal otomatis) yang berjalan."

| ID | User Story | SP | PIC | Breakdown Task Teknis |
|---|---|---|---|---|
| US-01 | Setup repo, branching, CI/CD | 3 | Ansen | Init repo Flutter, buat `develop`/`main`, setup GitHub Actions (`flutter analyze` + `flutter test`), buat `README.md` |
| US-02 | Login email/password | 3 | Qurratu | Setup Firebase Auth, buat screen login, validasi input, error handling |
| US-03 | Logout | 1 | Qurratu | Tombol logout di Profil/AppBar, clear session |
| US-04 | Tambah produk via scan barcode | 5 | Ansen | Integrasi `mobile_scanner`, form input produk, simpan ke Firestore |
| US-05 | Hitung modal per unit otomatis | 5 | Karine | Implementasi fungsi `hitungModalPerUnit()` + unit test, integrasi ke form tambah stok |
| US-06 | Daftar produk & stok | 3 | Karine | Screen list produk (StreamBuilder dari Firestore), tampilkan nama, stok, harga |
| US-14 | Dashboard skeleton | 5 | Ansen + Qurratu | Layout dashboard sesuai mockup (kartu ringkasan + chart placeholder), hubungkan ke data dummy dulu |
| US-17 | Firestore Security Rules dasar | 2 | Ansen | Rules: hanya user terautentikasi yang bisa read/write data miliknya |

**Total SP Sprint 1:** 27 (sedikit di atas estimasi kapasitas — disengaja sebagai buffer/stretch goal; jika H5 sprint planning menunjukkan tim kurang yakin, US-06 atau US-17 boleh dipindah ke Sprint 2)

### Definition of Done (DoD) Sprint 1
- Kode sudah di-merge ke `develop` melalui PR dengan minimal 1 review
- CI (analyze + test) hijau
- Fitur sudah dicoba manual sesuai acceptance criteria terkait (akan didetailkan di Fase B)
- Tidak ada bug blocking yang diketahui

---

## Output Akhir Fase A (Checklist)
- [ ] `project_charter.pdf` (Bagian 3)
- [ ] `studi_kelayakan.pdf` (Bagian 4)
- [ ] `product_backlog.xlsx` (Bagian 5 — 18 item, 61 SP)
- [ ] `sprint_backlog_sprint1.xlsx` (Bagian 6 — 8 item, 27 SP, dengan breakdown task & PIC)
- [ ] Board kolaborasi (GitHub Projects/Trello) sudah berisi semua item Sprint 1
- [ ] Repo GitHub sudah ada (boleh masih kosong/skeleton, isi penuh dimulai Fase C)
