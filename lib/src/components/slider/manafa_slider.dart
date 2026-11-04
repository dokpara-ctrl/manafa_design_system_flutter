import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../icons/manafa_icon.dart';
import '../../tokens/manafa_colors.dart';
import '../../tokens/manafa_radius.dart';
import '../../tokens/manafa_spacing.dart';
import '../../tokens/manafa_typography.dart';

/// Whether a [ManafaSlider] selects one value or a range.
enum ManafaSliderType { single, range }

/// Formats a slider value for display, e.g. `1000` as `1,000` or `40%`.
typedef ManafaSliderFormatter = String Function(double value);

/// Lets the user select a value or a range by dragging a thumb along a track.
///
/// Only the thumb can be dragged: tapping the track does not jump to a value.
/// With [divisions] set, stepper dots are shown and the value snaps to them.
///
/// Spec: Confluence `DED / Slider` and the Figma Global Design System
/// `Slider Group` component.
class ManafaSlider extends StatefulWidget {
  /// A slider with one thumb.
  const ManafaSlider({
    super.key,
    required double this.value,
    required this.onChanged,
    this.min = 0,
    this.max = 100,
    this.divisions,
    this.label,
    this.isRequired = false,
    this.showInfo = false,
    this.onInfoPressed,
    this.infoSemanticLabel = 'More information',
    this.showValue = false,
    this.showCurrency = false,
    this.showMarks = false,
    this.startMark,
    this.endMark,
    this.showTooltip = true,
    this.valueFormatter,
    this.semanticFormatter,
    this.minimumSemanticLabel = 'Minimum',
    this.maximumSemanticLabel = 'Maximum',
  }) : type = ManafaSliderType.single,
       values = null,
       onRangeChanged = null,
       assert(min < max),
       assert(value >= min && value <= max),
       assert(divisions == null || divisions > 0);

  /// A slider with a minimum and a maximum thumb that cannot cross.
  const ManafaSlider.range({
    super.key,
    required RangeValues this.values,
    required this.onRangeChanged,
    this.min = 0,
    this.max = 100,
    this.divisions,
    this.label,
    this.isRequired = false,
    this.showInfo = false,
    this.onInfoPressed,
    this.infoSemanticLabel = 'More information',
    this.showValue = false,
    this.showCurrency = false,
    this.showMarks = false,
    this.startMark,
    this.endMark,
    this.showTooltip = true,
    this.valueFormatter,
    this.semanticFormatter,
    this.minimumSemanticLabel = 'Minimum',
    this.maximumSemanticLabel = 'Maximum',
  }) : type = ManafaSliderType.range,
       value = null,
       onChanged = null,
       assert(min < max),
       assert(divisions == null || divisions > 0);

  final ManafaSliderType type;

  /// The selected value of a single slider.
  final double? value;

  /// The selected range of a range slider.
  final RangeValues? values;

  /// Called while a single slider is dragged. Null disables the slider.
  final ValueChanged<double>? onChanged;

  /// Called while a range slider is dragged. Null disables the slider.
  final ValueChanged<RangeValues>? onRangeChanged;

  final double min;
  final double max;

  /// Number of steps. When set, stepper dots are shown and values snap.
  final int? divisions;

  /// Header label, e.g. "Investment amount".
  final String? label;

  /// Shows the red required asterisk after the label.
  final bool isRequired;

  /// Shows the 16px info icon after the label.
  final bool showInfo;

  /// Called when the info icon is tapped, e.g. to open a Tooltip.
  final VoidCallback? onInfoPressed;

  /// Screen reader name for the info icon.
  final String infoSemanticLabel;

  /// Shows the current value at the end of the header.
  final bool showValue;

  /// Shows the riyal icon before amounts in the header and marks.
  final bool showCurrency;

  /// Shows the start and end labels under the track.
  final bool showMarks;

  /// Start mark text. Defaults to [min] formatted with [valueFormatter].
  final String? startMark;

  /// End mark text. Defaults to [max] formatted with [valueFormatter].
  final String? endMark;

