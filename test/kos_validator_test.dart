import 'package:flutter_test/flutter_test.dart';
import 'package:kosfinder/utils/kos_validator.dart';

void main() {
  group('KosValidator form & fasilitas tambahan (US04-AC1, US04-AC8)', () {
    test('validateHarga mengembalikan pesan persis Harga harus berupa angka bila tidak valid', () {
      expect(KosValidator.validateHarga(''), 'Harga harus berupa angka');
      expect(KosValidator.validateHarga('abc'), 'Harga harus berupa angka');
      expect(KosValidator.validateHarga('0'), 'Harga harus berupa angka');
      expect(KosValidator.validateHarga('-500000'), 'Harga harus berupa angka');
      expect(KosValidator.validateHarga('850000'), isNull);
    });

    test('validateKamarTersedia menerima angka >= 0 dan menolak negatif/teks', () {
      expect(KosValidator.validateKamarTersedia('0'), isNull);
      expect(KosValidator.validateKamarTersedia('8'), isNull);
      expect(KosValidator.validateKamarTersedia('-1'), isNotNull);
      expect(KosValidator.validateKamarTersedia('banyak'), isNotNull);
    });

    test('validateKontak mewajibkan hanya angka 9 sampai 14 digit', () {
      expect(KosValidator.validateKontak('081234567890'), isNull);
      expect(KosValidator.validateKontak('08123456'), isNotNull);
      expect(KosValidator.validateKontak('081234567890123'), isNotNull);
      expect(KosValidator.validateKontak('0812-3456-789'), isNotNull);
    });

    test('validateFasilitas mewajibkan minimal 1 fasilitas', () {
      expect(KosValidator.validateFasilitas(const []), isNotNull);
      expect(KosValidator.validateFasilitas(const ['WiFi']), isNull);
      expect(KosValidator.validateFasilitas(const ['Kulkas']), isNull);
    });

    test('validateFasilitasTambahan membatasi 2-20 karakter, anti duplikat, dan maks 3', () {
      expect(
        KosValidator.validateFasilitasTambahan('A', const ['WiFi']),
        'Nama fasilitas harus 2 sampai 20 karakter.',
      );
      expect(
        KosValidator.validateFasilitasTambahan('123456789012345678901', const []),
        'Nama fasilitas harus 2 sampai 20 karakter.',
      );
      expect(
        KosValidator.validateFasilitasTambahan('wifi', const ['AC']),
        'Fasilitas ini sudah ada.',
      );
      expect(
        KosValidator.validateFasilitasTambahan('kulkas', const ['Kulkas']),
        'Fasilitas ini sudah ada.',
      );
      expect(
        KosValidator.validateFasilitasTambahan(
          'Meja',
          const ['AC', 'Kulkas', 'Dispenser', 'Dapur'],
        ),
        'Maksimal 3 fasilitas tambahan.',
      );
      expect(
        KosValidator.validateFasilitasTambahan('Kulkas', const ['AC', 'WiFi']),
        isNull,
      );
    });
  });
}
