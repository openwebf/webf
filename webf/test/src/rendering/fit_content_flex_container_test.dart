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

  group('Intrinsic Sizing', () {
    testWidgets('width: fit-content on flex container sizes to children', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'fit-content-flex-container-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <html>
            <body style="margin: 0; padding: 0;">
              <div style="width: 300px;">
                <button id="btn"
                  style="
                    white-space: nowrap;
                    font-size: 14px;
                    min-height: 32px;
                    width: fit-content;
                    overflow: hidden;
                    padding: 5px 12px;
                    display: flex;
                    align-items: center;
                    justify-content: center;
                    border: 1px solid #000;
                  "
                >
                  <span id="text">限制限制</span>
                  <span id="icon" style="margin-left: 4px; display: inline-block; width: 16px; height: 16px; background: red;"></span>
                </button>
              </div>
            </body>
          </html>
        ''',
      );

      await tester.pump();

      final btn = prepared.getElementById('btn');
      final text = prepared.getElementById('text');
      final icon = prepared.getElementById('icon');

      final double expectedMin =
          text.offsetWidth + icon.offsetWidth + 4 /* margin-left */ + 24 /* padding-x */ + 2 /* border-x */;
      expect(btn.offsetWidth, greaterThanOrEqualTo(expectedMin - 1));
      expect(btn.offsetWidth, greaterThan(26));
    });
  });
}
