import 'dart:async';
import 'dart:io';

import 'package:kosfinder/config/supabase_config.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthUser {
  const AuthUser({
    required this.id,
    required this.email,
  });

  final String id;
  final String email;
}

class AuthRepositoryException implements Exception {
  const AuthRepositoryException(this.message);

  final String message;

  @override
  String toString() => message;
}

class AuthRepository {
  AuthRepository({
    SupabaseClient Function()? clientProvider,
    this.currentUserOverride,
    this.signInOverride,
    this.signUpOverride,
    this.signOutOverride,
    this.timeout = SupabaseConfig.requestTimeout,
  }) : _clientProvider = clientProvider ?? (() => SupabaseConfig.client);

  final SupabaseClient Function() _clientProvider;
  final AuthUser? Function()? currentUserOverride;
  final Future<AuthUser> Function(String email, String password)? signInOverride;
  final Future<AuthUser> Function(String email, String password)? signUpOverride;
  final Future<void> Function()? signOutOverride;
  final Duration timeout;

  AuthUser? get currentUser {
    final override = currentUserOverride;
    if (override != null) {
      return override();
    }
    try {
      final user = _clientProvider().auth.currentUser;
      if (user == null) return null;
      return AuthUser(id: user.id, email: user.email ?? '');
    } catch (_) {
      return null;
    }
  }

  Future<AuthUser> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final override = signInOverride;
      if (override != null) {
        return await override(email, password).timeout(timeout);
      }

      final response = await _clientProvider().auth
          .signInWithPassword(email: email, password: password)
          .timeout(timeout);
      final user = response.user;
      if (user == null) {
        throw const AuthRepositoryException(
          'Email atau password salah. Silakan periksa kembali.',
        );
      }
      return AuthUser(id: user.id, email: user.email ?? email);
    } on AuthRepositoryException {
      rethrow;
    } on AuthException catch (e) {
      throw AuthRepositoryException(_mapAuthMessage(e.message));
    } on TimeoutException {
      throw const AuthRepositoryException(
        'Koneksi terlalu lama. Periksa internet Anda lalu coba lagi.',
      );
    } on SocketException {
      throw const AuthRepositoryException(
        'Tidak ada koneksi internet. Periksa jaringan Anda lalu coba lagi.',
      );
    } catch (_) {
      throw const AuthRepositoryException(
        'Gagal masuk. Periksa koneksi internet Anda lalu coba lagi.',
      );
    }
  }

  Future<AuthUser> signUp({
    required String email,
    required String password,
  }) async {
    try {
      final override = signUpOverride;
      if (override != null) {
        return await override(email, password).timeout(timeout);
      }

      final response = await _clientProvider().auth
          .signUp(email: email, password: password)
          .timeout(timeout);
      final user = response.user;
      if (user == null) {
        throw const AuthRepositoryException(
          'Gagal membuat akun. Silakan coba lagi.',
        );
      }
      if (response.session == null) {
        throw const AuthRepositoryException(
          'Akun dibuat, silakan konfirmasi email Anda terlebih dahulu sebelum masuk.',
        );
      }
      return AuthUser(id: user.id, email: user.email ?? email);
    } on AuthRepositoryException {
      rethrow;
    } on AuthException catch (e) {
      throw AuthRepositoryException(_mapAuthMessage(e.message));
    } on TimeoutException {
      throw const AuthRepositoryException(
        'Koneksi terlalu lama. Periksa internet Anda lalu coba lagi.',
      );
    } on SocketException {
      throw const AuthRepositoryException(
        'Tidak ada koneksi internet. Periksa jaringan Anda lalu coba lagi.',
      );
    } catch (_) {
      throw const AuthRepositoryException(
        'Gagal mendaftar. Periksa koneksi internet Anda lalu coba lagi.',
      );
    }
  }

  Future<void> signOut() async {
    try {
      final override = signOutOverride;
      if (override != null) {
        await override().timeout(timeout);
        return;
      }
      await _clientProvider().auth.signOut().timeout(timeout);
    } on TimeoutException {
      throw const AuthRepositoryException(
        'Koneksi terlalu lama saat keluar. Silakan coba lagi.',
      );
    } on SocketException {
      throw const AuthRepositoryException(
        'Tidak ada koneksi internet. Periksa jaringan Anda lalu coba lagi.',
      );
    } catch (_) {
      throw const AuthRepositoryException(
        'Gagal keluar dari akun. Silakan coba lagi.',
      );
    }
  }

  static String _mapAuthMessage(String raw) {
    final lower = raw.toLowerCase();
    if (lower.contains('already registered') ||
        lower.contains('user_already_exists') ||
        lower.contains('already exists')) {
      return 'Email ini sudah terdaftar. Silakan masuk.';
    }
    if (lower.contains('invalid login credentials') ||
        lower.contains('invalid_credentials')) {
      return 'Email atau password salah. Silakan periksa kembali.';
    }
    if (lower.contains('email not confirmed')) {
      return 'Email belum dikonfirmasi. Silakan cek inbox email Anda.';
    }
    if (lower.contains('password')) {
      return 'Password minimal 6 karakter.';
    }
    if (lower.contains('email')) {
      return 'Format email tidak valid.';
    }
    return 'Proses autentikasi gagal. Periksa data dan koneksi internet Anda.';
  }
}
