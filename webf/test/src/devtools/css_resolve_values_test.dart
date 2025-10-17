/*
 * Tests for CSS.resolveValues support.
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

class _TestCSSModule extends InspectCSSModule {
  Map<String, dynamic>? lastResult;
  _TestCSSModule(DevToolsService s) : super(s);

  @override
  void sendToFrontend(int? id, JSONEncodable? result) {
    lastResult = result?.toJson().cast<String, dynamic>();
  }

  @override
  void sendEventToFrontend(InspectorEvent event) {}
}

void main() {
  setupTest();

  group('CSS.resolveValues', () {
    test('resolves simple values with propertyName for a node', () async {
      final controller = WebFController(
        viewportWidth: 320,
        viewportHeight: 640,
        bundle: WebFBundle.fromContent('<html><body>Test</body></html>'),
      );
      await controller.controlledInitCompleter.future;

      final dev = _FakeDevToolsService();
      dev.initWithContext(WebFControllerDebuggingAdapter(controller));
      final css = _TestCSSModule(dev);

      // Create an element as context and append to body
      final Pointer<NativeBindingObject> ptr = allocateNewBindingObject();
      controller.view.createElement(ptr, 'div');
      final Element el = controller.view.getBindingObject<Element>(ptr)!;
      final Element body = controller.view.document.documentElement!.querySelector(['body']) as Element;
      body.appendChild(el);

      final nodeId = controller.view.forDevtoolsNodeId(el);

      // Opacity
      css.handleResolveValues(1, {
        'nodeId': nodeId,
        'propertyName': 'opacity',
        'values': ['0.3']
      });
      var result = css.lastResult;
      expect(result, isNotNull);
      var results = (result!['results'] as List).cast<String>();
      expect(results.length, 1);
      expect(results.first, contains('0.3'));

      // Width
      css.handleResolveValues(2, {
        'nodeId': nodeId,
        'propertyName': 'width',
        'values': ['10px']
      });
      result = css.lastResult;
      expect(result, isNotNull);
      results = (result!['results'] as List).cast<String>();
      expect(results.length, 1);
      expect(results.first, contains('px'));

      await controller.dispose();
    });

    test('resolves calc() with propertyName', () async {
      final controller = WebFController(
        viewportWidth: 320,
        viewportHeight: 640,
        bundle: WebFBundle.fromContent('<html><body>Test</body></html>'),
      );
      await controller.controlledInitCompleter.future;

      final dev = _FakeDevToolsService();
      dev.initWithContext(WebFControllerDebuggingAdapter(controller));
      final css = _TestCSSModule(dev);

      final Pointer<NativeBindingObject> ptr = allocateNewBindingObject();
      controller.view.createElement(ptr, 'div');
      final Element el = controller.view.getBindingObject<Element>(ptr)!;
      final Element body = controller.view.document.documentElement!.querySelector(['body']) as Element;
      body.appendChild(el);

      final nodeId = controller.view.forDevtoolsNodeId(el);
      css.handleResolveValues(3, {
        'nodeId': nodeId,
        'propertyName': 'width',
        'values': ['calc(1px + 2px)']
      });
      final result = css.lastResult;
      expect(result, isNotNull);
      final results = (result!['results'] as List).cast<String>();
      expect(results.length, 1);
      expect(results.first, contains('3px'));

      await controller.dispose();
    });

    test('resolves 1em relative to element font-size', () async {
      final controller = WebFController(
        viewportWidth: 320,
        viewportHeight: 640,
        bundle: WebFBundle.fromContent('<html><body>Test</body></html>'),
      );
      await controller.controlledInitCompleter.future;

      final dev = _FakeDevToolsService();
      dev.initWithContext(WebFControllerDebuggingAdapter(controller));
      final css = _TestCSSModule(dev);

      final Pointer<NativeBindingObject> ptr = allocateNewBindingObject();
      controller.view.createElement(ptr, 'div');
      final Element el = controller.view.getBindingObject<Element>(ptr)!;
      final Element body = controller.view.document.documentElement!.querySelector(['body']) as Element;
      body.appendChild(el);

      // Set font-size to a known value and force recalc
      el.setInlineStyle('fontSize', '20px');
      el.recalculateStyle(rebuildNested: false, forceRecalculate: true);
      el.ownerDocument.updateStyleIfNeeded();

      final nodeId = controller.view.forDevtoolsNodeId(el);
      css.handleResolveValues(4, {
        'nodeId': nodeId,
        'propertyName': 'width',
        'values': ['1em']
      });
      final result = css.lastResult;
      expect(result, isNotNull);
      final results = (result!['results'] as List).cast<String>();
      expect(results.length, 1);
      expect(results.first, contains('20px'));

      await controller.dispose();
    });
  });
}

class _FakeDevToolsService extends DevToolsService {}
