import 'package:flutter/foundation.dart';
import 'package:kosfinder/models/kos.dart';
import 'package:kosfinder/repositories/kos_repository.dart';

class OwnerKosProvider extends ChangeNotifier {
  OwnerKosProvider({KosRepository? repository})
    : _repository = repository ?? KosRepository();

  final KosRepository _repository;

  List<Kos> _items = const [];
  bool _isLoading = false;
  bool _isSubmitting = false;
  bool _hasLoaded = false;
  String? _errorMessage;
  String? _loadedOwnerId;

  List<Kos> get items => _items;
  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;
  bool get hasLoaded => _hasLoaded;
  String? get errorMessage => _errorMessage;
  String? get loadedOwnerId => _loadedOwnerId;
  bool get isEmpty => _hasLoaded && _errorMessage == null && _items.isEmpty;

  int get totalKos => _items.length;
  int get totalKamar => _items.fold(0, (sum, kos) => sum + kos.kamarTersedia);
  int get totalPenuh => _items.where((kos) => kos.isPenuh).length;

  Future<void> loadMyKos(String ownerId) async {
    _isLoading = true;
    _errorMessage = null;
    _loadedOwnerId = ownerId;
    notifyListeners();

    try {
      _items = await _repository.fetchKosByOwner(ownerId);
      _hasLoaded = true;
    } on KosRepositoryException catch (e) {
      _errorMessage = e.message;
    } catch (_) {
      _errorMessage = 'Tidak bisa terhubung. Periksa internet Anda.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addKos({
    required String ownerId,
    required KosPayload payload,
  }) async {
    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final created = await _repository.createKos(
        ownerId: ownerId,
        payload: payload,
      );
      _items = [created, ..._items];
      _hasLoaded = true;
      return true;
    } on KosRepositoryException catch (e) {
      _errorMessage = e.message;
      return false;
    } catch (_) {
      _errorMessage = 'Gagal menyimpan kos. Periksa koneksi internet Anda.';
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  Future<bool> editKos({
    required String id,
    required KosPayload payload,
  }) async {
    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updated = await _repository.updateKos(id: id, payload: payload);
      _items = _items.map((item) => item.id == id ? updated : item).toList();
      return true;
    } on KosRepositoryException catch (e) {
      _errorMessage = e.message;
      return false;
    } catch (_) {
      _errorMessage = 'Gagal memperbarui kos. Periksa koneksi internet Anda.';
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  Future<bool> removeKos(String id) async {
    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.deleteKos(id);
      _items = _items.where((item) => item.id != id).toList();
      return true;
    } on KosRepositoryException catch (e) {
      _errorMessage = e.message;
      return false;
    } catch (_) {
      _errorMessage = 'Gagal menghapus kos. Periksa koneksi internet Anda.';
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  Future<bool> updateKamar(String id, int kamarTersedia) async {
    final normalized = kamarTersedia < 0 ? 0 : kamarTersedia;
    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updated = await _repository.updateKamarTersedia(
        id: id,
        kamarTersedia: normalized,
      );
      _items = _items.map((item) => item.id == id ? updated : item).toList();
      return true;
    } on KosRepositoryException catch (e) {
      _errorMessage = e.message;
      return false;
    } catch (_) {
      _errorMessage =
          'Gagal memperbarui jumlah kamar. Periksa koneksi internet Anda.';
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  void clear() {
    _items = const [];
    _isLoading = false;
    _isSubmitting = false;
    _hasLoaded = false;
    _errorMessage = null;
    _loadedOwnerId = null;
    notifyListeners();
  }
}
