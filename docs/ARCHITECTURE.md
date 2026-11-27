# Arsitektur & Rencana Teknis: KosFinder (v1)

Mengacu pada `docs/PRD.md` dan `AGENTS.md`. Menggunakan solusi paling sederhana dengan pola **Screen -> Provider -> Repository -> Supabase**.

## 1. Komponen Aplikasi & Tugasnya
| Komponen | Lokasi | Tugas | Story Terkait |
|---|---|---|---|
| Config Supabase | `lib/config/supabase_config.dart` | Baca `SUPABASE_URL` & `SUPABASE_ANON_KEY` via `--dart-define`, inisialisasi klien | `US01`–`US05` |
| Model Kos | `lib/models/kos.dart` | Representasi data kos & konversi JSON <-> objek Dart | `US01`, `US02`, `US04`, `US05` |
| Validator & Helper | `lib/utils/kos_validator.dart` | Validasi form (harga > 0, kamar >= 0, HP 9–14 digit, min 1 fasilitas), filter & format Rupiah | `US02`, `US04`, `US05` |
| Kos Repository | `lib/repositories/kos_repository.dart` | Query tabel `public.kos` (ambil terbaru, tambah, ubah, hapus) dengan timeout 10 detik | `US01`, `US02`, `US04`, `US05` |
| Auth Repository | `lib/repositories/auth_repository.dart` | Wrapper Supabase Auth (daftar, masuk, keluar, sesi aktif) | `US03`, `US04` |
| Kos Provider | `lib/providers/kos_provider.dart` | State daftar publik, cari area (*contains case-insensitive*), filter harga maks & fasilitas (AND), status loading/error/kosong | `US01`, `US02`, `US05` |
| Auth Provider | `lib/providers/auth_provider.dart` | State login pemilik & pemetaan error autentikasi ke bahasa Indonesia | `US03` |
| Owner Kos Provider | `lib/providers/owner_kos_provider.dart` | State daftar `Kos Saya` milik pemilik login serta aksi tambah, ubah, hapus, dan update kamar | `US04`, `US05` |
| Screens | `lib/screens/` | Antarmuka Android ramah lansia (teks >= 16 sp, tombol >= 48 dp) | `US01`–`US06` |

## 2. Daftar Layar & Alur Navigasi
- `HomeShellScreen` (`US01`, `US03`, `US06`): kerangka 2 tab bawah besar (**Cari Kos**, **Kos Saya**) + ikon **Tentang** di AppBar.
- `KosListScreen` (`US01`, `US02`, `US05`): bilah cari area, filter harga maks & ceklis fasilitas (`AC`, `WiFi`, `Kamar Mandi Dalam`, `Parkir`), daftar kos (tanpa nomor kontak), status kosong/gagal + tombol `"Coba lagi"`.
- `KosDetailScreen` (`US01`, `US05`): detail lengkap kos, jumlah kamar tersedia (`"Penuh"` jika `0`), nomor kontak, tombol `Salin`, `WhatsApp` (dengan penanganan jika WA tidak terpasang), dan `Telepon`.
- `AuthScreen` (`US03`): tampil di tab **Kos Saya** saat belum login; form Email + Password (min 6 karakter, tombol lihat password), tombol `Masuk`/`Daftar`, dan catatan lupa password.
- `MyKosScreen` (`US03`, `US04`, `US05`): tampil di tab **Kos Saya** saat sudah login; daftar kos milik sendiri, pesan `"Anda belum memasang kos."` bila kosong, tombol `+ Tambah Kos`, `Keluar`, serta aksi `Ubah` & `Hapus` (dialog konfirmasi).
- `KosFormScreen` (`US04`, `US05`): 1 form pendek untuk tambah/ubah kos & jumlah kamar tersedia, catatan privasi di dekat isian No. HP/WA, dan mempertahankan isian saat simpan gagal.
- `AboutScreen` (`US06`): info singkat KosFinder + `2415051069 - Putu Evan Jagadish Satriana`; tombol kembali menjaga state tab sebelumnya.

**Alur navigasi**: `HomeShellScreen` -> Tab `Cari Kos` (`KosListScreen` -> `KosDetailScreen`) | Tab `Kos Saya` (`AuthScreen` <-> `MyKosScreen` -> `KosFormScreen`) | AppBar `Tentang` (`AboutScreen`).

