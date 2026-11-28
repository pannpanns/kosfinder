import 'package:flutter_test/flutter_test.dart';
import 'package:kosfinder/models/kos.dart';
import 'package:kosfinder/providers/kos_provider.dart';
import 'package:kosfinder/repositories/kos_repository.dart';
import 'package:kosfinder/utils/kos_validator.dart';

Kos _makeKos({
  required String id,
  required String nama,
  required String area,
  required int harga,
  required List<String> fasilitas,
}) {
  return Kos(
    id: id,
    ownerId: 'owner-1',
    nama: nama,
    area: area,
    alamat: 'Jl. Contoh No. $id',
    harga: harga,
    kamarTersedia: 2,
    fasilitas: fasilitas,
    kontak: '081234567890',
    deskripsi: '',
    createdAt: DateTime(2026, 11, 27),
  );
}

void main() {
  final sampleList = [
    _makeKos(
      id: '1',
      nama: 'Kos Melati Kampus',
      area: 'Singaraja',
      harga: 900000,
      fasilitas: const ['WiFi', 'Kamar Mandi Dalam'],
    ),
    _makeKos(
      id: '2',
      nama: 'Kos Anggrek Eksklusif',
      area: 'Singaraja',
      harga: 2500000,
      fasilitas: const ['AC', 'WiFi', 'Kamar Mandi Dalam', 'Parkir'],
    ),
    _makeKos(
      id: '3',
      nama: 'Kos Cempaka Putra',
      area: 'Denpasar',
      harga: 1200000,
      fasilitas: const ['WiFi', 'Parkir'],
    ),
  ];

  group('KosValidator.filterKos (US02-AC1, AC2, AC3)', () {
    test('pencarian area contains tidak peka huruf besar atau kecil', () {
      final lower = KosValidator.filterKos(sampleList, areaQuery: 'singaraja');
      final title = KosValidator.filterKos(sampleList, areaQuery: 'Singaraja');
      final partial = KosValidator.filterKos(sampleList, areaQuery: 'singar');

      expect(lower.map((e) => e.id).toList(), ['1', '2']);
      expect(title.map((e) => e.id).toList(), ['1', '2']);
      expect(partial.map((e) => e.id).toList(), ['1', '2']);
    });

    test('filter harga maksimal Rp2.000.000 dan WiFi hanya meloloskan yang sesuai', () {
      final result = KosValidator.filterKos(
        sampleList,
        maxHarga: 2000000,
        requiredFasilitas: {'WiFi'},
      );

      expect(result.map((e) => e.id).toList(), ['1', '3']);
    });

    test('filter beberapa fasilitas memakai logika AND', () {
      final result = KosValidator.filterKos(
        sampleList,
        requiredFasilitas: {'WiFi', 'AC'},
      );

      expect(result.map((e) => e.id).toList(), ['2']);
    });
  });

  group('KosProvider filter & reset (US02-AC1..AC4)', () {
    test('menerapkan filter, mendeteksi hasil kosong, lalu resetFilters', () async {
      final repo = KosRepository(
        fetchRowsOverride: () async => sampleList.map((e) => e.toJson()).toList(),
      );
      final provider = KosProvider(repository: repo);
      await provider.loadKos();

      provider.setAreaQuery('Singaraja');
      provider.applyFilters(maxHarga: 2000000, fasilitas: {'WiFi'});
      expect(provider.items.map((e) => e.id).toList(), ['1']);
      expect(provider.isFilterEmpty, isFalse);

      provider.setAreaQuery('Ubud');
      expect(provider.items, isEmpty);
      expect(provider.isFilterEmpty, isTrue);

      provider.resetFilters();
      expect(provider.hasActiveFilters, isFalse);
      expect(provider.items, hasLength(3));
      expect(provider.isFilterEmpty, isFalse);
    });
  });
}
