/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/rendering.dart';
import 'package:webf/webf.dart';
import 'package:webf/foundation.dart';
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

  group('Baseline Alignment', () {
    testWidgets('should align replaced elements by baseline', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'baseline-replaced-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <div style="font-size: 20px;">
            Text before 
            <img src="data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iNTAiIGhlaWdodD0iNTAiIHhtbG5zPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2ZyI+PHJlY3Qgd2lkdGg9IjUwIiBoZWlnaHQ9IjUwIiBmaWxsPSJyZWQiLz48L3N2Zz4=" 
                 style="width: 50px; height: 50px; vertical-align: baseline;" />
            text after
          </div>
        ''',
      );

      final controller = prepared.controller;
      await tester.pump();
      // Wait for image to load
      await tester.pump(Duration(seconds: 1));

      final div = controller.view.document.querySelector(['div']) as dom.Element;
      final img = controller.view.document.querySelector(['img']) as dom.Element;
      
      expect(img.renderStyle.verticalAlign, equals(VerticalAlign.baseline));
      
      // The image bottom should align with text baseline
      // TODO: Verify actual baseline alignment once implemented
    });

    testWidgets('should support vertical-align: middle', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'vertical-align-middle-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <div style="font-size: 20px;">
            Text <img src="data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMzAiIGhlaWdodD0iMzAiIHhtbG5zPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2ZyI+PHJlY3Qgd2lkdGg9IjMwIiBoZWlnaHQ9IjMwIiBmaWxsPSJibHVlIi8+PC9zdmc+" 
                   style="width: 30px; height: 30px; vertical-align: middle;" /> middle
          </div>
        ''',
      );

      final controller = prepared.controller;
      await tester.pump();
      await tester.pump(Duration(seconds: 1));

      final img = controller.view.document.querySelector(['img']) as dom.Element;
      expect(img.renderStyle.verticalAlign, equals(VerticalAlign.middle));
    });

    testWidgets('should support vertical-align: top', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'vertical-align-top-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <div style="font-size: 20px;">
            Text <img src="data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMzAiIGhlaWdodD0iMzAiIHhtbG5zPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2ZyI+PHJlY3Qgd2lkdGg9IjMwIiBoZWlnaHQ9IjMwIiBmaWxsPSJncmVlbiIvPjwvc3ZnPg==" 
                   style="width: 30px; height: 30px; vertical-align: top;" /> top
          </div>
        ''',
      );

      final controller = prepared.controller;
      await tester.pump();
      await tester.pump(Duration(seconds: 1));

      final img = controller.view.document.querySelector(['img']) as dom.Element;
      expect(img.renderStyle.verticalAlign, equals(VerticalAlign.top));
    });

    testWidgets('should support vertical-align: bottom', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'vertical-align-bottom-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <div style="font-size: 20px;">
            Text <img src="data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMzAiIGhlaWdodD0iMzAiIHhtbG5zPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2ZyI+PHJlY3Qgd2lkdGg9IjMwIiBoZWlnaHQ9IjMwIiBmaWxsPSJ5ZWxsb3ciLz48L3N2Zz4=" 
                   style="width: 30px; height: 30px; vertical-align: bottom;" /> bottom
          </div>
        ''',
      );

      final controller = prepared.controller;
      await tester.pump();
      await tester.pump(Duration(seconds: 1));

      final img = controller.view.document.querySelector(['img']) as dom.Element;
      expect(img.renderStyle.verticalAlign, equals(VerticalAlign.bottom));
    });

    testWidgets('should align inline-block elements', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'inline-block-baseline-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <div style="font-size: 20px;">
            Text before
            <span style="display: inline-block; width: 50px; height: 50px; background: purple; vertical-align: baseline;">
              <div style="margin-top: 20px;">A</div>
            </span>
            text after
          </div>
        ''',
      );

      final controller = prepared.controller;
      await tester.pump();

      final span = controller.view.document.querySelector(['span']) as dom.Element;
      expect(span.renderStyle.display, equals(CSSDisplay.inlineBlock));
      expect(span.renderStyle.verticalAlign, equals(VerticalAlign.baseline));
      
      // For inline-block, baseline should be the baseline of last line box
      // or bottom margin edge if no line boxes
      // TODO: Verify actual baseline alignment once implemented
    });
  });
}