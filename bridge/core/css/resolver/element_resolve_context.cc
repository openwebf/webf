/*
 * Copyright (C) 1999 Lars Knoll (knoll@kde.org)
 * Copyright (C) 2003, 2004, 2005, 2006, 2007, 2008, 2009, 2010, 2011 Apple Inc.
 * All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Library General Public
 * License as published by the Free Software Foundation; either
 * version 2 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Library General Public License for more details.
 *
 * You should have received a copy of the GNU Library General Public License
 * along with this library; see the file COPYING.LIB.  If not, write to
 * the Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
 * Boston, MA 02110-1301, USA.
 *
 */

#include "core/css/resolver/element_resolve_context.h"

#include "core/dom/document.h"
#include "core/dom/element.h"
#include "core/style/computed_style.h"

namespace webf {

// Builds pseudo element ancestors for rule matching:
// - For regular elements just returns empty array.
// - For pseudo elements (including nested pseudo elements) returns
// array of every pseudo element ancestor, including
// pseudo element for which rule matching is performed.
void ElementResolveContext::BuildPseudoElementAncestors(Element* element) {
  pseudo_element_ancestors_size_ = 0;
  pseudo_element_ancestors_.fill(nullptr);
  
  if (!element->IsPseudoElement()) {
    return;
  }
  
  // For WebF, we currently only support simple pseudo elements
  // Future enhancement: support nested pseudo elements like ::after::marker
  pseudo_element_ancestors_[0] = element;
  pseudo_element_ancestors_size_ = 1;
}

namespace {
EInsideLink GetLinkStateForElement(Element& element) {
  // TODO: Check if document is active
  // For now, assume document is always active

  // TODO: Implement DevTools forced pseudo state support
  // TODO: Implement visited link state tracking
  
  // For now, just check if the element is a link
  if (element.IsLink()) {
    // TODO: Check visited state
    return EInsideLink::kInsideUnvisitedLink;
  }
  
  return EInsideLink::kNotInsideLink;
}
}  // namespace

ElementResolveContext::ElementResolveContext(Element& element)
    : element_(&element),
      ultimate_originating_element_(element_),  // TODO: Handle pseudo elements
      pseudo_element_(nullptr),  // TODO: Handle pseudo elements
      element_link_state_(GetLinkStateForElement(element)) {
  
  // TODO: Use LayoutTreeBuilderTraversal when available
  // For now, use direct parent element
  parent_element_ = element.parentElement();
  layout_parent_ = parent_element_;  // TODO: Handle display:contents case
  
  if (const Element* root_element = element.GetDocument().documentElement()) {
    if (&element != root_element) {
      root_element_style_ = root_element->GetComputedStyle();
    }
  }
  
  BuildPseudoElementAncestors(&element);
}

}  // namespace webf