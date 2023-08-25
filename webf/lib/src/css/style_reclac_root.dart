/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'package:webf/dom.dart';
import 'style_traversal_root.dart';

class StyleRecalcRoot extends StyleTraversalRoot {
  Element? rootElement() {
    assert(rootNode != null);
    if (rootNode!.isDocumentNode()) {
      return rootNode!.ownerDocument.documentElement;
    }
    if (rootNode!.isPseudoElement()) {
      return rootNode!.parentElement;
    }
    if (rootNode!.isTextNode()) {
      rootNode = rootNode!.getStyleRecalcParent();
    }
    return rootNode as Element;
  }

  void removedFromFlatTree(Node node) {
    if (rootNode == null) {
      return;
    }
    if (rootNode!.isDocumentNode()) {
      return;
    }
    assert(node.parentElement != null);
    subtreeModified(node.parentElement!);
  }

  @override
  void subtreeModified(ContainerNode parent) {
    if (rootNode == null) {
      return;
    }
    if (rootNode!.isDocumentNode()) {
      return;
    }
    if (isFlatTreeConnected(rootNode!)) {
      return;
    }
    final optAncestor = _firstFlatTreeAncestorForChildDirty(parent);
    if (optAncestor == null) {
      ContainerNode? commonAncestor = parent;
      var newRoot = parent;
      if (!isFlatTreeConnected(parent)) {
        commonAncestor = null;
        newRoot = parent.ownerDocument.documentElement!;
      }
      update(commonAncestor, newRoot);
      assert(!isSingleRoot);
      assert(rootNode == newRoot);
      return;
    }
    for (Element? ancestor = optAncestor; ancestor != null; ancestor = ancestor.getStyleRecalcParent()) {
      assert(ancestor.childNeedsStyleRecalc);
      assert(!ancestor.isDirtyForStyleRecalc);
      ancestor.childNeedsStyleRecalc = false;
    }
    clear();
  }

  @override
  bool isDirty(Node node) {
    return node.isDirtyForStyleRecalc;
  }

  Element? _firstFlatTreeAncestorForChildDirty(ContainerNode parent) {
    if (!parent.isElementNode()) {
      return parent.parentElement;
    }
    return parent as Element?;
  }

  bool isFlatTreeConnected(Node root) {
    if (!root.isConnected) {
      return false;
    }
    return root.isDirtyForStyleRecalc || root.childNeedsStyleRecalc;
  }

  @override
  bool isChildDirty(Node node) {
    return node.childNeedsStyleRecalc;
  }

  @override
  ContainerNode? parent(Node node) {
    return node.getStyleRecalcParent();
  }
}
