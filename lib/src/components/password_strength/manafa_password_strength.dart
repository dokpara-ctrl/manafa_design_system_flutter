import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../../icons/manafa_icon.dart';
import '../../tokens/manafa_colors.dart';
import '../../tokens/manafa_radius.dart';
import '../../tokens/manafa_spacing.dart';
import '../../tokens/manafa_typography.dart';

/// One password rule, with its label in both languages and its test.
@immutable
class ManafaPasswordRule {
  const ManafaPasswordRule({
    required this.id,
    required this.englishLabel,
    required this.arabicLabel,
    required this.test,
  });

  /// Stable name for the rule, e.g. `uppercase`.
  final String id;
  final String englishLabel;
  final String arabicLabel;

  /// Whether [password] meets the rule.
  final bool Function(String password) test;

  /// At least one uppercase letter (A–Z).
  static const uppercase = ManafaPasswordRule(
    id: 'uppercase',
    englishLabel: 'At least one uppercase letter (A–Z)',
    arabicLabel: 'حرف واحد كبير على الأقل',
    test: _hasUppercase,
  );

  /// At least one lowercase letter (a–z).
  static const lowercase = ManafaPasswordRule(
    id: 'lowercase',
    englishLabel: 'At least one lowercase letter (a–z)',
    arabicLabel: 'حرف واحد صغير على الأقل',
    test: _hasLowercase,
  );

  /// At least one number (0–9).
  static const number = ManafaPasswordRule(
    id: 'number',
    englishLabel: 'At least one number (0–9)',
    arabicLabel: 'رقم واحد على الأقل',
    test: _hasNumber,
  );

  /// At least one special character, i.e. ASCII punctuation or a symbol.
  static const specialCharacter = ManafaPasswordRule(
    id: 'special',
    englishLabel: 'At least one special character (e.g., ! @ # \$ %)',
    arabicLabel: 'رمز واحد على الأقل',
    test: _hasSpecialCharacter,
  );

  /// At least 8 characters.
  static const minLength = ManafaPasswordRule(
    id: 'minLength',
    englishLabel: 'At least 8 characters',
    arabicLabel: 'ما لا يقل عن 8 أحرف ورموز',
    test: _hasMinLength,
  );

  /// The five rules from the Confluence page, in their display order.
  static const defaults = [
    uppercase,
    lowercase,
    number,
    specialCharacter,
    minLength,
  ];

  String labelFor(Locale locale) =>
      locale.languageCode == 'ar' ? arabicLabel : englishLabel;
}

bool _hasUppercase(String p) => RegExp('[A-Z]').hasMatch(p);
bool _hasLowercase(String p) => RegExp('[a-z]').hasMatch(p);
bool _hasNumber(String p) => RegExp('[0-9]').hasMatch(p);
bool _hasSpecialCharacter(String p) => RegExp(r'[!-/:-@\[-`{-~]').hasMatch(p);
bool _hasMinLength(String p) => p.runes.length >= 8;

/// Which rules a password meets.
@immutable
class ManafaPasswordStrengthResult {
  const ManafaPasswordStrengthResult({
    required this.rules,
    required this.metRules,
  });

  /// Checks [password] against [rules].
  factory ManafaPasswordStrengthResult.evaluate(
    String password, [
    List<ManafaPasswordRule> rules = ManafaPasswordRule.defaults,
  ]) {
    return ManafaPasswordStrengthResult(
      rules: rules,
      metRules: {
        for (final rule in rules)
          if (rule.test(password)) rule.id,
      },
    );
  }

  final List<ManafaPasswordRule> rules;

  /// Ids of the rules that pass.
  final Set<String> metRules;

  int get metCount => metRules.length;

  bool isMet(ManafaPasswordRule rule) => metRules.contains(rule.id);

  /// All rules pass, so the screen can enable Continue.
  bool get isValid => metRules.length == rules.length;

  @override
  bool operator ==(Object other) =>
      other is ManafaPasswordStrengthResult &&
      other.rules == rules &&
      other.metRules.length == metRules.length &&
      other.metRules.containsAll(metRules);

  @override
  int get hashCode => Object.hash(rules, Object.hashAllUnordered(metRules));
}

/// Shows how close a new password is to meeting the password rules.
///
/// Place it directly under the password field and pass the field's text.
/// The bar fills by one step per rule met; the checklist collapses once all
/// rules pass and opens again if one stops passing.
///
/// Hiding it when focus moves to Confirm password is the screen's job.
///
/// Spec: Confluence `DED / Password Strength` and the Figma Global Design
/// System `Password Strength` component.
class ManafaPasswordStrength extends StatefulWidget {
  const ManafaPasswordStrength({
    super.key,
    required this.password,
    this.rules = ManafaPasswordRule.defaults,
    this.onChanged,
  });

  final String password;

  /// Rules to check, in display order. Defaults to the five Manafa rules.
  final List<ManafaPasswordRule> rules;

  /// Called after a build in which the set of met rules changed, and once
  /// after the first build.
  final ValueChanged<ManafaPasswordStrengthResult>? onChanged;

  @override
  State<ManafaPasswordStrength> createState() => _ManafaPasswordStrengthState();
}

