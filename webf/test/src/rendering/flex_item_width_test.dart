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

  group('Flex Item Width', () {
    testWidgets('block elements in flex container should not stretch to parent width', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'flex-item-width-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <html>
            <body style="margin: 0; padding: 0;">
              <div id="container" style="display: flex; width: 600px; background: #f0f0f0;">
                <div id="item1" style="background: red;">This is text</div>
                <div id="item2" style="background: green;">A span</div>
                <div id="item3" style="background: blue;">More text</div>
              </div>
            </body>
          </html>
        ''',
      );

      await tester.pump();

      final container = prepared.getElementById('container');
      final item1 = prepared.getElementById('item1');
      final item2 = prepared.getElementById('item2');
      final item3 = prepared.getElementById('item3');
      
      // Container should be 600px wide
      expect(container.offsetWidth, equals(600));
      
      // Items should size to their content, not stretch to 600px
      expect(item1.offsetWidth, lessThan(600));
      expect(item2.offsetWidth, lessThan(600));
      expect(item3.offsetWidth, lessThan(600));
      
      // Items should have different widths based on their content
      expect(item1.offsetWidth, isNot(equals(item2.offsetWidth)));
      expect(item2.offsetWidth, isNot(equals(item3.offsetWidth)));
      
      // Debug output
      print('Container width: ${container.offsetWidth}');
      print('Item 1 width: ${item1.offsetWidth}');
      print('Item 2 width: ${item2.offsetWidth}');
      print('Item 3 width: ${item3.offsetWidth}');
    });

    testWidgets('block elements with explicit width should respect it', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'flex-item-explicit-width-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <html>
            <body style="margin: 0; padding: 0;">
              <div id="container" style="display: flex; width: 600px;">
                <div id="item1" style="width: 100px; background: red;">This is text</div>
                <div id="item2" style="background: green;">A span</div>
              </div>
            </body>
          </html>
        ''',
      );

      await tester.pump();

      final item1 = prepared.getElementById('item1');
      final item2 = prepared.getElementById('item2');
      
      // Item with explicit width should be 100px
      expect(item1.offsetWidth, equals(100));
      
      // Item without width should size to content
      expect(item2.offsetWidth, lessThan(600));
      expect(item2.offsetWidth, isNot(equals(100)));
    });

    testWidgets('flex-grow should expand items', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'flex-grow-test-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <html>
            <body style="margin: 0; padding: 0;">
              <div id="container" style="display: flex; width: 600px;">
                <div id="item1" style="flex-grow: 1; background: red;">Item 1</div>
                <div id="item2" style="background: green;">Item 2</div>
              </div>
            </body>
          </html>
        ''',
      );

      await tester.pump();

      final container = prepared.getElementById('container');
      final item1 = prepared.getElementById('item1');
      final item2 = prepared.getElementById('item2');
      
      // Item 2 should size to content
      final item2ContentWidth = item2.offsetWidth;
      
      // Item 1 with flex-grow should take remaining space
      expect(item1.offsetWidth, equals(600 - item2ContentWidth));
      
      // Total should equal container width
      expect(item1.offsetWidth + item2.offsetWidth, equals(600));
    });
  });
}