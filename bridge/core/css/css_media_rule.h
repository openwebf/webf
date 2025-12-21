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

#ifndef WEBF_CORE_CSS_CSS_MEDIA_RULE_H_
#define WEBF_CORE_CSS_CSS_MEDIA_RULE_H_

#include "core/css/css_condition_rule.h"
#include "bindings/qjs/cppgc/member.h"
#include <memory>

namespace webf {

class MediaList;
class StyleRuleMedia;

class CSSMediaRule : public CSSConditionRule {
 public:
  CSSMediaRule(std::shared_ptr<StyleRuleMedia> media_rule, CSSStyleSheet* parent);
  ~CSSMediaRule() override;

  AtomicString cssText() const override;
  
  CSSRule::Type GetType() const override { return CSSRule::Type::kMediaRule; }

  MediaList* media() const;

  void Reattach(std::shared_ptr<StyleRuleBase>) override;

  void Trace(GCVisitor* visitor) const override;

 private:
  String conditionText() const override;

  mutable Member<MediaList> media_cssom_wrapper_;
};

}  // namespace webf

#endif  // WEBF_CORE_CSS_CSS_MEDIA_RULE_H_
