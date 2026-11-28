import 'package:flutter/foundation.dart';
import 'package:kosfinder/models/kos.dart';
import 'package:kosfinder/repositories/kos_repository.dart';
import 'package:kosfinder/utils/kos_validator.dart';

class KosProvider extends ChangeNotifier {
  KosProvider({KosRepository? repository})
    : _repository = repository ?? KosRepository();

  final KosRepository _repository;

  List<Kos> _allItems = const [];
  String _areaQuery = '';
  int? _maxHarga;
  Set<String> _selectedFasilitas = {};
  bool _isLoading = false;
  bool _hasLoaded = false;
  String? _errorMessage;

  List<Kos> get allItems => _allItems;
  List<Kos> get items => KosValidator.filterKos(
    _allItems,
    areaQuery: _areaQuery,
    maxHarga: _maxHarga,
    requiredFasilitas: _selectedFasilitas,
  );

  String get areaQuery => _areaQuery;
  int? get maxHarga => _maxHarga;
  Set<String> get selectedFasilitas => Set<String>.unmodifiable(_selectedFasilitas);
  bool get isLoading => _isLoading;
  bool get hasLoaded => _hasLoaded;
  String? get errorMessage => _errorMessage;

  bool get hasActiveFilters =>
      _areaQuery.trim().isNotEmpty ||
      _maxHarga != null ||
      _selectedFasilitas.isNotEmpty;

  bool get isEmpty => _hasLoaded && _errorMessage == null && _allItems.isEmpty;

  bool get isFilterEmpty =>
      _hasLoaded &&
      _errorMessage == null &&
      _allItems.isNotEmpty &&
      items.isEmpty;

  Future<void> loadKos() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _allItems = await _repository.fetchAllKos();
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

  void setAreaQuery(String query) {
    if (_areaQuery == query) return;
    _areaQuery = query;
    notifyListeners();
  }

  void setMaxHarga(int? maxHarga) {
    if (_maxHarga == maxHarga) return;
    _maxHarga = maxHarga;
    notifyListeners();
  }

  void toggleFasilitas(String fasilitas) {
    final next = Set<String>.from(_selectedFasilitas);
    if (!next.add(fasilitas)) {
      next.remove(fasilitas);
    }
    _selectedFasilitas = next;
    notifyListeners();
  }

  void applyFilters({
    int? maxHarga,
    Set<String>? fasilitas,
  }) {
    _maxHarga = maxHarga;
    if (fasilitas != null) {
      _selectedFasilitas = Set<String>.from(fasilitas);
    }
    notifyListeners();
  }

  void resetFilters() {
    if (!hasActiveFilters) return;
    _areaQuery = '';
    _maxHarga = null;
    _selectedFasilitas = {};
    notifyListeners();
  }
}
