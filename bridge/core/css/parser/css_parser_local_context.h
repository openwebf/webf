// Copyright 2017 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#ifndef WEBF_CORE_CSS_PARSER_CSS_PARSER_LOCAL_CONTEXT_H_
#define WEBF_CORE_CSS_PARSER_CSS_PARSER_LOCAL_CONTEXT_H_

#include "css_property_names.h"
#include "css_value_keywords.h"
#include "foundation/macros.h"

namespace webf {

// A wrapper class containing all local context when parsing a property.

class CSSParserLocalContext {
  WEBF_STACK_ALLOCATED();

 public:
  CSSParserLocalContext() = default;

  CSSParserLocalContext WithAliasParsing(bool use_alias_parsing) const {
    CSSParserLocalContext context = *this;
    context.use_alias_parsing_ = use_alias_parsing;
    return context;
  }

  CSSParserLocalContext WithAnimationTainted(bool is_animation_tainted) const {
    CSSParserLocalContext context = *this;
    context.is_animation_tainted_ = is_animation_tainted;
    return context;
  }

  CSSParserLocalContext WithCurrentShorthand(CSSPropertyID current_shorthand) const {
    CSSParserLocalContext context = *this;
    context.current_shorthand_ = current_shorthand;
    return context;
  }

  bool UseAliasParsing() const { return use_alias_parsing_; }

  // Any custom property used in a @keyframes rule becomes animation-tainted,
  // which prevents the custom property from being substituted into the
  // 'animation' property, or one of its longhands.
  //
  // https://drafts.csswg.org/css-variables/#animation-tainted
  bool IsAnimationTainted() const { return is_animation_tainted_; }

  CSSPropertyID CurrentShorthand() const { return current_shorthand_; }

 private:
  bool use_alias_parsing_ = false;
  bool is_animation_tainted_ = false;
  CSSPropertyID current_shorthand_ = CSSPropertyID::kInvalid;
};

}  // namespace webf

#endif  // WEBF_CORE_CSS_PARSER_CSS_PARSER_LOCAL_CONTEXT_H_
