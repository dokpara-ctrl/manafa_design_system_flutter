import 'package:flutter/material.dart';
import 'package:manafa_design_system/manafa_design_system.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

/// Figma Global Design System, `Slider Group` component set.
const _figma =
    'https://www.figma.com/design/LPauPCDSWDcNHmluzNtRTl/Global-Design-System?node-id=7850-46570';

@widgetbook.UseCase(name: 'Single', type: ManafaSlider, designLink: _figma)
Widget buildSingle(BuildContext context) {
  final knobs = _CommonKnobs.of(context);
  return _Canvas(
    child: _SingleDemo(
      initial: 40,
      builder: (value, onChanged) => ManafaSlider(
        value: value,
        onChanged: knobs.enabled ? onChanged : null,
        showTooltip: knobs.showTooltip,
        valueFormatter: _percent,
      ),
    ),
  );
}

@widgetbook.UseCase(name: 'Range', type: ManafaSlider, designLink: _figma)
Widget buildRange(BuildContext context) {
  final knobs = _CommonKnobs.of(context);
  final strings = _Strings.of(context);
  return _Canvas(
    child: _RangeDemo(
      initial: const RangeValues(20, 80),
      builder: (values, onChanged) => ManafaSlider.range(
        values: values,
        onRangeChanged: knobs.enabled ? onChanged : null,
        showTooltip: knobs.showTooltip,
        valueFormatter: _percent,
        minimumSemanticLabel: strings.minimum,
        maximumSemanticLabel: strings.maximum,
      ),
    ),
  );
}

@widgetbook.UseCase(name: 'With header', type: ManafaSlider, designLink: _figma)
Widget buildWithHeader(BuildContext context) {
  final strings = _Strings.of(context);
  final label = context.knobs.string(
    label: 'Label',
    initialValue: strings.risk,
  );
  final isRequired = context.knobs.boolean(
    label: 'Required',
    initialValue: true,
  );
  final showInfo = context.knobs.boolean(
    label: 'Info icon',
    initialValue: true,
  );
  final showValue = context.knobs.boolean(
    label: 'Current value',
    initialValue: true,
  );
  final knobs = _CommonKnobs.of(context);
  return _Canvas(
    child: _SingleDemo(
      initial: 40,
      builder: (value, onChanged) => ManafaSlider(
        value: value,
        onChanged: knobs.enabled ? onChanged : null,
        label: label,
        isRequired: isRequired,
        showInfo: showInfo,
        onInfoPressed: () {},
        infoSemanticLabel: strings.info,
        showValue: showValue,
        showTooltip: knobs.showTooltip,
        valueFormatter: _percent,
      ),
    ),
  );
}

@widgetbook.UseCase(
  name: 'With currency',
  type: ManafaSlider,
  designLink: _figma,
)
Widget buildWithCurrency(BuildContext context) {
  final strings = _Strings.of(context);
  final range = context.knobs.boolean(label: 'Range', initialValue: false);
  final knobs = _CommonKnobs.of(context);
  return _Canvas(
    child: range
        ? _RangeDemo(
            initial: const RangeValues(10000, 60000),
            builder: (values, onChanged) => ManafaSlider.range(
              values: values,
              onRangeChanged: knobs.enabled ? onChanged : null,
              min: 1000,
              max: 100000,
              label: strings.amount,
              showValue: true,
              showCurrency: true,
              showMarks: true,
              showTooltip: knobs.showTooltip,
              minimumSemanticLabel: strings.minimum,
              maximumSemanticLabel: strings.maximum,
            ),
          )
        : _SingleDemo(
            initial: 25000,
            builder: (value, onChanged) => ManafaSlider(
              value: value,
              onChanged: knobs.enabled ? onChanged : null,
              min: 1000,
              max: 100000,
              label: strings.amount,
              showValue: true,
              showCurrency: true,
              showMarks: true,
              showTooltip: knobs.showTooltip,
            ),
          ),
  );
}

@widgetbook.UseCase(name: 'With marks', type: ManafaSlider, designLink: _figma)
Widget buildWithMarks(BuildContext context) {
  final knobs = _CommonKnobs.of(context);
  return _Canvas(
    child: _SingleDemo(
      initial: 60,
      builder: (value, onChanged) => ManafaSlider(
        value: value,
        onChanged: knobs.enabled ? onChanged : null,
        showMarks: true,
        showTooltip: knobs.showTooltip,
        valueFormatter: _percent,
      ),
    ),
  );
}

@widgetbook.UseCase(name: 'With steps', type: ManafaSlider, designLink: _figma)
Widget buildWithSteps(BuildContext context) {
  final strings = _Strings.of(context);
  final divisions = context.knobs.int.slider(
    label: 'Steps',
    initialValue: 14,
    min: 2,
    max: 20,
  );
  final range = context.knobs.boolean(label: 'Range', initialValue: false);
  final knobs = _CommonKnobs.of(context);
  String years(double v) => strings.years(v.round());
  return _Canvas(
    child: range
        ? _RangeDemo(
            key: ValueKey('range-$divisions'),
            initial: RangeValues(
              (divisions * 0.25).roundToDouble(),
              (divisions * 0.75).roundToDouble(),
            ),
            builder: (values, onChanged) => ManafaSlider.range(
              values: values,
              onRangeChanged: knobs.enabled ? onChanged : null,
              max: divisions.toDouble(),
              divisions: divisions,
              label: strings.duration,
              showValue: true,
              showMarks: true,
              showTooltip: knobs.showTooltip,
              valueFormatter: years,
              minimumSemanticLabel: strings.minimum,
              maximumSemanticLabel: strings.maximum,
            ),
          )
        : _SingleDemo(
            key: ValueKey('single-$divisions'),
            initial: (divisions / 2).roundToDouble(),
            builder: (value, onChanged) => ManafaSlider(
              value: value,
              onChanged: knobs.enabled ? onChanged : null,
              max: divisions.toDouble(),
              divisions: divisions,
              label: strings.duration,
              showValue: true,
              showMarks: true,
              showTooltip: knobs.showTooltip,
              valueFormatter: years,
            ),
          ),
  );
}

