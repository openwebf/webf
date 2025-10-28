import 'package:flutter_test/flutter_test.dart';
import 'package:webf/dom.dart' as dom;
import 'package:webf/src/accessibility/semantics.dart';
import 'package:flutter/material.dart';

import '../../setup.dart';
import '../widget/test_utils.dart';

void main() {
  setUp(() {
    setupTest();
  });

  group('Accessible name computation', () {
    testWidgets('aria-label and fallbacks', (WidgetTester tester) async {
      final html = '''
        <div id="a" aria-label="Alpha"></div>
        <div id="l1">First</div>
        <div id="l2">Second</div>
        <div id="b" aria-labelledby="l1 l2"></div>
        <img id="img" src="" alt="Diagram" />
        <a id="link" href="#">Learn More</a>
        <button id="btn">Submit</button>
        <input id="ib" type="button" value="Press" />
      ''';

      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        html: '<body>$html</body>',
        controllerName: 'a11y-name-${DateTime.now().millisecondsSinceEpoch}',
        wrap: (child) => MaterialApp(home: Scaffold(body: child)),
      );

      dom.Element a = prepared.getElementById('a');
      dom.Element b = prepared.getElementById('b');
      dom.Element img = prepared.getElementById('img');
      dom.Element link = prepared.getElementById('link');
      dom.Element btn = prepared.getElementById('btn');
      dom.Element ib = prepared.getElementById('ib');

      expect(WebFAccessibility.computeAccessibleName(a), equals('Alpha'));
      expect(WebFAccessibility.computeAccessibleName(b), equals('First Second'));
      expect(WebFAccessibility.computeAccessibleName(img), equals('Diagram'));
      expect(WebFAccessibility.computeAccessibleName(link), equals('Learn More'));
      expect(WebFAccessibility.computeAccessibleName(btn), equals('Submit'));
      expect(WebFAccessibility.computeAccessibleName(ib), equals('Press'));
    });
  });
}
