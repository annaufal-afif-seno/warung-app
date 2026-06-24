import 'package:flutter/material.dart';
import '../models/produk_model.dart';
import '../utils/app_theme.dart';
import '../utils/business_logic.dart';
import 'stock_badge.dart';

/// `ProductListItem` — list item dengan thumbnail/icon produk, nama, stok,
/// harga jual, tombol edit. Sesuai UIUX_Design_System.md §2.3
class ProductListItem extends StatelessWidget {
  final ProdukModel produk;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onTap;

  const ProductListItem({
    super.key,
    required this.produk,
    this.onEdit,
    this.onDelete,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        onTap: onTap,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: AppColors.primaryLight,
          foregroundColor: AppColors.primary,
          child: produk.fotoProdukUrl != null
              ? ClipOval(
                  child: Image.network(
                    produk.fotoProdukUrl!,
                    width: 40,
                    height: 40,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        const Icon(Icons.inventory_2_outlined),
                  ),
                )
              : const Icon(Icons.inventory_2_outlined),
        ),
        title: Text(
          produk.nama.isEmpty ? '(Tanpa nama)' : produk.nama,
          style: AppTextStyles.heading2.copyWith(fontSize: 15),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Harga jual: ${formatRupiah(produk.hargaJual)}',
                style: AppTextStyles.caption,
              ),
              const SizedBox(height: 4),
              StockBadge(stok: produk.stok),
            ],
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (onEdit != null)
              IconButton(
                icon: const Icon(Icons.edit_outlined,
                    color: AppColors.primary),
                tooltip: 'Edit',
                onPressed: onEdit,
              ),
            if (onDelete != null)
              IconButton(
                icon: const Icon(Icons.delete_outline,
                    color: AppColors.danger),
                tooltip: 'Hapus',
                onPressed: onDelete,
              ),
          ],
        ),
      ),
    );
  }
}
