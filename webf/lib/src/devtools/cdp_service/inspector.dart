/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */
/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-2024 The WebF authors. All rights reserved.
 */
// ignore_for_file: constant_identifier_names

import 'dart:convert';
import 'dart:io';

import 'package:webf/devtools.dart';
import 'package:webf/dom.dart';
import 'package:webf/foundation.dart';

const String INSPECTOR_URL = 'devtools://devtools/bundled/inspector.html';
const int INSPECTOR_DEFAULT_PORT = 9222;
const String INSPECTOR_DEFAULT_ADDRESS = '127.0.0.1';

typedef NativeInspectorMessageHandler = void Function(String message);

class DOMUpdatedEvent extends InspectorEvent {
  @override
  String get method => 'DOM.documentUpdated';

  @override
  JSONEncodable? get params => null;
}

/// Event sent when DOM should be cleared (e.g., during controller switch)
class DOMClearEvent extends InspectorEvent {
  @override
  String get method => 'DOM.documentUpdated';

  @override
  JSONEncodable? get params => null;
}

// Incremental DOM mutation events (subset of Chrome DevTools Protocol)
class DOMChildNodeInsertedEvent extends InspectorEvent {
  final Node parent;
  final Node node;
  final Node? previousSibling;

  DOMChildNodeInsertedEvent(
      {required this.parent, required this.node, this.previousSibling});

  @override
  String get method => 'DOM.childNodeInserted';

  @override
  JSONEncodable? get params => JSONEncodableMap({
        'parentNodeId': parent.ownerView.forDevtoolsNodeId(parent),
        // Chrome DevTools expects a numeric NodeId here. For insert-as-first-child,
        // use 0 instead of null to ensure the event is applied.
        'previousNodeId': previousSibling != null
            ? parent.ownerView.forDevtoolsNodeId(previousSibling!)
            : 0,
        'node': InspectorNode(node).toJson(),
      });
}

class DOMChildNodeRemovedEvent extends InspectorEvent {
  final Node parent;
  final Node node;

  DOMChildNodeRemovedEvent({required this.parent, required this.node});

  @override
  String get method => 'DOM.childNodeRemoved';

  @override
  JSONEncodable? get params => JSONEncodableMap({
        'parentNodeId': parent.ownerView.forDevtoolsNodeId(parent),
        'nodeId': parent.ownerView.forDevtoolsNodeId(node),
      });
}

class DOMAttributeModifiedEvent extends InspectorEvent {
  final Element element;
  final String name;
  final String? value;

  DOMAttributeModifiedEvent(
      {required this.element, required this.name, this.value});

  @override
  String get method => 'DOM.attributeModified';

  @override
  JSONEncodable? get params => JSONEncodableMap({
        'nodeId': element.ownerView.forDevtoolsNodeId(element),
        'name': name,
        'value': value ?? ''
      });
}

class DOMAttributeRemovedEvent extends InspectorEvent {
  final Element element;
  final String name;

  DOMAttributeRemovedEvent({required this.element, required this.name});

  @override
  String get method => 'DOM.attributeRemoved';

  @override
  JSONEncodable? get params => JSONEncodableMap({
        'nodeId': element.ownerView.forDevtoolsNodeId(element),
        'name': name,
      });
}

class DOMCharacterDataModifiedEvent extends InspectorEvent {
  final TextNode node;

  DOMCharacterDataModifiedEvent({required this.node});

  @override
  String get method => 'DOM.characterDataModified';

  @override
  JSONEncodable? get params => JSONEncodableMap({
        'nodeId': node.ownerView.forDevtoolsNodeId(node),
        'characterData': node.data,
      });
}

class DOMChildNodeCountUpdatedEvent extends InspectorEvent {
  final Node node;
  final int childNodeCount;

  DOMChildNodeCountUpdatedEvent({required this.node, required this.childNodeCount});

  @override
  String get method => 'DOM.childNodeCountUpdated';

  @override
  JSONEncodable? get params => JSONEncodableMap({
        'nodeId': node.ownerView.forDevtoolsNodeId(node),
        'childNodeCount': childNodeCount,
      });
}

// Event to seed the children list of a parent node
class DOMSetChildNodesEvent extends InspectorEvent {
  final int parentId;
  final List<Map> nodes;

