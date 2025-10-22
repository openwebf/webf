import 'package:flutter_test/flutter_test.dart';
import 'package:webf/dom.dart' as dom;
import 'package:webf/src/css/css_perf.dart';
import 'package:webf/src/foundation/debug_flags.dart';

import '../../setup.dart';
import '../widget/test_utils.dart';

void main() {
  setupTest();

  group('Matched rules memoization', () {
    setUp(() {
      DebugFlags.enableCssPerf = true;
      DebugFlags.enableCssMemoization = true;
      CSSPerf.reset();
    });

    tearDown(() {
      CSSPerf.reset();
      DebugFlags.enableCssPerf = false;
      DebugFlags.enableCssMemoization = false;
    });

    testWidgets('reuses cached rules when selector keys stay stable',
        (WidgetTester tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        html: '''
        <style>
          .btn { color: blue; }
          [data-state="open"] { font-weight: bold; }
        </style>
        <div id="target" class="btn" data-state="open"></div>
        ''',
      );

      final dom.Element element =
          prepared.document.getElementById(['target']) as dom.Element;

      await tester.runAsync(() async {
        prepared.document
            .markElementStyleDirty(element, reason: 'initial memo test');
        prepared.document.flushStyle();
      });

      expect(CSSPerf.memoMisses, greaterThan(0));
      final int hitsAfterFirstFlush = CSSPerf.memoHits;
      final int missesAfterFirstFlush = CSSPerf.memoMisses;

      await tester.runAsync(() async {
        prepared.document
            .markElementStyleDirty(element, reason: 'repeat memo test');
        prepared.document.flushStyle();
      });

      expect(CSSPerf.memoHits, greaterThan(hitsAfterFirstFlush));
      expect(CSSPerf.memoMisses, equals(missesAfterFirstFlush));
    });

    testWidgets('busts cache when selector-relevant attribute value changes',
        (WidgetTester tester) async {
      DebugFlags.enableDomLogs = true;
      DebugFlags.enableCssTrace = true;
      DebugFlags.enableCssPerf = true;
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        html: '''
        <style>
          [data-state="open"] { color: red; }
        </style>
        <div id="target" data-state="open"></div>
        ''',
      );

      final dom.Element element =
          prepared.document.getElementById(['target']) as dom.Element;

      await tester.runAsync(() async {
        prepared.document
            .markElementStyleDirty(element, reason: 'prime memo cache');
        prepared.document.flushStyle();
      });

      CSSPerf.reset();

      await tester.runAsync(() async {
        element.setAttribute('data-state', 'closed');
        prepared.document
            .markElementStyleDirty(element, reason: 'state change');
        prepared.document.flushStyle();
      });

      expect(CSSPerf.memoMisses, greaterThanOrEqualTo(1));
      expect(CSSPerf.memoHits, anyOf(equals(0), equals(1)));
    });
  });
}