## 3. Rencana Database & Aturan Akses (Supabase PostgreSQL)
Hanya menggunakan **1 tabel** `public.kos` (terhubung ke `auth.users` bawaan Supabase Auth). Migrasi disimpan di `supabase/migrations/001_init.sql`.

| Kolom | Tipe | Aturan / Keterangan |
|---|---|---|
| `id` | `uuid` | Primary Key (`gen_random_uuid()`) |
| `owner_id` | `uuid` | Foreign Key ke `auth.users(id)` (`ON DELETE CASCADE`, default `auth.uid()`; boleh null khusus data contoh dari Table Editor, namun wajib `auth.uid()` saat insert dari app) |
| `nama` | `text` | `NOT NULL` |
| `area` | `text` | `NOT NULL` |
| `alamat` | `text` | `NOT NULL` |
| `harga` | `integer` | `NOT NULL CHECK (harga > 0)` — bertipe angka bulat (Rupiah/bulan) |
| `kamar_tersedia` | `integer` | `NOT NULL DEFAULT 1 CHECK (kamar_tersedia >= 0)` |
| `fasilitas` | `text[]` | `NOT NULL CHECK (cardinality(fasilitas) >= 1)` — nilai baku: `AC`, `WiFi`, `Kamar Mandi Dalam`, `Parkir` |
| `kontak` | `text` | `NOT NULL CHECK (kontak ~ '^[0-9]{9,14}$')` |
| `deskripsi` | `text` | `NOT NULL DEFAULT ''` (opsional di form) |
| `created_at` | `timestamptz` | `NOT NULL DEFAULT now()` — dipakai untuk urutan terbaru lebih dulu |

**Aturan Akses (Row Level Security pada `public.kos`)**:
- **Lihat (`SELECT`)**: semua pengguna (termasuk tanpa login / `anon`) boleh membaca semua baris (`US01`, `US02`, `US05`).
- **Tambah (`INSERT`)**: hanya pengguna login (`authenticated`) dengan `auth.uid() = owner_id` (`US04-AC1`, `US04-AC7`).
- **Ubah (`UPDATE`)**: hanya pengguna login (`authenticated`) yang `auth.uid() = owner_id` (`US04-AC2`, `US04-AC6`, `US04-AC7`, `US05`).
- **Hapus (`DELETE`)**: hanya pengguna login (`authenticated`) yang `auth.uid() = owner_id` (`US04-AC2`, `US04-AC6`, `US04-AC7`).

## 4. Konfigurasi & Rilis
- **Konfigurasi aman (`--dart-define`)**: `SUPABASE_URL` dan `SUPABASE_ANON_KEY` dibaca lewat `const String.fromEnvironment(...)`, tidak pernah ditulis di kode atau repository. `service_role` key tidak pernah dipakai di aplikasi.
  ```bash
  flutter run --dart-define=SUPABASE_URL=https://contoh.supabase.co --dart-define=SUPABASE_ANON_KEY=contoh_anon_key
  ```
- **Rilis v0.1.0**: jalankan `flutter analyze` dan `flutter test`, lalu build APK:
  ```bash
  flutter build apk --release --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...
  ```
  Buat tag Git `v0.1.0`, push tag, lalu unggah file APK dari `build/app/outputs/flutter-apk/` ke **GitHub Releases** (file `.apk` tidak di-commit ke repository).

## 5. Daftar Package (Minimal)
| Package | Alasan | Story Terkait |
|---|---|---|
| `provider` | State management sederhana sesuai `AGENTS.md` | `US01`–`US05` |
| `supabase_flutter` | Klien resmi Supabase untuk Auth & database PostgreSQL/RLS | `US01`–`US05` |
| `url_launcher` | Membuka WhatsApp (`wa.me`) & Telepon (`tel:`) dan mendeteksi jika WA tidak terpasang | `US01-AC2`, `US01-AC5` |

*(Fitur `Salin` memakai `Clipboard` bawaan Flutter dan pemformatan Rupiah memakai fungsi helper sederhana sehingga tidak perlu menambah package lain).*
