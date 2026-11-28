import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:kosfinder/providers/auth_provider.dart';
import 'package:kosfinder/repositories/auth_repository.dart';

void main() {
  group('AuthProvider validasi & sesi (US03-AC1..AC4, US03-AC6)', () {
    test('mempertahankan sesi aktif dari repository saat dibuka ulang (US03-AC4)', () {
      final repo = AuthRepository(
        currentUserOverride: () => const AuthUser(
          id: 'owner-1',
          email: 'wayan@contoh.com',
        ),
      );
      final provider = AuthProvider(repository: repo);

      expect(provider.isLoggedIn, isTrue);
      expect(provider.user?.email, 'wayan@contoh.com');
    });

    test('menolak email tidak valid dan password kurang dari 6 karakter', () async {
      final provider = AuthProvider(repository: AuthRepository());

      final badEmail = await provider.signIn(email: 'bukan-email', password: 'password123');
      expect(badEmail, isFalse);
      expect(provider.errorMessage, 'Format email tidak valid.');

      final shortPass = await provider.signUp(email: 'wayan@contoh.com', password: '123');
      expect(shortPass, isFalse);
      expect(provider.errorMessage, 'Password minimal 6 karakter.');
    });

    test('daftar berhasil dan keluar membersihkan user', () async {
      var signOutCalled = false;
      final repo = AuthRepository(
        signUpOverride: (email, password) async =>
            AuthUser(id: 'owner-1', email: email),
        signOutOverride: () async {
          signOutCalled = true;
        },
      );
      final provider = AuthProvider(repository: repo);

      final signedUp = await provider.signUp(
        email: 'wayan@contoh.com',
        password: 'password123',
      );
      expect(signedUp, isTrue);
      expect(provider.isLoggedIn, isTrue);

      final loggedOut = await provider.signOut();
      expect(loggedOut, isTrue);
      expect(signOutCalled, isTrue);
      expect(provider.isLoggedIn, isFalse);
      expect(provider.user, isNull);
    });

    test('email sudah terdaftar menampilkan pesan bahasa Indonesia sesuai PRD (US03-AC3)', () async {
      final repo = AuthRepository(
        signUpOverride: (email, password) async {
          throw const AuthRepositoryException(
            'Email ini sudah terdaftar. Silakan masuk.',
          );
        },
      );
      final provider = AuthProvider(repository: repo);

      final ok = await provider.signUp(
        email: 'wayan@contoh.com',
        password: 'password123',
      );
      expect(ok, isFalse);
      expect(provider.errorMessage, 'Email ini sudah terdaftar. Silakan masuk.');
    });

    test('kegagalan koneksi saat masuk menghasilkan pesan jelas tanpa crash', () async {
      final repo = AuthRepository(
        signInOverride: (email, password) async {
          throw const SocketException('offline');
        },
      );
      final provider = AuthProvider(repository: repo);

      final ok = await provider.signIn(
        email: 'wayan@contoh.com',
        password: 'password123',
      );
      expect(ok, isFalse);
      expect(provider.errorMessage, contains('Tidak ada koneksi internet'));
    });
  });
}
