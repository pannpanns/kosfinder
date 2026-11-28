import 'package:material_ui/material_ui.dart';
import 'package:kosfinder/models/kos.dart';
import 'package:kosfinder/providers/kos_provider.dart';
import 'package:kosfinder/screens/about_screen.dart';
import 'package:kosfinder/screens/kos_detail_screen.dart';
import 'package:kosfinder/theme/app_theme.dart';
import 'package:kosfinder/widgets/kos_card.dart';
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
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final provider = context.read<KosProvider>();
      if (!provider.hasLoaded && !provider.isLoading) {
        provider.loadKos();
      }
    });
  }

  void _openAbout() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const AboutScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<KosProvider>(
      builder: (context, provider, _) {
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
                const SizedBox(height: 20),
                if (provider.isLoading && !provider.hasLoaded)
                  _buildLoadingState()
                else if (provider.errorMessage != null && provider.items.isEmpty)
                  _buildErrorState(provider)
                else if (provider.items.isEmpty)
                  _buildEmptyState(provider)
                else
                  _buildKosList(provider),
              ],
            ),
          ),
        );
      },
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

  Widget _buildKosList(KosProvider provider) {
    final items = provider.items;
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
