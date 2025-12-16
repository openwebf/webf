/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/rendering.dart';
import 'package:webf/webf.dart';
import 'package:webf/dom.dart' as dom;
import '../../setup.dart';
import '../widget/test_utils.dart';
import 'style_test_utils.dart';

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

  group('Text Overflow', () {
    testWidgets('should apply text-overflow: ellipsis with nowrap', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'text-overflow-ellipsis-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <div style="width: 100px; overflow: hidden; white-space: nowrap; text-overflow: ellipsis;">
            This is a very long text that should be truncated with ellipsis
          </div>
        ''',
      );

      final controller = prepared.controller;
      await tester.pump();

      final div = controller.view.document.querySelector(['div']) as dom.Element;
      expect(div.renderStyle.textOverflow, equals(TextOverflow.ellipsis));
      expect(div.renderStyle.effectiveTextOverflow, equals(TextOverflow.ellipsis));
    });

    testWidgets('should not apply ellipsis when overflow is visible', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'text-overflow-visible-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <div style="width: 100px; overflow: visible; white-space: nowrap; text-overflow: ellipsis;">
            This is a very long text that should not be truncated
          </div>
        ''',
      );

      final controller = prepared.controller;
      await tester.pump();

      final div = controller.view.document.querySelector(['div']) as dom.Element;
      expect(div.renderStyle.textOverflow, equals(TextOverflow.ellipsis));
      expect(div.renderStyle.effectiveTextOverflow, equals(TextOverflow.visible));
    });

    testWidgets('should apply line-clamp', skip: true, (WidgetTester tester) async {
      // TODO: WebF doesn't fully support -webkit-line-clamp parsing yet
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'line-clamp-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <div style="width: 200px; -webkit-line-clamp: 2; display: -webkit-box; -webkit-box-orient: vertical; overflow: hidden;">
            This is a very long text that spans multiple lines and should be clamped to only show two lines with ellipsis at the end of the second line
          </div>
        ''',
      );

      final controller = prepared.controller;
      await tester.pump();

      final div = controller.view.document.querySelector(['div']) as dom.Element;
      expect(div.renderStyle.lineClamp, equals(2));
      expect(div.renderStyle.effectiveTextOverflow, equals(TextOverflow.ellipsis));
    });

    testWidgets('should handle text-overflow with inline elements', skip: true, (WidgetTester tester) async {
      // TODO: Text overflow with inline formatting context needs implementation
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'text-overflow-inline-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <div style="width: 150px; overflow: hidden; white-space: nowrap; text-overflow: ellipsis;">
            <span>This is</span> <strong>a very long</strong> <em>text with inline elements</em>
          </div>
        ''',
      );

      final controller = prepared.controller;
      await tester.pump();

      final div = controller.view.document.querySelector(['div']) as dom.Element;
      expect(div.renderStyle.effectiveTextOverflow, equals(TextOverflow.ellipsis));
    });

    testWidgets('should update text-overflow dynamically', skip: true, (WidgetTester tester) async {
      // TODO: Text-overflow property updates are not being propagated to render style
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'text-overflow-dynamic-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <div id="test" style="width: 100px; overflow: hidden; white-space: nowrap;">
            This is a very long text
          </div>
        ''',
      );

      final controller = prepared.controller;
      await tester.pump();

      final div = controller.view.document.querySelector(['div']) as dom.Element;
      expect(div.renderStyle.effectiveTextOverflow, equals(TextOverflow.clip));

      // Change to ellipsis
      StyleTestUtils.setStyleProperty(div, 'text-overflow', 'ellipsis');
      await tester.pump();

      expect(div.renderStyle.textOverflow, equals(TextOverflow.ellipsis));
      expect(div.renderStyle.effectiveTextOverflow, equals(TextOverflow.ellipsis));
    });
  });
}