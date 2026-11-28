import 'dart:async';
import 'dart:io';

import 'package:kosfinder/config/supabase_config.dart';
import 'package:kosfinder/models/kos.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class KosRepositoryException implements Exception {
  const KosRepositoryException(this.message);

  final String message;

  @override
  String toString() => message;
}

class KosRepository {
  KosRepository({
    SupabaseClient Function()? clientProvider,
    this.fetchRowsOverride,
    this.timeout = SupabaseConfig.requestTimeout,
  }) : _clientProvider = clientProvider ?? (() => SupabaseConfig.client);

  final SupabaseClient Function() _clientProvider;
  final Future<List<Map<String, dynamic>>> Function()? fetchRowsOverride;
  final Duration timeout;

  Future<List<Kos>> fetchAllKos() async {
    try {
      final rows = await _loadRows().timeout(timeout);
      return rows.map(Kos.fromJson).toList();
    } on TimeoutException {
      throw const KosRepositoryException(
        'Koneksi terlalu lama. Periksa internet Anda lalu coba lagi.',
      );
    } on SocketException {
      throw const KosRepositoryException(
        'Tidak ada koneksi internet. Periksa jaringan Anda lalu coba lagi.',
      );
    } on PostgrestException {
      throw const KosRepositoryException(
        'Gagal memuat data kos dari server. Silakan coba lagi.',
      );
    } catch (_) {
      throw const KosRepositoryException(
        'Tidak dapat terhubung ke server. Periksa koneksi internet Anda lalu coba lagi.',
      );
    }
  }

  Future<List<Map<String, dynamic>>> _loadRows() async {
    final override = fetchRowsOverride;
    if (override != null) {
      return override();
    }

    final data = await _clientProvider()
        .from('kos')
        .select()
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(data);
  }
}
