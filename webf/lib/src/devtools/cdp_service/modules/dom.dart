/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */
/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-2024 The WebF authors. All rights reserved.
 */
// ignore_for_file: constant_identifier_names

import 'dart:ffi';
import 'dart:ui' as ui;

import 'package:webf/devtools.dart';
import 'package:webf/dom.dart';
import 'package:webf/rendering.dart';
import 'package:flutter/rendering.dart';
import 'package:webf/launcher.dart';
import 'package:webf/src/devtools/cdp_service/debugging_context.dart';
import 'package:webf/foundation.dart';
import 'package:webf/src/bridge/native_types.dart';

const int DOCUMENT_NODE_ID = 0;
const String DEFAULT_FRAME_ID = 'main_frame';

class InspectDOMModule extends UIInspectorModule {
  @override
  String get name => 'DOM';

  DebuggingContext? get dbgContext =>
      devtoolsService.context; // new abstraction
  Document? get document => dbgContext?.document ?? controller?.view.document;

  WebFViewController? get view => controller?.view; // legacy fallback

  InspectDOMModule(super.devtoolsService);

  @override
  void receiveFromFrontend(
      int? id, String method, Map<String, dynamic>? params) {
    switch (method) {
      case 'getDocument':
        onGetDocument(id, method, params);
        break;
      case 'requestChildNodes':
        onRequestChildNodes(id, params!);
        break;
      case 'getBoxModel':
        onGetBoxModel(id, params!);
        break;
      case 'setInspectedNode':
        onSetInspectedNode(id, params!);
        break;
      case 'getNodeForLocation':
        onGetNodeForLocation(id, params!);
        break;
      case 'removeNode':
        onRemoveNode(id, params!);
        break;
      case 'setAttributesAsText':
        onSetAttributesAsText(id, params!);
        break;
      case 'getOuterHTML':
        onGetOuterHTML(id, params!);
        break;
      case 'setOuterHTML':
        onSetOuterHTML(id, params ?? const {});
        break;
      case 'setNodeValue':
        onSetNodeValue(id, params!);
        break;
      case 'setNodeName':
        onSetNodeName(id, params ?? const {});
        break;
      case 'setAttributeValue':
        onSetAttributeValue(id, params!);
        break;
      case 'removeAttribute':
        onRemoveAttribute(id, params ?? const {});
        break;
      case 'querySelector':
        onQuerySelector(id, params ?? const {});
        break;
      case 'querySelectorAll':
        onQuerySelectorAll(id, params ?? const {});
        break;
      case 'moveTo':
        onMoveTo(id, params ?? const {});
        break;
      case 'pushNodesByBackendIdsToFrontend':
        onPushNodesByBackendIdsToFrontend(id, params!);
        break;
      case 'highlightNode':
        // Forward to Overlay.highlightNode for compatibility with clients
        final overlay = devtoolsService.uiInspector?.moduleRegistrar['Overlay'];
        if (overlay is InspectOverlayModule) {
          overlay.onHighlightNode(id, params ?? const {});
        } else {
          sendToFrontend(id, null);
        }
        break;
      case 'hideHighlight':
        final overlay = devtoolsService.uiInspector?.moduleRegistrar['Overlay'];
        if (overlay is InspectOverlayModule) {
          overlay.onHideHighlight(id);
        } else {
          sendToFrontend(id, null);
        }
        break;
      case 'highlightRect':
        final overlay = devtoolsService.uiInspector?.moduleRegistrar['Overlay'];
        if (overlay is InspectOverlayModule) {
          overlay.onHighlightRect(id, params ?? const {});
        } else {
          sendToFrontend(id, null);
        }
        break;
      case 'resolveNode':
        onResolveNode(id, params!);
        break;
      case 'requestNode':
        onRequestNode(id, params ?? const {});
        break;
      case 'describeNode':
        onDescribeNode(id, params ?? const {});
        break;
    }
  }

  void onDescribeNode(int? id, Map<String, dynamic> params) {
    // https://chromedevtools.github.io/devtools-protocol/tot/DOM/#method-describeNode
    // Supports identifying by nodeId or backendNodeId. objectId is ignored for now.
    final ctx = dbgContext;
    if (ctx == null) {
      sendToFrontend(id, null);
      return;
    }

    Node? target;
    // Prefer nodeId if provided
    final int? nodeId = params['nodeId'];
    if (nodeId != null) {
      final targetId = ctx.getTargetIdByNodeId(nodeId);
      if (targetId != null && targetId != 0) {
        target = ctx.getBindingObject(Pointer.fromAddress(targetId)) as Node?;
      }
    }

    // Fallback to backendNodeId
    if (target == null) {
      final int? backendNodeId = params['backendNodeId'];
      if (backendNodeId != null && backendNodeId != 0) {
        target = ctx.getBindingObject(Pointer.fromAddress(backendNodeId)) as Node?;
      }
    }

    if (target == null) {
      sendToFrontend(id, null);
      return;
    }

    final int depth = (params['depth'] is int) ? (params['depth'] as int) : 1;

    Map<String, dynamic> toJsonWithDepth(Node n, int d) {
      final base = <String, dynamic>{
        'nodeId': n.ownerView.forDevtoolsNodeId(n),
        'backendNodeId': n.pointer?.address ?? 0,
        'nodeType': getNodeTypeValue(n.nodeType),
        'localName': n is Element ? n.tagName.toLowerCase() : null,
        'nodeName': n.nodeName,
        'nodeValue': n is TextNode
            ? (n).data
            : (n is Comment ? (n).data : ''),
        'parentId': n.parentNode != null ? n.ownerView.forDevtoolsNodeId(n.parentNode!) : 0,
        'childNodeCount': n.childNodes.length,
        'attributes': n is Element
            ? (() {
                final attrs = <String>[];
                (n).attributes.forEach((k, v) {
                  attrs.add(k);
                  attrs.add(v.toString());
                });
                return attrs;
              })()
            : null,
      };
      // Remove nulls to match prior InspectorNode encoding
      base.removeWhere((k, v) => v == null);

      if (d > 0 && n.childNodes.isNotEmpty) {
        final list = <Map<String, dynamic>>[];
        for (final c in n.childNodes) {
          if (c is Element || (c is TextNode && c.data.trim().isNotEmpty)) {
            list.add(toJsonWithDepth(c, d - 1));
          }
        }
        if (list.isNotEmpty) base['children'] = list;
      }
      return base;
    }

    final result = {'node': toJsonWithDepth(target, depth)};
    sendToFrontend(id, JSONEncodableMap(result));
  }

