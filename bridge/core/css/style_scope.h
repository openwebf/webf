// Copyright 2022 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// Copyright (C) 2022-present The WebF authors. All rights reserved.

#ifndef WEBF_CORE_CSS_STYLE_SCOPE_H_
#define WEBF_CORE_CSS_STYLE_SCOPE_H_

#include <optional>

#include "core/css/css_selector_list.h"
#include "core/css/parser/css_nesting_type.h"
#include "core/css/parser/css_parser_token_range.h"

namespace webf {

class StyleRule;
class StyleSheetContents;

class StyleScope final {
 public:
  // Construct a StyleScope with explicit roots specified by elements matching
  // the `from` selector list (within the StyleRule). The (optional) `to`
  // parameter selects the the limit elements, i.e. the extent of the scope.
  //
  // Note that the `from` selector list is represented here as a "dummy"
  // StyleRule instead of a CSSSelectorList, because scopes need to behave
  // as style rules to integrate with CSS Nesting.
  // https://drafts.csswg.org/css-nesting-1/#nesting-at-scope
  StyleScope(std::shared_ptr<StyleRule> from, std::shared_ptr<CSSSelectorList> to);
  // Construct a StyleScope with implicit roots at the parent nodes of the
  // stylesheet's owner nodes. Note that StyleScopes with implicit roots
  // can still have limits.
  explicit StyleScope(std::shared_ptr<StyleSheetContents> contents, std::shared_ptr<CSSSelectorList> to);
  StyleScope(const StyleScope&);
  // Note that the `nesting_type` and `parent_rule_for_nesting` provided here
  // are only used for parsing the <scope-start> selector. The <scope-end>
  // selector and style rules within the scope's body will use
  // CSSNestingType::kScope and `RuleForNesting()` instead.
  static std::shared_ptr<StyleScope> Parse(CSSParserTokenRange prelude,
                                           std::shared_ptr<const CSSParserContext> context,
                                           CSSNestingType nesting_type,
                                           std::shared_ptr<const StyleRule>& parent_rule_for_nesting,
                                           bool is_within_scope,
                                           std::shared_ptr<StyleSheetContents>& style_sheet);

  void Trace(GCVisitor*) const;

  std::shared_ptr<StyleScope> CopyWithParent(std::shared_ptr<const StyleScope>) const;

  // From() and To() both return the first CSSSelector in a list, or nullptr
  // if there is no list.
  const CSSSelector* From() const;
  const CSSSelector* To() const;
  const StyleScope* Parent() const { return parent_.get(); }

  // The rule to use for resolving the nesting selector (&) for this scope's
  // inner rules.
  StyleRule* RuleForNesting() const { return from_.get(); }

  // https://drafts.csswg.org/css-cascade-6/#implicit-scope
  bool IsImplicit() const { return contents_.get() != nullptr; }

 private:
  // If `contents_` is not nullptr, then this is a prelude-less @scope rule
  // which is implicitly scoped to the owner node's parent.
  std::shared_ptr<StyleSheetContents> contents_;
  std::shared_ptr<StyleRule> from_;      // May be nullptr.
  std::shared_ptr<CSSSelectorList> to_;  // May be nullptr.
  std::shared_ptr<const StyleScope> parent_;
  mutable std::optional<unsigned> specificity_;
};

}  // namespace webf

#endif  // WEBF_CORE_CSS_STYLE_SCOPE_H_
