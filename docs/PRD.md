# Product Requirements Document (PRD): KosFinder (v1)

## 1. Masalah dan Tujuan Terukur

**Masalah:** Info kos tersebar dan tidak lengkap, sehingga pencari sulit membandingkan harga dan fasilitas. Pemilik kos (mayoritas lanjut usia) tidak punya media promosi gratis yang sederhana dan sulit memperbarui ketersediaan kamar.

**Tujuan terukur (v1):**
- Pencari menemukan kos sesuai area, harga maksimal, dan fasilitas dalam <= 3 langkah tanpa login.
- Daftar kos termuat <= 3 detik pada koneksi normal (skala v1 <= 200 kos).
- Pemilik dapat mendaftar, masuk, dan menambah 1 kos lewat 1 form pendek secara mandiri.
- 100% upaya ubah atau hapus kos milik orang lain, atau tanpa login, ditolak backend (RLS Supabase).

## 2. Pengguna

- **Pencari kos** (mahasiswa atau pekerja): melihat daftar, mencari, menyaring, dan menghubungi pemilik. Tidak perlu login.
- **Pemilik kos** (rata-rata usia lanjut): mendaftar, masuk, dan mengelola kos miliknya. Wajib login.

## 3. Scope Versi 1

**Masuk scope (Vertical Slice 1 sampai 5):**
- Pencari: daftar kos, detail kos (kamar tersedia, "Penuh" jika 0, tombol Salin, WhatsApp, Telepon), pencarian area, filter harga maksimal dan fasilitas baku (AC, WiFi, Kamar Mandi Dalam, Parkir).
- Pemilik: daftar, masuk, keluar (email dan password sederhana), daftar kos milik sendiri, tambah, ubah, hapus kos milik sendiri, perbarui jumlah kamar tersedia.
- Umum: halaman Tentang menampilkan `<NIM> - <NAMA>`.

**TIDAK masuk scope v1:** pembayaran online, chat dalam aplikasi, ulasan dan rating, rekomendasi AI, verifikasi identitas atau KTP pemilik, upload foto, peta, **lupa password, login Google atau OTP/SMS**.

## 4. Fitur, User Flow, UI/UX, Technical dan Database

**User flow:**
- Pencari: buka app, tab Cari Kos, (opsional) ketik area dan atur filter, ketuk kartu kos, Detail Kos, Salin / WhatsApp / Telepon.
- Pemilik: buka app, tab **Kos Saya**, Masuk atau Daftar, daftar Kos Saya, + Tambah Kos, atau pilih kos untuk Ubah / Hapus (dengan dialog konfirmasi).

**UI/UX:**
- Navigasi 2 tab bawah besar (**Cari Kos**, **Kos Saya**) dan ikon Tentang di AppBar.
- Ramah pemilik lansia: sedikit layar, teks >= 16 sp, tombol aksi utama >= 48 dp, bahasa Indonesia sehari-hari, label fasilitas utuh (Kamar Mandi Dalam, bukan KM), umpan balik jelas saat berhasil simpan atau validasi gagal.
- **Form Kos:** Wajib: Nama Kos, Area, Alamat, Harga per bulan (> 0), Kamar tersedia (>= 0), No. HP/WA (hanya angka, 9 sampai 14 digit), **minimal 1 Fasilitas**. Opsional: Deskripsi singkat.
- Di dekat isian nomor tampil catatan: "Nomor ini akan terlihat oleh pencari kos."

**Technical dan database (ringkas):**
- Flutter (Android) dan Supabase (Auth, PostgreSQL, Row Level Security). Konfigurasi lewat `--dart-define`, tanpa key di kode.
- Satu tabel utama `kos`: id, owner_id (-> auth.users), nama, area, alamat, harga (integer), kamar_tersedia (integer), fasilitas (text[]), kontak, deskripsi, created_at.
- Aturan akses: semua orang boleh melihat; tambah, ubah, hapus hanya oleh pengguna login yang menjadi pemilik kos tersebut.
- Skema SQL dan policy RLS dirinci di `docs/ARCHITECTURE.md` dan `supabase/migrations/001_init.sql`.

**Aturan pencarian dan filter:**
- Area: pencarian "mengandung", tidak peka huruf besar/kecil.
- Harga: kos tampil jika harga <= harga maksimal.
- Fasilitas: bila lebih dari satu dipilih, kos harus memiliki **semua** fasilitas yang dipilih.
- Urutan daftar: kos terbaru lebih dulu.

## 5. Non-Functional Requirements (NFR)

