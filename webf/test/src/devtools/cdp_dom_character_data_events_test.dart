/*
 * Tests for CDP DOM.characterDataModified events.
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

  group('CDP DOM characterData events', () {
    setUp(() {
      ChromeDevToolsService.unifiedService.clearEventListenersForTest();
    });

    test('characterDataModified fires on TextNode.data', () async {
      final controller = WebFController(
        viewportWidth: 320,
        viewportHeight: 640,
        bundle: WebFBundle.fromContent('<html><body>Test</body></html>'),
      );

      await controller.controlledInitCompleter.future;

      final captured = <InspectorEvent>[];
      ChromeDevToolsService.unifiedService
          .addEventListenerForTest((InspectorEvent e) => captured.add(e));

      controller.view.devtoolsCharacterDataModified = (TextNode node) {
        ChromeDevToolsService.unifiedService
            .sendEventToFrontend(DOMCharacterDataModifiedEvent(node: node));
      };

      final Pointer<NativeBindingObject> textPtr = allocateNewBindingObject();
      controller.view.createTextNode(textPtr, '');
      final TextNode text = controller.view.getBindingObject<TextNode>(textPtr)!;

      final Element? body = controller.view.document.documentElement?.querySelector(['body']) as Element?;
      expect(body, isNotNull);
      body!.appendChild(text);

      text.data = 'Hello World';

      expect(captured.length, 1);
      expect(captured.first, isA<DOMCharacterDataModifiedEvent>());
      final DOMCharacterDataModifiedEvent evt = captured.first as DOMCharacterDataModifiedEvent;
      expect(evt.node, same(text));

      await controller.dispose();
    });

    test('bridge setAttribute data emits a single characterDataModified', () async {
      final controller = WebFController(
        viewportWidth: 320,
        viewportHeight: 640,
        bundle: WebFBundle.fromContent('<html><body>Test</body></html>'),
      );

      await controller.controlledInitCompleter.future;

      int count = 0;
      ChromeDevToolsService.unifiedService.addEventListenerForTest((InspectorEvent e) {
        if (e is DOMCharacterDataModifiedEvent) count++;
      });

      controller.view.devtoolsCharacterDataModified = (TextNode node) {
        ChromeDevToolsService.unifiedService
            .sendEventToFrontend(DOMCharacterDataModifiedEvent(node: node));
      };

      final Pointer<NativeBindingObject> textPtr = allocateNewBindingObject();
      controller.view.createTextNode(textPtr, 'A');
      final TextNode text = controller.view.getBindingObject<TextNode>(textPtr)!;

      final Element? body = controller.view.document.documentElement?.querySelector(['body']) as Element?;
      body!.appendChild(text);

      // Set via bridge; should emit once (setter emits, bridge does not double fire)
      controller.view.setAttribute(textPtr, 'data', 'B');

      expect(count, 1);

      await controller.dispose();
    });
  });
}

