import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:kosfinder/providers/owner_kos_provider.dart';
import 'package:kosfinder/repositories/kos_repository.dart';

Map<String, dynamic> _row({
  String id = 'kos-1',
  String ownerId = 'owner-a',
  String nama = 'Kos Melati',
  int kamar = 3,
}) {
  return {
    'id': id,
    'owner_id': ownerId,
    'nama': nama,
    'area': 'Singaraja',
    'alamat': 'Jl. Udayana No. 12',
    'harga': 850000,
    'kamar_tersedia': kamar,
    'fasilitas': ['WiFi', 'Kulkas'],
    'kontak': '081234567890',
    'deskripsi': 'Nyaman',
    'created_at': '2026-11-28T10:00:00.000Z',
  };
}

void main() {
  group('OwnerKosProvider CRUD & penolakan RLS (US04-AC1..AC8)', () {
    const samplePayload = KosPayload(
      nama: 'Kos Melati',
      area: 'Singaraja',
      alamat: 'Jl. Udayana No. 12',
      harga: 850000,
      kamarTersedia: 3,
      fasilitas: ['WiFi', 'Kulkas'],
      kontak: '081234567890',
      deskripsi: 'Nyaman',
    );

    test('loadMyKos, addKos, editKos, removeKos memperbarui daftar dan ringkasan', () async {
      final repo = KosRepository(
        fetchByOwnerOverride: (ownerId) async => [
          _row(id: 'kos-1', ownerId: ownerId, kamar: 3),
        ],
        createOverride: (ownerId, data) async => {
          ...data,
          'id': 'kos-2',
          'created_at': '2026-11-28T11:00:00.000Z',
        },
        updateOverride: (id, data) async => {
          ...data,
          'id': id,
          'owner_id': 'owner-a',
          'created_at': '2026-11-28T10:00:00.000Z',
        },
        deleteOverride: (id) async => true,
      );
      final provider = OwnerKosProvider(repository: repo);

      await provider.loadMyKos('owner-a');
      expect(provider.totalKos, 1);
      expect(provider.totalKamar, 3);
      expect(provider.totalPenuh, 0);

      final added = await provider.addKos(
        ownerId: 'owner-a',
        payload: samplePayload,
      );
      expect(added, isTrue);
      expect(provider.totalKos, 2);

      final edited = await provider.editKos(
        id: 'kos-1',
        payload: const KosPayload(
          nama: 'Kos Melati Baru',
          area: 'Singaraja',
          alamat: 'Jl. Udayana No. 12',
          harga: 900000,
          kamarTersedia: 0,
          fasilitas: ['WiFi'],
          kontak: '081234567890',
        ),
      );
      expect(edited, isTrue);
      expect(provider.totalPenuh, 1);
      expect(provider.items.last.nama, 'Kos Melati Baru');

      final removed = await provider.removeKos('kos-2');
      expect(removed, isTrue);
      expect(provider.totalKos, 1);
    });

    test('pemilik B ditolak oleh RLS saat mengubah atau menghapus kos pemilik A', () async {
      final repo = KosRepository(
        updateOverride: (id, data) async => null,
        deleteOverride: (id) async => false,
      );
      final provider = OwnerKosProvider(repository: repo);

      final edited = await provider.editKos(
        id: 'kos-milik-a',
        payload: samplePayload,
      );
      expect(edited, isFalse);
      expect(provider.errorMessage, contains('tidak memiliki izin'));

      final deleted = await provider.removeKos('kos-milik-a');
      expect(deleted, isFalse);
      expect(provider.errorMessage, contains('tidak memiliki izin'));
    });

    test('kegagalan koneksi saat simpan menyimpan pesan error jelas', () async {
      final repo = KosRepository(
        createOverride: (ownerId, data) async {
          throw const SocketException('offline');
        },
      );
      final provider = OwnerKosProvider(repository: repo);

      final added = await provider.addKos(
        ownerId: 'owner-a',
        payload: samplePayload,
      );
      expect(added, isFalse);
      expect(provider.errorMessage, contains('Tidak ada koneksi internet'));
    });
  });
}
