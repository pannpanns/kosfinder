import 'package:flutter/services.dart';
import 'package:kosfinder/models/kos.dart';
import 'package:kosfinder/providers/auth_provider.dart';
import 'package:kosfinder/providers/kos_provider.dart';
import 'package:kosfinder/providers/owner_kos_provider.dart';
import 'package:kosfinder/repositories/kos_repository.dart';
import 'package:kosfinder/screens/about_screen.dart';
import 'package:kosfinder/theme/app_theme.dart';
import 'package:kosfinder/utils/kos_validator.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

class KosFormScreen extends StatefulWidget {
  const KosFormScreen({
    super.key,
    this.existingKos,
  });

  final Kos? existingKos;

  @override
  State<KosFormScreen> createState() => _KosFormScreenState();
}

class _KosFormScreenState extends State<KosFormScreen> {
  late final TextEditingController _namaController;
  late final TextEditingController _areaController;
  late final TextEditingController _alamatController;
  late final TextEditingController _hargaController;
  late final TextEditingController _kamarController;
  late final TextEditingController _kontakController;
  late final TextEditingController _deskripsiController;
  late final List<String> _selectedFasilitas;

  String? _namaError;
  String? _areaError;
  String? _alamatError;
  String? _hargaError;
  String? _kamarError;
  String? _kontakError;
  String? _fasilitasError;
  String? _submitError;

  bool get _isEdit => widget.existingKos != null;

  @override
  void initState() {
    super.initState();
    final kos = widget.existingKos;
    _namaController = TextEditingController(text: kos?.nama ?? '');
    _areaController = TextEditingController(text: kos?.area ?? '');
    _alamatController = TextEditingController(text: kos?.alamat ?? '');
    _hargaController = TextEditingController(
      text: kos != null ? kos.harga.toString() : '',
    );
    _kamarController = TextEditingController(
      text: kos != null ? kos.kamarTersedia.toString() : '',
    );
    _kontakController = TextEditingController(text: kos?.kontak ?? '');
    _deskripsiController = TextEditingController(text: kos?.deskripsi ?? '');
    _selectedFasilitas = List<String>.from(kos?.fasilitas ?? const []);
  }

  @override
  void dispose() {
    _namaController.dispose();
    _areaController.dispose();
    _alamatController.dispose();
    _hargaController.dispose();
    _kamarController.dispose();
    _kontakController.dispose();
    _deskripsiController.dispose();
    super.dispose();
  }

  void _toggleStandardFacility(String item) {
    setState(() {
      if (_selectedFasilitas.contains(item)) {
        _selectedFasilitas.remove(item);
      } else {
        _selectedFasilitas.add(item);
      }
      _fasilitasError = null;
    });
  }

  void _removeCustomFacility(String item) {
    setState(() {
      _selectedFasilitas.remove(item);
      _fasilitasError = null;
    });
  }

  Future<void> _openAddFacilityDialog() async {
    final controller = TextEditingController();
    String? dialogError;

    final added = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: AppColors.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              title: const Text(
                'Tambah Fasilitas',
                style: AppTextStyles.cardTitle,
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Nama fasilitas', style: AppTextStyles.fieldLabel),
                  const SizedBox(height: 8),
                  TextField(
                    controller: controller,
                    autofocus: true,
                    textCapitalization: TextCapitalization.words,
                    onChanged: (_) {
                      if (dialogError != null) {
                        setDialogState(() => dialogError = null);
                      }
                    },
                    decoration: InputDecoration(
                      hintText: 'Contoh: Kulkas',
                      errorText: dialogError,
                    ),
                  ),
                ],
              ),
              actions: [
                SizedBox(
                  height: 48,
                  child: FilledButton(
                    onPressed: () => Navigator.of(dialogContext).pop(),
                    child: const Text('Batal'),
                  ),
                ),
                SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(96, 48),
                    ),
                    onPressed: () {
                      final error = KosValidator.validateFasilitasTambahan(
                        controller.text,
                        _selectedFasilitas,
                      );
                      if (error != null) {
                        setDialogState(() => dialogError = error);
                        return;
                      }
                      Navigator.of(dialogContext).pop(controller.text.trim());
                    },
                    child: const Text('Tambah'),
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    if (added != null && added.isNotEmpty && mounted) {
      setState(() {
        _selectedFasilitas.add(added);
        _fasilitasError = null;
      });
    }
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();

