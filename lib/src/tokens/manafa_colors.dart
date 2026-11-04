import 'package:flutter/material.dart';

/// Colour tokens from the Figma Global Design System (`Colors` collection).
///
/// Each field maps to one Figma variable; the Figma name is in its doc
/// comment. Read them with `ManafaColors.of(context)`.
@immutable
class ManafaColors extends ThemeExtension<ManafaColors> {
  const ManafaColors({
    required this.bgSurface2,
    required this.bgBase,
    required this.bgAppColor,
    required this.accentBlue,
    required this.accentRedError,
    required this.alphaWhite,
    required this.textBlack,
    required this.textWhite,
    required this.iconGray,
  });

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

  /// `Alpha/alpha-white`
  final Color alphaWhite;

  /// `Text/text-black`
  final Color textBlack;

  /// `Text/text-white`
  final Color textWhite;

  /// `Icons/icon-gray`
  final Color iconGray;

  static const ManafaColors light = ManafaColors(
    bgSurface2: Color(0x1F767680),
    bgBase: Color(0xFF000000),
    bgAppColor: Color(0xFFF0F0F0),
    accentBlue: Color(0xFF0029CC),
    accentRedError: Color(0xFFFF383C),
    alphaWhite: Color(0xFFFFFFFF),
    textBlack: Color(0xFF000000),
    textWhite: Color(0xFFFFFFFF),
    iconGray: Color(0xFF727272),
  );

  static const ManafaColors dark = ManafaColors(
    bgSurface2: Color(0x3D767680),
    bgBase: Color(0xFFFFFFFF),
    bgAppColor: Color(0xFF000000),
    accentBlue: Color(0xFF0091FF),
    accentRedError: Color(0xFFFF4245),
    alphaWhite: Color(0xFFFFFFFF),
    textBlack: Color(0xFFFFFFFF),
    textWhite: Color(0xFF000000),
    iconGray: Color(0xFF8A8A8A),
  );

  /// The colours of the nearest [Theme], or [light] when none are set.
  static ManafaColors of(BuildContext context) =>
      Theme.of(context).extension<ManafaColors>() ?? light;

  @override
  ManafaColors copyWith({
    Color? bgSurface2,
    Color? bgBase,
    Color? bgAppColor,
    Color? accentBlue,
    Color? accentRedError,
    Color? alphaWhite,
    Color? textBlack,
    Color? textWhite,
    Color? iconGray,
  }) {
    return ManafaColors(
      bgSurface2: bgSurface2 ?? this.bgSurface2,
      bgBase: bgBase ?? this.bgBase,
      bgAppColor: bgAppColor ?? this.bgAppColor,
      accentBlue: accentBlue ?? this.accentBlue,
      accentRedError: accentRedError ?? this.accentRedError,
      alphaWhite: alphaWhite ?? this.alphaWhite,
      textBlack: textBlack ?? this.textBlack,
      textWhite: textWhite ?? this.textWhite,
      iconGray: iconGray ?? this.iconGray,
    );
  }

  @override
  ManafaColors lerp(ManafaColors? other, double t) {
    if (other == null) return this;
    return ManafaColors(
      bgSurface2: Color.lerp(bgSurface2, other.bgSurface2, t)!,
      bgBase: Color.lerp(bgBase, other.bgBase, t)!,
      bgAppColor: Color.lerp(bgAppColor, other.bgAppColor, t)!,
      accentBlue: Color.lerp(accentBlue, other.accentBlue, t)!,
      accentRedError: Color.lerp(accentRedError, other.accentRedError, t)!,
      alphaWhite: Color.lerp(alphaWhite, other.alphaWhite, t)!,
      textBlack: Color.lerp(textBlack, other.textBlack, t)!,
      textWhite: Color.lerp(textWhite, other.textWhite, t)!,
      iconGray: Color.lerp(iconGray, other.iconGray, t)!,
    );
  }
}