const Duration _duration = Duration(milliseconds: 250);
const Curve _curve = Curves.easeOutCubic;
const double _barHeight = 6;
// Figma: Start shows a 2px stub in icon-24% black.
const double _startStubWidth = 2;
const double _iconSize = 16;

class _ManafaPasswordStrengthState extends State<ManafaPasswordStrength> {
  late ManafaPasswordStrengthResult _result;
  ManafaPasswordStrengthResult? _reported;

  @override
  void initState() {
    super.initState();
    assert(widget.rules.isNotEmpty, 'rules must not be empty');
    _result = ManafaPasswordStrengthResult.evaluate(
      widget.password,
      widget.rules,
    );
    _scheduleReport();
  }

  @override
  void didUpdateWidget(ManafaPasswordStrength oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.password != widget.password ||
        oldWidget.rules != widget.rules) {
      _result = ManafaPasswordStrengthResult.evaluate(
        widget.password,
        widget.rules,
      );
      _scheduleReport();
    }
  }

  // Reported after the frame, so a parent can setState in onChanged.
  void _scheduleReport() {
    if (widget.onChanged == null || _result == _reported) return;
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _result == _reported) return;
      _reported = _result;
      widget.onChanged?.call(_result);
    });
  }

  Color _barColor(ManafaColors colors) {
    final met = _result.metCount;
    final total = widget.rules.length;
    if (met == 0) return colors.icon24Black;
    if (met == total) return colors.accentGreenSuccess;
    // Five rules: red at 1–2, orange at 3–4.
    return met / total <= 0.4 ? colors.accentRedError : colors.accentOrange;
  }

  @override
  Widget build(BuildContext context) {
    final colors = ManafaColors.of(context);
    final strings = _Strings.of(context);
    final locale = Localizations.maybeLocaleOf(context) ?? const Locale('en');
    final total = widget.rules.length;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          container: true,
          liveRegion: true,
          label: strings.summary(_result.metCount, total),
          child: ExcludeSemantics(
            child: _Bar(
              fraction: _result.metCount / total,
              color: _barColor(colors),
              track: colors.bgAppColor,
            ),
          ),
        ),
        AnimatedCrossFade(
          duration: _duration,
          firstCurve: _curve,
          secondCurve: _curve,
          sizeCurve: _curve,
          crossFadeState: _result.isValid
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          firstChild: Padding(
            padding: const EdgeInsetsDirectional.only(
              top: ManafaSpacing.spacing8,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: ManafaSpacing.spacing8,
              children: [
                for (final rule in widget.rules)
                  _RuleRow(
                    label: rule.labelFor(locale),
                    met: _result.isMet(rule),
                    strings: strings,
                    colors: colors,
                  ),
              ],
            ),
          ),
          secondChild: const SizedBox(width: double.infinity),
        ),
      ],
    );
  }
}

class _Bar extends StatelessWidget {
  const _Bar({
    required this.fraction,
    required this.color,
    required this.track,
  });

  final double fraction;
  final Color color;
  final Color track;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: ManafaRadius.full,
      child: ColoredBox(
        color: track,
        child: SizedBox(
          height: _barHeight,
          child: LayoutBuilder(
            builder: (context, constraints) => Align(
              alignment: AlignmentDirectional.centerStart,
              child: AnimatedContainer(
                duration: _duration,
                curve: _curve,
                width: math.max(
                  _startStubWidth,
                  constraints.maxWidth * fraction,
                ),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: ManafaRadius.full,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RuleRow extends StatelessWidget {
  const _RuleRow({
    required this.label,
    required this.met,
    required this.strings,
    required this.colors,
  });

  final String label;
  final bool met;
  final _Strings strings;
  final ManafaColors colors;

  @override
  Widget build(BuildContext context) {
    return MergeSemantics(
      child: Semantics(
        label: '$label, ${met ? strings.met : strings.notMet}',
        child: ExcludeSemantics(
          child: Row(
            spacing: ManafaSpacing.spacing4,
            children: [
              TweenAnimationBuilder<Color?>(
                duration: _duration,
                curve: _curve,
                tween: ColorTween(
                  end: met ? colors.accentGreenSuccess : colors.icon24Black,
                ),
                builder: (context, color, _) => ManafaIcon(
                  ManafaIconData.alertsSuccessFill,
                  color: color!,
                  size: _iconSize,
                ),
              ),
              Flexible(
                child: Text(
                  label,
                  style: ManafaTextStyles.bodySmall.copyWith(
                    color: colors.textSubtext,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Screen reader copy, in the app's language.
class _Strings {
  const _Strings({
    required this.met,
    required this.notMet,
    required this.summary,
  });

  static final english = _Strings(
    met: 'met',
    notMet: 'not met',
    summary: (met, total) => '$met of $total password rules met',
  );

  static final arabic = _Strings(
    met: 'مستوفى',
    notMet: 'غير مستوفى',
    summary: (met, total) => 'تم استيفاء $met من $total من شروط كلمة المرور',
  );

  static _Strings of(BuildContext context) =>
      Localizations.maybeLocaleOf(context)?.languageCode == 'ar'
      ? arabic
      : english;

  final String met;
  final String notMet;
  final String Function(int met, int total) summary;
}
