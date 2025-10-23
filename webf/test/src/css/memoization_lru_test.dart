import 'package:flutter_test/flutter_test.dart';
import 'package:webf/dom.dart' as dom;
import 'package:webf/src/css/css_perf.dart';
import 'package:webf/src/foundation/debug_flags.dart';

import '../../setup.dart';
import '../widget/test_utils.dart';

void main() {
  setupTest();

  group('Matched rules memoization LRU', () {
    setUp(() {
      DebugFlags.enableCssPerf = true;
      DebugFlags.enableCssMemoization = true;
      // Ensure element setters do not perform immediate recalculation so each
      // test step yields exactly one style recompute during flush.
      DebugFlags.enableCssBatchRecalc = true;
      CSSPerf.reset();
    });

    tearDown(() {
      CSSPerf.reset();
      DebugFlags.enableCssPerf = false;
      DebugFlags.enableCssMemoization = false;
      DebugFlags.enableCssBatchRecalc = false;
    });

    testWidgets('retains recent entries when within capacity', (WidgetTester tester) async {
      DebugFlags.cssMatchedRulesCacheCapacity = 4;

      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        html: '''
          <style>
            .a { color: red }
            .b { color: green }
            .c { color: blue }
            .d { color: purple }
          </style>
          <div id="target" class="a"></div>
        '''
      );

      final dom.Element el = prepared.document.getElementById(['target']) as dom.Element;

      Future<void> switchClassAndFlush(String cls, String reason) async {
        el.className = cls;
        // When batching is disabled, mark dirty explicitly to ensure a flush
        // recalculates this element. When enabled, setter already marks dirty.
        if (!DebugFlags.enableCssBatchRecalc) {
          prepared.document.markElementStyleDirty(el, reason: reason);
        }
        prepared.document.flushStyle();
      }

      await tester.runAsync(() async {
        CSSPerf.reset();
        // Avoid reusing the pre-cached initial 'a' fingerprint; use distinct new ones.
        await switchClassAndFlush('b', 'prime b');
        await switchClassAndFlush('c', 'prime c');
        await switchClassAndFlush('d', 'prime d');
      });

      final int firstPassMisses = CSSPerf.memoMisses;
      final int firstPassHits = CSSPerf.memoHits;
      final int firstPassEvict = CSSPerf.memoEvictions;

      // 3 distinct fingerprints inserted (b,c,d), within capacity=4: no eviction expected.
      expect(firstPassMisses, greaterThanOrEqualTo(3));
      expect(firstPassHits, equals(0));
      expect(firstPassEvict, equals(0));

      await tester.runAsync(() async {
        await switchClassAndFlush('b', 'repeat b');
        await switchClassAndFlush('c', 'repeat c');
        await switchClassAndFlush('d', 'repeat d');
      });

      expect(CSSPerf.memoHits, greaterThanOrEqualTo(3));
      // Misses should not increase if cache retained entries.
      expect(CSSPerf.memoMisses, equals(firstPassMisses));
      // Still no eviction expected.
      expect(CSSPerf.memoEvictions, equals(firstPassEvict));
    });

    testWidgets('evicts oldest when capacity exceeded', (WidgetTester tester) async {
      DebugFlags.cssMatchedRulesCacheCapacity = 2;

      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        html: '''
          <style>
            .a { color: red }
            .b { color: green }
            .c { color: blue }
            .d { color: purple }
          </style>
          <div id="target" class="a"></div>
        '''
      );

      final dom.Element el = prepared.document.getElementById(['target']) as dom.Element;

      Future<void> switchClassAndFlush(String cls, String reason) async {
        el.className = cls;
        if (!DebugFlags.enableCssBatchRecalc) {
          prepared.document.markElementStyleDirty(el, reason: reason);
        }
        prepared.document.flushStyle();
      }

      await tester.runAsync(() async {
        CSSPerf.reset();
        // Avoid pre-cached 'a'; generate 3 unique entries with capacity 2 to cause evictions.
        await switchClassAndFlush('b', 'prime b'); // miss
        await switchClassAndFlush('c', 'prime c'); // miss
        await switchClassAndFlush('d', 'prime d'); // miss + eviction of 'b'
        await switchClassAndFlush('b', 'revisit b'); // miss (b was evicted)
      });

      expect(CSSPerf.memoHits, equals(0));
      expect(CSSPerf.memoMisses, greaterThanOrEqualTo(4));
      // At least two evictions likely: inserting 'd' then 'b' again at capacity 2.
      expect(CSSPerf.memoEvictions, greaterThanOrEqualTo(2));
    });
  });
}
