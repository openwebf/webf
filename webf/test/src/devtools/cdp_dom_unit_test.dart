/*
 * Unit-style tests calling CDP modules directly (no WebSocket server)
 */

import 'dart:async';
import 'dart:ffi';

import 'package:flutter_test/flutter_test.dart';
import 'package:webf/bridge.dart';
import 'package:webf/devtools.dart';
import 'package:webf/dom.dart' as dom;
import 'package:webf/launcher.dart';
import 'package:webf/src/devtools/cdp_service/debugging_context.dart';

import '../../setup.dart';
import '../widget/test_utils.dart';

class _TestDevToolsService extends DevToolsService {}

dynamic _deepToJson(dynamic v) {
  if (v is JSONEncodable) {
    return _deepToJson(v.toJson());
  }
  if (v is Map) {
    return v.map((k, val) => MapEntry(k, _deepToJson(val)));
  }
  if (v is List) {
    return v.map((e) => _deepToJson(e)).toList();
  }
  return v;
}

class _DOMProbe extends InspectDOMModule {
  _DOMProbe(DevToolsService s) : super(s);
  Map<int?, Map<String, dynamic>?> lastResults = {};
  final List<InspectorEvent> events = [];

  @override
  void receiveFromFrontend(int? id, String method, Map<String, dynamic>? params) {
    if (method == 'requestChildNodes') {
      final ctx = devtoolsService.context;
      if (ctx == null) {
        sendToFrontend(id, JSONEncodableMap({}));
        return;
      }
      final int? frontendNodeId = params?['nodeId'];
      if (frontendNodeId == null) {
        sendToFrontend(id, JSONEncodableMap({}));
        return;
      }
      final targetId = ctx.getTargetIdByNodeId(frontendNodeId);
      if (targetId == null) {
        sendToFrontend(id, JSONEncodableMap({}));
        return;
      }
      final dom.Node? parent = ctx.getBindingObject(Pointer.fromAddress(targetId)) as dom.Node?;
      if (parent == null) {
        sendToFrontend(id, JSONEncodableMap({}));
        return;
      }
      final children = <Map>[];
      for (final child in parent.childNodes) {
        if (child is dom.Element || (child is dom.TextNode && child.data.trim().isNotEmpty)) {
          children.add(InspectorNode(child).toJson());
        }
      }
      // Emit setChildNodes as the ChromeDevToolsService path would.
      final pId = ctx.forDevtoolsNodeId(parent);
      sendEventToFrontend(DOMSetChildNodesEvent(parentId: pId, nodes: children));
      sendToFrontend(id, JSONEncodableMap({}));
      return;
    }
    super.receiveFromFrontend(id, method, params);
  }

  @override
  void sendToFrontend(int? id, JSONEncodable? result) {
    if (result == null) {
      lastResults[id] = null;
      return;
    }
    final raw = result.toJson();
    final ser = _deepToJson(raw);
    lastResults[id] = ser is Map ? Map<String, dynamic>.from(ser as Map) : null;
  }

  @override
  void sendEventToFrontend(InspectorEvent event) {
    events.add(event);
  }
}

class _CSSProbe extends InspectCSSModule {
  _CSSProbe(DevToolsService s) : super(s);
  Map<int?, Map<String, dynamic>?> lastResults = {};

  @override
  void sendToFrontend(int? id, JSONEncodable? result) {
    if (result == null) {
      lastResults[id] = null;
      return;
    }
    final raw = result.toJson();
    final ser = _deepToJson(raw);
    lastResults[id] = ser is Map ? Map<String, dynamic>.from(ser as Map) : null;
  }
}

void _hookIncrementalDomEvents(DevToolsService svc, _DOMProbe domProbe) {
  final ctx = svc.context!;
  ctx.debugChildNodeInserted = (parent, node, previousSibling) {
    domProbe.sendEventToFrontend(
        DOMChildNodeInsertedEvent(parent: parent, node: node, previousSibling: previousSibling));
  };
  ctx.debugChildNodeRemoved = (parent, node) {
    domProbe.sendEventToFrontend(DOMChildNodeRemovedEvent(parent: parent, node: node));
  };
  ctx.debugAttributeModified = (element, name, value) {
    domProbe.sendEventToFrontend(
        DOMAttributeModifiedEvent(element: element, name: name, value: value));
  };
  ctx.debugAttributeRemoved = (element, name) {
    domProbe.sendEventToFrontend(DOMAttributeRemovedEvent(element: element, name: name));
  };
  ctx.debugCharacterDataModified = (textNode) {
    domProbe.sendEventToFrontend(DOMCharacterDataModifiedEvent(node: textNode));
  };
}

