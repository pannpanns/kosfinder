import 'package:kosfinder/providers/auth_provider.dart';
import 'package:kosfinder/screens/auth_screen.dart';
import 'package:kosfinder/screens/kos_list_screen.dart';
import 'package:kosfinder/screens/my_kos_screen.dart';
import 'package:kosfinder/theme/app_theme.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

class HomeShellScreen extends StatefulWidget {
  const HomeShellScreen({
    super.key,
    this.kosSayaTab,
  });

  final Widget? kosSayaTab;

  @override
  State<HomeShellScreen> createState() => _HomeShellScreenState();
}

class _HomeShellScreenState extends State<HomeShellScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final kosSayaWidget =
        widget.kosSayaTab ??
        Consumer<AuthProvider>(
          builder: (context, auth, _) {
            return auth.isLoggedIn ? const MyKosScreen() : const AuthScreen();
          },
        );

    final tabs = [
      const KosListScreen(),
      kosSayaWidget,
    ];

    return Scaffold(
      body: Stack(
        children: [
          IndexedStack(
            index: _currentIndex,
            children: tabs,
          ),
          Positioned(
            left: 20,
            right: 20,
            bottom: 20,
            child: SafeArea(
              top: false,
              child: _FloatingBottomNavBar(
                currentIndex: _currentIndex,
                onSelect: (index) {
                  if (_currentIndex != index) {
                    setState(() => _currentIndex = index);
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FloatingBottomNavBar extends StatelessWidget {
  const _FloatingBottomNavBar({
    required this.currentIndex,
    required this.onSelect,
  });

  final int currentIndex;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: AppColors.line, width: 1),
        boxShadow: AppShadows.navbar,
      ),
      child: Row(
        children: [
          Expanded(
            child: _NavTabButton(
              icon: Icons.search,
              label: 'Cari Kos',
              selected: currentIndex == 0,
              onTap: () => onSelect(0),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: _NavTabButton(
              icon: Icons.home_outlined,
              label: 'Kos Saya',
              selected: currentIndex == 1,
              onTap: () => onSelect(1),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavTabButton extends StatelessWidget {
  const _NavTabButton({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final fg = selected ? AppColors.primaryDeep : AppColors.muted;

    return Material(
      color: selected ? AppColors.primaryTint : Colors.transparent,
      borderRadius: BorderRadius.circular(24),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: 52,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 22, color: fg),
              const SizedBox(width: 8),
              Text(
                label,
                style: AppTextStyles.navTab.copyWith(color: fg),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
