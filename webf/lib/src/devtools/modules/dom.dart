/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */
import 'dart:ffi';
import 'dart:ui' as ui;

import 'package:webf/devtools.dart';
import 'package:webf/dom.dart';
import 'package:webf/rendering.dart';
import 'package:flutter/rendering.dart';
import 'package:webf/launcher.dart';
import 'package:webf/svg.dart';

const int DOCUMENT_NODE_ID = 0;
const String DEFAULT_FRAME_ID = 'main_frame';

class InspectDOMModule extends UIInspectorModule {
  @override
  String get name => 'DOM';

  Document get document => devtoolsService.controller!.view.document;
  WebFViewController get view => devtoolsService.controller!.view;
  InspectDOMModule(DevToolsService devtoolsService) : super(devtoolsService);

  @override
  void receiveFromFrontend(int? id, String method, Map<String, dynamic>? params) {
    switch (method) {
      case 'getDocument':
        onGetDocument(id, method, params);
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
      case 'setNodeValue':
        onSetNodeValue(id, params!);
        break;
      case 'pushNodesByBackendIdsToFrontend':
        onPushNodesByBackendIdsToFrontend(id, params!);
        break;
      case 'highlightNode':
        // Highlighting is handled by overlay module
        sendToFrontend(id, null);
        break;
      case 'hideHighlight':
        // Highlighting is handled by overlay module
        sendToFrontend(id, null);
        break;
      case 'resolveNode':
        onResolveNode(id, params!);
        break;
    }
  }

