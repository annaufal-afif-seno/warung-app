import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

/// `SummaryCard` — kartu ringkasan metric untuk Dashboard (F2).
/// Menampilkan label di atas dan nilai utama di bawah, dengan ikon
/// opsional di kanan. Warna dapat dikustomisasi via [valueColor].
///
/// Sesuai UIUX_Design_System.md §2.3 komponen reusable.
class SummaryCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color? iconColor;
  final Color? valueColor;
  final String? subtitle;
  final VoidCallback? onTap;

  const SummaryCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.iconColor,
    this.valueColor,
    this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveIconColor = iconColor ?? AppColors.primary;
    final effectiveValueColor = valueColor ?? AppColors.neutralDark;

    return Card(
      elevation: 1,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Baris atas: label + ikon ──────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      label,
                      style: AppTextStyles.caption.copyWith(
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.3,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(icon, color: effectiveIconColor, size: 20),
                ],
              ),
              const SizedBox(height: 8),
              // ── Nilai utama ───────────────────────────────
              Text(
                value,
                style: AppTextStyles.numericHighlight.copyWith(
                  color: effectiveValueColor,
                  fontSize: 20,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              // ── Subtitle opsional ─────────────────────────
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(
                  subtitle!,
                  style: AppTextStyles.caption,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// `SummaryCardGrid` — wrapper 2×2 grid untuk 4 SummaryCard Dashboard.
/// Memudahkan pemanggilan di DashboardScreen tanpa boilerplate GridView.
class SummaryCardGrid extends StatelessWidget {
  final List<SummaryCard> cards;

  const SummaryCardGrid({super.key, required this.cards});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 8,
      mainAxisSpacing: 8,
      childAspectRatio: 1.55,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: cards,
    );
  }
}
