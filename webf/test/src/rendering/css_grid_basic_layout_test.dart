/*
 * Copyright (C) 2025
 */

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/rendering.dart';
import 'package:webf/css.dart';
import 'package:webf/rendering.dart';
import '../widget/test_utils.dart';
import '../../setup.dart';

void main() {
  setUpAll(() {
    setupTest();
  });

  group('CSS Grid basic layout', () {
    testWidgets('columns px + fr resolve with definite width', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'grid-cols-fr-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <div id="grid" style="display: grid; width: 250px; grid-template-columns: 50px 1fr 1fr;">
            <div id="a" style="height:20px">A</div>
            <div id="b" style="height:20px">B</div>
            <div id="c" style="height:20px">C</div>
          </div>
        ''',
      );

      await tester.pump();

      final grid = prepared.getElementById('grid');
      final a = prepared.getElementById('a');
      final b = prepared.getElementById('b');
      final c = prepared.getElementById('c');

      expect(grid.renderStyle.display, equals(CSSDisplay.grid));
      final rg = grid.attachedRenderer as RenderGridLayout;
      expect(rg.hasSize, isTrue);
      expect(rg.size.width, equals(250));

      final ra = a.attachedRenderer as RenderBox;
      final rb = b.attachedRenderer as RenderBox;
      final rc = c.attachedRenderer as RenderBox;

      // Compute offsets relative to the grid container using layout transforms.
      final RenderGridLayout gridRenderer = grid.attachedRenderer as RenderGridLayout;
      final Offset aOffset = getLayoutTransformTo(ra, gridRenderer, excludeScrollOffset: true);
      final Offset bOffset = getLayoutTransformTo(rb, gridRenderer, excludeScrollOffset: true);
      final Offset cOffset = getLayoutTransformTo(rc, gridRenderer, excludeScrollOffset: true);

      // Expect B is placed after first 50px column
      expect(bOffset.dx, closeTo(50.0, 1.0));
      // C should be after B at ~150px (two 1fr columns share 200px -> 100px each)
      expect(cOffset.dx, closeTo(150.0, 2.0));
    });

    testWidgets('percentage columns resolve against definite width', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'grid-cols-pct-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <div id="grid" style="display: grid; width: 200px; grid-template-columns: 50% 50%;">
            <div id="a" style="height:10px">A</div>
            <div id="b" style="height:10px">B</div>
          </div>
        ''',
      );

      await tester.pump();

      final grid = prepared.getElementById('grid');
      final a = prepared.getElementById('a');
      final b = prepared.getElementById('b');

      expect(grid.renderStyle.display, equals(CSSDisplay.grid));
      final rg = grid.attachedRenderer as RenderGridLayout;
      expect(rg.size.width, equals(200));

      final ra = a.attachedRenderer as RenderBox;
      final rb = b.attachedRenderer as RenderBox;
      final RenderGridLayout gridRenderer = grid.attachedRenderer as RenderGridLayout;
      final Offset aOffset = getLayoutTransformTo(ra, gridRenderer, excludeScrollOffset: true);
      final Offset bOffset = getLayoutTransformTo(rb, gridRenderer, excludeScrollOffset: true);

      expect(aOffset.dx, closeTo(0.0, 1.0));
      expect(bOffset.dx, closeTo(100.0, 2.0));
    });

    testWidgets('grid-auto-columns create implicit tracks', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'grid-auto-cols-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <div id="grid" style="display: grid; grid-template-columns: 80px; grid-auto-columns: 40px;">
            <div id="item" style="height:20px; grid-column: 2 / span 2;"></div>
          </div>
        ''',
      );

      await tester.pump();

      final grid = prepared.getElementById('grid');
      final item = prepared.getElementById('item');

      final RenderGridLayout renderer = grid.attachedRenderer as RenderGridLayout;
      expect(renderer.size.width, equals(360));

      final Offset offset = getLayoutTransformTo(item.attachedRenderer as RenderBox, renderer, excludeScrollOffset: true);
      expect(offset.dx, closeTo(80.0, 1.0));

    });

    testWidgets('auto width grid fills block container width', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'grid-auto-width-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <div id="grid" style="display: grid; padding: 12px; grid-template-columns: 80px; grid-auto-columns: 40px;"></div>
        ''',
      );

      await tester.pump();

      final grid = prepared.getElementById('grid');
      final RenderGridLayout renderer = grid.attachedRenderer as RenderGridLayout;
      expect(renderer.size.width, equals(360));
    });

    testWidgets('grid-auto-flow column fills columns first', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'grid-auto-col-flow-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <div id="grid" style="display: grid; grid-auto-flow: column; grid-template-rows: 30px 30px; grid-auto-columns: 50px; column-gap: 0; row-gap: 0;">
            <div id="a" style="height:30px;"></div>
            <div id="b" style="height:30px;"></div>
            <div id="c" style="height:30px;"></div>
            <div id="d" style="height:30px;"></div>
          </div>
        ''',
      );

      await tester.pump();

      final grid = prepared.getElementById('grid');
      final RenderGridLayout renderer = grid.attachedRenderer as RenderGridLayout;
      final RenderBox renderA = prepared.getElementById('a').attachedRenderer as RenderBox;
      final RenderBox renderB = prepared.getElementById('b').attachedRenderer as RenderBox;
      final RenderBox renderC = prepared.getElementById('c').attachedRenderer as RenderBox;
      final RenderBox renderD = prepared.getElementById('d').attachedRenderer as RenderBox;

      expect(renderer.size.width, equals(100));

      final Offset aOffset = getLayoutTransformTo(renderA, renderer, excludeScrollOffset: true);
      final Offset bOffset = getLayoutTransformTo(renderB, renderer, excludeScrollOffset: true);
      final Offset cOffset = getLayoutTransformTo(renderC, renderer, excludeScrollOffset: true);
      final Offset dOffset = getLayoutTransformTo(renderD, renderer, excludeScrollOffset: true);

      expect(aOffset.dx, closeTo(0, 1));
      expect(aOffset.dy, closeTo(0, 1));
      expect(bOffset.dx, closeTo(0, 1));
      expect(bOffset.dy, closeTo(30, 1));
      expect(cOffset.dx, closeTo(50, 1));
      expect(cOffset.dy, closeTo(0, 1));
      expect(dOffset.dx, closeTo(50, 1));
      expect(dOffset.dy, closeTo(30, 1));
    });

    testWidgets('column auto-flow without explicit rows creates new columns', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'grid-auto-col-default-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <div id="grid" style="display: grid; grid-auto-flow: column; grid-auto-columns: 40px;">
            <div id="a" style="height:20px;"></div>
            <div id="b" style="height:20px;"></div>
            <div id="c" style="height:20px;"></div>
          </div>
        ''',
      );

      await tester.pump();

      final grid = prepared.getElementById('grid');
      final RenderGridLayout renderer = grid.attachedRenderer as RenderGridLayout;
      final RenderBox renderA = prepared.getElementById('a').attachedRenderer as RenderBox;
      final RenderBox renderB = prepared.getElementById('b').attachedRenderer as RenderBox;
      final RenderBox renderC = prepared.getElementById('c').attachedRenderer as RenderBox;

      final Offset aOffset = getLayoutTransformTo(renderA, renderer, excludeScrollOffset: true);
      final Offset bOffset = getLayoutTransformTo(renderB, renderer, excludeScrollOffset: true);
      final Offset cOffset = getLayoutTransformTo(renderC, renderer, excludeScrollOffset: true);

      expect(aOffset.dx, closeTo(0, 1));
      expect(bOffset.dx, closeTo(40, 1));
      expect(cOffset.dx, closeTo(80, 1));
      expect(aOffset.dy, closeTo(0, 1));
      expect(bOffset.dy, closeTo(0, 1));
      expect(cOffset.dy, closeTo(0, 1));
    });

    testWidgets('column auto-flow reuses explicit implicit rows', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'grid-auto-col-implicit-row-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <div id="grid" style="display: grid; grid-auto-flow: column; grid-template-rows: 20px 20px; grid-auto-columns: 40px;">
            <div id="extend" style="grid-column: 2; grid-row: 3; height:20px;"></div>
            <div id="a" style="height:20px;"></div>
            <div id="b" style="height:20px;"></div>
            <div id="c" style="height:20px;"></div>
          </div>
        ''',
      );

      await tester.pump();

      final grid = prepared.getElementById('grid');
      final RenderGridLayout renderer = grid.attachedRenderer as RenderGridLayout;
      final RenderBox renderA = prepared.getElementById('a').attachedRenderer as RenderBox;
      final RenderBox renderB = prepared.getElementById('b').attachedRenderer as RenderBox;
      final RenderBox renderC = prepared.getElementById('c').attachedRenderer as RenderBox;

      final Offset aOffset = getLayoutTransformTo(renderA, renderer, excludeScrollOffset: true);
      final Offset bOffset = getLayoutTransformTo(renderB, renderer, excludeScrollOffset: true);
      final Offset cOffset = getLayoutTransformTo(renderC, renderer, excludeScrollOffset: true);

      expect(aOffset.dy, closeTo(0, 1));
      expect(bOffset.dy, closeTo(20, 1));
      expect(cOffset.dy, closeTo(40, 1));
      expect(cOffset.dx, closeTo(0, 1));
    });

    testWidgets('grid-column 1 / -1 spans all explicit columns', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'grid-negative-column-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <div id="grid" style="display: grid; width: 180px; grid-template-columns: 60px 60px 60px;">
            <div id="span" style="grid-column: 1 / -1; height:30px;"></div>
          </div>
        ''',
      );

      await tester.pump();

      final grid = prepared.getElementById('grid');
      final element = prepared.getElementById('span');
      final RenderGridLayout renderer = grid.attachedRenderer as RenderGridLayout;
      final RenderBox renderSpan = element.attachedRenderer as RenderBox;

      expect(renderer.size.width, equals(180));
      expect(renderSpan.size.width, equals(180));
      final Offset offset = getLayoutTransformTo(renderSpan, renderer, excludeScrollOffset: true);
      expect(offset.dx, closeTo(0, 1));
    });

    testWidgets('grid-row with negative line targets last track', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'grid-negative-row-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <div id="grid" style="display: grid; grid-template-rows: 15px 15px 15px;">
            <div id="first" style="height:15px;"></div>
            <div id="last" style="grid-row: -1; height:15px;"></div>
          </div>
        ''',
      );

      await tester.pump();

      final grid = prepared.getElementById('grid');
      final RenderGridLayout renderer = grid.attachedRenderer as RenderGridLayout;
      final RenderBox firstBox = prepared.getElementById('first').attachedRenderer as RenderBox;
      final RenderBox lastBox = prepared.getElementById('last').attachedRenderer as RenderBox;

      final Offset firstOffset = getLayoutTransformTo(firstBox, renderer, excludeScrollOffset: true);
      final Offset lastOffset = getLayoutTransformTo(lastBox, renderer, excludeScrollOffset: true);

      expect(firstOffset.dy, closeTo(0, 1));
      expect(lastOffset.dy, closeTo(30, 1));
    });
  });
}
