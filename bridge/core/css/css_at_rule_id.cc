// Copyright 2015 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "css_at_rule_id.h"
#include <memory>
#include <optional>
#include "foundation/string_view.h"

namespace webf {

CSSAtRuleID CssAtRuleID(const std::string_view& name) {
  if (EqualIgnoringASCIICase(name, "charset")) {
    return CSSAtRuleID::kCSSAtRuleCharset;
  }
  if (EqualIgnoringASCIICase(name, "font-face")) {
    return CSSAtRuleID::kCSSAtRuleFontFace;
  }
  if (EqualIgnoringASCIICase(name, "font-palette-values")) {
    return CSSAtRuleID::kCSSAtRuleFontPaletteValues;
  }
  if (EqualIgnoringASCIICase(name, "font-feature-values")) {
    return CSSAtRuleID::kCSSAtRuleFontFeatureValues;
  }
  if (EqualIgnoringASCIICase(name, "stylistic")) {
    return CSSAtRuleID::kCSSAtRuleStylistic;
  }
  if (EqualIgnoringASCIICase(name, "styleset")) {
    return CSSAtRuleID::kCSSAtRuleStyleset;
  }
  if (EqualIgnoringASCIICase(name, "character-variant")) {
    return CSSAtRuleID::kCSSAtRuleCharacterVariant;
  }
  if (EqualIgnoringASCIICase(name, "swash")) {
    return CSSAtRuleID::kCSSAtRuleSwash;
  }
  if (EqualIgnoringASCIICase(name, "ornaments")) {
    return CSSAtRuleID::kCSSAtRuleOrnaments;
  }
  if (EqualIgnoringASCIICase(name, "annotation")) {
    return CSSAtRuleID::kCSSAtRuleAnnotation;
  }
  if (EqualIgnoringASCIICase(name, "import")) {
    return CSSAtRuleID::kCSSAtRuleImport;
  }
  if (EqualIgnoringASCIICase(name, "keyframes")) {
    return CSSAtRuleID::kCSSAtRuleKeyframes;
  }
  if (EqualIgnoringASCIICase(name, "layer")) {
    return CSSAtRuleID::kCSSAtRuleLayer;
  }
  if (EqualIgnoringASCIICase(name, "media")) {
    return CSSAtRuleID::kCSSAtRuleMedia;
  }
  if (EqualIgnoringASCIICase(name, "namespace")) {
    return CSSAtRuleID::kCSSAtRuleNamespace;
  }
  if (EqualIgnoringASCIICase(name, "page")) {
    return CSSAtRuleID::kCSSAtRulePage;
  }
  if (EqualIgnoringASCIICase(name, "property")) {
    return CSSAtRuleID::kCSSAtRuleProperty;
  }
  if (EqualIgnoringASCIICase(name, "container")) {
    return CSSAtRuleID::kCSSAtRuleContainer;
  }
  if (EqualIgnoringASCIICase(name, "counter-style")) {
    return CSSAtRuleID::kCSSAtRuleCounterStyle;
  }
  if (EqualIgnoringASCIICase(name, "scope")) {
    return CSSAtRuleID::kCSSAtRuleScope;
  }
  if (EqualIgnoringASCIICase(name, "supports")) {
    return CSSAtRuleID::kCSSAtRuleSupports;
  }
  if (EqualIgnoringASCIICase(name, "starting-style")) {
    return CSSAtRuleID::kCSSAtRuleStartingStyle;
  }
  if (EqualIgnoringASCIICase(name, "-webkit-keyframes")) {
    return CSSAtRuleID::kCSSAtRuleWebkitKeyframes;
  }

  // https://www.w3.org/TR/css-page-3/#syntax-page-selector
  if (EqualIgnoringASCIICase(name, "top-left-corner")) {
    return CSSAtRuleID::kCSSAtRuleTopLeftCorner;
  }
  if (EqualIgnoringASCIICase(name, "top-left")) {
    return CSSAtRuleID::kCSSAtRuleTopLeft;
  }
  if (EqualIgnoringASCIICase(name, "top-center")) {
    return CSSAtRuleID::kCSSAtRuleTopCenter;
  }
  if (EqualIgnoringASCIICase(name, "top-right")) {
    return CSSAtRuleID::kCSSAtRuleTopRight;
  }
  if (EqualIgnoringASCIICase(name, "top-right-corner")) {
    return CSSAtRuleID::kCSSAtRuleTopRightCorner;
  }
  if (EqualIgnoringASCIICase(name, "bottom-left-corner")) {
    return CSSAtRuleID::kCSSAtRuleBottomLeftCorner;
  }
  if (EqualIgnoringASCIICase(name, "bottom-left")) {
    return CSSAtRuleID::kCSSAtRuleBottomLeft;
  }
  if (EqualIgnoringASCIICase(name, "bottom-center")) {
    return CSSAtRuleID::kCSSAtRuleBottomCenter;
  }
  if (EqualIgnoringASCIICase(name, "bottom-right")) {
    return CSSAtRuleID::kCSSAtRuleBottomRight;
  }
  if (EqualIgnoringASCIICase(name, "bottom-right-corner")) {
    return CSSAtRuleID::kCSSAtRuleBottomRightCorner;
  }
  if (EqualIgnoringASCIICase(name, "left-top")) {
    return CSSAtRuleID::kCSSAtRuleLeftTop;
  }
  if (EqualIgnoringASCIICase(name, "left-middle")) {
    return CSSAtRuleID::kCSSAtRuleLeftMiddle;
  }
  if (EqualIgnoringASCIICase(name, "left-bottom")) {
    return CSSAtRuleID::kCSSAtRuleLeftBottom;
  }
  if (EqualIgnoringASCIICase(name, "right-top")) {
    return CSSAtRuleID::kCSSAtRuleRightTop;
  }
  if (EqualIgnoringASCIICase(name, "right-middle")) {
    return CSSAtRuleID::kCSSAtRuleRightMiddle;
  }
  if (EqualIgnoringASCIICase(name, "right-bottom")) {
    return CSSAtRuleID::kCSSAtRuleRightBottom;
  }
  if (EqualIgnoringASCIICase(name, "function")) {
    return CSSAtRuleID::kCSSAtRuleFunction;
  }

  return CSSAtRuleID::kCSSAtRuleInvalid;
}

std::string CssAtRuleIDToString(CSSAtRuleID id) {
  switch (id) {
    case CSSAtRuleID::kCSSAtRuleViewTransition:
      return "@view-transition";
    case CSSAtRuleID::kCSSAtRuleCharset:
      return "@charset";
    case CSSAtRuleID::kCSSAtRuleFontFace:
      return "@font-face";
    case CSSAtRuleID::kCSSAtRuleFontPaletteValues:
      return "@font-palette-values";
    case CSSAtRuleID::kCSSAtRuleImport:
      return "@import";
    case CSSAtRuleID::kCSSAtRuleKeyframes:
      return "@keyframes";
    case CSSAtRuleID::kCSSAtRuleLayer:
      return "@layer";
    case CSSAtRuleID::kCSSAtRuleMedia:
      return "@media";
    case CSSAtRuleID::kCSSAtRuleNamespace:
      return "@namespace";
    case CSSAtRuleID::kCSSAtRulePage:
      return "@page";
    case CSSAtRuleID::kCSSAtRulePositionTry:
      return "@position-try";
    case CSSAtRuleID::kCSSAtRuleProperty:
      return "@property";
    case CSSAtRuleID::kCSSAtRuleContainer:
      return "@container";
    case CSSAtRuleID::kCSSAtRuleCounterStyle:
      return "@counter-style";
    case CSSAtRuleID::kCSSAtRuleScope:
      return "@scope";
    case CSSAtRuleID::kCSSAtRuleStartingStyle:
      return "@starting-style";
    case CSSAtRuleID::kCSSAtRuleSupports:
      return "@supports";
    case CSSAtRuleID::kCSSAtRuleWebkitKeyframes:
      return "@-webkit-keyframes";
    case CSSAtRuleID::kCSSAtRuleAnnotation:
      return "@annotation";
    case CSSAtRuleID::kCSSAtRuleCharacterVariant:
      return "@character-variant";
    case CSSAtRuleID::kCSSAtRuleFontFeatureValues:
      return "@font-feature-values";
    case CSSAtRuleID::kCSSAtRuleOrnaments:
      return "@ornaments";
    case CSSAtRuleID::kCSSAtRuleStylistic:
      return "@stylistic";
    case CSSAtRuleID::kCSSAtRuleStyleset:
      return "@styleset";
    case CSSAtRuleID::kCSSAtRuleSwash:
      return "@swash";
    case CSSAtRuleID::kCSSAtRuleTopLeftCorner:
      return "@top-left-corner";
    case CSSAtRuleID::kCSSAtRuleTopLeft:
      return "@top-left";
    case CSSAtRuleID::kCSSAtRuleTopCenter:
      return "@top-center";
    case CSSAtRuleID::kCSSAtRuleTopRight:
      return "@top-right";
    case CSSAtRuleID::kCSSAtRuleTopRightCorner:
      return "@top-right-corner";
    case CSSAtRuleID::kCSSAtRuleBottomLeftCorner:
      return "@bottom-left-corner";
    case CSSAtRuleID::kCSSAtRuleBottomLeft:
      return "@bottom-left";
    case CSSAtRuleID::kCSSAtRuleBottomCenter:
      return "@bottom-center";
    case CSSAtRuleID::kCSSAtRuleBottomRight:
      return "@bottom-right";
    case CSSAtRuleID::kCSSAtRuleBottomRightCorner:
      return "@bottom-right-corner";
    case CSSAtRuleID::kCSSAtRuleLeftTop:
      return "@left-top";
    case CSSAtRuleID::kCSSAtRuleLeftMiddle:
      return "@left-middle";
    case CSSAtRuleID::kCSSAtRuleLeftBottom:
      return "@left-bottom";
    case CSSAtRuleID::kCSSAtRuleRightTop:
      return "@right-top";
    case CSSAtRuleID::kCSSAtRuleRightMiddle:
      return "@right-middle";
    case CSSAtRuleID::kCSSAtRuleRightBottom:
      return "@right-bottom";
    case CSSAtRuleID::kCSSAtRuleFunction:
      return "@function";
    case CSSAtRuleID::kCSSAtRuleInvalid:
      assert_m(false, "NOTREACHED_IN_MIGRATION");
      //      NOTREACHED_IN_MIGRATION();
      return "";
  };
}

}  // namespace webf