  void onGetNodeForLocation(int? id, Map<String, dynamic> params) {
    int x = params['x'];
    int y = params['y'];

    RenderBox rootRenderObject = document.viewport!;
    BoxHitTestResult result = BoxHitTestResult();
    rootRenderObject.hitTest(result, position: Offset(x.toDouble(), y.toDouble()));
    var hitPath = result.path;
    if (hitPath.isEmpty) {
      sendToFrontend(id, null);
      return;
    }
    // find real img element.
    if (hitPath.first.target is WebFRenderImage ||
          (hitPath.first.target is RenderSVGRoot &&
          (hitPath.first.target as RenderBoxModel).renderStyle.target.pointer == null)) {
      hitPath = hitPath.skip(1);
    }
    if (hitPath.isNotEmpty && hitPath.first.target is RenderBoxModel) {
      RenderObject lastHitRenderBoxModel = result.path.first.target as RenderObject;
      if (lastHitRenderBoxModel is RenderBoxModel) {
        int? targetId = view.forDevtoolsNodeId(lastHitRenderBoxModel.renderStyle.target);
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
    int? nodeId = params['nodeId'];
    if (nodeId == null) return;
    Node? node = view.getBindingObject<Node>(
        Pointer.fromAddress(view.getTargetIdByNodeId(nodeId)));
    if (node != null) {
      inspectedNode = node;
    }
    sendToFrontend(id, null);
  }

  /// https://chromedevtools.github.io/devtools-protocol/tot/DOM/#method-getDocument
  void onGetDocument(int? id, String method, Map<String, dynamic>? params) {
    Node root = this.document.documentElement!;
    InspectorDocument document = InspectorDocument(InspectorNode(root));

    sendToFrontend(id, document);
  }

  void onGetBoxModel(int? id, Map<String, dynamic> params) {
    int? nodeId = params['nodeId'];
    if (nodeId == null) return;
    Node? node = view.getBindingObject<Node>(
        Pointer.fromAddress(view.getTargetIdByNodeId(nodeId)));

    Element? element = null;
    if (node is Element) element = node;

    // BoxModel design to BorderBox in kraken.
    if (element != null && element.renderStyle.hasRenderBox() && element.renderStyle.isBoxModelHaveSize()) {
      ui.Offset contentBoxOffset = element.renderStyle.localToGlobal(ui.Offset.zero, ancestor: element.ownerDocument.viewport);

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
    int? nodeId = params['nodeId'];
    if (nodeId == null) return;
    
    Node? node = view.getBindingObject<Node>(
        Pointer.fromAddress(view.getTargetIdByNodeId(nodeId)));
    if (node != null && node.parentNode != null) {
      node.parentNode!.removeChild(node);
    }
    sendToFrontend(id, null);
  }
  
  void onSetAttributesAsText(int? id, Map<String, dynamic> params) {
    int? nodeId = params['nodeId'];
    String? text = params['text'];
    if (nodeId == null) return;
    
    Node? node = view.getBindingObject<Node>(
        Pointer.fromAddress(view.getTargetIdByNodeId(nodeId)));
    if (node is Element && text != null) {
      // Parse attribute text (format: attr1="value1" attr2="value2")
      // For now, just clear and set new attributes
      node.attributes.clear();
      
      // Simple parsing - this could be improved
      final regex = RegExp(r'(\w+)="([^"]*)"');
      for (final match in regex.allMatches(text)) {
        final attrName = match.group(1);
        final attrValue = match.group(2);
        if (attrName != null && attrValue != null) {
          node.setAttribute(attrName, attrValue);
        }
      }
    }
    sendToFrontend(id, null);
  }
  
  void onGetOuterHTML(int? id, Map<String, dynamic> params) {
    int? nodeId = params['nodeId'];
    if (nodeId == null) return;
    
    Node? node = view.getBindingObject<Node>(
        Pointer.fromAddress(view.getTargetIdByNodeId(nodeId)));
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
      
      sendToFrontend(id, JSONEncodableMap({
        'outerHTML': outerHTML,
      }));
    } else {
      sendToFrontend(id, JSONEncodableMap({
        'outerHTML': '',
      }));
    }
  }
  
  void onSetNodeValue(int? id, Map<String, dynamic> params) {
    int? nodeId = params['nodeId'];
    String? value = params['value'];
    if (nodeId == null) return;
    
    Node? node = view.getBindingObject<Node>(
        Pointer.fromAddress(view.getTargetIdByNodeId(nodeId)));
    if (node is TextNode && value != null) {
      node.data = value;
    }
    sendToFrontend(id, null);
  }
  
  void onPushNodesByBackendIdsToFrontend(int? id, Map<String, dynamic> params) {
    List? backendNodeIds = params['backendNodeIds'];
    if (backendNodeIds == null) {
      sendToFrontend(id, JSONEncodableMap({
        'nodeIds': [],
      }));
      return;
    }
    
    List<int> nodeIds = [];
    for (var backendId in backendNodeIds) {
      if (backendId is int) {
        Node? node = view.getBindingObject<Node>(Pointer.fromAddress(backendId));
        if (node != null) {
          nodeIds.add(view.forDevtoolsNodeId(node));
        }
      }
    }
    
    sendToFrontend(id, JSONEncodableMap({
      'nodeIds': nodeIds,
    }));
  }
  
  void onResolveNode(int? id, Map<String, dynamic> params) {
    int? nodeId = params['nodeId'];
    if (nodeId == null) return;
    
    Node? node = view.getBindingObject<Node>(
        Pointer.fromAddress(view.getTargetIdByNodeId(nodeId)));
    if (node != null) {
      // Return a remote object reference for the node
      sendToFrontend(id, JSONEncodableMap({
        'object': {
          'type': 'object',
          'subtype': 'node',
          'className': node.nodeName,
          'description': node.nodeName,
          'objectId': '${nodeId}',
        }
      }));
    } else {
      sendToFrontend(id, null);
    }
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
  /// the front-end.
  int backendNodeId = 0;

  /// [Node]'s nodeType.
  int get nodeType => getNodeTypeValue(referencedNode.nodeType);

  /// Node's nodeName.
  String get nodeName => referencedNode.nodeName.toLowerCase();

  /// Node's localName.
  String? localName;

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
        'children': referencedNode.childNodes.where((node) {
          return node is Element || (node is TextNode && node.data.isNotEmpty);
        }).map((Node node) => InspectorNode(node).toJson()).toList(),
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

  BoxModel({this.content, this.padding, this.border, this.margin, this.width, this.height});

  @override
  Map toJson() {
    return {
      'content': content,
      'padding': padding,
      'border': border,
      'margin': content,
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
