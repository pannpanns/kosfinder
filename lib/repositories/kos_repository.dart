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

class KosPayload {
  const KosPayload({
    required this.nama,
    required this.area,
    required this.alamat,
    required this.harga,
    required this.kamarTersedia,
    required this.fasilitas,
    required this.kontak,
    this.deskripsi = '',
  });

  final String nama;
  final String area;
  final String alamat;
  final int harga;
  final int kamarTersedia;
  final List<String> fasilitas;
  final String kontak;
  final String deskripsi;

  Map<String, dynamic> toDataMap() {
    return {
      'nama': nama.trim(),
      'area': area.trim(),
      'alamat': alamat.trim(),
      'harga': harga,
      'kamar_tersedia': kamarTersedia,
      'fasilitas': fasilitas,
      'kontak': kontak.trim(),
      'deskripsi': deskripsi.trim(),
    };
  }
}

class KosRepository {
  KosRepository({
    SupabaseClient Function()? clientProvider,
    this.fetchRowsOverride,
    this.fetchByOwnerOverride,
    this.createOverride,
    this.updateOverride,
    this.deleteOverride,
    this.timeout = SupabaseConfig.requestTimeout,
  }) : _clientProvider = clientProvider ?? (() => SupabaseConfig.client);

  final SupabaseClient Function() _clientProvider;
  final Future<List<Map<String, dynamic>>> Function()? fetchRowsOverride;
  final Future<List<Map<String, dynamic>>> Function(String ownerId)?
  fetchByOwnerOverride;
  final Future<Map<String, dynamic>> Function(
    String ownerId,
    Map<String, dynamic> payload,
  )?
  createOverride;
  final Future<Map<String, dynamic>?> Function(
    String id,
    Map<String, dynamic> payload,
  )?
  updateOverride;
  final Future<bool> Function(String id)? deleteOverride;
  final Duration timeout;

  Future<List<Kos>> fetchAllKos() async {
    return _guard(() async {
      final rows = await _loadRows().timeout(timeout);
      return rows.map(Kos.fromJson).toList();
    }, fallbackMessage: 'Gagal memuat data kos dari server. Silakan coba lagi.');
  }

  Future<List<Kos>> fetchKosByOwner(String ownerId) async {
    return _guard(() async {
      final override = fetchByOwnerOverride;
      final rows = override != null
          ? await override(ownerId).timeout(timeout)
          : List<Map<String, dynamic>>.from(
              await _clientProvider()
                  .from('kos')
                  .select()
                  .eq('owner_id', ownerId)
                  .order('created_at', ascending: false)
                  .timeout(timeout),
            );
      return rows.map(Kos.fromJson).toList();
    }, fallbackMessage: 'Gagal memuat daftar kos Anda. Silakan coba lagi.');
  }

  Future<Kos> createKos({
    required String ownerId,
    required KosPayload payload,
  }) async {
    return _guard(() async {
      final body = {
        ...payload.toDataMap(),
        'owner_id': ownerId,
      };
      final override = createOverride;
      final row = override != null
          ? await override(ownerId, body).timeout(timeout)
          : Map<String, dynamic>.from(
              await _clientProvider()
                  .from('kos')
                  .insert(body)
                  .select()
                  .single()
                  .timeout(timeout),
            );
      return Kos.fromJson(row);
    }, fallbackMessage: 'Gagal menyimpan data kos. Silakan coba lagi.');
  }

  Future<Kos> updateKos({
    required String id,
    required KosPayload payload,
  }) async {
    return _guard(() async {
      final body = payload.toDataMap();
      final override = updateOverride;
      final Map<String, dynamic>? row;
      if (override != null) {
        row = await override(id, body).timeout(timeout);
      } else {
        final raw = await _clientProvider()
            .from('kos')
            .update(body)
            .eq('id', id)
            .select()
            .maybeSingle()
            .timeout(timeout);
        row = raw == null ? null : Map<String, dynamic>.from(raw);
      }

      if (row == null) {
        throw const KosRepositoryException(
          'Anda tidak memiliki izin untuk mengubah kos ini.',
        );
      }
      return Kos.fromJson(row);
    }, fallbackMessage: 'Gagal memperbarui data kos. Silakan coba lagi.');
  }

  Future<void> deleteKos(String id) async {
    return _guard(() async {
      final override = deleteOverride;
      if (override != null) {
        final deleted = await override(id).timeout(timeout);
        if (!deleted) {
          throw const KosRepositoryException(
            'Anda tidak memiliki izin untuk menghapus kos ini.',
          );
        }
        return;
      }

      final deletedRows = await _clientProvider()
          .from('kos')
          .delete()
          .eq('id', id)
          .select('id')
          .timeout(timeout);
      if ((deletedRows as List).isEmpty) {
        throw const KosRepositoryException(
          'Anda tidak memiliki izin untuk menghapus kos ini.',
        );
      }
    }, fallbackMessage: 'Gagal menghapus kos. Silakan coba lagi.');
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

  Future<T> _guard<T>(
    Future<T> Function() action, {
    required String fallbackMessage,
  }) async {
    try {
      return await action();
    } on KosRepositoryException {
      rethrow;
    } on TimeoutException {
      throw const KosRepositoryException(
        'Koneksi terlalu lama. Periksa internet Anda lalu coba lagi.',
      );
    } on SocketException {
      throw const KosRepositoryException(
        'Tidak ada koneksi internet. Periksa jaringan Anda lalu coba lagi.',
      );
    } on PostgrestException catch (e) {
      final msg = e.message.toLowerCase();
      if (e.code == '42501' ||
          msg.contains('row-level security') ||
          msg.contains('permission denied')) {
        throw const KosRepositoryException(
          'Anda tidak memiliki izin untuk mengubah atau menghapus kos ini.',
        );
      }
      throw KosRepositoryException(fallbackMessage);
    } catch (_) {
      throw const KosRepositoryException(
        'Tidak dapat terhubung ke server. Periksa koneksi internet Anda lalu coba lagi.',
      );
    }
  }
}
