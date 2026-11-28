import 'package:flutter/foundation.dart';
import 'package:kosfinder/models/kos.dart';
import 'package:kosfinder/repositories/kos_repository.dart';

class KosProvider extends ChangeNotifier {
  KosProvider({KosRepository? repository})
    : _repository = repository ?? KosRepository();

  final KosRepository _repository;

  List<Kos> _items = const [];
  bool _isLoading = false;
  bool _hasLoaded = false;
  String? _errorMessage;

  List<Kos> get items => _items;
  bool get isLoading => _isLoading;
  bool get hasLoaded => _hasLoaded;
  String? get errorMessage => _errorMessage;
  bool get isEmpty => _hasLoaded && _errorMessage == null && _items.isEmpty;

  Future<void> loadKos() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _items = await _repository.fetchAllKos();
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
}
