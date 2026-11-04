import 'package:flutter/material.dart';

import 'manafa_colors.dart';
import 'manafa_typography.dart';

/// Light and dark [ThemeData] that carry the Manafa tokens.
abstract final class ManafaTheme {
  static ThemeData light() => _build(Brightness.light, ManafaColors.light);

  static ThemeData dark() => _build(Brightness.dark, ManafaColors.dark);

  static ThemeData _build(Brightness brightness, ManafaColors colors) {
    return ThemeData(
      brightness: brightness,
      fontFamily: ManafaTextStyles.fontFamily,
      package: ManafaTextStyles.fontPackage,
      scaffoldBackgroundColor: colors.bgAppColor,
      colorScheme: ColorScheme.fromSeed(
        seedColor: colors.accentBlue,
        brightness: brightness,
        primary: colors.accentBlue,
        error: colors.accentRedError,
        surface: colors.bgAppColor,
      ),
      extensions: [colors],
    );
  }
}
