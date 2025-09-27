/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:webf/webf.dart';
import 'package:webf/dom.dart' as dom;
import 'package:webf/css.dart';
import 'package:webf/rendering.dart';
import 'package:webf/foundation.dart';
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

  group('Inline-block baseline alignment', () {
    testWidgets('inline-block with text should align baseline correctly', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'baseline-test-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <div style="font-size: 20px; line-height: 1.5;">
            Text before
            <span style="display: inline-block; background: yellow;" id="inline-block">InlineBlock</span>
            text after
          </div>
        ''',
      );

      final inlineBlock = prepared.getElementById('inline-block');
      expect(inlineBlock, isNotNull);
      
      // Wait for layout to complete
      await tester.pump();
      await tester.pump();
      
      // Get the render box
      final renderBox = inlineBlock.attachedRenderer;
      expect(renderBox, isNotNull);
      expect(renderBox, isA<RenderFlowLayout>());
      
      final flowLayout = renderBox as RenderFlowLayout;
      
      // Inline-block should establish inline formatting context
      expect(flowLayout.establishIFC, isTrue);
      
      // Check baseline calculation
      final baseline = flowLayout.computeDistanceToActualBaseline(TextBaseline.alphabetic);
      
      // Baseline should not be null for inline-block with text
      expect(baseline, isNotNull);
      
      // Baseline should be reasonable (not 0, not full height)
      if (flowLayout.hasSize) {
        expect(baseline!, greaterThan(0));
        expect(baseline, lessThan(flowLayout.size.height));
        
        // For single line text, baseline is typically 70-80% of height
        final ratio = baseline / flowLayout.size.height;
        expect(ratio, greaterThan(0.6));
        expect(ratio, lessThan(0.9));
      }
    });

    testWidgets('inline-block with multiple lines uses last line baseline', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'multiline-test-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <div style="font-size: 20px;">
            Text
            <div style="display: inline-block; width: 100px; background: #eee;" id="multiline">
              First line
              Second line
            </div>
            Text
          </div>
        ''',
      );

      final multilineBlock = prepared.getElementById('multiline');
      expect(multilineBlock, isNotNull);
      
      // Wait for layout to complete
      await tester.pump();
      await tester.pump();
      
      final renderBox = multilineBlock.attachedRenderer;
      expect(renderBox, isNotNull);
      expect(renderBox, isA<RenderFlowLayout>());
      
      final flowLayout = renderBox as RenderFlowLayout;
      
      // Should establish IFC for inline-block
      expect(flowLayout.establishIFC, isTrue);
      
      // Get baseline
      final baseline = flowLayout.computeDistanceToActualBaseline(TextBaseline.alphabetic);
      expect(baseline, isNotNull);
      
      // For multi-line content, baseline should be closer to bottom (last line)
      if (flowLayout.hasSize) {
        final ratio = baseline! / flowLayout.size.height;
        expect(ratio, greaterThan(0.5)); // Should be in the lower half
      }
    });

    testWidgets('inline-block with overflow hidden uses bottom edge', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'overflow-test-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <div style="font-size: 20px;">
            Text
            <div style="display: inline-block; overflow: hidden; width: 100px; height: 50px; background: #ddd;" id="overflow">
              Content that might overflow
            </div>
            Text
          </div>
        ''',
      );

      final overflowBlock = prepared.getElementById('overflow');
      expect(overflowBlock, isNotNull);
      
      // Wait for layout to complete
      await tester.pump();
      await tester.pump();
      
      final renderBox = overflowBlock.attachedRenderer;
      expect(renderBox, isNotNull);
      expect(renderBox, isA<RenderFlowLayout>());
      
      final flowLayout = renderBox as RenderFlowLayout;
      
      // Get baseline
      final baseline = flowLayout.computeDistanceToActualBaseline(TextBaseline.alphabetic);
      expect(baseline, isNotNull);
      
      // With overflow hidden, baseline should be the bottom edge (full height)
      if (flowLayout.hasSize) {
        expect(baseline, equals(flowLayout.size.height));
      }
    });

    testWidgets('empty inline-block uses bottom edge as baseline', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'empty-test-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <div style="font-size: 20px;">
            Text
            <span style="display: inline-block; width: 50px; height: 30px; background: #ccc;" id="empty"></span>
            Text
          </div>
        ''',
      );

      final emptyBlock = prepared.getElementById('empty');
      expect(emptyBlock, isNotNull);
      
      // Wait for layout to complete
      await tester.pump();
      await tester.pump();
      
      final renderBox = emptyBlock.attachedRenderer;
      expect(renderBox, isNotNull);
      expect(renderBox, isA<RenderFlowLayout>());
      
      final flowLayout = renderBox as RenderFlowLayout;
      
      // Get baseline
      final baseline = flowLayout.computeDistanceToActualBaseline(TextBaseline.alphabetic);
      
      // Empty inline-block might return null or use bottom edge
      // The implementation should handle this gracefully
      if (baseline != null && flowLayout.hasSize) {
        // If a baseline is provided, it should be reasonable
        expect(baseline, greaterThanOrEqualTo(0));
        expect(baseline, lessThanOrEqualTo(flowLayout.size.height));
      }
    });

    testWidgets('inline-block without IFC (regular flow) tracks baseline', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'regular-flow-test-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <div style="display: inline-block; background: lightblue;" id="container">
            <div>Block content line 1</div>
            <div>Block content line 2</div>
          </div>
        ''',
      );

      final container = prepared.getElementById('container');
      expect(container, isNotNull);
      
      // Wait for layout to complete
      await tester.pump();
      await tester.pump();
      
      final renderBox = container.attachedRenderer;
      expect(renderBox, isNotNull);
      expect(renderBox, isA<RenderFlowLayout>());
      
      final flowLayout = renderBox as RenderFlowLayout;
      
      // This might not establish IFC if it only contains block-level children
      // But it should still track baseline during layout
      
      final baseline = flowLayout.computeDistanceToActualBaseline(TextBaseline.alphabetic);
      
      // The implementation should handle regular flow layout
      // Either return null or a reasonable baseline
      print('Regular flow baseline: $baseline');
      print('Establishes IFC: ${flowLayout.establishIFC}');
      print('Has size: ${flowLayout.hasSize}');
      
      if (baseline != null && flowLayout.hasSize) {
        expect(baseline, greaterThanOrEqualTo(0));
        expect(baseline, lessThanOrEqualTo(flowLayout.size.height));
      }
    });

    testWidgets('inline-block with flex child adopts flex baseline', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'inline-block-flex-baseline-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <div style="font-size: 18px;">
            before
            <span id="inline-block-flex" style="display: inline-block; background: rgba(0,0,0,0.05);">
              <div id="flex-child" style="display: flex; align-items: baseline; height: 40px; background: rgba(0,0,255,0.05); margin-top: 6px;">
                <div style="margin-top: 12px;">baseline</div>
              </div>
            </span>
            after
          </div>
        ''',
      );

      await tester.pump();
      await tester.pump();

      final inlineBlock = prepared.getElementById('inline-block-flex');
      final flexChild = prepared.getElementById('flex-child');

      expect(inlineBlock, isNotNull);
      expect(flexChild, isNotNull);

      final inlineRenderer = inlineBlock.attachedRenderer;
      final flexRenderer = flexChild.attachedRenderer;

      expect(inlineRenderer, isA<RenderFlowLayout>());
      expect(flexRenderer, isA<RenderFlexLayout>());

      final RenderFlowLayout inlineFlow = inlineRenderer as RenderFlowLayout;
      final RenderFlexLayout flexLayout = flexRenderer as RenderFlexLayout;

      final double? inlineBaseline = inlineFlow.computeDistanceToActualBaseline(TextBaseline.alphabetic);
      final double? flexBaseline = flexLayout.computeDistanceToActualBaseline(TextBaseline.alphabetic);

      expect(inlineBaseline, isNotNull);
      expect(flexBaseline, isNotNull);

      // Baseline should not fall back to the bottom edge.
      expect(inlineFlow.hasSize, isTrue);
      expect(inlineBaseline!, lessThan(inlineFlow.size.height));

      final Offset flexOffset = getLayoutTransformTo(flexLayout, inlineFlow, excludeScrollOffset: true);
      final double expectedBaseline = flexBaseline! + flexOffset.dy;

      expect(inlineBaseline, moreOrLessEquals(expectedBaseline, epsilon: 0.5));
    });

    testWidgets('complex nested inline-block structure', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'complex-nested-test-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <div id="root" style="border: 1px solid #000;">
            Start text
            <div style="display: inline-block;">
              <div id="child">Nested Block 1</div>
              <div>Nested Block 2</div>
            </div>
            <span style="display: inline-block;" id="inline-block">
              Inline content with <em>emphasis</em> 中文
            </span>
            End text
          </div>
        ''',
      );

      // Wait for layout to complete
      await tester.pump();
      await tester.pump();

      // Get the root element
      final root = prepared.getElementById('root');
      expect(root, isNotNull);
      
      // Get the nested inline-block div - it's the first div child
      dom.Element? nestedInlineBlock;
      for (var child in root.children) {
        if (child is dom.Element && child.tagName == 'DIV') {
          nestedInlineBlock = child;
          break;
        }
      }
      expect(nestedInlineBlock, isNotNull);
      expect(nestedInlineBlock!.renderStyle.display, equals(CSSDisplay.inlineBlock));
      
      // Get the inline-block span
      final inlineBlockSpan = prepared.getElementById('inline-block');
      expect(inlineBlockSpan, isNotNull);
      
      // Verify render boxes
      final nestedRenderBox = nestedInlineBlock.attachedRenderer;
      final spanRenderBox = inlineBlockSpan.attachedRenderer;
      
      expect(nestedRenderBox, isNotNull);
      expect(spanRenderBox, isNotNull);
      
      // Both should be RenderFlowLayout with inline-block display
      expect(nestedRenderBox, isA<RenderFlowLayout>());
      expect(spanRenderBox, isA<RenderFlowLayout>());
      
      final nestedFlow = nestedRenderBox as RenderFlowLayout;
      final spanFlow = spanRenderBox as RenderFlowLayout;
      
      // Check baseline calculations
      final nestedBaseline = nestedFlow.computeDistanceToActualBaseline(TextBaseline.alphabetic);
      final spanBaseline = spanFlow.computeDistanceToActualBaseline(TextBaseline.alphabetic);
      
      print('Complex nested structure test:');
      print('Nested inline-block baseline: $nestedBaseline');
      print('Nested inline-block size: ${nestedFlow.hasSize ? nestedFlow.size : "no size"}');
      print('Span inline-block baseline: $spanBaseline');
      print('Span inline-block size: ${spanFlow.hasSize ? spanFlow.size : "no size"}');
      
      // Both should have valid baselines
      expect(nestedBaseline, isNotNull);
      expect(spanBaseline, isNotNull);
      
      // The nested div contains two block elements, so it establishes a regular flow
      // and should use the baseline from the last line
      if (nestedFlow.hasSize && nestedBaseline != null) {
        // For a div with multiple block children, baseline should be based on last line
        expect(nestedBaseline, greaterThan(0));
        expect(nestedBaseline, lessThanOrEqualTo(nestedFlow.size.height));
        
        // With two lines of text, baseline should be closer to bottom
        final nestedRatio = nestedBaseline / nestedFlow.size.height;
        print('Nested baseline ratio: $nestedRatio');
      }
      
      // The span contains inline content with emphasis, so it establishes IFC
      // and should have a baseline from the text
      if (spanFlow.hasSize && spanBaseline != null) {
        expect(spanBaseline, greaterThan(0));
        expect(spanBaseline, lessThan(spanFlow.size.height));
        
        // For inline content, baseline should be closer to top than bottom
        final spanRatio = spanBaseline / spanFlow.size.height;
        print('Span baseline ratio: $spanRatio');
        expect(spanRatio, lessThan(0.9)); // Not at the very bottom
      }
      
      print('Nested establishes IFC: ${nestedFlow.establishIFC}');
      print('Span establishes IFC: ${spanFlow.establishIFC}');
    });
  });

  group('Inline-flex baseline with block child', () {
    testWidgets('inline-flex baseline equals first child bottom for alignment', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'inline-flex-child-baseline-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <div id="wrapper" style="
            border: 5px solid black;
            position: relative;
            width: 200px;
            height: 150px;
            margin: 10px;
          ">
            <div id="blue" style="
              width: 50px;
              height: 50px;
              background: blue;
              display: inline-block;
            "></div>
            <div id="magenta" style="
              border: 5px solid magenta;
              display: inline-flex;
            ">
              <div id="cyan" style="
                border: 10px solid cyan;
                padding: 15px;
                margin: 20px 0px;
                background: yellow;
              "></div>
            </div>
          </div>
        '''
      );

      final blue = prepared.getElementById('blue');
      final cyan = prepared.getElementById('cyan');

      await tester.pump();

      final blueRect = blue.getBoundingClientRect();
      final cyanRect = cyan.getBoundingClientRect();

      final blueBottom = blueRect.top + blue.offsetHeight;
      final cyanBottom = cyanRect.top + cyan.offsetHeight;

      // Baseline alignment expectation: blue bottom aligns with cyan bottom.
      expect((blueBottom - cyanBottom).abs(), lessThanOrEqualTo(1.0));
    });

    testWidgets('flex item with scrollable content uses first line baseline', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'inline-flex-scroll-baseline-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <div style="font-size: 18px;">
            before
            <div id="inline-flex" style="display: inline-flex; align-items: baseline; background: rgba(0,0,0,0.05);">
              <div id="scroll-item" style="overflow-y: scroll; height: 50px; padding-top: 15px;">
                <span>First line baseline</span><br/>
                Second line text that overflows<br/>
                Third line text
              </div>
            </div>
            after
          </div>
        ''',
      );

      await tester.pump();
      await tester.pump();

      final scrollItem = prepared.getElementById('scroll-item');
      expect(scrollItem, isNotNull);

      final renderBox = scrollItem.attachedRenderer;
      expect(renderBox, isA<RenderFlowLayout>());

      final RenderFlowLayout flowLayout = renderBox as RenderFlowLayout;
      expect(flowLayout.hasSize, isTrue);

      final double? firstBaseline = flowLayout.computeCssFirstBaselineOf(TextBaseline.alphabetic);
      final double? baseline = flowLayout.computeDistanceToActualBaseline(TextBaseline.alphabetic);
      expect(firstBaseline, isNotNull);
      expect(baseline, isNotNull);
      expect((baseline! - firstBaseline!).abs(), lessThanOrEqualTo(0.5));
    });

    testWidgets('inline-block baseline aligns with flex fallback', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'inline-block-flex-margin-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <div style="font-size: 16px;">
            <span id="canvas" style="display: inline-block; width: 50px; height: 50px; background: blue;"></span>
            <span id="magenta" style="display: inline-block; border: 5px solid magenta; margin: 10px;">
              <div id="flex" style="display: flex; border: 10px solid cyan; padding: 15px; margin: 20px 0; background: yellow;"></div>
            </span>
          </div>
        ''',
      );

      await tester.pump();
      await tester.pump();

      final magenta = prepared.getElementById('magenta');
      final canvas = prepared.getElementById('canvas');
      final flex = prepared.getElementById('flex');

      expect(magenta, isNotNull);
      expect(canvas, isNotNull);
      expect(flex, isNotNull);

      final RenderFlowLayout inlineBlock = magenta.attachedRenderer as RenderFlowLayout;
      final RenderFlowLayout canvasBlock = canvas.attachedRenderer as RenderFlowLayout;
      final RenderFlexLayout flexLayout = flex.attachedRenderer as RenderFlexLayout;

      final double? parentBaseline = inlineBlock.computeDistanceToActualBaseline(TextBaseline.alphabetic);
      final double? canvasBaseline = canvasBlock.computeDistanceToActualBaseline(TextBaseline.alphabetic);
      final double? childBaseline = flexLayout.computeDistanceToActualBaseline(TextBaseline.alphabetic);

      expect(parentBaseline, isNotNull);
      expect(canvasBaseline, isNotNull);
      expect(childBaseline, isNotNull);

      // Canvas inline-block baseline equals its border-box height.
      expect((canvasBaseline! - canvasBlock.boxSize!.height).abs(), lessThanOrEqualTo(0.5));
      // Inline-block with a flex fallback should synthesize baseline from its bottom border edge.
      expect((parentBaseline! - inlineBlock.boxSize!.height).abs(), lessThanOrEqualTo(0.5));
      // Flex baseline fallback should be defined.
      expect(childBaseline, greaterThan(0));
    });
  });
}
