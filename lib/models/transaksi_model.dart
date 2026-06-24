import 'package:cloud_firestore/cloud_firestore.dart';
import 'detail_transaksi_model.dart';

enum MetodePembayaran { cash, qris, transfer }

extension MetodePembayaranExt on MetodePembayaran {
  String get label {
    switch (this) {
      case MetodePembayaran.cash:
        return 'Cash';
      case MetodePembayaran.qris:
        return 'QRIS';
      case MetodePembayaran.transfer:
        return 'Transfer';
    }
  }

  static MetodePembayaran fromString(String val) {
    switch (val) {
      case 'qris':
        return MetodePembayaran.qris;
      case 'transfer':
        return MetodePembayaran.transfer;
      default:
        return MetodePembayaran.cash;
    }
  }
}

class TransaksiModel {
  final String id;
  final String idUser;
  final DateTime tanggal;
  final double totalHarga;
  final double totalKeuntungan;
  final MetodePembayaran metodePembayaran;
  final List<DetailTransaksiModel> detail;

  TransaksiModel({
    required this.id,
    required this.idUser,
    required this.tanggal,
    required this.totalHarga,
    required this.totalKeuntungan,
    required this.metodePembayaran,
    required this.detail,
  });

  factory TransaksiModel.fromMap(Map<String, dynamic> map, String docId) {
    final detailList = (map['detail'] as List<dynamic>? ?? [])
        .map((d) => DetailTransaksiModel.fromMap(Map<String, dynamic>.from(d)))
        .toList();

    return TransaksiModel(
      id: docId,
      idUser: map['idUser'] ?? '',
      tanggal: (map['tanggal'] as Timestamp).toDate(),
      totalHarga: (map['totalHarga'] ?? 0).toDouble(),
      totalKeuntungan: (map['totalKeuntungan'] ?? 0).toDouble(),
      metodePembayaran:
          MetodePembayaranExt.fromString(map['metodePembayaran'] ?? 'cash'),
      detail: detailList,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'idUser': idUser,
      'tanggal': Timestamp.fromDate(tanggal),
      'totalHarga': totalHarga,
      'totalKeuntungan': totalKeuntungan,
      'metodePembayaran': metodePembayaran.name,
      'detail': detail.map((d) => d.toMap()).toList(),
    };
  }
}
