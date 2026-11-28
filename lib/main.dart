import 'package:material_ui/material_ui.dart';
import 'package:kosfinder/config/supabase_config.dart';
import 'package:kosfinder/providers/kos_provider.dart';
import 'package:kosfinder/repositories/kos_repository.dart';
import 'package:kosfinder/screens/home_shell_screen.dart';
import 'package:kosfinder/theme/app_theme.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  String? configError;
  try {
    await SupabaseConfig.initialize();
  } on StateError catch (e) {
    configError = e.message;
  }

  runApp(KosFinderApp(configError: configError));
}

class KosFinderApp extends StatelessWidget {
  const KosFinderApp({
    super.key,
    this.kosRepository,
    this.configError,
  });

  final KosRepository? kosRepository;
  final String? configError;

  @override
  Widget build(BuildContext context) {
    if (configError != null) {
      return MaterialApp(
        title: 'KosFinder',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        home: _ConfigErrorScreen(message: configError!),
      );
    }

    return MultiProvider(
      providers: [
        ChangeNotifierProvider<KosProvider>(
          create: (_) => KosProvider(repository: kosRepository),
        ),
      ],
      child: MaterialApp(
        title: 'KosFinder',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        home: const HomeShellScreen(),
      ),
    );
  }
}

class _ConfigErrorScreen extends StatelessWidget {
  const _ConfigErrorScreen({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(24),
                boxShadow: AppShadows.card,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Konfigurasi Belum Lengkap',
                    style: AppTextStyles.cardTitle,
                  ),
                  const SizedBox(height: 12),
                  Text(message, style: AppTextStyles.body),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
