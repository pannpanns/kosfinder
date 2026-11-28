import 'package:material_ui/material_ui.dart';
import 'package:kosfinder/theme/app_theme.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  static const String creatorIdentity = '2415051069 - Putu Evan Jagadish Satriana';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleIconButton(
                icon: Icons.chevron_left,
                semanticLabel: 'Kembali',
                onPressed: () => Navigator.of(context).pop(),
              ),
              const SizedBox(height: 20),
              const Text('Tentang', style: AppTextStyles.screenTitle),
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: AppShadows.card,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: AppColors.primaryTint,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          alignment: Alignment.center,
                          child: const Text(
                            'K',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('KosFinder', style: AppTextStyles.cardTitle),
                              SizedBox(height: 2),
                              Text('Versi 0.1.0', style: AppTextStyles.supporting),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Aplikasi Android untuk membantu pencari kos menemukan hunian sesuai kebutuhan dan membantu pemilik kos mempromosikan kamarnya secara gratis.',
                      style: AppTextStyles.body,
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Divider(height: 1, color: AppColors.line),
                    ),
                    const Text('Dibuat oleh', style: AppTextStyles.supporting),
                    const SizedBox(height: 6),
                    const Text(
                      creatorIdentity,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: AppColors.ink,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
