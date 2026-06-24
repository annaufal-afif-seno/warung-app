import 'package:cloud_firestore/cloud_firestore.dart';

class PembelianModel {
  final String id;
  final String idProduk;
  final String namaProduk;
  final String barcode;
  final int jumlahDus;
  final int isiPerDus;
  final double hargaDus;
  final double modalPerUnit; // hargaDus / isiPerDus
  final DateTime tanggal;

  PembelianModel({
    required this.id,
    required this.idProduk,
    required this.namaProduk,
    required this.barcode,
    required this.jumlahDus,
    required this.isiPerDus,
    required this.hargaDus,
    required this.modalPerUnit,
    required this.tanggal,
  });

  int get totalUnit => jumlahDus * isiPerDus;
  double get totalModal => hargaDus * jumlahDus;

  factory PembelianModel.fromMap(Map<String, dynamic> map, String docId) {
    return PembelianModel(
      id: docId,
      idProduk: map['idProduk'] ?? '',
      namaProduk: map['namaProduk'] ?? '',
      barcode: map['barcode'] ?? '',
      jumlahDus: (map['jumlahDus'] ?? 0).toInt(),
      isiPerDus: (map['isiPerDus'] ?? 1).toInt(),
      hargaDus: (map['hargaDus'] ?? 0).toDouble(),
      modalPerUnit: (map['modalPerUnit'] ?? 0).toDouble(),
      tanggal: (map['tanggal'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'idProduk': idProduk,
      'namaProduk': namaProduk,
      'barcode': barcode,
      'jumlahDus': jumlahDus,
      'isiPerDus': isiPerDus,
      'hargaDus': hargaDus,
      'modalPerUnit': modalPerUnit,
      'totalUnit': totalUnit,
      'totalModal': totalModal,
      'tanggal': Timestamp.fromDate(tanggal),
    };
  }
}
