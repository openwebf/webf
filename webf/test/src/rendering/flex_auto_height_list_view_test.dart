/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:webf/rendering.dart';
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

  group('Flex auto height in list view', () {
    testWidgets('does not expand to available max height', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'flex-auto-height-listview-${DateTime.now().millisecondsSinceEpoch}',
        wrap: (Widget child) => Directionality(textDirection: TextDirection.ltr, child: child),
        html: '''
          <html>
            <body style="margin: 0; padding: 0;">
              <webf-list-view shrink-wrap="true">
                <div
                  id="container"
                  style="display: flex; align-items: center; justify-content: center; padding-top: 16px; padding-bottom: 40px;"
                >
                  <span style="display: inline-block; width: 40px; height: 1px;"></span>
                  <div style="padding: 0 16px; font-size: 16px; line-height: 24px;">aaa</div>
                  <span style="display: inline-block; width: 40px; height: 1px;"></span>
                </div>
              </webf-list-view>
            </body>
          </html>
        ''',
      );

      await tester.pump();

      final container = prepared.getElementById('container');
      final RenderFlexLayout flex = container.attachedRenderer as RenderFlexLayout;

      // Auto-height flex containers should shrink-wrap their content, even when hosted in
      // widget wrappers like ListView items.
      //
      // Expected: border-box height equals vertical padding + max child height (single-line row).
      final double paddingV = flex.renderStyle.paddingTop.computedValue + flex.renderStyle.paddingBottom.computedValue;

      final RenderBox child1 = flex.firstChild!;
      final RenderLayoutParentData child1ParentData = child1.parentData as RenderLayoutParentData;
      final RenderBox child2 = child1ParentData.nextSibling!;
      final RenderLayoutParentData child2ParentData = child2.parentData as RenderLayoutParentData;
      final RenderBox child3 = child2ParentData.nextSibling!;

      final double maxChildH = [child1.size.height, child2.size.height, child3.size.height].reduce((a, b) => a > b ? a : b);
      expect(flex.size.height, moreOrLessEquals(paddingV + maxChildH, epsilon: 1.0));
    });
  });
}
