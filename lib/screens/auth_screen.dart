import 'package:kosfinder/providers/auth_provider.dart';
import 'package:kosfinder/screens/about_screen.dart';
import 'package:kosfinder/theme/app_theme.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isRegisterMode = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit(AuthProvider auth) async {
    FocusScope.of(context).unfocus();
    final email = _emailController.text;
    final password = _passwordController.text;

    if (_isRegisterMode) {
      await auth.signUp(email: email, password: password);
    } else {
      await auth.signIn(email: email, password: password);
    }
  }

  void _toggleMode(AuthProvider auth) {
    auth.clearError();
    setState(() {
      _isRegisterMode = !_isRegisterMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        return ColoredBox(
          color: AppColors.surface,
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 120),
            child: Container(
              color: AppColors.primary,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    clipBehavior: Clip.hardEdge,
                    children: [
                      Positioned(
                        right: -50,
                        top: -60,
                        child: Container(
                          width: 220,
                          height: 220,
                          decoration: const BoxDecoration(
                            color: AppColors.authCircle1,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                      Positioned(
                        left: -40,
                        bottom: -30,
                        child: Container(
                          width: 150,
                          height: 150,
                          decoration: const BoxDecoration(
                            color: AppColors.authCircle2,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                      SafeArea(
                        bottom: false,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 12, 20, 22),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        width: 44,
                                        height: 44,
                                        decoration: BoxDecoration(
                                          color: AppColors.surface,
                                          borderRadius: BorderRadius.circular(14),
                                        ),
                                        alignment: Alignment.center,
                                        child: const Text(
                                          'K',
                                          style: TextStyle(
                                            fontSize: 22,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.primary,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      const Text(
                                        'KosFinder',
                                        style: TextStyle(
                                          fontSize: 19,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.surface,
                                        ),
                                      ),
                                    ],
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
                                _isRegisterMode
                                    ? 'Buat akun\npemilik kos'
                                    : 'Selamat datang,\npemilik kos',
                                style: AppTextStyles.screenTitle.copyWith(
                                  color: AppColors.surface,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Pasang kos Anda secara gratis.',
                                style: AppTextStyles.body.copyWith(
                                  color: AppColors.primaryTint,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(32),
                      ),
                    ),
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Email', style: AppTextStyles.fieldLabel),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          onChanged: (_) => auth.clearError(),
                          decoration: const InputDecoration(
                            hintText: 'nama@email.com',
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text('Password', style: AppTextStyles.fieldLabel),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          textInputAction: TextInputAction.done,
                          onChanged: (_) => auth.clearError(),
                          onSubmitted: (_) {
                            if (!auth.isLoading) {
                              _submit(auth);
                            }
                          },
                          decoration: InputDecoration(
                            hintText: 'Minimal 6 karakter',
                            suffixIcon: IconButton(
                              tooltip: _obscurePassword
                                  ? 'Lihat password'
                                  : 'Sembunyikan password',
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                color: AppColors.muted,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                          ),
                        ),
                        if (auth.errorMessage != null) ...[
                          const SizedBox(height: 14),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: AppColors.dangerSoft,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Text(
                              auth.errorMessage!,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: AppColors.dangerText,
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: auth.isLoading ? null : () => _submit(auth),
                          child: auth.isLoading
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: AppColors.surface,
                                  ),
                                )
                              : Text(_isRegisterMode ? 'Daftar' : 'Masuk'),
                        ),
                        const SizedBox(height: 12),
                        Center(
                          child: TextButton(
                            onPressed:
                                auth.isLoading ? null : () => _toggleMode(auth),
                            style: TextButton.styleFrom(
                              minimumSize: const Size(48, 48),
                            ),
                            child: Text.rich(
                              TextSpan(
                                text: _isRegisterMode
                                    ? 'Sudah punya akun? '
                                    : 'Belum punya akun? ',
                                style: AppTextStyles.supporting,
                                children: [
                                  TextSpan(
                                    text: _isRegisterMode ? 'Masuk' : 'Daftar',
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Text(
                            'Jika lupa password, daftar ulang dengan email lain.',
                            style: AppTextStyles.supporting,
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
      },
    );
  }
}