  void onRequestChildNodes(int? id, Map<String, dynamic> params) {
    // https://chromedevtools.github.io/devtools-protocol/tot/DOM/#method-requestChildNodes
    if (DebugFlags.enableDevToolsLogs) {
      devToolsLogger.finer('[DevTools] DOM.requestChildNodes nodeId=${params['nodeId']} depth=${params['depth']}');
    }
    final ctx = dbgContext;
    if (ctx == null) {
      sendToFrontend(id, null);
      return;
    }
    final int? frontendNodeId = params['nodeId'];
    if (frontendNodeId == null) {
      sendToFrontend(id, null);
      return;
    }

    final targetId = ctx.getTargetIdByNodeId(frontendNodeId);
    if (targetId == null) {
      sendToFrontend(id, null);
      return;
    }
    final Node? parent = ctx.getBindingObject(Pointer.fromAddress(targetId)) as Node?;
    if (parent == null) {
      sendToFrontend(id, null);
      return;
    }

    // Build immediate children list (filter whitespace-only text nodes)
    final children = <Map>[];
    for (final child in parent.childNodes) {
      if (child is Element || (child is TextNode && child.data.trim().isNotEmpty)) {
        children.add(InspectorNode(child).toJson());
      }
    }

    if (devtoolsService is ChromeDevToolsService) {
      final pId = ctx.forDevtoolsNodeId(parent);
      ChromeDevToolsService.unifiedService
          .sendEventToFrontend(DOMSetChildNodesEvent(parentId: pId, nodes: children));
      if (DebugFlags.enableDevToolsProtocolLogs) {
        devToolsProtocolLogger
            .finer('[DevTools] -> DOM.setChildNodes parent=$pId count=${children.length}');
      }
    }
    // Respond to the method call with empty result
    sendToFrontend(id, JSONEncodableMap({}));
  }

  void onGetNodeForLocation(int? id, Map<String, dynamic> params) {
    if (DebugFlags.enableDevToolsLogs) {
      devToolsLogger.finer('[DevTools] DOM.getNodeForLocation x=${params['x']} y=${params['y']}');
    }
    int x = params['x'];
    int y = params['y'];

    // Check if controller is attached to Flutter
    final ctx = dbgContext;
    if (ctx != null && !ctx.isFlutterAttached) {
      // Return null if controller is not attached
      sendToFrontend(id, null);
      return;
    }

    if (document == null) {
      sendToFrontend(id, null);
      return;
    }
    RenderBox rootRenderObject = document!.viewport!;
    BoxHitTestResult result = BoxHitTestResult();
    rootRenderObject.hitTest(result,
        position: Offset(x.toDouble(), y.toDouble()));
    var hitPath = result.path;
    if (hitPath.isEmpty) {
      sendToFrontend(id, null);
      return;
    }
    // find real img element.
    if (hitPath.first.target is WebFRenderImage ||
        ((hitPath.first.target as RenderBoxModel)
                    .renderStyle
                    .target
                    .pointer ==
                null)) {
      hitPath = hitPath.skip(1);
    }
    if (hitPath.isNotEmpty && hitPath.first.target is RenderBoxModel) {
      RenderObject lastHitRenderBoxModel =
          result.path.first.target as RenderObject;
      if (lastHitRenderBoxModel is RenderBoxModel && dbgContext != null) {
        int targetId = dbgContext!
            .forDevtoolsNodeId(lastHitRenderBoxModel.renderStyle.target);
        sendToFrontend(
            id,
            JSONEncodableMap({
              'backendId': targetId,
              'frameId': DEFAULT_FRAME_ID,
              'nodeId': targetId,
            }));
      } else {
        sendToFrontend(id, null);
      }
    } else {
      sendToFrontend(id, null);
    }
  }

  /// Enables console to refer to the node with given id via $x
  /// (see Command Line API for more details $x functions).
  Node? inspectedNode;

  void onSetInspectedNode(int? id, Map<String, dynamic> params) {
    if (DebugFlags.enableDevToolsLogs) {
      devToolsLogger.finer('[DevTools] DOM.setInspectedNode nodeId=${params['nodeId']}');
    }
    int? nodeId = params['nodeId'];
    final ctx = dbgContext;
    if (nodeId == null || ctx == null) {
      sendToFrontend(id, null);
      return;
    }
    final targetId = ctx.getTargetIdByNodeId(nodeId);
    Node? node;
    if (targetId != null) {
      node = ctx.getBindingObject(Pointer.fromAddress(targetId)) as Node?;
    }
    if (node != null) {
      inspectedNode = node;
      // Signal CSS module that computed style for this node may need refresh
      final cssModule = devtoolsService.uiInspector?.moduleRegistrar['CSS'];
      if (cssModule is InspectCSSModule) {
        cssModule.markComputedStyleDirtyByNodeId(nodeId);
      }
    }
    sendToFrontend(id, null);
  }

