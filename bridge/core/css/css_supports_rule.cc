/*
 * Copyright (C) 2012 Samsung Electronics. All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY APPLE INC. AND ITS CONTRIBUTORS ``AS IS''
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
 * THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
 * PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL APPLE INC. OR ITS CONTRIBUTORS
 * BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF
 * THE POSSIBILITY OF SUCH DAMAGE.
 */

/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "core/css/css_supports_rule.h"

#include "../../foundation/string/string_builder.h"
#include "core/css/style_rule.h"
#include "foundation/casting.h"

namespace webf {

CSSSupportsRule::CSSSupportsRule(std::shared_ptr<StyleRuleSupports> supports_rule,
                                 CSSStyleSheet* parent)
    : CSSConditionRule(std::static_pointer_cast<StyleRuleCondition>(supports_rule), parent) {}

CSSSupportsRule::~CSSSupportsRule() = default;

String CSSSupportsRule::conditionText() const {
  if (!group_rule_)
    return String::EmptyString();

  auto* supports_rule = To<StyleRuleSupports>(group_rule_.get());
  return supports_rule->ConditionText();
}

AtomicString CSSSupportsRule::cssText() const {
  StringBuilder result;
  result.Append("@supports "_s);
  result.Append(conditionText());
  AppendCSSTextForItems(result);
  return AtomicString(result.ReleaseString());
}

void CSSSupportsRule::Reattach(std::shared_ptr<StyleRuleBase> rule) {
  CSSConditionRule::Reattach(rule);
}

}  // namespace webf
