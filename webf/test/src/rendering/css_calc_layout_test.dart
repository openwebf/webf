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

    testWidgets('does not collapse calc(100% - 24px) inside shrink-to-fit flex item', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'calc-flex-shrink-to-fit-test-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <html>
            <body style="margin: 0;">
              <div id="right" style="width: 200px; display: flex; justify-content: flex-end; overflow: hidden;">
                <div id="inner" style="display: flex; align-items: flex-start; overflow: hidden;">
                  <div id="text" style="width: calc(100% - 24px); overflow: hidden; text-align: right;">Hello</div>
                  <div id="icon" style="width: 24px; height: 20px; background: red;"></div>
                </div>
              </div>
            </body>
          </html>
        ''',
      );

      final right = prepared.getElementById('right');
      final inner = prepared.getElementById('inner');
      final text = prepared.getElementById('text');
      final icon = prepared.getElementById('icon');

      expect(right.offsetWidth, equals(200.0));
      expect(icon.offsetWidth, equals(24.0));

      // If percentage-in-calc is resolved against an auto-sized (shrink-to-fit) flex item
      // during intrinsic sizing, it can collapse to 0 (inner becomes icon-only).
      expect(text.offsetWidth, greaterThan(0.0));
      expect(inner.offsetWidth, greaterThan(icon.offsetWidth));
    });
  });
}
