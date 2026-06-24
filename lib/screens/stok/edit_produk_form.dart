import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/produk_model.dart';
import '../../providers/produk_provider.dart';
import '../../utils/app_theme.dart';

/// Form Edit Produk — edit nama & harga jual tanpa mengubah stok.
/// Penambahan/pengurangan stok dilakukan lewat TambahStokForm (F4) atau
/// transaksi (F6), bukan lewat form ini.
class EditProdukForm extends StatefulWidget {
  final ProdukModel produk;

  const EditProdukForm({super.key, required this.produk});

  @override
  State<EditProdukForm> createState() => _EditProdukFormState();
}

class _EditProdukFormState extends State<EditProdukForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _namaController;
  late TextEditingController _hargaJualController;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _namaController = TextEditingController(text: widget.produk.nama);
    _hargaJualController =
        TextEditingController(text: widget.produk.hargaJual.toStringAsFixed(0));
  }

  @override
  void dispose() {
    _namaController.dispose();
    _hargaJualController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);

    final updated = ProdukModel(
      id: widget.produk.id,
      nama: _namaController.text.trim(),
      barcode: widget.produk.barcode,
      hargaModal: widget.produk.hargaModal,
      hargaJual: double.parse(_hargaJualController.text),
      isiPerDus: widget.produk.isiPerDus,
      stok: widget.produk.stok,
      fotoProdukUrl: widget.produk.fotoProdukUrl,
    );

    final provider = context.read<ProdukProvider>();
    final success = await provider.updateProduk(updated);

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (success) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Produk berhasil diperbarui'),
          backgroundColor: AppColors.primary,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage ?? 'Gagal menyimpan'),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }

  Future<void> _confirmDelete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Produk'),
        content: Text(
            'Apakah Anda yakin ingin menghapus "${widget.produk.nama}"? Tindakan ini tidak dapat dibatalkan.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.danger),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirm != true) return;
    if (!mounted) return;

    final provider = context.read<ProdukProvider>();
    final success = await provider.hapusProduk(widget.produk.id);

    if (!mounted) return;
    if (success) {
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage ?? 'Gagal menghapus'),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Produk'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: _confirmDelete,
            tooltip: 'Hapus produk',
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  initialValue: widget.produk.barcode,
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: 'Barcode',
                    prefixIcon: Icon(Icons.qr_code),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _namaController,
                  decoration: const InputDecoration(
                    labelText: 'Nama Produk',
                    prefixIcon: Icon(Icons.label_outline),
                  ),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Wajib diisi' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _hargaJualController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Harga Jual per Unit (Rp)',
                    prefixIcon: Icon(Icons.sell_outlined),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Wajib diisi';
                    final n = double.tryParse(v);
                    if (n == null || n <= 0) return 'Harus angka > 0';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.neutralBg,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Stok saat ini: ${widget.produk.stok} unit',
                          style: AppTextStyles.body),
                      const SizedBox(height: 4),
                      const Text(
                        'Untuk menambah stok, gunakan tombol "Tambah Stok" di halaman Manajemen Stok.',
                        style: AppTextStyles.caption,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _isSubmitting ? null : _submit,
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Simpan'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
