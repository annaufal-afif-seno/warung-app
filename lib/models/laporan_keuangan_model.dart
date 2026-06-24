class ChartDataPoint {
  final DateTime tanggal;
  final double totalPemasukan;
  final double totalKeuntungan;

  ChartDataPoint({
    required this.tanggal,
    required this.totalPemasukan,
    required this.totalKeuntungan,
  });
}

class LaporanKeuanganModel {
  final DateTime startDate;
  final DateTime endDate;
  final double totalPemasukan;
  final double totalModal;
  final double totalKeuntungan;
  final int jumlahTransaksi;
  final List<ChartDataPoint> chartData;

  LaporanKeuanganModel({
    required this.startDate,
    required this.endDate,
    required this.totalPemasukan,
    required this.totalModal,
    required this.totalKeuntungan,
    required this.jumlahTransaksi,
    required this.chartData,
  });

  double get marginPersen =>
      totalPemasukan > 0 ? (totalKeuntungan / totalPemasukan) * 100 : 0;
}
