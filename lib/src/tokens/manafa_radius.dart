import 'package:flutter/widgets.dart';

/// Radius tokens from the Figma Global Design System (`Radius` collection).
///
/// Names match Figma: `radius-16` is [ManafaRadius.radius16].
abstract final class ManafaRadius {
  static const double radius8 = 8;
  static const double radius16 = 16;

  /// `radius-full`: large enough to fully round any component.
  static const double radiusFull = 999;

  static const BorderRadius full = BorderRadius.all(
    Radius.circular(radiusFull),
  );
}
