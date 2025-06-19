// Copyright 2015 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "core/css/parser/css_at_rule_id.h"

#include <optional>

#include "core/css/parser/css_parser_context.h"
#include "foundation/ascii_types.h"
#include "foundation/string_builder.h"
#include <cassert>

namespace webf {

CSSAtRuleID CssAtRuleID(StringView name) {
  // Convert StringView to std::string_view for comparison
  std::string_view name_view;
  if (!name.IsNull() && name.Is8Bit()) {
    name_view = std::string_view(name.Characters8(), name.length());
  } else if (!name.IsNull()) {
    // For 16-bit strings, we need to convert to 8-bit first
    // For now, just return invalid for non-8bit strings
    return CSSAtRuleID::kCSSAtRuleInvalid;
  }
  
  if (EqualIgnoringASCIICase(name_view, "view-transition")) {
    return CSSAtRuleID::kCSSAtRuleViewTransition;
  }
  if (EqualIgnoringASCIICase(name_view, "charset")) {
    return CSSAtRuleID::kCSSAtRuleCharset;
  }
  if (EqualIgnoringASCIICase(name_view, "font-face")) {
    return CSSAtRuleID::kCSSAtRuleFontFace;
  }
  if (EqualIgnoringASCIICase(name_view, "font-palette-values")) {
    return CSSAtRuleID::kCSSAtRuleFontPaletteValues;
  }
  if (EqualIgnoringASCIICase(name_view, "font-feature-values")) {
    return CSSAtRuleID::kCSSAtRuleFontFeatureValues;
  }
  if (EqualIgnoringASCIICase(name_view, "stylistic")) {
    return CSSAtRuleID::kCSSAtRuleStylistic;
  }
  if (EqualIgnoringASCIICase(name_view, "styleset")) {
    return CSSAtRuleID::kCSSAtRuleStyleset;
  }
  if (EqualIgnoringASCIICase(name_view, "character-variant")) {
    return CSSAtRuleID::kCSSAtRuleCharacterVariant;
  }
  if (EqualIgnoringASCIICase(name_view, "swash")) {
    return CSSAtRuleID::kCSSAtRuleSwash;
  }
  if (EqualIgnoringASCIICase(name_view, "ornaments")) {
    return CSSAtRuleID::kCSSAtRuleOrnaments;
  }
  if (EqualIgnoringASCIICase(name_view, "annotation")) {
    return CSSAtRuleID::kCSSAtRuleAnnotation;
  }
  if (EqualIgnoringASCIICase(name_view, "import")) {
    return CSSAtRuleID::kCSSAtRuleImport;
  }
  if (EqualIgnoringASCIICase(name_view, "keyframes")) {
    return CSSAtRuleID::kCSSAtRuleKeyframes;
  }
  if (EqualIgnoringASCIICase(name_view, "layer")) {
    return CSSAtRuleID::kCSSAtRuleLayer;
  }
  if (EqualIgnoringASCIICase(name_view, "media")) {
    return CSSAtRuleID::kCSSAtRuleMedia;
  }
  if (EqualIgnoringASCIICase(name_view, "namespace")) {
    return CSSAtRuleID::kCSSAtRuleNamespace;
  }
  if (EqualIgnoringASCIICase(name_view, "page")) {
    return CSSAtRuleID::kCSSAtRulePage;
  }
  if (EqualIgnoringASCIICase(name_view, "position-try")) {
    return CSSAtRuleID::kCSSAtRulePositionTry;
  }
  if (EqualIgnoringASCIICase(name_view, "property")) {
    return CSSAtRuleID::kCSSAtRuleProperty;
  }
  if (EqualIgnoringASCIICase(name_view, "container")) {
    return CSSAtRuleID::kCSSAtRuleContainer;
  }
  if (EqualIgnoringASCIICase(name_view, "counter-style")) {
    return CSSAtRuleID::kCSSAtRuleCounterStyle;
  }
  if (EqualIgnoringASCIICase(name_view, "scope")) {
    return CSSAtRuleID::kCSSAtRuleScope;
  }
  if (EqualIgnoringASCIICase(name_view, "supports")) {
    return CSSAtRuleID::kCSSAtRuleSupports;
  }
  if (EqualIgnoringASCIICase(name_view, "starting-style")) {
    return CSSAtRuleID::kCSSAtRuleStartingStyle;
  }
  if (EqualIgnoringASCIICase(name_view, "-webkit-keyframes")) {
    return CSSAtRuleID::kCSSAtRuleWebkitKeyframes;
  }

  // https://www.w3.org/TR/css-page-3/#syntax-page-selector
  if (EqualIgnoringASCIICase(name_view, "top-left-corner")) {
    return CSSAtRuleID::kCSSAtRuleTopLeftCorner;
  }
  if (EqualIgnoringASCIICase(name_view, "top-left")) {
    return CSSAtRuleID::kCSSAtRuleTopLeft;
  }
  if (EqualIgnoringASCIICase(name_view, "top-center")) {
    return CSSAtRuleID::kCSSAtRuleTopCenter;
  }
  if (EqualIgnoringASCIICase(name_view, "top-right")) {
    return CSSAtRuleID::kCSSAtRuleTopRight;
  }
  if (EqualIgnoringASCIICase(name_view, "top-right-corner")) {
    return CSSAtRuleID::kCSSAtRuleTopRightCorner;
  }
  if (EqualIgnoringASCIICase(name_view, "bottom-left-corner")) {
    return CSSAtRuleID::kCSSAtRuleBottomLeftCorner;
  }
  if (EqualIgnoringASCIICase(name_view, "bottom-left")) {
    return CSSAtRuleID::kCSSAtRuleBottomLeft;
  }
  if (EqualIgnoringASCIICase(name_view, "bottom-center")) {
    return CSSAtRuleID::kCSSAtRuleBottomCenter;
  }
  if (EqualIgnoringASCIICase(name_view, "bottom-right")) {
    return CSSAtRuleID::kCSSAtRuleBottomRight;
  }
  if (EqualIgnoringASCIICase(name_view, "bottom-right-corner")) {
    return CSSAtRuleID::kCSSAtRuleBottomRightCorner;
  }
  if (EqualIgnoringASCIICase(name_view, "left-top")) {
    return CSSAtRuleID::kCSSAtRuleLeftTop;
  }
  if (EqualIgnoringASCIICase(name_view, "left-middle")) {
    return CSSAtRuleID::kCSSAtRuleLeftMiddle;
  }
  if (EqualIgnoringASCIICase(name_view, "left-bottom")) {
    return CSSAtRuleID::kCSSAtRuleLeftBottom;
  }
  if (EqualIgnoringASCIICase(name_view, "right-top")) {
    return CSSAtRuleID::kCSSAtRuleRightTop;
  }
  if (EqualIgnoringASCIICase(name_view, "right-middle")) {
    return CSSAtRuleID::kCSSAtRuleRightMiddle;
  }
  if (EqualIgnoringASCIICase(name_view, "right-bottom")) {
    return CSSAtRuleID::kCSSAtRuleRightBottom;
  }

  // CSS Functions and Mixins - not enabled in WebF yet
  // if (RuntimeEnabledFeatures::CSSFunctionsEnabled() &&
  //     EqualIgnoringASCIICase(name_view, "function")) {
  //   return CSSAtRuleID::kCSSAtRuleFunction;
  // }
  // if (RuntimeEnabledFeatures::CSSMixinsEnabled()) {
  //   if (EqualIgnoringASCIICase(name_view, "mixin")) {
  //     return CSSAtRuleID::kCSSAtRuleMixin;
  //   }
  //   if (EqualIgnoringASCIICase(name_view, "apply")) {
  //     return CSSAtRuleID::kCSSAtRuleApplyMixin;
  //   }
  // }

  return CSSAtRuleID::kCSSAtRuleInvalid;
}

StringView CssAtRuleIDToString(CSSAtRuleID id) {
  switch (id) {
    case CSSAtRuleID::kCSSAtRuleViewTransition:
      return StringView("@view-transition");
    case CSSAtRuleID::kCSSAtRuleCharset:
      return StringView("@charset");
    case CSSAtRuleID::kCSSAtRuleFontFace:
      return StringView("@font-face");
    case CSSAtRuleID::kCSSAtRuleFontPaletteValues:
      return StringView("@font-palette-values");
    case CSSAtRuleID::kCSSAtRuleImport:
      return StringView("@import");
    case CSSAtRuleID::kCSSAtRuleKeyframes:
      return StringView("@keyframes");
    case CSSAtRuleID::kCSSAtRuleLayer:
      return StringView("@layer");
    case CSSAtRuleID::kCSSAtRuleMedia:
      return StringView("@media");
    case CSSAtRuleID::kCSSAtRuleNamespace:
      return StringView("@namespace");
    case CSSAtRuleID::kCSSAtRulePage:
      return StringView("@page");
    case CSSAtRuleID::kCSSAtRulePositionTry:
      return StringView("@position-try");
    case CSSAtRuleID::kCSSAtRuleProperty:
      return StringView("@property");
    case CSSAtRuleID::kCSSAtRuleContainer:
      return StringView("@container");
    case CSSAtRuleID::kCSSAtRuleCounterStyle:
      return StringView("@counter-style");
    case CSSAtRuleID::kCSSAtRuleScope:
      return StringView("@scope");
    case CSSAtRuleID::kCSSAtRuleStartingStyle:
      return StringView("@starting-style");
    case CSSAtRuleID::kCSSAtRuleSupports:
      return StringView("@supports");
    case CSSAtRuleID::kCSSAtRuleWebkitKeyframes:
      return StringView("@-webkit-keyframes");
    case CSSAtRuleID::kCSSAtRuleAnnotation:
      return StringView("@annotation");
    case CSSAtRuleID::kCSSAtRuleCharacterVariant:
      return StringView("@character-variant");
    case CSSAtRuleID::kCSSAtRuleFontFeatureValues:
      return StringView("@font-feature-values");
    case CSSAtRuleID::kCSSAtRuleOrnaments:
      return StringView("@ornaments");
    case CSSAtRuleID::kCSSAtRuleStylistic:
      return StringView("@stylistic");
    case CSSAtRuleID::kCSSAtRuleStyleset:
      return StringView("@styleset");
    case CSSAtRuleID::kCSSAtRuleSwash:
      return StringView("@swash");
    case CSSAtRuleID::kCSSAtRuleTopLeftCorner:
      return StringView("@top-left-corner");
    case CSSAtRuleID::kCSSAtRuleTopLeft:
      return StringView("@top-left");
    case CSSAtRuleID::kCSSAtRuleTopCenter:
      return StringView("@top-center");
    case CSSAtRuleID::kCSSAtRuleTopRight:
      return StringView("@top-right");
    case CSSAtRuleID::kCSSAtRuleTopRightCorner:
      return StringView("@top-right-corner");
    case CSSAtRuleID::kCSSAtRuleBottomLeftCorner:
      return StringView("@bottom-left-corner");
    case CSSAtRuleID::kCSSAtRuleBottomLeft:
      return StringView("@bottom-left");
    case CSSAtRuleID::kCSSAtRuleBottomCenter:
      return StringView("@bottom-center");
    case CSSAtRuleID::kCSSAtRuleBottomRight:
      return StringView("@bottom-right");
    case CSSAtRuleID::kCSSAtRuleBottomRightCorner:
      return StringView("@bottom-right-corner");
    case CSSAtRuleID::kCSSAtRuleLeftTop:
      return StringView("@left-top");
    case CSSAtRuleID::kCSSAtRuleLeftMiddle:
      return StringView("@left-middle");
    case CSSAtRuleID::kCSSAtRuleLeftBottom:
      return StringView("@left-bottom");
    case CSSAtRuleID::kCSSAtRuleRightTop:
      return StringView("@right-top");
    case CSSAtRuleID::kCSSAtRuleRightMiddle:
      return StringView("@right-middle");
    case CSSAtRuleID::kCSSAtRuleRightBottom:
      return StringView("@right-bottom");
    case CSSAtRuleID::kCSSAtRuleFunction:
      return StringView("@function");
    case CSSAtRuleID::kCSSAtRuleMixin:
      return StringView("@mixin");
    case CSSAtRuleID::kCSSAtRuleApplyMixin:
      return StringView("@apply");
    case CSSAtRuleID::kCSSAtRuleInvalid:
    case CSSAtRuleID::kCount:
      assert(false);
      return StringView("");
  }
  return StringView("");
}

void CountAtRule(const CSSParserContext* context, CSSAtRuleID rule_id) {
  // WebF doesn't have usage counter infrastructure yet
  // This is a stub for future implementation
}

}  // namespace webf