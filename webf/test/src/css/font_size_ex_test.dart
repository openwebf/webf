import 'package:flutter_test/flutter_test.dart';
import 'package:webf/dom.dart' as dom;
import 'package:webf/rendering.dart';
import '../../setup.dart';
import '../widget/test_utils.dart';

void main() {
  setUpAll(() {
    setupTest();
  });

  group('font-size ex unit', () {
    testWidgets('font-size: 3ex resolves vs parent', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        html: '''
          <div id="c" style="font-size:16px">
            <p id="p" style="font-size:3ex">Hello</p>
          </div>
        ''',
      );

      final p = prepared.getElementById('p') as dom.Element;
      // With fallback 1ex=0.5em, 3ex = 1.5em; parent font-size=16px => 24px
      expect(p.attachedRenderer!.renderStyle.fontSize.computedValue, closeTo(24.0, 0.1));
    });
  });
}

