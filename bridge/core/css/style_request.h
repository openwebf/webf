/*
 * Copyright (C) 1999 Lars Knoll (knoll@kde.org)
 * Copyright (C) 2003, 2004, 2005, 2006, 2007, 2008, 2009, 2010, 2011 Apple Inc.
 * All rights reserved.
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

// Copyright (C) 2022-present The WebF authors. All rights reserved.

#ifndef WEBF_CORE_CSS_STYLE_REQUEST_H_
#define WEBF_CORE_CSS_STYLE_REQUEST_H_

#include "core/css/style_color.h"
#include "core/style/computed_style_constants.h"

namespace webf {

class ComputedStyle;
class CustomScrollbar;
class Element;

class ScrollbarPart;

enum RuleMatchingBehavior { kMatchAllRules, kMatchAllRulesExcludingSMIL };

class StyleRequest {
  WEBF_STACK_ALLOCATED();

 public:
  enum RequestType { kForRenderer, kForComputedStyle };
  enum RulesToInclude { kUAOnly, kAll };
  enum SearchTextRequest { kNone, kCurrent, kNotCurrent };

  StyleRequest() = default;

  bool IsPseudoStyleRequest() const { return pseudo_id != kPseudoIdNone; }

  const ComputedStyle* parent_override{nullptr};
  const ComputedStyle* layout_parent_override{nullptr};
  const ComputedStyle* originating_element_style{nullptr};
  // The styled element may be different from the matched element for SVG <use>
  // instantiations. In those cases we pass in the element that gets the style
  // as styled_element while the element matching the rules are the one passed
  // in the ElementResolveContext.
  Element* styled_element{nullptr};
  RuleMatchingBehavior matching_behavior{kMatchAllRules};

  PseudoId pseudo_id{kPseudoIdNone};
  RequestType type{kForRenderer};
  // TODO(guopengfei)：暂不支持Scrollbar
  //ScrollbarPart scrollbar_part{kNoPart};
  CustomScrollbar* scrollbar{nullptr};
  AtomicString pseudo_argument{g_empty_atom};
  std::vector<AtomicString> pseudo_ident_list;
  RulesToInclude rules_to_include{kAll};
  bool can_trigger_animations{true};
  SearchTextRequest search_text_request{kNone};

  explicit StyleRequest(const ComputedStyle* parent_override)
      : parent_override(parent_override),
        layout_parent_override(parent_override) {}

  StyleRequest(PseudoId pseudo_id,
               const ComputedStyle* parent_override,
               const ComputedStyle* originating_element_style = nullptr,
               const AtomicString& pseudo_argument = AtomicString::Null())
      : parent_override(parent_override),
        layout_parent_override(parent_override),
        originating_element_style(originating_element_style),
        pseudo_id(pseudo_id),
        pseudo_argument(pseudo_argument) {
    assert(!IsTransitionPseudoElement(pseudo_id) ||
           pseudo_id == kPseudoIdViewTransition || pseudo_argument.empty());
  }

//  StyleRequest(PseudoId pseudo_id,
//               CustomScrollbar* scrollbar,
//               const ComputedStyle* parent_override)
//      : parent_override(parent_override),
//        layout_parent_override(parent_override),
//        pseudo_id(pseudo_id),
//        //scrollbar_part(scrollbar_part),
//        scrollbar(scrollbar) {}

  StyleRequest(PseudoId pseudo_id, RequestType request_type)
      : pseudo_id(pseudo_id), type(request_type) {}
};

}  // namespace webf

#endif  // WEBF_CORE_CSS_STYLE_REQUEST_H_