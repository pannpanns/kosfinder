import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:kosfinder/models/kos.dart';
import 'package:kosfinder/repositories/kos_repository.dart';
import 'package:kosfinder/utils/kos_validator.dart';

void main() {
  group('Kos.fromJson (US01-AC1 / US05-AC2)', () {
    test('mem-parsing data kos lengkap dari JSON Supabase', () {
      final kos = Kos.fromJson({
        'id': 'kos-1',
        'owner_id': 'owner-1',
        'nama': 'Kos Melati Kampus',
        'area': 'Singaraja',
        'alamat': 'Jl. Udayana No. 12',
        'harga': 900000,
        'kamar_tersedia': 4,
        'fasilitas': ['WiFi', 'Kamar Mandi Dalam'],
        'kontak': '081234567890',
        'deskripsi': 'Dekat kampus.',
        'created_at': '2026-11-27T10:00:00.000Z',
      });

      expect(kos.id, 'kos-1');
      expect(kos.ownerId, 'owner-1');
      expect(kos.nama, 'Kos Melati Kampus');
      expect(kos.area, 'Singaraja');
      expect(kos.harga, 900000);
      expect(kos.kamarTersedia, 4);
      expect(kos.isPenuh, isFalse);
      expect(kos.statusKamar, '4 kamar tersedia');
      expect(kos.fasilitas, ['WiFi', 'Kamar Mandi Dalam']);
      expect(kos.kontak, '081234567890');
    });

    test('menangani owner_id null dan kamar_tersedia 0 sebagai Penuh', () {
      final kos = Kos.fromJson({
        'id': 'kos-2',
        'owner_id': null,
        'nama': 'Kos Cempaka',
        'area': 'Denpasar',
        'alamat': 'Jl. Sudirman No. 8',
        'harga': 1200000,
        'kamar_tersedia': 0,
        'fasilitas': ['WiFi', 'Parkir'],
        'kontak': '085611223344',
        'deskripsi': '',
        'created_at': '2026-11-27T11:00:00.000Z',
      });

      expect(kos.ownerId, isNull);
      expect(kos.isPenuh, isTrue);
      expect(kos.statusKamar, 'Penuh');
    });
  });

  group('KosValidator format harga & fasilitas (US01-AC1)', () {
    test('memformat angka harga menjadi Rupiah bertitik', () {
      expect(KosValidator.formatRupiah(0), 'Rp0');
      expect(KosValidator.formatRupiah(500), 'Rp500');
      expect(KosValidator.formatRupiah(900000), 'Rp900.000');
      expect(KosValidator.formatRupiah(2500000), 'Rp2.500.000');
      expect(KosValidator.formatHargaPerBulan(900000), 'Rp900.000 / bulan');
    });

    test('memakai label Kamar Mandi Dalam tanpa singkatan KM', () {
      expect(KosValidator.daftarFasilitas, contains('Kamar Mandi Dalam'));
      expect(KosValidator.daftarFasilitas, isNot(contains('KM Dalam')));
    });
  });

  group('KosRepository.fetchAllKos (US01-AC1, AC3, AC4)', () {
    test('mengembalikan daftar Kos saat backend mengembalikan data', () async {
      final repo = KosRepository(
        fetchRowsOverride: () async => [
          {
            'id': '1',
            'owner_id': null,
            'nama': 'Kos Melati',
            'area': 'Singaraja',
            'alamat': 'Jl. Udayana No. 12',
            'harga': 900000,
            'kamar_tersedia': 3,
            'fasilitas': ['WiFi'],
            'kontak': '081234567890',
            'deskripsi': '',
            'created_at': '2026-11-27T10:00:00.000Z',
          },
        ],
      );

      final result = await repo.fetchAllKos();
      expect(result, hasLength(1));
      expect(result.first.nama, 'Kos Melati');
    });

    test('mengembalikan list kosong saat database belum berisi kos', () async {
      final repo = KosRepository(fetchRowsOverride: () async => []);
      final result = await repo.fetchAllKos();
      expect(result, isEmpty);
    });

    test('melempar KosRepositoryException saat koneksi timeout', () async {
      final repo = KosRepository(
        timeout: const Duration(milliseconds: 20),
        fetchRowsOverride: () async {
          await Future<void>.delayed(const Duration(milliseconds: 100));
          return [];
        },
      );

      await expectLater(
        repo.fetchAllKos(),
        throwsA(
          isA<KosRepositoryException>().having(
            (e) => e.message,
            'message',
            contains('Koneksi terlalu lama'),
          ),
        ),
      );
    });

    test('melempar KosRepositoryException saat tidak ada koneksi', () async {
      final repo = KosRepository(
        fetchRowsOverride: () async {
          throw const SocketException('No internet');
        },
      );

      await expectLater(
        repo.fetchAllKos(),
        throwsA(
          isA<KosRepositoryException>().having(
            (e) => e.message,
            'message',
            contains('Tidak ada koneksi internet'),
          ),
        ),
      );
    });
  });
}
