# FASE B — Requirements Engineering & System Design (Overview & Urutan Running)

Durasi: Minggu 2 (7 hari kerja). Output Fase B menjadi acuan utama untuk Fase C (implementasi) — semua kode harus traceable ke SRS, user story, dan diagram di fase ini.

---

## URUTAN RUNNING (Hari per Hari)

| Hari | Aktivitas | PIC | Output |
|---|---|---|---|
| H1 | Tulis SRS Bagian 1–2 (Pendahuluan & Deskripsi Umum), berbasis Project Charter & Studi Kelayakan Fase A | Karine (draft), Ansen & Qurratu review | `SRS_v1.md` (bagian 1–2) |
| H2 | Tulis SRS Bagian 3.1 (Kebutuhan Fungsional F1–F9 detail: input/proses/output) dan 3.2 (Non-Fungsional measurable) | Ansen (3.1 — sisi teknis), Karine (3.2 — sisi pengguna) | `SRS_v1.md` (bagian 3) lengkap |
| H3 | Tulis User Story + Acceptance Criteria (Gherkin) untuk seluruh 18 item Product Backlog | Karine (PO) tulis, Ansen & Qurratu validasi terhadap SRS | `User_Stories_Acceptance_Criteria.md` |
| H4 | Buat/refine Use Case Diagram berdasarkan SRS fungsional final | Qurratu (draft), Ansen review relasi include/extend | `UML_UseCase.mermaid` |
| H5 | Buat Class Diagram — derive entitas dari SRS & user story (data apa yang disimpan/dimanipulasi) | Ansen (Lead Dev/Architect) | `UML_Class.mermaid` |
| H6 | Buat Activity Diagram (Transaksi Penjualan & Tambah Stok) + Diagram Arsitektur Sistem — keduanya butuh Class Diagram sebagai acuan entitas | Ansen + Qurratu | `UML_Activity_Transaksi.mermaid`, `UML_Activity_TambahStok.mermaid`, `Arsitektur_Sistem.mermaid` |
| H7 | Desain UI/UX (design system + mapping wireframe→mockup hi-fi di Figma), lalu review keseluruhan dokumen Fase B & finalisasi SRS v1 | Karine (UI/UX), semua tim (review) | `UIUX_Design_System.md`, Figma link, `SRS_v1.md` final |

### Mengapa urutan ini (dependency logic)
1. **SRS dulu (H1–H2)** — semua dokumen lain (user story, UML, arsitektur, UI/UX) harus konsisten dengan definisi kebutuhan fungsional/non-fungsional. Tanpa SRS final, AC dan diagram berisiko tidak sinkron.
2. **User Story + AC (H3)** sebelum UML — AC menjelaskan *behavior* detail per fitur, yang menjadi sumber alur untuk Use Case dan Activity Diagram.
3. **Use Case Diagram (H4)** sebelum Class Diagram — Use Case menunjukkan *apa* yang dilakukan aktor, baru kemudian Class Diagram menjawab *data apa* yang dibutuhkan untuk mendukung use case tersebut.
4. **Class Diagram (H5)** sebelum Activity Diagram & Arsitektur — Activity Diagram dan Arsitektur perlu merujuk ke entitas data yang sudah didefinisikan (mis. "update stok Produk", "simpan DetailTransaksi").
5. **UI/UX (H7) di akhir** — desain visual harus mengikuti struktur fungsional & data yang sudah final, supaya tidak ada mockup yang menggambarkan field/alur yang ternyata tidak ada di SRS/Class Diagram.

---

## Daftar Output Fase B (Checklist)
- [ ] `SRS_v1.md` — Software Requirements Specification lengkap
- [ ] `User_Stories_Acceptance_Criteria.md` — 18 user story dengan AC format Gherkin
- [ ] `UML_UseCase.mermaid` — Use Case Diagram (Pemilik Warung, Pembeli)
- [ ] `UML_Class.mermaid` — Class Diagram (User, Produk, Pembelian, Transaksi, DetailTransaksi, Laporan)
- [ ] `UML_Activity_Transaksi.mermaid` — Activity Diagram alur Transaksi Penjualan
- [ ] `UML_Activity_TambahStok.mermaid` — Activity Diagram alur Tambah Stok Produk
- [ ] `Arsitektur_Sistem.mermaid` — Diagram arsitektur (Flutter ⇄ Firebase)
- [ ] `UIUX_Design_System.md` — design system + mapping mockup hi-fi
- [ ] Link Figma (mockup hi-fi seluruh halaman)

Semua file di atas dibuat sebagai dokumen terpisah pada langkah selanjutnya.
