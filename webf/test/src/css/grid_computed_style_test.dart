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
              width:240px;
              grid-template-columns: 40px 1fr auto;
              grid-template-rows: 40px 50px;
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
      expect(gridComputed.getPropertyValue('grid-template-columns'), equals('40px 1fr auto'));
      expect(gridComputed.getPropertyValue('grid-template-rows'), equals('40px 50px'));
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
  });
}
