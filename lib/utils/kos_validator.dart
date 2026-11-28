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
}
