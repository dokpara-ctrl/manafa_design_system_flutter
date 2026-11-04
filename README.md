# Manafa Design System (Flutter)

The Flutter counterpart of Manafa's web Storybook: design tokens and components
for the mobile apps, with a [Widgetbook](https://www.widgetbook.io) to browse them.

Source of truth: the Figma Global Design System (`LPauPCDSWDcNHmluzNtRTl`) and
the component pages in Confluence (`DED`). When they disagree, Figma wins.

## Layout

```
lib/
  manafa_design_system.dart     public API (import this)
  src/
    tokens/                     colors, spacing, radius, typography, theme
    icons/                      Manafa icons (SVG assets)
    components/<name>/          one folder per component
assets/
  fonts/                        Cairo (variable font, OFL)
  icons/                        SVG icons from Figma
widgetbook/                     Widgetbook app (use cases per component)
test/                           widget tests
```

## Using it

```yaml
dependencies:
  manafa_design_system:
    git:
      url: <this repo>
```

```dart
MaterialApp(
  theme: ManafaTheme.light(),
  darkTheme: ManafaTheme.dark(),
  home: ManafaSlider(value: 40, onChanged: (v) {}),
);
```

Read tokens with `ManafaColors.of(context)`, `ManafaSpacing.spacing16`,
`ManafaRadius.radius16` and `ManafaTextStyles.bodyMedium`. Token names follow
Figma: `Bg/Pri/bg-surface 2` is `bgSurface2`, `spacing-8` is `spacing8`.

## Running Widgetbook

```bash
cd widgetbook
dart run build_runner build --delete-conflicting-outputs
flutter run -d chrome
```

Rerun `build_runner` after adding or renaming a `@widgetbook.UseCase`.

## Components

| Component | Figma | Confluence |
| --- | --- | --- |
| Slider | `Slider Group` | `DED / Slider` |
