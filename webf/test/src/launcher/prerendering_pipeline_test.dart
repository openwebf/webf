/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 *
 * Repro tests for prerendering-pipeline bugs (findings A and B).
 *
 * Finding A: `DOMContentLoaded` / `load` can fire during the prerender phase
 * (before the Flutter widget mounts), with geometry still 0. The mount-time
 * dispatch in `_loadingInPreRenderingMode` is then a no-op because of the
 * one-shot guard flags. The contract requires these events to fire on mount,
 * with real geometry.
 *
 * Finding B: a prerender timeout calls `completeError` on
 * `controllerPreRenderingCompleter`; the widget mount path awaits it without a
 * try/catch (and `mount()` calls `startForLoading()` fire-and-forget), so the
 * timeout surfaces as an unhandled exception.
 */

import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:webf/webf.dart';
import 'package:webf/dom.dart' as dom;

import '../../setup.dart';
import '../foundation/mock_bundle.dart';

void main() {
  setUp(() {
    setupTest();
  });

  setUp(() {
    final manager = WebFControllerManager.instance;
    manager.disposeAll();
    manager.initialize(const WebFControllerManagerConfig(
      maxAliveInstances: 5,
      maxAttachedInstances: 3,
      autoDisposeWhenLimitReached: true,
    ));
  });

  tearDown(() async {
    await WebFControllerManager.instance.disposeAll();
  });

  group('Prerendering pipeline', () {
    testWidgets('A: DOMContentLoaded/load fire AFTER the widget mounts (real geometry), not during prerender',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      // Ground truth for "has the WebF widget been mounted yet": flipped to true
      // immediately before we mount the WebF widget below.
      bool webfWidgetMounted = false;

      // Per-event: how many times it fired, and whether the WebF widget was
      // mounted when it first fired.
      int domContentLoadedCount = 0, loadCount = 0, resizeCount = 0, prerenderedCount = 0;
      bool? domContentLoadedAfterMount, loadAfterMount, resizeAfterMount, prerenderedAfterMount;

      final name = 'prerender-a-${DateTime.now().millisecondsSinceEpoch}';
      WebFController? controller;

      await tester.runAsync(() async {
        controller = await WebFControllerManager.instance.addWithPrerendering(
          name: name,
          createController: () => WebFController(
            viewportWidth: 360,
            viewportHeight: 640,
            onDOMContentLoaded: (c) {
              domContentLoadedCount++;
              domContentLoadedAfterMount ??= webfWidgetMounted;
            },
            onLoad: (c) {
              loadCount++;
              loadAfterMount ??= webfWidgetMounted;
            },
          ),
          bundle: WebFBundle.fromContent(
            '<html><body><div style="width:100px;height:100px;">hi</div></body></html>',
            url: 'test://$name/',
            contentType: htmlContentType,
          ),
        );
        await controller!.controlledInitCompleter.future;

        // resize and prerendered have no controller callback; listen on window.
        controller!.view.window.addEventListener(dom.EVENT_RESIZE, (dom.Event e) async {
          resizeCount++;
          resizeAfterMount ??= webfWidgetMounted;
        });
        controller!.view.window.addEventListener(dom.EVENT_PRERENDERED, (dom.Event e) async {
          prerenderedCount++;
          prerenderedAfterMount ??= webfWidgetMounted;
        });
      });

      // Simulate the embedder's UI ticking frames while WebF is prerendered but
      // not yet mounted. On a real device this is what lets the pre-mount
      // checkCompleted() post-frame callback run and dispatch the events early.
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(milliseconds: 50));
      await tester.pump(const Duration(milliseconds: 50));

      // Now mount the actual WebF widget. Drive the load using the same
      // interleaving of pump / runAsync / pumpFrames that WebFWidgetTestUtils uses.
      webfWidgetMounted = true;
      final webf = WebF.fromControllerName(controllerName: name);
      await tester.pumpWidget(webf);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.runAsync(() async {
        await controller!.controllerPreRenderingCompleter.future;
      });
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pumpFrames(webf, const Duration(milliseconds: 200));
      await tester.runAsync(() async {
        await controller!.controllerOnLoadCompleter.future;
      });
      await tester.pumpFrames(webf, const Duration(milliseconds: 200));

      // Characterize the full mount contract: resize -> DOMContentLoaded -> load
      // -> prerendered should all fire, and only after the widget is mounted.
      // ignore: avoid_print
      print('PRERENDER-CONTRACT '
          'resize(count=$resizeCount, afterMount=$resizeAfterMount) '
          'DOMContentLoaded(count=$domContentLoadedCount, afterMount=$domContentLoadedAfterMount) '
          'load(count=$loadCount, afterMount=$loadAfterMount) '
          'prerendered(count=$prerenderedCount, afterMount=$prerenderedAfterMount)');

      // Each contract event fires exactly once, only after mount (real geometry).
      expect(resizeCount, 1, reason: 'resize should fire exactly once at mount');
      expect(resizeAfterMount, isTrue, reason: 'resize fired before mount');
      expect(domContentLoadedCount, 1, reason: 'DOMContentLoaded should fire exactly once');
      expect(domContentLoadedAfterMount, isTrue,
          reason: 'DOMContentLoaded fired during prerender (before mount); geometry would be 0');
      expect(loadCount, 1, reason: 'load should fire exactly once');
      expect(loadAfterMount, isTrue, reason: 'load fired during prerender (before mount); geometry would be 0');
      expect(prerenderedCount, 1, reason: 'prerendered should fire exactly once at mount');
      expect(prerenderedAfterMount, isTrue, reason: 'prerendered fired before mount');
    });

    testWidgets('B: a prerender timeout does not raise an unhandled exception', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final hang = Completer<void>();
      addTearDown(() {
        if (!hang.isCompleted) hang.complete();
      });

      final name = 'prerender-b-${DateTime.now().millisecondsSinceEpoch}';
      final bundle = MockTimedBundle.controlled(
        completer: hang,
        content: '<html><body>hi</body></html>',
        contentType: htmlContentType,
        url: 'test://$name/',
      );

      // Kick off prerendering with a short timeout; never resolves -> times out.
      // Swallow the manager-level error so only the widget-mount path is observed.
      // ignore: unawaited_futures
      WebFControllerManager.instance
          .addWithPrerendering(
            name: name,
            createController: () => WebFController(viewportWidth: 360, viewportHeight: 640),
            bundle: bundle,
            timeout: const Duration(milliseconds: 200),
          )
          .catchError((_) => null);

      // Mount the widget while prerendering is still in-flight, so the mount
      // path (_loadingInPreRenderingMode) awaits the completer that will error.
      final webf = WebF.fromControllerName(controllerName: name);
      await tester.pumpWidget(webf);
      await tester.pump(const Duration(milliseconds: 100));

      // Advance past the 200ms prerender timeout.
      await tester.pump(const Duration(milliseconds: 250));
      await tester.pump(const Duration(milliseconds: 100));

      expect(tester.takeException(), isNull,
          reason: 'prerender timeout surfaced as an unhandled exception in the mount path');
    });

    testWidgets('C: an initial hybrid route is awaited at mount, not reported missing immediately',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      const route = '/modal_popup';
      final name = 'prerender-c-${DateTime.now().millisecondsSinceEpoch}';

      await tester.runAsync(() async {
        final controller = await WebFControllerManager.instance.addWithPrerendering(
          name: name,
          createController: () => WebFController(viewportWidth: 360, viewportHeight: 640),
          // The bundle does not register the $route hybrid router view, so the
          // route-load future stays pending (the JS app would register it shortly
          // after). The mount must wait for it rather than declaring it missing.
          bundle: WebFBundle.fromContent(
            '<html><body><div>home</div></body></html>',
            url: 'test://$name/',
            contentType: htmlContentType,
          ),
        );
        await controller!.controlledInitCompleter.future;
      });

      final webf = WebF.fromControllerName(controllerName: name, initialRoute: route);
      await tester.pumpWidget(webf);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      await tester.pumpFrames(webf, const Duration(milliseconds: 300));

      // While the route is still loading, WebF must NOT render the "route not
      // found" error. In prerender mode (evaluated == true) the FutureBuilder
      // guard used to skip waiting and build the root view immediately.
      expect(find.textContaining('was not found'), findsNothing,
          reason: 'prerender reported the initial route missing before it finished loading');
      expect(tester.takeException(), isNull,
          reason: 'building the route-not-found error widget threw before the route finished loading');

      // Unmount and flush the pending route-load (20s) and perf (10s) fallback
      // timers so the test does not fail on pending timers. The route is never
      // registered here (the JS app would register it), so we just let them lapse
      // with the widget detached.
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(seconds: 21));
    });
  });
}
