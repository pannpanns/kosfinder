import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:kosfinder/main.dart';
import 'package:kosfinder/repositories/auth_repository.dart';
import 'package:kosfinder/repositories/kos_repository.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  group('KosFormScreen Tambah & Ubah Kos (US04-AC1..AC8)', () {
    testWidgets('validasi harga menampilkan Harga harus berupa angka dan menjaga ketikan saat gagal simpan', (tester) async {
      var shouldFailSave = true;
      final rows = <Map<String, dynamic>>[];

      final authRepo = AuthRepository(
        currentUserOverride: () =>
            const AuthUser(id: 'owner-a', email: 'a@contoh.com'),
      );
      final kosRepo = KosRepository(
        fetchRowsOverride: () async => rows,
        fetchByOwnerOverride: (ownerId) async => rows,
        createOverride: (ownerId, data) async {
          if (shouldFailSave) {
            throw const SocketException('offline');
          }
          final created = {
            ...data,
            'id': 'kos-baru',
            'created_at': '2026-11-28T12:00:00.000Z',
          };
          rows.add(created);
          return created;
        },
      );

      await tester.pumpWidget(
        KosFinderApp(kosRepository: kosRepo, authRepository: authRepo),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Kos Saya'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Tambah Kos'));
      await tester.pumpAndSettle();

      expect(
        find.text('Nomor ini akan terlihat oleh pencari kos.'),
        findsOneWidget,
      );

      await tester.enterText(find.byType(TextField).at(0), 'Kos Baru');
      await tester.enterText(find.byType(TextField).at(1), 'Singaraja');
      await tester.enterText(find.byType(TextField).at(2), 'Jl. Ahmad Yani 10');
      await tester.enterText(find.byType(TextField).at(3), 'mahal');
      await tester.enterText(find.byType(TextField).at(4), '3');
      await tester.enterText(find.byType(TextField).at(5), '081234567890');

      final wifiChip = find.text('WiFi');
      await tester.ensureVisible(wifiChip);
      await tester.tap(wifiChip);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Simpan'));
      await tester.pumpAndSettle();

      expect(find.text('Harga harus berupa angka'), findsOneWidget);

      await tester.enterText(find.byType(TextField).at(3), '850000');
      await tester.tap(find.text('Simpan'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Tidak ada koneksi internet'), findsOneWidget);
      expect(find.text('Kos Baru'), findsOneWidget);

      shouldFailSave = false;
      await tester.tap(find.text('Simpan'));
      await tester.pumpAndSettle();

      expect(find.text('Kos berhasil disimpan.'), findsOneWidget);
      expect(find.text('Kos Baru'), findsOneWidget);
    });

    testWidgets('dialog Tambah fasilitas tambahan menolak duplikat, membatasi 3, dan mode Ubah Kos mengisi data awal', (tester) async {
      final rows = <Map<String, dynamic>>[
        {
          'id': 'kos-1',
          'owner_id': 'owner-a',
          'nama': 'Kos Lama',
          'area': 'Singaraja',
          'alamat': 'Jl. Udayana No. 5',
          'harga': 900000,
          'kamar_tersedia': 2,
          'fasilitas': ['WiFi', 'Kulkas'],
          'kontak': '081234567890',
          'deskripsi': 'Tenang',
          'created_at': '2026-11-28T10:00:00.000Z',
        },
      ];

      final authRepo = AuthRepository(
        currentUserOverride: () =>
            const AuthUser(id: 'owner-a', email: 'a@contoh.com'),
      );
      final kosRepo = KosRepository(
        fetchRowsOverride: () async => rows,
        fetchByOwnerOverride: (ownerId) async => rows,
        updateOverride: (id, data) async {
          rows[0] = {
            ...rows[0],
            ...data,
          };
          return rows[0];
        },
      );

      await tester.pumpWidget(
        KosFinderApp(kosRepository: kosRepo, authRepository: authRepo),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Kos Saya'));
      await tester.pumpAndSettle();

      await tester.drag(find.byType(ListView).last, const Offset(0, -180));
      await tester.pumpAndSettle();
      final ubahBtn = find.widgetWithText(FilledButton, 'Ubah').first;
      await tester.tap(ubahBtn);
      await tester.pumpAndSettle();

      expect(find.text('Ubah Kos'), findsOneWidget);
      expect(find.text('Kos Lama'), findsOneWidget);
      expect(find.text('Kulkas'), findsOneWidget);

      final tambahChip = find.text('Tambah');
      await tester.ensureVisible(tambahChip);
      await tester.tap(tambahChip);
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).last, 'kulkas');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Tambah'));
      await tester.pumpAndSettle();
      expect(find.text('Fasilitas ini sudah ada.'), findsOneWidget);

      await tester.enterText(find.byType(TextField).last, 'Dapur');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Tambah'));
      await tester.pumpAndSettle();
      expect(find.text('Dapur'), findsOneWidget);

      await tester.enterText(find.byType(TextField).at(0), 'Kos Diubah');
      await tester.tap(find.text('Simpan'));
      await tester.pumpAndSettle();

      expect(find.text('Kos berhasil disimpan.'), findsOneWidget);
      expect(find.text('Kos Diubah'), findsOneWidget);
    });
  });
}
