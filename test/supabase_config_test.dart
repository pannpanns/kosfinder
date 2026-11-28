import 'package:flutter_test/flutter_test.dart';
import 'package:kosfinder/config/supabase_config.dart';

void main() {
  group('SupabaseConfig.validate (NFR Keamanan / US01)', () {
    test('mengembalikan null jika URL https dan anonKey valid', () {
      final result = SupabaseConfig.validate(
        url: 'https://contoh-proyek.supabase.co',
        anonKey: 'contoh_anon_key_valid',
      );
      expect(result, isNull);
    });

    test('mengembalikan pesan error jika SUPABASE_URL kosong', () {
      final result = SupabaseConfig.validate(
        url: '   ',
        anonKey: 'contoh_anon_key',
      );
      expect(result, isNotNull);
      expect(result, contains('SUPABASE_URL'));
    });

    test('mengembalikan pesan error jika format URL tidak valid', () {
      final result = SupabaseConfig.validate(
        url: 'bukan-url',
        anonKey: 'contoh_anon_key',
      );
      expect(result, isNotNull);
      expect(result, contains('Format SUPABASE_URL tidak valid'));
    });

    test('mengembalikan pesan error jika SUPABASE_ANON_KEY kosong', () {
      final result = SupabaseConfig.validate(
        url: 'https://contoh-proyek.supabase.co',
        anonKey: '',
      );
      expect(result, isNotNull);
      expect(result, contains('SUPABASE_ANON_KEY'));
    });

    test('tidak menyimpan URL atau key hardcoded secara default', () {
      expect(SupabaseConfig.url, isEmpty);
      expect(SupabaseConfig.anonKey, isEmpty);
      expect(SupabaseConfig.isConfigured, isFalse);
    });
  });
}
