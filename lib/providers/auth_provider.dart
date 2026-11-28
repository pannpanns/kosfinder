import 'package:flutter/foundation.dart';
import 'package:kosfinder/repositories/auth_repository.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider({AuthRepository? repository})
    : _repository = repository ?? AuthRepository() {
    _user = _repository.currentUser;
  }

  final AuthRepository _repository;

  AuthUser? _user;
  bool _isLoading = false;
  String? _errorMessage;

  AuthUser? get user => _user;
  bool get isLoggedIn => _user != null;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  static String? validateEmail(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return 'Email wajib diisi.';
    }
    final emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailPattern.hasMatch(trimmed)) {
      return 'Format email tidak valid.';
    }
    return null;
  }

  static String? validatePassword(String value) {
    if (value.isEmpty) {
      return 'Password wajib diisi.';
    }
    if (value.length < 6) {
      return 'Password minimal 6 karakter.';
    }
    return null;
  }

  void clearError() {
    if (_errorMessage == null) return;
    _errorMessage = null;
    notifyListeners();
  }

  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    final validationError = _validateCredentials(email: email, password: password);
    if (validationError != null) {
      _errorMessage = validationError;
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _user = await _repository.signIn(
        email: email.trim(),
        password: password,
      );
      return true;
    } on AuthRepositoryException catch (e) {
      _errorMessage = e.message;
      return false;
    } catch (_) {
      _errorMessage = 'Gagal masuk. Periksa koneksi internet Anda lalu coba lagi.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> signUp({
    required String email,
    required String password,
  }) async {
    final validationError = _validateCredentials(email: email, password: password);
    if (validationError != null) {
      _errorMessage = validationError;
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _user = await _repository.signUp(
        email: email.trim(),
        password: password,
      );
      return true;
    } on AuthRepositoryException catch (e) {
      _errorMessage = e.message;
      return false;
    } catch (_) {
      _errorMessage = 'Gagal mendaftar. Periksa koneksi internet Anda lalu coba lagi.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> signOut() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.signOut();
      _user = null;
      return true;
    } on AuthRepositoryException catch (e) {
      _errorMessage = e.message;
      return false;
    } catch (_) {
      _errorMessage = 'Gagal keluar dari akun. Silakan coba lagi.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  String? _validateCredentials({
    required String email,
    required String password,
  }) {
    return validateEmail(email) ?? validatePassword(password);
  }
}
