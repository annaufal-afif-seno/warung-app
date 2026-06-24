import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../models/laporan_keuangan_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/laporan_provider.dart';
import '../../utils/app_theme.dart';

// ──────────────────────────────────────────────────────────
//  HELPER
// ──────────────────────────────────────────────────────────
String _formatRp(double v) {
  if (v >= 1000000) return 'Rp ${(v / 1000000).toStringAsFixed(1)}Jt';
  if (v >= 1000) return 'Rp ${(v / 1000).toStringAsFixed(0)}Rb';
  return 'Rp ${v.toStringAsFixed(0)}';
}

String _formatRupiah(double amount) {
  final s = amount.toStringAsFixed(0).replaceAllMapped(
    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
    (m) => '${m[1]}.',
  );
  return 'Rp $s';
}

// ══════════════════════════════════════════════════════════
//  LAPORAN SCREEN — F8
// ══════════════════════════════════════════════════════════
class LaporanScreen extends StatefulWidget {
  const LaporanScreen({super.key});

  @override
  State<LaporanScreen> createState() => _LaporanScreenState();
}

class _LaporanScreenState extends State<LaporanScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final idUser = context.read<AuthProvider>().currentUser?.id;
      if (idUser != null) {
        context.read<LaporanProvider>().muat(idUser);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Laporan Keuangan'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: () {
              final idUser =
                  context.read<AuthProvider>().currentUser?.id;
              if (idUser != null) {
                context.read<LaporanProvider>().muat(idUser);
              }
            },
          ),
        ],
      ),
      body: Consumer<LaporanProvider>(
        builder: (context, provider, _) {
          final idUser =
              context.read<AuthProvider>().currentUser?.id ?? '';

          return RefreshIndicator(
            onRefresh: () => provider.muat(idUser),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── Filter Periode ──────────────────────
                  _PeriodeFilter(idUser: idUser),
                  const SizedBox(height: 16),

                  if (provider.isLoading)
                    const SizedBox(
                      height: 200,
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (provider.errorMessage != null)
                    _ErrorCard(message: provider.errorMessage!)
                  else if (provider.laporan == null)
                    const _EmptyCard()
                  else ...[
                    // ── Kartu Ringkasan ─────────────────
                    _RingkasanCards(laporan: provider.laporan!),
                    const SizedBox(height: 16),

                    // ── Grafik ──────────────────────────
                    if (provider.laporan!.chartData.isNotEmpty) ...[
                      _GrafikCard(laporan: provider.laporan!),
                      const SizedBox(height: 16),
                    ],

                    // ── Info Periode ────────────────────
                    _PeriodeInfo(laporan: provider.laporan!),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────
//  FILTER PERIODE
// ──────────────────────────────────────────────────────────
class _PeriodeFilter extends StatelessWidget {
  final String idUser;
  const _PeriodeFilter({required this.idUser});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LaporanProvider>();
    final now = DateTime.now();
    final isHariIni = _isSameDay(provider.tanggalReferensi, now) &&
        provider.periode == 'harian';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            // Chip pilih periode
            Row(
              children: LaporanProvider.periodeOptions.map((p) {
                final selected = provider.periode == p;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: ChoiceChip(
                      label: Text(
                        _labelPeriode(p),
                        style: TextStyle(
                          fontSize: 12,
                          color: selected ? Colors.white : AppColors.neutralDark,
                        ),
                      ),
                      selected: selected,
                      selectedColor: AppColors.primary,
                      backgroundColor: AppColors.neutralBg,
                      onSelected: (_) => provider.setPeriode(p, idUser),
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 10),

            // Navigasi maju-mundur periode
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: () => provider.navigasiPeriode(-1, idUser),
                ),
                Expanded(
                  child: Text(
                    _labelTanggal(
                        provider.periode, provider.tanggalReferensi),
                    textAlign: TextAlign.center,
                    style: AppTextStyles.body
                        .copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: () => provider.navigasiPeriode(1, idUser),
                ),
              ],
            ),
            if (!isHariIni)
              TextButton.icon(
                onPressed: () => provider.resetKeHariIni(idUser),
                icon: const Icon(Icons.today, size: 16),
                label: const Text('Kembali ke Hari Ini'),
                style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    padding: EdgeInsets.zero),
              ),
          ],
        ),
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  String _labelPeriode(String p) {
    switch (p) {
      case 'harian':
        return 'Harian';
      case 'mingguan':
        return 'Mingguan';
      case 'bulanan':
        return 'Bulanan';
      case 'tahunan':
        return 'Tahunan';
      default:
        return p;
    }
  }

  String _labelTanggal(String periode, DateTime ref) {
    switch (periode) {
      case 'harian':
        return DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(ref);
      case 'mingguan':
        final wd = ref.weekday;
        final start = ref.subtract(Duration(days: wd - 1));
        final end = start.add(const Duration(days: 6));
        return '${DateFormat('d MMM', 'id_ID').format(start)} – ${DateFormat('d MMM yyyy', 'id_ID').format(end)}';
      case 'bulanan':
        return DateFormat('MMMM yyyy', 'id_ID').format(ref);
      case 'tahunan':
        return 'Tahun ${ref.year}';
      default:
        return '';
    }
  }
}

// ──────────────────────────────────────────────────────────
//  RINGKASAN CARDS
// ──────────────────────────────────────────────────────────
class _RingkasanCards extends StatelessWidget {
  final LaporanKeuanganModel laporan;
  const _RingkasanCards({required this.laporan});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _StatCard(
                label: 'Total Pemasukan',
                value: _formatRupiah(laporan.totalPemasukan),
                icon: Icons.arrow_downward,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _StatCard(
                label: 'Total Modal',
                value: _formatRupiah(laporan.totalModal),
                icon: Icons.remove_circle_outline,
                color: AppColors.neutralGrey,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                label: 'Keuntungan',
                value: _formatRupiah(laporan.totalKeuntungan),
                icon: Icons.trending_up,
                color: laporan.totalKeuntungan >= 0
                    ? AppColors.primary
                    : AppColors.danger,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _StatCard(
                label: 'Margin',
                value: '${laporan.marginPersen.toStringAsFixed(1)}%',
                icon: Icons.percent,
                color: AppColors.secondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        _StatCard(
          label: 'Jumlah Transaksi',
          value: '${laporan.jumlahTransaksi} transaksi',
          icon: Icons.receipt_long_outlined,
          color: AppColors.primary,
          fullWidth: true,
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final bool fullWidth;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: AppTextStyles.caption),
                  Text(
                    value,
                    style: AppTextStyles.body.copyWith(
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────
//  GRAFIK BATANG
// ──────────────────────────────────────────────────────────
class _GrafikCard extends StatelessWidget {
  final LaporanKeuanganModel laporan;
  const _GrafikCard({required this.laporan});

  @override
  Widget build(BuildContext context) {
    final data = laporan.chartData;
    final maxY = data
        .map((d) => d.totalPemasukan)
        .fold(0.0, (a, b) => a > b ? a : b);

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 16, 12, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Tren Pemasukan & Keuntungan',
                style: AppTextStyles.heading2),
            const SizedBox(height: 4),
            Row(
              children: [
                _LegendDot(color: AppColors.primary, label: 'Pemasukan'),
                const SizedBox(width: 16),
                _LegendDot(color: AppColors.secondary, label: 'Keuntungan'),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 180,
              child: BarChart(
                BarChartData(
                  maxY: maxY > 0 ? maxY * 1.2 : 10000,
                  barTouchData: BarTouchData(
                    touchTooltipData: BarTouchTooltipData(
                      tooltipBgColor: AppColors.neutralDark.withOpacity(0.85),
                      getTooltipItem: (group, gi, rod, ri) {
                        final d = data[group.x];
                        final label = ri == 0
                            ? 'Pemasukan: ${_formatRp(d.totalPemasukan)}'
                            : 'Keuntungan: ${_formatRp(d.totalKeuntungan)}';
                        return BarTooltipItem(
                          label,
                          const TextStyle(
                              color: Colors.white, fontSize: 12),
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (v, _) {
                          final i = v.toInt();
                          if (i < 0 || i >= data.length) {
                            return const SizedBox.shrink();
                          }
                          final d = data[i].tanggal;
                          return Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              '${d.day}/${d.month}',
                              style: const TextStyle(
                                  fontSize: 9,
                                  color: AppColors.neutralGrey),
                            ),
                          );
                        },
                        reservedSize: 24,
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 52,
                        getTitlesWidget: (v, _) => Text(
                          _formatRp(v),
                          style: const TextStyle(
                              fontSize: 9, color: AppColors.neutralGrey),
                        ),
                      ),
                    ),
                    topTitles:
                        const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles:
                        const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  gridData: FlGridData(
                    show: true,
                    horizontalInterval: maxY > 0 ? maxY / 4 : 2500,
                    getDrawingHorizontalLine: (_) => FlLine(
                      color: Colors.grey.shade200,
                      strokeWidth: 1,
                    ),
                    drawVerticalLine: false,
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: List.generate(data.length, (i) {
                    final d = data[i];
                    return BarChartGroupData(
                      x: i,
                      barRods: [
                        BarChartRodData(
                          toY: d.totalPemasukan,
                          color: AppColors.primary,
                          width: 10,
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(4)),
                        ),
                        BarChartRodData(
                          toY: d.totalKeuntungan,
                          color: AppColors.secondary,
                          width: 10,
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(4)),
                        ),
                      ],
                    );
                  }),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: AppTextStyles.caption),
      ],
    );
  }
}

// ──────────────────────────────────────────────────────────
//  INFO PERIODE & STATES
// ──────────────────────────────────────────────────────────
class _PeriodeInfo extends StatelessWidget {
  final LaporanKeuanganModel laporan;
  const _PeriodeInfo({required this.laporan});

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('d MMM yyyy', 'id_ID');
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            const Icon(Icons.date_range_outlined,
                color: AppColors.neutralGrey, size: 18),
            const SizedBox(width: 8),
            Text(
              '${fmt.format(laporan.startDate)} – ${fmt.format(laporan.endDate)}',
              style: AppTextStyles.caption,
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  final String message;
  const _ErrorCard({required this.message});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.danger.withOpacity(0.05),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.error_outline, color: AppColors.danger),
            const SizedBox(width: 12),
            Expanded(
              child: Text(message,
                  style: const TextStyle(color: AppColors.danger)),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyCard extends StatelessWidget {
  const _EmptyCard();

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(Icons.bar_chart_outlined, size: 48, color: Colors.grey),
            SizedBox(height: 12),
            Text('Belum ada transaksi di periode ini',
                style: AppTextStyles.body, textAlign: TextAlign.center),
            Text('Coba pilih periode lain atau buat transaksi terlebih dahulu.',
                style: AppTextStyles.caption, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