  /// https://chromedevtools.github.io/devtools-protocol/tot/DOM/#method-getDocument
  void onGetDocument(int? id, String method, Map<String, dynamic>? params) {
    if (DebugFlags.enableDevToolsLogs) {
      devToolsLogger.finer('[DevTools] DOM.getDocument');
    }
    // Check if we're using the unified service and if it's in the middle of a context switch
    if (devtoolsService is ChromeDevToolsService) {
      final unifiedService = ChromeDevToolsService.unifiedService;
      if (unifiedService.isContextSwitching) {
        // Return null during context switch to clear the DOM panel
        sendToFrontend(id, null);
        return;
      }
    }

    // Check if controller is attached to Flutter
    final ctx = dbgContext;
    if (ctx != null && !ctx.isFlutterAttached) {
      // Return null if controller is not attached to show empty document
      sendToFrontend(id, null);
      return;
    }

    if (document == null || document!.documentElement == null) {
      sendToFrontend(id, null);
      return;
    }
    Node root = document!.documentElement!;
    InspectorDocument inspectorDoc = InspectorDocument(InspectorNode(root));

    sendToFrontend(id, inspectorDoc);
  }

  void onGetBoxModel(int? id, Map<String, dynamic> params) {
    if (DebugFlags.enableDevToolsLogs) {
      devToolsLogger.finer('[DevTools] DOM.getBoxModel nodeId=${params['nodeId']}');
    }
    int? nodeId = params['nodeId'];
    final ctx = dbgContext;
    if (nodeId == null || ctx == null) {
      sendToFrontend(id, null);
      return;
    }
    final targetId = ctx.getTargetIdByNodeId(nodeId);
    Node? node;
    if (targetId != null) {
      node = ctx.getBindingObject(Pointer.fromAddress(targetId)) as Node?;
    }

    Element? element;
    if (node is Element) element = node;

    // BoxModel design to BorderBox in kraken.
    if (element != null &&
        element.renderStyle.hasRenderBox() &&
        element.renderStyle.isBoxModelHaveSize()) {
      ui.Offset contentBoxOffset = element.renderStyle.localToGlobal(
          ui.Offset.zero,
          ancestor: element.ownerDocument.viewport);

      int widthWithinBorder = element.renderStyle.boxSize()!.width.toInt();
      int heightWithinBorder = element.renderStyle.boxSize()!.height.toInt();
      List<double> border = [
        contentBoxOffset.dx,
        contentBoxOffset.dy,
        contentBoxOffset.dx + widthWithinBorder,
        contentBoxOffset.dy,
        contentBoxOffset.dx + widthWithinBorder,
        contentBoxOffset.dy + heightWithinBorder,
        contentBoxOffset.dx,
        contentBoxOffset.dy + heightWithinBorder,
      ];
      List<double> padding = [
        border[0] + (element.renderStyle.borderLeftWidth?.computedValue ?? 0),
        border[1] + (element.renderStyle.borderTopWidth?.computedValue ?? 0),
        border[2] - (element.renderStyle.borderRightWidth?.computedValue ?? 0),
        border[3] + (element.renderStyle.borderTopWidth?.computedValue ?? 0),
        border[4] - (element.renderStyle.borderRightWidth?.computedValue ?? 0),
        border[5] - (element.renderStyle.borderBottomWidth?.computedValue ?? 0),
        border[6] + (element.renderStyle.borderLeftWidth?.computedValue ?? 0),
        border[7] - (element.renderStyle.borderBottomWidth?.computedValue ?? 0),
      ];
      List<double> content = [
        padding[0] + element.renderStyle.paddingLeft.computedValue,
        padding[1] + element.renderStyle.paddingTop.computedValue,
        padding[2] - element.renderStyle.paddingRight.computedValue,
        padding[3] + element.renderStyle.paddingTop.computedValue,
        padding[4] - element.renderStyle.paddingRight.computedValue,
        padding[5] - element.renderStyle.paddingBottom.computedValue,
        padding[6] + element.renderStyle.paddingLeft.computedValue,
        padding[7] - element.renderStyle.paddingBottom.computedValue,
      ];
      List<double> margin = [
        border[0] - element.renderStyle.marginLeft.computedValue,
        border[1] - element.renderStyle.marginTop.computedValue,
        border[2] + element.renderStyle.marginRight.computedValue,
        border[3] - element.renderStyle.marginTop.computedValue,
        border[4] + element.renderStyle.marginRight.computedValue,
        border[5] + element.renderStyle.marginBottom.computedValue,
        border[6] - element.renderStyle.marginLeft.computedValue,
        border[7] + element.renderStyle.marginBottom.computedValue,
      ];

      BoxModel boxModel = BoxModel(
        content: content,
        padding: padding,
        border: border,
        margin: margin,
        width: widthWithinBorder,
        height: heightWithinBorder,
      );
      sendToFrontend(
          id,
          JSONEncodableMap({
            'model': boxModel,
          }));
    } else {
      sendToFrontend(id, null);
    }
  }

