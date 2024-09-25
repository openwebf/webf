/*
 * (C) 1999-2003 Lars Knoll (knoll@kde.org)
 * (C) 2002-2003 Dirk Mueller (mueller@kde.org)
 * Copyright (C) 2002, 2005, 2006, 2007, 2012 Apple Inc. All rights reserved.
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

#include "css_rule.h"
#include "core/css/css_style_sheet.h"
#include "core/css/style_sheet_contents.h"
#include "bindings/qjs/script_wrappable.h"

namespace webf {

struct SameSizeAsCSSRule : public ScriptWrappable {
  unsigned char bitfields;
  Member<ScriptWrappable> member;
};

static_assert(sizeof(CSSRule) == sizeof(SameSizeAsCSSRule));

void CSSRule::SetParentStyleSheet(webf::CSSStyleSheet* style_sheet) {
  parent_is_rule_ = false;
  parent_ = style_sheet;
}

void CSSRule::SetParentRule(webf::CSSRule* rule) {
  parent_is_rule_ = true;
  parent_ = rule;
}

void CSSRule::Trace(webf::GCVisitor* visitor) const {
  visitor->TraceMember(parent_);
  ScriptWrappable::Trace(visitor);
}

CSSRule::CSSRule(webf::CSSStyleSheet* parent)
    : has_cached_selector_text_(false), parent_is_rule_(false), parent_(parent), ScriptWrappable(parent->ctx()) {}

const CSSParserContext* CSSRule::ParserContext() const {
  CSSStyleSheet* style_sheet = parentStyleSheet();
  return style_sheet->Contents()->ParserContext().get();
}

bool CSSRule::VerifyParentIsCSSRule() const {
  return !parent_ || parent_->GetWrapperTypeInfo()->isSubclass(
                         CSSRule::GetStaticWrapperTypeInfo());
}

bool CSSRule::VerifyParentIsCSSStyleSheet() const {
  return !parent_ || parent_->GetWrapperTypeInfo()->isSubclass(
                         CSSStyleSheet::GetStaticWrapperTypeInfo());
}

}  // namespace webf