@widgetbook.UseCase(name: 'Arabic', type: ManafaSlider, designLink: _figma)
Widget buildArabic(BuildContext context) {
  const strings = _Strings.arabic;
  final knobs = _CommonKnobs.of(context);
  // Always right to left, whatever the Locale addon says.
  return Directionality(
    textDirection: TextDirection.rtl,
    child: _Canvas(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: ManafaSpacing.spacing32,
        children: [
          _SingleDemo(
            initial: 25000,
            builder: (value, onChanged) => ManafaSlider(
              value: value,
              onChanged: knobs.enabled ? onChanged : null,
              min: 10000,
              max: 100000,
              divisions: 18,
              label: strings.amount,
              isRequired: true,
              showInfo: true,
              onInfoPressed: () {},
              infoSemanticLabel: strings.info,
              showValue: true,
              showCurrency: true,
              showMarks: true,
              showTooltip: knobs.showTooltip,
              semanticFormatter: _riyalArabic,
            ),
          ),
          _RangeDemo(
            initial: const RangeValues(10000, 60000),
            builder: (values, onChanged) => ManafaSlider.range(
              values: values,
              onRangeChanged: knobs.enabled ? onChanged : null,
              min: 1000,
              max: 100000,
              label: strings.priceRange,
              showValue: true,
              showCurrency: true,
              showMarks: true,
              showTooltip: knobs.showTooltip,
              semanticFormatter: _riyalArabic,
              minimumSemanticLabel: strings.minimum,
              maximumSemanticLabel: strings.maximum,
            ),
          ),
        ],
      ),
    ),
  );
}

String _percent(double value) => '${value.round()}%';

String _riyalArabic(double value) => '${value.round()} ريال';

/// Knobs shared by every use case.
class _CommonKnobs {
  const _CommonKnobs({required this.enabled, required this.showTooltip});

  factory _CommonKnobs.of(BuildContext context) => _CommonKnobs(
    showTooltip: context.knobs.boolean(
      label: 'Value tooltip',
      initialValue: true,
    ),
    enabled: context.knobs.boolean(label: 'Enabled', initialValue: true),
  );

  final bool enabled;
  final bool showTooltip;
}

/// Sample copy in the locale picked in the Locale addon.
class _Strings {
  const _Strings({
    required this.amount,
    required this.priceRange,
    required this.risk,
    required this.duration,
    required this.info,
    required this.minimum,
    required this.maximum,
    required this.yearsSuffix,
  });

  static const english = _Strings(
    amount: 'Investment amount',
    priceRange: 'Price range',
    risk: 'Risk level',
    duration: 'Duration',
    info: 'More information',
    minimum: 'Minimum',
    maximum: 'Maximum',
    yearsSuffix: 'years',
  );

  static const arabic = _Strings(
    amount: 'مبلغ الاستثمار',
    priceRange: 'نطاق السعر',
    risk: 'مستوى المخاطرة',
    duration: 'المدة',
    info: 'مزيد من المعلومات',
    minimum: 'الحد الأدنى',
    maximum: 'الحد الأقصى',
    yearsSuffix: 'سنوات',
  );

  static _Strings of(BuildContext context) =>
      Localizations.localeOf(context).languageCode == 'ar' ? arabic : english;

  final String amount;
  final String priceRange;
  final String risk;
  final String duration;
  final String info;
  final String minimum;
  final String maximum;
  final String yearsSuffix;

  String years(int count) => '$count $yearsSuffix';
}

/// The app background with a 340px reference width, as in Figma.
class _Canvas extends StatelessWidget {
  const _Canvas({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: ManafaColors.of(context).bgAppColor,
      child: Center(
        child: Padding(
          // Leaves room for the value tooltip above the track.
          padding: const EdgeInsets.symmetric(
            horizontal: ManafaSpacing.spacing24,
            vertical: ManafaSpacing.spacing32,
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 340),
            child: child,
          ),
        ),
      ),
    );
  }
}

class _SingleDemo extends StatefulWidget {
  const _SingleDemo({super.key, required this.initial, required this.builder});

  final double initial;
  final Widget Function(double value, ValueChanged<double> onChanged) builder;

  @override
  State<_SingleDemo> createState() => _SingleDemoState();
}

class _SingleDemoState extends State<_SingleDemo> {
  late double _value = widget.initial;

  @override
  Widget build(BuildContext context) =>
      widget.builder(_value, (value) => setState(() => _value = value));
}

class _RangeDemo extends StatefulWidget {
  const _RangeDemo({super.key, required this.initial, required this.builder});

  final RangeValues initial;
  final Widget Function(RangeValues values, ValueChanged<RangeValues> onChanged)
  builder;

  @override
  State<_RangeDemo> createState() => _RangeDemoState();
}

class _RangeDemoState extends State<_RangeDemo> {
  late RangeValues _values = widget.initial;

  @override
  Widget build(BuildContext context) =>
      widget.builder(_values, (values) => setState(() => _values = values));
}
