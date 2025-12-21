// Copyright 2018 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
//
// Copyright (C) 2022-present The WebF authors. All rights reserved.

#include "core/css/style_recalc_root.h"

#include "core/dom/document.h"
#include "core/dom/element.h"

namespace webf {

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
  Node* root_node = GetRootNode();
  if (!root_node) {
    return;
  }

  // If the current root is still connected, keep it; style recalc will clear
  // dirty bits as usual.
  if (root_node->isConnected()) {
    return;
  }

  // The root was detached. Clear child-dirty breadcrumbs on ancestors up to
  // the first non-dirty ancestor, then reset the recalc root. This keeps the
  // tree consistent for future dirty marks.
  for (Node* ancestor = &parent; ancestor; ancestor = ancestor->ParentOrShadowHostNode()) {
    if (!ancestor->ChildNeedsStyleRecalc()) {
      break;
    }
    ancestor->ClearChildNeedsStyleRecalc();
  }
  Clear();
}

}  // namespace webf
