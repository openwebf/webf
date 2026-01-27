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

  group('Input Direction', () {
    testWidgets('text input inherits RTL direction', (WidgetTester tester) async {
      await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'input-direction-rtl-test-${DateTime.now().millisecondsSinceEpoch}',
        wrap: (child) => MaterialApp(home: Scaffold(body: SizedBox.expand(child: child))),
        html: '''
          <html>
            <body style="margin: 0; padding: 0;">
              <div style="direction: rtl;">
                <input id="i" type="text" placeholder="أدخل اسمك" />
              </div>
            </body>
          </html>
        ''',
      );

      final Finder input = find.byType(TextField);
      expect(input, findsOneWidget);
      expect(tester.widget<TextField>(input).textDirection, TextDirection.rtl);
    });
  });
}
