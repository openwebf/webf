//
// Created by 谢作兵 on 12/06/24.
//

#ifndef WEBF_CSS_AT_RULE_ID_H
#define WEBF_CSS_AT_RULE_ID_H


namespace webf {

class StringView;
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

CSSAtRuleID CssAtRuleID(StringView name);
StringView CssAtRuleIDToString(CSSAtRuleID id);


}  // namespace webf

#endif  // WEBF_CSS_AT_RULE_ID_H