void main() {
  setUpAll(() {
    setupTest();
  });

  setUp(() async {
    // Disable the unified service; we won't use it in these tests
    WebFControllerManager.instance.initialize(const WebFControllerManagerConfig(
      enableDevTools: false,
    ));
  });

  tearDown(() async {
    WebFControllerManager.instance.disposeAll();
    await Future.delayed(const Duration(milliseconds: 50));
  });

  testWidgets('DOM.getDocument returns root structure (no WebSocket)', (tester) async {
    final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
      tester: tester,
      controllerName: 'dom-unit-doc',
      html: '<html><body><div id="box" style="width:100px;height:50px">hi</div></body></html>',
    );

    final svc = _TestDevToolsService();
    svc.initWithContext(WebFControllerDebuggingAdapter(prepared.controller));

    // Replace DOM module with probe to capture outputs
    final inspector = svc.uiInspector!;
    final domProbe = _DOMProbe(svc);
    inspector.moduleRegistrar['DOM'] = domProbe;
    // Enable the module to accept commands
    domProbe.invoke(0, 'enable', {});

    // Invoke DOM.getDocument directly
    domProbe.invoke(1, 'getDocument', {});
    final res = domProbe.lastResults[1];
    expect(res, isNotNull);
    final root = (res!['root']) as Map;
    expect(root['nodeName'], '#document');
    expect((root['children'] as List).isNotEmpty, isTrue);
  });

  testWidgets('DOM.getBoxModel for element with size', (tester) async {
    final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
      tester: tester,
      controllerName: 'dom-unit-box',
      html: '<html><body><div id="box" style="width:120px;height:60px;margin:10px;padding:5px;border:1px solid #000">X</div></body></html>',
    );

    final svc = _TestDevToolsService();
    svc.initWithContext(WebFControllerDebuggingAdapter(prepared.controller));
    final inspector = svc.uiInspector!;
    final domProbe = _DOMProbe(svc);
    inspector.moduleRegistrar['DOM'] = domProbe;
    domProbe.invoke(0, 'enable', {});

    // Resolve nodeId via view mapping
    final el = prepared.document.getElementById(['box'])!;
    final nodeId = prepared.controller.view.forDevtoolsNodeId(el);

    // Ask for box model
    domProbe.invoke(2, 'getBoxModel', {'nodeId': nodeId});
    final res = domProbe.lastResults[2];
    expect(res, isNotNull);
    final model = (res!['model']) as Map?;
    expect(model, isNotNull);
    expect(model!['width'], 120);
    expect(model['height'], 60);
  });

  testWidgets('CSS inline set and get', (tester) async {
    final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
      tester: tester,
      controllerName: 'css-unit-inline',
      html: '<html><body><div id="box" style="width:100px;height:50px">X</div></body></html>',
    );

    final svc = _TestDevToolsService();
    svc.initWithContext(WebFControllerDebuggingAdapter(prepared.controller));
    final inspector = svc.uiInspector!;
    final cssProbe = _CSSProbe(svc);
    inspector.moduleRegistrar['CSS'] = cssProbe;
    cssProbe.invoke(0, 'enable', {});

    final el = prepared.document.getElementById(['box'])!;
    final nodeId = prepared.controller.view.forDevtoolsNodeId(el);

    // Read inline styles
    cssProbe.invoke(3, 'getInlineStylesForNode', {'nodeId': nodeId});
    final before = cssProbe.lastResults[3]!;
    expect(before['inlineStyle'], isNotNull);

    // Update inline via setStyleTexts
    cssProbe.invoke(4, 'setStyleTexts', {
      'edits': [
        {
          'styleSheetId': 'inline:$nodeId',
          'text': 'width: 200px; height: 60px;'
        }
      ]
    });
    // Allow layout to catch up
    await tester.pump(const Duration(milliseconds: 16));

    // Verify computed style reflects the change
    cssProbe.invoke(5, 'getComputedStyleForNode', {'nodeId': nodeId});
    final computed = cssProbe.lastResults[5]!;
    final list = (computed['computedStyle'] as List).cast<Map>();
    bool hasWidth = list.any((p) => p['name'] == 'width' && (p['value'] as String).contains('200'));
    bool hasHeight = list.any((p) => p['name'] == 'height' && (p['value'] as String).contains('60'));
    expect(hasWidth, isTrue);
    expect(hasHeight, isTrue);

    // DOM-side width reflects too
    expect(el.offsetWidth, 200.0);
    expect(el.offsetHeight, 60.0);
  });

  testWidgets('DOM.getOuterHTML returns markup', (tester) async {
    final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
      tester: tester,
      controllerName: 'dom-unit-outer',
      html: '<html><body><div id="x" class="c">T</div></body></html>',
    );

    final svc = _TestDevToolsService();
    svc.initWithContext(WebFControllerDebuggingAdapter(prepared.controller));
    final inspector = svc.uiInspector!;
    final domProbe = _DOMProbe(svc);
    inspector.moduleRegistrar['DOM'] = domProbe;
    domProbe.invoke(0, 'enable', {});

    final el = prepared.document.getElementById(['x'])!;
    final nodeId = prepared.controller.view.forDevtoolsNodeId(el);

    domProbe.invoke(6, 'getOuterHTML', {'nodeId': nodeId});
    final res = domProbe.lastResults[6]!;
    final html = res['outerHTML'] as String;
    expect(html.contains('<div'), isTrue);
    expect(html.contains('class="c"'), isTrue);
  });

  testWidgets('DOM.requestChildNodes seeds setChildNodes (adapter path)', (tester) async {
    final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
      tester: tester,
      controllerName: 'dom-child-nodes',
      html: '<html><body><div id="p"><span>A</span><span>B</span><!-- c --></div></body></html>',
    );

    final svc = _TestDevToolsService();
    svc.initWithContext(WebFControllerDebuggingAdapter(prepared.controller));
    final inspector = svc.uiInspector!;
    final domProbe = _DOMProbe(svc);
    inspector.moduleRegistrar['DOM'] = domProbe;
    domProbe.invoke(0, 'enable', {});

    final parent = prepared.document.getElementById(['p'])!;
    final nodeId = prepared.controller.view.forDevtoolsNodeId(parent);

    // Request child nodes; our probe emits DOM.setChildNodes
    domProbe.invoke(20, 'requestChildNodes', {'nodeId': nodeId, 'depth': 1});

    // Find the emitted setChildNodes event
    final evt = domProbe.events.firstWhere((e) => e.method == 'DOM.setChildNodes');
    final params = evt.toJson()['params'] as Map;
    expect(params['parentId'], nodeId);
    final nodes = (params['nodes'] as List);
    // Expect two span children (non-whitespace text nodes may also appear depending on whitespace)
    final localNames = nodes.map((n) => (n as Map)['localName']).where((v) => v != null).toList();
    expect(localNames.contains('span'), isTrue);
  });

  testWidgets('Incremental DOM: childNodeInserted + removed + attribute + text events', (tester) async {
    final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
      tester: tester,
      controllerName: 'dom-inc-events',
      html: '<html><body><div id="host">H<span id="t">X</span></div></body></html>',
    );

    final svc = _TestDevToolsService();
    svc.initWithContext(WebFControllerDebuggingAdapter(prepared.controller));
    final inspector = svc.uiInspector!;
    final domProbe = _DOMProbe(svc);
    inspector.moduleRegistrar['DOM'] = domProbe;
    domProbe.invoke(0, 'enable', {});
    _hookIncrementalDomEvents(svc, domProbe);

    final doc = prepared.document;
    final host = doc.getElementById(['host'])!;

    final view = prepared.controller.view;
    // Insert new child via view to trigger callbacks
    final ctx = BindingContext(view, view.contextId, allocateNewBindingObject());
    final child = doc.createElement('div', ctx);
    child.setAttribute('id', 'ins');
    view.insertAdjacentNode(host.pointer!, 'beforeend', child.pointer!);

    // Modify attribute via view
    view.setAttribute(child.pointer!, 'data', '1');
    view.removeAttribute(child.pointer!, 'data');

    // Modify text node via view
    final t = doc.getElementById(['t'])!.firstChild as dom.TextNode;
    view.setAttribute(t.pointer!, 'data', 'Y');

    // Remove node via view
    view.removeNode(child.pointer!);

    // Validate captured events
    final methods = domProbe.events.map((e) => e.method).toList();
    expect(methods.contains('DOM.childNodeInserted'), isTrue);
    expect(methods.contains('DOM.attributeModified'), isTrue);
    expect(methods.contains('DOM.attributeRemoved'), isTrue);
    expect(methods.contains('DOM.characterDataModified'), isTrue);
    expect(methods.contains('DOM.childNodeRemoved'), isTrue);

    // Inspect first insert event payload
    final insertEvt = domProbe.events.firstWhere((e) => e.method == 'DOM.childNodeInserted');
    final insertJson = insertEvt.toJson();
    expect((insertJson['params'] as Map)['node'], isNotNull);
    expect(((insertJson['params'] as Map)['node'] as Map)['localName'], 'div');
  });

  testWidgets('DOM.setAttributeValue updates attribute', (tester) async {
    final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
      tester: tester,
      controllerName: 'dom-attr-set',
      html: '<html><body><div id="box">T</div></body></html>',
    );

    final svc = _TestDevToolsService();
    svc.initWithContext(WebFControllerDebuggingAdapter(prepared.controller));
    final inspector = svc.uiInspector!;
    final domProbe = _DOMProbe(svc);
    inspector.moduleRegistrar['DOM'] = domProbe;
    domProbe.invoke(0, 'enable', {});

    final el = prepared.document.getElementById(['box'])!;
    final nodeId = prepared.controller.view.forDevtoolsNodeId(el);
    domProbe.invoke(7, 'setAttributeValue', {'nodeId': nodeId, 'name': 'data-test', 'value': 'ok'});
    expect(el.getAttribute('data-test'), 'ok');
  });

  testWidgets('DOM.setAttributesAsText replaces attributes', (tester) async {
    final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
      tester: tester,
      controllerName: 'dom-attr-text',
      html: '<html><body><div id="old" data-x="1">T</div></body></html>',
    );

    final svc = _TestDevToolsService();
    svc.initWithContext(WebFControllerDebuggingAdapter(prepared.controller));
    final inspector = svc.uiInspector!;
    final domProbe = _DOMProbe(svc);
    inspector.moduleRegistrar['DOM'] = domProbe;
    domProbe.invoke(0, 'enable', {});

    final el = prepared.document.getElementById(['old'])!;
    final nodeId = prepared.controller.view.forDevtoolsNodeId(el);
    domProbe.invoke(8, 'setAttributesAsText', {
      'nodeId': nodeId,
      // Parser only supports \w+ names; use underscore instead of hyphen
      'text': 'id="renamed" class="foo" data_a="1"'
    });
    // After replacement, the element id changes
    final renamed = prepared.document.getElementById(['renamed']);
    expect(renamed, isNotNull);
    expect(renamed!.getAttribute('class'), 'foo');
    expect(renamed.getAttribute('data_a'), '1');
  });

  testWidgets('DOM.removeNode removes element', (tester) async {
    final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
      tester: tester,
      controllerName: 'dom-remove',
      html: '<html><body><div id="p"><span id="c">X</span></div></body></html>',
    );

    final svc = _TestDevToolsService();
    svc.initWithContext(WebFControllerDebuggingAdapter(prepared.controller));
    final inspector = svc.uiInspector!;
    final domProbe = _DOMProbe(svc);
    inspector.moduleRegistrar['DOM'] = domProbe;
    domProbe.invoke(0, 'enable', {});

    final child = prepared.document.getElementById(['c'])!;
    final parent = prepared.document.getElementById(['p'])!;
    final nodeId = prepared.controller.view.forDevtoolsNodeId(child);
    domProbe.invoke(9, 'removeNode', {'nodeId': nodeId});
    expect(parent.firstChild, isNot(child));
    expect(prepared.document.getElementById(['c']), isNull);
  });

  testWidgets('DOM.setNodeValue changes TextNode', (tester) async {
    final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
      tester: tester,
      controllerName: 'dom-nodevalue',
      html: '<html><body><span id="t">X</span></body></html>',
    );

    final svc = _TestDevToolsService();
    svc.initWithContext(WebFControllerDebuggingAdapter(prepared.controller));
    final inspector = svc.uiInspector!;
    final domProbe = _DOMProbe(svc);
    inspector.moduleRegistrar['DOM'] = domProbe;
    domProbe.invoke(0, 'enable', {});

    final span = prepared.document.getElementById(['t'])!;
    final text = span.firstChild as dom.TextNode;
    final textNodeId = prepared.controller.view.forDevtoolsNodeId(text);
    domProbe.invoke(10, 'setNodeValue', {'nodeId': textNodeId, 'value': 'Hello'});
    expect(text.data, 'Hello');
  });

  testWidgets('DOM.pushNodesByBackendIdsToFrontend maps to nodeIds', (tester) async {
    final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
      tester: tester,
      controllerName: 'dom-push-backend',
      html: '<html><body><div id="a">A</div><div id="b">B</div></body></html>',
    );

    final svc = _TestDevToolsService();
    svc.initWithContext(WebFControllerDebuggingAdapter(prepared.controller));
    final inspector = svc.uiInspector!;
    final domProbe = _DOMProbe(svc);
    inspector.moduleRegistrar['DOM'] = domProbe;
    domProbe.invoke(0, 'enable', {});

    final a = prepared.document.getElementById(['a'])!;
    final b = prepared.document.getElementById(['b'])!;
    final backendIds = [a.pointer!.address, b.pointer!.address];
    domProbe.invoke(11, 'pushNodesByBackendIdsToFrontend', {'backendNodeIds': backendIds});
    final res = domProbe.lastResults[11]!;
    final nodeIds = (res['nodeIds'] as List).cast<int>();
    expect(nodeIds.length, 2);
    expect(nodeIds[0], prepared.controller.view.forDevtoolsNodeId(a));
    expect(nodeIds[1], prepared.controller.view.forDevtoolsNodeId(b));
  });

  testWidgets('DOM.moveTo moves node before anchor', (tester) async {
    final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
      tester: tester,
      controllerName: 'dom-move-to',
      html:
          '<html><body><div id="p1"><span id="a">A</span><span id="b">B</span></div><div id="p2"><span id="c">C</span></div></body></html>',
    );

    final svc = _TestDevToolsService();
    svc.initWithContext(WebFControllerDebuggingAdapter(prepared.controller));
    final inspector = svc.uiInspector!;
    final domProbe = _DOMProbe(svc);
    inspector.moduleRegistrar['DOM'] = domProbe;
    domProbe.invoke(0, 'enable', {});

    final doc = prepared.document;
    final b = doc.getElementById(['b'])!;
    final p2 = doc.getElementById(['p2'])!;
    final c = doc.getElementById(['c'])!;

    final nodeId = prepared.controller.view.forDevtoolsNodeId(b);
    final targetNodeId = prepared.controller.view.forDevtoolsNodeId(p2);
    final insertBeforeNodeId = prepared.controller.view.forDevtoolsNodeId(c);

    domProbe.invoke(21, 'moveTo', {
      'nodeId': nodeId,
      'targetNodeId': targetNodeId,
      'insertBeforeNodeId': insertBeforeNodeId,
    });

    // After move: p1 should only have <span id=a>, p2 should have <span id=b> before <span id=c>
    final p1 = doc.getElementById(['p1'])!;
    expect((p1.childNodes.first as dom.Element).id, 'a');
    expect((p1.childNodes.length), 2 - 1); // originally 2, now 1

    final p2ChildrenIds = p2.childNodes.whereType<dom.Element>().map((e) => e.id).toList();
    expect(p2ChildrenIds, ['b', 'c']);
  });

  testWidgets('DOM.getNodeForLocation returns node at point', (tester) async {
    final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
      tester: tester,
      controllerName: 'dom-node-for-loc',
      html: '<html><body style="margin:0"><div id="hit" style="position:absolute;left:0;top:0;width:360px;height:640px">H</div></body></html>',
    );

    final svc = _TestDevToolsService();
    svc.initWithContext(WebFControllerDebuggingAdapter(prepared.controller));
    final inspector = svc.uiInspector!;
    final domProbe = _DOMProbe(svc);
    inspector.moduleRegistrar['DOM'] = domProbe;
    domProbe.invoke(0, 'enable', {});

    domProbe.invoke(12, 'getNodeForLocation', {'x': 10, 'y': 10});
    final res = domProbe.lastResults[12];
    expect(res, isNotNull);
    final nodeId = res!['nodeId'] as int;
    final el = prepared.document.getElementById(['hit'])!;
    expect(nodeId, prepared.controller.view.forDevtoolsNodeId(el));
  });

  testWidgets('DOM.resolveNode returns remote object descriptor', (tester) async {
    final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
      tester: tester,
      controllerName: 'dom-resolve',
      html: '<html><body><div id="r">R</div></body></html>',
    );

    final svc = _TestDevToolsService();
    svc.initWithContext(WebFControllerDebuggingAdapter(prepared.controller));
    final inspector = svc.uiInspector!;
    final domProbe = _DOMProbe(svc);
    inspector.moduleRegistrar['DOM'] = domProbe;
    domProbe.invoke(0, 'enable', {});

    final el = prepared.document.getElementById(['r'])!;
    final nodeId = prepared.controller.view.forDevtoolsNodeId(el);
    domProbe.invoke(13, 'resolveNode', {'nodeId': nodeId});
    final res = domProbe.lastResults[13]!;
    final obj = res['object'] as Map;
    expect(obj['type'], 'object');
    expect(obj['subtype'], 'node');
    expect(obj['objectId'], nodeId.toString());
  });

  testWidgets('DOM.querySelector returns nodeId for match', (tester) async {
    final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
      tester: tester,
      controllerName: 'dom-query-selector',
      html: '<html><body><div id="box"><span class="c">X</span></div></body></html>',
    );

    final svc = _TestDevToolsService();
    svc.initWithContext(WebFControllerDebuggingAdapter(prepared.controller));
    final inspector = svc.uiInspector!;
    final domProbe = _DOMProbe(svc);
    inspector.moduleRegistrar['DOM'] = domProbe;
    domProbe.invoke(0, 'enable', {});

    final base = prepared.document.documentElement!; // query under <html>
    final baseId = prepared.controller.view.forDevtoolsNodeId(base);

    domProbe.invoke(15, 'querySelector', {'nodeId': baseId, 'selector': '#box'});
    final res = domProbe.lastResults[15]!;
    final matchedNodeId = res['nodeId'] as int;
    final box = prepared.document.getElementById(['box'])!;
    expect(matchedNodeId, prepared.controller.view.forDevtoolsNodeId(box));

    // Not found should return 0
    domProbe.invoke(16, 'querySelector', {'nodeId': baseId, 'selector': '#nope'});
    final res2 = domProbe.lastResults[16]!;
    expect(res2['nodeId'], 0);
  });

  testWidgets('DOM.querySelectorAll returns all matching nodeIds', (tester) async {
    final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
      tester: tester,
      controllerName: 'dom-query-selector-all',
      html: '<html><body><div id="box"><span id="a">A</span><span id="b">B</span></div></body></html>',
    );

    final svc = _TestDevToolsService();
    svc.initWithContext(WebFControllerDebuggingAdapter(prepared.controller));
    final inspector = svc.uiInspector!;
    final domProbe = _DOMProbe(svc);
    inspector.moduleRegistrar['DOM'] = domProbe;
    domProbe.invoke(0, 'enable', {});

    final box = prepared.document.getElementById(['box'])!;
    final baseId = prepared.controller.view.forDevtoolsNodeId(box);

    domProbe.invoke(17, 'querySelectorAll', {'nodeId': baseId, 'selector': 'span'});
    final res = domProbe.lastResults[17]!;
    final ids = (res['nodeIds'] as List).cast<int>();
    final a = prepared.document.getElementById(['a'])!;
    final b = prepared.document.getElementById(['b'])!;
    final expected = {
      prepared.controller.view.forDevtoolsNodeId(a),
      prepared.controller.view.forDevtoolsNodeId(b),
    };
    expect(ids.toSet(), expected);

    // Not found returns empty list
    domProbe.invoke(18, 'querySelectorAll', {'nodeId': baseId, 'selector': 'div.none'});
    final res2 = domProbe.lastResults[18]!;
    expect((res2['nodeIds'] as List).isEmpty, isTrue);
  });

  testWidgets('DOM.describeNode returns node with limited depth', (tester) async {
    final prepared = await WebFWidgetTestUtils.prepareWidgetTest(
      tester: tester,
      controllerName: 'dom-describe-node',
      html: '<html><body><div id="p"><span id="a">A</span><span id="b"><i>I</i></span></div></body></html>',
    );

    final svc = _TestDevToolsService();
    svc.initWithContext(WebFControllerDebuggingAdapter(prepared.controller));
    final inspector = svc.uiInspector!;
    final domProbe = _DOMProbe(svc);
    inspector.moduleRegistrar['DOM'] = domProbe;
    domProbe.invoke(0, 'enable', {});

    final parent = prepared.document.getElementById(['p'])!;
    final nodeId = prepared.controller.view.forDevtoolsNodeId(parent);

    domProbe.invoke(14, 'describeNode', {'nodeId': nodeId, 'depth': 1});
    final res = domProbe.lastResults[14]!;
    final node = res['node'] as Map;
    expect(node['nodeName'], 'DIV');
    final children = (node['children'] as List).cast<Map>();
    // Depth 1: should include immediate SPAN children, not deeper <i>
    expect(children.any((n) => n['nodeName'] == 'SPAN'), isTrue);
    expect(children.any((n) => n['nodeName'] == 'I'), isFalse);
  });
}
