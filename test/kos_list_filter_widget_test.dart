import 'package:flutter_test/flutter_test.dart';
import 'package:kosfinder/main.dart';
import 'package:kosfinder/repositories/kos_repository.dart';
import 'package:material_ui/material_ui.dart';

List<Map<String, dynamic>> _sampleRows() {
  return [
    {
      'id': '1',
      'owner_id': null,
      'nama': 'Kos Melati Kampus',
      'area': 'Singaraja',
      'alamat': 'Jl. Udayana No. 12',
      'harga': 900000,
      'kamar_tersedia': 4,
      'fasilitas': ['WiFi', 'Kamar Mandi Dalam'],
      'kontak': '081234567890',
      'deskripsi': '',
      'created_at': '2026-11-27T10:00:00.000Z',
    },
    {
      'id': '2',
      'owner_id': null,
      'nama': 'Kos Anggrek Eksklusif',
      'area': 'Singaraja',
      'alamat': 'Jl. Ahmad Yani No. 45',
      'harga': 2500000,
      'kamar_tersedia': 2,
      'fasilitas': ['AC', 'WiFi', 'Kamar Mandi Dalam', 'Parkir'],
      'kontak': '081298765432',
      'deskripsi': '',
      'created_at': '2026-11-27T09:00:00.000Z',
    },
    {
      'id': '3',
      'owner_id': null,
      'nama': 'Kos Cempaka Putra',
      'area': 'Denpasar',
      'alamat': 'Jl. Sudirman No. 8',
      'harga': 1200000,
      'kamar_tersedia': 1,
      'fasilitas': ['WiFi', 'Parkir'],
      'kontak': '085611223344',
      'deskripsi': '',
      'created_at': '2026-11-27T08:00:00.000Z',
    },
  ];
}

void main() {
  group('KosListScreen Cari & Filter UI (US02-AC1..AC4)', () {
    testWidgets('cari singaraja dan Singaraja memberi hasil yang sama', (tester) async {
      final repo = KosRepository(fetchRowsOverride: () async => _sampleRows());
      await tester.pumpWidget(KosFinderApp(kosRepository: repo));
      await tester.pumpAndSettle();

      final searchField = find.byType(TextField).first;
      await tester.enterText(searchField, 'singaraja');
      await tester.pumpAndSettle();

      expect(find.text('2 kos ditemukan'), findsOneWidget);
      expect(find.text('Kos Melati Kampus'), findsOneWidget);
      expect(find.text('Kos Anggrek Eksklusif'), findsOneWidget);
      expect(find.text('Kos Cempaka Putra'), findsNothing);

      await tester.enterText(searchField, 'Singaraja');
      await tester.pumpAndSettle();

      expect(find.text('2 kos ditemukan'), findsOneWidget);
      expect(find.text('Kos Melati Kampus'), findsOneWidget);
      expect(find.text('Kos Anggrek Eksklusif'), findsOneWidget);
    });

    testWidgets('filter maksimal Rp2.000.000 dan WiFi lewat chip serta reset saat hasil kosong', (tester) async {
      final repo = KosRepository(fetchRowsOverride: () async => _sampleRows());
      await tester.pumpWidget(KosFinderApp(kosRepository: repo));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Maks Rp2 jt'));
      await tester.tap(find.text('WiFi').first);
      await tester.pumpAndSettle();

      expect(find.text('Kos Melati Kampus'), findsOneWidget);
      expect(find.text('Kos Cempaka Putra'), findsOneWidget);
      expect(find.text('Kos Anggrek Eksklusif'), findsNothing);

      await tester.enterText(find.byType(TextField).first, 'Ubud');
      await tester.pumpAndSettle();

      expect(find.text('Tidak ada kos yang cocok.'), findsOneWidget);
      await tester.tap(find.text('Hapus Filter'));
      await tester.pumpAndSettle();

      expect(find.text('3 kos ditemukan'), findsOneWidget);
    });

    testWidgets('bottom sheet Filter mendukung input harga maksimal dan fasilitas AND', (tester) async {
      final repo = KosRepository(fetchRowsOverride: () async => _sampleRows());
      await tester.pumpWidget(KosFinderApp(kosRepository: repo));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Filter'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).last, '2000000');
      await tester.tap(find.text('Kamar Mandi Dalam').last);
      await tester.tap(find.text('Terapkan'));
      await tester.pumpAndSettle();

      expect(find.text('1 kos ditemukan'), findsOneWidget);
      expect(find.text('Kos Melati Kampus'), findsOneWidget);
    });
  });
}
