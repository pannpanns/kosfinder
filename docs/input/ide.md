# Ide: KosFinder

## Gambaran singkat

KosFinder adalah aplikasi Android untuk mempertemukan pencari kos dengan pemilik kos.
Pencari bisa mencari kos dengan mudah tanpa harus login. Pemilik kos bisa
mempromosikan kosnya secara gratis dengan langkah yang sangat sederhana.

## Pengguna

1. Pencari kos
   - Mahasiswa yang merantau ke kota kampus.
   - Pekerja yang bekerja atau mencari kerja jauh dari rumah.
   - Biasanya belum mengenal daerah tujuan, sehingga butuh informasi yang jelas.
   - Hanya melihat dan mencari, jadi TIDAK perlu login.

2. Pemilik kos
   - Ingin mempromosikan kosnya secara gratis.
   - Rata-rata sudah berusia lanjut dan tidak terbiasa dengan aplikasi yang rumit.
   - Perlu login (daftar dan masuk) agar hanya ia yang bisa mengatur kosnya sendiri.

## Masalah

Pencari kos:
- Informasi kos tersebar di media sosial, grup WhatsApp, dan dari mulut ke mulut.
- Sulit mencari kos di daerah yang belum dikenal.
- Sulit membandingkan harga dan fasilitas antar kos.
- Informasi sering tidak lengkap, misalnya fasilitas tidak disebut atau kontak sulit dicari.

Pemilik kos:
- Tidak punya cara promosi yang mudah dan gratis.
- Promosi lewat spanduk atau mulut ke mulut jangkauannya terbatas.
- Aplikasi yang rumit membuat mereka enggan mencoba.

## Yang diharapkan bisa dilakukan

Pencari kos:
- Melihat daftar kos yang tersedia.
- Mencari kos berdasarkan area.
- Menyaring berdasarkan rentang harga dan fasilitas (misalnya AC, WiFi, kamar mandi dalam).
- Melihat detail kos: nama, alamat, harga per bulan, fasilitas, deskripsi singkat, dan kontak pemilik.
- Menghubungi pemilik lewat kontak yang tercantum (di luar aplikasi, misalnya telepon atau WhatsApp).

Pemilik kos:
- Mendaftar dan masuk dengan cara sederhana.
- Menambah kos lewat satu form pendek.
- Melihat daftar kos miliknya sendiri.
- Mengubah dan menghapus kos MILIKNYA SENDIRI.
- Tidak bisa mengubah atau menghapus kos milik pemilik lain.

## Gambaran cerita pemakaian

Cerita 1 (pencari): Rina baru diterima kuliah di kota lain. Ia membuka KosFinder, memilih
area dekat kampus, menyaring harga di bawah Rp1.000.000 dengan WiFi, lalu membuka satu kos
untuk melihat detail dan kontak pemiliknya.

Cerita 2 (pemilik): Pak Wayan punya 8 kamar kos. Ia mendaftar, masuk, menekan tombol
"Tambah Kos", mengisi form singkat, lalu menyimpan. Kosnya langsung muncul di daftar
pencari. Beberapa bulan kemudian ia mengubah harga lewat layar yang sama.

Cerita 3 (kasus gagal): Sinyal hilang saat daftar kos dimuat. Aplikasi menampilkan pesan
yang jelas dan tombol "Coba lagi", bukan layar kosong atau aplikasi menutup sendiri.

## Prinsip kemudahan untuk pemilik kos

Karena pemilik kos rata-rata berusia lanjut, aplikasi harus:
- Punya sedikit layar dan alur yang pendek.
- Memakai tombol besar dan tulisan besar yang jelas.
- Memakai bahasa Indonesia sehari-hari, tanpa istilah teknis.
- Memakai form yang pendek, hanya berisi isian yang benar-benar perlu.
- Memberi pesan kesalahan yang jelas dan sopan (misalnya "Harga harus berupa angka").
- Meminta konfirmasi sebelum menghapus kos.
- Memberi tanda jelas saat berhasil menyimpan.

## Ukuran keberhasilan (gambaran awal)

- Pencari bisa menemukan kos yang sesuai (area, harga, fasilitas) dalam beberapa langkah saja.
- Pemilik bisa menambah satu kos tanpa bantuan orang lain.
- Pemilik tidak bisa mengubah atau menghapus kos milik orang lain.
- Aplikasi tetap menampilkan pesan yang jelas saat data kosong atau koneksi gagal.

## Batasan

- Aplikasi Android, dibuat dengan Flutter. Backend Supabase.
- Gratis untuk pemilik kos dan pencari kos.
- Alur harus sederhana, terutama bagi pemilik kos.
- Hak akses (siapa boleh mengubah apa) harus ditegakkan di backend, bukan sekadar
  menyembunyikan tombol.
- Versi pertama TIDAK mencakup: pembayaran online, chat, ulasan dan rating, rekomendasi AI,
  verifikasi identitas pemilik, upload foto, peta.
