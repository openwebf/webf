// Copyright 2015 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "core/css/parser/css_at_rule_id.h"

#include <optional>

#include <cassert>
#include "../../../foundation/string/ascii_types.h"
#include "../../../foundation/string/string_builder.h"
#include "foundation/string/utf8_codecs.h"
#include "core/css/parser/css_parser_context.h"

namespace webf {

CSSAtRuleID CssAtRuleID(StringView name) {
  if (name.IsNull()) {
    return CSSAtRuleID::kCSSAtRuleInvalid;
  }

  // Convert StringView to UTF-8 for comparison, regardless of backing width.
  UTF8String utf8_string = UTF8Codecs::Encode(name);
  
  if (EqualIgnoringASCIICase(utf8_string, "view-transition")) {
    return CSSAtRuleID::kCSSAtRuleViewTransition;
  }
  if (EqualIgnoringASCIICase(utf8_string, "charset")) {
    return CSSAtRuleID::kCSSAtRuleCharset;
  }
  if (EqualIgnoringASCIICase(utf8_string, "font-face")) {
    return CSSAtRuleID::kCSSAtRuleFontFace;
  }
  if (EqualIgnoringASCIICase(utf8_string, "font-palette-values")) {
    return CSSAtRuleID::kCSSAtRuleFontPaletteValues;
  }
  if (EqualIgnoringASCIICase(utf8_string, "font-feature-values")) {
    return CSSAtRuleID::kCSSAtRuleFontFeatureValues;
  }
  if (EqualIgnoringASCIICase(utf8_string, "stylistic")) {
    return CSSAtRuleID::kCSSAtRuleStylistic;
  }
  if (EqualIgnoringASCIICase(utf8_string, "styleset")) {
    return CSSAtRuleID::kCSSAtRuleStyleset;
  }
  if (EqualIgnoringASCIICase(utf8_string, "character-variant")) {
    return CSSAtRuleID::kCSSAtRuleCharacterVariant;
  }
  if (EqualIgnoringASCIICase(utf8_string, "swash")) {
    return CSSAtRuleID::kCSSAtRuleSwash;
  }
  if (EqualIgnoringASCIICase(utf8_string, "ornaments")) {
    return CSSAtRuleID::kCSSAtRuleOrnaments;
  }
  if (EqualIgnoringASCIICase(utf8_string, "annotation")) {
    return CSSAtRuleID::kCSSAtRuleAnnotation;
  }
  if (EqualIgnoringASCIICase(utf8_string, "import")) {
    return CSSAtRuleID::kCSSAtRuleImport;
  }
  if (EqualIgnoringASCIICase(utf8_string, "keyframes")) {
    return CSSAtRuleID::kCSSAtRuleKeyframes;
  }
  if (EqualIgnoringASCIICase(utf8_string, "layer")) {
    return CSSAtRuleID::kCSSAtRuleLayer;
  }
  if (EqualIgnoringASCIICase(utf8_string, "media")) {
    return CSSAtRuleID::kCSSAtRuleMedia;
  }
  if (EqualIgnoringASCIICase(utf8_string, "namespace")) {
    return CSSAtRuleID::kCSSAtRuleNamespace;
  }
  if (EqualIgnoringASCIICase(utf8_string, "page")) {
    return CSSAtRuleID::kCSSAtRulePage;
  }
  if (EqualIgnoringASCIICase(utf8_string, "position-try")) {
    return CSSAtRuleID::kCSSAtRulePositionTry;
  }
  if (EqualIgnoringASCIICase(utf8_string, "property")) {
    return CSSAtRuleID::kCSSAtRuleProperty;
  }
  if (EqualIgnoringASCIICase(utf8_string, "container")) {
    return CSSAtRuleID::kCSSAtRuleContainer;
  }
  if (EqualIgnoringASCIICase(utf8_string, "counter-style")) {
    return CSSAtRuleID::kCSSAtRuleCounterStyle;
  }
  if (EqualIgnoringASCIICase(utf8_string, "scope")) {
    return CSSAtRuleID::kCSSAtRuleScope;
  }
  if (EqualIgnoringASCIICase(utf8_string, "supports")) {
    return CSSAtRuleID::kCSSAtRuleSupports;
  }
  if (EqualIgnoringASCIICase(utf8_string, "starting-style")) {
    return CSSAtRuleID::kCSSAtRuleStartingStyle;
  }
  if (EqualIgnoringASCIICase(utf8_string, "-webkit-keyframes")) {
    return CSSAtRuleID::kCSSAtRuleWebkitKeyframes;
  }

  // https://www.w3.org/TR/css-page-3/#syntax-page-selector
  if (EqualIgnoringASCIICase(utf8_string, "top-left-corner")) {
    return CSSAtRuleID::kCSSAtRuleTopLeftCorner;
  }
  if (EqualIgnoringASCIICase(utf8_string, "top-left")) {
    return CSSAtRuleID::kCSSAtRuleTopLeft;
  }
  if (EqualIgnoringASCIICase(utf8_string, "top-center")) {
    return CSSAtRuleID::kCSSAtRuleTopCenter;
  }
  if (EqualIgnoringASCIICase(utf8_string, "top-right")) {
    return CSSAtRuleID::kCSSAtRuleTopRight;
  }
  if (EqualIgnoringASCIICase(utf8_string, "top-right-corner")) {
    return CSSAtRuleID::kCSSAtRuleTopRightCorner;
  }
  if (EqualIgnoringASCIICase(utf8_string, "bottom-left-corner")) {
    return CSSAtRuleID::kCSSAtRuleBottomLeftCorner;
  }
  if (EqualIgnoringASCIICase(utf8_string, "bottom-left")) {
    return CSSAtRuleID::kCSSAtRuleBottomLeft;
  }
  if (EqualIgnoringASCIICase(utf8_string, "bottom-center")) {
    return CSSAtRuleID::kCSSAtRuleBottomCenter;
  }
  if (EqualIgnoringASCIICase(utf8_string, "bottom-right")) {
    return CSSAtRuleID::kCSSAtRuleBottomRight;
  }
  if (EqualIgnoringASCIICase(utf8_string, "bottom-right-corner")) {
    return CSSAtRuleID::kCSSAtRuleBottomRightCorner;
  }
  if (EqualIgnoringASCIICase(utf8_string, "left-top")) {
    return CSSAtRuleID::kCSSAtRuleLeftTop;
  }
  if (EqualIgnoringASCIICase(utf8_string, "left-middle")) {
    return CSSAtRuleID::kCSSAtRuleLeftMiddle;
  }
  if (EqualIgnoringASCIICase(utf8_string, "left-bottom")) {
    return CSSAtRuleID::kCSSAtRuleLeftBottom;
  }
  if (EqualIgnoringASCIICase(utf8_string, "right-top")) {
    return CSSAtRuleID::kCSSAtRuleRightTop;
  }
  if (EqualIgnoringASCIICase(utf8_string, "right-middle")) {
    return CSSAtRuleID::kCSSAtRuleRightMiddle;
  }
  if (EqualIgnoringASCIICase(utf8_string, "right-bottom")) {
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
