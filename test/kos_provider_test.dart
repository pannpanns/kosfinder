import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:kosfinder/main.dart';
import 'package:kosfinder/providers/kos_provider.dart';
import 'package:kosfinder/repositories/kos_repository.dart';
import 'package:kosfinder/screens/about_screen.dart';
import 'package:kosfinder/screens/kos_list_screen.dart';
import 'package:kosfinder/widgets/kos_card.dart';

Map<String, dynamic> _sampleRow({
  String id = '1',
  String nama = 'Kos Melati',
  String area = 'Singaraja',
  int harga = 900000,
  int kamarTersedia = 3,
  List<String> fasilitas = const ['WiFi', 'Kamar Mandi Dalam'],
  String kontak = '081234567890',
}) {
  return {
    'id': id,
    'owner_id': null,
    'nama': nama,
    'area': area,
    'alamat': 'Jl. Udayana No. 12',
    'harga': harga,
    'kamar_tersedia': kamarTersedia,
    'fasilitas': fasilitas,
    'kontak': kontak,
    'deskripsi': 'Dekat kampus.',
    'created_at': '2026-11-27T10:00:00.000Z',
  };
}

void main() {
  group('KosProvider (US01-AC1, AC3, AC4)', () {
    test('memuat daftar kos dan membersihkan error', () async {
      final repo = KosRepository(
        fetchRowsOverride: () async => [_sampleRow()],
      );
      final provider = KosProvider(repository: repo);

      await provider.loadKos();

      expect(provider.isLoading, isFalse);
      expect(provider.hasLoaded, isTrue);
      expect(provider.errorMessage, isNull);
      expect(provider.items, hasLength(1));
      expect(provider.items.first.nama, 'Kos Melati');
    });

    test('menandai isEmpty saat data dari server kosong', () async {
      final repo = KosRepository(fetchRowsOverride: () async => []);
      final provider = KosProvider(repository: repo);

      await provider.loadKos();

      expect(provider.isEmpty, isTrue);
      expect(provider.errorMessage, isNull);
    });

    test('menyimpan pesan error saat koneksi gagal lalu pulih saat coba lagi', () async {
      var fail = true;
      final repo = KosRepository(
        fetchRowsOverride: () async {
          if (fail) throw const SocketException('offline');
          return [_sampleRow()];
        },
      );
      final provider = KosProvider(repository: repo);

      await provider.loadKos();
      expect(provider.errorMessage, isNotNull);
      expect(provider.items, isEmpty);

      fail = false;
      await provider.loadKos();
      expect(provider.errorMessage, isNull);
      expect(provider.items, hasLength(1));
    });
  });

  group('KosCard & UI T03 (US01-AC1, AC3, AC4, US06-AC1, AC2)', () {
    test('initialFor mengabaikan awalan Kos', () {
      expect(KosCard.initialFor('Kos Melati'), 'M');
      expect(KosCard.initialFor('kos anggrek'), 'A');
      expect(KosCard.initialFor('Pondok Indah'), 'P');
      expect(KosCard.initialFor(''), 'K');
    });

    test('greetingForHour menyesuaikan sapaan pagi, siang, sore, malam', () {
      expect(KosListScreen.greetingForHour(7), 'Selamat pagi');
      expect(KosListScreen.greetingForHour(13), 'Selamat siang');
      expect(KosListScreen.greetingForHour(16), 'Selamat sore');
      expect(KosListScreen.greetingForHour(21), 'Selamat malam');
      expect(KosListScreen.greetingForHour(2), 'Selamat malam');
    });

    testWidgets('menampilkan daftar kos tanpa nomor kontak dan status Penuh', (tester) async {
      final repo = KosRepository(
        fetchRowsOverride: () async => [
          _sampleRow(id: '1', nama: 'Kos Melati', kamarTersedia: 3, kontak: '081234567890'),
          _sampleRow(id: '2', nama: 'Kos Cempaka', kamarTersedia: 0, kontak: '085611223344'),
        ],
      );

      await tester.pumpWidget(KosFinderApp(kosRepository: repo));
      await tester.pumpAndSettle();

      expect(find.text('2 kos ditemukan'), findsOneWidget);
      expect(find.text('Kos Melati'), findsOneWidget);
      expect(find.text('3 kamar'), findsOneWidget);
      expect(find.text('Penuh'), findsOneWidget);
      expect(find.text('Kamar Mandi Dalam'), findsNWidgets(2));
      expect(find.text('081234567890'), findsNothing);
      expect(find.text('085611223344'), findsNothing);
    });

    testWidgets('menampilkan pesan kosong saat belum ada kos', (tester) async {
      final repo = KosRepository(fetchRowsOverride: () async => []);

      await tester.pumpWidget(KosFinderApp(kosRepository: repo));
      await tester.pumpAndSettle();

      expect(find.text('Belum ada kos yang terdaftar.'), findsOneWidget);
    });

    testWidgets('menampilkan pesan gagal koneksi dan tombol Coba lagi berfungsi', (tester) async {
      var shouldFail = true;
      final repo = KosRepository(
        fetchRowsOverride: () async {
          if (shouldFail) throw const SocketException('offline');
          return [_sampleRow(nama: 'Kos Melati')];
        },
      );

      await tester.pumpWidget(KosFinderApp(kosRepository: repo));
      await tester.pumpAndSettle();

      expect(find.text('Coba lagi'), findsOneWidget);

      shouldFail = false;
      await tester.tap(find.text('Coba lagi'));
      await tester.pumpAndSettle();

      expect(find.text('Kos Melati'), findsOneWidget);
    });

    testWidgets('halaman Tentang menampilkan NIM - Nama dan kembali menjaga tab aktif', (tester) async {
      final repo = KosRepository(fetchRowsOverride: () async => [_sampleRow()]);

      await tester.pumpWidget(KosFinderApp(kosRepository: repo));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Kos Saya'));
      await tester.pumpAndSettle();
      expect(
        find.text('Fitur masuk pemilik dan pengelolaan Kos Saya akan hadir pada Slice 3 (T08).'),
        findsOneWidget,
      );

      await tester.tap(find.byTooltip('Tentang').last);
      await tester.pumpAndSettle();

      expect(find.text(AboutScreen.creatorIdentity), findsOneWidget);
      expect(find.text('2415051069 - Putu Evan Jagadish Satriana'), findsOneWidget);

      await tester.tap(find.byTooltip('Kembali'));
      await tester.pumpAndSettle();

      expect(
        find.text('Fitur masuk pemilik dan pengelolaan Kos Saya akan hadir pada Slice 3 (T08).'),
        findsOneWidget,
      );
    });
  });
}