    final namaErr = KosValidator.validateRequired(_namaController.text, 'Nama Kos');
    final areaErr = KosValidator.validateRequired(_areaController.text, 'Area');
    final alamatErr = KosValidator.validateRequired(_alamatController.text, 'Alamat');
    final hargaErr = KosValidator.validateHarga(_hargaController.text);
    final kamarErr = KosValidator.validateKamarTersedia(_kamarController.text);
    final kontakErr = KosValidator.validateKontak(_kontakController.text);
    final fasilitasErr = KosValidator.validateFasilitas(_selectedFasilitas);

    setState(() {
      _namaError = namaErr;
      _areaError = areaErr;
      _alamatError = alamatErr;
      _hargaError = hargaErr;
      _kamarError = kamarErr;
      _kontakError = kontakErr;
      _fasilitasError = fasilitasErr;
      _submitError = null;
    });

    if (namaErr != null ||
        areaErr != null ||
        alamatErr != null ||
        hargaErr != null ||
        kamarErr != null ||
        kontakErr != null ||
        fasilitasErr != null) {
      return;
    }

    final auth = context.read<AuthProvider>();
    final ownerId = auth.user?.id;
    if (ownerId == null || ownerId.isEmpty) {
      setState(() {
        _submitError = 'Sesi login Anda sudah berakhir. Silakan masuk ulang.';
      });
      return;
    }

    final payload = KosPayload(
      nama: _namaController.text,
      area: _areaController.text,
      alamat: _alamatController.text,
      harga: int.parse(_hargaController.text.trim()),
      kamarTersedia: int.parse(_kamarController.text.trim()),
      fasilitas: List<String>.from(_selectedFasilitas),
      kontak: _kontakController.text,
      deskripsi: _deskripsiController.text,
    );

    final ownerKos = context.read<OwnerKosProvider>();
    final kosProvider = context.read<KosProvider>();

    final bool ok;
    if (_isEdit) {
      ok = await ownerKos.editKos(id: widget.existingKos!.id, payload: payload);
    } else {
      ok = await ownerKos.addKos(ownerId: ownerId, payload: payload);
    }

    if (!mounted) return;

    if (!ok) {
      setState(() {
        _submitError =
            ownerKos.errorMessage ?? 'Gagal menyimpan data kos. Coba lagi.';
      });
      return;
    }

