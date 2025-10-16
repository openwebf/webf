/*
 * Copyright (C) 2025-present The WebF authors.
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

  group('CDP DOM attribute events', () {
    setUp(() {
      ChromeDevToolsService.unifiedService.clearEventListenersForTest();
    });

    test('attributeModified fires on Element.setAttribute', () async {
      final controller = WebFController(
        viewportWidth: 320,
        viewportHeight: 640,
        bundle: WebFBundle.fromContent('<html><body>Test</body></html>'),
      );

      await controller.controlledInitCompleter.future;

      final captured = <InspectorEvent>[];
      ChromeDevToolsService.unifiedService
          .addEventListenerForTest((InspectorEvent e) => captured.add(e));

      // Wire DevTools hooks directly to the unified service test channel.
      controller.view.devtoolsAttributeModified = (Element el, String name, String? value) {
        ChromeDevToolsService.unifiedService
            .sendEventToFrontend(DOMAttributeModifiedEvent(element: el, name: name, value: value));
      };

      // Create and attach an element
      final Pointer<NativeBindingObject> ptr = allocateNewBindingObject();
      controller.view.createElement(ptr, 'div');
      final Element el = controller.view.getBindingObject<Element>(ptr)!;

      final Element? body = controller.view.document.documentElement?.querySelector(['body']) as Element?;
      expect(body, isNotNull);
      body!.appendChild(el);

      // Set attribute and expect one event
      el.setAttribute('id', 'foo');

      expect(captured.length, 1);
      expect(captured.first, isA<DOMAttributeModifiedEvent>());
      final DOMAttributeModifiedEvent evt = captured.first as DOMAttributeModifiedEvent;
      expect(evt.name, 'id');
      expect(evt.value, 'foo');
      expect(evt.element, same(el));

      await controller.dispose();
    });

    test('attributeRemoved fires on Element.removeAttribute', () async {
      final controller = WebFController(
        viewportWidth: 320,
        viewportHeight: 640,
        bundle: WebFBundle.fromContent('<html><body>Test</body></html>'),
      );

      await controller.controlledInitCompleter.future;

      final captured = <InspectorEvent>[];
      ChromeDevToolsService.unifiedService
          .addEventListenerForTest((InspectorEvent e) => captured.add(e));

      controller.view.devtoolsAttributeRemoved = (Element el, String name) {
        ChromeDevToolsService.unifiedService
            .sendEventToFrontend(DOMAttributeRemovedEvent(element: el, name: name));
      };

      final Pointer<NativeBindingObject> ptr = allocateNewBindingObject();
      controller.view.createElement(ptr, 'div');
      final Element el = controller.view.getBindingObject<Element>(ptr)!;

      final Element? body = controller.view.document.documentElement?.querySelector(['body']) as Element?;
      expect(body, isNotNull);
      body!.appendChild(el);

      // Pre-set an attribute then remove it
      el.setAttribute('data-x', '1');

      controller.view.devtoolsAttributeModified = (Element el, String name, String? value) {
        ChromeDevToolsService.unifiedService
            .sendEventToFrontend(DOMAttributeModifiedEvent(element: el, name: name, value: value));
      };

      // Clear previously captured modified event if any
      captured.clear();

      el.removeAttribute('data-x');

      expect(captured.length, 1);
      expect(captured.first, isA<DOMAttributeRemovedEvent>());
      final DOMAttributeRemovedEvent evt = captured.first as DOMAttributeRemovedEvent;
      expect(evt.name, 'data-x');
      expect(evt.element, same(el));

      await controller.dispose();
    });

    test('no duplicate events when value unchanged', () async {
      final controller = WebFController(
        viewportWidth: 320,
        viewportHeight: 640,
        bundle: WebFBundle.fromContent('<html><body>Test</body></html>'),
      );

      await controller.controlledInitCompleter.future;

      int modifiedCount = 0;
      ChromeDevToolsService.unifiedService.addEventListenerForTest((InspectorEvent e) {
        if (e is DOMAttributeModifiedEvent) modifiedCount++;
      });

      controller.view.devtoolsAttributeModified = (Element el, String name, String? value) {
        ChromeDevToolsService.unifiedService
            .sendEventToFrontend(DOMAttributeModifiedEvent(element: el, name: name, value: value));
      };

      final Pointer<NativeBindingObject> ptr = allocateNewBindingObject();
      controller.view.createElement(ptr, 'div');
      final Element el = controller.view.getBindingObject<Element>(ptr)!;

      final Element? body = controller.view.document.documentElement?.querySelector(['body']) as Element?;
      body!.appendChild(el);

      el.setAttribute('role', 'button');
      el.setAttribute('role', 'button'); // unchanged, should not emit again

      expect(modifiedCount, 1);

      await controller.dispose();
    });

    test('bridge setAttribute emits a single attributeModified', () async {
      final controller = WebFController(
        viewportWidth: 320,
        viewportHeight: 640,
        bundle: WebFBundle.fromContent('<html><body>Test</body></html>'),
      );

      await controller.controlledInitCompleter.future;

      int modifiedCount = 0;
      ChromeDevToolsService.unifiedService.addEventListenerForTest((InspectorEvent e) {
        if (e is DOMAttributeModifiedEvent) modifiedCount++;
      });

      controller.view.devtoolsAttributeModified = (Element el, String name, String? value) {
        ChromeDevToolsService.unifiedService
            .sendEventToFrontend(DOMAttributeModifiedEvent(element: el, name: name, value: value));
      };

      final Pointer<NativeBindingObject> ptr = allocateNewBindingObject();
      controller.view.createElement(ptr, 'div');
      final Element el = controller.view.getBindingObject<Element>(ptr)!;

      final Element? body = controller.view.document.documentElement?.querySelector(['body']) as Element?;
      body!.appendChild(el);

      // Call through bridge, which forwards to Element.setAttribute. Should emit once.
      controller.view.setAttribute(ptr, 'data-bridge', '1');

      expect(modifiedCount, 1);

      await controller.dispose();
    });
  });
}

