/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */
/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-2024 The WebF authors. All rights reserved.
 */
import 'package:flutter/foundation.dart';
import 'package:webf/dom.dart';
import 'package:webf/html.dart';

typedef InsertNodeHandler = void Function(ContainerNode container, Node child, Node? next);

bool collectChildrenAndRemoveFromOldParent(Node node, List<Node> nodes) {
  if (node is DocumentFragment) {
    getChildNodes(node, nodes);
    node.removeChildren();
    return nodes.isNotEmpty;
  }
  nodes.add(node);
  ContainerNode? oldParent = node.parentNode;
  if (oldParent != null && node.isConnected) {
    oldParent.removeChild(node);
  }
  return nodes.isNotEmpty;
}

void getChildNodes(ContainerNode node, List<Node> nodes) {
  assert(nodes.isEmpty);
  for (Node? child = node.firstChild; child != null; child = child.nextSibling) {
    nodes.add(child);
  }
}

abstract class ContainerNode extends Node {
  ContainerNode(super.nodeType, [super.context]);

  void _adoptAndAppendChild(ContainerNode container, Node child, Node? next) {
    child.parentOrShadowHostNode = this;
    if (lastChild != null) {
      child.previousSibling = lastChild;
      lastChild!.nextSibling = child;
    } else {
      firstChild = child;
    }
    lastChild = child;
  }

  void _adoptAndInsertBefore(ContainerNode container, Node child, Node? next) {
    assert(next!.parentNode == container);

    // Use insertBefore if you need to handle reparenting (and want DOM mutation
    // events).
    assert(child.parentNode == null);
    assert(child.nextSibling == null);
    assert(child.previousSibling == null);

    Node? prev = next!.previousSibling;
    assert(lastChild != prev);
    next.previousSibling = child;
    if (prev != null) {
      assert(firstChild != next);
      assert(prev.nextSibling == next);
      prev.nextSibling = child;
    } else {
      assert(firstChild == next);
      firstChild = child;
    }
    child.parentOrShadowHostNode = this;
    child.previousSibling = prev;
    child.nextSibling = next;
  }

  @mustCallSuper
  @override
  Node insertBefore(Node child, Node referenceNode) {
    // https://dom.spec.whatwg.org/#concept-node-pre-insert

    // insertBefore(node, null) is equivalent to appendChild(node)

    // 1. Ensure pre-insertion validity of node into parent before child.
    // 2. Let reference child be child.
    // 3. If reference child is node, set it to node’s next sibling.
    // Already done at C++ side.

    // 4. Adopt node into parent’s node document.
    List<Node> targets = [];
    if (!collectChildrenAndRemoveFromOldParent(child, targets)) {
      return child;
    }

    // 5. Insert node into parent before reference child.
    _insertNode(targets, referenceNode, _adoptAndInsertBefore);

    // 6. Mark this element dirty only when it can influence selector matching.
    // Avoid marking <head> and <html> which otherwise force root recalcs.
    if (this is Element) {
      final Element el = this as Element;
      if (el is! HeadElement && el is! HTMLElement) {
        ownerDocument.markElementStyleDirty(el, reason: 'childList-insert');
      }
    }

    // 7. Trigger connected callback
    if (child.isConnected) {
      child.connectedCallback();
    }

    // To insert a node into a parent before a child, run step 9 from the spec:
    // 8. Run the children changed steps for parent when inserting a node into a parent.
    // https://dom.spec.whatwg.org/#concept-node-insert
    didInsertNode(targets, referenceNode);

    return child;
  }

  @override
  Node? replaceChild(Node newNode, Node oldNode) {
    // https://dom.spec.whatwg.org/#concept-node-replace
    // Step 2 to 6 are already done at C++ side.

    bool isOldChildConnected = oldNode.isConnected;

    // 7. Let reference child be child’s next sibling.
    Node? next = oldNode.nextSibling;

    // 8. If reference child is node, set it to node’s next sibling.
    if (next == newNode) next = newNode.nextSibling;

    // 10. Adopt node into parent’s node document.
    // Though the following CollectChildrenAndRemoveFromOldParent() also calls
    // RemoveChild(), we'd like to call RemoveChild() here to make a separated
    // MutationRecord.
    ContainerNode? newChildParent = newNode.parentNode;
    if (newChildParent != null) {
      newChildParent.removeChild(newNode);
    }

    // 9. Let previousSibling be child’s previous sibling.
    // 11. Let removedNodes be the empty list.
    // 15. Queue a mutation record of "childList" for target parent with
    // addedNodes nodes, removedNodes removedNodes, nextSibling reference child,
    // and previousSibling previousSibling.

    // 12. If child’s parent is not null, run these substeps:
    //    1. Set removedNodes to a list solely containing child.
    //    2. Remove child from its parent with the suppress observers flag set.
    ContainerNode? oldChildParent = oldNode.parentNode;
    if (oldChildParent != null) {
      oldChildParent.removeChild(oldNode);
    }

    List<Node> targets = [];

    // 13. Let nodes be node’s children if node is a DocumentFragment node, and
    // a list containing solely node otherwise.
    if (!collectChildrenAndRemoveFromOldParent(newNode, targets)) return oldNode;
    // 10. Adopt node into parent’s node document.
    // 14. Insert node into parent before reference child with the suppress
    // observers flag set.
    if (next != null) {
      _insertNode(targets, next, _adoptAndInsertBefore);
    } else {
      _insertNode(targets, null, _adoptAndAppendChild);
    }

    if (isOldChildConnected) {
      oldNode.disconnectedCallback();
      newNode.connectedCallback();
    }

    didInsertNode(targets, next);

    return oldNode;
  }

