/*
 * (C) 1999-2003 Lars Knoll (knoll@kde.org)
 * (C) 2002-2003 Dirk Mueller (mueller@kde.org)
 * Copyright (C) 2002, 2005, 2006, 2008, 2012 Apple Inc. All rights reserved.
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

#include "core/css/css_style_rule.h"

#include "../../foundation/string/string_builder.h"
#include "bindings/qjs/cppgc/garbage_collected.h"
#include "bindings/qjs/exception_state.h"
#include "core/css/css_style_sheet.h"
#include "core/css/parser/css_parser.h"
#include "core/css/style_rule.h"
#include "core/css/style_rule_css_style_declaration.h"
#include "core/executing_context.h"

namespace webf {

CSSStyleRule::CSSStyleRule(std::shared_ptr<StyleRule> style_rule,
                           CSSStyleSheet* parent,
                           uint32_t position)
    : CSSRule(parent),
      style_rule_(std::move(style_rule)),
      child_rule_position_(position) {}

CSSStyleRule::~CSSStyleRule() = default;

// TODO: find out why this was LegacyCssStyleDeclaration
CSSStyleDeclaration* CSSStyleRule::style() const {
  if (!style_rule_)
    return nullptr;

  if (!properties_cssom_wrapper_) {
    properties_cssom_wrapper_ = MakeGarbageCollected<StyleRuleCSSStyleDeclaration>(
        std::shared_ptr<const MutableCSSPropertyValueSet>(&style_rule_->MutableProperties(), 
                                                          [](const MutableCSSPropertyValueSet*){}),
        const_cast<CSSStyleRule*>(this));
  }
  return properties_cssom_wrapper_.Get();
}

AtomicString CSSStyleRule::selectorText() const {
  if (!style_rule_)
    return AtomicString();

  return AtomicString(style_rule_->SelectorsText());
}

void CSSStyleRule::setSelectorText(const ExecutingContext* context,
                                   const AtomicString& selector_text,
                                   ExceptionState& exception_state) {
  SetSelectorText(context, selector_text);
}

void CSSStyleRule::SetSelectorText(const ExecutingContext* context,
                                   const AtomicString& selector_text) {
  if (!style_rule_)
    return;

  // TODO: Implement selector parsing and updating
  // This requires access to parser context and updating the StyleRule
}

AtomicString CSSStyleRule::cssText() const {
  if (!style_rule_)
    return AtomicString();

  StringBuilder result;
  result.Append(selectorText().GetString());
  result.Append(" { "_s);
  
  auto style_decl = style();
  if (style_decl) {
    result.Append(style_decl->cssText().GetString());
  }
  
  result.Append(" }"_s);
  return AtomicString(result.ReleaseString());
}

void CSSStyleRule::setCSSText(const AtomicString& css_text,
                              ExceptionState& exception_state) {
  // TODO: Implement parsing and updating the rule
  // TODO: Implement setCSSText
}

void CSSStyleRule::Reattach(std::shared_ptr<StyleRuleBase> rule) {
  if (!rule || !rule->IsStyleRule())
    return;
    
  style_rule_ = std::static_pointer_cast<StyleRule>(rule);
  
  if (properties_cssom_wrapper_) {
    // Reset the wrapper to force re-creation with new properties
    properties_cssom_wrapper_ = nullptr;
  }
}

void CSSStyleRule::Trace(GCVisitor* visitor) const {
  visitor->TraceMember(properties_cssom_wrapper_);
  CSSRule::Trace(visitor);
}

}  // namespace webf