  void onRemoveNode(int? id, Map<String, dynamic> params) {
    if (DebugFlags.enableDevToolsLogs) {
      devToolsLogger.finer('[DevTools] DOM.removeNode nodeId=${params['nodeId']}');
    }
    int? nodeId = params['nodeId'];
    final ctx = dbgContext;
    if (nodeId == null || ctx == null) {
      sendToFrontend(id, null);
      return;
    }
    final targetId = ctx.getTargetIdByNodeId(nodeId);
    Node? node;
    if (targetId != null) {
      node = ctx.getBindingObject(Pointer.fromAddress(targetId)) as Node?;
    }
    if (node != null) {
      // Prefer controller bridge to emit incremental CDP events (childNodeRemoved)
      final controller = ctx.getController() ?? devtoolsService.controller;
      if (controller != null) {
        try {
          controller.view.removeNode(node.pointer!);
        } catch (_) {
          if (node.parentNode != null) {
            node.parentNode!.removeChild(node);
          }
        }
      } else if (node.parentNode != null) {
        node.parentNode!.removeChild(node);
      }
    }
    sendToFrontend(id, null);
  }

  void onSetAttributesAsText(int? id, Map<String, dynamic> params) {
    if (DebugFlags.enableDevToolsLogs) {
      devToolsLogger.finer('[DevTools] DOM.setAttributesAsText nodeId=${params['nodeId']}');
    }
    int? nodeId = params['nodeId'];
    String? text = params['text'];
    String? name = params['name'];
    final ctx = dbgContext;
    if (nodeId == null || ctx == null) {
      sendToFrontend(id, null);
      return;
    }
    final targetId = ctx.getTargetIdByNodeId(nodeId);
    Node? node;
    if (targetId != null) {
      node = ctx.getBindingObject(Pointer.fromAddress(targetId)) as Node?;
    }
    if (node is Element && text != null) {
      final el = node;
      if (name != null && name.isNotEmpty) {
        // Update single attribute case
        if (text.isEmpty) {
          el.removeAttribute(name);
        } else {
          el.setAttribute(name, text);
        }
      } else {
        // Replace attributes from text string
        el.attributes.clear();
        // Match name="value" or name='value', allow hyphens/colons in attribute name
        final pair = RegExp(r"""([^\s=]+)\s*=\s*("([^"]*)"|'([^']*)')""");
        for (final m in pair.allMatches(text)) {
          final attrName = m.group(1);
          final dv = m.group(3); // double-quoted value
          final sv = m.group(4); // single-quoted value
          final attrValue = dv ?? sv ?? '';
          if (attrName != null) {
            el.setAttribute(attrName, attrValue);
          }
        }
        // Also handle boolean attributes present without =value
        // by scanning leftover tokens that look like names
        final consumed = pair.allMatches(text).map((m) => m.group(0)!).join(' ');
        final remainder = text.replaceAll(consumed, ' ').trim();
        if (remainder.isNotEmpty) {
          // Split by whitespace and set empty string for each token not containing '='
          for (final token in remainder.split(RegExp(r'\s+'))) {
            if (token.isEmpty) continue;
            if (!token.contains('=')) {
              el.setAttribute(token, '');
            }
          }
        }
      }
    }
    sendToFrontend(id, null);
  }

  void onGetOuterHTML(int? id, Map<String, dynamic> params) {
    if (DebugFlags.enableDevToolsLogs) {
      devToolsLogger.finer('[DevTools] DOM.getOuterHTML nodeId=${params['nodeId']}');
    }
    int? nodeId = params['nodeId'];
    final ctx = dbgContext;
    if (nodeId == null || ctx == null) return;
    final targetId = ctx.getTargetIdByNodeId(nodeId);
    Node? node;
    if (targetId != null) {
      node = ctx.getBindingObject(Pointer.fromAddress(targetId)) as Node?;
    }
    if (node is Element) {
      // Generate outer HTML
      String outerHTML = '<${node.tagName.toLowerCase()}';

      // Add attributes
      node.attributes.forEach((key, value) {
        outerHTML += ' $key="$value"';
      });

      // Add children
      if (node.hasChildren()) {
        outerHTML += '>';
        for (Node child in node.childNodes) {
          if (child is TextNode) {
            outerHTML += child.data;
          } else if (child is Element) {
            // Recursively get child HTML
            outerHTML += '...'; // Simplified for now
          }
        }
        outerHTML += '</${node.tagName.toLowerCase()}>';
      } else {
        outerHTML += '/>';
      }

      sendToFrontend(
          id,
          JSONEncodableMap({
            'outerHTML': outerHTML,
          }));
    } else {
      sendToFrontend(
          id,
          JSONEncodableMap({
            'outerHTML': '',
          }));
    }
  }

