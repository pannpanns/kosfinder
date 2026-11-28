import 'package:kosfinder/models/kos.dart';
import 'package:kosfinder/providers/auth_provider.dart';
import 'package:kosfinder/providers/kos_provider.dart';
import 'package:kosfinder/providers/owner_kos_provider.dart';
import 'package:kosfinder/screens/kos_form_screen.dart';
import 'package:kosfinder/theme/app_theme.dart';
import 'package:kosfinder/widgets/kos_card.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

class MyKosScreen extends StatefulWidget {
  const MyKosScreen({
    super.key,
    this.onAddTap,
    this.onEditTap,
  });

  final VoidCallback? onAddTap;
  final ValueChanged<Kos>? onEditTap;

  @override
  State<MyKosScreen> createState() => _MyKosScreenState();
}

class _MyKosScreenState extends State<MyKosScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _syncLoad());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) => _syncLoad());
  }

  void _syncLoad() {
    if (!mounted) return;
    final ownerId = context.read<AuthProvider>().user?.id;
    if (ownerId == null || ownerId.isEmpty) return;

    final ownerKos = context.read<OwnerKosProvider>();
    if (ownerKos.loadedOwnerId != ownerId && !ownerKos.isLoading) {
      ownerKos.loadMyKos(ownerId);
    }
  }

  Future<void> _confirmDelete(Kos kos) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: const Text('Hapus kos ini?', style: AppTextStyles.cardTitle),
          content: Text(
            'Data "${kos.nama}" akan dihapus dari daftar kos.',
            style: AppTextStyles.body,
          ),
          actions: [
            SizedBox(
              height: 48,
              child: FilledButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: const Text('Batal'),
              ),
            ),
            SizedBox(
              height: 48,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.dangerSoft,
                  foregroundColor: AppColors.dangerText,
                ),
                onPressed: () => Navigator.of(dialogContext).pop(true),
                child: const Text('Hapus'),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) return;

    final ownerKos = context.read<OwnerKosProvider>();
    final kosProvider = context.read<KosProvider>();
    final ok = await ownerKos.removeKos(kos.id);
    if (!mounted) return;

    if (ok) {
      await kosProvider.loadKos();
      if (!mounted) return;
      _showMessage('Kos berhasil dihapus.');
    } else {
      _showMessage(
        ownerKos.errorMessage ?? 'Gagal menghapus kos. Silakan coba lagi.',
      );
    }
  }

  Future<void> _changeKamar(Kos kos, int nextKamar) async {
    final ownerKos = context.read<OwnerKosProvider>();
    final kosProvider = context.read<KosProvider>();
    final ok = await ownerKos.updateKamar(kos.id, nextKamar);
    if (!mounted) return;

    if (ok) {
      await kosProvider.loadKos();
      if (!mounted) return;
      _showMessage(
        nextKamar == 0
            ? 'Status kos diubah menjadi Penuh.'
            : 'Kamar tersedia diperbarui menjadi $nextKamar.',
      );
    } else {
      _showMessage(
        ownerKos.errorMessage ?? 'Gagal memperbarui jumlah kamar.',
      );
    }
  }

  void _showMessage(String text) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(text)));
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final ownerKos = context.watch<OwnerKosProvider>();
    final ownerId = auth.user?.id ?? '';

    return SafeArea(
      bottom: false,
      child: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () async {
          if (ownerId.isNotEmpty) {
            await ownerKos.loadMyKos(ownerId);
          }
        },
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Kos Saya', style: AppTextStyles.screenTitle),
                Material(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(999),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: auth.isLoading
                        ? null
                        : () async {
                            await auth.signOut();
                            ownerKos.clear();
                          },
                    child: Container(
                      constraints: const BoxConstraints(minHeight: 44),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: AppColors.line),
                      ),
                      child: const Text(
                        'Keluar',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.ink,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _OwnerSummaryBox(
                    value: '${ownerKos.totalKos}',
                    label: 'Kos',
                    highlighted: true,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _OwnerSummaryBox(
                    value: '${ownerKos.totalKamar}',
                    label: 'Kamar',
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _OwnerSummaryBox(
                    value: '${ownerKos.totalPenuh}',
                    label: 'Penuh',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: ownerKos.isSubmitting
                  ? null
                  : () {
                      final handler = widget.onAddTap;
                      if (handler != null) {
                        handler();
                        return;
                      }
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const KosFormScreen(),
                        ),
                      );
                    },
              icon: const Icon(Icons.add, size: 22),
              label: const Text('Tambah Kos'),
            ),
            const SizedBox(height: 18),
            if (ownerKos.isLoading && !ownerKos.hasLoaded)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 48),
                child: Column(
                  children: [
                    CircularProgressIndicator(color: AppColors.primary),
                    SizedBox(height: 14),
                    Text('Memuat...', style: AppTextStyles.supporting),
                  ],
                ),
              )
            else if (ownerKos.errorMessage != null && ownerKos.items.isEmpty)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: AppShadows.card,
                ),
                child: Column(
                  children: [
                    Text(
                      ownerKos.errorMessage!,
                      style: AppTextStyles.body,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 14),
                    ElevatedButton(
                      onPressed: ownerId.isEmpty
                          ? null
                          : () => ownerKos.loadMyKos(ownerId),
                      child: const Text('Coba lagi'),
                    ),
                  ],
                ),
              )
            else if (ownerKos.items.isEmpty)
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: AppShadows.card,
                ),
                child: const Text(
                  'Anda belum memasang kos.',
                  style: AppTextStyles.body,
                  textAlign: TextAlign.center,
                ),
              )
            else
              for (var i = 0; i < ownerKos.items.length; i++) ...[
                _buildOwnerCard(ownerKos.items[i], ownerKos.isSubmitting),
                if (i < ownerKos.items.length - 1) const SizedBox(height: 14),
              ],
          ],
        ),
      ),
    );
  }

  Widget _buildOwnerCard(Kos kos, bool isSubmitting) {
    return KosCard(
      kos: kos,
      footer: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Kamar tersedia', style: AppTextStyles.supporting),
                Row(
                  children: [
                    Semantics(
                      button: true,
                      label: 'Kurangi kamar',
                      child: IconButton(
                        tooltip: 'Kurangi kamar',
                        style: IconButton.styleFrom(
                          backgroundColor: AppColors.surface,
                          minimumSize: const Size(48, 48),
                        ),
                        onPressed: isSubmitting || kos.kamarTersedia <= 0
                            ? null
                            : () => _changeKamar(kos, kos.kamarTersedia - 1),
                        icon: const Icon(Icons.remove, size: 20),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Text(
                        kos.isPenuh ? 'Penuh' : '${kos.kamarTersedia}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: kos.isPenuh
                              ? AppColors.dangerText
                              : AppColors.ink,
                        ),
                      ),
                    ),
                    Semantics(
                      button: true,
                      label: 'Tambah kamar',
                      child: IconButton(
                        tooltip: 'Tambah kamar',
                        style: IconButton.styleFrom(
                          backgroundColor: AppColors.primaryTint,
                          foregroundColor: AppColors.primaryDeep,
                          minimumSize: const Size(48, 48),
                        ),
                        onPressed: isSubmitting
                            ? null
                            : () => _changeKamar(kos, kos.kamarTersedia + 1),
                        icon: const Icon(Icons.add, size: 20),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: FilledButton.icon(
                    onPressed: isSubmitting
                        ? null
                        : () {
                            final handler = widget.onEditTap;
                            if (handler != null) {
                              handler(kos);
                              return;
                            }
                            Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) => KosFormScreen(existingKos: kos),
                              ),
                            );
                          },
                    icon: const Icon(Icons.edit_outlined, size: 18),
                    label: const Text('Ubah'),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.dangerSoft,
                      foregroundColor: AppColors.dangerText,
                    ),
                    onPressed: isSubmitting ? null : () => _confirmDelete(kos),
                    icon: const Icon(Icons.delete_outline, size: 18),
                    label: const Text('Hapus'),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _OwnerSummaryBox extends StatelessWidget {
  const _OwnerSummaryBox({
    required this.value,
    required this.label,
    this.highlighted = false,
  });

  final String value;
  final String label;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: highlighted ? AppColors.primary : AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: highlighted ? AppColors.surface : AppColors.ink,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: highlighted ? AppColors.primaryTint : AppColors.muted,
            ),
          ),
        ],
      ),
    );
  }
}
