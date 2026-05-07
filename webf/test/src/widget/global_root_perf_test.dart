/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */

// ignore_for_file: avoid_print

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:webf/html.dart';
import 'package:webf/webf.dart';

import '../../setup.dart';
import 'test_utils.dart';

/// Performance thresholds (ms). Adjust if hardware differs significantly.
const int _kRegistrationThresholdMs = 50;
const int _kListenerNotifyThresholdMs = 5;
const int _kLargeChildrenThresholdMs = 500;
const int _kCycleThresholdMs = 200;
const int _kMultiListenerThresholdMs = 10;

void main() {
  setUpAll(() {
    setupTest();
  });

  setUp(() {
    WebFControllerManager.instance.initialize(
      WebFControllerManagerConfig(
        maxAliveInstances: 5,
        maxAttachedInstances: 5,
        enableDevTools: false,
      ),
    );
  });

  tearDown(() async {
    await WebFControllerManager.instance.disposeAll();
    await Future.delayed(const Duration(milliseconds: 100));
  });

  // ---------------------------------------------------------------------------
  // 1. Registration / unregistration timing
  // ---------------------------------------------------------------------------
  group('GlobalRootElement - registration performance', () {
    testWidgets('connectedCallback registers within ${_kRegistrationThresholdMs}ms', (tester) async {
      // Measure time from DOM append to globalRoot being set.
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        html: '<div id="container"></div>',
      );

      final controller = prepared.controller;
      final sw = Stopwatch()..start();

      await tester.runAsync(() async {
        await controller.view.evaluateJavaScripts('''
          var gr = document.createElement('webf-global-root');
          document.body.appendChild(gr);
        ''');
        controller.view.document.updateStyleIfNeeded();
      });
      await tester.pump(const Duration(milliseconds: 50));

      sw.stop();
      expect(controller.view.globalRoot, isNotNull);

      print('[PERF] connectedCallback registration: ${sw.elapsedMilliseconds}ms');
      expect(sw.elapsedMilliseconds, lessThan(_kRegistrationThresholdMs),
          reason: 'Registration should complete within ${_kRegistrationThresholdMs}ms');
    });

    testWidgets('disconnectedCallback unregisters within ${_kRegistrationThresholdMs}ms', (tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        html: '<webf-global-root id="gr"></webf-global-root>',
      );

      final controller = prepared.controller;
      expect(controller.view.globalRoot, isNotNull);

      final sw = Stopwatch()..start();

      await tester.runAsync(() async {
        await controller.view.evaluateJavaScripts(
            'document.getElementById("gr").remove();');
        controller.view.document.updateStyleIfNeeded();
      });
      await tester.pump(const Duration(milliseconds: 50));

      sw.stop();
      expect(controller.view.globalRoot, isNull);

      print('[PERF] disconnectedCallback unregistration: ${sw.elapsedMilliseconds}ms');
      expect(sw.elapsedMilliseconds, lessThan(_kRegistrationThresholdMs),
          reason: 'Unregistration should complete within ${_kRegistrationThresholdMs}ms');
    });

    testWidgets('10 consecutive replacements complete within ${_kCycleThresholdMs}ms total', (tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        html: '<webf-global-root id="gr0"></webf-global-root>',
      );

      final controller = prepared.controller;
      final sw = Stopwatch()..start();

      for (int i = 1; i <= 10; i++) {
        await tester.runAsync(() async {
          await controller.view.evaluateJavaScripts('''
            var old = document.querySelector('webf-global-root');
            if (old) old.remove();
            var gr = document.createElement('webf-global-root');
            gr.id = 'gr$i';
            document.body.appendChild(gr);
          ''');
          controller.view.document.updateStyleIfNeeded();
        });
        await tester.pump(const Duration(milliseconds: 10));
      }

      sw.stop();
      expect(controller.view.globalRoot, isNotNull);

      print('[PERF] 10 consecutive replacements: ${sw.elapsedMilliseconds}ms total');
      expect(sw.elapsedMilliseconds, lessThan(_kCycleThresholdMs),
          reason: '10 replacements should complete within ${_kCycleThresholdMs}ms');
    });
  });

  // ---------------------------------------------------------------------------
  // 2. Listener notification performance
  // ---------------------------------------------------------------------------
  group('view_controller - listener notification performance', () {
    testWidgets('single listener notified within ${_kListenerNotifyThresholdMs}ms', (tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        html: '<div>no global root</div>',
      );

      final controller = prepared.controller;
      int notifyCount = 0;
      final sw = Stopwatch();

      controller.view.addGlobalRootListener(() {
        sw.stop();
        notifyCount++;
      });

      sw.start();
      await tester.runAsync(() async {
        await controller.view.evaluateJavaScripts('''
          var gr = document.createElement('webf-global-root');
          document.body.appendChild(gr);
        ''');
        controller.view.document.updateStyleIfNeeded();
      });
      await tester.pump(const Duration(milliseconds: 50));

      expect(notifyCount, greaterThan(0));
      print('[PERF] single listener notification latency: ${sw.elapsedMilliseconds}ms');
      expect(sw.elapsedMilliseconds, lessThan(_kListenerNotifyThresholdMs),
          reason: 'Listener should be notified within ${_kListenerNotifyThresholdMs}ms');
    });

    testWidgets('50 listeners all notified within ${_kMultiListenerThresholdMs}ms', (tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        html: '<div>no global root</div>',
      );

      final controller = prepared.controller;
      int notifyCount = 0;
      final listeners = <VoidCallback>[];

      for (int i = 0; i < 50; i++) {
        void l() => notifyCount++;
        listeners.add(l);
        controller.view.addGlobalRootListener(l);
      }

      final sw = Stopwatch()..start();

      await tester.runAsync(() async {
        await controller.view.evaluateJavaScripts('''
          var gr = document.createElement('webf-global-root');
          document.body.appendChild(gr);
        ''');
        controller.view.document.updateStyleIfNeeded();
      });
      await tester.pump(const Duration(milliseconds: 50));

      sw.stop();

      expect(notifyCount, equals(50));
      print('[PERF] 50 listeners notification: ${sw.elapsedMilliseconds}ms');
      expect(sw.elapsedMilliseconds, lessThan(_kMultiListenerThresholdMs),
          reason: '50 listeners should all be notified within ${_kMultiListenerThresholdMs}ms');

      for (final l in listeners) {
        controller.view.removeGlobalRootListener(l);
      }
    });

    testWidgets('add/remove 100 listeners has no memory leak (count stays 0 after remove)', (tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        html: '<div>no global root</div>',
      );

      final controller = prepared.controller;
      int notifyCount = 0;

      // Add and immediately remove 100 listeners
      for (int i = 0; i < 100; i++) {
        void l() => notifyCount++;
        controller.view.addGlobalRootListener(l);
        controller.view.removeGlobalRootListener(l);
      }

      await tester.runAsync(() async {
        await controller.view.evaluateJavaScripts('''
          var gr = document.createElement('webf-global-root');
          document.body.appendChild(gr);
        ''');
        controller.view.document.updateStyleIfNeeded();
      });
      await tester.pump(const Duration(milliseconds: 50));

      expect(notifyCount, equals(0),
          reason: 'All removed listeners should not be notified — no leak');
    });
  });

  // ---------------------------------------------------------------------------
  // 3. Child rendering performance
  // ---------------------------------------------------------------------------
  group('GlobalRootElement - child rendering performance', () {
    testWidgets('50 normal-flow children render within ${_kLargeChildrenThresholdMs}ms', (tester) async {
      final children = List.generate(
        50,
        (i) => '<div id="perf-child-$i" style="height:10px;width:100%;">item $i</div>',
      ).join('');

      final sw = Stopwatch()..start();

      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        html: '<webf-global-root>$children</webf-global-root>',
      );

      sw.stop();

      // Verify all children exist
      for (int i = 0; i < 50; i++) {
        final child = prepared.controller.view.document.getElementById(['perf-child-$i']);
        expect(child, isNotNull, reason: 'perf-child-$i should exist');
      }

      print('[PERF] 50 children initial render: ${sw.elapsedMilliseconds}ms');
      expect(sw.elapsedMilliseconds, lessThan(_kLargeChildrenThresholdMs),
          reason: '50 children should render within ${_kLargeChildrenThresholdMs}ms');
    });

    testWidgets('100 children appended dynamically within ${_kLargeChildrenThresholdMs}ms', (tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        html: '<webf-global-root id="gr"></webf-global-root>',
      );

      final controller = prepared.controller;
      final sw = Stopwatch()..start();

      await tester.runAsync(() async {
        // Append 100 children in a single JS call for efficiency
        await controller.view.evaluateJavaScripts('''
          var gr = document.getElementById('gr');
          var fragment = document.createDocumentFragment();
          for (var i = 0; i < 100; i++) {
            var div = document.createElement('div');
            div.id = 'dyn-child-' + i;
            div.style.height = '10px';
            fragment.appendChild(div);
          }
          gr.appendChild(fragment);
        ''');
        controller.view.document.updateStyleIfNeeded();
      });
      await tester.pump(const Duration(milliseconds: 100));

      sw.stop();

      // Spot-check a few children
      expect(controller.view.document.getElementById(['dyn-child-0']), isNotNull);
      expect(controller.view.document.getElementById(['dyn-child-99']), isNotNull);

      print('[PERF] 100 dynamic children append: ${sw.elapsedMilliseconds}ms');
      expect(sw.elapsedMilliseconds, lessThan(_kLargeChildrenThresholdMs),
          reason: '100 dynamic children should append within ${_kLargeChildrenThresholdMs}ms');
    });

    testWidgets('20 mixed-position children render within ${_kLargeChildrenThresholdMs}ms', (tester) async {
      // Mix of normal, fixed, absolute, sticky — exercises all PositionPlaceHolder paths
      final children = List.generate(20, (i) {
        final positions = ['static', 'fixed', 'absolute', 'sticky'];
        final pos = positions[i % 4];
        final extra = pos == 'sticky' ? 'top:0;' : pos == 'fixed' ? 'top:${i * 5}px;left:0;' : '';
        return '<div id="mix-$i" style="position:$pos;${extra}width:50px;height:20px;">$i</div>';
      }).join('');

      final sw = Stopwatch()..start();

      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        html: '<webf-global-root>$children</webf-global-root>',
      );

      sw.stop();

      expect(prepared.controller.view.globalRoot, isNotNull);
      print('[PERF] 20 mixed-position children render: ${sw.elapsedMilliseconds}ms');
      expect(sw.elapsedMilliseconds, lessThan(_kLargeChildrenThresholdMs),
          reason: '20 mixed-position children should render within ${_kLargeChildrenThresholdMs}ms');
    });
  });

  // ---------------------------------------------------------------------------
  // 4. High-frequency add/remove stability
  // ---------------------------------------------------------------------------
  group('GlobalRootElement - high-frequency stability', () {
    testWidgets('50 rapid add/remove cycles complete within ${_kCycleThresholdMs * 3}ms', (tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        html: '<div id="container"></div>',
      );

      final controller = prepared.controller;
      final sw = Stopwatch()..start();

      for (int i = 0; i < 50; i++) {
        await tester.runAsync(() async {
          await controller.view.evaluateJavaScripts('''
            var existing = document.querySelector('webf-global-root');
            if (existing) existing.remove();
            var gr = document.createElement('webf-global-root');
            document.body.appendChild(gr);
          ''');
          controller.view.document.updateStyleIfNeeded();
        });
        // Minimal pump — just enough to process microtasks
        await tester.pump(const Duration(milliseconds: 5));
      }

      sw.stop();
      expect(controller.view.globalRoot, isNotNull);

      print('[PERF] 50 rapid add/remove cycles: ${sw.elapsedMilliseconds}ms total');
      expect(sw.elapsedMilliseconds, lessThan(_kCycleThresholdMs * 3),
          reason: '50 cycles should complete within ${_kCycleThresholdMs * 3}ms');
    });

    testWidgets('repeated setGlobalRoot/removeGlobalRoot does not grow listener list', (tester) async {
      // Verify that the internal listener list does not grow unboundedly.
      // Each cycle does: remove (→ removeGlobalRoot notifies) + append (→ setGlobalRoot notifies).
      // So each cycle fires our listener exactly 2 times (or 1 on cycle 0 when there's nothing to remove).
      // The key invariant: the count must be IDENTICAL across all cycles after the first.
      // If the listener list grew, later cycles would show higher counts.
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        html: '<div>no global root</div>',
      );

      final controller = prepared.controller;
      final notifyCounts = <int>[];

      for (int cycle = 0; cycle < 5; cycle++) {
        int count = 0;
        void listener() => count++;
        controller.view.addGlobalRootListener(listener);

        await tester.runAsync(() async {
          await controller.view.evaluateJavaScripts('''
            var existing = document.querySelector('webf-global-root');
            if (existing) existing.remove();
            var gr = document.createElement('webf-global-root');
            document.body.appendChild(gr);
          ''');
          controller.view.document.updateStyleIfNeeded();
        });
        await tester.pump(const Duration(milliseconds: 30));

        notifyCounts.add(count);
        controller.view.removeGlobalRootListener(listener);
      }

      print('[PERF] listener counts per cycle: $notifyCounts');

      // cycle 0: no existing element → only setGlobalRoot fires → count == 1
      // cycle 1+: remove (removeGlobalRoot) + append (setGlobalRoot) → count == 2
      // If the listener list leaked, later cycles would show counts > 2.
      expect(notifyCounts[0], equals(1),
          reason: 'Cycle 0 has no prior element to remove, so only 1 notification');
      for (int i = 1; i < notifyCounts.length; i++) {
        expect(notifyCounts[i], equals(2),
            reason: 'Cycle $i should notify exactly 2 times (remove + set) — no listener leak');
      }
    });
  });

  // ---------------------------------------------------------------------------
  // 5. WebFGlobalRootView rebuild performance
  // ---------------------------------------------------------------------------
  group('WebFGlobalRootView - rebuild performance', () {
    testWidgets('globalRoot set by listener within one pump frame', (tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        html: '<div id="container"></div>',
      );

      final controller = prepared.controller;
      expect(controller.view.globalRoot, isNull);

      // Add global root while WebF tree is still mounted
      await tester.runAsync(() async {
        await controller.view.evaluateJavaScripts('''
          var gr = document.createElement('webf-global-root');
          document.body.appendChild(gr);
        ''');
        controller.view.document.updateStyleIfNeeded();
      });

      final sw = Stopwatch()..start();
      await tester.pump(const Duration(milliseconds: 16)); // ~1 frame at 60fps
      sw.stop();

      // globalRoot must be set — connectedCallback + listener fired correctly
      expect(controller.view.globalRoot, isNotNull);

      print('[PERF] globalRoot set after one pump frame: ${sw.elapsedMilliseconds}ms');
      expect(sw.elapsedMilliseconds, lessThan(100),
          reason: 'globalRoot should be set within one frame budget');
    });
  });
}