  /// https://chromedevtools.github.io/devtools-protocol/tot/DOM/#method-setOuterHTML
  /// Sets outer HTML for an element. Simplified parser that supports tag, attributes,
  /// and plain text content. Nested markup in content will be treated as text.
  void onSetOuterHTML(int? id, Map<String, dynamic> params) {
    final ctx = dbgContext;
    if (ctx == null) {
      sendToFrontend(id, null);
      return;
    }
    final int? nodeId = params['nodeId'];
    final String? outer = params['outerHTML'];
    if (nodeId == null || outer == null) {
      sendToFrontend(id, null);
      return;
    }

    final targetId = ctx.getTargetIdByNodeId(nodeId);
    if (targetId == null || targetId == 0) {
      sendToFrontend(id, null);
      return;
    }
    final Node? baseNode = ctx.getBindingObject(Pointer.fromAddress(targetId)) as Node?;
    if (baseNode is! Element) {
      sendToFrontend(id, null);
      return;
    }

    // Parse minimal outerHTML: <tag attrs>content</tag> or <tag attrs/> self-closing
    final selfClose = RegExp(r"""^\s*<\s*([a-zA-Z0-9-]+)([^>]*)/\s*>\s*$""");
    final normal = RegExp(r"""^\s*<\s*([a-zA-Z0-9-]+)([^>]*)>([\s\S]*)<\/\s*\1\s*>\s*$""");
    String? tag;
    String attrs = '';
    String content = '';
    RegExpMatch? m = normal.firstMatch(outer);
    if (m != null) {
      tag = m.group(1);
      attrs = m.group(2)?.trim() ?? '';
      content = m.group(3) ?? '';
    } else {
      m = selfClose.firstMatch(outer);
      if (m != null) {
        tag = m.group(1);
        attrs = m.group(2)?.trim() ?? '';
        content = '';
      }
    }

    if (tag == null || tag.isEmpty) {
      // Fallback: ignore invalid markup
      sendToFrontend(id, null);
      return;
    }

    final controller = ctx.getController() ?? devtoolsService.controller;
    if (controller == null) {
      sendToFrontend(id, null);
      return;
    }

    // Prepare working element reference; rename if needed and update nodeId
    Element workingEl = baseNode;
    int workingNodeId = nodeId;
    if (baseNode.tagName.toLowerCase() != tag.toLowerCase()) {
      final newPtr = allocateNewBindingObject();
      try {
        controller.view.createElement(newPtr, tag);
        // Copy attributes/inline style
        controller.view.cloneNode(baseNode.pointer!, newPtr);
        final Element? newEl = ctx.getBindingObject(newPtr) as Element?;
        if (newEl != null) {
          // Move children from old to new
          while (baseNode.firstChild != null) {
            newEl.appendChild(baseNode.firstChild!);
          }
          // Insert new next to old and remove old
          controller.view.insertAdjacentNode(baseNode.pointer!, 'afterend', newPtr);
          controller.view.removeNode(baseNode.pointer!);
          workingEl = newEl;
          workingNodeId = ctx.forDevtoolsNodeId(newEl);
        }
      } catch (_) {
        // fall back: keep baseNode
      }
    }

    // Apply attributes
    if (attrs.isNotEmpty) {
      onSetAttributesAsText(null, {'nodeId': workingNodeId, 'text': attrs});
    } else {
      // Clear attributes (preserve id if present in original) – keep it simple: leave as-is when empty
    }

    // Replace children with plain text content
    try {
      // Remove all existing children via view bridge to emit events
      while (workingEl.firstChild != null) {
        final child = workingEl.firstChild!;
        controller.view.removeNode(child.pointer!);
      }
    } catch (_) {
      // Fallback: direct removal
      while (workingEl.firstChild != null) {
        workingEl.removeChild(workingEl.firstChild!);
      }
    }

    final trimmed = content.trim();
    if (trimmed.isNotEmpty) {
      // If content contains markup, treat as text
      final textPtr = allocateNewBindingObject();
      controller.view.createTextNode(textPtr, trimmed);
      try {
        controller.view.insertAdjacentNode(workingEl.pointer!, 'beforeend', textPtr);
      } catch (_) {
        final tnode = ctx.getBindingObject(textPtr) as Node?;
        if (tnode != null) workingEl.appendChild(tnode);
      }
    }

    sendToFrontend(id, null);
  }

  void onSetNodeValue(int? id, Map<String, dynamic> params) {
    if (DebugFlags.enableDevToolsLogs) {
      devToolsLogger.finer('[DevTools] DOM.setNodeValue nodeId=${params['nodeId']}');
    }
    int? nodeId = params['nodeId'];
    String? value = params['value'];
    final ctx = dbgContext;
    if (nodeId == null || ctx == null) return;
    final targetId = ctx.getTargetIdByNodeId(nodeId);
    Node? node;
    if (targetId != null) {
      node = ctx.getBindingObject(Pointer.fromAddress(targetId)) as Node?;
    }
    if (node is TextNode && value != null) {
      node.data = value;
    }
    sendToFrontend(id, null);
  }

  /// https://chromedevtools.github.io/devtools-protocol/tot/DOM/#method-setNodeName
  /// Renames a node (typically an element) to the provided tag name, returning the new nodeId.
  void onSetNodeName(int? id, Map<String, dynamic> params) {
    final ctx = dbgContext;
    if (ctx == null) {
      sendToFrontend(id, null);
      return;
    }
    final int? nodeId = params['nodeId'];
    final String? name = params['name'];
    if (nodeId == null || name == null || name.isEmpty) {
      sendToFrontend(id, null);
      return;
    }

    final targetId = ctx.getTargetIdByNodeId(nodeId);
    if (targetId == null || targetId == 0) {
      sendToFrontend(id, null);
      return;
    }

    final Node? node = ctx.getBindingObject(Pointer.fromAddress(targetId)) as Node?;
    if (node is! Element) {
      // Only elements can be renamed by tag
      sendToFrontend(id, JSONEncodableMap({'nodeId': nodeId}));
      return;
    }

    final controller = ctx.getController() ?? devtoolsService.controller;
    if (controller == null) {
      sendToFrontend(id, JSONEncodableMap({'nodeId': nodeId}));
      return;
    }

    // Create new native element for the new tag name
    final newPtr = allocateNewBindingObject();
    try {
      controller.view.createElement(newPtr, name);
    } catch (e) {
      sendToFrontend(id, JSONEncodableMap({'nodeId': nodeId}));
      return;
    }

    // Copy attributes/inline styles/id/class via clone helper
    try {
      controller.view.cloneNode(node.pointer!, newPtr);
    } catch (_) {}

    // Move children to the new element (DOM-level; will be included in inserted node payload)
    final Element? newEl = ctx.getBindingObject(newPtr) as Element?;
    if (newEl != null) {
      while (node.firstChild != null) {
        newEl.appendChild(node.firstChild!);
      }
      // Insert new element after the original, then remove original to trigger CDP events
      try {
        controller.view.insertAdjacentNode(node.pointer!, 'afterend', newPtr);
      } catch (_) {}
      try {
        controller.view.removeNode(node.pointer!);
      } catch (_) {
        node.parentNode?.removeChild(node);
      }

      final newId = ctx.forDevtoolsNodeId(newEl);
      sendToFrontend(id, JSONEncodableMap({'nodeId': newId}));
      return;
    }

    // Fallback
    sendToFrontend(id, JSONEncodableMap({'nodeId': nodeId}));
  }

