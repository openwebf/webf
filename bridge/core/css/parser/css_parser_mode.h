//
// Created by 谢作兵 on 07/06/24.
//

#ifndef WEBF_CSS_PARSER_MODE_H
#define WEBF_CSS_PARSER_MODE_H

#include <stdint.h>

namespace webf {

// Must not grow beyond 4 bits, due to packing in CSSPropertyValueSet.
enum CSSParserMode : uint8_t {
  kHTMLStandardMode,
  kHTMLQuirksMode,
  // SVG attributes are parsed in quirks mode but rules differ slightly.
  kSVGAttributeMode,
  // @font-face rules are specially tagged in CSSPropertyValueSet so
  // CSSOM modifications don't treat them as style rules.
  kCSSFontFaceRuleMode,
  // @keyframes rules are specially tagged in CSSPropertyValueSet so CSSOM
  // modifications don't allow setting animation-* in their keyframes.
  kCSSKeyframeRuleMode,
  // @property rules are specially tagged so modifications through the
  // inspector don't treat them as style rules.
  kCSSPropertyRuleMode,
  // @font-palette-values rules are specially tagged so modifications through
  // the inspector don't treat them as style rules.
  kCSSFontPaletteValuesRuleMode,
  // @position-try rules have limitations on what they allow, also through
  // mutations in CSSOM.
  // https://drafts.csswg.org/css-anchor-position-1/#om-position-try
  kCSSPositionTryRuleMode,
  // User agent stylesheets are parsed in standards mode but also allows
  // internal properties and values.
  kUASheetMode,
  // This should always be the last entry.
  kNumCSSParserModes
};

inline bool IsQuirksModeBehavior(CSSParserMode mode) {
  return mode == kHTMLQuirksMode;
}

inline bool IsUASheetBehavior(CSSParserMode mode) {
  return mode == kUASheetMode;
}

inline bool IsUseCounterEnabledForMode(CSSParserMode mode) {
  // We don't count the UA style sheet in our statistics.
  return mode != kUASheetMode;
}

// Used in CSSParser APIs to say if we should defer parsing of declaration lists
// in style rules until we need them for CSSOM access, or for applying matched
// rules to computed style.
enum class CSSDeferPropertyParsing { kNo, kYes };

}  // namespace webf

#endif  // WEBF_CSS_PARSER_MODE_H
