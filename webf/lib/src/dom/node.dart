/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart' show Widget;
import 'package:webf/dom.dart';
import 'package:webf/foundation.dart';
import 'package:webf/widget.dart';

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

enum RenderObjectManagerType { FLUTTER_ELEMENT, WEBF_NODE }

typedef NoteVisitor = void Function(Node node);

/// [RenderObjectNode] provide the renderObject related abstract life cycle for
/// [Node] or [Element]s, which wrap [RenderObject]s, which provide the actual
/// rendering of the application.
abstract class RenderObjectNode {
  RenderBox? get renderer;

  /// Creates an instance of the [RenderObject] class that this
  /// [RenderObjectNode] represents, using the configuration described by this
  /// [RenderObjectNode].
  ///
  /// This method should not do anything with the children of the render object.
  /// That should instead be handled by the method that overrides
  /// [Node.attachTo] in the object rendered by this object.
  RenderBox createRenderer();

  /// The renderObject will be / has been insert into parent. You can apply properties
  /// to renderObject.
  ///
  /// This method should not do anything to update the children of the render
  /// object.
  @protected
  void willAttachRenderer();

  @protected
  void didAttachRenderer();

  /// A render object previously associated with this Node will be / has been removed
  /// from the tree. The given [RenderObject] will be of the same type as
  /// returned by this object's [createRenderer].
  @protected
  void willDetachRenderer();

  @protected
  void didDetachRenderer();
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
  Widget? get flutterWidget => null;
  /// WebF nodes could be wrapped by [WebFElementToWidgetAdaptor] and the renderObject of this node is managed by Flutter framework.
  /// So if managedByFlutterWidget is true, WebF DOM can not disposed Node's renderObject directly.
  bool managedByFlutterWidget = false;
  /// true if node are created by Flutter widgets.
  bool createdByFlutterWidget = false;
  List<Node> childNodes = [];

  /// The Node.parentNode read-only property returns the parent of the specified node in the DOM tree.
  Node? parentNode;
  NodeType nodeType;
  String get nodeName;

  // Children changed steps for node.
  // https://dom.spec.whatwg.org/#concept-node-children-changed-ext
  void childrenChanged() {
    if (!isConnected) {
      return;
    }

    // invalidate style
    Node parent = this;
    while (parent.parentNode != null) {
      parent.needsStyleRecalculate = true;
      parent = parent.parentNode!;
    }
    ownerDocument.needsStyleRecalculate = true;
    ownerDocument.updateStyleIfNeeded();
  }

  // FIXME: The ownerDocument getter steps are to return null, if this is a document; otherwise this’s node document.
  // https://dom.spec.whatwg.org/#dom-node-ownerdocument
  late Document ownerDocument;

  bool needsStyleRecalculate = true;

  /// The Node.parentElement read-only property returns the DOM node's parent Element,
  /// or null if the node either has no parent, or its parent isn't a DOM Element.
  Element? get parentElement {
    if (parentNode != null && parentNode!.nodeType == NodeType.ELEMENT_NODE) {
      return parentNode as Element;
    }
    return null;
  }

  Element? get previousElementSibling {
    if (previousSibling != null && previousSibling!.nodeType == NodeType.ELEMENT_NODE) {
      return previousSibling as Element;
    }
    return null;
  }

  Element? get nextElementSibling {
    if (nextSibling != null && nextSibling!.nodeType == NodeType.ELEMENT_NODE) {
      return nextSibling as Element;
    }
    return null;
  }

  Node(this.nodeType, [BindingContext? context]) : super(context);

  // If node is on the tree, the root parent is body.
  bool get isConnected {
    // If renderer is attached, which means node must been connected.
    if (isRendererAttached) return true;

    Node parent = this;
    while (parent.parentNode != null) {
      parent = parent.parentNode!;
    }
    return parent == ownerDocument;
  }

  Node get firstChild => childNodes.first;

  Node get lastChild => childNodes.last;

  Node? get previousSibling {
    if (parentNode == null) return null;
    int index = parentNode!.childNodes.indexOf(this);
    if (index - 1 < 0) return null;
    return parentNode!.childNodes[index - 1];
  }

  Node? get nextSibling {
    if (parentNode == null) return null;
    int index = parentNode!.childNodes.indexOf(this);
    if (index + 1 > parentNode!.childNodes.length - 1) return null;
    return parentNode!.childNodes[index + 1];
  }

