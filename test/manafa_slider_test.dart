import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:manafa_design_system/manafa_design_system.dart';

Widget _host(Widget child, {TextDirection direction = TextDirection.ltr}) {
  return MaterialApp(
    theme: ManafaTheme.light(),
    home: Directionality(
      textDirection: direction,
      child: Scaffold(
        body: Center(child: SizedBox(width: 340, child: child)),
      ),
    ),
  );
}

// Track is 340 wide; a single thumb travels 340 - 28 = 312px.
const _travel = 312.0;

Finder get _track => find.byType(GestureDetector).first;

Offset _thumbCenter(WidgetTester tester, double fraction, {bool rtl = false}) {
  final rect = tester.getRect(_track);
  final fromStart = 2 + 12 + fraction * _travel;
  return Offset(
    rtl ? rect.right - fromStart : rect.left + fromStart,
    rect.center.dy,
  );
}

void main() {
  testWidgets('tapping the track does not jump', (tester) async {
    double value = 50;
    await tester.pumpWidget(
      _host(
        StatefulBuilder(
          builder: (context, setState) => ManafaSlider(
            value: value,
            onChanged: (v) => setState(() => value = v),
          ),
        ),
      ),
    );
    await tester.tapAt(tester.getRect(_track).centerLeft + const Offset(20, 0));
    await tester.pump();
    expect(value, 50);
  });

  testWidgets('dragging the thumb changes the value', (tester) async {
    double value = 50;
    await tester.pumpWidget(
      _host(
        StatefulBuilder(
          builder: (context, setState) => ManafaSlider(
            value: value,
            onChanged: (v) => setState(() => value = v),
          ),
        ),
      ),
    );
    await tester.dragFrom(
      _thumbCenter(tester, 0.5),
      const Offset(_travel / 4, 0),
    );
    await tester.pump();
    expect(value, closeTo(75, 1));
  });

  testWidgets('a drag that starts away from the thumb is ignored', (
    tester,
  ) async {
    double value = 50;
    await tester.pumpWidget(
      _host(
        StatefulBuilder(
          builder: (context, setState) => ManafaSlider(
            value: value,
            onChanged: (v) => setState(() => value = v),
          ),
        ),
      ),
    );
    await tester.dragFrom(_thumbCenter(tester, 0.1), const Offset(60, 0));
    await tester.pump();
    expect(value, 50);
  });

  testWidgets('dragging right lowers the value in RTL', (tester) async {
    double value = 50;
    await tester.pumpWidget(
      _host(
        StatefulBuilder(
          builder: (context, setState) => ManafaSlider(
            value: value,
            onChanged: (v) => setState(() => value = v),
          ),
        ),
        direction: TextDirection.rtl,
      ),
    );
    await tester.dragFrom(
      _thumbCenter(tester, 0.5, rtl: true),
      const Offset(_travel / 4, 0),
    );
    await tester.pump();
    expect(value, closeTo(25, 1));
  });

  testWidgets('values snap to divisions', (tester) async {
    double value = 50;
    await tester.pumpWidget(
      _host(
        StatefulBuilder(
          builder: (context, setState) => ManafaSlider(
            value: value,
            divisions: 4,
            onChanged: (v) => setState(() => value = v),
          ),
        ),
      ),
    );
    await tester.dragFrom(_thumbCenter(tester, 0.5), const Offset(50, 0));
    await tester.pump();
    expect(value, 75);
  });

  testWidgets('range thumbs cannot cross', (tester) async {
    var values = const RangeValues(40, 60);
    await tester.pumpWidget(
      _host(
        StatefulBuilder(
          builder: (context, setState) => ManafaSlider.range(
            values: values,
            onRangeChanged: (v) => setState(() => values = v),
          ),
        ),
      ),
    );
    // Range thumbs travel 340 - 54 = 286px; the minimum thumb starts at 2.
    final rect = tester.getRect(_track);
    final minCenter = Offset(rect.left + 2 + 12 + 0.4 * 286, rect.center.dy);
    await tester.dragFrom(minCenter, const Offset(200, 0));
    await tester.pump();
    expect(values.start, 60);
    expect(values.end, 60);
  });

  testWidgets('shows the tooltip and haptics only while dragging', (
    tester,
  ) async {
    final haptics = <String>[];
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'HapticFeedback.vibrate') haptics.add('tick');
        return null;
      },
    );
    double value = 50;
    await tester.pumpWidget(
      _host(
        StatefulBuilder(
          builder: (context, setState) => ManafaSlider(
            value: value,
            onChanged: (v) => setState(() => value = v),
          ),
        ),
      ),
    );
    expect(find.text('50'), findsNothing);
    final gesture = await tester.startGesture(_thumbCenter(tester, 0.5));
    await gesture.moveBy(const Offset(20, 0));
    await gesture.moveBy(const Offset(20, 0));
    await tester.pump();
    expect(find.text(value.round().toString()), findsOneWidget);
    expect(haptics, isNotEmpty);
    await gesture.up();
    await tester.pump();
    expect(find.text(value.round().toString()), findsNothing);
  });

  testWidgets('exposes slider semantics with min, max and thumb names', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(
      _host(
        ManafaSlider.range(
          values: const RangeValues(20, 80),
          onRangeChanged: (_) {},
          label: 'Price range',
          showCurrency: true,
        ),
      ),
    );
    final min = tester.getSemantics(
      find.bySemanticsLabel('Price range, Minimum'),
    );
    expect(min.value, 'SAR 20');
    expect(min.minValue, '0');
    expect(min.maxValue, '100');
    expect(min.flagsCollection.isSlider, isTrue);
    expect(find.bySemanticsLabel('Price range, Maximum'), findsOneWidget);
    handle.dispose();
  });
}
