import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/dashboard_provider.dart';
import '../../utils/app_theme.dart';
import '../../utils/business_logic.dart';
import '../../widgets/summary_card.dart';
import '../../widgets/stock_badge.dart';

/// Dashboard Screen — F2 (Epic 2)
/// Algoritma data sesuai pipeline §5.5.d — terhubung ke FirestoreService.getDashboardData
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    final auth = context.read<AuthProvider>();
    final idUser = auth.currentUser?.id;
    if (idUser != null) {
      context.read<DashboardProvider>().loadDashboard(idUser);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final dashboard = context.watch<DashboardProvider>();
    final namaWarung = auth.currentUser?.namaWarung ?? 'Warung Saya';

    return Scaffold(
      appBar: AppBar(
        title: Text(namaWarung),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: dashboard.isLoading ? null : _loadData,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => _loadData(),
        child: dashboard.isLoading && dashboard.jumlahProdukTersedia == 0
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Ringkasan Hari Ini',
                        style: AppTextStyles.heading2),
                    const SizedBox(height: 12),
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 1.4,
                      children: [
                        SummaryCard(
                          icon: Icons.point_of_sale,
                          label: 'Penjualan Hari Ini',
                          value: formatRupiah(dashboard.totalPenjualanHariIni),
                          color: AppColors.primary,
                        ),
                        SummaryCard(
                          icon: Icons.trending_up,
                          label: 'Keuntungan Hari Ini',
                          value:
                              formatRupiah(dashboard.totalKeuntunganHariIni),
                          color: AppColors.secondary,
                        ),
                        SummaryCard(
                          icon: Icons.inventory_2,
                          label: 'Produk Tersedia',
                          value: '${dashboard.jumlahProdukTersedia}',
                          color: AppColors.primary,
                        ),
                        SummaryCard(
                          icon: Icons.warning_amber_rounded,
                          label: 'Stok Hampir Habis',
                          value: '${dashboard.produkHampirHabis.length}',
                          color: AppColors.danger,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const Text('Stok Hampir Habis',
                        style: AppTextStyles.heading2),
                    const SizedBox(height: 12),
                    if (dashboard.produkHampirHabis.isEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Column(
                          children: [
                            Icon(Icons.check_circle_outline,
                                color: AppColors.primary, size: 36),
                            SizedBox(height: 8),
                            Text(
                              'Semua stok aman, tidak ada produk\nyang hampir habis.',
                              style: AppTextStyles.body,
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      )
                    else
                      SizedBox(
                        height: 110,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: dashboard.produkHampirHabis.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(width: 12),
                          itemBuilder: (context, index) {
                            final produk = dashboard.produkHampirHabis[index];
                            return Container(
                              width: 160,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                    color: Colors.grey.shade200),
                              ),
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    produk.nama.isEmpty
                                        ? '(Tanpa nama)'
                                        : produk.nama,
                                    style: AppTextStyles.heading2
                                        .copyWith(fontSize: 14),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 8),
                                  StockBadge(stok: produk.stok),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
      ),
    );
  }
}
