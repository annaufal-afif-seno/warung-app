import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../models/produk_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/produk_provider.dart';
import '../../utils/app_theme.dart';
import '../../widgets/product_list_item.dart';
import 'tambah_stok_form.dart';
import 'edit_produk_form.dart';

/// Manajemen Stok Screen — F3 + F4 (Epic 3)
/// Search bar + list produk + FAB scan barcode (kamera) + fallback input manual.
class ManajemenStokScreen extends StatefulWidget {
  const ManajemenStokScreen({super.key});

  @override
  State<ManajemenStokScreen> createState() => _ManajemenStokScreenState();
}

class _ManajemenStokScreenState extends State<ManajemenStokScreen> {
  final _searchController = TextEditingController();
  String _query = '';
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_started) {
      _started = true;
      final idUser = context.read<AuthProvider>().currentUser?.id;
      if (idUser != null) {
        context.read<ProdukProvider>().listenProduk(idUser);
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ── Buka scanner kamera ──────────────────────────────────
  Future<void> _bukaScannerKamera() async {
    final barcode = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => const _BarcodeScannerPage()),
    );
    if (barcode != null && barcode.isNotEmpty) {
      await _handleBarcodeResult(barcode);
    }
  }

  // ── Fallback: input barcode manual ──────────────────────
  Future<void> _inputBarcodeManual() async {
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
            prefixIcon: Icon(Icons.qr_code_scanner),
          ),
          onSubmitted: (v) {
            if (v.trim().isNotEmpty) Navigator.pop(ctx, v.trim());
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                Navigator.pop(ctx, controller.text.trim());
              }
            },
            child: const Text('Lanjut'),
          ),
        ],
      ),
    );
    if (barcode != null && barcode.isNotEmpty) {
      await _handleBarcodeResult(barcode);
    }
  }

  /// Setelah dapat barcode (dari kamera atau manual):
  /// cek produk lama/baru → buka TambahStokForm — sesuai algoritma §5.5.a
  Future<void> _handleBarcodeResult(String barcode) async {
    final idUser = context.read<AuthProvider>().currentUser?.id;
    if (idUser == null) return;

    final produkProvider = context.read<ProdukProvider>();
    final produkExisting =
        await produkProvider.getProdukByBarcode(barcode, idUser);

    if (!mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TambahStokForm(
          produkAwal: produkExisting,
          barcodeAwal: barcode,
        ),
      ),
    );
  }

  void _openEdit(ProdukModel produk) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => EditProdukForm(produk: produk)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final produkProvider = context.watch<ProdukProvider>();
    final filteredList = produkProvider.searchProduk(_query);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manajemen Stok'),
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              onChanged: (v) => setState(() => _query = v),
              decoration: InputDecoration(
                hintText: 'Cari nama produk atau barcode...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _query.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _query = '');
                        },
                      )
                    : null,
              ),
            ),
          ),

          // List produk
          Expanded(
            child: produkProvider.isLoading &&
                    produkProvider.produkList.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : filteredList.isEmpty
                    ? _EmptyState(query: _query)
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: filteredList.length,
                        itemBuilder: (context, i) {
                          final produk = filteredList[i];
                          return ProductListItem(
                            produk: produk,
                            onEdit: () => _openEdit(produk),
                            onTap: () => _openEdit(produk),
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // FAB kecil: input manual
          FloatingActionButton.small(
            heroTag: 'fab_manual',
            onPressed: _inputBarcodeManual,
            backgroundColor: AppColors.neutralGrey,
            tooltip: 'Input Barcode Manual',
            child: const Icon(Icons.keyboard, color: Colors.white),
          ),
          const SizedBox(height: 8),
          // FAB utama: scan kamera
          FloatingActionButton(
            heroTag: 'fab_scan',
            onPressed: _bukaScannerKamera,
            backgroundColor: AppColors.primary,
            tooltip: 'Scan Barcode dengan Kamera',
            child: const Icon(Icons.qr_code_scanner, color: Colors.white),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────
//  HALAMAN FULL-SCREEN BARCODE SCANNER
// ──────────────────────────────────────────────────────────
class _BarcodeScannerPage extends StatefulWidget {
  const _BarcodeScannerPage();

  @override
  State<_BarcodeScannerPage> createState() => _BarcodeScannerPageState();
}

class _BarcodeScannerPageState extends State<_BarcodeScannerPage> {
  final MobileScannerController _ctrl = MobileScannerController();
  bool _detected = false;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_detected) return;
    final code = capture.barcodes.firstOrNull?.rawValue;
    if (code != null && code.isNotEmpty) {
      _detected = true;
      Navigator.pop(context, code);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Barcode'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.flash_on),
            tooltip: 'Flash',
            onPressed: () => _ctrl.toggleTorch(),
          ),
          IconButton(
            icon: const Icon(Icons.flip_camera_ios),
            tooltip: 'Ganti Kamera',
            onPressed: () => _ctrl.switchCamera(),
          ),
        ],
      ),
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          MobileScanner(
            controller: _ctrl,
            onDetect: _onDetect,
          ),

          // Overlay viewfinder
          Center(
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.secondary, width: 2),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),

          // Label
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Arahkan kamera ke barcode produk',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────
//  EMPTY STATE
// ──────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  final String query;
  const _EmptyState({required this.query});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.inventory_2_outlined,
                size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              query.isEmpty
                  ? 'Belum ada produk.\nTekan tombol scan untuk menambah produk pertama.'
                  : 'Produk tidak ditemukan untuk\n"$query"',
              style: AppTextStyles.body,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
