import 'package:flutter/services.dart';
import 'package:kosfinder/models/kos.dart';
import 'package:kosfinder/providers/kos_provider.dart';
import 'package:kosfinder/screens/about_screen.dart';
import 'package:kosfinder/screens/kos_detail_screen.dart';
import 'package:kosfinder/theme/app_theme.dart';
import 'package:kosfinder/utils/kos_validator.dart';
import 'package:kosfinder/widgets/kos_card.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

class KosListScreen extends StatefulWidget {
  const KosListScreen({
    super.key,
    this.onKosTap,
  });

  final ValueChanged<Kos>? onKosTap;

  static String greetingForHour(int hour) {
    if (hour >= 4 && hour < 11) return 'Selamat pagi';
    if (hour >= 11 && hour < 15) return 'Selamat siang';
    if (hour >= 15 && hour < 18) return 'Selamat sore';
    return 'Selamat malam';
  }

  @override
  State<KosListScreen> createState() => _KosListScreenState();
}

class _KosListScreenState extends State<KosListScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final provider = context.read<KosProvider>();
      if (_searchController.text != provider.areaQuery) {
        _searchController.text = provider.areaQuery;
      }
      if (!provider.hasLoaded && !provider.isLoading) {
        provider.loadKos();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openAbout() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const AboutScreen()),
    );
  }

  void _resetAllFilters(KosProvider provider) {
    _searchController.clear();
    provider.resetFilters();
  }

  Future<void> _openFilterSheet(KosProvider provider) async {
    final priceController = TextEditingController(
      text: provider.maxHarga?.toString() ?? '',
    );
    var tempFasilitas = Set<String>.from(provider.selectedFasilitas);

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final bottomInset = MediaQuery.of(context).viewInsets.bottom;
            return Padding(
              padding: EdgeInsets.fromLTRB(20, 20, 20, 24 + bottomInset),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.fieldBorder,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('Filter Kos', style: AppTextStyles.cardTitle),
                  const SizedBox(height: 16),
                  const Text('Harga maksimal (Rp)', style: AppTextStyles.fieldLabel),
                  const SizedBox(height: 8),
                  TextField(
                    controller: priceController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: const InputDecoration(
                      hintText: 'Contoh: 2000000',
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('Fasilitas', style: AppTextStyles.fieldLabel),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: KosValidator.daftarFasilitas.map((item) {
                      final selected = tempFasilitas.contains(item);
                      return _FilterSheetChip(
                        label: item,
                        selected: selected,
                        onTap: () {
                          setSheetState(() {
                            if (selected) {
                              tempFasilitas.remove(item);
                            } else {
                              tempFasilitas.add(item);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 56,
                          child: FilledButton(
                            onPressed: () {
                              _searchController.clear();
                              provider.resetFilters();
                              Navigator.of(sheetContext).pop();
                            },
                            child: const Text('Hapus Filter'),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            final raw = priceController.text.trim();
                            final parsedHarga =
                                raw.isEmpty ? null : int.tryParse(raw);
                            provider.applyFilters(
                              maxHarga:
                                  parsedHarga != null && parsedHarga > 0
                                      ? parsedHarga
                                      : null,
                              fasilitas: tempFasilitas,
                            );
                            Navigator.of(sheetContext).pop();
                          },
                          child: const Text('Terapkan'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<KosProvider>(
      builder: (context, provider, _) {
        final items = provider.items;
        return SafeArea(
          bottom: false,
          child: RefreshIndicator(
            color: AppColors.primary,
            onRefresh: provider.loadKos,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 116),
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            KosListScreen.greetingForHour(DateTime.now().hour),
                            style: AppTextStyles.supporting,
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Cari kos di\nmana hari ini?',
                            style: AppTextStyles.screenTitle,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    CircleIconButton(
                      icon: Icons.info_outline,
                      semanticLabel: 'Tentang',
                      onPressed: _openAbout,
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                _buildSearchBar(provider),
                const SizedBox(height: 12),
                _buildFilterChips(provider),
                const SizedBox(height: 18),
                if (provider.isLoading && !provider.hasLoaded)
                  _buildLoadingState()
                else if (provider.errorMessage != null &&
                    provider.allItems.isEmpty)
                  _buildErrorState(provider)
                else if (provider.isEmpty)
                  _buildEmptyState(provider)
                else if (provider.isFilterEmpty)
                  _buildFilterEmptyState(provider)
                else
                  _buildKosList(items),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSearchBar(KosProvider provider) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(28),
        boxShadow: AppShadows.card,
      ),
      child: TextField(
        controller: _searchController,
        onChanged: provider.setAreaQuery,
        style: AppTextStyles.body,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: 'Ketik area, misalnya Singaraja',
          hintStyle: AppTextStyles.supporting,
          filled: false,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 16,
          ),
          prefixIcon: const Icon(
            Icons.search,
            size: 22,
            color: AppColors.muted,
          ),
          suffixIcon: provider.areaQuery.isEmpty
              ? null
              : IconButton(
                  tooltip: 'Hapus pencarian',
                  icon: const Icon(Icons.close, size: 20, color: AppColors.muted),
                  onPressed: () {
                    _searchController.clear();
                    provider.setAreaQuery('');
                  },
                ),
        ),
      ),
    );
  }

  Widget _buildFilterChips(KosProvider provider) {
    final activeExtraFacilities = provider.selectedFasilitas
        .where((item) => item != 'WiFi')
        .toList();
    final isCustomMaxHarga =
        provider.maxHarga != null &&
        provider.maxHarga != 1000000 &&
        provider.maxHarga != 2000000;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _ActionChipPill(
          label: 'Filter',
          icon: Icons.tune,
          dark: true,
          selected: false,
          onTap: () => _openFilterSheet(provider),
        ),
        _ActionChipPill(
          label: 'Maks Rp1 jt',
          selected: provider.maxHarga == 1000000,
          onTap: () => provider.setMaxHarga(
            provider.maxHarga == 1000000 ? null : 1000000,
          ),
        ),
        _ActionChipPill(
          label: 'Maks Rp2 jt',
          selected: provider.maxHarga == 2000000,
          onTap: () => provider.setMaxHarga(
            provider.maxHarga == 2000000 ? null : 2000000,
          ),
        ),
        if (isCustomMaxHarga)
          _ActionChipPill(
            label: 'Maks ${KosValidator.formatRupiah(provider.maxHarga!)}',
            selected: true,
            onTap: () => provider.setMaxHarga(null),
          ),
        _ActionChipPill(
          label: 'WiFi',
          selected: provider.selectedFasilitas.contains('WiFi'),
          onTap: () => provider.toggleFasilitas('WiFi'),
        ),
        for (final item in activeExtraFacilities)
          _ActionChipPill(
            label: item,
            selected: true,
            onTap: () => provider.toggleFasilitas(item),
          ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 64),
      child: Column(
        children: [
          CircularProgressIndicator(color: AppColors.primary),
          SizedBox(height: 16),
          Text('Memuat...', style: AppTextStyles.supporting),
        ],
      ),
    );
  }

  Widget _buildErrorState(KosProvider provider) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        children: [
          const Icon(
            Icons.wifi_off_rounded,
            size: 40,
            color: AppColors.dangerText,
          ),
          const SizedBox(height: 12),
          Text(
            provider.errorMessage ?? 'Tidak bisa terhubung. Periksa internet Anda.',
            style: AppTextStyles.body,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: provider.loadKos,
            child: const Text('Coba lagi'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(KosProvider provider) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        children: [
          const Icon(
            Icons.home_work_outlined,
            size: 40,
            color: AppColors.muted,
          ),
          const SizedBox(height: 12),
          const Text(
            'Belum ada kos yang terdaftar.',
            style: AppTextStyles.body,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: FilledButton(
              onPressed: provider.loadKos,
              child: const Text('Muat ulang'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterEmptyState(KosProvider provider) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        children: [
          const Icon(
            Icons.search_off_rounded,
            size: 40,
            color: AppColors.muted,
          ),
          const SizedBox(height: 12),
          const Text(
            'Tidak ada kos yang cocok.',
            style: AppTextStyles.body,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: FilledButton(
              onPressed: () => _resetAllFilters(provider),
              child: const Text('Hapus Filter'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKosList(List<Kos> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${items.length} kos ditemukan',
              style: AppTextStyles.fieldLabel,
            ),
            const Text('Terbaru', style: AppTextStyles.supporting),
          ],
        ),
        const SizedBox(height: 14),
        for (var i = 0; i < items.length; i++) ...[
          KosCard(
            kos: items[i],
            onTap: () {
              final customTap = widget.onKosTap;
              if (customTap != null) {
                customTap(items[i]);
                return;
              }
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => KosDetailScreen(kos: items[i]),
                ),
              );
            },
          ),
          if (i < items.length - 1) const SizedBox(height: 14),
        ],
      ],
    );
  }
}

class _ActionChipPill extends StatelessWidget {
  const _ActionChipPill({
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon,
    this.dark = false,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final IconData? icon;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    final bg = dark
        ? AppColors.ink
        : (selected ? AppColors.primaryTint : AppColors.surface);
    final fg = dark
        ? AppColors.surface
        : (selected ? AppColors.primaryDeep : AppColors.ink);

    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
        boxShadow: AppShadows.card,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(999),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Container(
            constraints: const BoxConstraints(minHeight: 44),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 17, color: fg),
                  const SizedBox(width: 6),
                ],
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: fg,
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

class _FilterSheetChip extends StatelessWidget {
  const _FilterSheetChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.primaryTint : AppColors.neutralChip,
      borderRadius: BorderRadius.circular(999),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: 44),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                selected ? Icons.check_box : Icons.check_box_outline_blank,
                size: 20,
                color: selected ? AppColors.primary : AppColors.muted,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: selected ? AppColors.primaryDeep : AppColors.ink,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
