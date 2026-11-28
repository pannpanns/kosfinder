# KosFinder

Aplikasi Android berbasis **Flutter** dan **Supabase** untuk mempertemukan pencari kos (tanpa login) dengan pemilik kos (dengan login sederhana).

## Cara Menjalankan

Konfigurasi Supabase **tidak ditulis di dalam kode** dan tidak disimpan di file `.env` pada repository. Jalankan aplikasi dari terminal Anda dengan mengisi `SUPABASE_URL` dan `SUPABASE_ANON_KEY` asli melalui `--dart-define`:

```bash
flutter run \
  --dart-define=SUPABASE_URL=https://contoh-proyek.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=contoh_anon_key_palsu
```

Di Windows PowerShell (satu baris):

```powershell
flutter run --dart-define=SUPABASE_URL=https://contoh-proyek.supabase.co --dart-define=SUPABASE_ANON_KEY=contoh_anon_key_palsu
```

> **Keamanan:** Gunakan hanya **anon / publishable key**. Jangan pernah menaruh `service_role` key atau kredensial asli di dalam kode, chat, maupun riwayat commit.

## Pengujian Lokal

```bash
flutter analyze
flutter test
```

## Dokumen Proyek
- `docs/input/ide.md` — Ide awal
- `docs/PRD.md` — Kebutuhan produk, user story, dan acceptance criteria
- `docs/ARCHITECTURE.md` — Arsitektur aplikasi dan skema database
- `docs/TASKS.md` — Daftar task per vertical slice
- `supabase/migrations/001_init.sql` — Skema tabel `public.kos` dan policy RLS