- **Keamanan:** hak akses ditegakkan di backend lewat RLS (bukan sekadar menyembunyikan tombol). `service_role` key tidak pernah ada di aplikasi atau repository. Tidak ada key, password, atau `.env` di riwayat commit.
- **Keandalan:** timeout jaringan 10 detik. Saat offline atau gagal memuat, aplikasi tidak crash dan menampilkan pesan sopan dan tombol "Coba lagi".
- **Kemudahan pakai:** teks >= 16 sp, tombol >= 48 dp, pesan error spesifik (misal "Harga harus berupa angka"), konfirmasi sebelum menghapus kos.
- **Performa:** muat daftar awal <= 3 detik pada koneksi normal untuk <= 200 data kos.
- **Privasi:** nomor kontak pemilik hanya tampil di halaman Detail Kos, tidak di kartu daftar.

## 6. User Story dan Acceptance Criteria (AC)

### US01. Lihat Daftar dan Detail Kos (Slice 1)
Sebagai pencari kos, saya ingin melihat daftar dan detail kos tanpa login, agar dapat membandingkan pilihan dan menghubungi pemilik.

- **US01-AC1 (Daftar tampil):** Given data kos tersedia dan koneksi aktif, When pencari membuka tab Cari Kos tanpa login, Then daftar kos tampil <= 3 detik berisi nama, area, harga per bulan, fasilitas, dan status kamar (tanpa kontak).
- **US01-AC2 (Detail dan kontak):** Given pencari mengetuk satu kos, When halaman Detail terbuka, Then tampil nama, area, alamat, harga per bulan, fasilitas, deskripsi, kamar tersedia ("Penuh" jika 0), kontak, dan tombol Salin, WhatsApp, Telepon.
- **US01-AC3 (Data kosong):** Given belum ada kos di database, When tab Cari Kos dimuat, Then tampil pesan data kos masih kosong, bukan layar kosong atau error.
- **US01-AC4 (Koneksi gagal):** Given perangkat offline atau timeout (> 10 detik), When data dimuat, Then aplikasi tidak crash dan menampilkan pesan gagal koneksi dan tombol "Coba lagi".
- **US01-AC5 (WhatsApp tidak ada):** Given WhatsApp tidak terpasang, When pencari menekan tombol WhatsApp, Then tampil pesan jelas bahwa WhatsApp tidak ditemukan, dan tombol Salin serta Telepon tetap bisa dipakai.

### US02. Cari Area dan Filter Harga/Fasilitas (Slice 2)
Sebagai pencari kos, saya ingin mencari berdasarkan area serta menyaring harga maksimal dan fasilitas, agar cepat menemukan kos yang cocok.

- **US02-AC1 (Cari area):** Given ada kos di area "Singaraja", When pencari mengetik "singaraja", "Singaraja", atau sebagian seperti "singar", Then kos di area tersebut tampil dan hasilnya sama.
- **US02-AC2 (Filter harga dan fasilitas):** Given ada kos Rp900.000 (WiFi) dan Rp2.500.000 (WiFi, AC), When filter harga maksimal Rp2.000.000 dan WiFi dipilih, Then kos Rp900.000 tampil dan Rp2.500.000 tidak tampil.
- **US02-AC3 (Beberapa fasilitas):** Given pencari memilih WiFi dan AC, When filter diterapkan, Then hanya kos yang memiliki kedua fasilitas itu yang tampil.
- **US02-AC4 (Hasil kosong):** Given tidak ada kos yang memenuhi kata kunci atau filter, When pencarian diterapkan, Then tampil pesan hasil tidak ditemukan dan tombol reset filter.

### US03. Autentikasi Pemilik Kos (Slice 3)
Sebagai pemilik kos, saya ingin mendaftar, masuk, dan keluar secara sederhana, agar hanya saya yang mengelola kos milik saya.

- **US03-AC1 (Daftar dan masuk):** Given pemilik belum login di tab Kos Saya, When memasukkan email valid dan password minimal 6 karakter (tersedia tombol lihat password) lalu menekan Daftar atau Masuk, Then pemilik masuk ke daftar kos miliknya.
- **US03-AC2 (Input salah atau gagal koneksi):** Given email atau password salah, atau koneksi gagal, When pemilik menekan Masuk, Then tampil pesan error bahasa Indonesia yang jelas tanpa crash.
- **US03-AC3 (Email sudah terdaftar):** Given email sudah terdaftar, When pemilik mendaftar dengan email itu, Then tampil pesan "Email ini sudah terdaftar. Silakan masuk."
- **US03-AC4 (Tetap login):** Given pemilik sudah login, When aplikasi ditutup lalu dibuka lagi, Then pemilik tetap dalam keadaan login.
- **US03-AC5 (Belum login):** Given pengguna belum login, When membuka tab Kos Saya, Then diarahkan ke layar Masuk dan tidak melihat data pemilik.
- **US03-AC6 (Keluar):** Given pemilik login dan menekan Keluar, When keluar berhasil, Then tab Kos Saya kembali ke layar Masuk dan tab Cari Kos tetap dapat diakses tanpa login.
- **US03-AC7 (Catatan lupa password):** Given layar Masuk tampil, When pemilik melihat layar tersebut, Then tampil catatan singkat: "Jika lupa password, daftar ulang dengan email lain."

