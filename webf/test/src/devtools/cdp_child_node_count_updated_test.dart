/*
 * Tests for CDP DOM.childNodeCountUpdated events.
 */

import 'dart:ffi';

import 'package:flutter_test/flutter_test.dart';
import 'package:webf/devtools.dart';
import 'package:webf/foundation.dart';
import 'package:webf/launcher.dart';
import 'package:webf/src/bridge/native_types.dart';
import 'package:webf/dom.dart';

import '../../setup.dart';

void main() {
  setupTest();

  group('CDP DOM childNodeCountUpdated', () {
    setUp(() {
      ChromeDevToolsService.unifiedService.clearEventListenersForTest();
    });

    test('fires on child insertion and removal', () async {
      final controller = WebFController(
        viewportWidth: 320,
        viewportHeight: 640,
        bundle: WebFBundle.fromContent('<html><body>Test</body></html>'),
      );

      await controller.controlledInitCompleter.future;

      final events = <InspectorEvent>[];
      ChromeDevToolsService.unifiedService
          .addEventListenerForTest((InspectorEvent e) => events.add(e));

      // Wire minimal hooks to simulate DevTools behavior without running server
      controller.view.devtoolsChildNodeInserted = (Node parent, Node node, Node? previousSibling) {
        final count = parent.childNodes
            .where((c) => c is Element || (c is TextNode && c.data.trim().isNotEmpty))
            .length;
        ChromeDevToolsService.unifiedService.sendEventToFrontend(
            DOMChildNodeCountUpdatedEvent(node: parent, childNodeCount: count));
      };
      controller.view.devtoolsChildNodeRemoved = (Node parent, Node node) {
        final count = parent.childNodes
            .where((c) => c is Element || (c is TextNode && c.data.trim().isNotEmpty))
            .length;
        ChromeDevToolsService.unifiedService.sendEventToFrontend(
            DOMChildNodeCountUpdatedEvent(node: parent, childNodeCount: count));
      };

      // Create a parent <div> and attach to body (no DevTools event needed for this step)
      final Pointer<NativeBindingObject> parentPtr = allocateNewBindingObject();
      controller.view.createElement(parentPtr, 'div');
      final Element parentEl = controller.view.getBindingObject<Element>(parentPtr)!;
      final Element body = controller.view.document.documentElement!.querySelector(['body']) as Element;
      body.appendChild(parentEl);

      // Insert a first child via bridge to trigger DevTools hooks
      final Pointer<NativeBindingObject> child1Ptr = allocateNewBindingObject();
      controller.view.createElement(child1Ptr, 'span');
      controller.view.insertAdjacentNode(parentPtr, 'beforeend', child1Ptr);

      // Expect at least one count-updated event; the last should have count 1
      expect(events.whereType<DOMChildNodeCountUpdatedEvent>().isNotEmpty, isTrue);
      final DOMChildNodeCountUpdatedEvent last1 =
          events.whereType<DOMChildNodeCountUpdatedEvent>().last;
      expect(last1.childNodeCount, 1);

      // Insert a second child
      final Pointer<NativeBindingObject> child2Ptr = allocateNewBindingObject();
      controller.view.createElement(child2Ptr, 'span');
      controller.view.insertAdjacentNode(parentPtr, 'beforeend', child2Ptr);

      final DOMChildNodeCountUpdatedEvent last2 =
          events.whereType<DOMChildNodeCountUpdatedEvent>().last;
      expect(last2.childNodeCount, 2);

      // Remove one child
      controller.view.removeNode(child2Ptr);
      final DOMChildNodeCountUpdatedEvent last3 =
          events.whereType<DOMChildNodeCountUpdatedEvent>().last;
      expect(last3.childNodeCount, 1);

      await controller.dispose();
    });
  });
}