  /// Shows the value tooltip above the thumb while dragging.
  final bool showTooltip;

  /// Formats values for the header, marks and tooltip.
  final ManafaSliderFormatter? valueFormatter;

  /// Formats values for screen readers, e.g. "SAR 1,000". Defaults to
  /// [valueFormatter], with "SAR " in front when [showCurrency] is on.
  final ManafaSliderFormatter? semanticFormatter;

  /// Screen reader name of the range slider's first thumb.
  final String minimumSemanticLabel;

  /// Screen reader name of the range slider's second thumb.
  final String maximumSemanticLabel;

  @override
  State<ManafaSlider> createState() => _ManafaSliderState();
}

// Figma: track 20 high, fill padding 2 around a 24×16 thumb.
const double _trackHeight = 20;
const double _fillPadding = ManafaSpacing.spacing2;
const double _thumbWidth = 24;
const double _thumbHeight = 16;
const double _thumbPressDepth = 1;
// Drags may start this far outside the thumb, for a 48px wide touch target.
const double _thumbHitSlop = 12;
// Continuous sliders tick haptics this many times across the track.
const int _continuousHapticTicks = 20;

class _ManafaSliderState extends State<ManafaSlider> {
  /// Thumb being dragged: 0 for the single or minimum thumb, 1 for maximum.
  int? _activeThumb;

  /// Unsnapped value under the finger, so snapping does not lose drag distance.
  double _dragValue = 0;
  int _hapticTick = 0;

  bool get _isRange => widget.type == ManafaSliderType.range;

  bool get _enabled =>
      _isRange ? widget.onRangeChanged != null : widget.onChanged != null;

  double _valueOf(int thumb) {
    if (!_isRange) return widget.value!;
    return thumb == 0 ? widget.values!.start : widget.values!.end;
  }

  String _format(double value) =>
      (widget.valueFormatter ?? _defaultFormat)(value);

  String _semanticValue(double value) {
    final formatter = widget.semanticFormatter;
    if (formatter != null) return formatter(value);
    return widget.showCurrency ? 'SAR ${_format(value)}' : _format(value);
  }

  double? get _step => widget.divisions == null
      ? null
      : (widget.max - widget.min) / widget.divisions!;

  double _snap(double value) {
    final step = _step;
    if (step == null) return value;
    final snapped = widget.min + ((value - widget.min) / step).round() * step;
    return snapped.clamp(widget.min, widget.max);
  }

  double _fraction(double value) =>
      (value - widget.min) / (widget.max - widget.min);

  // Thumbs sit inside the fill with 2px padding. Range thumbs share the track
  // so that at equal values they sit side by side instead of overlapping.
  double _travel(double width) => _isRange
      ? width - 2 * _thumbWidth - 3 * _fillPadding
      : width - _thumbWidth - 2 * _fillPadding;

  /// Distance from the track's start edge to the thumb's start edge.
  double _thumbStart(int thumb, double width) {
    final offset = _fillPadding + _fraction(_valueOf(thumb)) * _travel(width);
    return thumb == 0 ? offset : offset + _thumbWidth + _fillPadding;
  }

  void _emit(int thumb, double value) {
    if (!_isRange) {
      if (value != widget.value) widget.onChanged!(value);
      return;
    }
    final current = widget.values!;
    final next = thumb == 0
        ? RangeValues(value, current.end)
        : RangeValues(current.start, value);
    if (next != current) widget.onRangeChanged!(next);
  }

  void _hapticFor(double value) {
    final step = _step;
    final tick = step != null
        ? ((value - widget.min) / step).round()
        : (_fraction(value) * _continuousHapticTicks).floor();
    if (tick != _hapticTick) {
      _hapticTick = tick;
      HapticFeedback.selectionClick();
    }
  }

