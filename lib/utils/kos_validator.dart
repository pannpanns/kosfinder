import 'package:kosfinder/models/kos.dart';

class KosValidator {
  KosValidator._();

  // Label ditulis penuh sesuai PRD agar tidak membingungkan pengguna.
  static const List<String> daftarFasilitas = [
    'AC',
    'WiFi',
    'Kamar Mandi Dalam',
    'Parkir',
  ];

  static const int maxFasilitasTambahan = 3;

  static String formatRupiah(int harga) {
    final isNegative = harga < 0;
    final digits = harga.abs().toString();
    final buffer = StringBuffer();

    for (var i = 0; i < digits.length; i++) {
      final remaining = digits.length - i;
      buffer.write(digits[i]);
      if (remaining > 1 && remaining % 3 == 1) {
        buffer.write('.');
      }
    }

    final prefix = isNegative ? '-Rp' : 'Rp';
    return '$prefix${buffer.toString()}';
  }

  static String formatHargaPerBulan(int harga) {
    return '${formatRupiah(harga)} / bulan';
  }

  static List<Kos> filterKos(
    List<Kos> source, {
    String areaQuery = '',
    int? maxHarga,
    Set<String> requiredFasilitas = const {},
  }) {
    final normalizedQuery = areaQuery.trim().toLowerCase();
    final normalizedRequired = requiredFasilitas
        .map((item) => item.trim().toLowerCase())
        .where((item) => item.isNotEmpty)
        .toSet();

    return source.where((kos) {
      if (normalizedQuery.isNotEmpty &&
          !kos.area.toLowerCase().contains(normalizedQuery)) {
        return false;
      }

      if (maxHarga != null && kos.harga > maxHarga) {
        return false;
      }

      if (normalizedRequired.isNotEmpty) {
        final owned = kos.fasilitas
            .map((item) => item.trim().toLowerCase())
            .toSet();
        for (final req in normalizedRequired) {
          if (!owned.contains(req)) {
            return false;
          }
        }
      }

      return true;
    }).toList();
  }

  static String? validateRequired(String value, String fieldName) {
    if (value.trim().isEmpty) {
      return '$fieldName wajib diisi.';
    }
    return null;
  }

  static String? validateHarga(String value) {
    final trimmed = value.trim();
    final parsed = int.tryParse(trimmed);
    if (parsed == null || parsed <= 0) {
      return 'Harga harus berupa angka';
    }
    return null;
  }

  static String? validateKamarTersedia(String value) {
    final trimmed = value.trim();
    final parsed = int.tryParse(trimmed);
    if (parsed == null || parsed < 0) {
      return 'Jumlah kamar harus berupa angka 0 atau lebih.';
    }
    return null;
  }

  static String? validateKontak(String value) {
    final trimmed = value.trim();
    if (!RegExp(r'^[0-9]{9,14}$').hasMatch(trimmed)) {
      return 'No. HP / WhatsApp harus berupa 9 sampai 14 digit angka.';
    }
    return null;
  }

  static String? validateFasilitas(List<String> selected) {
    if (selected.isEmpty) {
      return 'Pilih minimal 1 fasilitas.';
    }
    return null;
  }

  static List<String> customFacilitiesFrom(List<String> selected) {
    final standardLower = daftarFasilitas
        .map((item) => item.toLowerCase())
        .toSet();
    return selected
        .where((item) => !standardLower.contains(item.trim().toLowerCase()))
        .toList();
  }

  static String? validateFasilitasTambahan(
    String value,
    List<String> existingFacilities,
  ) {
    final trimmed = value.trim();
    if (trimmed.length < 2 || trimmed.length > 20) {
      return 'Nama fasilitas harus 2 sampai 20 karakter.';
    }

    if (customFacilitiesFrom(existingFacilities).length >=
        maxFasilitasTambahan) {
      return 'Maksimal $maxFasilitasTambahan fasilitas tambahan.';
    }

    final normalized = trimmed.toLowerCase();
    final allKnown = {
      ...daftarFasilitas.map((item) => item.toLowerCase()),
      ...existingFacilities.map((item) => item.trim().toLowerCase()),
    };
    if (allKnown.contains(normalized)) {
      return 'Fasilitas ini sudah ada.';
    }

    return null;
  }
}
