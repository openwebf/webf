import 'package:flutter_test/flutter_test.dart';
import '../../setup.dart';
import '../widget/test_utils.dart';

void main() {
  setUpAll(() {
    setupTest();
  });

  group('text-indent units', () {
    testWidgets('computes 2ex as approx 1em', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        html: '''
          <div id="p" style="text-indent: 2ex; font-size:16px">Hello</div>
        ''',
      );
      final el = prepared.getElementById('p');
      // With our fallback 1ex = 0.5em and font-size=16px, 2ex = 16px
      expect(el.attachedRenderer!.renderStyle.textIndent.computedValue, closeTo(16.0, 0.1));
    });

    testWidgets('percentage resolves against container width', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        html: '''
          <div id="c" style="width: 200px">
            <p id="p" style="text-indent: 50%">Hello</p>
          </div>
        ''',
      );
      final p = prepared.getElementById('p');
      // 50% of 200px container width = 100px
      expect(p.attachedRenderer!.renderStyle.textIndent.computedValue, closeTo(100.0, 0.1));
    });
  });
}

