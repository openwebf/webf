// Copyright 2021 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "core/css/style_recalc_context.h"

//#include "core/css/container_query_evaluator.h"
//#include "core/dom/layout_tree_builder_traversal.h"
//#include "core/dom/node_computed_style.h"
//#include "core/html/html_slot_element.h"

namespace webf {

StyleRecalcContext StyleRecalcContext::FromAncestors(Element& /*element*/) {
  // WebF does not yet implement the full Blink ancestor-based context
  // construction. For now we return a default-initialized context, which
  // keeps the API surface compatible without affecting the current
  // style-recalc pipeline (which ignores these fields).
  StyleRecalcContext context;
  return context;
}

StyleRecalcContext StyleRecalcContext::FromInclusiveAncestors(Element& element) {
  // Until we port Blink's more detailed logic, treat this the same as
  // FromAncestors().
  return FromAncestors(element);
}

StyleRecalcContext StyleRecalcContext::ForSlotChildren(const HTMLSlotElement& /*slot*/) const {
  // Shadow DOM and ::slotted() are not wired yet; keep the current context.
  return *this;
}

StyleRecalcContext StyleRecalcContext::ForSlottedRules(HTMLSlotElement& /*slot*/) const {
  // Shadow DOM and ::slotted() are not wired yet; keep the current context.
  return *this;
}

StyleRecalcContext StyleRecalcContext::ForPartRules(Element& /*host*/) const {
  // ::part() rules are not yet using StyleRecalcContext; return an unchanged
  // copy until that pipeline is ported.
  return *this;
}

}  // namespace webf
