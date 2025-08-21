// Copyright 2017 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#include "at_rule_descriptors.h"
#include "core/css/style_rule.h"
#include "foundation/macros.h"

namespace webf {

class CSSParserContext;
class CSSParserTokenStream;
class CSSValue;
struct CSSTokenizedValue;

class AtRuleDescriptorParser {
  WEBF_STATIC_ONLY(AtRuleDescriptorParser);

 public:
  static bool ParseAtRule(StyleRule::RuleType,
                          AtRuleDescriptorID,
                          const CSSTokenizedValue&,
                          std::shared_ptr<const CSSParserContext>,
                          std::vector<CSSPropertyValue>&);
  static std::shared_ptr<const CSSValue> ParseFontFaceDescriptor(AtRuleDescriptorID,
                                                                 CSSParserTokenStream&,
                                                                 std::shared_ptr<const CSSParserContext>);
  static std::shared_ptr<const CSSValue> ParseFontFaceDescriptor(AtRuleDescriptorID,
                                                                 const std::string& value,
                                                                 std::shared_ptr<const CSSParserContext>);
  // Convenience overload with engine String types
  static std::shared_ptr<const CSSValue> ParseFontFaceDescriptor(AtRuleDescriptorID id,
                                                                 StringView value,
                                                                 std::shared_ptr<const CSSParserContext> ctx) {
    return ParseFontFaceDescriptor(id, String(value).ToUTF8String(), ctx);
  }
  static std::shared_ptr<const CSSValue> ParseFontFaceDescriptor(AtRuleDescriptorID,
                                                                 const CSSTokenizedValue&,
                                                                 std::shared_ptr<const CSSParserContext>);
  static std::shared_ptr<const CSSValue> ParseFontFaceDeclaration(CSSParserTokenStream&,
                                                                  std::shared_ptr<const CSSParserContext>);
  static std::shared_ptr<const CSSValue> ParseAtPropertyDescriptor(AtRuleDescriptorID,
                                                                   const CSSTokenizedValue&,
                                                                   std::shared_ptr<const CSSParserContext>);
  static std::shared_ptr<const CSSValue> ParseAtFontPaletteValuesDescriptor(AtRuleDescriptorID,
                                                                            CSSParserTokenStream&,
                                                                            std::shared_ptr<const CSSParserContext>);
  static std::shared_ptr<const CSSValue> ParseAtViewTransitionDescriptor(AtRuleDescriptorID,
                                                                         CSSParserTokenStream&,
                                                                         std::shared_ptr<const CSSParserContext>);
  static std::shared_ptr<const CSSValue> ParseAtCounterStyleDescriptor(AtRuleDescriptorID,
                                                                       CSSParserTokenStream&,
                                                                       std::shared_ptr<const CSSParserContext>);
};

}  // namespace webf
