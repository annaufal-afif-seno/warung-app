import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/produk_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/produk_provider.dart';
import '../../utils/app_theme.dart';
import '../../utils/business_logic.dart';

/// Form Tambah Stok — F3 + F4 (Epic 3)
/// Sesuai US-04/US-05: live calculation modal per unit saat user mengetik.
/// Jika [produkAwal] diberikan (hasil scan/produk lama), field nama & harga
/// jual sebelumnya akan dipra-isi. Jika null, dianggap produk baru.
class TambahStokForm extends StatefulWidget {
  final ProdukModel? produkAwal;
  final String? barcodeAwal;

  const TambahStokForm({super.key, this.produkAwal, this.barcodeAwal});

  @override
  State<TambahStokForm> createState() => _TambahStokFormState();
}

class _TambahStokFormState extends State<TambahStokForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _namaController;
  late TextEditingController _barcodeController;
  final _jumlahDusController = TextEditingController();
  final _isiPerDusController = TextEditingController();
  final _hargaDusController = TextEditingController();
  late TextEditingController _hargaJualController;

  double _modalPerUnit = 0;
  bool _isSubmitting = false;

  bool get _isProdukBaru => widget.produkAwal == null;

  @override
  void initState() {
    super.initState();
    _namaController =
        TextEditingController(text: widget.produkAwal?.nama ?? '');
    _barcodeController = TextEditingController(
        text: widget.produkAwal?.barcode ?? widget.barcodeAwal ?? '');
    _hargaJualController = TextEditingController(
        text: widget.produkAwal != null && widget.produkAwal!.hargaJual > 0
            ? widget.produkAwal!.hargaJual.toStringAsFixed(0)
            : '');
    if (widget.produkAwal != null && widget.produkAwal!.isiPerDus > 0) {
      _isiPerDusController.text = widget.produkAwal!.isiPerDus.toString();
    }

    _hargaDusController.addListener(_recalculate);
    _isiPerDusController.addListener(_recalculate);
  }

  void _recalculate() {
    final hargaDus = double.tryParse(_hargaDusController.text) ?? 0;
    final isiPerDus = int.tryParse(_isiPerDusController.text) ?? 0;
    setState(() {
      if (hargaDus > 0 && isiPerDus > 0) {
        _modalPerUnit = hitungModalPerUnit(hargaDus, isiPerDus);
      } else {
        _modalPerUnit = 0;
      }
    });
  }

  @override
  void dispose() {
    _namaController.dispose();
    _barcodeController.dispose();
    _jumlahDusController.dispose();
    _isiPerDusController.dispose();
    _hargaDusController.dispose();
    _hargaJualController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();
    final idUser = auth.currentUser?.id;
    if (idUser == null) return;

    setState(() => _isSubmitting = true);

    final produkProvider = context.read<ProdukProvider>();
    final hargaJualText = _hargaJualController.text.trim();

    final success = await produkProvider.tambahStok(
      idUser: idUser,
      barcode: _barcodeController.text.trim(),
      jumlahDus: int.parse(_jumlahDusController.text),
      hargaDus: double.parse(_hargaDusController.text),
      isiPerDus: int.parse(_isiPerDusController.text),
      namaProduk: _namaController.text.trim(),
      hargaJualBaru: hargaJualText.isEmpty ? null : double.parse(hargaJualText),
    );

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (success) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Stok berhasil diperbarui'),
          backgroundColor: AppColors.primary,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(produkProvider.errorMessage ?? 'Gagal menyimpan'),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isProdukBaru ? 'Tambah Produk Baru' : 'Tambah Stok'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (_isProdukBaru)
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.info_outline, color: AppColors.secondary),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Barcode belum terdaftar. Lengkapi data produk baru di bawah.',
                            style: AppTextStyles.body,
                          ),
                        ),
                      ],
                    ),
                  ),
                TextFormField(
                  controller: _barcodeController,
                  decoration: const InputDecoration(
                    labelText: 'Barcode',
                    prefixIcon: Icon(Icons.qr_code),
                  ),
                  readOnly: widget.barcodeAwal != null ||
                      widget.produkAwal != null,
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Wajib diisi' : null,
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
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _jumlahDusController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Jumlah Dus',
                          prefixIcon: Icon(Icons.inventory),
                        ),
                        validator: _validatePositiveInt,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _isiPerDusController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Isi per Dus',
                        ),
                        validator: _validatePositiveInt,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _hargaDusController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Harga per Dus (Rp)',
                    prefixIcon: Icon(Icons.attach_money),
                  ),
                  validator: _validatePositiveDouble,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _hargaJualController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: _isProdukBaru
                        ? 'Harga Jual per Unit (Rp)'
                        : 'Harga Jual per Unit (Rp) — opsional, kosongkan jika tetap',
                    prefixIcon: const Icon(Icons.sell_outlined),
                  ),
                  validator: (v) {
                    if (_isProdukBaru) {
                      return _validatePositiveDouble(v);
                    }
                    if (v != null && v.trim().isNotEmpty) {
                      return _validatePositiveDouble(v);
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                // Live calculation modal per unit — US-05 AC1
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Modal per Unit (otomatis)',
                          style: AppTextStyles.caption),
                      const SizedBox(height: 4),
                      Text(
                        formatRupiah(_modalPerUnit),
                        style: AppTextStyles.numericHighlight,
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Modal per unit = Harga per Dus ÷ Isi per Dus',
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
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String? _validatePositiveInt(String? v) {
    if (v == null || v.trim().isEmpty) return 'Wajib diisi';
    final n = int.tryParse(v);
    if (n == null || n <= 0) return 'Harus angka > 0';
    return null;
  }

  String? _validatePositiveDouble(String? v) {
    if (v == null || v.trim().isEmpty) return 'Wajib diisi';
    final n = double.tryParse(v);
    if (n == null || n <= 0) return 'Harus angka > 0';
    return null;
  }
}
