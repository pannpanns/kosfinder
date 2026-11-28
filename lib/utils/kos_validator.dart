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
}
