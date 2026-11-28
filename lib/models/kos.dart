class Kos {
  const Kos({
    required this.id,
    this.ownerId,
    required this.nama,
    required this.area,
    required this.alamat,
    required this.harga,
    required this.kamarTersedia,
    required this.fasilitas,
    required this.kontak,
    required this.deskripsi,
    required this.createdAt,
  });

  final String id;
  final String? ownerId;
  final String nama;
  final String area;
  final String alamat;
  final int harga;
  final int kamarTersedia;
  final List<String> fasilitas;
  final String kontak;
  final String deskripsi;
  final DateTime createdAt;

  bool get isPenuh => kamarTersedia <= 0;

  String get statusKamar =>
      isPenuh ? 'Penuh' : '$kamarTersedia kamar tersedia';

  factory Kos.fromJson(Map<String, dynamic> json) {
    final rawFasilitas = json['fasilitas'];
    final fasilitasList = rawFasilitas is List
        ? rawFasilitas.map((item) => item.toString()).toList()
        : <String>[];

    final rawCreatedAt = json['created_at'];
    final parsedDate = rawCreatedAt is String
        ? DateTime.parse(rawCreatedAt)
        : DateTime.fromMillisecondsSinceEpoch(0);

    return Kos(
      id: json['id'].toString(),
      ownerId: json['owner_id']?.toString(),
      nama: (json['nama'] ?? '').toString(),
      area: (json['area'] ?? '').toString(),
      alamat: (json['alamat'] ?? '').toString(),
      harga: (json['harga'] as num).toInt(),
      kamarTersedia: (json['kamar_tersedia'] as num?)?.toInt() ?? 0,
      fasilitas: List<String>.unmodifiable(fasilitasList),
      kontak: (json['kontak'] ?? '').toString(),
      deskripsi: (json['deskripsi'] ?? '').toString(),
      createdAt: parsedDate,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'owner_id': ownerId,
      'nama': nama,
      'area': area,
      'alamat': alamat,
      'harga': harga,
      'kamar_tersedia': kamarTersedia,
      'fasilitas': fasilitas,
      'kontak': kontak,
      'deskripsi': deskripsi,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
