# Daftar Task: KosFinder (v1)

Mengacu pada `docs/PRD.md`, `docs/ARCHITECTURE.md`, dan `AGENTS.md`.
Disusun per *vertical slice* (Slice 1–4 wajib, Slice 5 bonus). Setiap slice menghasilkan aplikasi yang dapat dijalankan dan diuji.

Status: `TODO` | `IN_PROGRESS` | `DONE`

## Slice 1 — Daftar & Detail Kos (+ Halaman Tentang) [Wajib]
| ID | Tujuan | Story & AC | File yang Boleh Diubah | Cara Menguji | Status |
|---|---|---|---|---|---|
| T01 | Tambah package (`provider`, `supabase_flutter`, `url_launcher`), konfigurasi `--dart-define`, dan panduan jalan di `README.md` | US01-AC1, US01-AC4, NFR Keamanan | `pubspec.yaml`, `lib/config/supabase_config.dart`, `README.md`, `test/supabase_config_test.dart` | `flutter analyze`, `flutter test`, jalankan app dengan `--dart-define` (nilai asli di terminal SE) | DONE |
| T02 | Buat model `Kos`, helper format Rupiah, dan `KosRepository` (ambil daftar terbaru, timeout 10 dtk) | US01-AC1, US01-AC3, US01-AC4 | `lib/models/kos.dart`, `lib/utils/kos_validator.dart`, `lib/repositories/kos_repository.dart`, `test/kos_model_test.dart` | Unit test parsing JSON & format Rupiah; `flutter analyze` & `flutter test` lulus | DONE |
| T03 | Buat `KosProvider`, kerangka 2 tab (`HomeShellScreen`), daftar publik (`KosListScreen`), dan `AboutScreen` | US01-AC1, US01-AC3, US01-AC4, US06-AC1, US06-AC2 | `lib/theme/app_theme.dart`, `lib/widgets/kos_card.dart`, `lib/providers/kos_provider.dart`, `lib/screens/home_shell_screen.dart`, `lib/screens/kos_list_screen.dart`, `lib/screens/about_screen.dart`, `lib/main.dart`, `test/kos_provider_test.dart`, `test/widget_test.dart` | Unit test loading/kosong/error; uji di emulator: daftar dari Supabase tampil tanpa kontak, offline muncul pesan + `Coba lagi`, halaman `Tentang` tampil `2415051069 - Putu Evan Jagadish Satriana` | DONE |
| T04 | Buat halaman Detail Kos (`KosDetailScreen`) dengan nomor kontak serta tombol `Salin`, `WhatsApp`, dan `Telepon` | US01-AC2, US01-AC5 | `lib/screens/kos_detail_screen.dart`, `lib/screens/kos_list_screen.dart`, `test/kos_detail_test.dart` | Widget test detail & pesan saat WhatsApp tidak tersedia; ketuk kartu kos di emulator lalu uji `Salin`, `WhatsApp`, `Telepon` | DONE |

## Slice 2 — Pencarian & Filter [Wajib]
| ID | Tujuan | Story & AC | File yang Boleh Diubah | Cara Menguji | Status |
|---|---|---|---|---|---|
| T05 | Tambah logika cari area (*contains case-insensitive*) serta filter harga maks & multi-fasilitas (AND) | US02-AC1, US02-AC2, US02-AC3 | `lib/utils/kos_validator.dart`, `lib/providers/kos_provider.dart`, `test/kos_filter_test.dart` | Unit test `"singaraja"` == `"Singaraja"` == `"singar"`, harga `<= 2.000.000`, dan filter `WiFi` + `AC` (harus punya keduanya) | DONE |
| T06 | Tambah UI bilah cari area, filter harga maks, ceklis fasilitas (`AC`, `WiFi`, `Kamar Mandi Dalam`, `Parkir`), pesan kosong & reset filter | US02-AC1, US02-AC2, US02-AC3, US02-AC4 | `lib/screens/kos_list_screen.dart`, `test/kos_list_filter_widget_test.dart` | Widget test hasil kosong & tombol reset; uji di emulator: cari `"singaraja"` vs `"Singaraja"`, maks Rp2.000.000, hasil kosong tampil pesan | DONE |