  // Is child renderObject attached.
  bool get isRendererAttached => renderer != null && renderer!.attached;

  bool contains(Node child) {
    return childNodes.contains(child);
  }

  /// Attach a renderObject to parent.
  void attachTo(Element parent, {RenderBox? after}) {}

  /// Unmount referenced render object.
  void unmountRenderObject({bool deep = false, bool keepFixedAlive = false}) {}

  /// Release any resources held by this node.
  @override
  void dispose() {
    parentNode?.removeChild(this);
    assert(!isRendererAttached, 'Should unmount $this before calling dispose.');
    super.dispose();
  }

  @override
  RenderBox createRenderer() => throw FlutterError('[createRenderer] is not implemented.');

  @override
  void willAttachRenderer() {}

  @override
  void didAttachRenderer() {}

  @override
  void willDetachRenderer() {}

  @override
  void didDetachRenderer() {}

  void visitChild(NoteVisitor visitor) {
    childNodes.forEach((node) {
      node.visitChild(visitor);
      visitor(node);
    });
  }

  @mustCallSuper
  Node appendChild(Node child) {
    child._ensureOrphan();
    child.parentNode = this;
    childNodes.add(child);

    if (child.isConnected) {
      child.connectedCallback();
    }

    // To insert a node into a parent before a child, run step 9 from the spec:
    // 9. Run the children changed steps for parent when inserting a node into a parent.
    // https://dom.spec.whatwg.org/#concept-node-insert
    childrenChanged();

    return child;
  }

  @mustCallSuper
  Node insertBefore(Node child, Node referenceNode) {
    child._ensureOrphan();
    int referenceIndex = childNodes.indexOf(referenceNode);
    if (referenceIndex == -1) {
      return appendChild(child);
    } else {
      child.parentNode = this;
      childNodes.insert(referenceIndex, child);

      if (child.isConnected) {
        child.connectedCallback();
      }

      // To insert a node into a parent before a child, run step 9 from the spec:
      // 9. Run the children changed steps for parent when inserting a node into a parent.
      // https://dom.spec.whatwg.org/#concept-node-insert
      childrenChanged();

      return child;
    }
  }

  @mustCallSuper
  Node removeChild(Node child) {
    // Not remove node type which is not present in RenderObject tree such as Comment
    // Only append node types which is visible in RenderObject tree
    // Only remove childNode when it has parent
    if (child.isRendererAttached) {
      child.unmountRenderObject();
    }

    if (childNodes.contains(child)) {
      bool isConnected = child.isConnected;
      childNodes.remove(child);
      child.parentNode = null;

      if (isConnected) {
        child.disconnectedCallback();
      }

      // To remove a node, run step 21 from the spec:
      // 21. Run the children changed steps for parent.
      // https://dom.spec.whatwg.org/#concept-node-remove
      childrenChanged();
    }
    return child;
  }

  @mustCallSuper
  Node? replaceChild(Node newNode, Node oldNode) {
    Node? replacedNode;
    if (childNodes.contains(oldNode)) {
      newNode._ensureOrphan();
      bool isOldNodeConnected = oldNode.isConnected;
      int referenceIndex = childNodes.indexOf(oldNode);
      oldNode.parentNode = null;
      newNode.parentNode = this;
      replacedNode = oldNode;
      childNodes[referenceIndex] = newNode;

      if (isOldNodeConnected) {
        oldNode.disconnectedCallback();
        newNode.connectedCallback();
      }

      // To insert a node into a parent before a child, run step 9 from the spec:
      // 9. Run the children changed steps for parent when inserting a node into a parent.
      // https://dom.spec.whatwg.org/#concept-node-insert
      childrenChanged();
    }
    return replacedNode;
  }

  /// Ensure node is not connected to a parent element.
  void _ensureOrphan() {
    Node? _parent = parentNode;
    if (_parent != null) {
      _parent.removeChild(this);
    }
  }

  /// Ensure child and child's child render object is attached.
  void ensureChildAttached() {}

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
  void dispatchEvent(Event event) {
    if (disposed) return;
    super.dispatchEvent(event);
  }

  @override
  EventTarget? get parentEventTarget => parentNode;

  // Whether Kraken Node need to manage render object.
  RenderObjectManagerType get renderObjectManagerType => RenderObjectManagerType.WEBF_NODE;

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
