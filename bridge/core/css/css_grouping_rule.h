/*
 * (C) 1999-2003 Lars Knoll (knoll@kde.org)
 * (C) 2002-2003 Dirk Mueller (mueller@kde.org)
 * Copyright (C) 2002, 2006, 2008, 2012 Apple Inc. All rights reserved.
 * Copyright (C) 2006 Samuel Weinig (sam@webkit.org)
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
 */

/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef WEBF_CORE_CSS_CSS_GROUPING_RULE_H_
#define WEBF_CORE_CSS_CSS_GROUPING_RULE_H_

#include "core/css/css_rule.h"
#include "bindings/qjs/cppgc/member.h"
#include "core/css/style_rule.h"
#include <vector>

namespace webf {

class ExceptionState;
class CSSRuleList;

class CSSGroupingRule : public CSSRule {
 public:
  ~CSSGroupingRule() override;

  void Reattach(std::shared_ptr<StyleRuleBase>) override;

  CSSRuleList* cssRules() const override;

  unsigned insertRule(const ExecutingContext*,
                      const String& rule,
                      unsigned index,
                      ExceptionState&);
  void deleteRule(unsigned index, ExceptionState&);

  // For CSSRuleList
  unsigned length() const;
  CSSRule* Item(unsigned index, bool trigger_use_counters = true) const;

  // Get an item, but signal that it's been requested internally from the
  // engine, and not directly from a script.
  CSSRule* ItemInternal(unsigned index) const {
    return Item(index, /*trigger_use_counters=*/false);
  }

  void Trace(GCVisitor* visitor) const override;

 protected:
  CSSGroupingRule(std::shared_ptr<StyleRuleGroup> group_rule, CSSStyleSheet* parent);

  void AppendCSSTextForItems(StringBuilder&) const;

  std::shared_ptr<StyleRuleGroup> group_rule_;
  mutable std::vector<Member<CSSRule>> child_rule_cssom_wrappers_;
  mutable Member<CSSRuleList> rule_list_cssom_wrapper_;
};

template <>
struct DowncastTraits<CSSGroupingRule> {
  static bool AllowFrom(const CSSRule& rule) {
    switch (rule.GetType()) {
      // CSSConditionRule (inherits CSSGroupingRule):
      case CSSRule::kMediaRule:
      case CSSRule::kSupportsRule:
      case CSSRule::kContainerRule:
      // CSSGroupingRule:
      case CSSRule::kLayerBlockRule:
      case CSSRule::kPageRule:
      case CSSRule::kScopeRule:
      case CSSRule::kStartingStyleRule:
        return true;
      default:
        return false;
    }
  }
};

}  // namespace webf

#endif  // WEBF_CORE_CSS_CSS_GROUPING_RULE_H_
