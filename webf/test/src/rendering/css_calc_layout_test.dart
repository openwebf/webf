/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

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
    await Future.delayed(Duration(milliseconds: 100));
  });

  group('CSS calc() mixed units', () {
    testWidgets('resolves calc((100% - 20px) / 3) against container width', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'calc-percent-minus-test-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <html>
            <body style="margin: 0;">
              <div id="container" style="width: 300px; background: blue; padding: 0; border: 0;">
                <div id="t1" style="height: 20px; width: calc((100% - 20px) / 3);"></div>
                <div id="t2" style="height: 20px; width: calc(80px / 3);"></div>
              </div>
            </body>
          </html>
        ''',
      );

      final container = prepared.getElementById('container');
      final t1 = prepared.getElementById('t1');
      final t2 = prepared.getElementById('t2');

      expect(container.offsetWidth, equals(300.0));

      const double expected = (300.0 - 20.0) / 3.0;
      expect(t1.offsetWidth, closeTo(expected, 0.01));
      expect(t1.getBoundingClientRect().width, closeTo(expected, 0.01));

      expect(t2.offsetWidth, closeTo(80.0 / 3.0, 0.01));
    });
  });
}
