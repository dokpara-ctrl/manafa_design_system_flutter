import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../manafa_package.dart';

/// Icons from the Figma Global Design System (`↪ Icons` page).
///
/// Names match Figma: `icon/general/info` is [ManafaIconData.generalInfo].
enum ManafaIconData {
  /// `icons/alerts/success-fill`
  alertsSuccessFill('assets/icons/icon_alerts_success_fill.svg'),

  /// `icon/general/info`
  generalInfo('assets/icons/icon_general_info.svg'),

  /// `icon/general/riyal-icon`
  generalRiyal('assets/icons/icon_general_riyal.svg');

  const ManafaIconData(this.assetPath);

  final String assetPath;
}

/// A Manafa icon, tinted with a colour token.
class ManafaIcon extends StatelessWidget {
  const ManafaIcon(
    this.icon, {
    super.key,
    required this.color,
    this.size = 16,
    this.semanticLabel,
  });

  final ManafaIconData icon;
  final Color color;
  final double size;

  /// Leave null for decorative icons.
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      icon.assetPath,
      package: manafaPackage,
      width: size,
      height: size,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
      semanticsLabel: semanticLabel,
      excludeFromSemantics: semanticLabel == null,
    );
  }
}