  /// https://chromedevtools.github.io/devtools-protocol/tot/DOM/#method-querySelector
  /// Returns the nodeId of the first element that matches the selector under the given node.
  void onQuerySelector(int? id, Map<String, dynamic> params) {
    final ctx = dbgContext;
    if (ctx == null) {
      sendToFrontend(id, null);
      return;
    }

    final int? baseNodeId = params['nodeId'];
    final String? selector = params['selector'];
    if (baseNodeId == null || selector == null || selector.isEmpty) {
      sendToFrontend(id, JSONEncodableMap({'nodeId': 0}));
      return;
    }

    final basePtr = ctx.getTargetIdByNodeId(baseNodeId);
    if (basePtr == null || basePtr == 0) {
      sendToFrontend(id, JSONEncodableMap({'nodeId': 0}));
      return;
    }

    final Node? baseNode = ctx.getBindingObject(Pointer.fromAddress(basePtr)) as Node?;
    Element? matched;
    try {
      if (baseNode is Element) {
        matched = baseNode.querySelector([selector]);
      } else if (baseNode is Document) {
        matched = baseNode.querySelector([selector]);
      } else if (baseNode?.parentNode is Element) {
        matched = (baseNode!.parentNode as Element).querySelector([selector]);
      }
    } catch (_) {}

    if (matched != null) {
      final nid = ctx.forDevtoolsNodeId(matched);
      sendToFrontend(id, JSONEncodableMap({'nodeId': nid}));
    } else {
      sendToFrontend(id, JSONEncodableMap({'nodeId': 0}));
    }
  }

  /// https://chromedevtools.github.io/devtools-protocol/tot/DOM/#method-querySelectorAll
  /// Returns the nodeIds of all elements that match the selector under the given node.
  void onQuerySelectorAll(int? id, Map<String, dynamic> params) {
    final ctx = dbgContext;
    if (ctx == null) {
      sendToFrontend(id, null);
      return;
    }

    final int? baseNodeId = params['nodeId'];
    final String? selector = params['selector'];
    if (baseNodeId == null || selector == null || selector.isEmpty) {
      sendToFrontend(id, JSONEncodableMap({'nodeIds': <int>[]}));
      return;
    }

    final basePtr = ctx.getTargetIdByNodeId(baseNodeId);
    if (basePtr == null || basePtr == 0) {
      sendToFrontend(id, JSONEncodableMap({'nodeIds': <int>[]}));
      return;
    }

    final Node? baseNode = ctx.getBindingObject(Pointer.fromAddress(basePtr)) as Node?;
    List<Element> matches = const <Element>[];
    try {
      if (baseNode is Element) {
        matches = (baseNode.querySelectorAll([selector]) as List).cast<Element>();
      } else if (baseNode is Document) {
        matches = (baseNode.querySelectorAll([selector]) as List).cast<Element>();
      } else if (baseNode?.parentNode is Element) {
        matches = ((baseNode!.parentNode as Element).querySelectorAll([selector]) as List).cast<Element>();
      }
    } catch (_) {}

    final nodeIds = matches.map((el) => ctx.forDevtoolsNodeId(el)).toList(growable: false);
    sendToFrontend(id, JSONEncodableMap({'nodeIds': nodeIds}));
  }

