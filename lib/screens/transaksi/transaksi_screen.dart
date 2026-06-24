import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/produk_model.dart';
import '../../models/transaksi_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/produk_provider.dart';
import '../../providers/transaksi_provider.dart';
import '../../utils/app_theme.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

// ──────────────────────────────────────────────────────────
//  HELPER
// ──────────────────────────────────────────────────────────
String _formatRupiah(double amount) {
  final s = amount.toStringAsFixed(0).replaceAllMapped(
    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
    (m) => '${m[1]}.',
  );
  return 'Rp $s';
}

// ══════════════════════════════════════════════════════════
//  TRANSAKSI SCREEN — F5 / F6 / F7
// ══════════════════════════════════════════════════════════
class TransaksiScreen extends StatefulWidget {
  const TransaksiScreen({super.key});

  @override
  State<TransaksiScreen> createState() => _TransaksiScreenState();
}

class _TransaksiScreenState extends State<TransaksiScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TransaksiProvider(),
      child: _TransaksiView(tabController: _tabController),
    );
  }
}

class _TransaksiView extends StatelessWidget {
  final TabController tabController;
  const _TransaksiView({required this.tabController});

  @override
  Widget build(BuildContext context) {
    final tx = context.watch<TransaksiProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaksi'),
        actions: [
          if (!tx.cartEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep_outlined),
              tooltip: 'Kosongkan keranjang',
              onPressed: () => _konfirmasiKosongkan(context, tx),
            ),
        ],
        bottom: TabBar(
          controller: tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: AppColors.secondary,
          tabs: [
            const Tab(icon: Icon(Icons.qr_code_scanner), text: 'Scan'),
            Tab(
              icon: Badge(
                isLabelVisible: !tx.cartEmpty,
                label: Text('${tx.totalItem}'),
                backgroundColor: AppColors.secondary,
                child: const Icon(Icons.shopping_cart_outlined),
              ),
              text: 'Keranjang',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: tabController,
        children: [
          _ScanTab(tabController: tabController),
          const _KeranjangTab(),
        ],
      ),
    );
  }

