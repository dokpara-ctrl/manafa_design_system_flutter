import 'package:flutter/material.dart';
import 'package:manafa_design_system/manafa_design_system.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

/// Figma Global Design System, `Password Strength` page.
const _figma =
    'https://www.figma.com/design/LPauPCDSWDcNHmluzNtRTl/Global-Design-system?node-id=9936-7236';

@widgetbook.UseCase(
  name: 'Playground',
  type: ManafaPasswordStrength,
  designLink: _figma,
)
Widget buildPlayground(BuildContext context) {
  return const _Canvas(child: _Playground());
}

@widgetbook.UseCase(
  name: 'State: 0 of 5 (Start)',
  type: ManafaPasswordStrength,
  designLink: _figma,
)
Widget buildStart(BuildContext context) =>
    const _Canvas(child: _StateExample(typed: ''));

@widgetbook.UseCase(
  name: 'State: 2 of 5',
  type: ManafaPasswordStrength,
  designLink: _figma,
)
Widget buildTwo(BuildContext context) =>
    const _Canvas(child: _StateExample(typed: 'Ab'));

@widgetbook.UseCase(
  name: 'State: 3 of 5',
  type: ManafaPasswordStrength,
  designLink: _figma,
)
Widget buildThree(BuildContext context) =>
    const _Canvas(child: _StateExample(typed: 'Ab1'));

@widgetbook.UseCase(
  name: 'State: 4 of 5',
  type: ManafaPasswordStrength,
  designLink: _figma,
)
Widget buildFour(BuildContext context) =>
    const _Canvas(child: _StateExample(typed: 'Ab1!'));

@widgetbook.UseCase(
  name: 'State: 5 of 5 (Complete)',
  type: ManafaPasswordStrength,
  designLink: _figma,
)
Widget buildComplete(BuildContext context) =>
    const _Canvas(child: _StateExample(typed: 'Ab1!xyz9'));

@widgetbook.UseCase(
  name: 'Full flow',
  type: ManafaPasswordStrength,
  designLink: _figma,
)
Widget buildFullFlow(BuildContext context) =>
    const _Canvas(child: _CreatePasswordFlow());

@widgetbook.UseCase(
  name: 'Arabic',
  type: ManafaPasswordStrength,
  designLink: _figma,
)
Widget buildArabic(BuildContext context) {
  // Always Arabic and right to left, whatever the Locale addon says.
  return Localizations.override(
    context: context,
    locale: const Locale('ar'),
    child: const _Canvas(child: _CreatePasswordFlow()),
  );
}

/// A password field to type into, with the live result underneath.
class _Playground extends StatefulWidget {
  const _Playground();

  @override
  State<_Playground> createState() => _PlaygroundState();
}

class _PlaygroundState extends State<_Playground> {
  final _controller = TextEditingController();
  ManafaPasswordStrengthResult? _result;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings = _Strings.of(context);
    final colors = ManafaColors.of(context);
    final result = _result;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _PasswordField(
          label: strings.password,
          hint: strings.hint,
          controller: _controller,
        ),
        const SizedBox(height: ManafaSpacing.spacing8),
        ManafaPasswordStrength(
          password: _controller.text,
          onChanged: (r) => setState(() => _result = r),
        ),
        const SizedBox(height: ManafaSpacing.spacing24),
        if (result != null)
          Text(
            'onChanged: ${result.metCount} of ${result.rules.length} met, '
            'isValid: ${result.isValid}',
            textDirection: TextDirection.ltr,
            style: ManafaTextStyles.bodySmall.copyWith(
              color: colors.textSubtext,
            ),
          ),
      ],
    );
  }
}

/// One of the Figma examples: a filled field and the strength under it.
class _StateExample extends StatelessWidget {
  const _StateExample({required this.typed});

  final String typed;

  @override
  Widget build(BuildContext context) {
    final strings = _Strings.of(context);
    final colors = ManafaColors.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          '${strings.typed}: ${typed.isEmpty ? '—' : typed}',
          style: ManafaTextStyles.bodySmall.copyWith(color: colors.textSubtext),
        ),
        const SizedBox(height: ManafaSpacing.spacing16),
        _PasswordField(
          label: strings.password,
          hint: strings.hint,
          initialText: typed,
          readOnly: true,
        ),
        const SizedBox(height: ManafaSpacing.spacing8),
        ManafaPasswordStrength(password: typed),
      ],
    );
  }
}

/// Create password screen: strength shows under Password and hides when
/// Confirm password has focus; Continue needs all rules and a match.
class _CreatePasswordFlow extends StatefulWidget {
  const _CreatePasswordFlow();

  @override
  State<_CreatePasswordFlow> createState() => _CreatePasswordFlowState();
}

