import 'package:supabase_flutter/supabase_flutter.dart';

/// Kredensial Supabase wajib datang dari --dart-define agar tidak pernah masuk ke kode.
class SupabaseConfig {
  SupabaseConfig._();

  static const String url = String.fromEnvironment('SUPABASE_URL');
  static const String anonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

  static const Duration requestTimeout = Duration(seconds: 10);

  static bool get isConfigured => validate(url: url, anonKey: anonKey) == null;

  static String? validate({required String url, required String anonKey}) {
    final trimmedUrl = url.trim();
    final trimmedKey = anonKey.trim();

    if (trimmedUrl.isEmpty) {
      return 'SUPABASE_URL belum diisi. Jalankan aplikasi dengan --dart-define=SUPABASE_URL=...';
    }

    final uri = Uri.tryParse(trimmedUrl);
    if (uri == null ||
        !uri.hasScheme ||
        (uri.scheme != 'https' && uri.scheme != 'http') ||
        uri.host.isEmpty) {
      return 'Format SUPABASE_URL tidak valid. Gunakan URL lengkap seperti https://contoh.supabase.co';
    }

    if (trimmedKey.isEmpty) {
      return 'SUPABASE_ANON_KEY belum diisi. Jalankan aplikasi dengan --dart-define=SUPABASE_ANON_KEY=...';
    }

    return null;
  }

  static Future<void> initialize() async {
    final error = validate(url: url, anonKey: anonKey);
    if (error != null) {
      throw StateError(error);
    }

    await Supabase.initialize(url: url.trim(), publishableKey: anonKey.trim());
  }

  static SupabaseClient get client => Supabase.instance.client;
}
