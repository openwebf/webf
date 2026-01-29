// Copyright 2018 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
//
// Copyright (C) 2022-present The WebF authors. All rights reserved.

#include "core/css/style_recalc_root.h"

#include <utility>

#include "core/dom/document.h"
#include "core/dom/element.h"

namespace webf {

namespace {

// In Blink, the "flat tree" may exclude nodes that are still connected in the
// light tree (e.g. due to slotting / shadow DOM). WebF currently does not
// implement those concepts, but we still keep Blink's predicate structure so
// traversal-root invariants behave the same when porting code.
bool IsFlatTreeConnected(const Node& root) {
  if (!root.isConnected()) {
    return false;
  }
  // If the recalc root is removed from the flat tree because an intermediate
  // flat-tree container disappeared, Blink clears recalc flags during detach.
  // Use the presence of recalc flags as a proxy for flat-tree membership.
  return root.IsDirtyForStyleRecalc() || root.ChildNeedsStyleRecalc();
}

// Returns a pair:
//  - first: whether we were able to determine a suitable flat-tree ancestor.
//  - second: the ancestor element from which to clear child-dirty breadcrumbs.
std::pair<bool, Element*> FirstFlatTreeAncestorForChildDirty(ContainerNode& parent) {
  if (!parent.IsElementNode()) {
    // The flat tree does not contain the document node. The closest ancestor
    // for dirty bits is the parent element (or nullptr).
    return {true, parent.ParentOrShadowHostElement()};
  }
  // WebF does not implement shadow DOM yet; for light-tree elements the parent
  // itself is the closest flat-tree ancestor.
  return {true, To<Element>(&parent)};
}

}  // namespace

Element& StyleRecalcRoot::RootElement() const {
  Node* root_node = GetRootNode();
  assert(root_node);

  if (root_node->IsDocumentNode()) {
    Element* doc_element = root_node->GetDocument().documentElement();
    assert(doc_element);
    return *doc_element;
  }

  if (root_node->IsTextNode()) {
    // For text nodes, start recalc at the style-recalc parent element.
    root_node = root_node->GetStyleRecalcParent();
  }

  // For now we ignore pseudo-elements / shadow DOM and assume the root is an
  // Element in the light DOM.
  return To<Element>(*root_node);
}

bool StyleRecalcRoot::IsDirty(const Node& node) const {
  // Mirror Blink's StyleRecalcRoot::IsDirty by consulting the node's
  // IsDirtyForStyleRecalc() helper (self-dirty / layout-dirty), rather than
  // treating child-dirty breadcrumbs as sufficient.
  return node.IsDirtyForStyleRecalc();
}

void StyleRecalcRoot::SubtreeModified(ContainerNode& parent) {
  if (!GetRootNode()) {
    return;
  }

  if (GetRootNode()->IsDocumentNode()) {
    return;
  }

  if (IsFlatTreeConnected(*GetRootNode())) {
    return;
  }

  // We are notified with the light tree parent of the node(s) which were
  // removed from the DOM. Clear child-dirty breadcrumbs on the closest flat
  // tree ancestor chain so that the next dirty mark can establish a fresh
  // traversal root, mirroring Blink's StyleRecalcRoot::SubtreeModified.
  auto opt_ancestor = FirstFlatTreeAncestorForChildDirty(parent);
  if (!opt_ancestor.first) {
    ContainerNode* common_ancestor = &parent;
    ContainerNode* new_root = &parent;
    if (!IsFlatTreeConnected(parent)) {
      // Fall back to the document root element since the flat tree is in a
      // state where we do not know what a suitable common ancestor would be.
      common_ancestor = nullptr;
      new_root = parent.GetDocument().documentElement();
    }
    if (new_root) {
      Update(common_ancestor, new_root);
    }
    return;
  }

  for (Element* ancestor = opt_ancestor.second; ancestor; ancestor = ancestor->GetStyleRecalcParent()) {
    assert(ancestor->ChildNeedsStyleRecalc());
    assert(!ancestor->NeedsStyleRecalc());
    ancestor->ClearChildNeedsStyleRecalc();
  }
  Clear();
}

}  // namespace webf
