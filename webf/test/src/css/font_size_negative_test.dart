import 'package:flutter_test/flutter_test.dart';
import '../../setup.dart';
import '../widget/test_utils.dart';

void main() {
  setUpAll(() {
    setupTest();
  });

  group('font-size', () {
    testWidgets('negative <length> is ignored', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        html: '''
          <div id="c" style="font-size:40px">
            <p id="p" style="font-size:-0.5in; margin:10px 0">Hello</p>
          </div>
        ''',
      );

      final p = prepared.getElementById('p');
      expect(p.attachedRenderer!.renderStyle.fontSize.computedValue, closeTo(40.0, 0.1));
      expect(tester.takeException(), isNull);
    });
  });
}

