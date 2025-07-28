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
      
      // Natural font metrics should be used (no forced multiplier)
      expect(height1, lessThan(20.0),
        reason: 'Natural font metrics should be close to font size');
      expect(height3, lessThan(20.0),
        reason: 'Serif natural font metrics should be close to font size');
      
      // Line-height should still work correctly
      expect(height2, equals(32.0),
        reason: 'line-height: 2 should make the line box 32px (16px * 2)');
      expect(height4, equals(32.0),
        reason: 'Serif with line-height: 2 should also be 32px');
      
      // Line-height should override natural font metrics
      expect(height2, greaterThan(height1 * 1.8),
        reason: 'line-height: 2 should be significantly larger than natural metrics');
    });

    testWidgets('line-height respects minimum font metrics', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'min-metrics-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <div id="test1" style="font-size: 20px; line-height: 0.5;">Small line-height</div>
          <div id="test2" style="font-size: 20px; line-height: 1;">Normal line-height</div>
          <div id="test3" style="font-size: 20px; line-height: normal;">Natural line-height</div>
        ''',
      );
      await tester.pump();

      final div1 = prepared.controller.view.document.querySelector(['#test1']) as dom.Element;
      final div2 = prepared.controller.view.document.querySelector(['#test2']) as dom.Element;
      final div3 = prepared.controller.view.document.querySelector(['#test3']) as dom.Element;
      
      final height1 = (div1.attachedRenderer as RenderBox).size.height;
      final height2 = (div2.attachedRenderer as RenderBox).size.height;
      final height3 = (div3.attachedRenderer as RenderBox).size.height;
      
      print('line-height: 0.5 (20px font): $height1');
      print('line-height: 1 (20px font): $height2');
      print('line-height: normal (20px font): $height3');
      
      // Even with small line-height, should respect font metrics minimum
      expect(height1, greaterThanOrEqualTo(10.0),
        reason: 'line-height: 0.5 should be at least 10px (20px * 0.5)');
      
      // line-height: 1 should equal font size
      expect(height2, equals(20.0),
        reason: 'line-height: 1 should equal font size');
      
      // Natural line-height should use font metrics
      expect(height3, greaterThan(18.0),
        reason: 'Natural line-height should use font metrics');
      expect(height3, lessThan(25.0),
        reason: 'Natural line-height should be reasonable');
    });

    testWidgets('text from integration test should render correctly', (WidgetTester tester) async {
      // This is the test case from the integration test that was failing
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'integration-case-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <div class="color-test">
            <p style="color: red; border: 2px solid currentColor;">
              Text with currentColor border
            </p>
          </div>
        ''',
      );
      await tester.pump();

      final p = prepared.controller.view.document.querySelector(['p']) as dom.Element;
      final renderBox = p.attachedRenderer as RenderBoxModel;
      
      final height = renderBox.contentSize.height;
      print('P element content height: $height');
      
      // Height should use natural font metrics
      expect(height, greaterThan(14.0),
        reason: 'P element should have reasonable height');
      expect(height, lessThan(25.0),
        reason: 'P element should not have excessive height');
      
      // Verify currentColor is working
      final borderColor = renderBox.renderStyle.borderTopColor?.value;
      final textColor = renderBox.renderStyle.color.value;
      expect(borderColor, equals(textColor),
        reason: 'Border should use currentColor which matches text color');
    });
  });
}