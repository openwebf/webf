/*
 * Copyright (C) 2025-present The WebF authors. All rights reserved.
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

  group('CSS Flex Order', () {
    testWidgets('should reorder flex items by order property', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'flex-order-basic-test-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <html>
            <body style="margin: 0; padding: 0;">
              <div id="container" style="display: flex; width: 200px; height: 50px;">
                <div id="item1" style="width: 50px; height: 50px; order: 2; background: red;"></div>
                <div id="item2" style="width: 50px; height: 50px; order: 1; background: green;"></div>
                <div id="item3" style="width: 50px; height: 50px; order: 3; background: blue;"></div>
              </div>
            </body>
          </html>
        ''',
      );

      final item1 = prepared.getElementById('item1');
      final item2 = prepared.getElementById('item2');
      final item3 = prepared.getElementById('item3');

      await tester.pump();

      // item2 (order:1) should be first, then item1 (order:2), then item3 (order:3).
      expect(item2.offsetLeft, 0);
      expect(item1.offsetLeft, 50);
      expect(item3.offsetLeft, 100);
    });

    testWidgets('should keep stable order for same order values', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'flex-order-stable-test-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <html>
            <body style="margin: 0; padding: 0;">
              <div id="container" style="display: flex; width: 200px; height: 50px;">
                <div id="item1" style="width: 50px; height: 50px; order: 1; background: red;"></div>
                <div id="item2" style="width: 50px; height: 50px; order: 1; background: green;"></div>
                <div id="item3" style="width: 50px; height: 50px; order: 0; background: blue;"></div>
              </div>
            </body>
          </html>
        ''',
      );

      final item1 = prepared.getElementById('item1');
      final item2 = prepared.getElementById('item2');
      final item3 = prepared.getElementById('item3');

      await tester.pump();

      // item3 (order:0) comes first; item1 and item2 share the same order and
      // should keep DOM order (stable sort): item1 before item2.
      expect(item3.offsetLeft, 0);
      expect(item1.offsetLeft, 50);
      expect(item2.offsetLeft, 100);
    });
  });
}

