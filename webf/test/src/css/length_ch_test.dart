import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:webf/css.dart';

import '../../setup.dart';
import '../widget/test_utils.dart';

void main() {
  setUpAll(() {
    setupTest();
  });

  group('length ch unit', () {
    testWidgets('width: 40ch resolves vs "0" glyph width', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        html: '''
          <p id="p" style="width:40ch;font:16px/1 monospace">Hello</p>
        ''',
      );

      final p = prepared.getElementById('p');
      final CSSRenderStyle rs = p.attachedRenderer!.renderStyle as CSSRenderStyle;

      expect(rs.width.type, CSSLengthType.CH);

      final TextStyle style = CSSTextMixin.createTextStyle(rs);
      final TextPainter tp = TextPainter(
        text: TextSpan(text: '0', style: style),
        textScaler: rs.textScaler,
        textDirection: rs.direction,
        maxLines: 1,
      )..layout(minWidth: 0, maxWidth: double.infinity);

      expect(rs.width.computedValue, closeTo(tp.width * 40, 0.5));
    });
  });
}
