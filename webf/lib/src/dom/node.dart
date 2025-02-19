/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart' as flutter;
import 'package:webf/dom.dart';
import 'package:webf/bridge.dart';
import 'package:webf/rendering.dart';
import 'node_data.dart';

enum NodeType {
  ELEMENT_NODE,
  TEXT_NODE,
  COMMENT_NODE,
  DOCUMENT_NODE,
  DOCUMENT_FRAGMENT_NODE,
}

enum DocumentPosition {
  EQUIVALENT,
  DISCONNECTED,
  PRECEDING,
  FOLLOWING,
  CONTAINS,
  CONTAINED_BY,
  IMPLEMENTATION_SPECIFIC,
}

enum ChildrenChangeType {
  ELEMENT_INSERTED,
  NON_ELEMENT_INSERTED,
  ELEMENT_REMOVED,
  NON_ELEMENT_REMOVED,
  ALL_CHILDREN_REMOVED,
  TEXT_CHANGE
}

enum ChildrenChangeSource { API, PARSER }

enum ChildrenChangeAffectsElements { NO, YES }

class ChildrenChange {
  final ChildrenChangeType type;
  final ChildrenChangeSource byParser;
  final ChildrenChangeAffectsElements affectsElements;
  final Node? siblingChanged;
  final Node? siblingBeforeChange;
  final Node? siblingAfterChange;
  final List<Node>? removedNodes;
  final String? oldText;

  ChildrenChange({
    required this.type,
    required this.byParser,
    required this.affectsElements,
    this.siblingChanged,
    this.siblingBeforeChange,
    this.siblingAfterChange,
    this.removedNodes,
    this.oldText,
  });

  factory ChildrenChange.forInsertion(
      Node node, Node? unchangedPrevious, Node? unchangedNext, ChildrenChangeSource byParser) {
    return ChildrenChange(
      type: node.isElementNode() ? ChildrenChangeType.ELEMENT_INSERTED : ChildrenChangeType.NON_ELEMENT_INSERTED,
      byParser: byParser,
      affectsElements: node.isElementNode() ? ChildrenChangeAffectsElements.YES : ChildrenChangeAffectsElements.NO,
      siblingChanged: node,
      siblingBeforeChange: unchangedPrevious,
      siblingAfterChange: unchangedNext,
    );
  }

  factory ChildrenChange.forRemoval(
      Node node, Node? previousSibling, Node? nextSibling, ChildrenChangeSource byParser) {
    return ChildrenChange(
      type: node.isElementNode() ? ChildrenChangeType.ELEMENT_REMOVED : ChildrenChangeType.NON_ELEMENT_REMOVED,
      byParser: byParser,
      affectsElements: node.isElementNode() ? ChildrenChangeAffectsElements.YES : ChildrenChangeAffectsElements.NO,
      siblingChanged: node,
      siblingBeforeChange: previousSibling,
      siblingAfterChange: nextSibling,
    );
  }

  bool isChildInsertion() {
    return type == ChildrenChangeType.ELEMENT_INSERTED || type == ChildrenChangeType.NON_ELEMENT_INSERTED;
  }

  bool isChildRemoval() {
    return type == ChildrenChangeType.ELEMENT_REMOVED || type == ChildrenChangeType.NON_ELEMENT_REMOVED;
  }

  bool isChildElementChange() {
    return type == ChildrenChangeType.ELEMENT_INSERTED || type == ChildrenChangeType.ELEMENT_REMOVED;
  }
}

enum RenderObjectManagerType { FLUTTER_ELEMENT, WEBF_NODE }

typedef NodeVisitor = void Function(Node node);

/// [RenderObjectNode] provide the renderObject related abstract life cycle for
/// [Node] or [Element]s, which wrap [RenderObject]s, which provide the actual
/// rendering of the application.
abstract class RenderObjectNode {
  RenderBox? get domRenderer;

  RenderBox? get attachedRenderer;

  /// Creates an instance of the [RenderObject] class that this
  /// [RenderObjectNode] represents, using the configuration described by this
  /// [RenderObjectNode].
  ///
  /// This method should not do anything with the children of the render object.
  /// That should instead be handled by the method that overrides
  RenderBox createRenderer();

  /// The renderObject will be / has been insert into parent. You can apply properties
  /// to renderObject.
  ///
  /// This method should not do anything to update the children of the render
  /// object.
  @protected
  void willAttachRenderer(flutter.RenderObjectElement? flutterWidgetElement);

  @protected
  void didAttachRenderer(flutter.RenderObjectElement? flutterWidgetElement);

