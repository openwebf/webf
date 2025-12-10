// Copyright 2018 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
//
// Copyright (C) 2022-present The WebF authors. All rights reserved.

#ifndef WEBF_CORE_CSS_STYLE_RECALC_ROOT_H_
#define WEBF_CORE_CSS_STYLE_RECALC_ROOT_H_

#include "core/css/style_traversal_root.h"

namespace webf {

class Element;
class Node;
class ContainerNode;

// Minimal StyleRecalcRoot used to track a common ancestor root for all nodes
// that need style recalculation. This is a simplified version of Blink's
// StyleRecalcRoot:
// - We ignore flat-tree / shadow DOM specifics for now.
// - Any node with NeedsStyleRecalc() or ChildNeedsStyleRecalc() is considered
//   "dirty" for the purpose of root selection.
class StyleRecalcRoot : public StyleTraversalRoot {
  WEBF_DISALLOW_NEW();

 public:
  // Return the Element at which style recalc should start. If the stored root
  // node is the Document, return documentElement(); if it's a text node, walk
  // up to its style-recalc parent; otherwise we expect an Element.
  Element& RootElement() const;

  // Called when a subtree containing the current root has been structurally
  // modified. If the current root is no longer connected to the DOM, clear
  // the recalc root so the next dirty mark will establish a new one.
  void SubtreeModified(ContainerNode& parent) final;

 private:
  bool IsDirty(const Node& node) const final;
};

}  // namespace webf

#endif  // WEBF_CORE_CSS_STYLE_RECALC_ROOT_H_

