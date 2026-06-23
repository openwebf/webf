/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 *
 * Repro for the hybrid-history "context not attached" bug.
 *
 * A single controller can back several simultaneously-mounted WebF route widgets
 * (the root `WebF` view plus `WebFRouterView` sub-routes on an inner Navigator,
 * as in the mini-program page). They all push/pop into one build-context stack.
 *
 * `popBuildContext` removes entries by `routePath` rather than by the specific
 * `BuildContext`, so unmounting one route deletes EVERY entry sharing that path —
 * including a sibling route that is still mounted. The stack ends up empty while
 * a route is still on screen, so `currentBuildContext` is null and
 * `HybridHistory` navigation throws "context not attached".
 */

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:webf/webf.dart';
import 'package:webf/launcher.dart';

import '../../setup.dart';
import '../foundation/mock_bundle.dart';

// Avoids the real Flutter attach which needs a live BuildContext.
class _TestWebFController extends WebFController {
  @override
  bool get isFlutterAttached => true;
  @override
  void attachToFlutter(BuildContext context) {}
  @override
  void detachFromFlutter(BuildContext? context) {}
}

class _FakeBuildContext extends Fake implements BuildContext {}

void main() {
  setUp(() {
    setupTest();
  });

  setUp(() {
    final manager = WebFControllerManager.instance;
    manager.disposeAll();
    manager.initialize(const WebFControllerManagerConfig(maxAliveInstances: 5, maxAttachedInstances: 3));
  });

  tearDown(() async {
    await WebFControllerManager.instance.disposeAll();
  });

  group('Build context stack', () {
    test('popping one route keeps a still-mounted sibling on the same path', () async {
      final controller = await WebFControllerManager.instance.addWithPreload(
        name: 'bcs-test',
        createController: () => _TestWebFController(),
        bundle: MockTimedBundle.fast(content: 'console.log("ok")'),
      );

      // Two distinct mounted route widgets sharing the controller, both on '/p2p'
      // (root WebF view + a re-pushed '/p2p' sub-route).
      final ctxRoot = _FakeBuildContext();
      final ctxSubRoute = _FakeBuildContext();

      controller!.pushNewBuildContext(context: ctxRoot, routePath: '/p2p', state: null);
      controller.pushNewBuildContext(context: ctxSubRoute, routePath: '/p2p', state: null);

      // The top sub-route unmounts and removes ITS entry.
      controller.popBuildContext(context: ctxSubRoute, routePath: '/p2p');

      // The root route is still mounted, so currentBuildContext must remain it.
      expect(controller.currentBuildContext, isNotNull,
          reason: 'popping a sibling route emptied the build-context stack');
      expect(controller.currentBuildContext?.context, same(ctxRoot),
          reason: 'popBuildContext removed the wrong entry (matched by path, not by BuildContext)');

      // Clear the remaining entry so controller disposal doesn't process the fake.
      controller.popBuildContext(context: ctxRoot, routePath: '/p2p');
      expect(controller.currentBuildContext, isNull);
    });

    testWidgets('getRootViewport returns null instead of throwing when the build context is dead',
        (WidgetTester tester) async {
      // Capture a real BuildContext, then remove it from the tree so its element
      // is torn down — like a FlutterBoost container pop. findRenderObject() on
      // such an element throws "Cannot get renderObject of inactive element".
      late BuildContext deadContext;
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Builder(builder: (c) {
            deadContext = c;
            return const SizedBox.shrink();
          }),
        ),
      );
      await tester.pumpWidget(const SizedBox.shrink());
      expect(deadContext.mounted, isFalse);

      late WebFController controller;
      await tester.runAsync(() async {
        controller = (await WebFControllerManager.instance.addWithPreload(
          name: 'gv-test',
          createController: () => _TestWebFController(),
          bundle: MockTimedBundle.fast(content: 'console.log("ok")'),
        ))!;
        await controller.controlledInitCompleter.future;
      });

      // Drive navigation/geometry through the now-dead build context.
      controller.pushNewBuildContext(context: deadContext, routePath: '/p2p', state: null);

      final el = controller.view.document.documentElement;
      expect(el, isNotNull);
      // Before the fix this threw; now it returns null for a dead context.
      expect(el!.getRootViewport(), isNull);

      controller.popBuildContext(context: deadContext, routePath: '/p2p');
    });
  });
}