  /// A render object previously associated with this Node will be / has been removed
  /// from the tree. The given [RenderObject] will be of the same type as
  /// returned by this object's [createRenderer].
  @protected
  void willDetachRenderer(flutter.RenderObjectElement? flutterWidgetElement);

  @protected
  void didDetachRenderer(flutter.RenderObjectElement? flutterWidgetElement);
}

/// Lifecycle that triggered when node tree changes.
/// Ref: https://html.spec.whatwg.org/multipage/custom-elements.html#concept-custom-element-definition-lifecycle-callbacks
abstract class LifecycleCallbacks {
  // Invoked each time the custom element is appended into a document-connected element.
  // This will happen each time the node is moved, and may happen before the element's
  // contents have been fully parsed.
  void connectedCallback();

  // Invoked each time the custom element is disconnected from the document's DOM.
  void disconnectedCallback();

// Invoked each time the custom element is moved to a new document.
// @TODO: Currently only single document exists, this callback will never be triggered.
// void adoptedCallback();

// @TODO: [attributeChangedCallback] works with static getter [observedAttributes].
// void attributeChangedCallback();
}

abstract class Node extends EventTarget implements RenderObjectNode, LifecycleCallbacks {
  /// WebF nodes could be wrapped by [WebFRenderLayoutWidgetAdaptor] and the renderObject of this node is managed by Flutter framework.
  /// So if managedByFlutterWidget is true, WebF DOM can not disposed Node's renderObject directly.
  bool _managedByFlutterWidget = false;

  bool get managedByFlutterWidget => _managedByFlutterWidget;

  // Determine if this node or element was created by flutter widget
  // If this value is true, this node won't participate the DOM event system.
  bool isWidgetOwned = false;

  set managedByFlutterWidget(bool value) {
    if (_managedByFlutterWidget) return;

    _managedByFlutterWidget = true;

    Node? first = firstChild;
    while (first != null) {
      first.managedByFlutterWidget = true;
      first = first.nextSibling;
    }
  }

  /// The Node.parentNode read-only property returns the parent of the specified node in the DOM tree.
  ContainerNode? get parentNode => parentOrShadowHostNode;

  ContainerNode? _parentOrShadowHostNode;

  ContainerNode? get parentOrShadowHostNode => _parentOrShadowHostNode;

  set parentOrShadowHostNode(ContainerNode? value) {
    _parentOrShadowHostNode = value;
  }

  Node? _previous;
  Node? _next;

  Node? get firstChild;

  Node? get lastChild;

  NodeType nodeType;

  String get nodeName;

  NodeData? _node_data;

  NodeData? get nodeData => _node_data;

  NodeData ensureNodeData() {
    _node_data ??= NodeData();
    return _node_data!;
  }

  Node treeRoot() {
    Node? currentNode = this;
    while (currentNode!.parentNode != null) {
      currentNode = currentNode.parentNode;
    }
    return currentNode;
  }

  // Children changed steps for node.
  // https://dom.spec.whatwg.org/#concept-node-children-changed-ext
  void childrenChanged(ChildrenChange change) {
    if (!isConnected) {
      return;
    }
    ownerDocument.updateStyleIfNeeded();
  }

  // https://dom.spec.whatwg.org/#dom-node-ownerdocument
  Document get ownerDocument => ownerView.document;

  /// The Node.parentElement read-only property returns the DOM node's parent Element,
  /// or null if the node either has no parent, or its parent isn't a DOM Element.
  Element? get parentElement {
    if (parentNode != null && parentNode!.nodeType == NodeType.ELEMENT_NODE) {
      return parentNode as Element;
    }
    return null;
  }

  Element? get previousElementSibling {
    Node? previous = previousSibling;
    while (previous != null) {
      if (previous is Element) {
        return previous;
      }
      previous = previous.previousSibling;
    }
    return null;
  }

  Element? get nextElementSibling {
    Node? next = nextSibling;
    while (next != null) {
      if (next is Element) {
        return next;
      }
      next = next.nextSibling;
    }
    return null;
  }

  Node(this.nodeType, [BindingContext? context]) : super(context);

  bool _isConnected = false;

  set isConnected(bool value) {
    _isConnected = value;

    Node? first = firstChild;
    while (first != null) {
      first.isConnected = value;
      first = first.nextSibling;
    }
  }

  // If node is on the tree, the root parent is body.
  bool get isConnected => _isConnected;

  bool isInTreeScope() {
    return isConnected;
  }

  Node? get previousSibling => _previous;

  Node? get attachedRenderPreviousSibling {
    Node? previousSibling = this.previousSibling;
    do {
      if (previousSibling?.attachedRenderer != null) return previousSibling;
      previousSibling = previousSibling?.previousSibling;
    } while (previousSibling != null);
    return null;
  }

