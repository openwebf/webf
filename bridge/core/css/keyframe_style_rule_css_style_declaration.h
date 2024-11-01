// Copyright 2015 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#ifndef WEBF_CORE_CSS_KEYFRAME_STYLE_RULE_CSS_STYLE_DECLARATION_H_
#define WEBF_CORE_CSS_KEYFRAME_STYLE_RULE_CSS_STYLE_DECLARATION_H_

#include "core/css/style_rule_css_style_declaration.h"

namespace webf {

class CSSKeyframeRule;

class KeyframeStyleRuleCSSStyleDeclaration final
    : public StyleRuleCSSStyleDeclaration {
 public:
  KeyframeStyleRuleCSSStyleDeclaration(std::shared_ptr<MutableCSSPropertyValueSet>,
                                       CSSKeyframeRule*);

 private:
  void DidMutate(MutationType) override;
  bool IsKeyframeStyle() const final { return true; }
};


}

#endif  // WEBF_CORE_CSS_KEYFRAME_STYLE_RULE_CSS_STYLE_DECLARATION_H_
