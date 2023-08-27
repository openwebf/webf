/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'package:webf/dom.dart';
import 'style_traversal_root.dart';

class StyleInvalidationRoot extends StyleTraversalRoot {
  Element? rootElement() {
    assert(rootNode != null);
    if (rootNode!.isDocumentNode()) {
      return rootNode!.ownerDocument.documentElement;
    }
    return rootNode as Element?;
  }

  @override
  ContainerNode? parent(Node node) {
    return node.parentNode;
  }

  @override
  bool isChildDirty(Node node) {
    return node.childNeedsStyleRecalc;
  }

  @override
  bool isDirty(Node node) {
    return node.needsStyleInvalidation;
  }

  @override
  void subtreeModified(ContainerNode parent) {
    if (rootNode == null || rootNode!.isConnected) {
      return;
    }
    for (Node? ancestor = parent; ancestor != null; ancestor = ancestor.parentNode) {
      assert(ancestor.childNeedsStyleInvalidation);
      assert(!ancestor.needsStyleInvalidation);
      ancestor.childNeedsStyleRecalc = false;
    }
    clear(); // Assuming there is a clear method in StyleTraversalRoot or its subclass
  }
}
