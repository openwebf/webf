/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

// Class used to represent a common ancestor for all dirty nodes in a DOM tree.
// Subclasses implement the various types of dirtiness for style recalc, style
// invalidation, and layout tree rebuild. The common ancestor is used as a
// starting point for traversal to avoid unnecessary DOM tree traversal.
//
// The first dirty node is stored as a single root. When a second node is
// added with a common child-dirty ancestor which is not dirty, we store that
// as a common root. Any subsequent dirty nodes added whose closest child-dirty
// ancestor is not itself dirty, or is the current root, will cause us to fall
// back to use the document as the root node. In order to find a lowest common
// ancestor we would have had to traverse up the ancestor chain to see if we are
// below the current common root or not.
//
// Note that when the common ancestor candidate passed into Update is itself
// dirty, we know that we are currently below the current root node and don't
// have to modify it.

import 'dart:core';
import 'package:webf/dom.dart';

enum RootType { kSingleRoot, kCommonRoot }

abstract class StyleTraversalRoot {
  // Dart doesn't have an equivalent for DISALLOW_NEW() or the macro-based system
  // that C++ uses. So, we're skipping that.

  StyleTraversalRoot();

  void update(ContainerNode? commonAncestor, Node dirtyNode) {
    assert(dirtyNode.isConnected);
    _assertRootNodeInvariants();

    if (commonAncestor == null) {
      // Equivalent logic for checking if the node is a document node or root node.
      Element? documentElement = dirtyNode.ownerDocument.documentElement;
      if (dirtyNode.isDocumentNode() ||
          (rootNode != null && dirtyNode == documentElement)) {
        rootType = RootType.kCommonRoot;
      } else {
        assert(documentElement == null ||
            (rootNode == null && rootType == RootType.kSingleRoot));
      }
      rootNode = dirtyNode;
      _assertRootNodeInvariants();
      return;
    }

    assert(rootNode != null);
    if (commonAncestor == rootNode || isDirty(commonAncestor)) {
      rootType = RootType.kCommonRoot;
      return;
    }
    if (rootType == RootType.kCommonRoot) {
      rootNode = commonAncestor.ownerDocument;
      return;
    }
    rootNode = commonAncestor;
    rootType = RootType.kCommonRoot;
  }

  void subtreeModified(ContainerNode parent);

  Node? get rootNode => _rootNode;
  set rootNode(Node? node) {
    _rootNode = node;
  }

  void clear() {
    _rootNode = null;
    rootType = RootType.kSingleRoot;
  }

  bool get isSingleRoot => rootType == RootType.kSingleRoot;

  // Dart doesn't have support for protected destructors as C++ does.
  // So the destructor for this Dart class is omitted.

  ContainerNode? parent(Node node);
  bool isChildDirty(Node node);
  bool isDirty(Node node);

  void _assertRootNodeInvariants() {
    // Dart does not have DCHECK, but we can use assert for a similar effect.
    assert(_rootNode == null ||
        _rootNode!.isDocumentNode() ||
        isDirty(_rootNode!) ||
        isChildDirty(_rootNode!) ||
        _isModifyingFlatTree());
  }

  bool _isModifyingFlatTree() {
    assert(_rootNode != null);
    return _rootNode!.ownerDocument.styleEngine.inDOMRemoval;
  }

  Node? _rootNode;
  RootType rootType = RootType.kSingleRoot;
}
