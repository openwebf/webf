import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:webf/webf.dart';

import '../../setup.dart';
import '../widget/test_utils.dart';

void main() {
  setUpAll(() {
    setupTest();
  });

  setUp(() {
    WebFControllerManager.instance.initialize(
      WebFControllerManagerConfig(
        maxAliveInstances: 5,
        maxAttachedInstances: 5,
        enableDevTools: false,
      ),
    );
  });

  tearDown(() async {
    WebFControllerManager.instance.disposeAll();
    await Future.delayed(const Duration(milliseconds: 100));
  });

  group('Input Checked', () {
    testWidgets('checkbox initializes from checked attribute presence', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'checkbox-initial-checked-test-${DateTime.now().millisecondsSinceEpoch}',
        wrap: (child) => MaterialApp(home: Scaffold(body: child)),
        html: '''
          <html>
            <body style="margin: 0; padding: 0;">
              <input id="cb" type="checkbox" checked />
            </body>
          </html>
        ''',
      );

      final cb = prepared.getElementById('cb') as dynamic;
      expect(cb.getChecked(), isTrue);
    });

    testWidgets('radio initializes from checked attribute presence', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'radio-initial-checked-test-${DateTime.now().millisecondsSinceEpoch}',
        wrap: (child) => MaterialApp(home: Scaffold(body: child)),
        html: '''
          <html>
            <body style="margin: 0; padding: 0;">
              <input id="r1" type="radio" name="g" value="a" checked />
              <input id="r2" type="radio" name="g" value="b" />
            </body>
          </html>
        ''',
      );

      final r1 = prepared.getElementById('r1') as dynamic;
      final r2 = prepared.getElementById('r2') as dynamic;
      expect(r1.getChecked(), isTrue);
      expect(r2.getChecked(), isFalse);
    });

    testWidgets('checkbox checked toggles with attribute set/remove', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'checkbox-attr-toggle-test-${DateTime.now().millisecondsSinceEpoch}',
        wrap: (child) => MaterialApp(home: Scaffold(body: child)),
        html: '''
          <html>
            <body style="margin: 0; padding: 0;">
              <input id="cb" type="checkbox" />
            </body>
          </html>
        ''',
      );

      final cb = prepared.getElementById('cb') as dynamic;
      expect(cb.getChecked(), isFalse);

      cb.setAttribute('checked', '');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));
      expect(cb.getChecked(), isTrue);

      cb.removeAttribute('checked');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));
      expect(cb.getChecked(), isFalse);
    });
  });
}

