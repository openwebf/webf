import 'package:flutter/rendering.dart';
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
    // Clean up any controllers from previous tests
    WebFControllerManager.instance.disposeAll();
    // Add a small delay to ensure file locks are released
    await Future.delayed(Duration(milliseconds: 100));
  });

  group('Font metrics and line-height combined', () {
    testWidgets('fonts should use natural metrics and line-height should still work', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'combined-test-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <div id="test1" style="font-size: 16px;">Natural font metrics</div>
          <div id="test2" style="font-size: 16px; line-height: 2;">With line-height: 2</div>
          <div id="test3" style="font-size: 16px; font-family: serif;">Serif font natural metrics</div>
          <div id="test4" style="font-size: 16px; font-family: serif; line-height: 2;">Serif with line-height: 2</div>
        ''',
      );
      await tester.pump();

      final div1 = prepared.controller.view.document.querySelector(['#test1']) as dom.Element;
      final div2 = prepared.controller.view.document.querySelector(['#test2']) as dom.Element;
      final div3 = prepared.controller.view.document.querySelector(['#test3']) as dom.Element;
      final div4 = prepared.controller.view.document.querySelector(['#test4']) as dom.Element;

      final height1 = (div1.attachedRenderer as RenderBox).size.height;
      final height2 = (div2.attachedRenderer as RenderBox).size.height;
      final height3 = (div3.attachedRenderer as RenderBox).size.height;
      final height4 = (div4.attachedRenderer as RenderBox).size.height;

      print('Default font natural height: $height1');
      print('Default font with line-height 2: $height2');
      print('Serif font natural height: $height3');
      print('Serif font with line-height 2: $height4');

      // Natural font metrics should be used (no forced multiplier) for default font.
      expect(height1, lessThan(20.0),
        reason: 'Natural font metrics (default font) should be close to font size');
      // Different fallback serif fonts can report different natural metrics across platforms.
      // Instead of asserting an absolute pixel, validate that explicit line-height scales it predictably.
      expect(height3, greaterThan(0), reason: 'Serif natural height should be positive');

      // Line-height should still work correctly: doubles the line box relative to each font's natural metrics.
      expect(height2, equals(height1 * 2),
        reason: 'line-height: 2 should double the default font line box');
      expect(height4, equals(height3 * 2),
        reason: 'line-height: 2 should double the serif font line box');

      // Line-height should override natural font metrics
      expect(height2, greaterThan(height1 * 1.8),
        reason: 'line-height: 2 should be significantly larger than natural metrics');
    });
  });
}
