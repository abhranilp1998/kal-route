import 'package:google_fonts/google_fonts.dart';
import 'package:material_ui/material_ui.dart';

class AppColors {
  static const bg = Color(0xFF111315);
  static const card = Color(0xFF1B1E21);
  static const card2 = Color(0xFF22262A);
  static const line = Color(0xFF2A2E33);
  static const text = Color(0xFFECEDEE);
  static const muted = Color(0xFF8A8F98);
  static const faint = Color(0xFF5D626A);
  static const amber = Color(0xFFF2B84B);
  static const onAmber = Color(0xFF1A1405);
  static const metro = Color(0xFF4C8DFF);
  static const bus = Color(0xFF3CC27A);
  static const walk = Color(0xFF8A8F98);
  static const auto = Color(0xFFF2B84B);
  static const ferry = Color(0xFF36C5D6);

  static Color forMode(String mode) => switch (mode) {
        'METRO' || 'TRAIN' => metro,
        'BUS' => bus,
        'AUTO' => auto,
        'FERRY' => ferry,
        'TRAM' => const Color(0xFFB57BFF),
        'WALK' => walk,
        _ => muted,
      };
}

const tabular = [FontFeature.tabularFigures()];

class AppText {
  static TextStyle heading(double size) => GoogleFonts.manrope(
      fontSize: size, fontWeight: FontWeight.w800, color: AppColors.text, letterSpacing: -0.4);
  static TextStyle leave([double size = 32]) => GoogleFonts.inter(
      fontSize: size,
      fontWeight: FontWeight.w700,
      color: AppColors.amber,
      letterSpacing: -0.6,
      fontFeatures: tabular);
  static TextStyle eyebrow([Color c = AppColors.muted]) => GoogleFonts.jetBrainsMono(
      fontSize: 11, letterSpacing: 1.6, color: c, fontWeight: FontWeight.w500);
  static TextStyle body({double size = 14, Color color = AppColors.text, FontWeight w = FontWeight.w500}) =>
      GoogleFonts.inter(fontSize: size, color: color, fontWeight: w, fontFeatures: tabular);
}

ThemeData buildTheme() {
  final base = ThemeData(brightness: Brightness.dark, useMaterial3: true);
  return base.copyWith(
    scaffoldBackgroundColor: AppColors.bg,
    colorScheme: const ColorScheme.dark(
      surface: AppColors.bg,
      primary: AppColors.amber,
      onPrimary: AppColors.onAmber,
      secondary: AppColors.metro,
      surfaceContainerHighest: AppColors.card,
    ),
    textTheme: GoogleFonts.interTextTheme(base.textTheme)
        .apply(bodyColor: AppColors.text, displayColor: AppColors.text),
    cardTheme: const CardThemeData(color: AppColors.card, elevation: 0, margin: EdgeInsets.zero),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: Color(0xFF181B1E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      showDragHandle: true,
      dragHandleColor: Color(0xFF3A3E44),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: AppColors.bg,
      indicatorColor: AppColors.amber.withValues(alpha: 0.14),
      surfaceTintColor: Colors.transparent,
      iconTheme: WidgetStateProperty.resolveWith((s) => IconThemeData(
          color: s.contains(WidgetState.selected) ? AppColors.amber : AppColors.muted)),
      labelTextStyle: WidgetStateProperty.resolveWith((s) => AppText.body(
          size: 11, color: s.contains(WidgetState.selected) ? AppColors.amber : AppColors.muted)),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.card2,
      contentTextStyle: AppText.body(),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.amber,
        foregroundColor: AppColors.onAmber,
        minimumSize: const Size.fromHeight(54),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.card2,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
      labelStyle: AppText.body(color: AppColors.muted),
    ),
    dividerColor: AppColors.line,
  );
}
