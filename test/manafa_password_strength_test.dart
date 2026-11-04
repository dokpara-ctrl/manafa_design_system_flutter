import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:manafa_design_system/manafa_design_system.dart';

Widget _host(Widget child, {Locale locale = const Locale('en')}) {
  return MaterialApp(
    theme: ManafaTheme.light(),
    locale: locale,
    supportedLocales: const [Locale('en'), Locale('ar')],
    localizationsDelegates: GlobalMaterialLocalizations.delegates,
    home: Scaffold(body: SizedBox(width: 340, child: child)),
  );
}

void main() {
  group('rules', () {
    int met(String password) =>
        ManafaPasswordStrengthResult.evaluate(password).metCount;

    test('Figma examples', () {
      expect(met(''), 0);
      expect(met('Ab'), 2);
      expect(met('Ab1'), 3);
      expect(met('Ab1!'), 4);
      expect(met('Ab1!xyz9'), 5);
      expect(ManafaPasswordStrengthResult.evaluate('Ab1!xyz9').isValid, isTrue);
    });

    test('rules pass in any order', () {
      final result = ManafaPasswordStrengthResult.evaluate('12345678');
      expect(result.metRules, {'number', 'minLength'});
      expect(result.isValid, isFalse);
    });

    test('custom rules replace the defaults', () {
      final result = ManafaPasswordStrengthResult.evaluate('abc', [
        ManafaPasswordRule.lowercase,
        ManafaPasswordRule.number,
      ]);
      expect(result.metCount, 1);
      expect(result.rules.length, 2);
    });
  });

  testWidgets('reports the result and collapses when complete', (tester) async {
    final reports = <ManafaPasswordStrengthResult>[];
    var password = 'Ab1!';
    late StateSetter setPassword;
    await tester.pumpWidget(
      _host(
        StatefulBuilder(
          builder: (context, setState) {
            setPassword = setState;
            return ManafaPasswordStrength(
              password: password,
              onChanged: reports.add,
            );
          },
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(reports.single.metCount, 4);
    expect(find.text('At least 8 characters'), findsOneWidget);

    setPassword(() => password = 'Ab1!xyz9');
    await tester.pumpAndSettle();
    expect(reports.last.isValid, isTrue);
    // Collapsed: the checklist is laid out at zero height.
    final crossFade = tester.widget<AnimatedCrossFade>(
      find.byType(AnimatedCrossFade),
    );
    expect(crossFade.crossFadeState, CrossFadeState.showSecond);

    setPassword(() => password = 'Ab1!xyz');
    await tester.pumpAndSettle();
    expect(reports.last.metCount, 4);
    expect(
      tester
          .widget<AnimatedCrossFade>(find.byType(AnimatedCrossFade))
          .crossFadeState,
      CrossFadeState.showFirst,
    );
  });

  testWidgets('does not report again when the met rules are unchanged', (
    tester,
  ) async {
    final reports = <ManafaPasswordStrengthResult>[];
    var password = 'ab';
    late StateSetter setPassword;
    await tester.pumpWidget(
      _host(
        StatefulBuilder(
          builder: (context, setState) {
            setPassword = setState;
            return ManafaPasswordStrength(
              password: password,
              onChanged: reports.add,
            );
          },
        ),
      ),
    );
    await tester.pump();
    setPassword(() => password = 'abc');
    await tester.pump();
    await tester.pump();
    expect(reports.length, 1);
  });

  testWidgets('announces the count and each rule', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(
      _host(const ManafaPasswordStrength(password: 'Ab1')),
    );
    await tester.pumpAndSettle();
    final summary = tester.getSemantics(
      find.bySemanticsLabel('3 of 5 password rules met'),
    );
    expect(summary.flagsCollection.isLiveRegion, isTrue);
    expect(
      find.bySemanticsLabel('At least one number (0–9), met'),
      findsOneWidget,
    );
    expect(
      find.bySemanticsLabel('At least 8 characters, not met'),
      findsOneWidget,
    );
    handle.dispose();
  });

  testWidgets('uses Arabic labels and mirrors in Arabic', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(
      _host(
        const ManafaPasswordStrength(password: 'Ab'),
        locale: const Locale('ar'),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('رقم واحد على الأقل'), findsOneWidget);
    expect(
      find.bySemanticsLabel('تم استيفاء 2 من 5 من شروط كلمة المرور'),
      findsOneWidget,
    );
    // RTL: the icon sits to the right of its label.
    final icon = tester.getCenter(find.byType(ManafaIcon).first);
    final label = tester.getCenter(find.text('حرف واحد كبير على الأقل'));
    expect(icon.dx, greaterThan(label.dx));
    handle.dispose();
  });
}
