/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'package:flutter_test/flutter_test.dart';
import 'package:webf/dom.dart' as dom;
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

  group('logical padding with direction inheritance', () {
    testWidgets('paddingInlineStart remaps when direction changes to RTL', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'logical-padding-rtl-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <html>
            <head>
              <style>
                body { margin: 0; padding: 0; }
                #wrapper { width: 160px; }
                ol { margin: 0; }
              </style>
            </head>
            <body>
              <div id="wrapper">
                <ol id="list" style="list-style-type: lower-alpha;">
                  <li>البند الأول</li>
                </ol>
              </div>
            </body>
          </html>
        ''',
      );

      // Apply direction after OL exists so UA defaults were applied under LTR,
      // then set paddingInlineStart under RTL. This used to leave a stale
      // LTR-side padding, shrinking content width.
      final dom.Element wrapper = prepared.getElementById('wrapper');
      final dom.Element list = prepared.getElementById('list');

      wrapper.style.setProperty('direction', 'rtl');
      list.style.setProperty('paddingInlineStart', '20px');

      wrapper.style.flushPendingProperties();
      list.style.flushPendingProperties();

      await tester.pump(const Duration(milliseconds: 50));

      expect(list.renderStyle.paddingLeft.computedValue, 0.0);
      expect(list.renderStyle.paddingRight.computedValue, 20.0);
      expect(list.renderStyle.contentBoxLogicalWidth, 140.0);
    });
  });
}
