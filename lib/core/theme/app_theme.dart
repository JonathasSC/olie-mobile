import 'package:flutter/material.dart';

/// Famílias empacotadas em `assets/fonts` (ver pubspec.yaml).
abstract final class OlieFonts {
  /// Condensada de rótulo — só para marca, títulos e contadores.
  static const display = 'BigShoulders';
  static const body = 'Atkinson';

  /// Datas, valores e rótulos em caixa-alta.
  static const mono = 'PlexMono';
}

/// Cores do Olie que não cabem no [ColorScheme]: estados de prazo e dinheiro.
///
/// O acento (oliva) fica no `colorScheme.primary`; as cores semânticas
/// abaixo são separadas dele e só marcam estado.
@immutable
class OliePalette extends ThemeExtension<OliePalette> {
  final Color paper;
  final Color surface;
  final Color ink;
  final Color muted;
  final Color rule;
  final Color olive;
  final Color oliveSoft;
  final Color money;
  final Color moneySoft;
  final Color warning;
  final Color warningSoft;
  final Color critical;
  final Color criticalSoft;

  const OliePalette({
    required this.paper,
    required this.surface,
    required this.ink,
    required this.muted,
    required this.rule,
    required this.olive,
    required this.oliveSoft,
    required this.money,
    required this.moneySoft,
    required this.warning,
    required this.warningSoft,
    required this.critical,
    required this.criticalSoft,
  });

  static const light = OliePalette(
    paper: Color(0xFFEEF0E8),
    surface: Color(0xFFF8F9F4),
    ink: Color(0xFF1E2419),
    muted: Color(0xFF5E6653),
    rule: Color(0xFFD5D9CB),
    olive: Color(0xFF55652A),
    oliveSoft: Color(0xFFDDE3C6),
    money: Color(0xFF3E5C6B),
    moneySoft: Color(0xFFD6E1E6),
    warning: Color(0xFF9A5B00),
    warningSoft: Color(0xFFF5E2BF),
    critical: Color(0xFFB33A30),
    criticalSoft: Color(0xFFF4D8D3),
  );

  static const dark = OliePalette(
    paper: Color(0xFF141811),
    surface: Color(0xFF1C2118),
    ink: Color(0xFFE4E8D8),
    muted: Color(0xFFA1A992),
    rule: Color(0xFF2E3528),
    olive: Color(0xFFB3C47A),
    oliveSoft: Color(0xFF323B1E),
    money: Color(0xFF8FB3C4),
    moneySoft: Color(0xFF1F3038),
    warning: Color(0xFFE3A13A),
    warningSoft: Color(0xFF3B2C12),
    critical: Color(0xFFEF7A6C),
    criticalSoft: Color(0xFF3F1D19),
  );

  static OliePalette of(BuildContext context) =>
      Theme.of(context).extension<OliePalette>()!;

  @override
  OliePalette copyWith({Color? paper, Color? ink}) => OliePalette(
    paper: paper ?? this.paper,
    surface: surface,
    ink: ink ?? this.ink,
    muted: muted,
    rule: rule,
    olive: olive,
    oliveSoft: oliveSoft,
    money: money,
    moneySoft: moneySoft,
    warning: warning,
    warningSoft: warningSoft,
    critical: critical,
    criticalSoft: criticalSoft,
  );

  @override
  OliePalette lerp(OliePalette? other, double t) {
    if (other == null) return this;
    Color mix(Color a, Color b) => Color.lerp(a, b, t)!;
    return OliePalette(
      paper: mix(paper, other.paper),
      surface: mix(surface, other.surface),
      ink: mix(ink, other.ink),
      muted: mix(muted, other.muted),
      rule: mix(rule, other.rule),
      olive: mix(olive, other.olive),
      oliveSoft: mix(oliveSoft, other.oliveSoft),
      money: mix(money, other.money),
      moneySoft: mix(moneySoft, other.moneySoft),
      warning: mix(warning, other.warning),
      warningSoft: mix(warningSoft, other.warningSoft),
      critical: mix(critical, other.critical),
      criticalSoft: mix(criticalSoft, other.criticalSoft),
    );
  }
}

/// Estilos fora da escala do Material, usados em pontos específicos.
abstract final class OlieText {
  /// Rótulo pequeno em caixa-alta (seções, tipos de item).
  static TextStyle label(BuildContext context, {Color? color}) => TextStyle(
    fontFamily: OlieFonts.mono,
    fontSize: 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 1.1,
    color: color ?? OliePalette.of(context).muted,
  );

  /// Datas e valores alinhados.
  static TextStyle data(
    BuildContext context, {
    double size = 13,
    Color? color,
    FontWeight weight = FontWeight.w400,
  }) => TextStyle(
    fontFamily: OlieFonts.mono,
    fontSize: size,
    fontWeight: weight,
    color: color ?? OliePalette.of(context).muted,
    fontFeatures: const [FontFeature.tabularFigures()],
  );

  /// Números grandes das etiquetas de contagem.
  static TextStyle figure(
    BuildContext context, {
    double size = 26,
    Color? color,
  }) => TextStyle(
    fontFamily: OlieFonts.display,
    fontSize: size,
    fontWeight: FontWeight.w800,
    height: 1,
    color: color ?? OliePalette.of(context).ink,
    fontFeatures: const [FontFeature.tabularFigures()],
  );
}

class AppTheme {
  AppTheme._();

