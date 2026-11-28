import 'package:flutter/services.dart';
import 'package:kosfinder/models/kos.dart';
import 'package:kosfinder/providers/kos_provider.dart';
import 'package:kosfinder/screens/about_screen.dart';
import 'package:kosfinder/theme/app_theme.dart';
import 'package:kosfinder/utils/kos_validator.dart';
import 'package:kosfinder/widgets/kos_card.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class KosDetailScreen extends StatelessWidget {
  const KosDetailScreen({
    super.key,
    required this.kos,
    this.launchUriOverride,
  });

  final Kos kos;
  final Future<bool> Function(Uri uri)? launchUriOverride;

  static String formatPhoneDisplay(String raw) {
    final digits = raw.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return raw.trim();
    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && i % 4 == 0) {
        buffer.write(' ');
      }
      buffer.write(digits[i]);
    }
    return buffer.toString();
  }

  static Uri whatsappUri(String raw) {
    final digits = raw.replaceAll(RegExp(r'[^0-9]'), '');
    final normalized =
        digits.startsWith('0') ? '62${digits.substring(1)}' : digits;
    return Uri.parse('https://wa.me/$normalized');
  }

  static Uri telUri(String raw) {
    final digits = raw.replaceAll(RegExp(r'[^0-9]'), '');
    return Uri.parse('tel:$digits');
  }

  static String formatFullAddress(Kos kos) {
    final alamat = kos.alamat.trim();
    final area = kos.area.trim();
    if (area.isEmpty) return alamat;
    if (alamat.toLowerCase().contains(area.toLowerCase())) {
      return alamat;
    }
    return '$alamat, $area';
  }

  Future<bool> _launch(Uri uri) async {
    final override = launchUriOverride;
    if (override != null) {
      return override(uri);
    }
    try {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      return false;
    }
  }

  Future<void> _openWhatsApp(BuildContext context, String kontak) async {
    final ok = await _launch(whatsappUri(kontak));
    if (!context.mounted || ok) return;
    _showMessage(
      context,
      'WhatsApp tidak ditemukan di perangkat ini. Anda tetap bisa memakai Telepon atau Salin nomor.',
    );
  }

  Future<void> _openTelepon(BuildContext context, String kontak) async {
    final ok = await _launch(telUri(kontak));
    if (!context.mounted || ok) return;
    _showMessage(
      context,
      'Aplikasi telepon tidak ditemukan. Anda tetap bisa menyalin nomor kontak.',
    );
  }

  Future<void> _copyKontak(BuildContext context, String kontak) async {
    await Clipboard.setData(ClipboardData(text: kontak));
    if (!context.mounted) return;
    _showMessage(context, 'Nomor kontak disalin.');
  }

  void _showMessage(BuildContext context, String text) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(text)));
  }

  Kos _resolveLatestKos(BuildContext context) {
    try {
      final items = context.watch<KosProvider>().allItems;
      for (final item in items) {
        if (item.id == kos.id) {
          return item;
        }
      }
    } on ProviderNotFoundException {
      // Layar ini dapat dirender mandiri di test tanpa KosProvider.
    }
    return kos;
  }

  @override
  Widget build(BuildContext context) {
    final activeKos = _resolveLatestKos(context);
    final isPenuh = activeKos.isPenuh;
    final heroBg = isPenuh ? AppColors.fullVisual : AppColors.primaryTint;
    final circle1 = isPenuh ? AppColors.fullCircle1 : AppColors.visualCircle1;
    final circle2 = isPenuh ? AppColors.fullCircle2 : AppColors.visualCircle2;
    final initialColor = isPenuh ? AppColors.muted : AppColors.primary;
    final badgeText = isPenuh
        ? 'Penuh'
        : '${activeKos.kamarTersedia} kamar tersedia';
    final badgeColor = isPenuh ? AppColors.dangerText : AppColors.primaryDeep;

    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(36),
                    ),
                    child: Container(
                      height: 290,
                      width: double.infinity,
                      color: heroBg,
                      child: Stack(
                        children: [
                          Positioned(
                            right: -45,
                            top: -55,
                            child: Container(
                              width: 240,
                              height: 240,
                              decoration: BoxDecoration(
                                color: circle2,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                          Positioned(
                            left: -35,
                            bottom: -55,
                            child: Container(
                              width: 176,
                              height: 176,
                              decoration: BoxDecoration(
                                color: circle1,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                          Center(
                            child: Text(
                              KosCard.initialFor(activeKos.nama),
                              style: TextStyle(
                                fontSize: 100,
                                fontWeight: FontWeight.w700,
                                color: initialColor,
                                height: 1,
                              ),
                            ),
                          ),
                          SafeArea(
                            bottom: false,
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      CircleIconButton(
                                        icon: Icons.chevron_left,
                                        semanticLabel: 'Kembali',
                                        onPressed: () =>
                                            Navigator.of(context).pop(),
                                      ),
                                      CircleIconButton(
                                        icon: Icons.info_outline,
                                        semanticLabel: 'Tentang',
                                        onPressed: () {
                                          Navigator.of(context).push(
                                            MaterialPageRoute<void>(
                                              builder: (_) =>
                                                  const AboutScreen(),
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 8,
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
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(activeKos.nama, style: AppTextStyles.detailTitle),
                        const SizedBox(height: 8),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(top: 3),
                              child: Icon(
                                Icons.location_on_outlined,
                                size: 18,
                                color: AppColors.muted,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                formatFullAddress(activeKos),
                                style: AppTextStyles.supporting,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              KosValidator.formatRupiah(activeKos.harga),
                              style: AppTextStyles.detailPrice,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '/bulan',
                              style: AppTextStyles.supporting.copyWith(
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        Row(
                          children: [
                            Expanded(
                              child: _SummaryBox(
                                label: 'Kamar',
                                value: '${activeKos.kamarTersedia} sisa',
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _SummaryBox(
                                label: 'Fasilitas',
                                value: '${activeKos.fasilitas.length} item',
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _SummaryBox(
                                label: 'Status',
                                value: isPenuh ? 'Penuh' : 'Tersedia',
                                valueColor: isPenuh
                                    ? AppColors.dangerText
                                    : AppColors.ink,
                              ),
                            ),
                          ],
                        ),
                        if (activeKos.fasilitas.isNotEmpty) ...[
                          const SizedBox(height: 18),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: activeKos.fasilitas
                                .map(
                                  (item) => Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.surface,
                                      borderRadius: BorderRadius.circular(999),
                                      boxShadow: AppShadows.card,
                                    ),
                                    child: Text(
                                      item,
                                      style: AppTextStyles.facilityTag.copyWith(
                                        fontSize: 15,
                                        color: AppColors.ink,
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        ],
                        if (activeKos.deskripsi.trim().isNotEmpty) ...[
                          const SizedBox(height: 18),
                          Text(
                            activeKos.deskripsi.trim(),
                            style: AppTextStyles.body,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
              boxShadow: AppShadows.bottomPanel,
            ),
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Kontak pemilik',
                          style: AppTextStyles.supporting,
                        ),
                        Text(
                          formatPhoneDisplay(activeKos.kontak),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppColors.ink,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () =>
                                _openWhatsApp(context, activeKos.kontak),
                            icon: const Icon(Icons.chat_bubble_outline, size: 20),
                            label: const Text('Buka WhatsApp'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        _SquareActionButton(
                          icon: Icons.call_outlined,
                          semanticLabel: 'Telepon',
                          onPressed: () =>
                              _openTelepon(context, activeKos.kontak),
                        ),
                        const SizedBox(width: 10),
                        _SquareActionButton(
                          icon: Icons.copy_outlined,
                          semanticLabel: 'Salin nomor',
                          onPressed: () =>
                              _copyKontak(context, activeKos.kontak),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryBox extends StatelessWidget {
  const _SummaryBox({
    required this.label,
    required this.value,
    this.valueColor = AppColors.ink,
  });

  final String label;
  final String value;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTextStyles.supporting.copyWith(fontSize: 13),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: valueColor,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _SquareActionButton extends StatelessWidget {
  const _SquareActionButton({
    required this.icon,
    required this.semanticLabel,
    required this.onPressed,
  });

  final IconData icon;
  final String semanticLabel;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticLabel,
      child: Tooltip(
        message: semanticLabel,
        child: Material(
          color: AppColors.primarySoft,
          borderRadius: BorderRadius.circular(18),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onPressed,
            child: SizedBox(
              width: 56,
              height: 56,
              child: Icon(icon, size: 22, color: AppColors.primaryDeep),
            ),
          ),
        ),
      ),
    );
  }
}