  /// https://chromedevtools.github.io/devtools-protocol/tot/DOM/#method-moveTo
  /// Moves the node identified by nodeId into the new container (targetNodeId),
  /// optionally before insertBeforeNodeId when provided. Returns the nodeId.
  void onMoveTo(int? id, Map<String, dynamic> params) {
    final ctx = dbgContext;
    if (ctx == null) {
      sendToFrontend(id, null);
      return;
    }

    final int? nodeId = params['nodeId'];
    final int? targetNodeId = params['targetNodeId'];
    // Spec uses insertBeforeNodeId; accept alternative keys for compatibility.
    final int? insertBeforeNodeId = params['insertBeforeNodeId'] ?? params['anchorNodeId'];

    if (nodeId == null || targetNodeId == null) {
      sendToFrontend(id, null);
      return;
    }

    final nodePtrAddr = ctx.getTargetIdByNodeId(nodeId);
    final targetPtrAddr = ctx.getTargetIdByNodeId(targetNodeId);
    final beforePtrAddr = insertBeforeNodeId != null ? ctx.getTargetIdByNodeId(insertBeforeNodeId) : null;

    if (nodePtrAddr == null || targetPtrAddr == null) {
      sendToFrontend(id, null);
      return;
    }

    final node = ctx.getBindingObject(Pointer.fromAddress(nodePtrAddr)) as Node?;
    final target = ctx.getBindingObject(Pointer.fromAddress(targetPtrAddr)) as Node?;
    final before = (beforePtrAddr != null && beforePtrAddr != 0)
        ? ctx.getBindingObject(Pointer.fromAddress(beforePtrAddr)) as Node?
        : null;

    if (node == null || target == null) {
      sendToFrontend(id, null);
      return;
    }

    // Use controller view bridge to ensure DevTools incremental callbacks fire.
    final controller = ctx.getController() ?? devtoolsService.controller;
    if (controller == null) {
      // Fallback to raw DOM operations if controller not present
      try {
        // Remove from old parent
        node.parentNode?.removeChild(node);
        // Insert before anchor if provided else append
        if (before != null && before.parentNode == target) {
          target.insertBefore(node, before);
        } else if (target is ContainerNode) {
          target.appendChild(node);
        }
      } catch (_) {}
    } else {
      final view = controller.view;
      try {
        // Emit removal from old parent
        if (node.parentNode != null) {
          view.removeNode(node.pointer!);
        }
        // Insert before anchor or append to target
        if (before != null) {
          // Insert before the given reference node
          view.insertAdjacentNode(before.pointer!, 'beforebegin', node.pointer!);
        } else {
          // Append as last child of target
          view.insertAdjacentNode(target.pointer!, 'beforeend', node.pointer!);
        }
      } catch (_) {}
    }

    sendToFrontend(id, JSONEncodableMap({'nodeId': nodeId}));
  }

  void onSetAttributeValue(int? id, Map<String, dynamic> params) {
    // https://chromedevtools.github.io/devtools-protocol/tot/DOM/#method-setAttributeValue
    if (DebugFlags.enableDevToolsLogs) {
      devToolsLogger.finer('[DevTools] DOM.setAttributeValue nodeId=${params['nodeId']} name=${params['name']}');
    }
    final ctx = dbgContext;
    if (ctx == null) {
      sendToFrontend(id, null);
      return;
    }
    int? nodeId = params['nodeId'];
    String? name = params['name'];
    String? value = params['value'];
    if (nodeId == null || name == null || value == null) {
      sendToFrontend(id, null);
      return;
    }
    final targetId = ctx.getTargetIdByNodeId(nodeId);
    if (targetId == null) {
      sendToFrontend(id, null);
      return;
    }
    final Node? node = ctx.getBindingObject(Pointer.fromAddress(targetId)) as Node?;
    if (node is Element) {
      // Prefer controller bridge to emit incremental attributeModified events
      final controller = ctx.getController() ?? devtoolsService.controller;
      if (controller != null) {
        try {
          controller.view.setAttribute(node.pointer!, name, value);
        } catch (_) {
          node.setAttribute(name, value);
        }
      } else {
        node.setAttribute(name, value);
      }
    }
    sendToFrontend(id, null);
  }

  void onRemoveAttribute(int? id, Map<String, dynamic> params) {
    // https://chromedevtools.github.io/devtools-protocol/tot/DOM/#method-removeAttribute
    if (DebugFlags.enableDevToolsLogs) {
      devToolsLogger
          .finer('[DevTools] DOM.removeAttribute nodeId=${params['nodeId']} name=${params['name']}');
    }
    final ctx = dbgContext;
    if (ctx == null) {
      sendToFrontend(id, null);
      return;
    }
    int? nodeId = params['nodeId'];
    String? name = params['name'];
    if (nodeId == null || name == null) {
      sendToFrontend(id, null);
      return;
    }
    final targetId = ctx.getTargetIdByNodeId(nodeId);
    if (targetId == null) {
      sendToFrontend(id, null);
      return;
    }
    final Node? node = ctx.getBindingObject(Pointer.fromAddress(targetId)) as Node?;
    if (node is Element) {
      final controller = ctx.getController() ?? devtoolsService.controller;
      if (controller != null) {
        try {
          controller.view.removeAttribute(node.pointer!, name);
        } catch (_) {
          node.removeAttribute(name);
        }
      } else {
        node.removeAttribute(name);
      }
    }
    sendToFrontend(id, null);
  }

  void onPushNodesByBackendIdsToFrontend(int? id, Map<String, dynamic> params) {
    List? backendNodeIds = params['backendNodeIds'];
    if (backendNodeIds == null) {
      sendToFrontend(
          id,
          JSONEncodableMap({
            'nodeIds': [],
          }));
      return;
    }

    List<int> nodeIds = [];
    final ctx = dbgContext;
    for (var backendId in backendNodeIds) {
      if (backendId is int && ctx != null) {
        Node? node =
            ctx.getBindingObject(Pointer.fromAddress(backendId)) as Node?;
        if (node != null) {
          nodeIds.add(ctx.forDevtoolsNodeId(node));
        }
      }
    }

    sendToFrontend(
        id,
        JSONEncodableMap({
          'nodeIds': nodeIds,
        }));
  }

  void onResolveNode(int? id, Map<String, dynamic> params) {
    int? nodeId = params['nodeId'];
    final ctx = dbgContext;
    if (nodeId == null || ctx == null) return;
    final targetId = ctx.getTargetIdByNodeId(nodeId);
    Node? node;
    if (targetId != null) {
      node = ctx.getBindingObject(Pointer.fromAddress(targetId)) as Node?;
    }
    if (node != null) {
      // Return a remote object reference for the node
      sendToFrontend(
          id,
          JSONEncodableMap({
            'object': {
              'type': 'object',
              'subtype': 'node',
              'className': node.nodeName,
              'description': node.nodeName,
              'objectId': '$nodeId',
            }
          }));
    } else {
      sendToFrontend(id, null);
    }
  }

