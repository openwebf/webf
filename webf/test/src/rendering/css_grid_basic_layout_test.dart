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

    testWidgets('auto-fit collapses unused tracks for justification', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'grid-auto-fit-center-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <div id="grid" style="display: grid; width: 200px; grid-template-columns: repeat(auto-fit, 40px); justify-content: center; column-gap: 0;">
            <div id="a" style="height:20px;"></div>
            <div id="b" style="height:20px;"></div>
          </div>
        ''',
      );

      await tester.pump();

      final grid = prepared.getElementById('grid');
      final RenderGridLayout renderer = grid.attachedRenderer as RenderGridLayout;
      final RenderBox renderA = prepared.getElementById('a').attachedRenderer as RenderBox;
      final RenderBox renderB = prepared.getElementById('b').attachedRenderer as RenderBox;

      final Offset aOffset = getLayoutTransformTo(renderA, renderer, excludeScrollOffset: true);
      final Offset bOffset = getLayoutTransformTo(renderB, renderer, excludeScrollOffset: true);

      expect(aOffset.dx, closeTo(60, 1));
      expect(bOffset.dx, closeTo(100, 1));
    });

    testWidgets('auto-fit rows collapse unused tracks for alignment', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'grid-auto-fit-rows-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <div id="grid" style="display: grid; height: 200px; grid-template-columns: 60px; grid-template-rows: repeat(auto-fit, 40px); align-content: center; row-gap: 0;">
            <div id="a" style="height:20px;"></div>
            <div id="b" style="height:20px;"></div>
          </div>
        ''',
      );

      await tester.pump();

      final grid = prepared.getElementById('grid');
      final RenderGridLayout renderer = grid.attachedRenderer as RenderGridLayout;
      final RenderBox renderA = prepared.getElementById('a').attachedRenderer as RenderBox;
      final RenderBox renderB = prepared.getElementById('b').attachedRenderer as RenderBox;

      final Offset aOffset = getLayoutTransformTo(renderA, renderer, excludeScrollOffset: true);
      final Offset bOffset = getLayoutTransformTo(renderB, renderer, excludeScrollOffset: true);

      expect(aOffset.dy, closeTo(60, 1));
      expect(bOffset.dy, closeTo(100, 1));
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

      expect(renderer.size.width, equals(360));

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

    testWidgets('row dense auto-placement fills earlier gaps', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'grid-row-dense-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <div id="grid" style="display: grid; width: 180px; grid-auto-flow: row dense; grid-template-columns: 60px 60px 60px; grid-auto-rows: 40px; column-gap: 0; row-gap: 0;">
            <div id="wide1" style="height:40px; grid-column: span 2;"></div>
            <div id="wide2" style="height:40px; grid-column: span 2;"></div>
            <div id="compact" style="height:40px;"></div>
          </div>
        ''',
      );

      await tester.pump();

      final grid = prepared.getElementById('grid');
      final RenderGridLayout renderer = grid.attachedRenderer as RenderGridLayout;
      final RenderBox wide2 = prepared.getElementById('wide2').attachedRenderer as RenderBox;
      final RenderBox compact = prepared.getElementById('compact').attachedRenderer as RenderBox;

      final Offset wide2Offset = getLayoutTransformTo(wide2, renderer, excludeScrollOffset: true);
      final Offset compactOffset = getLayoutTransformTo(compact, renderer, excludeScrollOffset: true);

      expect(wide2Offset.dy, closeTo(40, 1));
      expect(compactOffset.dy, closeTo(0, 1));
      expect(compactOffset.dx, closeTo(120, 1));
    });

    testWidgets('column dense auto-placement fills earlier gaps', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'grid-column-dense-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <div id="grid" style="display: grid; grid-auto-flow: column dense; grid-template-rows: 40px 40px 40px; grid-auto-columns: 60px; column-gap: 0; row-gap: 0;">
            <div id="tall1" style="width:60px; grid-row: span 2;"></div>
            <div id="tall2" style="width:60px; grid-row: span 2;"></div>
            <div id="short" style="width:60px; height:40px;"></div>
          </div>
        ''',
      );

      await tester.pump();

      final grid = prepared.getElementById('grid');
      final RenderGridLayout renderer = grid.attachedRenderer as RenderGridLayout;
      final RenderBox tall2 = prepared.getElementById('tall2').attachedRenderer as RenderBox;
      final RenderBox shortCell = prepared.getElementById('short').attachedRenderer as RenderBox;

      final Offset tall2Offset = getLayoutTransformTo(tall2, renderer, excludeScrollOffset: true);
      final Offset shortOffset = getLayoutTransformTo(shortCell, renderer, excludeScrollOffset: true);

      expect(tall2Offset.dx, closeTo(60, 1));
      expect(shortOffset.dx, closeTo(0, 1));
      expect(shortOffset.dy, closeTo(80, 1));
    });

    testWidgets('grid-template-areas maps named placements', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'grid-template-areas-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <div id="grid" style="display: grid; width: 180px; grid-template-columns: 60px 60px 60px; grid-template-rows: 40px 40px; grid-template-areas: &quot;header header side&quot; &quot;footer footer side&quot;;">
            <div id="header" style="height: 40px; grid-area: header;"></div>
            <div id="footer" style="height: 40px; grid-area: footer;"></div>
            <div id="side" style="height: 80px; grid-area: side;"></div>
          </div>
        ''',
      );

      await tester.pump();

      final grid = prepared.getElementById('grid');
      final header = prepared.getElementById('header');
      final footer = prepared.getElementById('footer');
      final side = prepared.getElementById('side');

      final RenderGridLayout renderer = grid.attachedRenderer as RenderGridLayout;
      final RenderBox headerBox = header.attachedRenderer as RenderBox;
      final RenderBox footerBox = footer.attachedRenderer as RenderBox;
      final RenderBox sideBox = side.attachedRenderer as RenderBox;

      final Offset headerOffset = getLayoutTransformTo(headerBox, renderer, excludeScrollOffset: true);
      final Offset footerOffset = getLayoutTransformTo(footerBox, renderer, excludeScrollOffset: true);
      final Offset sideOffset = getLayoutTransformTo(sideBox, renderer, excludeScrollOffset: true);

      expect(renderer.size.width, equals(180));
      expect(headerOffset.dx, closeTo(0, 1));
      expect(headerBox.size.width, closeTo(120, 1));
      expect(footerOffset.dy, closeTo(40, 1));
      expect(sideOffset.dx, closeTo(120, 1));
      expect(sideBox.size.height, closeTo(80, 1));
    });

    testWidgets('grid-area shorthand positions child', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'grid-area-sh-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <div id="grid" style="display: grid; grid-template-columns: 60px 60px; grid-template-rows: 30px 30px;">
            <div id="a" style="height:30px;"></div>
            <div id="area" style="height:30px; grid-area: 2 / 1 / span 1 / span 2;"></div>
          </div>
        ''',
      );

      await tester.pump();

      final grid = prepared.getElementById('grid');
      final RenderGridLayout renderer = grid.attachedRenderer as RenderGridLayout;
      final RenderBox renderArea = prepared.getElementById('area').attachedRenderer as RenderBox;
      final Offset offset = getLayoutTransformTo(renderArea, renderer, excludeScrollOffset: true);

      expect(offset.dy, closeTo(30, 1));
      expect(renderArea.size.width, closeTo(120, 1));
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

    testWidgets('justify-content center shifts tracks', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'grid-justify-center-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <div id="grid" style="display: grid; width: 200px; justify-content: center; grid-template-columns: 50px 50px;">
            <div id="a" style="height:20px;"></div>
          </div>
        ''',
      );

      await tester.pump();

      final grid = prepared.getElementById('grid');
      final RenderGridLayout renderer = grid.attachedRenderer as RenderGridLayout;
      final RenderBox child = prepared.getElementById('a').attachedRenderer as RenderBox;
      final Offset offset = getLayoutTransformTo(child, renderer, excludeScrollOffset: true);

      expect(offset.dx, closeTo(50, 1));
    });

    testWidgets('align-content end pushes tracks to bottom', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'grid-align-end-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <div id="grid" style="display: grid; height: 200px; align-content: flex-end; grid-template-rows: 40px 40px;">
            <div id="a" style="height:40px;"></div>
            <div id="b" style="height:40px;"></div>
          </div>
        ''',
      );

      await tester.pump();

      final grid = prepared.getElementById('grid');
      final RenderGridLayout renderer = grid.attachedRenderer as RenderGridLayout;
      final RenderBox child = prepared.getElementById('a').attachedRenderer as RenderBox;
      final Offset offset = getLayoutTransformTo(child, renderer, excludeScrollOffset: true);

      expect(offset.dy, closeTo(120, 1));
    });

    testWidgets('justify-items center offsets child within cell', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'grid-justify-items-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <div id="grid" style="display: grid; width: 100px; grid-template-columns: 100px; justify-items: center;">
            <div id="child" style="display:inline-block; width: 20px; height: 10px;"></div>
          </div>
        ''',
      );

      await tester.pump();

      final grid = prepared.getElementById('grid');
      final RenderGridLayout renderer = grid.attachedRenderer as RenderGridLayout;
      final RenderBox child = prepared.getElementById('child').attachedRenderer as RenderBox;
      final Offset offset = getLayoutTransformTo(child, renderer, excludeScrollOffset: true);

      expect(offset.dx, closeTo(40, 1));
    });

    testWidgets('justify-self end overrides justify-items', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'grid-justify-self-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <div id="grid" style="display: grid; width: 100px; grid-template-columns: 100px; justify-items: start;">
            <div id="child" style="display:inline-block; width: 20px; height: 10px; justify-self: end;"></div>
          </div>
        ''',
      );

      await tester.pump();

      final grid = prepared.getElementById('grid');
      final RenderGridLayout renderer = grid.attachedRenderer as RenderGridLayout;
      final RenderBox child = prepared.getElementById('child').attachedRenderer as RenderBox;
      final Offset offset = getLayoutTransformTo(child, renderer, excludeScrollOffset: true);

      expect(offset.dx, closeTo(80, 1));
    });

    testWidgets('align-items center offsets child vertically', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'grid-align-items-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <div id="grid" style="display: grid; height: 120px; grid-template-rows: 120px; grid-template-columns: 60px; align-items: center;">
            <div id="child" style="display:inline-block; height: 40px; width: 20px;"></div>
          </div>
        ''',
      );

      await tester.pump();

      final grid = prepared.getElementById('grid');
      final RenderGridLayout renderer = grid.attachedRenderer as RenderGridLayout;
      final RenderBox child = prepared.getElementById('child').attachedRenderer as RenderBox;
      final Offset offset = getLayoutTransformTo(child, renderer, excludeScrollOffset: true);

      expect(offset.dy, closeTo(40, 1));
    });

    testWidgets('align-self flex-end overrides align-items', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'grid-align-self-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <div id="grid" style="display: grid; height: 120px; grid-template-rows: 120px; grid-template-columns: 60px; align-items: flex-start;">
            <div id="child" style="display:inline-block; height: 30px; width: 20px; align-self: flex-end;"></div>
          </div>
        ''',
      );

      await tester.pump();

      final grid = prepared.getElementById('grid');
      final RenderGridLayout renderer = grid.attachedRenderer as RenderGridLayout;
      final RenderBox child = prepared.getElementById('child').attachedRenderer as RenderBox;
      final Offset offset = getLayoutTransformTo(child, renderer, excludeScrollOffset: true);

      expect(offset.dy, closeTo(90, 1));
    });

    testWidgets('place-content controls both axes', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'grid-place-content-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <div id="grid" style="display: grid; width: 200px; height: 200px; grid-template-columns: 60px 60px; grid-template-rows: 40px 40px; place-content: center flex-end;">
            <div id="cell" style="height:40px;"></div>
          </div>
        ''',
      );

      await tester.pump();

      final grid = prepared.getElementById('grid');
      final RenderGridLayout renderer = grid.attachedRenderer as RenderGridLayout;
      final RenderBox child = prepared.getElementById('cell').attachedRenderer as RenderBox;
      final Offset offset = getLayoutTransformTo(child, renderer, excludeScrollOffset: true);

      expect(offset.dx, closeTo(80, 1));
      expect(offset.dy, closeTo(60, 1));
    });

    testWidgets('place-items applies align and justify axes', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'grid-place-items-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <div id="grid" style="display: grid; width: 120px; height: 120px; grid-template-columns: 120px; grid-template-rows: 120px; place-items: flex-end center;">
            <div id="cell" style="display:inline-block; width: 20px; height: 20px;"></div>
          </div>
        ''',
      );

      await tester.pump();

      final grid = prepared.getElementById('grid');
      final RenderGridLayout renderer = grid.attachedRenderer as RenderGridLayout;
      final RenderBox child = prepared.getElementById('cell').attachedRenderer as RenderBox;
      final Offset offset = getLayoutTransformTo(child, renderer, excludeScrollOffset: true);

      expect(offset.dx, closeTo(50, 1));
      expect(offset.dy, closeTo(100, 1));
    });

    testWidgets('place-self overrides place-items on the child', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'grid-place-self-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <div id="grid" style="display: grid; width: 100px; height: 120px; grid-template-columns: 100px; grid-template-rows: 120px; place-items: flex-start flex-start;">
            <div id="cell" style="display:inline-block; width: 20px; height: 30px; place-self: flex-end center;"></div>
          </div>
        ''',
      );

      await tester.pump();

      final grid = prepared.getElementById('grid');
      final RenderGridLayout renderer = grid.attachedRenderer as RenderGridLayout;
      final RenderBox child = prepared.getElementById('cell').attachedRenderer as RenderBox;
      final Offset offset = getLayoutTransformTo(child, renderer, excludeScrollOffset: true);

      expect(offset.dx, closeTo(40, 1));
      expect(offset.dy, closeTo(90, 1));
    });
  });
}