### US04. Kelola Kos Milik Sendiri (Slice 4)
Sebagai pemilik kos, saya ingin menambah, mengubah, dan menghapus kos milik saya sendiri, agar informasi kos akurat dan aman dari orang lain.

- **US04-AC1 (Tambah dan validasi):** Given pemilik sudah login, When mengisi semua isian wajib dengan benar (termasuk minimal 1 fasilitas) dan menekan Simpan, Then tampil notifikasi berhasil dan kos muncul di Kos Saya dan Cari Kos. Jika harga bukan angka atau <= 0, tampil "Harga harus berupa angka". Jika isian wajib kosong atau tidak ada fasilitas dipilih, tampil pesan di isian terkait dan data tidak tersimpan.
- **US04-AC2 (Ubah dan konfirmasi hapus):** Given pemilik memilih kos miliknya, When mengubah data dan menyimpan, Then data diperbarui. When menekan Hapus, Then muncul dialog konfirmasi sebelum penghapusan dijalankan.
- **US04-AC3 (Batal hapus):** Given dialog konfirmasi hapus muncul, When pemilik menekan Batal, Then kos tidak terhapus.
- **US04-AC4 (Simpan gagal):** Given koneksi gagal saat menyimpan, When pemilik menekan Simpan, Then tampil pesan gagal koneksi dan isian yang sudah diketik tidak hilang.
- **US04-AC5 (Belum punya kos):** Given pemilik login tetapi belum punya kos, When membuka Kos Saya, Then tampil pesan "Anda belum memasang kos." dan tombol Tambah Kos.
- **US04-AC6 (Pemilik lain ditolak):** Given kos X dimiliki Pemilik A, When Pemilik B mencoba mengubah atau menghapus kos X (lewat aplikasi maupun panggilan langsung API), Then backend (RLS) menolak permintaan dan data kos X tidak berubah.
- **US04-AC7 (Tanpa login ditolak):** Given pengguna tidak login, When mencoba menambah, mengubah, atau menghapus kos lewat panggilan langsung API, Then backend menolak permintaan.

### US05. Ketersediaan Kamar (Slice 5, Bonus)
Sebagai pemilik kos, saya ingin mengubah jumlah kamar tersedia, agar pencari melihat sisa kamar atau status Penuh secara akurat.

- **US05-AC1 (Perbarui kamar):** Given pemilik mengubah kamar_tersedia pada kos miliknya (misal ke 2), When pencari membuka detail kos tersebut, Then jumlah kamar yang tampil berubah menjadi 2.
- **US05-AC2 (Status Penuh):** Given pemilik mengatur kamar_tersedia menjadi 0, When pencari melihat kos di daftar atau detail, Then status ketersediaan tampil "Penuh".

### US06. Halaman Tentang
Sebagai pengguna atau penguji, saya ingin melihat halaman Tentang berisi identitas pembuat, agar pembuat aplikasi teridentifikasi.

- **US06-AC1:** Given pengguna menekan ikon Tentang di AppBar, When halaman terbuka, Then tampil info singkat KosFinder dan teks `<NIM> - <NAMA>`.
- **US06-AC2 (Kembali):** Given halaman Tentang terbuka, When pengguna menekan tombol kembali, Then pengguna kembali ke tab sebelumnya tanpa mereset status login maupun kata kunci pencarian dan filter yang aktif.

## 7. Daftar Pertanyaan / Hal Terbuka

**Sudah dijawab SE:**
1. Lupa password: **diterima untuk v1** tidak ada fitur lupa password. Pemilik yang lupa password mendaftar ulang dengan email lain. Layar Masuk menampilkan catatan singkat (US03-AC7). Fitur ini dipertimbangkan untuk versi berikutnya.

**Masih terbuka:**
2. NIM dan Nama lengkap final untuk halaman Tentang (dibutuhkan pada Tahap 3, AGENTS.md). Format: `<NIM> - <NAMA>`.
3. Konfirmasi email saat Sign Up di dashboard Supabase perlu dimatikan agar pemilik lanjut usia langsung masuk setelah daftar (dikerjakan SE saat setup Supabase, bukan oleh agen).
