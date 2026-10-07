import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'fade_colors.dart';
import 'fade_tokens.dart';
import 'fade_typography.dart';

/// Builds Fade's [ThemeData] for dark and light mode from the semantic tokens.
///
/// ```dart
/// MaterialApp(
///   theme: FadeTheme.light(),
///   darkTheme: FadeTheme.dark(),
///   themeMode: ThemeMode.system,
/// )
/// ```
abstract final class FadeTheme {
  static ThemeData dark() => _build(FadeColors.dark, Brightness.dark);
  static ThemeData light() => _build(FadeColors.light, Brightness.light);

  static ThemeData _build(FadeColors c, Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final text = FadeType.textTheme(
      primary: c.textPrimary,
      secondary: c.textSecondary,
      tertiary: c.textTertiary,
    );

    final scheme = ColorScheme(
      brightness: brightness,
      primary: c.accent,
      onPrimary: c.onAccent,
      primaryContainer: c.accentSoft,
      onPrimaryContainer: c.accentText,
      secondary: c.textPrimary,
      onSecondary: c.background,
      secondaryContainer: c.surfaceHigh,
      onSecondaryContainer: c.textPrimary,
      tertiary: c.info,
      onTertiary: c.background,
      error: c.danger,
      onError: c.onDanger,
      errorContainer: c.dangerSoft,
      onErrorContainer: c.danger,
      surface: c.surface,
      onSurface: c.textPrimary,
      onSurfaceVariant: c.textSecondary,
      surfaceDim: c.background,
      surfaceBright: c.surfaceRaised,
      surfaceContainerLowest: c.background,
      surfaceContainerLow: c.surface,
      surfaceContainer: c.surface,
      surfaceContainerHigh: c.surfaceRaised,
      surfaceContainerHighest: c.surfaceHigh,
      outline: c.borderStrong,
      outlineVariant: c.border,
      shadow: const Color(0xFF000000),
      scrim: c.scrim,
      inverseSurface: c.textPrimary,
      onInverseSurface: c.background,
      inversePrimary: isDark ? FadePalette.brass : FadePalette.gold,
    );

    final buttonShape = RoundedRectangleBorder(borderRadius: FadeRadius.mdAll);
    final buttonText = FadeType.label;
    const buttonPadding = EdgeInsets.symmetric(
      horizontal: FadeSpace.s20,
      vertical: FadeSpace.s16,
    );
    const buttonMin = Size(64, 52);

    OutlineInputBorder inputBorder(Color color, [double width = 1]) =>
        OutlineInputBorder(
          borderRadius: FadeRadius.mdAll,
          borderSide: BorderSide(color: color, width: width),
        );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: c.background,
      canvasColor: c.background,
      primaryColor: c.accent,
      dividerColor: c.border,
      splashFactory: InkSparkle.splashFactory,
      fontFamily: FadeType.body.fontFamily,
      textTheme: text,
      primaryTextTheme: text,
      extensions: <ThemeExtension<dynamic>>[c],
      visualDensity: VisualDensity.standard,
      appBarTheme: AppBarTheme(
        backgroundColor: c.background,
        foregroundColor: c.textPrimary,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: FadeType.title.copyWith(color: c.textPrimary),
        iconTheme: IconThemeData(color: c.textPrimary, size: 24),
        systemOverlayStyle: isDark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: c.accent,
          foregroundColor: c.onAccent,
          disabledBackgroundColor: c.surfaceHigh,
          disabledForegroundColor: c.textTertiary,
          elevation: 0,
          shadowColor: Colors.transparent,
          minimumSize: buttonMin,
          padding: buttonPadding,
          shape: buttonShape,
          textStyle: buttonText,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: c.accent,
          foregroundColor: c.onAccent,
          disabledBackgroundColor: c.surfaceHigh,
          disabledForegroundColor: c.textTertiary,
          minimumSize: buttonMin,
          padding: buttonPadding,
          shape: buttonShape,
          textStyle: buttonText,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: c.textPrimary,
          disabledForegroundColor: c.textTertiary,
          side: BorderSide(color: c.borderStrong),
          minimumSize: buttonMin,
          padding: buttonPadding,
          shape: buttonShape,
          textStyle: buttonText,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: c.accentText,
          disabledForegroundColor: c.textTertiary,
          shape: buttonShape,
          textStyle: buttonText,
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: c.textPrimary,
          minimumSize: const Size(44, 44),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: c.accent,
        foregroundColor: c.onAccent,
        elevation: 0,
        highlightElevation: 0,
        shape: RoundedRectangleBorder(borderRadius: FadeRadius.lgAll),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: c.inputFill,
        isDense: false,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: FadeSpace.s16,
          vertical: FadeSpace.s16,
        ),
        border: inputBorder(c.border),
        enabledBorder: inputBorder(c.border),
        focusedBorder: inputBorder(c.accent, 1.5),
        errorBorder: inputBorder(c.danger),
        focusedErrorBorder: inputBorder(c.danger, 1.5),
        disabledBorder: inputBorder(c.border.withValues(alpha: 0.5)),
        hintStyle: FadeType.body.copyWith(color: c.textTertiary),
        labelStyle: FadeType.bodySm.copyWith(color: c.textSecondary),
        floatingLabelStyle: FadeType.bodySm.copyWith(color: c.accentText),
        helperStyle: FadeType.caption.copyWith(color: c.textTertiary),
        errorStyle: FadeType.caption.copyWith(color: c.danger),
        prefixIconColor: c.textSecondary,
        suffixIconColor: c.textSecondary,
      ),
      cardTheme: CardThemeData(
        color: c.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: FadeRadius.lgAll,
          side: BorderSide(color: c.border),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: c.surface,
        selectedColor: c.accentSoft,
        disabledColor: c.surfaceHigh,
        side: BorderSide(color: c.border),
        labelStyle: FadeType.labelSm.copyWith(color: c.textPrimary),
        secondaryLabelStyle: FadeType.labelSm.copyWith(color: c.accentText),
        padding: const EdgeInsets.symmetric(
          horizontal: FadeSpace.s12,
          vertical: FadeSpace.s8,
        ),
        shape: RoundedRectangleBorder(borderRadius: FadeRadius.fullAll),
        checkmarkColor: c.accentText,
      ),
      listTileTheme: ListTileThemeData(
        iconColor: c.textSecondary,
        textColor: c.textPrimary,
        titleTextStyle: FadeType.title.copyWith(color: c.textPrimary),
        subtitleTextStyle: FadeType.bodySm.copyWith(color: c.textSecondary),
        contentPadding: const EdgeInsets.symmetric(horizontal: FadeSpace.s16),
        minVerticalPadding: FadeSpace.s12,
        shape: RoundedRectangleBorder(borderRadius: FadeRadius.mdAll),
      ),
      dividerTheme: DividerThemeData(color: c.border, thickness: 1, space: 1),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: c.surface,
        surfaceTintColor: Colors.transparent,
        modalBackgroundColor: c.surface,
        modalBarrierColor: c.scrim,
        showDragHandle: true,
        dragHandleColor: c.borderStrong,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(FadeRadius.xl),
          ),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: c.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: FadeRadius.xlAll),
        titleTextStyle: FadeType.h3.copyWith(color: c.textPrimary),
        contentTextStyle: FadeType.body.copyWith(color: c.textSecondary),
        barrierColor: c.scrim,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: isDark ? c.surfaceHigh : FadePalette.graphite900,
        contentTextStyle: FadeType.bodySm.copyWith(
          color: isDark ? c.textPrimary : FadePalette.bone,
        ),
        actionTextColor: FadePalette.gold,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: FadeRadius.mdAll),
        elevation: 0,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: c.surface,
        surfaceTintColor: Colors.transparent,
        indicatorColor: c.accentSoft,
        elevation: 0,
        height: 68,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return FadeType.caption.copyWith(
            color: selected ? c.textPrimary : c.textTertiary,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: selected ? c.accentText : c.textTertiary,
            size: 24,
          );
        }),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: c.surface,
        selectedItemColor: c.accentText,
        unselectedItemColor: c.textTertiary,
        selectedLabelStyle: FadeType.caption.copyWith(
          fontWeight: FontWeight.w700,
        ),
        unselectedLabelStyle: FadeType.caption,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        showSelectedLabels: true,
        showUnselectedLabels: true,
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: c.textPrimary,
        unselectedLabelColor: c.textTertiary,
        labelStyle: FadeType.label,
        unselectedLabelStyle: FadeType.label,
        indicatorColor: c.accent,
        dividerColor: c.border,
        indicatorSize: TabBarIndicatorSize.label,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return c.onAccent;
          return isDark ? c.textSecondary : FadePalette.white;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return c.accent;
          return c.surfaceHigh;
        }),
        trackOutlineColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return Colors.transparent;
          return c.borderStrong;
        }),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return c.accent;
          return Colors.transparent;
        }),
        checkColor: WidgetStatePropertyAll(c.onAccent),
        side: BorderSide(color: c.borderStrong, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      ),
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return c.accent;
          return c.borderStrong;
        }),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: c.accent,
        linearTrackColor: c.surfaceHigh,
        circularTrackColor: Colors.transparent,
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: isDark ? c.surfaceHigh : FadePalette.graphite900,
          borderRadius: FadeRadius.smAll,
        ),
        textStyle: FadeType.caption.copyWith(
          color: isDark ? c.textPrimary : FadePalette.bone,
        ),
      ),
      iconTheme: IconThemeData(color: c.textPrimary, size: 24),
      datePickerTheme: DatePickerThemeData(
        backgroundColor: c.surface,
        surfaceTintColor: Colors.transparent,
        headerBackgroundColor: c.surface,
        headerForegroundColor: c.textPrimary,
        todayBorder: BorderSide(color: c.accent),
        shape: RoundedRectangleBorder(borderRadius: FadeRadius.xlAll),
      ),
      timePickerTheme: TimePickerThemeData(
        backgroundColor: c.surface,
        shape: RoundedRectangleBorder(borderRadius: FadeRadius.xlAll),
      ),
    );
  }
}

/// Convenience accessors: `context.fadeColors.accent`, `context.isDarkMode`.
extension FadeThemeContext on BuildContext {
  /// Semantic color tokens for the current theme. Falls back to dark tokens if
  /// the app has not adopted [FadeTheme] yet.
  FadeColors get fadeColors =>
      Theme.of(this).extension<FadeColors>() ?? FadeColors.dark;

  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;

  /// True when the user has asked the OS to reduce motion.
  bool get reduceMotion => MediaQuery.maybeDisableAnimationsOf(this) ?? false;
}
