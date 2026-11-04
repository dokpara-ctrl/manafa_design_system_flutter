import 'package:flutter/material.dart';

/// Colour tokens from the Figma Global Design System (`Colors` collection).
///
/// Each field maps to one Figma variable; the Figma name is in its doc
/// comment. Read them with `ManafaColors.of(context)`.
@immutable
class ManafaColors extends ThemeExtension<ManafaColors> {
  const ManafaColors({
    required this.bgSurface,
    required this.bgSurface2,
    required this.bgBase,
    required this.bgAppColor,
    required this.accentBlue,
    required this.accentRedError,
    required this.accentOrange,
    required this.accentGreenSuccess,
    required this.alphaWhite,
    required this.textBlack,
    required this.textWhite,
    required this.textSubtext,
    required this.iconGray,
    required this.icon24Black,
  });

  /// `Bg/Pri/bg-surface`
  final Color bgSurface;

  /// `Bg/Pri/bg-surface 2`
  final Color bgSurface2;

  /// `Bg/Pri/bg-base`
  final Color bgBase;

  /// `Bg/Pri/bg-app-color`
  final Color bgAppColor;

  /// `Accent/accent-blue`
  final Color accentBlue;

  /// `Accent/accent-red-error`
  final Color accentRedError;

  /// `Accent/accent-orange`
  final Color accentOrange;

  /// `Accent/accent-green-success`
  final Color accentGreenSuccess;

  /// `Alpha/alpha-white`
  final Color alphaWhite;

  /// `Text/text-black`
  final Color textBlack;

  /// `Text/text-white`
  final Color textWhite;

  /// `Text/text-subtext`
  final Color textSubtext;

  /// `Icons/icon-gray`
  final Color iconGray;

  /// `Icons/icon-24% black`
  final Color icon24Black;

  static const ManafaColors light = ManafaColors(
    bgSurface: Color(0xFFFFFFFF),
    bgSurface2: Color(0x1F767680),
    bgBase: Color(0xFF000000),
    bgAppColor: Color(0xFFF0F0F0),
    accentBlue: Color(0xFF0029CC),
    accentRedError: Color(0xFFFF383C),
    accentOrange: Color(0xFFFF8D28),
    accentGreenSuccess: Color(0xFF34C759),
    alphaWhite: Color(0xFFFFFFFF),
    textBlack: Color(0xFF000000),
    textWhite: Color(0xFFFFFFFF),
    textSubtext: Color(0x991A1A21),
    iconGray: Color(0xFF727272),
    icon24Black: Color(0x3D000000),
  );

  static const ManafaColors dark = ManafaColors(
    bgSurface: Color(0xFF1C1C1E),
    bgSurface2: Color(0x3D767680),
    bgBase: Color(0xFFFFFFFF),
    bgAppColor: Color(0xFF000000),
    accentBlue: Color(0xFF0091FF),
    accentRedError: Color(0xFFFF4245),
    accentOrange: Color(0xFFFF9230),
    accentGreenSuccess: Color(0xFF30D158),
    alphaWhite: Color(0xFFFFFFFF),
    textBlack: Color(0xFFFFFFFF),
    textWhite: Color(0xFF000000),
    textSubtext: Color(0xB2EBEBF5),
    iconGray: Color(0xFF8A8A8A),
    icon24Black: Color(0x3DFFFFFF),
  );

  /// The colours of the nearest [Theme], or [light] when none are set.
  static ManafaColors of(BuildContext context) =>
      Theme.of(context).extension<ManafaColors>() ?? light;

  @override
  ManafaColors copyWith({
    Color? bgSurface,
    Color? bgSurface2,
    Color? bgBase,
    Color? bgAppColor,
    Color? accentBlue,
    Color? accentRedError,
    Color? accentOrange,
    Color? accentGreenSuccess,
    Color? alphaWhite,
    Color? textBlack,
    Color? textWhite,
    Color? textSubtext,
    Color? iconGray,
    Color? icon24Black,
  }) {
    return ManafaColors(
      bgSurface: bgSurface ?? this.bgSurface,
      bgSurface2: bgSurface2 ?? this.bgSurface2,
      bgBase: bgBase ?? this.bgBase,
      bgAppColor: bgAppColor ?? this.bgAppColor,
      accentBlue: accentBlue ?? this.accentBlue,
      accentRedError: accentRedError ?? this.accentRedError,
      accentOrange: accentOrange ?? this.accentOrange,
      accentGreenSuccess: accentGreenSuccess ?? this.accentGreenSuccess,
      alphaWhite: alphaWhite ?? this.alphaWhite,
      textBlack: textBlack ?? this.textBlack,
      textWhite: textWhite ?? this.textWhite,
      textSubtext: textSubtext ?? this.textSubtext,
      iconGray: iconGray ?? this.iconGray,
      icon24Black: icon24Black ?? this.icon24Black,
    );
  }

  @override
  ManafaColors lerp(ManafaColors? other, double t) {
    if (other == null) return this;
    return ManafaColors(
      bgSurface: Color.lerp(bgSurface, other.bgSurface, t)!,
      bgSurface2: Color.lerp(bgSurface2, other.bgSurface2, t)!,
      bgBase: Color.lerp(bgBase, other.bgBase, t)!,
      bgAppColor: Color.lerp(bgAppColor, other.bgAppColor, t)!,
      accentBlue: Color.lerp(accentBlue, other.accentBlue, t)!,
      accentRedError: Color.lerp(accentRedError, other.accentRedError, t)!,
      accentOrange: Color.lerp(accentOrange, other.accentOrange, t)!,
      accentGreenSuccess: Color.lerp(
        accentGreenSuccess,
        other.accentGreenSuccess,
        t,
      )!,
      alphaWhite: Color.lerp(alphaWhite, other.alphaWhite, t)!,
      textBlack: Color.lerp(textBlack, other.textBlack, t)!,
      textWhite: Color.lerp(textWhite, other.textWhite, t)!,
      textSubtext: Color.lerp(textSubtext, other.textSubtext, t)!,
      iconGray: Color.lerp(iconGray, other.iconGray, t)!,
      icon24Black: Color.lerp(icon24Black, other.icon24Black, t)!,
    );
  }
}
