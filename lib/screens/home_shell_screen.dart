import 'package:material_ui/material_ui.dart';
import 'package:kosfinder/screens/about_screen.dart';
import 'package:kosfinder/screens/kos_list_screen.dart';
import 'package:kosfinder/theme/app_theme.dart';

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
    final tabs = [
      const KosListScreen(),
      widget.kosSayaTab ?? const _KosSayaPlaceholder(),
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

// TODO(T08): ganti placeholder ini dengan AuthScreen dan MyKosScreen pada Slice 3.
class _KosSayaPlaceholder extends StatelessWidget {
  const _KosSayaPlaceholder();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 116),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Kos Saya', style: AppTextStyles.screenTitle),
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
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(24),
                boxShadow: AppShadows.card,
              ),
              child: const Text(
                'Fitur masuk pemilik dan pengelolaan Kos Saya akan hadir pada Slice 3 (T08).',
                style: AppTextStyles.body,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