    await kosProvider.loadKos();
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text('Kos berhasil disimpan.')));
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final isSubmitting = context.watch<OwnerKosProvider>().isSubmitting;
    final customFacilities = KosValidator.customFacilitiesFrom(_selectedFasilitas);

    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: SafeArea(
              bottom: false,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CircleIconButton(
                          icon: Icons.chevron_left,
                          semanticLabel: 'Kembali',
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                        CircleIconButton(
                          icon: Icons.info_outline,
                          semanticLabel: 'Tentang',
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) => const AboutScreen(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Text(
                      _isEdit ? 'Ubah Kos' : 'Tambah Kos',
                      style: AppTextStyles.screenTitle,
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Isi data kos Anda dengan singkat.',
                      style: AppTextStyles.supporting,
                    ),
                    const SizedBox(height: 18),
                    _FormGroupCard(
                      title: 'INFO KOS',
                      children: [
                        _LabeledField(
                          label: 'Nama Kos',
                          controller: _namaController,
                          hintText: 'Contoh: Kos Melati',
                          errorText: _namaError,
                          onChanged: (_) {
                            if (_namaError != null) {
                              setState(() => _namaError = null);
                            }
                          },
                        ),
                        const SizedBox(height: 14),
                        _LabeledField(
                          label: 'Area',
                          controller: _areaController,
                          hintText: 'Contoh: Tembalang',
                          errorText: _areaError,
                          onChanged: (_) {
                            if (_areaError != null) {
                              setState(() => _areaError = null);
                            }
                          },
                        ),
                        const SizedBox(height: 14),
                        _LabeledField(
                          label: 'Alamat',
                          controller: _alamatController,
                          hintText: 'Nama jalan dan nomor',
                          errorText: _alamatError,
                          onChanged: (_) {
                            if (_alamatError != null) {
                              setState(() => _alamatError = null);
                            }
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    _FormGroupCard(
                      title: 'HARGA DAN KAMAR',
                      children: [
                        _LabeledField(
                          label: 'Harga per bulan (Rp)',
                          controller: _hargaController,
                          hintText: '850000',
                          keyboardType: TextInputType.number,
                          errorText: _hargaError,
                          onChanged: (_) {
                            if (_hargaError != null) {
                              setState(() => _hargaError = null);
                            }
                          },
                        ),
                        const SizedBox(height: 14),
                        _LabeledField(
                          label: 'Kamar tersedia',
                          controller: _kamarController,
                          hintText: '3',
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          errorText: _kamarError,
                          onChanged: (_) {
                            if (_kamarError != null) {
                              setState(() => _kamarError = null);
                            }
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    _FormGroupCard(
                      title: 'KONTAK',
                      children: [
                        _LabeledField(
                          label: 'No. HP / WhatsApp',
                          controller: _kontakController,
                          hintText: '081234567890',
                          keyboardType: TextInputType.phone,
                          errorText: _kontakError,
                          onChanged: (_) {
                            if (_kontakError != null) {
                              setState(() => _kontakError = null);
                            }
                          },
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Nomor ini akan terlihat oleh pencari kos.',
                          style: AppTextStyles.supporting,
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    _FormGroupCard(
                      title: 'FASILITAS (PILIH MINIMAL SATU)',
                      children: [
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            for (final item in KosValidator.daftarFasilitas)
                              _StandardFacilityChip(
                                label: item,
                                selected: _selectedFasilitas.contains(item),
                                onTap: () => _toggleStandardFacility(item),
                              ),
                            for (final custom in customFacilities)
                              _CustomFacilityChip(
                                label: custom,
                                onRemove: () => _removeCustomFacility(custom),
                              ),
                            _AddFacilityChip(onTap: _openAddFacilityDialog),
                          ],
                        ),
                        if (_fasilitasError != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            _fasilitasError!,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.dangerText,
                            ),
                          ),
                        ],
                        const SizedBox(height: 10),
                        const Text(
                          'Tidak ada di daftar? Ketuk Tambah untuk menulis fasilitas sendiri.',
                          style: AppTextStyles.supporting,
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    _FormGroupCard(
                      title: 'OPSIONAL',
                      children: [
                        _LabeledField(
                          label: 'Deskripsi singkat',
                          controller: _deskripsiController,
                          hintText: 'Ceritakan singkat tentang kos Anda',
                          maxLines: 3,
                        ),
                      ],
                    ),
                    if (_submitError != null) ...[
                      const SizedBox(height: 14),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.dangerSoft,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Text(
                          _submitError!,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppColors.dangerText,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
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
                child: ElevatedButton(
                  onPressed: isSubmitting ? null : _submit,
                  child: isSubmitting
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: AppColors.surface,
                          ),
                        )
                      : const Text('Simpan'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FormGroupCard extends StatelessWidget {
  const _FormGroupCard({
    required this.title,
    required this.children,
  });

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.groupTitle),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}

class _LabeledField extends StatelessWidget {
  const _LabeledField({
    required this.label,
    required this.controller,
    required this.hintText,
    this.errorText,
    this.keyboardType,
    this.inputFormatters,
    this.maxLines = 1,
    this.onChanged,
  });

  final String label;
  final TextEditingController controller;
  final String hintText;
  final String? errorText;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final int maxLines;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.fieldLabel),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          maxLines: maxLines,
          minLines: 1,
          onChanged: onChanged,
          style: AppTextStyles.body,
          decoration: InputDecoration(
            hintText: hintText,
            errorText: errorText,
          ),
        ),
      ],
    );
  }
}

class _StandardFacilityChip extends StatelessWidget {
  const _StandardFacilityChip({
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
      color: AppColors.neutralChip,
      borderRadius: BorderRadius.circular(999),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: 48),
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
                  color: AppColors.ink,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CustomFacilityChip extends StatelessWidget {
  const _CustomFacilityChip({
    required this.label,
    required this.onRemove,
  });

  final String label;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Hapus fasilitas $label',
      child: Material(
        color: AppColors.primaryTint,
        borderRadius: BorderRadius.circular(999),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onRemove,
          child: Container(
            constraints: const BoxConstraints(minHeight: 48),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryDeep,
                  ),
                ),
                const SizedBox(width: 6),
                const Icon(
                  Icons.close,
                  size: 18,
                  color: AppColors.primaryDeep,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AddFacilityChip extends StatelessWidget {
  const _AddFacilityChip({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedPillPainter(color: AppColors.primary),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(999),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Container(
            constraints: const BoxConstraints(minHeight: 48),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.add, size: 18, color: AppColors.primary),
                SizedBox(width: 6),
                Text(
                  'Tambah',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
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

class _DashedPillPainter extends CustomPainter {
  const _DashedPillPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(size.height / 2),
    );
    final path = Path()..addRRect(rrect);
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    const dashWidth = 6.0;
    const dashSpace = 4.0;
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final next = (distance + dashWidth).clamp(0.0, metric.length);
        canvas.drawPath(metric.extractPath(distance, next), paint);
        distance += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedPillPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
