// Copyright 2022 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// Copyright (C) 2022-present The WebF authors. All rights reserved.

#include "core/css/style_scope.h"
#include "core/css/parser/css_selector_parser.h"
#include "core/css/properties/css_parsing_utils.h"
#include "core/css/style_rule.h"
#include "core/css/style_sheet_contents.h"
#include "core/dom/element.h"
#include "core/base/containers/span.h"

namespace webf {

StyleScope::StyleScope(std::shared_ptr<StyleRule> from, std::shared_ptr<CSSSelectorList> to)
    : from_(from), to_(to) {}

StyleScope::StyleScope(std::shared_ptr<StyleSheetContents> contents, std::shared_ptr<CSSSelectorList> to)
    : contents_(contents), to_(to) {}

StyleScope::StyleScope(const StyleScope& other)
    : contents_(other.contents_),
      from_(other.from_ ? other.from_->Copy() : nullptr),
      to_(other.to_ ? other.to_->Copy() : nullptr),
      parent_(other.parent_) {}

std::shared_ptr<StyleScope> StyleScope::CopyWithParent(std::shared_ptr<const StyleScope> parent) const {
  std::shared_ptr<StyleScope> copy = std::make_shared<StyleScope>(*this);
  copy->parent_ = parent;
  return copy;
}

const CSSSelector* StyleScope::From() const {
  if (from_) {
    return from_->FirstSelector();
  }
  return nullptr;
}

const CSSSelector* StyleScope::To() const {
  if (to_) {
    return to_->First();
  }
  return nullptr;
}

std::shared_ptr<StyleScope> StyleScope::Parse(CSSParserTokenRange prelude,
                           std::shared_ptr<const CSSParserContext> context,
                           CSSNestingType nesting_type,
                           std::shared_ptr<const StyleRule>& parent_rule_for_nesting,
                           bool is_within_scope,
                           std::shared_ptr<StyleSheetContents>& style_sheet) {
  std::vector<CSSSelector> arena;

  std::optional<tcb::span<CSSSelector>> from;
  std::optional<tcb::span<CSSSelector>> to;

  prelude.ConsumeWhitespace();

  // <scope-start>
  if (prelude.Peek().GetType() == kLeftParenthesisToken) {
    auto block = prelude.ConsumeBlock();
    std::string text = block.Serialize();
    CSSTokenizer tokenizer(text);
    CSSParserTokenStream stream(tokenizer);
    from = CSSSelectorParser::ParseScopeBoundary(
        stream, context, nesting_type, parent_rule_for_nesting, is_within_scope,
        style_sheet, arena);
    if (!from.has_value()) {
      return nullptr;
    }
  }

  std::shared_ptr<StyleRule> from_rule = nullptr;
  if (from.has_value() && !from.value().empty()) {
    std::shared_ptr<ImmutableCSSPropertyValueSet> properties = std::make_shared<ImmutableCSSPropertyValueSet>(
        /* properties */ nullptr,
         /* count */ 0,
        CSSParserMode::kHTMLStandardMode);
    from_rule = StyleRule::Create(from.value(), properties);
  }

  prelude.ConsumeWhitespace();

  // to (<scope-end>)
  if (css_parsing_utils::ConsumeIfIdent(prelude, "to")) {
    if (prelude.Peek().GetType() != kLeftParenthesisToken) {
      return nullptr;
    }

    // Note that <scope-start> should act as the enclosing style rule for
    // the purposes of matching the parent pseudo-class (&) within <scope-end>,
    // hence we're not passing any of `nesting_type`, `parent_rule_for_nesting`,
    // or `is_within_scope` to `ParseScopeBoundary` here.
    //
    // https://drafts.csswg.org/css-nesting-1/#nesting-at-scope
    auto block = prelude.ConsumeBlock();
    std::string text = block.Serialize();
    CSSTokenizer tokenizer(text);
    CSSParserTokenStream stream(tokenizer);
    to = CSSSelectorParser::ParseScopeBoundary(
        stream, context, CSSNestingType::kScope,
        /* parent_rule_for_nesting */ from_rule,
        /* is_within_scope */ true, style_sheet, arena);
    if (!to.has_value()) {
      return nullptr;
    }
  }

  prelude.ConsumeWhitespace();

  if (!prelude.AtEnd()) {
    return nullptr;
  }

  std::shared_ptr<CSSSelectorList> to_list =
      to.has_value() ? CSSSelectorList::AdoptSelectorVector(to.value())
                     : nullptr;

  if (!from.has_value()) {
    // Implicitly rooted.
    return std::make_shared<StyleScope>(style_sheet, to_list);
  }

  return std::make_shared<StyleScope>(from_rule, to_list);
}

void StyleScope::Trace(GCVisitor* visitor) const {
}

}  // namespace webf
