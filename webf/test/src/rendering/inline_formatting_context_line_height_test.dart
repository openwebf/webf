// ignore_for_file: avoid_print

import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:webf/webf.dart';
import 'package:webf/dom.dart' as dom;
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

  group('CSS line-height in inline formatting context', () {
    testWidgets('should apply line-height: 2 to increase line box height', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'line-height-2-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <div id="test1" style="font-size: 16px;">Normal line height text</div>
          <div id="test2" style="font-size: 16px; line-height: 2;">Double line height text</div>
        ''',
      );
      await tester.pump();

      final div1 = prepared.controller.view.document.querySelector(['#test1']) as dom.Element;
      final div2 = prepared.controller.view.document.querySelector(['#test2']) as dom.Element;
      
      final height1 = (div1.attachedRenderer as RenderBox).size.height;
      final height2 = (div2.attachedRenderer as RenderBox).size.height;
      
      print('Normal line-height box height: $height1');
      print('line-height: 2 box height: $height2');
      
      // With line-height: 2, the box should be twice as tall
      expect(height2, greaterThan(height1 * 1.8),
        reason: 'line-height: 2 should make the line box approximately twice as tall');
    });

    testWidgets('should apply line-height: 1.5 correctly', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'line-height-1.5-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <div id="test1" style="font-size: 20px;">Normal height</div>
          <div id="test2" style="font-size: 20px; line-height: 1.5;">1.5x height</div>
        ''',
      );
      await tester.pump();

      final div1 = prepared.controller.view.document.querySelector(['#test1']) as dom.Element;
      final div2 = prepared.controller.view.document.querySelector(['#test2']) as dom.Element;
      
      final height1 = (div1.attachedRenderer as RenderBox).size.height;
      final height2 = (div2.attachedRenderer as RenderBox).size.height;
      
      print('Normal line-height (20px font): $height1');
      print('line-height: 1.5 (20px font): $height2');
      
      // With line-height: 1.5, height should be approximately 1.5x the normal height
      expect(height2, greaterThan(height1 * 1.3),
        reason: 'line-height: 1.5 should increase the line box height');
    });

    testWidgets('should apply absolute line-height values', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'line-height-px-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <div id="test1" style="font-size: 14px; line-height: 30px;">30px line height</div>
          <div id="test2" style="font-size: 14px; line-height: 40px;">40px line height</div>
        ''',
      );
      await tester.pump();

      final div1 = prepared.controller.view.document.querySelector(['#test1']) as dom.Element;
      final div2 = prepared.controller.view.document.querySelector(['#test2']) as dom.Element;
      
      final height1 = (div1.attachedRenderer as RenderBox).size.height;
      final height2 = (div2.attachedRenderer as RenderBox).size.height;
      
      print('line-height: 30px box height: $height1');
      print('line-height: 40px box height: $height2');
      
      // Heights should match the specified line-height values
      expect(height1, equals(30.0),
        reason: 'line-height: 30px should make the line box exactly 30px tall');
      expect(height2, equals(40.0),
        reason: 'line-height: 40px should make the line box exactly 40px tall');
    });

    testWidgets('should apply percentage line-height values', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'line-height-percent-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <div id="test" style="font-size: 20px; line-height: 150%;">150% line height</div>
        ''',
      );
      await tester.pump();

      final div = prepared.controller.view.document.querySelector(['#test']) as dom.Element;
      final height = (div.attachedRenderer as RenderBox).size.height;
      
      print('line-height: 150% (20px font) box height: $height');
      
      // 150% of 20px = 30px
      expect(height, equals(30.0),
        reason: 'line-height: 150% with 20px font should result in 30px line box');
    });

    testWidgets('should apply em-based line-height values', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'line-height-em-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <div id="test" style="font-size: 16px; line-height: 1.5em;">1.5em line height</div>
        ''',
      );
      await tester.pump();

      final div = prepared.controller.view.document.querySelector(['#test']) as dom.Element;
      final height = (div.attachedRenderer as RenderBox).size.height;
      
      print('line-height: 1.5em (16px font) box height: $height');
      
      // 1.5em of 16px = 24px
      expect(height, equals(24.0),
        reason: 'line-height: 1.5em with 16px font should result in 24px line box');
    });

    testWidgets('line-height should affect multi-line text', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'line-height-multiline-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <div id="test" style="width: 100px; font-size: 16px; line-height: 2;">
            This is a long text that should wrap to multiple lines
          </div>
        ''',
      );
      await tester.pump();

      final div = prepared.controller.view.document.querySelector(['#test']) as dom.Element;
      final height = (div.attachedRenderer as RenderBox).size.height;
      
      print('Multi-line text with line-height: 2 box height: $height');
      
      // With line-height: 2 and 16px font, each line should be 32px
      // Multiple lines should show the cumulative effect
      expect(height, greaterThan(32.0),
        reason: 'Multi-line text should show cumulative line-height effect');
    });

    testWidgets('line-height: normal should use natural font metrics', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'line-height-normal-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <div id="test" style="font-size: 16px; line-height: normal;">Normal line height</div>
        ''',
      );
      await tester.pump();

      final div = prepared.controller.view.document.querySelector(['#test']) as dom.Element;
      final height = (div.attachedRenderer as RenderBox).size.height;
      
      print('line-height: normal (16px font) box height: $height');
      
      // With natural font metrics, height should be close to font size
      expect(height, greaterThan(14.0));
      expect(height, lessThan(20.0),
        reason: 'line-height: normal should use natural font metrics');
    });
  });
}