  void _onDragStart(DragStartDetails details, double width, bool rtl) {
    final dx = details.localPosition.dx;
    final position = rtl ? width - dx : dx;
    int? hit;
    double bestDistance = double.infinity;
    for (final thumb in _isRange ? const [0, 1] : const [0]) {
      final start = _thumbStart(thumb, width);
      final center = start + _thumbWidth / 2;
      final distance = (position - center).abs();
      if (distance <= _thumbWidth / 2 + _thumbHitSlop &&
          distance < bestDistance) {
        hit = thumb;
        bestDistance = distance;
      }
    }
    // Drags that start on the track away from a thumb are ignored.
    if (hit == null) return;
    final thumb = hit;
    setState(() {
      _activeThumb = thumb;
      _dragValue = _valueOf(thumb);
      _hapticTick = -1;
    });
    // The first tick fires the drag-start haptic.
    _hapticFor(_dragValue);
  }

  void _onDragUpdate(DragUpdateDetails details, double width, bool rtl) {
    final thumb = _activeThumb;
    if (thumb == null) return;
    final delta = rtl ? -details.delta.dx : details.delta.dx;
    var lower = widget.min;
    var upper = widget.max;
    if (_isRange) {
      // Range thumbs cannot cross.
      if (thumb == 0) upper = widget.values!.end;
      if (thumb == 1) lower = widget.values!.start;
    }
    _dragValue =
        (_dragValue + delta / _travel(width) * (widget.max - widget.min)).clamp(
          lower,
          upper,
        );
    final value = _snap(_dragValue).clamp(lower, upper);
    _hapticFor(value);
    _emit(thumb, value);
  }

  void _onDragEnd() {
    if (_activeThumb == null) return;
    setState(() => _activeThumb = null);
  }

  void _nudge(int thumb, int direction) {
    final step = _step ?? (widget.max - widget.min) / 100;
    var lower = widget.min;
    var upper = widget.max;
    if (_isRange) {
      if (thumb == 0) upper = widget.values!.end;
      if (thumb == 1) lower = widget.values!.start;
    }
    final value = _snap(_valueOf(thumb) + direction * step).clamp(lower, upper);
    HapticFeedback.selectionClick();
    _emit(thumb, value);
  }

  double _nudged(int thumb, int direction) {
    final step = _step ?? (widget.max - widget.min) / 100;
    return _snap(_valueOf(thumb) + direction * step)
        .clamp(widget.min, widget.max);
  }

