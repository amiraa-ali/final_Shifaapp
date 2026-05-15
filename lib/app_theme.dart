import 'package:flutter/material.dart';

// =========================================================
// APP COLORS — Single source of truth
// =========================================================
class AppColors {
  AppColors._();

  static const Color primary = Color(0xFF009f93);

  static const Color secondary = Color(0xFF39ab4a);

  static const Color background = Color(0xFFF6F7FB);

  static const Color surface = Colors.white;

  static const Color error = Color(0xFFE53935);

  static const Color textPrimary = Color(0xFF1A1A2E);

  static const Color textSecondary = Color(0xFF6B7280);

  static const Color divider = Color(0xFFE5E7EB);

  // Status Colors
  static const Color upcoming = Color(0xFF10B981);

  static const Color completed = Color(0xFF3B82F6);

  static const Color cancelled = Color(0xFFEF4444);

  // Main Gradient
  static const LinearGradient mainGradient = LinearGradient(
    colors: [secondary, primary],
    begin: Alignment.bottomRight,
    end: Alignment.topLeft,
  );

  static const LinearGradient headerGradient = LinearGradient(
    colors: [Color(0xFF2ECC71), Color(0xFF1ABC9C)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

// =========================================================
// TEXT STYLES
// =========================================================
class AppText {
  AppText._();

  static const TextStyle h1 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    letterSpacing: -0.5,
  );

  static const TextStyle h2 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static const TextStyle h3 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const TextStyle body = TextStyle(
    fontSize: 14,
    color: AppColors.textSecondary,
    height: 1.5,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 12,
    color: AppColors.textSecondary,
  );

  static const TextStyle button = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Colors.white,
    letterSpacing: 0.3,
  );
}

// =========================================================
// APP THEME
// =========================================================
class AppTheme {
  AppTheme._();

  static ThemeData get light => ThemeData(
    useMaterial3: true,

    fontFamily: 'Roboto',

    scaffoldBackgroundColor: AppColors.background,

    primaryColor: AppColors.primary,

    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.light,
    ),

    // =================================================
    // APP BAR
    // =================================================
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.primary,

      foregroundColor: Colors.white,

      elevation: 0,

      centerTitle: true,

      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    ),

    // =================================================
    // CARD
    // =================================================
    cardTheme: CardThemeData(
      elevation: 2,

      shadowColor: Colors.black12,

      color: AppColors.surface,

      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
    ),

    // =================================================
    // BUTTON
    // =================================================
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,

        foregroundColor: Colors.white,

        elevation: 0,

        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),

        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),

        textStyle: AppText.button,
      ),
    ),

    // =================================================
    // INPUTS
    // =================================================
    inputDecorationTheme: InputDecorationTheme(
      filled: true,

      fillColor: Colors.grey.shade50,

      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),

      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),

        borderSide: const BorderSide(color: AppColors.divider),
      ),

      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),

        borderSide: const BorderSide(color: AppColors.divider),
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),

        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),

      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),

        borderSide: const BorderSide(color: AppColors.error),
      ),
    ),

    // =================================================
    // NAVIGATION BAR
    // =================================================
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: Colors.white,

      indicatorColor: AppColors.primary.withOpacity(0.12),

      labelTextStyle: WidgetStateProperty.all(
        const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
      ),

      height: 68,
    ),

    // =================================================
    // DIVIDER
    // =================================================
    dividerTheme: const DividerThemeData(
      color: AppColors.divider,
      thickness: 1,
      space: 1,
    ),

    // =================================================
    // SNACKBAR
    // =================================================
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.primary,

      behavior: SnackBarBehavior.floating,

      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),

      contentTextStyle: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w600,
      ),
    ),

    // =================================================
    // PROGRESS INDICATOR
    // =================================================
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: AppColors.primary,
    ),

    // =================================================
    // PAGE TRANSITIONS
    // =================================================
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: CupertinoPageTransitionsBuilder(),

        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      },
    ),
  );
}

// =========================================================
// REUSABLE WIDGETS
// =========================================================

class GradientAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  final List<Widget>? actions;

  final Widget? leading;

  final double height;

  const GradientAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.height = kToolbarHeight,
  });

  @override
  Size get preferredSize => Size.fromHeight(height);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
      ),

      leading: leading,

      actions: actions,

      flexibleSpace: Container(
        decoration: const BoxDecoration(gradient: AppColors.mainGradient),
      ),

      backgroundColor: Colors.transparent,

      foregroundColor: Colors.white,

      elevation: 0,
    );
  }
}

// =========================================================
// GRADIENT BUTTON
// =========================================================
class GradientButton extends StatelessWidget {
  final String label;

  final VoidCallback? onPressed;

  final bool isLoading;

  final double height;

  final IconData? icon;

  const GradientButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.height = 52,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: height,

      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: onPressed == null
              ? const LinearGradient(colors: [Colors.grey, Colors.grey])
              : AppColors.mainGradient,

          borderRadius: BorderRadius.circular(14),

          boxShadow: onPressed == null
              ? []
              : [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.35),

                    blurRadius: 12,

                    offset: const Offset(0, 4),
                  ),
                ],
        ),

        child: ElevatedButton(
          onPressed: isLoading ? null : onPressed,

          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,

            shadowColor: Colors.transparent,

            elevation: 0,

            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),

          child: isLoading
              ? const SizedBox(
                  width: 22,
                  height: 22,

                  child: CircularProgressIndicator(
                    color: Colors.white,

                    strokeWidth: 2,
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,

                  children: [
                    if (icon != null) ...[
                      Icon(icon, size: 20),

                      const SizedBox(width: 8),
                    ],

                    Text(label, style: AppText.button),
                  ],
                ),
        ),
      ),
    );
  }
}

// =========================================================
// PROFILE INFO TILE
// =========================================================
class ProfileInfoTile extends StatelessWidget {
  final IconData icon;

  final String label;

  final String value;

  final Color? iconColor;

  const ProfileInfoTile({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final color = iconColor ?? AppColors.primary;

    return Row(
      children: [
        Container(
          width: 40,
          height: 40,

          decoration: BoxDecoration(
            color: color.withOpacity(0.1),

            borderRadius: BorderRadius.circular(10),
          ),

          child: Icon(icon, color: color, size: 20),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              Text(label, style: AppText.caption),

              const SizedBox(height: 2),

              Text(value, style: AppText.h3.copyWith(fontSize: 14)),
            ],
          ),
        ),
      ],
    );
  }
}
