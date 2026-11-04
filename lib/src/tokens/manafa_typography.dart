import 'package:flutter/painting.dart';

import '../manafa_package.dart';

/// Text style tokens from the Figma Global Design System (`Typography`).
///
/// Names match Figma: `headers/medium` is [ManafaTextStyles.headersMedium].
/// Styles carry no colour; components apply a colour token.
abstract final class ManafaTextStyles {
  /// The one place the font family is defined (Figma variable `font`).
  ///
  /// Cairo ships as a variable font, so each style sets the `wght` axis as
  /// well as [TextStyle.fontWeight].
  static const String fontFamily = 'Cairo';

  /// Fonts are bundled in this package, so styles must name it.
  static const String fontPackage = manafaPackage;

  /// `headers/medium`: Bold 14, line height 1.44, letter spacing -0.084.
  static const TextStyle headersMedium = TextStyle(
    fontFamily: fontFamily,
    package: fontPackage,
    fontSize: 14,
    fontWeight: FontWeight.w700,
    fontVariations: [FontVariation('wght', 700)],
    height: 1.44,
    letterSpacing: -0.084,
    leadingDistribution: TextLeadingDistribution.even,
  );

  /// `body/medium`: Semi Bold 14, line height 1.44, letter spacing -0.084.
  static const TextStyle bodyMedium = TextStyle(
    fontFamily: fontFamily,
    package: fontPackage,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    fontVariations: [FontVariation('wght', 600)],
    height: 1.44,
    letterSpacing: -0.084,
    leadingDistribution: TextLeadingDistribution.even,
  );

  /// `body/small`: Semi Bold 12, line height 1.32, letter spacing 0.
  static const TextStyle bodySmall = TextStyle(
    fontFamily: fontFamily,
    package: fontPackage,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    fontVariations: [FontVariation('wght', 600)],
    height: 1.32,
    letterSpacing: 0,
    leadingDistribution: TextLeadingDistribution.even,
  );
}
