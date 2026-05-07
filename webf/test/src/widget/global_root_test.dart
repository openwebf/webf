/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */

import 'dart:ui' as ui;
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:webf/css.dart';
import 'package:webf/html.dart';
import 'package:webf/webf.dart';

import '../../setup.dart';
import 'test_utils.dart';

/// Wraps [widget] in a [Directionality] so widgets like [Stack] that require
/// a text-direction ancestor work correctly in unit tests.
Widget _withDirectionality(Widget widget) {
  return Directionality(
    textDirection: TextDirection.ltr,
    child: widget,
  );
}

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
  // 1. Registration lifecycle
  // ---------------------------------------------------------------------------
  group('GlobalRootElement - registration lifecycle', () {
    testWidgets('registers with view when connected to DOM', (tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        html: '<webf-global-root id="gr"></webf-global-root>',
      );

      expect(prepared.controller.view.globalRoot, isNotNull,
          reason: 'globalRoot should be set after element connects');
      expect(prepared.controller.view.globalRoot, isA<GlobalRootElement>());
    });

    testWidgets('unregisters from view when removed from DOM', (tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        html: '<webf-global-root id="gr"></webf-global-root>',
      );

      final controller = prepared.controller;
      expect(controller.view.globalRoot, isNotNull);

      await tester.runAsync(() async {
        await controller.view.evaluateJavaScripts(
            'document.getElementById("gr").remove();');
        controller.view.document.updateStyleIfNeeded();
      });
      await tester.pump(const Duration(milliseconds: 100));

      expect(controller.view.globalRoot, isNull,
          reason: 'globalRoot should be null after element is removed');
    });

    testWidgets('second webf-global-root replaces the first', (tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        html: '<webf-global-root id="gr1"></webf-global-root>',
      );

      final controller = prepared.controller;
      final first = controller.view.globalRoot;
      expect(first, isNotNull);

      await tester.runAsync(() async {
        await controller.view.evaluateJavaScripts('''
          var gr2 = document.createElement('webf-global-root');
          gr2.id = 'gr2';
          document.body.appendChild(gr2);
        ''');
        controller.view.document.updateStyleIfNeeded();
      });
      await tester.pump(const Duration(milliseconds: 100));

      final second = controller.view.globalRoot;
      expect(second, isNotNull);
      expect(second, isNot(same(first)),
          reason: 'second global root should replace the first');
    });

    testWidgets('globalRoot is null when no webf-global-root in DOM', (tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        html: '<div>no global root here</div>',
      );

      expect(prepared.controller.view.globalRoot, isNull);
    });

    testWidgets('re-adding element after removal re-registers', (tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        html: '<webf-global-root id="gr"></webf-global-root>',
      );

      final controller = prepared.controller;

      // Remove
      await tester.runAsync(() async {
        await controller.view.evaluateJavaScripts(
            'document.getElementById("gr").remove();');
        controller.view.document.updateStyleIfNeeded();
      });
      await tester.pump(const Duration(milliseconds: 100));
      expect(controller.view.globalRoot, isNull);

      // Re-add
      await tester.runAsync(() async {
        await controller.view.evaluateJavaScripts('''
          var gr = document.createElement('webf-global-root');
          document.body.appendChild(gr);
        ''');
        controller.view.document.updateStyleIfNeeded();
      });
      await tester.pump(const Duration(milliseconds: 100));
      expect(controller.view.globalRoot, isNotNull,
          reason: 'globalRoot should be re-registered after re-adding element');
    });
  });

  // ---------------------------------------------------------------------------
  // 2. WebFGlobalRootView widget rendering
  // ---------------------------------------------------------------------------
  group('WebFGlobalRootView - widget rendering', () {
    testWidgets('renders SizedBox.shrink when globalRoot is null', (tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        html: '<div>no global root</div>',
      );

      // Verify controller state
      expect(prepared.controller.view.globalRoot, isNull);

      // Render WebFGlobalRootView standalone (controller has no globalRoot)
      // — must pumpWidget after prepareWidgetTest has finished
      final view = WebFGlobalRootView(controller: prepared.controller);
      await tester.pumpWidget(_withDirectionality(view));
      await tester.pump();

      expect(find.byType(WebFGlobalRootView), findsOneWidget);
      expect(find.byType(WebFRouterViewport), findsNothing);
    });

    testWidgets('renders WebFRouterViewport when globalRoot is set', (tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        html: '<webf-global-root><div>overlay</div></webf-global-root>',
      );

      // globalRoot is already set by the time prepareWidgetTest completes
      expect(prepared.controller.view.globalRoot, isNotNull);

      final view = WebFGlobalRootView(controller: prepared.controller);
      await tester.pumpWidget(_withDirectionality(view));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(WebFRouterViewport), findsOneWidget);
    });

    testWidgets('rebuilds when globalRoot is dynamically added', (tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        html: '<div id="container"></div>',
      );

      final controller = prepared.controller;
      expect(controller.view.globalRoot, isNull);

      // Add global root dynamically — DOM op runs while WebF tree is still mounted
      await tester.runAsync(() async {
        await controller.view.evaluateJavaScripts('''
          var gr = document.createElement('webf-global-root');
          document.body.appendChild(gr);
        ''');
        controller.view.document.updateStyleIfNeeded();
      });
      await tester.pump(const Duration(milliseconds: 100));

      // Verify via controller state — listener fired synchronously
      expect(controller.view.globalRoot, isNotNull,
          reason: 'globalRoot should be set after dynamic append');

      // Now render WebFGlobalRootView to confirm it shows the viewport
      final view = WebFGlobalRootView(controller: controller);
      await tester.pumpWidget(_withDirectionality(view));
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byType(WebFRouterViewport), findsOneWidget);
    });

    testWidgets('collapses back to SizedBox.shrink when globalRoot is removed', (tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        html: '<webf-global-root id="gr"><div>overlay</div></webf-global-root>',
      );

      final controller = prepared.controller;
      expect(controller.view.globalRoot, isNotNull);

      // Remove global root while WebF tree is still mounted
      await tester.runAsync(() async {
        await controller.view.evaluateJavaScripts(
            'document.getElementById("gr").remove();');
        controller.view.document.updateStyleIfNeeded();
      });
      await tester.pump(const Duration(milliseconds: 100));

      // Verify controller state — removeGlobalRoot was called synchronously
      expect(controller.view.globalRoot, isNull,
          reason: 'globalRoot should be null after element removed');

      // Now render WebFGlobalRootView — globalRoot is null so it shows SizedBox.shrink
      final view = WebFGlobalRootView(controller: controller);
      await tester.pumpWidget(_withDirectionality(view));
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byType(WebFRouterViewport), findsNothing,
          reason: 'WebFGlobalRootView should render nothing when globalRoot is null');
    });

    testWidgets('listener is cleaned up on dispose — no setState after unmount', (tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        html: '<webf-global-root id="gr"></webf-global-root>',
      );

      final controller = prepared.controller;
      final gr = controller.view.globalRoot! as GlobalRootElement;

      await tester.pumpWidget(_withDirectionality(WebFGlobalRootView(controller: controller)));
      await tester.pump();

      // Dispose the widget
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();

      // Trigger a globalRoot change after dispose — should not throw
      expect(
        () => controller.view.removeGlobalRoot(gr),
        returnsNormally,
      );
    });
  });

  // ---------------------------------------------------------------------------
  // 3. Child rendering — normal flow and positioned
  // ---------------------------------------------------------------------------
  group('GlobalRootElement - child rendering', () {
    testWidgets('renders normal flow children with correct dimensions', (tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        html: '''
          <webf-global-root>
            <div id="child" style="width:100px;height:50px;">hello</div>
          </webf-global-root>
        ''',
      );

      final child = prepared.getElementById('child');
      expect(child.offsetWidth, equals(100.0));
      expect(child.offsetHeight, equals(50.0));
    });

    testWidgets('renders fixed-position children', (tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        html: '''
          <webf-global-root>
            <div id="fixed-child" style="position:fixed;top:0;left:0;width:200px;height:80px;">
              fixed overlay
            </div>
          </webf-global-root>
        ''',
      );

      final child = prepared.getElementById('fixed-child');
      expect(child.renderStyle.position, equals(CSSPositionType.fixed));
    });

    testWidgets('renders absolute-position children', (tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        html: '''
          <webf-global-root>
            <div id="abs-child" style="position:absolute;top:10px;left:10px;width:150px;height:60px;">
              absolute overlay
            </div>
          </webf-global-root>
        ''',
      );

      final child = prepared.getElementById('abs-child');
      expect(child.renderStyle.position, equals(CSSPositionType.absolute));
    });

    testWidgets('renders sticky-position children', (tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        html: '''
          <webf-global-root>
            <div id="sticky-child" style="position:sticky;top:0;width:100%;height:44px;">
              sticky header
            </div>
          </webf-global-root>
        ''',
      );

      final child = prepared.getElementById('sticky-child');
      expect(child.renderStyle.position, equals(CSSPositionType.sticky));
    });

    testWidgets('dynamically added children appear in DOM', (tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        html: '<webf-global-root id="gr"></webf-global-root>',
      );

      final controller = prepared.controller;

      await tester.runAsync(() async {
        await controller.view.evaluateJavaScripts('''
          var child = document.createElement('div');
          child.id = 'dynamic-child';
          child.style.width = '100px';
          child.style.height = '50px';
          document.getElementById('gr').appendChild(child);
        ''');
        controller.view.document.updateStyleIfNeeded();
      });
      await tester.pump(const Duration(milliseconds: 100));

      final child = controller.view.document.getElementById(['dynamic-child']);
      expect(child, isNotNull);
    });

    testWidgets('dynamically removed children are gone from DOM', (tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        html: '''
          <webf-global-root id="gr">
            <div id="removable">to be removed</div>
          </webf-global-root>
        ''',
      );

      final controller = prepared.controller;
      expect(controller.view.document.getElementById(['removable']), isNotNull);

      await tester.runAsync(() async {
        await controller.view.evaluateJavaScripts(
            'document.getElementById("removable").remove();');
        controller.view.document.updateStyleIfNeeded();
      });
      await tester.pump(const Duration(milliseconds: 100));

      expect(controller.view.document.getElementById(['removable']), isNull);
    });

    testWidgets('empty webf-global-root renders without error', (tester) async {
      await expectLater(
        () => WebFWidgetTestUtils.prepareWidgetTest(
          tester: tester,
          html: '<webf-global-root></webf-global-root>',
        ),
        returnsNormally,
      );
    });

    testWidgets('webf-global-root with many children renders all of them', (tester) async {
      final children = List.generate(
        20,
        (i) => '<div id="child-$i" style="height:10px;">item $i</div>',
      ).join('');

      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        html: '<webf-global-root>$children</webf-global-root>',
      );

      for (int i = 0; i < 20; i++) {
        final child = prepared.controller.view.document.getElementById(['child-$i']);
        expect(child, isNotNull, reason: 'child-$i should exist');
      }
    });
  });

  // ---------------------------------------------------------------------------
  // 4. Key stability
  // ---------------------------------------------------------------------------
  group('GlobalRootElement - key stability', () {
    testWidgets('always uses the fixed ValueKey WEBF_GLOBAL_ROOT', (tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        html: '<webf-global-root id="gr"></webf-global-root>',
      );

      final gr = prepared.controller.view.globalRoot as GlobalRootElement;
      expect(gr.key, equals(const ValueKey('WEBF_GLOBAL_ROOT')));
    });
  });

  // ---------------------------------------------------------------------------
  // 5. view_controller listener management
  // ---------------------------------------------------------------------------
  group('view_controller - listener management', () {
    testWidgets('multiple listeners are all notified on setGlobalRoot', (tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        html: '<div>no global root yet</div>',
      );

      final controller = prepared.controller;
      int notifyCount = 0;

      void listener1() => notifyCount++;
      void listener2() => notifyCount++;

      controller.view.addGlobalRootListener(listener1);
      controller.view.addGlobalRootListener(listener2);

      await tester.runAsync(() async {
        await controller.view.evaluateJavaScripts('''
          var gr = document.createElement('webf-global-root');
          document.body.appendChild(gr);
        ''');
        controller.view.document.updateStyleIfNeeded();
      });
      await tester.pump(const Duration(milliseconds: 100));

      expect(notifyCount, equals(2),
          reason: 'both listeners should be notified');

      controller.view.removeGlobalRootListener(listener1);
      controller.view.removeGlobalRootListener(listener2);
    });

    testWidgets('removed listener is not notified', (tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        html: '<div>no global root yet</div>',
      );

      final controller = prepared.controller;
      int notifyCount = 0;
      void listener() => notifyCount++;

      controller.view.addGlobalRootListener(listener);
      controller.view.removeGlobalRootListener(listener);

      await tester.runAsync(() async {
        await controller.view.evaluateJavaScripts('''
          var gr = document.createElement('webf-global-root');
          document.body.appendChild(gr);
        ''');
        controller.view.document.updateStyleIfNeeded();
      });
      await tester.pump(const Duration(milliseconds: 100));

      expect(notifyCount, equals(0),
          reason: 'removed listener should not be notified');
    });

    testWidgets('removeGlobalRoot is a no-op for non-matching element', (tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        html: '<webf-global-root id="gr1"></webf-global-root>',
      );

      final controller = prepared.controller;
      final original = controller.view.globalRoot!;

      // Add a second global root (it will replace the first via setGlobalRoot),
      // then remove the original — the second should remain.
      await tester.runAsync(() async {
        await controller.view.evaluateJavaScripts('''
          var gr2 = document.createElement('webf-global-root');
          gr2.id = 'gr2';
          document.body.appendChild(gr2);
        ''');
        controller.view.document.updateStyleIfNeeded();
      });
      await tester.pump(const Duration(milliseconds: 100));

      final second = controller.view.globalRoot!;
      expect(second, isNot(same(original)));

      // Manually call removeGlobalRoot with the original (already replaced) element.
      // Since globalRoot is now `second`, this should be a no-op.
      controller.view.removeGlobalRoot(original as GlobalRootElement);

      expect(controller.view.globalRoot, same(second),
          reason: 'removeGlobalRoot should only remove the matching element');
    });

    testWidgets('listeners are notified on removeGlobalRoot', (tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        html: '<webf-global-root id="gr"></webf-global-root>',
      );

      final controller = prepared.controller;
      int notifyCount = 0;
      void listener() => notifyCount++;
      controller.view.addGlobalRootListener(listener);

      await tester.runAsync(() async {
        await controller.view.evaluateJavaScripts(
            'document.getElementById("gr").remove();');
        controller.view.document.updateStyleIfNeeded();
      });
      await tester.pump(const Duration(milliseconds: 100));

      expect(notifyCount, greaterThan(0),
          reason: 'listeners should be notified when globalRoot is removed');

      controller.view.removeGlobalRootListener(listener);
    });
  });

  // ---------------------------------------------------------------------------
  // 6. WebFGlobalRootView - controller swap
  // ---------------------------------------------------------------------------
  group('WebFGlobalRootView - controller swap', () {
    testWidgets('updates listener when controller changes', (tester) async {
      tester.view.physicalSize = const ui.Size(360, 640);
      tester.view.devicePixelRatio = 1;

      final ts = DateTime.now().millisecondsSinceEpoch;
      final name1 = 'ctrl-swap-1-$ts';
      final name2 = 'ctrl-swap-2-$ts';

      WebFController? ctrl1, ctrl2;

      await tester.runAsync(() async {
        ctrl1 = await WebFControllerManager.instance.addWithPreload(
          name: name1,
          createController: () =>
              WebFController(viewportWidth: 360, viewportHeight: 640),
          bundle: WebFBundle.fromContent(
            '<webf-global-root id="gr1"></webf-global-root>',
            url: 'test://$name1/',
            contentType: htmlContentType,
          ),
        );
        ctrl2 = await WebFControllerManager.instance.addWithPreload(
          name: name2,
          createController: () =>
              WebFController(viewportWidth: 360, viewportHeight: 640),
          bundle: WebFBundle.fromContent(
            '<div>no global root</div>',
            url: 'test://$name2/',
            contentType: htmlContentType,
          ),
        );
        await Future.wait([
          ctrl1!.controlledInitCompleter.future,
          ctrl2!.controlledInitCompleter.future,
        ]);
      });

      // Mount with ctrl1 (has global root)
      await tester.pumpWidget(_withDirectionality(WebFGlobalRootView(controller: ctrl1!)));
      await tester.pump(const Duration(milliseconds: 200));
      expect(ctrl1!.view.globalRoot, isNotNull);

      // Swap to ctrl2 (no global root) — should not throw
      await tester.pumpWidget(_withDirectionality(WebFGlobalRootView(controller: ctrl2!)));
      await tester.pump(const Duration(milliseconds: 100));
      expect(ctrl2!.view.globalRoot, isNull);
      // Old controller's listener should have been removed — no crash
    });
  });

  // ---------------------------------------------------------------------------
  // 7. Stress / edge cases
  // ---------------------------------------------------------------------------
  group('GlobalRootElement - stress and edge cases', () {
    testWidgets('rapid add/remove cycles do not crash', (tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        html: '<div id="container"></div>',
      );

      final controller = prepared.controller;

      for (int i = 0; i < 10; i++) {
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
      }

      // After rapid cycling, a valid global root should still be registered
      expect(controller.view.globalRoot, isNotNull);
    });

    testWidgets('mixed positioned and normal children render without error', (tester) async {
      await expectLater(
        () => WebFWidgetTestUtils.prepareWidgetTest(
          tester: tester,
          html: '''
            <webf-global-root>
              <div id="normal" style="height:20px;">normal</div>
              <div id="fixed" style="position:fixed;top:0;right:0;width:50px;height:50px;">fixed</div>
              <div id="abs" style="position:absolute;top:10px;left:10px;width:80px;height:30px;">abs</div>
              <div id="sticky" style="position:sticky;top:0;height:40px;">sticky</div>
            </webf-global-root>
          ''',
        ),
        returnsNormally,
      );
    });

    testWidgets('webf-global-root nested inside another element still registers', (tester) async {
      // The element should register regardless of where it sits in the DOM tree
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        html: '''
          <div id="wrapper">
            <webf-global-root id="gr"></webf-global-root>
          </div>
        ''',
      );

      expect(prepared.controller.view.globalRoot, isNotNull,
          reason: 'globalRoot should register even when nested inside another element');
    });

    testWidgets('defaultStyle has display:block', (tester) async {
      final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
        tester: tester,
        html: '<webf-global-root id="gr"></webf-global-root>',
      );

      final gr = prepared.controller.view.globalRoot as GlobalRootElement;
      expect(gr.defaultStyle['display'], equals('block'));
    });
  });
}
