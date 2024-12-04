/*
 * (C) 1999-2003 Lars Knoll (knoll@kde.org)
 * (C) 2002-2003 Dirk Mueller (mueller@kde.org)
 * Copyright (C) 2002, 2006, 2008, 2012 Apple Inc. All rights reserved.
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

#include "css_import_rule.h"
#include "core/css/css_markup.h"

namespace webf {

CSSImportRule::CSSImportRule(StyleRuleImport* import_rule, CSSStyleSheet* parent)
    : CSSRule(parent), import_rule_(import_rule) {}

CSSImportRule::~CSSImportRule() = default;

AtomicString CSSImportRule::href() const {
  return AtomicString(import_rule_->Href());
}

MediaList* CSSImportRule::media() {
  if (!media_cssom_wrapper_) {
    media_cssom_wrapper_ = MakeGarbageCollected<MediaList>(this);
  }
  return media_cssom_wrapper_.Get();
}

AtomicString CSSImportRule::cssText() const {
  StringBuilder result;
  result.Append("@import ");
  result.Append(SerializeURI(import_rule_->Href()));

  if (import_rule_->IsLayered()) {
    result.Append(" layer");
    AtomicString layer_name = layerName();
    if (layer_name.length()) {
      result.Append("(");
      result.Append(layer_name.ToStdString());
      result.Append(")");
    }
  }

  if (std::string supports = import_rule_->GetSupportsString(); supports != "") {
    result.Append(" supports(");
    result.Append(supports);
    result.Append(")");
  }

  if (import_rule_->MediaQueries()) {
    std::string media_text = import_rule_->MediaQueries()->MediaText();
    if (!media_text.empty()) {
      result.Append(' ');
      result.Append(media_text);
    }
  }
  result.Append(';');

  return AtomicString(result.ReleaseString());
}

CSSStyleSheet* CSSImportRule::styleSheet() const {
  // TODO(yukishiino): CSSImportRule.styleSheet attribute is not nullable,
  // thus this function must not return nullptr.
  if (!import_rule_->GetStyleSheet()) {
    return nullptr;
  }

  if (!style_sheet_cssom_wrapper_) {
    style_sheet_cssom_wrapper_ = MakeGarbageCollected<CSSStyleSheet>(
        GetExecutingContext(), import_rule_->GetStyleSheet(), const_cast<CSSImportRule*>(this));
  }
  return style_sheet_cssom_wrapper_.Get();
}

AtomicString CSSImportRule::layerName() const {
  if (!import_rule_->IsLayered()) {
    return AtomicString::Empty();
  }
  return AtomicString(import_rule_->GetLayerNameAsString());
}

AtomicString CSSImportRule::supportsText() const {
  return AtomicString(import_rule_->GetSupportsString());
}

void CSSImportRule::Reattach(std::shared_ptr<StyleRuleBase>) {
  // FIXME: Implement when enabling caching for stylesheets with import rules.
  NOTREACHED_IN_MIGRATION();
}

std::shared_ptr<const MediaQuerySet> CSSImportRule::MediaQueries() const {
  return import_rule_->MediaQueries();
}

void CSSImportRule::SetMediaQueries(std::shared_ptr<const MediaQuerySet> media_queries) {
  import_rule_->SetMediaQueries(media_queries);
}

void CSSImportRule::Trace(GCVisitor* visitor) const {
  visitor->TraceMember(media_cssom_wrapper_);
  visitor->TraceMember(style_sheet_cssom_wrapper_);
  CSSRule::Trace(visitor);
}

}  // namespace webf