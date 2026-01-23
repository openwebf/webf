/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/rendering.dart';
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

  group('Flex align-items center with padding', () {
    testWidgets('centers items within content box when free space is 0', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'flex-align-center-padding-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <html>
            <body style="margin: 0; padding: 0;">
              <div
                id="container"
                style="display: flex; align-items: center; justify-content: center; border: 1px solid #000; padding-top: 16px; padding-bottom: 40px;"
              ><span id="left" style="display: inline-block; width: 40px; height: 1px; border: 1px solid #000;"></span><div id="middle" style="padding: 0 16px; font-size: 16px; line-height: 24px;">aaa</div><span id="right" style="display: inline-block; width: 40px; height: 1px; border: 1px solid #000;"></span></div>
            </body>
          </html>
        ''',
      );

      await tester.pump();

      final container = prepared.getElementById('container');
      final RenderFlexLayout flex = container.attachedRenderer as RenderFlexLayout;
      expect(flex.childCount, equals(3));

      final RenderBox child1 = flex.firstChild!;
      final RenderLayoutParentData child1ParentData = child1.parentData as RenderLayoutParentData;
      final RenderBox child2 = child1ParentData.nextSibling!;
      final RenderLayoutParentData child2ParentData = child2.parentData as RenderLayoutParentData;
      final RenderBox child3 = child2ParentData.nextSibling!;

      double centerY(RenderBox child) {
        final RenderLayoutParentData parentData = child.parentData as RenderLayoutParentData;
        return parentData.offset.dy + child.size.height / 2.0;
      }

      // All three items should share the same cross-axis center, regardless of container padding.
      expect(centerY(child1), moreOrLessEquals(centerY(child2), epsilon: 0.5));
      expect(centerY(child3), moreOrLessEquals(centerY(child2), epsilon: 0.5));
    });
  });
}
