# AGENTS.md — Aturan Kerja Agen AI (KosFinder)

## 1. Konteks Proyek & Dokumen Acuan
KosFinder adalah aplikasi mobile Android (Flutter + Supabase) untuk mempertemukan pencari kos dan pemilik kos.
Selalu rujuk dokumen berikut sebagai sumber kebenaran:
- `docs/PRD.md` — masalah, pengguna, scope v1, NFR, user story (`US01`–`US06`), dan acceptance criteria.
- `docs/ARCHITECTURE.md` — struktur komponen (`Screen - Provider - Repository - Supabase`), skema database, konfigurasi `--dart-define`, dan daftar package.
- `docs/TASKS.md` — daftar task berurutan (`T01`, `T02`, ...), file yang boleh diubah, dan cara uji.

## 2. Cara Kerja Agen
- **Satu task per permintaan**: kerjakan hanya satu task yang diminta dari `docs/TASKS.md`.
- **Dilarang mengubah file di luar task**: hanya buat atau ubah file yang tercantum pada task tersebut.
- **Rencanakan dulu untuk perubahan besar**: ajukan rencana singkat dan tunggu persetujuan SE sebelum mengubah kode lintas layar/modul.
- **Pilih solusi paling sederhana (YAGNI)**: jangan menambah fitur, abstraksi, atau komponen yang tidak diminta di `docs/PRD.md`.
- **Dilarang menambah package tanpa persetujuan SE**: jangan mengedit `pubspec.yaml` untuk menambah dependency baru sebelum mendapat izin eksplisit dari SE.

## 3. Teknologi & Standar Implementasi
- **Stack wajib**: Flutter (Android), `Provider` untuk state management, dan `Supabase` untuk backend (Auth + PostgreSQL + RLS).
- Ikuti pola `Screen -> Provider -> Repository -> Supabase`.
- Bahasa antarmuka menggunakan bahasa Indonesia sehari-hari yang ramah pengguna lanjut usia (teks `>= 16 sp`, tombol aksi utama `>= 48 dp`, label fasilitas lengkap seperti `Kamar Mandi Dalam`).

## 4. Aturan Keamanan (Wajib)
- **Tidak ada key, token, atau password di kode maupun repository** (termasuk file `.env`).
- Konfigurasi `SUPABASE_URL` dan `SUPABASE_ANON_KEY` wajib dibaca melalui `--dart-define`.
- **`service_role` key TIDAK PERNAH dipakai di aplikasi** atau dikirim ke chat/kode.
- **Hak akses ditegakkan di backend melalui Row Level Security (RLS) Supabase**, bukan sekadar menyembunyikan tombol di UI.

## 5. Aturan Git & Commit
- **Satu task atau satu dokumen, satu commit** (commit hanya dilakukan setelah SE memeriksa dan menyetujui).
- Pesan commit wajib menyebut ID task atau jenis dokumen, contoh: `T03: tampil daftar kos (US01-AC1)` atau `docs: tambah PRD`.

## 6. Identitas Halaman Tentang
- Halaman `Tentang` wajib menampilkan NIM dan Nama pembuat secara persis:
  `2415051069 - Putu Evan Jagadish Satriana`

## 7. Definition of Done (DoD)
Setiap task kode baru dianggap selesai hanya jika seluruh poin berikut terpenuhi:
1. `flutter analyze` bersih (0 error dan 0 warning/info baru yang mengganggu).
2. `flutter test` lulus seluruhnya (termasuk unit test untuk logika yang dibuat pada task tersebut).
3. Aplikasi dijalankan di device (HP Android atau emulator) dan diuji sesuai AC terkait.
4. Agen melaporkan secara jujur apa yang sudah diuji dan **apa yang belum diuji**.
