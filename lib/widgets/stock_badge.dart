import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

/// `StockBadge` — badge warna `secondary` jika stok ≤ threshold,
/// badge `danger` jika stok = 0. Sesuai UIUX_Design_System.md §2.3
class StockBadge extends StatelessWidget {
  final int stok;
  final int threshold;

  const StockBadge({super.key, required this.stok, this.threshold = 5});

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color fgColor;
    String label;

    if (stok == 0) {
      bgColor = AppColors.danger.withOpacity(0.12);
      fgColor = AppColors.danger;
      label = 'Stok habis';
    } else if (stok <= threshold) {
      bgColor = AppColors.secondary.withOpacity(0.18);
      fgColor = AppColors.secondary;
      label = 'Stok: $stok (hampir habis)';
    } else {
      bgColor = AppColors.primaryLight;
      fgColor = AppColors.primary;
      label = 'Stok: $stok';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: AppTextStyles.caption.copyWith(
          color: fgColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