## Slice 3 — Login Pemilik [Wajib]
| ID | Tujuan | Story & AC | File yang Boleh Diubah | Cara Menguji | Status |
|---|---|---|---|---|---|
| T07 | Buat `AuthRepository` dan `AuthProvider` (daftar, masuk, keluar, sesi persisten, error bahasa Indonesia) | US03-AC1, US03-AC2, US03-AC3, US03-AC4, US03-AC6 | `lib/repositories/auth_repository.dart`, `lib/providers/auth_provider.dart`, `test/auth_provider_test.dart` | Unit test validasi email/password min 6 karakter & pemetaan error (`Email ini sudah terdaftar. Silakan masuk.`) | DONE |
| T08 | Buat layar Masuk/Daftar (`AuthScreen`), hubungkan tab `Kos Saya`, tombol lihat password, dan catatan lupa password | US03-AC1, US03-AC2, US03-AC3, US03-AC4, US03-AC5, US03-AC6, US03-AC7 | `lib/screens/auth_screen.dart`, `lib/screens/my_kos_screen.dart`, `lib/screens/home_shell_screen.dart`, `lib/main.dart`, `test/auth_screen_test.dart` | Widget test form & catatan lupa password; uji di emulator: daftar, keluar, masuk, tutup & buka ulang tetap login, `Cari Kos` tetap jalan tanpa login | DONE |

## Slice 4 — Tambah, Ubah, Hapus Kos Milik Sendiri [Wajib]
| ID | Tujuan | Story & AC | File yang Boleh Diubah | Cara Menguji | Status |
|---|---|---|---|---|---|
| T09 | Tambah validasi form kos (termasuk fasilitas tambahan maks 3, 2-20 karakter) & operasi CRUD di repository dan `OwnerKosProvider` | US04-AC1, US04-AC2, US04-AC4, US04-AC6, US04-AC7, US04-AC8 | `lib/utils/kos_validator.dart`, `lib/repositories/kos_repository.dart`, `lib/providers/owner_kos_provider.dart`, `test/kos_validator_test.dart`, `test/owner_kos_provider_test.dart` | Unit test pesan `"Harga harus berupa angka"`, No. HP 9–14 digit, min 1 fasilitas, serta error gagal simpan | DONE |
| T10 | Lengkapi `MyKosScreen` (daftar kos milik sendiri, pesan `"Anda belum memasang kos."`, dialog konfirmasi hapus + batal) | US04-AC2, US04-AC3, US04-AC5, US04-AC6 | `lib/screens/my_kos_screen.dart`, `lib/main.dart`, `test/my_kos_screen_test.dart` | Widget test kondisi kosong & batal hapus; uji di emulator dengan akun Pemilik A dan pastikan Pemilik B tidak melihat/mengubah kos Pemilik A | DONE |
| T11 | Buat `KosFormScreen` (form tambah/ubah ramah lansia, dialog `+ Tambah` fasilitas tambahan, catatan privasi kontak, pertahankan isian saat gagal simpan) | US04-AC1, US04-AC2, US04-AC4, US04-AC6, US04-AC8 | `lib/screens/kos_form_screen.dart`, `lib/screens/my_kos_screen.dart`, `test/kos_form_screen_test.dart` | Widget test validasi & ketikan tidak hilang saat gagal simpan; uji di emulator: Pemilik A tambah/ubah/hapus kos, cek di `Cari Kos`, lalu uji dua akun (Pemilik B ditolak RLS) | DONE |

## Slice 5 — Ketersediaan Kamar [Bonus]
| ID | Tujuan | Story & AC | File yang Boleh Diubah | Cara Menguji | Status |
|---|---|---|---|---|---|
| T12 | Tambah kontrol cepat perbarui jumlah kamar (termasuk `0`) di `Kos Saya` & tampilkan badge `"Penuh"` di daftar serta detail kos | US05-AC1, US05-AC2 | `lib/repositories/kos_repository.dart`, `lib/providers/owner_kos_provider.dart`, `lib/screens/my_kos_screen.dart`, `lib/screens/kos_list_screen.dart`, `lib/screens/kos_detail_screen.dart`, `test/kamar_tersedia_test.dart` | Unit & widget test status `"Penuh"` saat `kamar_tersedia == 0`; uji di emulator: pemilik ubah jumlah kamar (termasuk ke `0`) lalu cek langsung di sisi pencari | TODO |