  /// https://chromedevtools.github.io/devtools-protocol/tot/DOM/#method-requestNode
  /// Returns nodeId for a given objectId (from Runtime.evaluate/resolveNode).
  void onRequestNode(int? id, Map<String, dynamic> params) {
    final ctx = dbgContext;
    if (ctx == null) {
      sendToFrontend(id, null);
      return;
    }

    final dynamic objectId = params['objectId'];
    int parsedNodeId = 0;
    if (objectId is String) {
      // Our resolveNode encodes nodeId as string objectId
      parsedNodeId = int.tryParse(objectId) ?? 0;
    } else if (objectId is int) {
      parsedNodeId = objectId;
    }

    // Validate that the node exists in mapping
    if (parsedNodeId != 0) {
      final targetId = ctx.getTargetIdByNodeId(parsedNodeId);
      if (targetId == null || targetId == 0) {
        parsedNodeId = 0;
      }
    }

    sendToFrontend(id, JSONEncodableMap({'nodeId': parsedNodeId}));
  }
}

class InspectorDocument extends JSONEncodable {
  InspectorNode child;

  InspectorDocument(this.child);

  @override
  Map toJson() {
    var owner = child.referencedNode.ownerDocument;
    return {
      'depth': 0,
      'root': {
        'nodeId': DOCUMENT_NODE_ID,
        'backendNodeId': DOCUMENT_NODE_ID,
        'nodeType': 9,
        'nodeName': '#document',
        'childNodeCount': 1,
        'children': [child.toJson()],
        'baseURL': owner.controller.url,
        'documentURL': owner.controller.url,
      },
    };
  }
}

/// https://chromedevtools.github.io/devtools-protocol/tot/DOM/#type-Node
class InspectorNode extends JSONEncodable {
  /// DOM interaction is implemented in terms of mirror objects that represent the actual
  /// DOM nodes. DOMNode is a base node mirror type.
  InspectorNode(this.referencedNode);

  /// Reference backend Kraken DOM Node.
  Node referencedNode;

  /// Node identifier that is passed into the rest of the DOM messages as the nodeId.
  /// Backend will only push node with given id once. It is aware of all requested nodes
  /// and will only fire DOM events for nodes known to the client.
  int? get nodeId => referencedNode.ownerView.forDevtoolsNodeId(referencedNode);

  /// Optional. The id of the parent node if any.
  int get parentId {
    if (referencedNode.parentNode != null &&
        referencedNode.parentNode!.pointer != null) {
      return referencedNode.parentNode!.ownerView
          .forDevtoolsNodeId(referencedNode.parentNode!);
    } else {
      return 0;
    }
  }

  /// The BackendNodeId for this node.
  /// Unique DOM node identifier used to reference a node that may not have been pushed to
  /// the front-end. Use native pointer address when available.
  int get backendNodeId => referencedNode.pointer?.address ?? 0;

  /// [Node]'s nodeType.
  int get nodeType => getNodeTypeValue(referencedNode.nodeType);

  /// Node's nodeName (CDP expects uppercase tag for HTML elements).
  String get nodeName => referencedNode.nodeName;

  /// Node's localName.
  String? get localName => referencedNode is Element
      ? (referencedNode as Element).tagName.toLowerCase()
      : null;

  /// Node's nodeValue.
  String get nodeValue {
    if (referencedNode.nodeType == NodeType.TEXT_NODE) {
      TextNode textNode = referencedNode as TextNode;
      return textNode.data;
    } else if (referencedNode.nodeType == NodeType.COMMENT_NODE) {
      Comment comment = referencedNode as Comment;
      return comment.data;
    } else {
      return '';
    }
  }

  int get childNodeCount => referencedNode.childNodes.length;

  List<String>? get attributes {
    if (referencedNode.nodeType == NodeType.ELEMENT_NODE) {
      List<String> attrs = [];
      Element el = referencedNode as Element;
      el.attributes.forEach((key, value) {
        attrs.add(key);
        attrs.add(value.toString());
      });
      return attrs;
    } else {
      return null;
    }
  }

  @override
  Map toJson() {
    return {
      'nodeId': nodeId,
      'backendNodeId': backendNodeId,
      'nodeType': nodeType,
      'localName': localName,
      'nodeName': nodeName,
      'nodeValue': nodeValue,
      'parentId': parentId,
      'childNodeCount': childNodeCount,
      'attributes': attributes,
      if (childNodeCount > 0)
        'children': referencedNode.childNodes
            .where((node) {
              return node is Element ||
                  (node is TextNode && node.data.trim().isNotEmpty);
            })
            .map((Node node) => InspectorNode(node).toJson())
            .toList(),
    };
  }
}

class BoxModel extends JSONEncodable {
  List<double>? content;
  List<double>? padding;
  List<double>? border;
  List<double>? margin;
  int? width;
  int? height;

  BoxModel(
      {this.content,
      this.padding,
      this.border,
      this.margin,
      this.width,
      this.height});

  @override
  Map toJson() {
    return {
      'content': content,
      'padding': padding,
      'border': border,
      'margin': margin,
      'width': width,
      'height': height,
    };
  }
}

class Rect extends JSONEncodable {
  num? x;
  num? y;
  num? width;
  num? height;

  Rect({this.x, this.y, this.width, this.height});

  @override
  Map toJson() {
    return {
      'x': x,
      'y': y,
      'width': width,
      'height': height,
    };
  }
}
