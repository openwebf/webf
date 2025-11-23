/*
 * CSS Grid auto-flow parsing tests.
 */

import 'package:flutter_test/flutter_test.dart';
import 'package:webf/webf.dart';
import 'package:webf/css.dart';
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

  group('grid-auto-flow', () {
    testWidgets('parses row dense value', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'grid-auto-flow-test-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <div id="grid" style="display:grid; grid-template-columns: 100px 1fr; grid-auto-flow: row dense;">
            <div>Item 1</div>
            <div>Item 2</div>
          </div>
        ''',
      );

      final gridElement = prepared.getElementById('grid');
      expect(gridElement.renderStyle.gridAutoFlow, GridAutoFlow.rowDense);
    });

    testWidgets('parses column dense value', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        controllerName: 'grid-auto-flow-test-column-${DateTime.now().millisecondsSinceEpoch}',
        html: '''
          <div id="grid" style="display:grid; grid-template-rows: 60px 60px; grid-auto-flow: column dense;">
            <div>Item 1</div>
            <div>Item 2</div>
          </div>
        ''',
      );

      final gridElement = prepared.getElementById('grid');
      expect(gridElement.renderStyle.gridAutoFlow, GridAutoFlow.columnDense);
    });
  });
}
