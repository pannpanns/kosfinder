# KosFinder

Aplikasi Android berbasis **Flutter** dan **Supabase** untuk mempertemukan pencari kos (tanpa login) dengan pemilik kos (dengan login sederhana), dibangun ramah pengguna lanjut usia.

Pembuat: `2415051069 - Putu Evan Jagadish Satriana`

## Fitur Utama (v0.1.0)

- **Pencari Kos (tanpa login):**
  - Melihat daftar kos terbaru beserta harga per bulan, fasilitas, dan status ketersediaan kamar (`Penuh` jika `0`).
  - Mencari area (*contains case-insensitive*) serta menyaring harga maksimal dan kombinasi fasilitas baku (`AC`, `WiFi`, `Kamar Mandi Dalam`, `Parkir`).
  - Melihat detail kos lengkap dan menghubungi pemilik lewat **Salin**, **WhatsApp**, atau **Telepon**.
- **Pemilik Kos (dengan login email & password):**
  - Mendaftar, masuk, dan keluar secara sederhana (tersedia tombol lihat password dan catatan lupa password).
  - Melihat ringkasan & daftar **Kos Saya**, menambah, mengubah, dan menghapus kos (dengan dialog konfirmasi).
  - Menambah maksimal 3 fasilitas tambahan (`2-20` karakter) di luar 4 fasilitas baku.
  - Mengubah jumlah kamar tersedia secara cepat lewat tombol `-` / `+`.
- **Halaman Tentang:** menampilkan informasi singkat aplikasi serta identitas pembuat (`2415051069 - Putu Evan Jagadish Satriana`).
- **Keamanan Backend (RLS):** hak akses `INSERT`, `UPDATE`, dan `DELETE` ditegakkan di PostgreSQL Supabase melalui Row Level Security (`auth.uid() = owner_id`).

## Persiapan Database (Supabase)

1. Buat proyek di Supabase dan jalankan kedua file migrasi di **SQL Editor** secara berurutan:
   - `supabase/migrations/001_init.sql` (tabel `public.kos`, index, dan policy RLS)
   - `supabase/migrations/002_grant_kos_privileges.sql` (hak akses `anon` & `authenticated`)
2. Di **Authentication -> Providers -> Email**, nonaktifkan **Confirm email** jika ingin pemilik kos langsung masuk setelah mendaftar.

## Cara Menjalankan

Konfigurasi Supabase **tidak ditulis di dalam kode** dan tidak disimpan di file `.env` pada repository. Jalankan aplikasi dari terminal dengan mengisi `SUPABASE_URL` dan `SUPABASE_ANON_KEY` asli melalui `--dart-define`:

```bash
flutter run \
  --dart-define=SUPABASE_URL=https://contoh-proyek.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=contoh_anon_key_palsu
```

Di Windows PowerShell (satu baris):

```powershell
flutter run --dart-define=SUPABASE_URL=https://contoh-proyek.supabase.co --dart-define=SUPABASE_ANON_KEY=contoh_anon_key_palsu
```

## Cara Build APK Rilis

```powershell
flutter build apk --release --dart-define=SUPABASE_URL=https://contoh-proyek.supabase.co --dart-define=SUPABASE_ANON_KEY=contoh_anon_key_palsu
```

Hasil APK berada di `build/app/outputs/flutter-apk/app-release.apk` (folder `build/` diabaikan Git dan tidak masuk repository).

> **Keamanan:** Gunakan hanya **anon / publishable key**. Jangan pernah menaruh `service_role` key atau kredensial asli di dalam kode, chat, maupun riwayat commit.

## Pengujian Lokal

```bash
flutter analyze
flutter test
```

## Batasan Versi 1

Sesuai `docs/PRD.md`, versi `0.1.0` **belum mencakup**: pembayaran online, chat dalam aplikasi, ulasan dan rating, rekomendasi AI, verifikasi identitas/KTP pemilik, upload foto kos, peta lokasi, lupa password, maupun login Google atau OTP/SMS.

## Dokumen Proyek

- `docs/input/ide.md` - Ide awal
- `docs/PRD.md` - Kebutuhan produk, user story, dan acceptance criteria
- `docs/ARCHITECTURE.md` - Arsitektur aplikasi (`Screen -> Provider -> Repository -> Supabase`) dan skema database
- `docs/TASKS.md` - Daftar task (`T01`-`T12`) per vertical slice
- `docs/test-plan.md` - Rencana dan hasil uji terima seluruh AC
- `supabase/migrations/001_init.sql` - Skema tabel `public.kos` dan policy RLS
- `supabase/migrations/002_grant_kos_privileges.sql` - Grant akses role `anon` dan `authenticated`