  void _konfirmasiKosongkan(BuildContext context, TransaksiProvider tx) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Kosongkan Keranjang'),
        content: const Text('Semua item di keranjang akan dihapus.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          TextButton(
            onPressed: () {
              tx.kosongkanKeranjang();
              Navigator.pop(ctx);
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.danger),
            child: const Text('Kosongkan'),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════
//  TAB 1 — SCAN PRODUK
// ══════════════════════════════════════════════════════════
class _ScanTab extends StatefulWidget {
  final TabController tabController;
  const _ScanTab({required this.tabController});

  @override
  State<_ScanTab> createState() => _ScanTabState();
}

class _ScanTabState extends State<_ScanTab> {
  final MobileScannerController _ctrl = MobileScannerController();
  bool _scanning = false;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _prosesBarcode(String barcode) async {
    if (_scanning) return;
    setState(() => _scanning = true);
    await _ctrl.stop();

    final auth = context.read<AuthProvider>();
    final idUser = auth.currentUser?.id;
    if (idUser == null) {
      _resumeScan();
      return;
    }

    // Cari dari list produk yang sudah di-cache di ProdukProvider
    final produkList = context.read<ProdukProvider>().produkList;
    ProdukModel? produk;
    for (final p in produkList) {
      if (p.barcode == barcode) {
        produk = p;
        break;
      }
    }

    if (!mounted) return;
    final tx = context.read<TransaksiProvider>();
    final snack = ScaffoldMessenger.of(context);

    if (produk == null) {
      snack.showSnackBar(SnackBar(
        content: Text('Produk barcode "$barcode" tidak ditemukan di stok.'),
        backgroundColor: AppColors.danger,
      ));
    } else if (produk.stok <= 0) {
      snack.showSnackBar(SnackBar(
        content: Text('Stok ${produk.nama} habis.'),
        backgroundColor: AppColors.danger,
      ));
    } else {
      tx.tambahKeKeranjang(produk);
      if (tx.errorMessage == null) {
        snack.showSnackBar(SnackBar(
          content: Text('${produk.nama} ditambahkan ✓'),
          backgroundColor: AppColors.primary,
          duration: const Duration(milliseconds: 1200),
        ));
        // Pindah ke tab keranjang
        widget.tabController.animateTo(1);
      } else {
        snack.showSnackBar(SnackBar(
          content: Text(tx.errorMessage!),
          backgroundColor: AppColors.danger,
        ));
      }
    }

    await Future.delayed(const Duration(milliseconds: 1000));
    _resumeScan();
  }

  void _resumeScan() {
    if (mounted) {
      setState(() => _scanning = false);
      _ctrl.start();
    }
  }

  Future<void> _inputManual() async {
    final controller = TextEditingController();
    final barcode = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Input Barcode Manual'),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Kode Barcode',
            prefixIcon: Icon(Icons.qr_code),
          ),
          onSubmitted: (v) {
            if (v.trim().isNotEmpty) Navigator.pop(ctx, v.trim());
          },
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                Navigator.pop(ctx, controller.text.trim());
              }
            },
            child: const Text('Cari'),
          ),
        ],
      ),
    );
    if (barcode != null && barcode.isNotEmpty) {
      await _prosesBarcode(barcode);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tx = context.watch<TransaksiProvider>();

    return Column(
      children: [
        // Scanner
        Expanded(
          flex: 3,
          child: Stack(
            children: [
              MobileScanner(
                controller: _ctrl,
                onDetect: (capture) {
                  final code = capture.barcodes.firstOrNull?.rawValue;
                  if (code != null) _prosesBarcode(code);
                },
              ),
              if (_scanning)
                Container(
                  color: Colors.black38,
                  child: const Center(
                      child: CircularProgressIndicator(color: Colors.white)),
                ),
              Positioned(
                bottom: 12,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Arahkan ke barcode produk',
                      style: TextStyle(color: Colors.white, fontSize: 13),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Panel bawah
        Container(
          color: AppColors.surface,
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Column(
            children: [
              OutlinedButton.icon(
                onPressed: _inputManual,
                icon: const Icon(Icons.keyboard),
                label: const Text('Input Barcode Manual'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(44),
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                ),
              ),
              const SizedBox(height: 10),
              if (tx.cartEmpty)
                const Text(
                  'Keranjang kosong — scan produk untuk mulai',
                  style: AppTextStyles.caption,
                  textAlign: TextAlign.center,
                )
              else
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('${tx.totalItem} item', style: AppTextStyles.body),
                    Text(
                      _formatRupiah(tx.totalHarga),
                      style: AppTextStyles.body.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════
//  TAB 2 — KERANJANG & CHECKOUT
// ══════════════════════════════════════════════════════════
class _KeranjangTab extends StatelessWidget {
  const _KeranjangTab();

  @override
  Widget build(BuildContext context) {
    final tx = context.watch<TransaksiProvider>();

    if (tx.cartEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.shopping_cart_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('Keranjang kosong', style: AppTextStyles.body),
            Text('Scan produk di tab Scan', style: AppTextStyles.caption),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Error banner
        if (tx.errorMessage != null)
          Container(
            width: double.infinity,
            color: AppColors.danger.withOpacity(0.1),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                const Icon(Icons.error_outline,
                    color: AppColors.danger, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(tx.errorMessage!,
                      style: const TextStyle(
                          color: AppColors.danger, fontSize: 13)),
                ),
                IconButton(
                  icon: const Icon(Icons.close,
                      color: AppColors.danger, size: 18),
                  onPressed: tx.clearError,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),

        // Daftar item
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: tx.cart.length,
            itemBuilder: (ctx, i) => _CartItemTile(item: tx.cart[i]),
          ),
        ),

        // Panel checkout
        _CheckoutPanel(),
      ],
    );
  }
}

class _CartItemTile extends StatelessWidget {
  final CartItem item;
  const _CartItemTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final tx = context.read<TransaksiProvider>();

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            // Info produk
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.produk.nama,
                    style: AppTextStyles.body
                        .copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${_formatRupiah(item.produk.hargaJual)} / unit',
                    style: AppTextStyles.caption,
                  ),
                  Text(
                    'Subtotal: ${_formatRupiah(item.subtotal)}',
                    style: AppTextStyles.caption
                        .copyWith(color: AppColors.primary),
                  ),
                ],
              ),
            ),
            // Kontrol jumlah
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(
                    item.jumlahUnit == 1
                        ? Icons.delete_outline
                        : Icons.remove_circle_outline,
                    size: 22,
                    color: AppColors.danger,
                  ),
                  onPressed: () =>
                      tx.ubahJumlah(item.produk.id, item.jumlahUnit - 1),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                SizedBox(
                  width: 32,
                  child: Text(
                    '${item.jumlahUnit}',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.body.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline,
                      size: 22, color: AppColors.primary),
                  onPressed: () =>
                      tx.ubahJumlah(item.produk.id, item.jumlahUnit + 1),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CheckoutPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final tx = context.watch<TransaksiProvider>();

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
              color: Colors.black12, offset: Offset(0, -2), blurRadius: 8)
        ],
      ),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Total & keuntungan
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total', style: AppTextStyles.heading2),
              Text(
                _formatRupiah(tx.totalHarga),
                style: AppTextStyles.numericHighlight
                    .copyWith(color: AppColors.primary),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              'Keuntungan: ${_formatRupiah(tx.totalKeuntungan)}',
              style: AppTextStyles.caption.copyWith(color: AppColors.primary),
            ),
          ),
          const Divider(height: 16),

          // Pilih metode bayar
          const Text('Metode Pembayaran',
              style: AppTextStyles.body),
          const SizedBox(height: 8),
          Row(
            children: MetodePembayaran.values.map((m) {
              final selected = tx.metodePembayaran == m;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: GestureDetector(
                    onTap: () => tx.setMetodePembayaran(m),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.symmetric(vertical: 9),
                      decoration: BoxDecoration(
                        color: selected ? AppColors.primary : AppColors.neutralBg,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: selected
                              ? AppColors.primary
                              : Colors.grey.shade300,
                        ),
                      ),
                      child: Text(
                        m.label,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: selected ? Colors.white : AppColors.neutralDark,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),

          // Tombol bayar
          ElevatedButton.icon(
            onPressed: tx.isLoading ? null : () => _checkout(context, tx),
            icon: tx.isLoading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white))
                : const Icon(Icons.check_circle_outline),
            label: Text(tx.isLoading ? 'Memproses...' : 'Bayar Sekarang'),
          ),
        ],
      ),
    );
  }

  Future<void> _checkout(BuildContext context, TransaksiProvider tx) async {
    final idUser = context.read<AuthProvider>().currentUser?.id;
    if (idUser == null) return;

    final success = await tx.prosesTransaksi(idUser);
    if (!context.mounted) return;

    if (success) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => _StrukDialog(transaksiId: tx.lastTransaksiId ?? ''),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(tx.errorMessage ?? 'Transaksi gagal'),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }
}

class _StrukDialog extends StatelessWidget {
  final String transaksiId;
  const _StrukDialog({required this.transaksiId});

  @override
  Widget build(BuildContext context) {
    final shortId = transaksiId.length > 12
        ? '${transaksiId.substring(0, 12)}...'
        : transaksiId;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check_circle, color: AppColors.primary, size: 60),
          const SizedBox(height: 12),
          const Text('Transaksi Berhasil!',
              style: AppTextStyles.heading2, textAlign: TextAlign.center),
          const SizedBox(height: 8),
          Text('ID: $shortId',
              style: AppTextStyles.caption, textAlign: TextAlign.center),
          const SizedBox(height: 4),
          const Text(
            'Stok dikurangi otomatis\n& tercatat di pembukuan.',
            style: AppTextStyles.caption,
            textAlign: TextAlign.center,
          ),
        ],
      ),
      actions: [
        ElevatedButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Transaksi Baru'),
        ),
      ],
    );
  }
}