  set previousSibling(Node? value) {
    _previous = value;
  }

  Node? get nextSibling => _next;

  Node? get attachedRenderNextSibling {
    Node? nextSibling = this.nextSibling;
    do {
      if (nextSibling?.attachedRenderer != null) return nextSibling;
      nextSibling = nextSibling?.nextSibling;
    } while (nextSibling != null);
    return null;
  }

  set nextSibling(Node? value) {
    _next = value;
  }

  NodeList get childNodes {
    if (this is ContainerNode) {
      return ensureNodeData().ensureChildNodeList(this as ContainerNode);
    }
    return ensureNodeData().ensureEmptyChildNodeList(this);
  }

  flutter.Widget toWidget({Key? key}) {
    throw FlutterError('UnKnown node types for widget conversion');
  }

  // Is child renderObject attached.
  bool get isRendererAttached;

  // Is child renderObject attached to the render object tree segment, and may be this segment are not attached to flutter.
  bool get isRendererAttachedToSegmentTree;

  bool isDescendantOf(Node? other) {
    // Return true if other is an ancestor of this, otherwise false
    if (other == null || isConnected != other.isConnected) {
      return false;
    }
    if (other.ownerDocument != ownerDocument) {
      return false;
    }
    ContainerNode? n = parentNode;
    while (n != null) {
      if (n == other) {
        return true;
      }
      n = n.parentNode;
    }
    return false;
  }

  /// Release any resources held by this node.
  @override
  void dispose() async {
    if (isConnected) {
      parentNode?.removeChild(this);
    }
    if (this is! Document && !managedByFlutterWidget) {
      assert(!isRendererAttachedToSegmentTree, 'Should unmount $this before calling dispose.');
    }
    super.dispose();
  }

  @override
  RenderBox createRenderer([WebRenderLayoutRenderObjectElement? flutterWidgetElement]) =>
      throw FlutterError('[createRenderer] is not implemented.');

  @override
  RenderObject willAttachRenderer([flutter.RenderObjectElement? flutterWidgetElement]) =>
      throw FlutterError('[willAttachRenderer] is not implemented.');

  @override
  void didAttachRenderer(flutter.RenderObjectElement? flutterWidgetElement) {}

  @override
  void willDetachRenderer(flutter.RenderObjectElement? flutterWidgetElement) {}

  @override
  void didDetachRenderer(flutter.RenderObjectElement? flutterWidgetElement) {}

  Node? appendChild(Node child) {
    return null;
  }

  Node? insertBefore(Node child, Node referenceNode) {
    return null;
  }

  Node? removeChild(Node child) {
    return null;
  }

  Node? replaceChild(Node newNode, Node oldNode) {
    return null;
  }

  @override
  void connectedCallback() {
    for (var child in childNodes) {
      child.connectedCallback();
    }
  }

  @override
  void disconnectedCallback() {
    for (var child in childNodes) {
      child.disconnectedCallback();
    }
  }

  @override
  Future<void> dispatchEvent(Event event) async {
    if (disposed) return;
    super.dispatchEvent(event);
  }

  @override
  EventTarget? get parentEventTarget => parentNode;

  // Whether Kraken Node need to manage render object.
  RenderObjectManagerType get renderObjectManagerType => RenderObjectManagerType.WEBF_NODE;

  // ---------------------------------------------------------------------------
  // Notification of document structure changes (see container_node.h for more
  // notification methods)
  //
  // InsertedInto() implementations must not modify the DOM tree, and must not
  // dispatch synchronous events.
  void insertedInto(ContainerNode insertionPoint) {
    assert(insertionPoint.isConnected || isContainerNode());
    if (insertionPoint.isConnected) {
      _isConnected = true;
    }
  }

  void removedFrom(ContainerNode insertionPoint) {
    assert(insertionPoint.isConnected || isContainerNode());
    if (insertionPoint.isConnected) {
      _isConnected = false;
    }
  }

  bool isTextNode() {
    return this is TextNode;
  }

  bool isContainerNode() {
    return this is ContainerNode;
  }

  bool isElementNode() {
    return this is Element;
  }

  bool isDocumentFragment() {
    return this is DocumentFragment;
  }