class _CreatePasswordFlowState extends State<_CreatePasswordFlow> {
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  final _passwordFocus = FocusNode();
  final _confirmFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    for (final listenable in [
      _password,
      _confirm,
      _passwordFocus,
      _confirmFocus,
    ]) {
      listenable.addListener(() => setState(() {}));
    }
  }

  @override
  void dispose() {
    _password.dispose();
    _confirm.dispose();
    _passwordFocus.dispose();
    _confirmFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings = _Strings.of(context);
    final colors = ManafaColors.of(context);
    final password = _password.text;
    final isValid = ManafaPasswordStrengthResult.evaluate(password).isValid;
    final canContinue = isValid && _confirm.text == password;
    // Confluence Logic: nothing while empty and unfocused; hidden while
    // Confirm password has focus.
    final showStrength =
        !_confirmFocus.hasFocus &&
        (_passwordFocus.hasFocus || password.isNotEmpty);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _PasswordField(
          label: strings.password,
          hint: strings.hint,
          controller: _password,
          focusNode: _passwordFocus,
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          alignment: AlignmentDirectional.topStart,
          child: showStrength
              ? Padding(
                  padding: const EdgeInsetsDirectional.only(
                    top: ManafaSpacing.spacing8,
                  ),
                  child: ManafaPasswordStrength(password: password),
                )
              : const SizedBox(width: double.infinity),
        ),
        const SizedBox(height: ManafaSpacing.spacing24),
        _PasswordField(
          label: strings.confirm,
          hint: strings.hint,
          controller: _confirm,
          focusNode: _confirmFocus,
        ),
        const SizedBox(height: ManafaSpacing.spacing32),
        // Stand-in until the Button component is in the Flutter library.
        FilledButton(
          onPressed: canContinue ? () {} : null,
          style: FilledButton.styleFrom(
            backgroundColor: colors.accentBlue,
            foregroundColor: colors.alphaWhite,
            minimumSize: const Size.fromHeight(36),
            textStyle: ManafaTextStyles.bodyMedium,
          ),
          child: Text(strings.continueLabel),
        ),
      ],
    );
  }
}

/// Stand-in for the Figma `Input-fields/password` until Input Field is in
/// the Flutter library.
class _PasswordField extends StatefulWidget {
  const _PasswordField({
    required this.label,
    required this.hint,
    this.controller,
    this.initialText,
    this.focusNode,
    this.readOnly = false,
  });

  final String label;
  final String hint;

  /// Defaults to a controller holding [initialText].
  final TextEditingController? controller;
  final String? initialText;
  final FocusNode? focusNode;
  final bool readOnly;

  @override
  State<_PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<_PasswordField> {
  bool _obscured = true;
  late final TextEditingController _ownController = TextEditingController(
    text: widget.initialText,
  );

  @override
  void dispose() {
    _ownController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = ManafaColors.of(context);
    OutlineInputBorder border(Color color, double width) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(ManafaRadius.radius16),
      borderSide: BorderSide(color: color, width: width),
    );
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          spacing: ManafaSpacing.spacing4,
          children: [
            Text(
              widget.label,
              style: ManafaTextStyles.headersMedium.copyWith(
                color: colors.textBlack,
              ),
            ),
            Text(
              '*',
              style: ManafaTextStyles.headersMedium.copyWith(
                color: colors.accentRedError,
              ),
            ),
          ],
        ),
        const SizedBox(height: ManafaSpacing.spacing8),
        TextField(
          controller: widget.controller ?? _ownController,
          focusNode: widget.focusNode,
          readOnly: widget.readOnly,
          obscureText: _obscured,
          enableSuggestions: false,
          autocorrect: false,
          style: ManafaTextStyles.bodyMedium.copyWith(color: colors.textBlack),
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: ManafaTextStyles.bodyMedium.copyWith(
              color: colors.textSubtext,
            ),
            filled: true,
            fillColor: colors.alphaWhite.withValues(
              alpha: Theme.of(context).brightness == Brightness.dark ? 0.08 : 1,
            ),
            contentPadding: const EdgeInsetsDirectional.symmetric(
              horizontal: ManafaSpacing.spacing16,
              vertical: ManafaSpacing.spacing12,
            ),
            enabledBorder: border(colors.bgSurface2, 1),
            focusedBorder: border(colors.accentBlue, 2),
            suffixIcon: IconButton(
              onPressed: () => setState(() => _obscured = !_obscured),
              icon: Icon(
                _obscured
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                color: colors.textBlack,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Sample copy in the locale picked in the Locale addon.
class _Strings {
  const _Strings({
    required this.password,
    required this.confirm,
    required this.hint,
    required this.continueLabel,
    required this.typed,
  });

  static const english = _Strings(
    password: 'Password',
    confirm: 'Confirm password',
    hint: 'Enter password',
    continueLabel: 'Continue',
    typed: 'Typed',
  );

  static const arabic = _Strings(
    password: 'كلمة المرور',
    confirm: 'تأكيد كلمة المرور',
    hint: 'أدخل كلمة المرور',
    continueLabel: 'متابعة',
    typed: 'المدخل',
  );

  static _Strings of(BuildContext context) =>
      Localizations.localeOf(context).languageCode == 'ar' ? arabic : english;

  final String password;
  final String confirm;
  final String hint;
  final String continueLabel;
  final String typed;
}

/// A `bg-surface` card on the app background, as in the Figma examples.
/// The strength track is `bg-app-color`, so it needs the card to show.
class _Canvas extends StatelessWidget {
  const _Canvas({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: ManafaColors.of(context).bgAppColor,
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(ManafaSpacing.spacing16),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 388),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: ManafaColors.of(context).bgSurface,
                // Figma example card radius; not a component token.
                borderRadius: BorderRadius.circular(24),
              ),
              child: Padding(
                padding: const EdgeInsets.all(ManafaSpacing.spacing24),
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
