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

#ifndef WEBF_CORE_CSS_CSS_IMPORT_RULE_H_
#define WEBF_CORE_CSS_CSS_IMPORT_RULE_H_

#include "core/css/css_rule.h"
#include "core/css/media_query_set_owner.h"
#include "core/css/style_rule_import.h"
#include "core/css/css_style_sheet.h"

namespace webf {

class MediaList;
class StyleRuleImport;

class CSSImportRule final : public CSSRule, public MediaQuerySetOwner {
  DEFINE_WRAPPERTYPEINFO();

 public:
  CSSImportRule(StyleRuleImport*, CSSStyleSheet*);
  ~CSSImportRule() override;

  AtomicString cssText() const override;
  void Reattach(std::shared_ptr<StyleRuleBase>) override;

  AtomicString href() const;
  MediaList* media();
  CSSStyleSheet* styleSheet() const;

  AtomicString layerName() const;

  AtomicString supportsText() const;

  void Trace(GCVisitor*) const override;

 private:
  CSSRule::Type GetType() const override { return kImportRule; }

  MediaQuerySetOwner* GetMediaQuerySetOwner() override { return this; }
  std::shared_ptr<const MediaQuerySet> MediaQueries() const override;
  void SetMediaQueries(std::shared_ptr<const MediaQuerySet>) override;

  std::shared_ptr<StyleRuleImport> import_rule_;
  mutable Member<MediaList> media_cssom_wrapper_;
  mutable Member<CSSStyleSheet> style_sheet_cssom_wrapper_;
};

template <>
struct DowncastTraits<CSSImportRule> {
  static bool AllowFrom(const CSSRule& rule) {
    return rule.GetType() == CSSRule::kImportRule;
  }
};


}

#endif  // WEBF_CORE_CSS_CSS_IMPORT_RULE_H_
