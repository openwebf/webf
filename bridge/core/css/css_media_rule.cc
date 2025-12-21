/*
 * (C) 1999-2003 Lars Knoll (knoll@kde.org)
 * (C) 2002-2003 Dirk Mueller (mueller@kde.org)
 * Copyright (C) 2002, 2005, 2006, 2008, 2012 Apple Inc. All rights reserved.
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

#include "core/css/css_media_rule.h"

#include "../../foundation/string/string_builder.h"
#include "bindings/qjs/cppgc/garbage_collected.h"
#include "core/css/media_list.h"
#include "core/css/style_rule.h"
#include "foundation/casting.h"

namespace webf {

CSSMediaRule::CSSMediaRule(std::shared_ptr<StyleRuleMedia> media_rule,
                           CSSStyleSheet* parent)
    : CSSConditionRule(std::static_pointer_cast<StyleRuleCondition>(media_rule), parent) {}

CSSMediaRule::~CSSMediaRule() = default;

MediaList* CSSMediaRule::media() const {
  if (!group_rule_)
    return nullptr;

  if (!media_cssom_wrapper_) {
    media_cssom_wrapper_ = MakeGarbageCollected<MediaList>(const_cast<CSSMediaRule*>(this));
  }
  return media_cssom_wrapper_.Get();
}

String CSSMediaRule::conditionText() const {
  if (!group_rule_)
    return String::EmptyString();

  auto* media_rule = To<StyleRuleMedia>(group_rule_.get());
  return media_rule->MediaQueries()->MediaText();
}

AtomicString CSSMediaRule::cssText() const {
  StringBuilder result;
  result.Append("@media "_s);
  result.Append(conditionText());
  AppendCSSTextForItems(result);
  return AtomicString(result.ReleaseString());
}

void CSSMediaRule::Reattach(std::shared_ptr<StyleRuleBase> rule) {
  CSSConditionRule::Reattach(rule);
  if (media_cssom_wrapper_ && rule) {
    // Reset the wrapper to force re-creation with new media queries
    media_cssom_wrapper_ = nullptr;
  }
}

void CSSMediaRule::Trace(GCVisitor* visitor) const {
  visitor->TraceMember(media_cssom_wrapper_);
  CSSConditionRule::Trace(visitor);
}

}  // namespace webf
