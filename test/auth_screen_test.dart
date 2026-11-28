import 'package:flutter_test/flutter_test.dart';
import 'package:kosfinder/main.dart';
import 'package:kosfinder/repositories/auth_repository.dart';
import 'package:kosfinder/repositories/kos_repository.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  group('AuthScreen & tab Kos Saya (US03-AC1..AC7)', () {
    testWidgets('menampilkan layar Masuk dan catatan lupa password saat belum login', (tester) async {
      final kosRepo = KosRepository(fetchRowsOverride: () async => []);
      final authRepo = AuthRepository(currentUserOverride: () => null);

      await tester.pumpWidget(
        KosFinderApp(kosRepository: kosRepo, authRepository: authRepo),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Kos Saya'));
      await tester.pumpAndSettle();

      expect(find.text('Selamat datang,\npemilik kos'), findsOneWidget);
      expect(
        find.text('Jika lupa password, daftar ulang dengan email lain.'),
        findsOneWidget,
      );

      final passwordField = tester.widget<TextField>(find.byType(TextField).last);
      expect(passwordField.obscureText, isTrue);
      await tester.tap(find.byTooltip('Lihat password'));
      await tester.pumpAndSettle();
      final visibleField = tester.widget<TextField>(find.byType(TextField).last);
      expect(visibleField.obscureText, isFalse);
    });

    testWidgets('berhasil daftar, masuk, keluar, dan Cari Kos tetap jalan tanpa login', (tester) async {
      final kosRepo = KosRepository(
        fetchRowsOverride: () async => [
          {
            'id': '1',
            'owner_id': 'owner-1',
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
      final authRepo = AuthRepository(
        currentUserOverride: () => null,
        signUpOverride: (email, password) async =>
            AuthUser(id: 'owner-1', email: email),
        signInOverride: (email, password) async =>
            AuthUser(id: 'owner-1', email: email),
        signOutOverride: () async {},
      );

      await tester.pumpWidget(
        KosFinderApp(kosRepository: kosRepo, authRepository: authRepo),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Kos Saya'));
      await tester.pumpAndSettle();

      final toggleButton = find.byType(TextButton);
      await tester.ensureVisible(toggleButton);
      await tester.pumpAndSettle();
      await tester.tap(toggleButton);
      await tester.pumpAndSettle();
      expect(find.text('Buat akun\npemilik kos'), findsOneWidget);

      await tester.enterText(find.byType(TextField).at(0), 'wayan@contoh.com');
      await tester.enterText(find.byType(TextField).at(1), 'password123');
      final daftarButton = find.widgetWithText(ElevatedButton, 'Daftar');
      await tester.ensureVisible(daftarButton);
      await tester.pumpAndSettle();
      await tester.tap(daftarButton);
      await tester.pumpAndSettle();

      expect(find.text('Keluar'), findsOneWidget);

      await tester.tap(find.text('Keluar'));
      await tester.pumpAndSettle();
      expect(find.text('Selamat datang,\npemilik kos'), findsOneWidget);

      await tester.tap(find.text('Cari Kos').last);
      await tester.pumpAndSettle();
      expect(find.text('Kos Melati'), findsOneWidget);
    });
  });
}
