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

#ifndef WEBF_CORE_CSS_RESOLVER_ELEMENT_RESOLVE_CONTEXT_H_
#define WEBF_CORE_CSS_RESOLVER_ELEMENT_RESOLVE_CONTEXT_H_

#include <array>
#include <memory>
#include "core/dom/element.h"
#include "core/style/computed_style_constants.h"
#include "core/style/computed_style_base_constants.h"
#include "foundation/macros.h"

namespace webf {

class Element;
class ComputedStyle;

// Wraps an Element for use by ElementRuleCollector. Computes various values
// from the element for quick access during style calculation. It is immutable.
class ElementResolveContext {
  WEBF_STACK_ALLOCATED();

 public:
  explicit ElementResolveContext(Element&);

  Element& GetElement() const { return *element_; }
  Element& GetUltimateOriginatingElementOrSelf() const {
    return *ultimate_originating_element_;
  }
  Element* GetPseudoElement() const { return pseudo_element_; }
  const Element* ParentElement() const { return parent_element_; }
  const Element* LayoutParentElement() const { return layout_parent_; }
  const ComputedStyle* RootElementStyle() const { return root_element_style_; }
  const ComputedStyle* ParentStyle() const {
    return ParentElement() ? ParentElement()->GetComputedStyle() : nullptr;
  }
  const ComputedStyle* LayoutParentStyle() const {
    return LayoutParentElement() ? LayoutParentElement()->GetComputedStyle()
                                 : nullptr;
  }
  EInsideLink ElementLinkState() const { return element_link_state_; }

  // Some view-transition pseudos can be nested as much as 5 elements.
  static constexpr size_t kMaxPseudoElementsNesting = 5u;
  using PseudoElementAncestors =
      std::array<Element*, kMaxPseudoElementsNesting>;
  
  const PseudoElementAncestors& GetPseudoElementAncestors() const {
    return pseudo_element_ancestors_;
  }
  
  size_t PseudoElementAncestorsSize() const {
    return pseudo_element_ancestors_size_;
  }

 private:
  void BuildPseudoElementAncestors(Element*);

  // The Element we are resolving styles for. May be a PseudoElement.
  Element* element_;
  // Same as element_ for real elements or ultimate originating element for
  // pseudo elements.
  Element* ultimate_originating_element_;
  // The PseudoElement when resolving styles for a pseudo elements, otherwise
  // null.
  Element* pseudo_element_;
  Element* parent_element_{nullptr};
  Element* layout_parent_{nullptr};
  const ComputedStyle* root_element_style_{nullptr};
  EInsideLink element_link_state_;
  size_t pseudo_element_ancestors_size_ = 0;
  // Originating elements array for matching nested pseudo elements.
  PseudoElementAncestors pseudo_element_ancestors_;
};

}  // namespace webf

#endif  // WEBF_CORE_CSS_RESOLVER_ELEMENT_RESOLVE_CONTEXT_H_