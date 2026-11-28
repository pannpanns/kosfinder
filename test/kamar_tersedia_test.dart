import 'package:flutter_test/flutter_test.dart';
import 'package:kosfinder/main.dart';
import 'package:kosfinder/providers/owner_kos_provider.dart';
import 'package:kosfinder/repositories/auth_repository.dart';
import 'package:kosfinder/repositories/kos_repository.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  group('Ketersediaan kamar Slice 5 (US05-AC1, US05-AC2)', () {
    test('OwnerKosProvider.updateKamar memperbarui kamar dan menolak nilai negatif', () async {
      final repo = KosRepository(
        fetchByOwnerOverride: (ownerId) async => [
          {
            'id': 'kos-1',
            'owner_id': ownerId,
            'nama': 'Kos Melati',
            'area': 'Singaraja',
            'alamat': 'Jl. Udayana No. 12',
            'harga': 850000,
            'kamar_tersedia': 3,
            'fasilitas': ['WiFi'],
            'kontak': '081234567890',
            'deskripsi': '',
            'created_at': '2026-11-28T10:00:00.000Z',
          },
        ],
        updateKamarOverride: (id, kamar) async => {
          'id': id,
          'owner_id': 'owner-a',
          'nama': 'Kos Melati',
          'area': 'Singaraja',
          'alamat': 'Jl. Udayana No. 12',
          'harga': 850000,
          'kamar_tersedia': kamar,
          'fasilitas': ['WiFi'],
          'kontak': '081234567890',
          'deskripsi': '',
          'created_at': '2026-11-28T10:00:00.000Z',
        },
      );

      final provider = OwnerKosProvider(repository: repo);
      await provider.loadMyKos('owner-a');

      final okZero = await provider.updateKamar('kos-1', 0);
      expect(okZero, isTrue);
      expect(provider.items.single.isPenuh, isTrue);
      expect(provider.items.single.statusKamar, 'Penuh');

      final okClamped = await provider.updateKamar('kos-1', -2);
      expect(okClamped, isTrue);
      expect(provider.items.single.kamarTersedia, 0);

      final okTwo = await provider.updateKamar('kos-1', 2);
      expect(okTwo, isTrue);
      expect(provider.items.single.kamarTersedia, 2);
      expect(provider.items.single.statusKamar, '2 kamar tersedia');
    });

    testWidgets('perubahan jumlah kamar ke 0 tampil Penuh di Kos Saya, Cari Kos, dan Detail Kos', (tester) async {
      final row = <String, dynamic>{
        'id': 'kos-1',
        'owner_id': 'owner-a',
        'nama': 'Kos Melati',
        'area': 'Singaraja',
        'alamat': 'Jl. Udayana No. 12',
        'harga': 850000,
        'kamar_tersedia': 1,
        'fasilitas': ['WiFi'],
        'kontak': '081234567890',
        'deskripsi': 'Dekat kampus.',
        'created_at': '2026-11-28T10:00:00.000Z',
      };

      final authRepo = AuthRepository(
        currentUserOverride: () =>
            const AuthUser(id: 'owner-a', email: 'a@contoh.com'),
      );
      final kosRepo = KosRepository(
        fetchRowsOverride: () async => [Map<String, dynamic>.from(row)],
        fetchByOwnerOverride: (ownerId) async => [Map<String, dynamic>.from(row)],
        updateKamarOverride: (id, kamar) async {
          row['kamar_tersedia'] = kamar;
          return Map<String, dynamic>.from(row);
        },
      );

      await tester.pumpWidget(
        KosFinderApp(kosRepository: kosRepo, authRepository: authRepo),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Kos Saya'));
      await tester.pumpAndSettle();

      await tester.drag(find.byType(ListView).last, const Offset(0, -140));
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('Kurangi kamar').first);
      await tester.pumpAndSettle();

      expect(find.text('Penuh'), findsAtLeastNWidgets(2));

      await tester.tap(find.text('Cari Kos').last);
      await tester.pumpAndSettle();

      expect(find.text('Penuh'), findsOneWidget);

      await tester.tap(find.text('Kos Melati'));
      await tester.pumpAndSettle();

      expect(find.text('Penuh'), findsNWidgets(2));
      expect(find.text('0 sisa'), findsOneWidget);
    });
  });
}
