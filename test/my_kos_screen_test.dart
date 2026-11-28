import 'package:flutter_test/flutter_test.dart';
import 'package:kosfinder/main.dart';
import 'package:kosfinder/repositories/auth_repository.dart';
import 'package:kosfinder/repositories/kos_repository.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  group('MyKosScreen (US04-AC2, AC3, AC5, AC6)', () {
    testWidgets('menampilkan pesan Anda belum memasang kos saat pemilik belum punya kos', (tester) async {
      final authRepo = AuthRepository(
        currentUserOverride: () =>
            const AuthUser(id: 'owner-a', email: 'a@contoh.com'),
      );
      final kosRepo = KosRepository(
        fetchRowsOverride: () async => [],
        fetchByOwnerOverride: (ownerId) async => [],
      );

      await tester.pumpWidget(
        KosFinderApp(kosRepository: kosRepo, authRepository: authRepo),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Kos Saya'));
      await tester.pumpAndSettle();

      expect(find.text('Anda belum memasang kos.'), findsOneWidget);
      expect(find.text('Tambah Kos'), findsOneWidget);
    });

    testWidgets('menampilkan ringkasan kos, batal hapus, lalu hapus kos setelah konfirmasi', (tester) async {
      var rows = [
        {
          'id': 'kos-1',
          'owner_id': 'owner-a',
          'nama': 'Kos Melati',
          'area': 'Singaraja',
          'alamat': 'Jl. Udayana No. 12',
          'harga': 850000,
          'kamar_tersedia': 3,
          'fasilitas': ['AC', 'WiFi'],
          'kontak': '081234567890',
          'deskripsi': '',
          'created_at': '2026-11-28T10:00:00.000Z',
        },
        {
          'id': 'kos-2',
          'owner_id': 'owner-a',
          'nama': 'Kos Anggrek',
          'area': 'Singaraja',
          'alamat': 'Jl. Ahmad Yani No. 45',
          'harga': 700000,
          'kamar_tersedia': 0,
          'fasilitas': ['WiFi', 'Parkir'],
          'kontak': '081298765432',
          'deskripsi': '',
          'created_at': '2026-11-28T09:00:00.000Z',
        },
      ];

      final authRepo = AuthRepository(
        currentUserOverride: () =>
            const AuthUser(id: 'owner-a', email: 'a@contoh.com'),
      );
      final kosRepo = KosRepository(
        fetchRowsOverride: () async => rows,
        fetchByOwnerOverride: (ownerId) async => rows,
        deleteOverride: (id) async {
          rows = rows.where((item) => item['id'] != id).toList();
          return true;
        },
      );

      await tester.pumpWidget(
        KosFinderApp(kosRepository: kosRepo, authRepository: authRepo),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Kos Saya'));
      await tester.pumpAndSettle();

      expect(find.text('2'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
      expect(find.text('1'), findsOneWidget);
      expect(find.text('Kos Melati'), findsOneWidget);

      final deleteButton = find.widgetWithText(FilledButton, 'Hapus').first;
      await tester.ensureVisible(deleteButton);
      await tester.pumpAndSettle();
      await tester.tap(deleteButton);
      await tester.pumpAndSettle();

      expect(find.text('Hapus kos ini?'), findsOneWidget);
      await tester.tap(find.text('Batal'));
      await tester.pumpAndSettle();
      expect(rows, hasLength(2));

      await tester.tap(deleteButton);
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Hapus').last);
      await tester.pumpAndSettle();

      expect(rows, hasLength(1));
      expect(find.text('Kos berhasil dihapus.'), findsOneWidget);
    });
  });
}
