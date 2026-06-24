class DetailTransaksiModel {
  final String idProduk;
  final String namaProduk;
  final int jumlahUnit;
  final double hargaJualSaatTransaksi;
  final double hargaModalSaatTransaksi;
  final double subtotal;
  final double keuntungan;

  DetailTransaksiModel({
    required this.idProduk,
    required this.namaProduk,
    required this.jumlahUnit,
    required this.hargaJualSaatTransaksi,
    required this.hargaModalSaatTransaksi,
    required this.subtotal,
    required this.keuntungan,
  });

  factory DetailTransaksiModel.fromMap(Map<String, dynamic> map) {
    return DetailTransaksiModel(
      idProduk: map['idProduk'] ?? '',
      namaProduk: map['namaProduk'] ?? '',
      jumlahUnit: (map['jumlahUnit'] ?? 0).toInt(),
      hargaJualSaatTransaksi: (map['hargaJualSaatTransaksi'] ?? 0).toDouble(),
      hargaModalSaatTransaksi: (map['hargaModalSaatTransaksi'] ?? 0).toDouble(),
      subtotal: (map['subtotal'] ?? 0).toDouble(),
      keuntungan: (map['keuntungan'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'idProduk': idProduk,
      'namaProduk': namaProduk,
      'jumlahUnit': jumlahUnit,
      'hargaJualSaatTransaksi': hargaJualSaatTransaksi,
      'hargaModalSaatTransaksi': hargaModalSaatTransaksi,
      'subtotal': subtotal,
      'keuntungan': keuntungan,
    };
  }
}
