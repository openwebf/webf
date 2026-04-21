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

  testWidgets('select label does not overflow when constrained by parent width',
      (WidgetTester tester) async {
    await WebFWidgetTestUtils.prepareWidgetTest(
      tester: tester,
      controllerName:
          'select-layout-test-${DateTime.now().millisecondsSinceEpoch}',
      wrap: (child) =>
          MaterialApp(home: Scaffold(body: SizedBox.expand(child: child))),
      html: '''
        <html>
          <body style="margin: 0; padding: 0;">
            <div style="width: 64px;">
              <select id="compact-select" style="width: 100%;">
                <option selected>Very long option label for narrow width</option>
              </select>
            </div>
          </body>
        </html>
      ''',
    );

    expect(tester.takeException(), isNull);
  });
}
