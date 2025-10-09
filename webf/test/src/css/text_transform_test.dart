import 'package:flutter_test/flutter_test.dart';
import 'package:webf/rendering.dart';
import 'package:webf/src/dom/elements/element.dart' as dom;
import '../webf_test_bindings.dart';

void main() {
  group('text-transform', () {
    testWidgets('uppercase and lowercase', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        html: '''
          <div>
            <span id="u" style="text-transform: uppercase">Abc def</span>
            <span id="l" style="text-transform: lowercase">Abc DEF</span>
          </div>
        ''',
      );
      final u = prepared.getElementById('u') as dom.Element;
      final l = prepared.getElementById('l') as dom.Element;
      // Verify the property is parsed and present
      expect(u.attachedRenderer!.renderStyle.textTransform, equals(TextTransform.uppercase));
      expect(l.attachedRenderer!.renderStyle.textTransform, equals(TextTransform.lowercase));
    });

    testWidgets('capitalize respects nbsp and all-caps words', (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        html: '''
          <div>
            <span id="c" style="text-transform: capitalize">usa&nbsp;road test</span>
          </div>
        ''',
      );
      final c = prepared.getElementById('c') as dom.Element;
      expect(c.attachedRenderer!.renderStyle.textTransform, equals(TextTransform.capitalize));
    });
  });
}

