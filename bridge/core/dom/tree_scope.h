/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef BRIDGE_CORE_DOM_TREE_SCOPE_H_
#define BRIDGE_CORE_DOM_TREE_SCOPE_H_

#include <cassert>

namespace webf {

class ContainerNode;
class Document;

// The root node of a document tree (in which case this is a Document) or of a
// shadow tree (in which case this is a ShadowRoot). Various things, like
// element IDs, are scoped to the TreeScope in which they are rooted, if any.
//
// A class which inherits both Node and TreeScope must call clearRareData() in
// its destructor so that the Node destructor no longer does problematic
// NodeList cache manipulation in the destructor.
class TreeScope {
  friend class Node;

 public:
  Document& GetDocument() const {
    assert(document_);
    return *document_;
  }

 ContainerNode& RootNode() const { return *root_node_; }

 protected:
  explicit TreeScope(Document&);

 private:
  ContainerNode* root_node_;
  Document* document_;
  TreeScope* parent_tree_scope_;
};

}  // namespace webf

#endif  // BRIDGE_CORE_DOM_TREE_SCOPE_H_
