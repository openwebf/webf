/*
 * Copyright (C) 2025
 */

import 'package:flutter_test/flutter_test.dart';
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

      final pa = ra.parentData as RenderLayoutParentData;
      final pb = rb.parentData as RenderLayoutParentData;
      final pc = rc.parentData as RenderLayoutParentData;

      // Expect B is placed after first 50px column
      expect(pb.offset.dx, closeTo(50.0, 0.5));
      // C should be after B at ~150px (two 1fr columns share 200px -> 100px each)
      expect(pc.offset.dx, closeTo(150.0, 1.0));
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
      final pa = ra.parentData as RenderLayoutParentData;
      final pb = rb.parentData as RenderLayoutParentData;

      expect(pa.offset.dx, closeTo(0.0, 0.5));
      expect(pb.offset.dx, closeTo(100.0, 0.5));
    });
  });
}

