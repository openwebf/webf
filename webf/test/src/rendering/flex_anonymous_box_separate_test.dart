/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'package:flutter_test/flutter_test.dart';
import 'package:webf/webf.dart';
import 'package:webf/dom.dart' as dom;
import 'package:webf/css.dart';
import 'package:webf/rendering.dart';
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

  group('Flex Anonymous Box Separation', () {
    testWidgets('should create separate anonymous boxes for non-contiguous text', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'flex-separate-anonymous-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <html>
            <body style="margin: 0; padding: 0;">
              <div id="container" style="display: flex;">
                (this is text)
                <span>A span</span>
                More text
              </div>
            </body>
          </html>
        ''',
      );

      await tester.pump();

      final container = prepared.getElementById('container');
      expect(container.renderStyle.display, equals(CSSDisplay.flex));
      
      // Check the DOM children
      final childNodes = container.childNodes;
      print('DOM children count: ${childNodes.length}');
      
      int i = 0;
      for (var node in childNodes) {
        if (node is dom.TextNode) {
          print('Child $i: TextNode with data: "${node.data}"');
        } else if (node is dom.Element) {
          print('Child $i: Element <${node.tagName}>');
        }
        i++;
      }
      
      // Get the render object to check flex items
      final renderer = container.attachedRenderer as RenderFlexLayout;
      print('Flex renderer child count: ${renderer.childCount}');
      
      // Should have 3 flex items:
      // 1. Anonymous box for "(this is text)"
      // 2. The span element
      // 3. Anonymous box for "More text"
      expect(renderer.childCount, equals(3), reason: 'Should have 3 flex items');
    });

    testWidgets('should handle mixed inline elements correctly', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'flex-mixed-inline-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <html>
            <body style="margin: 0; padding: 0;">
              <div id="container" style="display: flex;">
                Text before
                <span style="background: red;">Inline span</span>
                <div style="background: blue;">Block div</div>
                Text after
              </div>
            </body>
          </html>
        ''',
      );

      await tester.pump();

      final container = prepared.getElementById('container');
      final renderer = container.attachedRenderer as RenderFlexLayout;
      
      // Should have 4 flex items:
      // 1. Anonymous box for "Text before"
      // 2. The span element (direct flex item)
      // 3. The div element (direct flex item)
      // 4. Anonymous box for "Text after"
      expect(renderer.childCount, equals(4), reason: 'Should have 4 flex items');
    });

    testWidgets('inline-flex should also create separate anonymous boxes', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'inline-flex-separate-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <html>
            <body style="margin: 0; padding: 0;">
              <span id="container" style="display: inline-flex;">
                First text
                <span>Middle span</span>
                Last text
              </span>
            </body>
          </html>
        ''',
      );

      await tester.pump();

      final container = prepared.getElementById('container');
      expect(container.renderStyle.display, equals(CSSDisplay.inlineFlex));
      
      final renderer = container.attachedRenderer as RenderFlexLayout;
      
      // Should have 3 flex items
      expect(renderer.childCount, equals(3), reason: 'Should have 3 flex items in inline-flex');
    });
  });
}