  static ThemeData get light => _build(OliePalette.light, Brightness.light);

  static ThemeData get dark => _build(OliePalette.dark, Brightness.dark);

  static ThemeData _build(OliePalette p, Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final scheme = ColorScheme(
      brightness: brightness,
      primary: p.olive,
      onPrimary: isDark ? const Color(0xFF1A2008) : const Color(0xFFF8F9F4),
      primaryContainer: p.oliveSoft,
      onPrimaryContainer: p.ink,
      secondary: p.money,
      onSecondary: isDark ? const Color(0xFF0E1D24) : const Color(0xFFF8F9F4),
      secondaryContainer: p.moneySoft,
      onSecondaryContainer: p.ink,
      tertiary: p.warning,
      onTertiary: isDark ? const Color(0xFF2A1B00) : const Color(0xFFFFFFFF),
      tertiaryContainer: p.warningSoft,
      onTertiaryContainer: p.ink,
      error: p.critical,
      onError: isDark ? const Color(0xFF2A0B07) : const Color(0xFFFFFFFF),
      errorContainer: p.criticalSoft,
      onErrorContainer: p.ink,
      surface: p.paper,
      onSurface: p.ink,
      onSurfaceVariant: p.muted,
      surfaceContainerLowest: p.paper,
      surfaceContainerLow: p.surface,
      surfaceContainer: p.surface,
      surfaceContainerHigh: p.surface,
      surfaceContainerHighest: p.rule,
      outline: p.muted,
      outlineVariant: p.rule,
      inverseSurface: p.ink,
      onInverseSurface: p.paper,
      inversePrimary: isDark ? OliePalette.light.olive : OliePalette.dark.olive,
    );

    TextStyle display(double size, {FontWeight weight = FontWeight.w800}) =>
        TextStyle(
          fontFamily: OlieFonts.display,
          fontSize: size,
          fontWeight: weight,
          height: 1.0,
          letterSpacing: 0.2,
          color: p.ink,
        );

    final textTheme = TextTheme(
      displayLarge: display(64),
      displayMedium: display(52),
      displaySmall: display(40),
      headlineLarge: display(36),
      headlineMedium: display(30),
      headlineSmall: display(24, weight: FontWeight.w600),
      titleLarge: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: p.ink,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: p.ink,
      ),
      titleSmall: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: p.ink,
      ),
      bodyLarge: TextStyle(fontSize: 16, height: 1.45, color: p.ink),
      bodyMedium: TextStyle(fontSize: 14, height: 1.45, color: p.ink),
      bodySmall: TextStyle(fontSize: 12.5, height: 1.4, color: p.muted),
      labelLarge: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
      labelMedium: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
      labelSmall: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
    );

    final fieldBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(6),
      borderSide: BorderSide(color: p.rule),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      fontFamily: OlieFonts.body,
      textTheme: textTheme,
      scaffoldBackgroundColor: p.paper,
      canvasColor: p.paper,
      dividerTheme: DividerThemeData(color: p.rule, thickness: 1, space: 1),
      extensions: [p],
      appBarTheme: AppBarTheme(
        backgroundColor: p.paper,
        surfaceTintColor: Colors.transparent,
        foregroundColor: p.ink,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: display(26),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: p.surface,
        surfaceTintColor: Colors.transparent,
        indicatorColor: p.oliveSoft,
        height: 68,
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => TextStyle(
            fontFamily: OlieFonts.mono,
            fontSize: 11,
            letterSpacing: 0.8,
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w600
                : FontWeight.w400,
            color: states.contains(WidgetState.selected) ? p.ink : p.muted,
          ),
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            color: states.contains(WidgetState.selected) ? p.olive : p.muted,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: p.surface,
        border: fieldBorder,
        enabledBorder: fieldBorder,
        focusedBorder: fieldBorder.copyWith(
          borderSide: BorderSide(color: p.olive, width: 1.6),
        ),
        labelStyle: TextStyle(color: p.muted),
        hintStyle: TextStyle(color: p.muted.withValues(alpha: 0.8)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(0, 46),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          textStyle: const TextStyle(
            fontFamily: OlieFonts.body,
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(0, 46),
          foregroundColor: p.ink,
          side: BorderSide(color: p.rule),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          alignment: Alignment.centerLeft,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: p.olive),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: p.ink,
        foregroundColor: p.paper,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        extendedTextStyle: const TextStyle(
          fontFamily: OlieFonts.body,
          fontWeight: FontWeight.w700,
          fontSize: 15,
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: p.surface,
        selectedColor: p.oliveSoft,
        side: BorderSide(color: p.rule),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        labelStyle: TextStyle(color: p.ink, fontSize: 13),
        showCheckmark: false,
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: SegmentedButton.styleFrom(
          selectedBackgroundColor: p.ink,
          selectedForegroundColor: p.paper,
          foregroundColor: p.ink,
          side: BorderSide(color: p.rule),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: p.paper,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
        dragHandleColor: p.rule,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: p.paper,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: p.ink,
        contentTextStyle: TextStyle(color: p.paper, fontFamily: OlieFonts.body),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      ),
      checkboxTheme: CheckboxThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
        side: BorderSide(color: p.muted, width: 1.5),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: p.olive,
        linearTrackColor: p.rule,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? p.paper : p.muted,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? p.olive : p.rule,
        ),
      ),
    );
  }
}
