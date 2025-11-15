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

  testWidgets('paragraph text surfaces to semantics traversal', (WidgetTester tester) async {
    final html = '''
      <p id="plain-text">Paragraph text should be read aloud.</p>
    ''';

    await WebFWidgetTestUtils.prepareWidgetTest(
      tester: tester,
      html: '<body>$html</body>',
      controllerName: 'a11y-p-${DateTime.now().millisecondsSinceEpoch}',
      wrap: (child) => MaterialApp(home: Scaffold(body: child)),
    );

    final handle = tester.ensureSemantics();
    try {
      await tester.pump();
      expect(find.bySemanticsLabel('Paragraph text should be read aloud.'), findsOneWidget);
    } finally {
      handle.dispose();
    }
  });

  testWidgets('dynamically inserted paragraphs become readable', (WidgetTester tester) async {
    final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
      tester: tester,
      html: '<body></body>',
      controllerName: 'a11y-p-dynamic-${DateTime.now().millisecondsSinceEpoch}',
      wrap: (child) => MaterialApp(home: Scaffold(body: child)),
    );

    await prepared.controller.view.evaluateJavaScripts('''
      const p = document.createElement('p');
      p.id = 'dynamic-p';
      p.textContent = 'Dynamic paragraph text should be announced.';
      document.body.appendChild(p);
    ''');

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    final handle = tester.ensureSemantics();
    try {
      await tester.pump();
      expect(find.bySemanticsLabel('Dynamic paragraph text should be announced.'), findsOneWidget);
    } finally {
      handle.dispose();
    }
  });

  testWidgets('section landmark exposes heading and description text', (WidgetTester tester) async {
    final html = '''
      <section id="landmark" class="componentItem" aria-labelledby="landmark-demo-title">
        <h2 id="landmark-demo-title" class="itemLabel">Landmarks & Skip Navigation</h2>
        <p id="landmark-desc" class="itemDesc">
          Structure pages so assistive technologies can offer shortcuts. Skip links paired with semantic landmarks let keyboard users move directly to the content they need.
        </p>
        <div class="landmarkExample"></div>
      </section>
    ''';

    final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
      tester: tester,
      html: '<body>$html</body>',
      controllerName: 'a11y-landmark-${DateTime.now().millisecondsSinceEpoch}',
      wrap: (child) => MaterialApp(home: Scaffold(body: child)),
    );

    final dom.Element section = prepared.getElementById('landmark');
    final dom.Element heading = prepared.getElementById('landmark-demo-title');
    final dom.Element description = prepared.getElementById('landmark-desc');

    expect(WebFAccessibility.computeAccessibleName(heading), equals('Landmarks & Skip Navigation'));
    expect(WebFAccessibility.computeAccessibleName(section), equals('Landmarks & Skip Navigation'));
    expect(
      WebFAccessibility.computeAccessibleName(description),
      startsWith('Structure pages so assistive technologies can offer shortcuts.'),
    );
  });

  testWidgets('navigation links read separately with correct labels', (WidgetTester tester) async {
    final html = '''
      <nav>
        <a id="home" href="/home" aria-current="page">Home</a>
        <a id="about" href="/about">About</a>
      </nav>
    ''';

    await WebFWidgetTestUtils.prepareWidgetTest(
      tester: tester,
      html: '<body>$html</body>',
      controllerName: 'a11y-nav-${DateTime.now().millisecondsSinceEpoch}',
      wrap: (child) => MaterialApp(home: Scaffold(body: child)),
    );

    final handle = tester.ensureSemantics();
    try {
      await tester.pump();
      expect(find.bySemanticsLabel('Home'), findsOneWidget);
      expect(find.bySemanticsLabel('About'), findsOneWidget);
    } finally {
      handle.dispose();
    }
  });
}