  @override
  Node? removeChild(Node child) {
    if (this is Element) {
      final Element el = this as Element;
      if (el is! HeadElement && el is! HTMLElement) {
        ownerDocument.markElementStyleDirty(el, reason: 'childList-remove');
      }
    }

    bool isOldChildConnected = child.isConnected;
    assert(child.parentNode == this);

    Node? prev = child.previousSibling;
    Node? next = child.nextSibling;
    removeBetween(prev, next, child);
    notifyNodeRemoved(child);

    if (isOldChildConnected) {
      child.disconnectedCallback();
    }

    // 21. Run the children changed steps for parent.
    // https://dom.spec.whatwg.org/#concept-node-remove
    childrenChanged(ChildrenChange.forRemoval(child, prev, next, ChildrenChangeSource.API));

    return child;
  }

  void _insertNode(
      List<Node> targets, Node? next, InsertNodeHandler mutator) {
    for (final targetNode in targets) {
      assert(targetNode.parentNode == null);
      mutator(this, targetNode, next);
      notifyNodeInsertedInternal(targetNode);
    }
  }

  @mustCallSuper
  @override
  Node appendChild(Node child) {

    List<Node> targets = [];
    if (!collectChildrenAndRemoveFromOldParent(child, targets)) {
      return child;
    }

    _insertNode(targets, null, _adoptAndAppendChild);

    if (this is Element) {
      final Element el = this as Element;
      if (el is! HeadElement && el is! HTMLElement) {
        ownerDocument.markElementStyleDirty(el, reason: 'childList-append');
      }
    }

    if (child.isConnected) {
      child.connectedCallback();
    }

    didInsertNode(targets, null);

    return child;
  }

  void removeChildren() {
    if (firstChild == null) {
      return;
    }

    Node? child = firstChild;
    while (child != null) {
      removeBetween(null, child.nextSibling, child);
      notifyNodeRemoved(child);
    }

    ContainerNode thisNode = this;
    thisNode.ensureNodeData().ensureChildNodeList(thisNode).invalidateCache();
  }

  void notifyNodeRemoved(Node node) {
    node.isConnected = false;
  }

  void notifyNodeInsertedInternal(Node root) {
    if (!isConnected) return;
    root.isConnected = isConnected;
  }

  void removeBetween(Node? previousChild, Node? nextChild, Node oldChild) {
    assert(oldChild.parentNode == this);

    if (nextChild != null) {
      nextChild.previousSibling = previousChild;
    }
    if (previousChild != null) {
      previousChild.nextSibling = nextChild;
    }
    if (firstChild == oldChild) {
      firstChild = nextChild;
    }
    if (lastChild == oldChild) {
      lastChild = previousChild;
    }

    oldChild.previousSibling = null;
    oldChild.nextSibling = null;
    oldChild.parentOrShadowHostNode = null;
  }

  void didInsertNode(List<Node> targets, Node? next) {
    Node? unchangedPrevious = targets.isNotEmpty ? targets[0].previousSibling : null;

    for (final targetNode in targets) {
      childrenChanged(ChildrenChange.forInsertion(targetNode, unchangedPrevious, next, ChildrenChangeSource.API));
    }
  }

  @override
  void childrenChanged(ChildrenChange change) {
    super.childrenChanged(change);
    invalidateNodeListCachesInAncestors(change);
  }

  void invalidateNodeListCachesInAncestors(ChildrenChange? change) {
    // This is a performance optimization, NodeList cache invalidation is
    // not necessary for a text change.
    if (change != null && change.type == ChildrenChangeType.TEXT_CHANGE) {
      return;
    }

    if (nodeData != null) {
      if (nodeData!.nodeList is ChildNodeList) {
        if (change != null) {
          (nodeData!.nodeList as ChildNodeList).childrenChanged(change);
        } else {
          (nodeData!.nodeList as ChildNodeList).invalidateCache();
        }
      }
      if (parentNode != null) {
        ownerDocument.nthIndexCache.invalidateWithParentNode(parentNode!);
      }
    }

    // This is a performance optimization, NodeList cache invalidation is
    // not necessary for non-element nodes.
    if (change != null &&
        change.affectsElements == ChildrenChangeAffectsElements.NO) {
      return;
    }

    ContainerNode? node = this;
    while (node != null) {
      NodeList lists = node.childNodes;
      if (lists is ChildNodeList) {
        lists.invalidateCache();
      }
      node = node.parentNode;
    }
    if (parentNode != null) {
      ownerDocument.nthIndexCache.invalidateWithParentNode(parentNode!);
    }
  }

  Node? _firstChild;

  @override
  Node? get firstChild => _firstChild;

  Node? get firstAttachedRenderChild {
    Node? firstChild = _firstChild;
    do {
      if (firstChild?.attachedRenderer != null) {
        return firstChild;
      }
      firstChild = firstChild?.nextSibling;
    } while(firstChild != null);
    return null;
  }

  set firstChild(Node? value) {
    _firstChild = value;
  }

  Node? _lastChild;

  @override
  Node? get lastChild => _lastChild;

  Node? get lastAttachedRenderChild {
    Node? lastChild = _lastChild;
    do {
      if (lastChild?.attachedRenderer != null) {
        return lastChild;
      }
      lastChild = lastChild?.previousSibling;
    } while(lastChild != null);
    return null;
  }


  set lastChild(Node? value) {
    _lastChild = value;
  }
}
