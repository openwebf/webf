/*
 * Tests for CDP DOM.setChildNodes events (seeding children list).
 */

import 'dart:ffi';

import 'package:flutter_test/flutter_test.dart';
import 'package:webf/devtools.dart';
import 'package:webf/foundation.dart';
import 'package:webf/launcher.dart';
import 'package:webf/src/bridge/native_types.dart';
import 'package:webf/dom.dart';
import 'package:webf/src/devtools/cdp_service/debugging_context.dart';

import '../../setup.dart';

void main() {
  setupTest();

  group('CDP DOM.setChildNodes (seed)', () {
    setUp(() {
      // Clear prior listeners and seeded state by issuing a documentUpdated before capturing
      ChromeDevToolsService.unifiedService.clearEventListenersForTest();
      ChromeDevToolsService.unifiedService.sendEventToFrontend(DOMUpdatedEvent());
    });

    test('emitted on first child insertion when parent not seeded', () async {
      final controller = WebFController(
        viewportWidth: 320,
        viewportHeight: 640,
        bundle: WebFBundle.fromContent('<html><body>Test</body></html>'),
      );

      await controller.controlledInitCompleter.future;

      // Initialize DevTools service so that insertion hooks are active and seeding logic runs
      final dev = ChromeDevToolsService();
      dev.initWithContext(WebFControllerDebuggingAdapter(controller));

      final events = <InspectorEvent>[];
      ChromeDevToolsService.unifiedService
          .addEventListenerForTest((InspectorEvent e) => events.add(e));

      // Create a parent <div> and attach to body via bridge (so hooks run)
      final Pointer<NativeBindingObject> parentPtr = allocateNewBindingObject();
      controller.view.createElement(parentPtr, 'div');
      final Element parentEl = controller.view.getBindingObject<Element>(parentPtr)!;
      final Element body = controller.view.document.documentElement!.querySelector(['body']) as Element;
      controller.view.insertAdjacentNode(body.pointer!, 'beforeend', parentPtr);

      // Insert first child; service should seed with DOM.setChildNodes for the parent
      final Pointer<NativeBindingObject> childPtr = allocateNewBindingObject();
      controller.view.createElement(childPtr, 'span');
      controller.view.insertAdjacentNode(parentPtr, 'beforeend', childPtr);

      // Find the latest DOM.setChildNodes for parent
      final parentId = controller.view.forDevtoolsNodeId(parentEl);
      final setEvents = events.whereType<DOMSetChildNodesEvent>().toList();
      expect(setEvents.isNotEmpty, isTrue);
      final DOMSetChildNodesEvent last = setEvents.last;
      expect(last.params?.toJson()['parentId'], parentId);

      final nodes = (last.params?.toJson()['nodes'] as List).cast<Map>();
      expect(nodes.length, greaterThanOrEqualTo(1));
      // Ensure the inserted child is included
      final childEl = controller.view.getBindingObject<Element>(childPtr)!;
      final childId = controller.view.forDevtoolsNodeId(childEl);
      expect(nodes.any((m) => m['nodeId'] == childId), isTrue);

      await controller.dispose();
    });
  });
}

