// Copyright 2015 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef WEBF_CORE_CSS_PARSER_CSS_AT_RULE_ID_H_
#define WEBF_CORE_CSS_PARSER_CSS_AT_RULE_ID_H_

#include "../../../foundation/string/string_view.h"

namespace webf {

class CSSParserContext;

enum class CSSAtRuleID {
  kCSSAtRuleInvalid,
  kCSSAtRuleViewTransition,
  kCSSAtRuleCharset,
  kCSSAtRuleFontFace,
  kCSSAtRuleFontPaletteValues,
  kCSSAtRuleImport,
  kCSSAtRuleKeyframes,
  kCSSAtRuleLayer,
  kCSSAtRuleMedia,
  kCSSAtRuleNamespace,
  kCSSAtRulePage,
  kCSSAtRulePositionTry,
  kCSSAtRuleProperty,
  kCSSAtRuleContainer,
  kCSSAtRuleCounterStyle,
  kCSSAtRuleScope,
  kCSSAtRuleStartingStyle,
  kCSSAtRuleSupports,
  kCSSAtRuleWebkitKeyframes,
  // Font-feature-values related at-rule ids below:
  kCSSAtRuleAnnotation,
  kCSSAtRuleCharacterVariant,
  kCSSAtRuleFontFeatureValues,
  kCSSAtRuleOrnaments,
  kCSSAtRuleStylistic,
  kCSSAtRuleStyleset,
  kCSSAtRuleSwash,
  // https://www.w3.org/TR/css-page-3/#syntax-page-selector
  kCSSAtRuleTopLeftCorner,
  kCSSAtRuleTopLeft,
  kCSSAtRuleTopCenter,
  kCSSAtRuleTopRight,
  kCSSAtRuleTopRightCorner,
  kCSSAtRuleBottomLeftCorner,
  kCSSAtRuleBottomLeft,
  kCSSAtRuleBottomCenter,
  kCSSAtRuleBottomRight,
  kCSSAtRuleBottomRightCorner,
  kCSSAtRuleLeftTop,
  kCSSAtRuleLeftMiddle,
  kCSSAtRuleLeftBottom,
  kCSSAtRuleRightTop,
  kCSSAtRuleRightMiddle,
  kCSSAtRuleRightBottom,
  // CSS Functions and Mixins
  kCSSAtRuleFunction,
  kCSSAtRuleMixin,
  kCSSAtRuleApplyMixin,

  kCount  // Must go last.
};

CSSAtRuleID CssAtRuleID(StringView name);
StringView CssAtRuleIDToString(CSSAtRuleID id);

void CountAtRule(const CSSParserContext* context, CSSAtRuleID rule_id);

}  // namespace webf

#endif  // WEBF_CORE_CSS_PARSER_CSS_AT_RULE_ID_H_