  DOMSetChildNodesEvent({required this.parentId, required this.nodes});

  @override
  String get method => 'DOM.setChildNodes';

  @override
  JSONEncodable? get params => JSONEncodableMap({
        'parentId': parentId,
        'nodes': nodes,
      });
}

class InspectorServerInit {
  final int port;
  final String address;
  final String bundleURL;
  final double contextId;

  InspectorServerInit(this.contextId, this.port, this.address, this.bundleURL);
}

class InspectorServerConnect {
  final String url;

  InspectorServerConnect(this.url);
}

class InspectorClientConnected {}

class InspectorServerStart {
  int port;

  InspectorServerStart(this.port);
}

class InspectorFrontEndMessage {
  InspectorFrontEndMessage(this.id, this.module, this.method, this.params);

  int? id;
  String module;
  String method;
  final Map<String, dynamic>? params;
}

class InspectorMethodResult {
  final int? id;
  final Map? result;

  InspectorMethodResult(this.id, this.result);
}

class InspectorReload {
  double contextId;

  InspectorReload(this.contextId);
}

class UIInspector {
  final DevToolsService devtoolsService;
  final Map<String, UIInspectorModule> moduleRegistrar = {};

  UIInspector(this.devtoolsService) {
    registerModule(InspectDOMModule(devtoolsService));
    registerModule(InspectOverlayModule(devtoolsService));
    registerModule(InspectPageModule(devtoolsService));
    registerModule(InspectCSSModule(devtoolsService));
    registerModule(InspectNetworkModule(devtoolsService));
    registerModule(InspectLogModule(devtoolsService));
  }

  void registerModule(UIInspectorModule module) {
    moduleRegistrar[module.name] = module;
  }

  void onServerStart(int port) async {
    String remoteAddress = await UIInspector.getConnectedLocalNetworkAddress();
    String inspectorURL = '$INSPECTOR_URL?ws=$remoteAddress:$port';

    devToolsLogger.info('WebF DevTool listening at ws://$remoteAddress:$port');
    devToolsLogger.info('Open Chrome/Edge and enter following url to your navigator:');
    devToolsLogger.info('    $inspectorURL');
    if (DebugFlags.enableDevToolsLogs) {
      devToolsLogger.info('[DevTools] Server started ws=$remoteAddress:$port');
    }
  }

  void messageRouter(
      int? id, String module, String method, Map<String, dynamic>? params) {
    if (moduleRegistrar.containsKey(module)) {
      moduleRegistrar[module]!.invoke(id, method, params);
    }
  }

  void onDOMTreeChanged() {
    // For the unified service, send directly through the service
    if (devtoolsService is ChromeDevToolsService) {
      ChromeDevToolsService.unifiedService
          .sendEventToFrontend(DOMUpdatedEvent());
      if (DebugFlags.enableDevToolsProtocolLogs) {
        devToolsProtocolLogger.finer('[DevTools] -> DOM.documentUpdated (treeChanged)');
      }
    } else {}
  }

  void dispose() {
    moduleRegistrar.clear();
  }

  static Future<String> getConnectedLocalNetworkAddress() async {
    List<NetworkInterface> interfaces = await NetworkInterface.list(
        includeLoopback: false, type: InternetAddressType.IPv4);

    String result = INSPECTOR_DEFAULT_ADDRESS;
    for (NetworkInterface interface in interfaces) {
      if (interface.name == 'en0' ||
          interface.name == 'eth0' ||
          interface.name == 'wlan0') {
        result = interface.addresses.first.address;
        break;
      }
    }

    return result;
  }
}

abstract class JSONEncodable {
  Map toJson();

  @override
  String toString() {
    return jsonEncode(toJson());
  }
}

abstract class InspectorEvent extends JSONEncodable {
  String get method;

  JSONEncodable? get params;

  InspectorEvent();

  @override
  Map toJson() {
    return {
      'method': method,
      'params': params?.toJson() ?? {},
    };
  }
}

class JSONEncodableMap extends JSONEncodable {
  Map<String, dynamic> map;

  JSONEncodableMap(this.map);

  @override
  Map toJson() => map;
}