  @override
  Widget build(BuildContext context) {
    final colors = ManafaColors.of(context);
    final hasHeader = widget.label != null || widget.showValue;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (hasHeader) ...[
          _buildHeader(colors),
          const SizedBox(height: ManafaSpacing.spacing8),
        ],
        _buildTrack(context, colors),
        if (widget.showMarks) ...[
          // Figma: track and marks are grouped with spacing-4.
          const SizedBox(height: ManafaSpacing.spacing4),
          _buildMarks(colors),
        ],
      ],
    );
  }

  Widget _buildHeader(ManafaColors colors) {
    final label = widget.label;
    final headerValue = _isRange
        ? '${_format(widget.values!.start)} – ${_format(widget.values!.end)}'
        : _format(widget.value!);
    return Row(
      children: [
        if (label != null)
          Expanded(
            child: Padding(
              padding: const EdgeInsetsDirectional.only(
                end: ManafaSpacing.spacing8,
              ),
              child: Row(
                children: [
                  Flexible(
                    child: Text(
                      label,
                      style: ManafaTextStyles.headersMedium.copyWith(
                        color: colors.textBlack,
                      ),
                    ),
                  ),
                  if (widget.showInfo) ...[
                    const SizedBox(width: ManafaSpacing.spacing4),
                    _InfoButton(
                      color: colors.iconGray,
                      semanticLabel: widget.infoSemanticLabel,
                      onPressed: widget.onInfoPressed,
                    ),
                  ],
                  // Figma places the asterisk after the info icon.
                  if (widget.isRequired) ...[
                    const SizedBox(width: ManafaSpacing.spacing4),
                    ExcludeSemantics(
                      child: Text(
                        '*',
                        style: ManafaTextStyles.headersMedium.copyWith(
                          color: colors.accentRedError,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        if (label != null && widget.showValue)
          const SizedBox(width: ManafaSpacing.spacing24),
        if (widget.showValue)
          Expanded(
            child: Align(
              alignment: AlignmentDirectional.centerEnd,
              child: _Amount(
                text: headerValue,
                showCurrency: widget.showCurrency,
                style: ManafaTextStyles.bodyMedium.copyWith(
                  color: colors.textBlack,
                ),
                iconColor: colors.textBlack,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildTrack(BuildContext context, ManafaColors colors) {
    final rtl = Directionality.of(context) == TextDirection.rtl;
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final thumbs = _isRange ? const [0, 1] : const [0];
        final fillStart = _isRange ? _thumbStart(0, width) - _fillPadding : 0.0;
        final fillEnd =
            _thumbStart(thumbs.last, width) + _thumbWidth + _fillPadding;
        final active = _activeThumb;
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onHorizontalDragStart: _enabled
              ? (d) => _onDragStart(d, width, rtl)
              : null,
          onHorizontalDragUpdate: _enabled
              ? (d) => _onDragUpdate(d, width, rtl)
              : null,
          onHorizontalDragEnd: _enabled ? (_) => _onDragEnd() : null,
          onHorizontalDragCancel: _enabled ? _onDragEnd : null,
          child: SizedBox(
            height: _trackHeight,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: colors.bgSurface2,
                      borderRadius: ManafaRadius.full,
                    ),
                  ),
                ),
                if (widget.divisions != null)
                  Positioned.fill(
                    child: _StepDots(
                      count: widget.divisions! + 1,
                      color: colors.iconGray,
                    ),
                  ),
                PositionedDirectional(
                  start: fillStart,
                  width: math.max(0, fillEnd - fillStart),
                  top: 0,
                  bottom: 0,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: colors.accentBlue,
                      borderRadius: ManafaRadius.full,
                    ),
                  ),
                ),
                for (final thumb in thumbs)
                  PositionedDirectional(
                    start: _thumbStart(thumb, width),
                    top: _fillPadding,
                    child: _buildThumbSemantics(
                      thumb,
                      rtl,
                      _Thumb(
                        color: colors.alphaWhite,
                        pressed: active == thumb,
                      ),
                    ),
                  ),
                if (widget.showTooltip && active != null)
                  PositionedDirectional(
                    start: _thumbStart(active, width) + _thumbWidth / 2 - width,
                    width: 2 * width,
                    bottom: _trackHeight + ManafaSpacing.spacing8,
                    child: IgnorePointer(
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: _ValueTooltip(
                          text: _format(_valueOf(active)),
                          background: colors.bgBase,
                          foreground: colors.textWhite,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildThumbSemantics(int thumb, bool rtl, Widget child) {
    final label = widget.label;
    final String? name;
    if (_isRange) {
      final thumbName = thumb == 0
          ? widget.minimumSemanticLabel
          : widget.maximumSemanticLabel;
      name = label == null ? thumbName : '$label, $thumbName';
    } else {
      name = label;
    }
    final value = _valueOf(thumb);
    return Semantics(
      slider: true,
      label: name,
      value: _semanticValue(value),
      increasedValue: _semanticValue(_nudged(thumb, 1)),
      decreasedValue: _semanticValue(_nudged(thumb, -1)),
      minValue: _numberString(widget.min),
      maxValue: _numberString(widget.max),
      textDirection: rtl ? TextDirection.rtl : TextDirection.ltr,
      enabled: _enabled,
      onIncrease: _enabled ? () => _nudge(thumb, 1) : null,
      onDecrease: _enabled ? () => _nudge(thumb, -1) : null,
      child: child,
    );
  }

  Widget _buildMarks(ManafaColors colors) {
    final style = ManafaTextStyles.bodySmall.copyWith(color: colors.textBlack);
    return Padding(
      padding: const EdgeInsetsDirectional.symmetric(
        horizontal: ManafaSpacing.spacing4,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: _Amount(
              text: widget.startMark ?? _format(widget.min),
              showCurrency: widget.showCurrency,
              style: style,
              iconColor: colors.textBlack,
            ),
          ),
          const SizedBox(width: ManafaSpacing.spacing24),
          Flexible(
            child: _Amount(
              text: widget.endMark ?? _format(widget.max),
              showCurrency: widget.showCurrency,
              style: style,
              iconColor: colors.textBlack,
            ),
          ),
        ],
      ),
    );
  }
}

/// `1000.0` as `1000`, `0.5` as `0.5`, for semantics min and max.
String _numberString(double value) =>
    value == value.roundToDouble() ? value.round().toString() : '$value';

String _defaultFormat(double value) {
  final rounded = value.round();
  final negative = rounded < 0;
  final digits = rounded.abs().toString();
  final buffer = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buffer.write(',');
    buffer.write(digits[i]);
  }
  return negative ? '-$buffer' : buffer.toString();
}

class _Thumb extends StatelessWidget {
  const _Thumb({required this.color, required this.pressed});

  final Color color;
  final bool pressed;

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: Offset(0, pressed ? _thumbPressDepth : 0),
      child: Container(
        width: _thumbWidth,
        height: _thumbHeight,
        decoration: BoxDecoration(
          color: color,
          borderRadius: ManafaRadius.full,
        ),
      ),
    );
  }
}

class _StepDots extends StatelessWidget {
  const _StepDots({required this.count, required this.color});

  final int count;
  final Color color;

  @override
  Widget build(BuildContext context) {
    // Figma: centred at 50% + 0.5px, 16px inset, spread evenly.
    return Transform.translate(
      offset: const Offset(0, 0.5),
      child: Opacity(
        opacity: 0.2,
        child: Padding(
          padding: const EdgeInsetsDirectional.symmetric(
            horizontal: ManafaSpacing.spacing16,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (var i = 0; i < count; i++)
                Container(
                  width: 3,
                  height: 3,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ValueTooltip extends StatelessWidget {
  const _ValueTooltip({
    required this.text,
    required this.background,
    required this.foreground,
  });

  final String text;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    // Figma small Tooltip: 8×4 padding, radius-16, and a 10px square arrow
    // with radius 4, rotated 45°, 6.14px below the container.
    const arrowBox = 14.142;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(
          left: 0,
          right: 0,
          bottom: -6.14,
          child: Center(
            child: SizedBox.square(
              dimension: arrowBox,
              child: Center(
                child: Transform.rotate(
                  angle: math.pi / 4,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: background,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: ManafaSpacing.spacing8,
            vertical: ManafaSpacing.spacing4,
          ),
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(ManafaRadius.radius16),
          ),
          child: Text(
            text,
            maxLines: 1,
            style: ManafaTextStyles.bodySmall.copyWith(color: foreground),
          ),
        ),
      ],
    );
  }
}

class _InfoButton extends StatelessWidget {
  const _InfoButton({
    required this.color,
    required this.semanticLabel,
    this.onPressed,
  });

  final Color color;
  final String semanticLabel;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: onPressed != null,
      label: semanticLabel,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onPressed,
        child: ManafaIcon(ManafaIconData.generalInfo, color: color),
      ),
    );
  }
}

/// A number with the optional riyal icon in front of it.
///
/// Figma shows the icon to the left of the number in both languages, so the
/// icon is always placed on the left. The text keeps the ambient direction.
class _Amount extends StatelessWidget {
  const _Amount({
    required this.text,
    required this.showCurrency,
    required this.style,
    required this.iconColor,
  });

  final String text;
  final bool showCurrency;
  final TextStyle style;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      textDirection: TextDirection.ltr,
      children: [
        if (showCurrency)
          ManafaIcon(ManafaIconData.generalRiyal, color: iconColor),
        Flexible(
          child: Text(text, style: style, overflow: TextOverflow.ellipsis),
        ),
      ],
    );
  }
}
