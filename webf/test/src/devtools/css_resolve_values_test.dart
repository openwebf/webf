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
    test('resolves simple declarations for a node', () async {
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

      css.handleResolveValues(1, {
        'nodeId': nodeId,
        'declarations': [
          {'name': 'opacity', 'value': '0.3'},
          {'name': 'width', 'value': '10px'},
        ]
      });

      final result = css.lastResult;
      expect(result, isNotNull);
      final resolved = (result!['resolved'] as List).cast<Map>();
      expect(resolved.length, 2);
      final opacity = resolved.firstWhere((m) => m['name'] == 'opacity')['value'] as String;
      expect(opacity, contains('0.3'));
      final width = resolved.firstWhere((m) => m['name'] == 'width')['value'] as String;
      expect(width, contains('px'));

      await controller.dispose();
    });

    test('parses style text and resolves', () async {
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
      css.handleResolveValues(2, {
        'nodeId': nodeId,
        'text': 'height: 24px; opacity: 0.5;'
      });

      final result = css.lastResult;
      expect(result, isNotNull);
      final resolved = (result!['resolved'] as List).cast<Map>();
      expect(resolved.length, greaterThanOrEqualTo(2));
      final height = resolved.firstWhere((m) => m['name'] == 'height')['value'] as String;
      expect(height, contains('24'));
      final opacity = resolved.firstWhere((m) => m['name'] == 'opacity')['value'] as String;
      expect(opacity, contains('0.5'));

      await controller.dispose();
    });
  });
}

class _FakeDevToolsService extends DevToolsService {}
