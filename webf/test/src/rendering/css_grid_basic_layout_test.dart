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
      final b = prepared.getElementById('b');
      final c = prepared.getElementById('c');

      expect(grid.renderStyle.display, equals(CSSDisplay.grid));
      final rg = grid.attachedRenderer as RenderGridLayout;
      expect(rg.hasSize, isTrue);
      expect(rg.size.width, equals(250));

      final rb = b.attachedRenderer as RenderBox;
      final rc = c.attachedRenderer as RenderBox;

      // Compute offsets relative to the grid container using layout transforms.
      final RenderGridLayout gridRenderer = grid.attachedRenderer as RenderGridLayout;
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

    testWidgets('percentage gap resolves auto row-gap against content height', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'grid-gap-pct-auto-rows-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <div id="grid" style="display: grid; width: 300px; grid-template-columns: auto auto; grid-template-rows: auto; gap: 5%;">
            <div id="a" style="padding: 20px; background: #7B1FA2; color: white;">1</div>
            <div id="b" style="padding: 20px; background: #8E24AA; color: white;">2</div>
            <div id="c" style="padding: 20px; background: #9C27B0; color: white;">3</div>
            <div id="d" style="padding: 20px; background: #AB47BC; color: white;">4</div>
          </div>
        ''',
      );

      await tester.pump();

      final grid = prepared.getElementById('grid');
      final a = prepared.getElementById('a');
      final b = prepared.getElementById('b');
      final c = prepared.getElementById('c');

      final RenderGridLayout gridRenderer = grid.attachedRenderer as RenderGridLayout;
      final RenderBox ra = a.attachedRenderer as RenderBox;
      final RenderBox rb = b.attachedRenderer as RenderBox;
      final RenderBox rc = c.attachedRenderer as RenderBox;

      final Offset aOffset = getLayoutTransformTo(ra, gridRenderer, excludeScrollOffset: true);
      final Offset bOffset = getLayoutTransformTo(rb, gridRenderer, excludeScrollOffset: true);
      final Offset cOffset = getLayoutTransformTo(rc, gridRenderer, excludeScrollOffset: true);

      final double columnGap = bOffset.dx - (aOffset.dx + ra.size.width);
      expect(columnGap, closeTo(15.0, 1.0)); // 5% of 300px

      final double rowGap = cOffset.dy - (aOffset.dy + ra.size.height);
      expect(rowGap, greaterThan(0));
      expect(rowGap, closeTo(gridRenderer.size.height * 0.05, 1.0));
    });

    testWidgets('nested percentage widths do not inflate auto row height', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'grid-nested-percent-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <div id="grid" style="display: grid; grid-template-columns: auto; grid-template-rows: auto;">
            <div id="item" style="padding: 10px; background: #FFB74D;">
              <div style="width: 80%; padding: 10px; background: #FF9800;">
                <div style="width: 90%; padding: 10px; background: #F57C00; color: white;">Nested content</div>
              </div>
            </div>
          </div>
        ''',
      );

      await tester.pump();

      final grid = prepared.getElementById('grid');
      final item = prepared.getElementById('item');

      final RenderGridLayout gridRenderer = grid.attachedRenderer as RenderGridLayout;
      final RenderBox itemRenderer = item.attachedRenderer as RenderBox;

      expect(gridRenderer.size.height, greaterThan(80));
      expect(gridRenderer.size.height, lessThanOrEqualTo(100)); // Give more headroom
      expect(itemRenderer.size.height, greaterThan(80));
      expect(itemRenderer.size.height, lessThanOrEqualTo(100)); // Give more headroom
      expect(itemRenderer.size.height, gridRenderer.size.height);
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

    testWidgets('reverse column line range falls back to auto placement', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'grid-invalid-column-range-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <div id="grid" style="display: grid; width: 150px; grid-template-columns: 50px 50px 50px; grid-auto-columns: 50px; column-gap: 0; row-gap: 0;">
            <div id="a" style="height:10px;"></div>
            <div id="b" style="height:10px; grid-column: 5 / 2;"></div>
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

      expect(aOffset.dx, closeTo(0, 1));
      expect(bOffset.dx, closeTo(50, 1));
      expect(bOffset.dy, closeTo(0, 1));
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

    testWidgets('justify-content space-between distributes columns', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'grid-justify-space-between-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <div id="grid" style="display: grid; width: 200px; justify-content: space-between; grid-template-columns: 40px 40px; column-gap: 0; row-gap: 0;">
            <div id="a" style="height:20px;"></div>
            <div id="b" style="height:20px;"></div>
          </div>
        ''',
      );

      await tester.pump();

      final RenderGridLayout renderer = prepared.getElementById('grid').attachedRenderer as RenderGridLayout;
      final RenderBox renderA = prepared.getElementById('a').attachedRenderer as RenderBox;
      final RenderBox renderB = prepared.getElementById('b').attachedRenderer as RenderBox;

      final Offset aOffset = getLayoutTransformTo(renderA, renderer, excludeScrollOffset: true);
      final Offset bOffset = getLayoutTransformTo(renderB, renderer, excludeScrollOffset: true);

      expect(aOffset.dx, closeTo(0, 1));
      expect(bOffset.dx, closeTo(160, 1));
      expect(bOffset.dy, closeTo(0, 1));
    });

    testWidgets('justify-content space-around distributes columns', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'grid-justify-space-around-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <div id="grid" style="display: grid; width: 200px; justify-content: space-around; grid-template-columns: 40px 40px; column-gap: 0; row-gap: 0;">
            <div id="a" style="height:20px;"></div>
            <div id="b" style="height:20px;"></div>
          </div>
        ''',
      );

      await tester.pump();

      final RenderGridLayout renderer = prepared.getElementById('grid').attachedRenderer as RenderGridLayout;
      final RenderBox renderA = prepared.getElementById('a').attachedRenderer as RenderBox;
      final RenderBox renderB = prepared.getElementById('b').attachedRenderer as RenderBox;

      final Offset aOffset = getLayoutTransformTo(renderA, renderer, excludeScrollOffset: true);
      final Offset bOffset = getLayoutTransformTo(renderB, renderer, excludeScrollOffset: true);

      expect(aOffset.dx, closeTo(30, 1));
      expect(bOffset.dx, closeTo(130, 1));
      expect(bOffset.dy, closeTo(0, 1));
    });

    testWidgets('justify-content space-evenly distributes columns', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'grid-justify-space-evenly-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <div id="grid" style="display: grid; width: 200px; justify-content: space-evenly; grid-template-columns: 40px 40px; column-gap: 0; row-gap: 0;">
            <div id="a" style="height:20px;"></div>
            <div id="b" style="height:20px;"></div>
          </div>
        ''',
      );

      await tester.pump();

      final RenderGridLayout renderer = prepared.getElementById('grid').attachedRenderer as RenderGridLayout;
      final RenderBox renderA = prepared.getElementById('a').attachedRenderer as RenderBox;
      final RenderBox renderB = prepared.getElementById('b').attachedRenderer as RenderBox;

      final Offset aOffset = getLayoutTransformTo(renderA, renderer, excludeScrollOffset: true);
      final Offset bOffset = getLayoutTransformTo(renderB, renderer, excludeScrollOffset: true);

      expect(aOffset.dx, closeTo(40, 1));
      expect(bOffset.dx, closeTo(120, 1));
      expect(bOffset.dy, closeTo(0, 1));
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

    testWidgets('minmax(0, 1fr) prevents flex min overflow with percent-sized content', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'grid-minmax-0-fr-percent-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <div id="grid" style="display: grid; width: 200px; grid-template-columns: repeat(2, minmax(0, 1fr)); column-gap: 16px;">
            <div id="a" style="border: 1px solid #000; overflow: hidden;">
              <div style="height: 150px; background: #000;">
                <img style="width: 100%; height: 150px; object-fit: contain;"
                  src="data:image/svg+xml,%3Csvg%20xmlns%3D'http%3A%2F%2Fwww.w3.org%2F2000%2Fsvg'%20width%3D'300'%20height%3D'224'%3E%3Crect%20width%3D'300'%20height%3D'224'%20fill%3D'red'%2F%3E%3C%2Fsvg%3E" />
              </div>
            </div>
            <div id="b" style="border: 1px solid #000; overflow: hidden;">
              <div style="height: 150px; background: #000;">
                <img style="width: 100%; height: 150px; object-fit: contain;"
                  src="data:image/svg+xml,%3Csvg%20xmlns%3D'http%3A%2F%2Fwww.w3.org%2F2000%2Fsvg'%20width%3D'300'%20height%3D'224'%3E%3Crect%20width%3D'300'%20height%3D'224'%20fill%3D'blue'%2F%3E%3C%2Fsvg%3E" />
              </div>
            </div>
          </div>
        ''',
      );

      await tester.pump();

      final grid = prepared.getElementById('grid');
      final b = prepared.getElementById('b');

      final RenderGridLayout gridRenderer = grid.attachedRenderer as RenderGridLayout;
      final RenderBox rb = b.attachedRenderer as RenderBox;

      // Each column should be (200 - 16) / 2 = 92px, so B starts at 92 + 16 = 108px.
      final Offset bOffset = getLayoutTransformTo(rb, gridRenderer, excludeScrollOffset: true);
      expect(bOffset.dx, closeTo(108.0, 2.0));

      // The grid should not overflow horizontally (regression for flex min-size inflation).
      expect(gridRenderer.scrollableSize.width, closeTo(200.0, 2.0));
    });
  });
}
