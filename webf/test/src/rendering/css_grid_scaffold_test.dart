/*
 * Copyright (C) 2025-present The WebF authors. All rights reserved.
 */

import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:webf/css.dart';
import 'package:webf/rendering.dart';
import 'package:webf/foundation.dart';
import '../widget/test_utils.dart';
import '../../setup.dart';

void main() {
  setUpAll(() {
    setupTest();
  });

  group('CSS Grid scaffold', () {
    testWidgets('display:grid creates RenderGridLayout', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'grid-scaffold-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <div id="grid" style="display: grid; width: 200px; height: 100px;">
            <div id="item1">A</div>
            <div id="item2">B</div>
          </div>
        ''',
      );

      await tester.pump();

      final grid = prepared.getElementById('grid');
      expect(grid.renderStyle.display, equals(CSSDisplay.grid));
      expect(grid.attachedRenderer, isA<RenderGridLayout>());
    });

    testWidgets('gap marks grid container for layout', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'grid-gap-invalidation-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <div id="grid" style="display: grid; width: 120px;">
            <div style="height: 20px;">1</div>
            <div style="height: 20px;">2</div>
          </div>
        ''',
      );

      await tester.pump();
      final grid = prepared.getElementById('grid');
      final renderer = grid.attachedRenderer as RenderGridLayout;
      final beforeSize = renderer.size;

      // Update gap via inline style and ensure no exceptions; size may change after layout
      grid.style.setProperty('gap', '10px');
      await tester.pump();
      await tester.pump();

      // Renderer should still be attached and have a size computed
      expect(grid.attachedRenderer, isA<RenderGridLayout>());
      expect((grid.attachedRenderer as RenderGridLayout).hasSize, isTrue);
      // Size validity: width remains the same (120px + padding/border), height not zero.
      final afterSize = (grid.attachedRenderer as RenderGridLayout).size;
      expect(afterSize.width, equals(beforeSize.width));
      expect(afterSize.height, greaterThan(0));
    });

    testWidgets('parent data tracks resolved placement', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'grid-parent-data-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <div id="grid" style="display: grid; width: 200px; grid-template-columns: 100px 100px;">
            <div id="item-a">A</div>
            <div id="item-b">B</div>
            <div id="item-c">C</div>
            <div id="item-d" style="grid-column: span 2;">D</div>
          </div>
        ''',
      );

      await tester.pump();

      final grid = prepared.getElementById('grid');
      GridLayoutParentData parentDataFor(String id) {
        RenderObject? renderer = prepared.getElementById(id).attachedRenderer;
        expect(renderer, isNotNull);
        while (renderer != null && renderer.parent != grid.attachedRenderer) {
          renderer = renderer.parent as RenderObject?;
        }
        expect(renderer, isA<RenderBox>());
        return (renderer as RenderBox).parentData as GridLayoutParentData;
      }

      expect(parentDataFor('item-a').rowStart, equals(0));
      expect(parentDataFor('item-a').columnStart, equals(0));
      expect(parentDataFor('item-b').rowStart, equals(0));
      expect(parentDataFor('item-b').columnStart, equals(1));
      expect(parentDataFor('item-c').rowStart, equals(1));
      expect(parentDataFor('item-c').columnStart, equals(0));
      expect(parentDataFor('item-d').rowStart, greaterThanOrEqualTo(1));
      expect(parentDataFor('item-d').columnSpan, equals(2));
    });

    testWidgets('grid feature flag falls back to flow layout when disabled', (WidgetTester tester) async {
      // Disable grid layout feature and ensure display:grid uses flow layout instead.
      DebugFlags.enableCssGridLayout = false;
      addTearDown(() {
        DebugFlags.enableCssGridLayout = true;
      });

      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'grid-flag-fallback-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <div id="grid" style="display: grid; width: 200px; height: 100px;">
            <div id="item1">A</div>
            <div id="item2">B</div>
          </div>
        ''',
      );

      await tester.pump();

      final grid = prepared.getElementById('grid');
      expect(grid.renderStyle.display, equals(CSSDisplay.grid));
      expect(grid.attachedRenderer, isA<RenderFlowLayout>());
    });
  });
}
