/*
 * Tests for CDP DOM.childNodeInserted events.
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

  group('CDP DOM.childNodeInserted', () {
    setUp(() {
      ChromeDevToolsService.unifiedService.clearEventListenersForTest();
    });

    test('reports parent/prev/node on append and subsequent append', () async {
      final controller = WebFController(
        viewportWidth: 320,
        viewportHeight: 640,
        bundle: WebFBundle.fromContent('<html><body>Test</body></html>'),
      );

      await controller.controlledInitCompleter.future;

      final events = <InspectorEvent>[];
      ChromeDevToolsService.unifiedService
          .addEventListenerForTest((InspectorEvent e) => events.add(e));

      // Wire insertion hook to forward CDP event without running server
      controller.view.devtoolsChildNodeInserted = (Node parent, Node node, Node? previousSibling) {
        ChromeDevToolsService.unifiedService.sendEventToFrontend(
          DOMChildNodeInsertedEvent(parent: parent, node: node, previousSibling: previousSibling),
        );
      };

      // Prepare parent and body
      final Pointer<NativeBindingObject> parentPtr = allocateNewBindingObject();
      controller.view.createElement(parentPtr, 'div');
      final Element parentEl = controller.view.getBindingObject<Element>(parentPtr)!;
      final Element body = controller.view.document.documentElement!.querySelector(['body']) as Element;
      body.appendChild(parentEl);

      // Append first child
      final Pointer<NativeBindingObject> child1Ptr = allocateNewBindingObject();
      controller.view.createElement(child1Ptr, 'span');
      controller.view.insertAdjacentNode(parentPtr, 'beforeend', child1Ptr);

      // Last event should be childNodeInserted with previousNodeId=0
      final DOMChildNodeInsertedEvent e1 =
          events.whereType<DOMChildNodeInsertedEvent>().last;
      expect(e1.params?.toJson()['parentNodeId'], parentEl.ownerView.forDevtoolsNodeId(parentEl));
      expect(e1.params?.toJson()['previousNodeId'], 0);

      // Append second child
      final Pointer<NativeBindingObject> child2Ptr = allocateNewBindingObject();
      controller.view.createElement(child2Ptr, 'span');
      controller.view.insertAdjacentNode(parentPtr, 'beforeend', child2Ptr);

      // Now previousNodeId should be first child's id
      final DOMChildNodeInsertedEvent e2 =
          events.whereType<DOMChildNodeInsertedEvent>().last;
      final child1 = controller.view.getBindingObject<Element>(child1Ptr)!;
      expect(e2.params?.toJson()['previousNodeId'], child1.ownerView.forDevtoolsNodeId(child1));

      await controller.dispose();
    });
  });
}

