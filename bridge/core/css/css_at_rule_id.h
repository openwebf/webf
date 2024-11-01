// Copyright 2015 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef WEBF_CSS_AT_RULE_ID_H
#define WEBF_CSS_AT_RULE_ID_H

#include <string>

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
  // CSS Functions
  kCSSAtRuleFunction,
};

CSSAtRuleID CssAtRuleID(const std::string_view& name);
std::string CssAtRuleIDToString(CSSAtRuleID id);


}  // namespace webf

#endif  // WEBF_CSS_AT_RULE_ID_H
