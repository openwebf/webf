/*
 * Tests for CDP DOM.documentUpdated events.
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

  group('CDP DOM.documentUpdated', () {
    setUp(() {
      ChromeDevToolsService.unifiedService.clearEventListenersForTest();
    });

    test('fires on full tree change fallback', () async {
      final controller = WebFController(
        viewportWidth: 320,
        viewportHeight: 640,
        bundle: WebFBundle.fromContent('<html><body>Test</body></html>'),
      );

      await controller.controlledInitCompleter.future;

      final events = <InspectorEvent>[];
      ChromeDevToolsService.unifiedService
          .addEventListenerForTest((InspectorEvent e) => events.add(e));

      // Wire fallback full-tree change hook to send DOM.documentUpdated
      controller.view.debugDOMTreeChanged = () {
        ChromeDevToolsService.unifiedService
            .sendEventToFrontend(DOMUpdatedEvent());
      };

      // Create a node and append to body
      final Pointer<NativeBindingObject> ptr = allocateNewBindingObject();
      controller.view.createElement(ptr, 'div');
      final Element el = controller.view.getBindingObject<Element>(ptr)!;
      final Element body = controller.view.document.documentElement!.querySelector(['body']) as Element;
      body.appendChild(el);

      // Remove node via bridge without devtoolsChildNodeRemoved set (falls back to debugDOMTreeChanged)
      controller.view.removeAttribute(ptr, 'irrelevant'); // ensure inited
      controller.view.devtoolsChildNodeRemoved = null; // explicit
      controller.view.removeNode(ptr);

      // Expect a DOM.documentUpdated event captured
      expect(events.whereType<DOMUpdatedEvent>().isNotEmpty, isTrue);

      await controller.dispose();
    });
  });
}

