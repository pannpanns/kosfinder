import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kosfinder/models/kos.dart';
import 'package:kosfinder/screens/kos_detail_screen.dart';
import 'package:kosfinder/theme/app_theme.dart';
import 'package:material_ui/material_ui.dart';

Kos _sampleKos({
  int kamarTersedia = 3,
  String alamat = 'Jl. Mawar No. 5',
  String area = 'Tembalang',
  String deskripsi = 'Dekat kampus, lingkungan tenang.',
}) {
  return Kos(
    id: '1',
    ownerId: 'owner-1',
    nama: 'Kos Melati',
    area: area,
    alamat: alamat,
    harga: 850000,
    kamarTersedia: kamarTersedia,
    fasilitas: const ['AC', 'WiFi', 'Kamar Mandi Dalam'],
    kontak: '081234567890',
    deskripsi: deskripsi,
    createdAt: DateTime(2026, 11, 27),
  );
}

void main() {
  group('KosDetailScreen helper (US01-AC2)', () {
    test('formatPhoneDisplay memisahkan digit tiap 4 angka', () {
      expect(KosDetailScreen.formatPhoneDisplay('081234567890'), '0812 3456 7890');
    });

    test('whatsappUri mengubah awalan 0 menjadi 62', () {
      expect(
        KosDetailScreen.whatsappUri('081234567890').toString(),
        'https://wa.me/6281234567890',
      );
      expect(
        KosDetailScreen.whatsappUri('6281234567890').toString(),
        'https://wa.me/6281234567890',
      );
    });

    test('formatFullAddress tidak menduplikasi area bila sudah ada di alamat', () {
      expect(
        KosDetailScreen.formatFullAddress(
          _sampleKos(alamat: 'Jl. Udayana No. 12, Singaraja', area: 'Singaraja'),
        ),
        'Jl. Udayana No. 12, Singaraja',
      );
      expect(
        KosDetailScreen.formatFullAddress(_sampleKos()),
        'Jl. Mawar No. 5, Tembalang',
      );
    });
  });

  group('KosDetailScreen widget (US01-AC2, US01-AC5)', () {
    testWidgets('menampilkan seluruh detail kos, fasilitas, deskripsi, dan kontak', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light(),
          home: KosDetailScreen(kos: _sampleKos()),
        ),
      );

      expect(find.text('Kos Melati'), findsOneWidget);
      expect(find.text('Jl. Mawar No. 5, Tembalang'), findsOneWidget);
      expect(find.text('Rp850.000'), findsOneWidget);
      expect(find.text('3 kamar tersedia'), findsOneWidget);
      expect(find.text('3 sisa'), findsOneWidget);
      expect(find.text('3 item'), findsOneWidget);
      expect(find.text('Tersedia'), findsOneWidget);
      expect(find.text('Kamar Mandi Dalam'), findsOneWidget);
      expect(find.text('Dekat kampus, lingkungan tenang.'), findsOneWidget);
      expect(find.text('0812 3456 7890'), findsOneWidget);
    });

    testWidgets('menampilkan status Penuh saat kamar tersedia 0', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light(),
          home: KosDetailScreen(kos: _sampleKos(kamarTersedia: 0)),
        ),
      );

      expect(find.text('Penuh'), findsNWidgets(2));
      expect(find.text('0 sisa'), findsOneWidget);
    });

    testWidgets('menampilkan pesan jelas saat WhatsApp tidak terpasang (US01-AC5)', (tester) async {
      final launched = <Uri>[];
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light(),
          home: KosDetailScreen(
            kos: _sampleKos(),
            launchUriOverride: (uri) async {
              launched.add(uri);
              return uri.scheme == 'tel';
            },
          ),
        ),
      );

      await tester.tap(find.text('Buka WhatsApp'));
      await tester.pumpAndSettle();

      expect(launched.single.toString(), 'https://wa.me/6281234567890');
      expect(
        find.text(
          'WhatsApp tidak ditemukan di perangkat ini. Anda tetap bisa memakai Telepon atau Salin nomor.',
        ),
        findsOneWidget,
      );

      await tester.pump(const Duration(seconds: 5));
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('Telepon'));
      await tester.pumpAndSettle();
      expect(launched.last.toString(), 'tel:081234567890');

      String? copiedText;
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (call) async {
          if (call.method == 'Clipboard.setData') {
            copiedText = (call.arguments as Map)['text'] as String?;
          }
          return null;
        },
      );

      await tester.tap(find.byTooltip('Salin nomor'));
      await tester.pumpAndSettle();
      expect(copiedText, '081234567890');
      expect(find.text('Nomor kontak disalin.'), findsOneWidget);

      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      );
    });
  });
}
