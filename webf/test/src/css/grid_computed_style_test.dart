/*
 * CSS Grid computed style serialization tests.
 */

import 'package:flutter_test/flutter_test.dart';
import 'package:webf/webf.dart';
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
    await Future.delayed(const Duration(milliseconds: 50));
  });

  group('grid computed style serialization', () {
    testWidgets('serializes template tracks, auto tracks, and placements', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'grid-computed-style-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <div id="grid"
            style="
              display:grid;
              width:320px;
              grid-template-columns: [nav-start] minmax(40px, 1fr) [nav-end content-start] repeat(2, [content-line] 1fr) [content-end];
              grid-template-rows: [row-start] 40px [row-middle] minmax(50px, 120px) [row-end];
              grid-auto-flow: column dense;
              grid-auto-rows: 60px auto;
              grid-auto-columns: 80px auto;
              place-content: space-evenly flex-end;
              place-items: center start;
            ">
            <div id="child" style="height:20px; width: 30px; grid-column: 2 / span 2; grid-row-start: span 3; place-self: stretch end;"></div>
          </div>
        ''',
      );

      await tester.pump();

      final grid = prepared.getElementById('grid');
      final child = prepared.getElementById('child');

      final gridComputed = prepared.controller.view.window.getComputedStyle(grid);
      expect(
        gridComputed.getPropertyValue('grid-template-columns'),
        equals('[nav-start] minmax(40px, 1fr) [nav-end content-start] repeat(2, [content-line] 1fr) [content-end]'),
      );
      expect(
        gridComputed.getPropertyValue('grid-template-rows'),
        equals('[row-start] 40px [row-middle] minmax(50px, 120px) [row-end]'),
      );
      expect(gridComputed.getPropertyValue('grid-auto-columns'), equals('80px auto'));
      expect(gridComputed.getPropertyValue('grid-auto-rows'), equals('60px auto'));
      expect(gridComputed.getPropertyValue('grid-auto-flow'), equals('column dense'));
      expect(gridComputed.getPropertyValue('justify-items'), equals('start'));
      expect(gridComputed.getPropertyValue('align-items'), equals('center'));
      expect(gridComputed.getPropertyValue('place-content'), equals('space-evenly flex-end'));
      expect(gridComputed.getPropertyValue('place-items'), equals('center start'));

      final childComputed = prepared.controller.view.window.getComputedStyle(child);
      expect(childComputed.getPropertyValue('grid-column-start'), equals('2'));
      expect(childComputed.getPropertyValue('grid-column-end'), equals('span 2'));
      expect(childComputed.getPropertyValue('grid-column'), equals('2 / span 2'));
      expect(childComputed.getPropertyValue('grid-row-start'), equals('span 3'));
      expect(childComputed.getPropertyValue('grid-row-end'), equals('auto'));
      expect(childComputed.getPropertyValue('grid-row'), equals('span 3 / auto'));
      expect(childComputed.getPropertyValue('justify-self'), equals('end'));
      expect(childComputed.getPropertyValue('align-self'), equals('stretch'));
      expect(childComputed.getPropertyValue('place-self'), equals('stretch end'));
    });

    testWidgets('serializes named line placements', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'grid-named-lines-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <div id="grid"
            style="
              display:grid;
              width:200px;
              grid-template-columns: [content-line] 40px [content-line] 60px [content-line];
              grid-template-rows: [row-line] 50px [row-line] 50px;
            ">
            <div id="named" style="grid-column: content-line 2 / content-line 3; grid-row: row-line 1 / row-line 2;"></div>
          </div>
        ''',
      );

      await tester.pump();

      final named = prepared.getElementById('named');
      final computed = prepared.controller.view.window.getComputedStyle(named);
      expect(computed.getPropertyValue('grid-column-start'), equals('content-line 2'));
      expect(computed.getPropertyValue('grid-column-end'), equals('content-line 3'));
      expect(computed.getPropertyValue('grid-row-start'), equals('row-line 1'));
      expect(computed.getPropertyValue('grid-row-end'), equals('row-line 2'));
    });

    testWidgets('serializes auto-fill repeat and fit-content templates', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'grid-auto-repeat-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <div id="grid"
            style="
              display:grid;
              grid-template-columns: repeat(auto-fill, fit-content(80px));
              grid-template-rows: repeat(2, 40px);
            ">
          </div>
        ''',
      );

      await tester.pump();

      final grid = prepared.getElementById('grid');
      final computed = prepared.controller.view.window.getComputedStyle(grid);
      expect(computed.getPropertyValue('grid-template-columns'), equals('repeat(auto-fill, fit-content(80px))'));
      expect(computed.getPropertyValue('grid-template-rows'), equals('repeat(2, 40px)'));
    });
  });
}
