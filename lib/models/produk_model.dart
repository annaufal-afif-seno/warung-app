class ProdukModel {
  final String id;
  final String nama;
  final String barcode;
  final double hargaModal;   // modal per unit
  final double hargaJual;
  final int isiPerDus;
  int stok;
  final String? fotoProdukUrl;

  ProdukModel({
    required this.id,
    required this.nama,
    required this.barcode,
    required this.hargaModal,
    required this.hargaJual,
    required this.isiPerDus,
    required this.stok,
    this.fotoProdukUrl,
  });

  factory ProdukModel.fromMap(Map<String, dynamic> map, String docId) {
    return ProdukModel(
      id: docId,
      nama: map['nama'] ?? '',
      barcode: map['barcode'] ?? '',
      hargaModal: (map['hargaModal'] ?? 0).toDouble(),
      hargaJual: (map['hargaJual'] ?? 0).toDouble(),
      isiPerDus: (map['isiPerDus'] ?? 1).toInt(),
      stok: (map['stok'] ?? 0).toInt(),
      fotoProdukUrl: map['fotoProdukUrl'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nama': nama,
      'barcode': barcode,
      'hargaModal': hargaModal,
      'hargaJual': hargaJual,
      'isiPerDus': isiPerDus,
      'stok': stok,
      'fotoProdukUrl': fotoProdukUrl,
    };
  }

  /// Apakah stok hampir habis (threshold default 5)
  bool isStokHampirHabis({int threshold = 5}) => stok <= threshold;

  double get marginKeuntungan => hargaJual - hargaModal;
}
