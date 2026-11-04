import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:manafa_design_system/manafa_design_system.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import 'main.directories.g.dart';

void main() => runApp(const WidgetbookApp());

@widgetbook.App()
class WidgetbookApp extends StatelessWidget {
  const WidgetbookApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Widgetbook.material(
      directories: directories,
      addons: [
        ViewportAddon([
          // 390 × 844.
          IosViewports.iPhone13,
          // 360 × 800, the most common Android phone size.
          AndroidViewports.samsungGalaxyS20,
        ]),
        MaterialThemeAddon(
          themes: [
            WidgetbookTheme(name: 'Light', data: ManafaTheme.light()),
            WidgetbookTheme(name: 'Dark', data: ManafaTheme.dark()),
          ],
        ),
        LocalizationAddon(
          locales: const [Locale('ar'), Locale('en')],
          initialLocale: const Locale('ar'),
          localizationsDelegates: GlobalMaterialLocalizations.delegates,
        ),
        TextScaleAddon(min: 1, max: 2, divisions: 4),
      ],
    );
  }
}
