import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/semantics.dart';
import 'package:webf/dom.dart' as dom;
import 'package:webf/src/accessibility/semantics.dart';
import 'package:flutter/material.dart';

import '../../setup.dart';
import '../widget/test_utils.dart';

SemanticsNode? _findSemanticsNodeWithLabel(SemanticsNode root, String label) {
  SemanticsNode? found;
  void visit(SemanticsNode node) {
    if (found != null) return;
    if (node.getSemanticsData().label == label) {
      found = node;
      return;
    }
    node.visitChildren((SemanticsNode child) {
      visit(child);
      return found == null;
    });
  }

  visit(root);
  return found;
}

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

  testWidgets('inline strong text stays discoverable', (WidgetTester tester) async {
    final html = '''
      <section>
        <p id="p_element">P element</p>
        <strong id="strong_element">Strong element</strong>
      </section>
    ''';

    await WebFWidgetTestUtils.prepareWidgetTest(
      tester: tester,
      html: '<body>$html</body>',
      controllerName: 'a11y-strong-${DateTime.now().millisecondsSinceEpoch}',
      wrap: (child) => MaterialApp(home: Scaffold(body: child)),
    );

    final handle = tester.ensureSemantics();
    try {
      await tester.pump();
      expect(find.bySemanticsLabel('P element'), findsOneWidget);
      expect(find.bySemanticsLabel('Strong element'), findsOneWidget);
    } finally {
      handle.dispose();
    }
  });

  group('Overflow scroll semantics', () {
    testWidgets('overflow scroll exposes scrollPosition and updates on scroll', (WidgetTester tester) async {
      final rows = List<String>.generate(
        60,
        (i) => '<div style="height: 20px; line-height: 20px;">Message ${i + 1}</div>',
      ).join();

      final html = '''
        <div id="region"
             role="region"
             aria-label="Chat Messages"
             tabindex="0"
             style="height: 100px; width: 200px; overflow-y: auto; border: 1px solid #000;">
          $rows
        </div>
      ''';

      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        html: '<body>$html</body>',
        controllerName: 'a11y-overflow-${DateTime.now().millisecondsSinceEpoch}',
        wrap: (child) => MaterialApp(home: Scaffold(body: child)),
      );

      final dom.Element region = prepared.getElementById('region');

      final SemanticsHandle handle = tester.ensureSemantics();
      try {
        await tester.pump();

        final SemanticsOwner semanticsOwner = tester.binding.pipelineOwner.semanticsOwner!;
        final SemanticsNode root = semanticsOwner.rootSemanticsNode!;

        final SemanticsNode? regionNodeBefore = _findSemanticsNodeWithLabel(root, 'Chat Messages');
        expect(regionNodeBefore, isNotNull);

        final SemanticsData before = regionNodeBefore!.getSemanticsData();
        expect(before.flagsCollection.hasImplicitScrolling, isTrue);
        expect(before.scrollExtentMax, isNotNull);
        expect(before.scrollExtentMax!, greaterThan(0.0));
        expect(before.scrollPosition, isNotNull);
        final double? posBefore = before.scrollPosition;

        // Programmatic scroll should update semantics scrollPosition.
        region.scrollTop = 200;
        await tester.pump();

        final SemanticsNode? regionNodeAfter = _findSemanticsNodeWithLabel(root, 'Chat Messages');
        expect(regionNodeAfter, isNotNull);
        final SemanticsData after = regionNodeAfter!.getSemanticsData();
        expect(after.scrollPosition, isNotNull);
        expect(after.scrollPosition!, greaterThan(0.0));
        if (posBefore != null) {
          expect(after.scrollPosition!, isNot(posBefore));
        }
      } finally {
        handle.dispose();
      }
    });

    testWidgets('overflow scroll hides offscreen nodes in semantics', (WidgetTester tester) async {
      final rows = List<String>.generate(
        80,
        (i) => '<div style="height: 20px; line-height: 20px;">Message ${i + 1}</div>',
      ).join();

      final html = '''
        <div id="region"
             role="region"
             aria-label="Chat Messages"
             tabindex="0"
             style="height: 100px; width: 200px; overflow-y: auto; border: 1px solid #000;">
          $rows
        </div>
      ''';

      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        html: '<body>$html</body>',
        controllerName: 'a11y-overflow-hidden-${DateTime.now().millisecondsSinceEpoch}',
        wrap: (child) => MaterialApp(home: Scaffold(body: child)),
      );

      final dom.Element region = prepared.getElementById('region');

      final SemanticsHandle handle = tester.ensureSemantics();
      try {
        // WebF may keep scheduling frames (e.g. internal callbacks); avoid
        // pumpAndSettle timeouts by pumping a small, fixed amount.
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 50));

        final SemanticsOwner semanticsOwner = tester.binding.pipelineOwner.semanticsOwner!;
        SemanticsNode root = semanticsOwner.rootSemanticsNode!;

        final SemanticsNode? msg1Before = _findSemanticsNodeWithLabel(root, 'Message 1');
        expect(msg1Before, isNotNull);
        expect(msg1Before!.getSemanticsData().flagsCollection.isHidden, isFalse);

        // Scroll to the bottom, pushing "Message 1" out of the viewport.
        region.scrollTop = region.scrollHeight;
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 50));

        root = semanticsOwner.rootSemanticsNode!;
        final SemanticsNode? msg1After = _findSemanticsNodeWithLabel(root, 'Message 1');
        expect(msg1After, isNotNull);
        expect(msg1After!.getSemanticsData().flagsCollection.isHidden, isTrue);
      } finally {
        handle.dispose();
      }
    });
  });
}
