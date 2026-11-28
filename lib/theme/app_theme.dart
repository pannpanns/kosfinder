import 'package:material_ui/material_ui.dart';

class AppColors {
  AppColors._();

  static const Color background = Color(0xFFF4F6F5);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color ink = Color(0xFF12211D);
  static const Color primary = Color(0xFF0B6B58);
  static const Color primaryDeep = Color(0xFF084A3D);
  static const Color primaryTint = Color(0xFFDDF3EC);
  static const Color primarySoft = Color(0xFFE8F4F0);
  static const Color visualCircle1 = Color(0xFFC6E9DE);
  static const Color visualCircle2 = Color(0xFFB5E0D2);
  static const Color authCircle1 = Color(0xFF14806A);
  static const Color authCircle2 = Color(0xFF0F7561);
  static const Color muted = Color(0xFF5B6B66);
  static const Color fieldBorder = Color(0xFFD5E0DC);
  static const Color line = Color(0xFFE3E8E5);
  static const Color neutralChip = Color(0xFFF0F4F3);
  static const Color tagText = Color(0xFF33423D);
  static const Color dangerText = Color(0xFF8F1D14);
  static const Color dangerSoft = Color(0xFFFDE4E1);
  static const Color fullVisual = Color(0xFFE9ECEB);
  static const Color fullCircle1 = Color(0xFFDDE1E0);
  static const Color fullCircle2 = Color(0xFFD2D7D5);
}

class AppShadows {
  AppShadows._();

  static const List<BoxShadow> card = [
    BoxShadow(
      color: Color(0x1412211D),
      blurRadius: 30,
      offset: Offset(0, 10),
    ),
  ];

  static const List<BoxShadow> navbar = [
    BoxShadow(
      color: Color(0x1F12211D),
      blurRadius: 30,
      offset: Offset(0, 10),
    ),
  ];

  static const List<BoxShadow> bottomPanel = [
    BoxShadow(
      color: Color(0x1412211D),
      blurRadius: 30,
      offset: Offset(0, -10),
    ),
  ];
}

class AppTextStyles {
  AppTextStyles._();

  static const TextStyle screenTitle = TextStyle(
    fontSize: 30,
    fontWeight: FontWeight.w700,
    height: 1.15,
    letterSpacing: -0.9,
    color: AppColors.ink,
  );

  static const TextStyle detailTitle = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    height: 1.15,
    letterSpacing: -0.8,
    color: AppColors.ink,
  );

  static const TextStyle cardTitle = TextStyle(
    fontSize: 19,
    fontWeight: FontWeight.w700,
    color: AppColors.ink,
  );

  static const TextStyle cardPrice = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: AppColors.primary,
  );

  static const TextStyle detailPrice = TextStyle(
    fontSize: 30,
    fontWeight: FontWeight.w700,
    color: AppColors.primary,
  );

  static const TextStyle body = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.45,
    color: AppColors.ink,
  );

  static const TextStyle supporting = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: AppColors.muted,
  );

  static const TextStyle facilityTag = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.tagText,
  );

  static const TextStyle badge = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w700,
  );

  static const TextStyle fieldLabel = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w700,
    color: AppColors.ink,
  );

  static const TextStyle groupTitle = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.78,
    color: AppColors.muted,
  );

  static const TextStyle primaryButton = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w700,
    color: AppColors.surface,
  );

  static const TextStyle smallButton = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w700,
  );

  static const TextStyle navTab = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w600,
  );
}

class AppTheme {
  AppTheme._();

  static ThemeData light() {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        surface: AppColors.surface,
        error: AppColors.dangerText,
      ),
      scaffoldBackgroundColor: AppColors.background,
    );

    return base.copyWith(
      textTheme: base.textTheme.apply(
        bodyColor: AppColors.ink,
        displayColor: AppColors.ink,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.surface,
          minimumSize: const Size.fromHeight(56),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          textStyle: AppTextStyles.primaryButton,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primarySoft,
          foregroundColor: AppColors.primaryDeep,
          minimumSize: const Size(48, 48),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          textStyle: AppTextStyles.smallButton,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        hintStyle: AppTextStyles.body.copyWith(color: AppColors.muted),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.fieldBorder, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.fieldBorder, width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.dangerText, width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.dangerText, width: 2),
        ),
        errorStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.dangerText,
        ),
      ),
    );
  }
}

class CircleIconButton extends StatelessWidget {
  const CircleIconButton({
    super.key,
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
        child: Container(
          width: 48,
          height: 48,
          decoration: const BoxDecoration(
            color: AppColors.surface,
            shape: BoxShape.circle,
            boxShadow: AppShadows.card,
          ),
          child: Material(
            color: Colors.transparent,
            shape: const CircleBorder(),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: onPressed,
              child: Icon(icon, size: 22, color: AppColors.ink),
            ),
          ),
        ),
      ),
    );
  }
}
