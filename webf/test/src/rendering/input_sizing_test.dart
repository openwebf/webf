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

  group('Input Sizing', () {
    testWidgets('input `size` attribute affects intrinsic width', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'input-size-attr-test-${DateTime.now().millisecondsSinceEpoch}',
        viewportWidth: 1000,
        wrap: (child) => MaterialApp(home: Scaffold(body: child)),
        html: '''
          <html>
            <body style="margin: 0; padding: 0; font-size: 16px;">
              <input id="small" size="10" />
              <input id="large" size="40" />
            </body>
          </html>
        ''',
      );

      final small = prepared.getElementById('small');
      final large = prepared.getElementById('large');

      expect(large.offsetWidth, greaterThan(small.offsetWidth * 2));
    });

    testWidgets('flexed input expands in main axis', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'input-flex-grow-test-${DateTime.now().millisecondsSinceEpoch}',
        wrap: (child) => MaterialApp(home: Scaffold(body: child)),
        html: '''
          <html>
            <body style="margin: 0; padding: 0;">
              <div style="display: flex; width: 300px;">
                <input id="in" style="flex: 1 1 0%; min-width: 0;" />
              </div>
            </body>
          </html>
        ''',
      );

      final input = prepared.getElementById('in');
      expect(input.offsetWidth, closeTo(300.0, 0.5));
    });
  });
}
