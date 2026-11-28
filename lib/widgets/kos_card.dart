import 'package:material_ui/material_ui.dart';
import 'package:kosfinder/models/kos.dart';
import 'package:kosfinder/theme/app_theme.dart';
import 'package:kosfinder/utils/kos_validator.dart';

class KosCard extends StatelessWidget {
  const KosCard({
    super.key,
    required this.kos,
    this.onTap,
    this.footer,
  });

  final Kos kos;
  final VoidCallback? onTap;
  final Widget? footer;

  // Abaikan awalan "Kos " agar inisial pembeda antar kos tidak selalu huruf K.
  static String initialFor(String nama) {
    final trimmed = nama.trim();
    if (trimmed.isEmpty) {
      return 'K';
    }
    final withoutPrefix = trimmed.replaceFirst(
      RegExp(r'^kos\s+', caseSensitive: false),
      '',
    );
    final source = withoutPrefix.trim().isNotEmpty ? withoutPrefix.trim() : trimmed;
    return source.substring(0, 1).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final isPenuh = kos.isPenuh;
    final visualBg = isPenuh ? AppColors.fullVisual : AppColors.primaryTint;
    final circle1 = isPenuh ? AppColors.fullCircle1 : AppColors.visualCircle1;
    final circle2 = isPenuh ? AppColors.fullCircle2 : AppColors.visualCircle2;
    final initialColor = isPenuh ? AppColors.muted : AppColors.primary;
    final badgeText = isPenuh ? 'Penuh' : '${kos.kamarTersedia} kamar';
    final badgeColor = isPenuh ? AppColors.dangerText : AppColors.primaryDeep;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppShadows.card,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(24),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    height: 120,
                    width: double.infinity,
                    color: visualBg,
                    child: Stack(
                      children: [
                        Positioned(
                          right: -30,
                          top: -42,
                          child: Container(
                            width: 148,
                            height: 148,
                            decoration: BoxDecoration(
                              color: circle2,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                        Positioned(
                          left: -26,
                          bottom: -48,
                          child: Container(
                            width: 112,
                            height: 112,
                            decoration: BoxDecoration(
                              color: circle1,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                        Center(
                          child: Text(
                            initialFor(kos.nama),
                            style: TextStyle(
                              fontSize: 56,
                              fontWeight: FontWeight.w700,
                              color: initialColor,
                              height: 1,
                            ),
                          ),
                        ),
                        Positioned(
                          left: 12,
                          top: 12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              badgeText,
                              style: AppTextStyles.badge.copyWith(
                                color: badgeColor,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 12, 8, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(kos.nama, style: AppTextStyles.cardTitle),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            size: 16,
                            color: AppColors.muted,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              kos.area,
                              style: AppTextStyles.supporting,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            KosValidator.formatRupiah(kos.harga),
                            style: AppTextStyles.cardPrice,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '/bulan',
                            style: AppTextStyles.supporting.copyWith(
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      if (kos.fasilitas.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: kos.fasilitas
                              .map(
                                (item) => Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.neutralChip,
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: Text(
                                    item,
                                    style: AppTextStyles.facilityTag,
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ],
                      if (footer != null) ...[
                        const SizedBox(height: 12),
                        footer!,
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