  bool hasChildren() {
    return firstChild != null;
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty('nodeType', nodeType));
    properties.add(DiagnosticsProperty('nodeName', nodeName));
    properties.add(DiagnosticsProperty('managedByFlutterWidget', managedByFlutterWidget));
    properties.add(DiagnosticsProperty('isConnected', isConnected));
    properties.add(DiagnosticsProperty('isRendererAttached', isRendererAttached));
    properties.add(DiagnosticsProperty('isRendererAttachedToSegmentTree', isRendererAttachedToSegmentTree));
    properties.add(DiagnosticsProperty('renderObjectManagerType', renderObjectManagerType));
  }

  @override
  List<DiagnosticsNode> debugDescribeChildren() {
    final List<DiagnosticsNode> children = <DiagnosticsNode>[];
    if (firstChild != null) {
      Node child = firstChild!;
      int count = 1;
      while (true) {
        children.add(child.toDiagnosticsNode(name: 'child $count'));
        if (child == lastChild) {
          break;
        }
        count += 1;
        child = child.nextSibling!;
      }
    }
    return children;
  }

  static RenderBox? findMostClosedSiblings(Node? previousSibling) {
    RenderBox? afterRenderObject = previousSibling?.domRenderer;

    // Found the most closed
    if (afterRenderObject == null) {
      Node? ref = previousSibling?.previousSibling;
      while (ref != null && afterRenderObject == null) {
        afterRenderObject = ref.domRenderer;
        ref = ref.previousSibling;
      }
    }

    // Renderer of referenceNode may not moved to a difference place compared to its original place
    // in the dom tree due to position absolute/fixed.
    // Use the renderPositionPlaceholder to get the same place as dom tree in this case.
    if (afterRenderObject is RenderBoxModel) {
      RenderBox? renderPositionPlaceholder = afterRenderObject.renderPositionPlaceholder;
      if (renderPositionPlaceholder != null) {
        afterRenderObject = renderPositionPlaceholder;
      }
    }

    return afterRenderObject;
  }

  static RenderBox? findParentLastRenderBox(Node currentNode) {
    RenderBox? after;
    RenderBox? box = currentNode.domRenderer;
    if (box is RenderLayoutBox) {
      RenderLayoutBox? scrollingContentBox = box.renderScrollingContent;
      if (scrollingContentBox != null) {
        after = scrollingContentBox.lastChild;
      } else {
        after = box.lastChild;
      }
    } else if (box is ContainerRenderObjectMixin<RenderBox, ContainerParentDataMixin<RenderBox>>) {
      after = (box as ContainerRenderObjectMixin<RenderBox, ContainerParentDataMixin<RenderBox>>).lastChild;
    }

    return after;
  }

  DocumentPosition compareDocumentPosition(Node other) {
    if (this == other) {
      return DocumentPosition.EQUIVALENT;
    }

    // We need to find a common ancestor container, and then compare the indices of the two immediate children.
    List<Node> chain1 = [];
    List<Node> chain2 = [];
    Node? current = this;
    while (current != null && current.parentNode != null) {
      chain1.insert(0, current);
      current = current.parentNode;
    }
    current = other;
    while (current != null && current.parentNode != null) {
      chain2.insert(0, current);
      current = current.parentNode;
    }

    // If the two elements don't have a common root, they're not in the same tree.
    if (chain1.first != chain2.first) {
      return DocumentPosition.DISCONNECTED;
    }

    // Walk the two chains backwards and look for the first difference.
    for (int i = 0; i < math.min(chain1.length, chain2.length); i++) {
      if (chain1[i] != chain2[i]) {
        if (chain2[i].nextSibling == null) {
          return DocumentPosition.FOLLOWING;
        }
        if (chain1[i].nextSibling == null) {
          return DocumentPosition.PRECEDING;
        }

        // Otherwise we need to see which node occurs first.  Crawl backwards from child2 looking for child1.
        Node? previousSibling = chain2[i].previousSibling;
        while (previousSibling != null) {
          if (chain1[i] == previousSibling) {
            return DocumentPosition.FOLLOWING;
          }
          previousSibling = previousSibling.previousSibling;
        }
        return DocumentPosition.PRECEDING;
      }
    }
    // There was no difference between the two parent chains, i.e., one was a subset of the other.  The shorter
    // chain is the ancestor.
    return chain1.length < chain2.length ? DocumentPosition.FOLLOWING : DocumentPosition.PRECEDING;
  }
}

/// https://dom.spec.whatwg.org/#dom-node-nodetype
int getNodeTypeValue(NodeType nodeType) {
  switch (nodeType) {
    case NodeType.ELEMENT_NODE:
      return 1;
    case NodeType.TEXT_NODE:
      return 3;
    case NodeType.COMMENT_NODE:
      return 8;
    case NodeType.DOCUMENT_NODE:
      return 9;
    case NodeType.DOCUMENT_FRAGMENT_NODE:
      return 11;
  }
}
