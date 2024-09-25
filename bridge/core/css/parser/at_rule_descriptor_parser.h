// Copyright 2017 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#include "at_rule_descriptors.h"
#include "core/css/style_rule.h"
#include "foundation/macros.h"

namespace webf {

class CSSParserContext;
class CSSParserTokenRange;
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
                                                                 CSSParserTokenRange&,
                                                                 std::shared_ptr<const CSSParserContext>);
  static std::shared_ptr<const CSSValue> ParseFontFaceDescriptor(AtRuleDescriptorID,
                                                                 const std::string& value,
                                                                 std::shared_ptr<const CSSParserContext>);
  static std::shared_ptr<const CSSValue> ParseFontFaceDescriptor(AtRuleDescriptorID,
                                                                 const CSSTokenizedValue&,
                                                                 std::shared_ptr<const CSSParserContext>);
  static std::shared_ptr<const CSSValue> ParseFontFaceDeclaration(CSSParserTokenRange&, std::shared_ptr<const CSSParserContext>);
  static std::shared_ptr<const CSSValue> ParseAtPropertyDescriptor(AtRuleDescriptorID,
                                                                   const CSSTokenizedValue&,
                                                                   std::shared_ptr<const CSSParserContext>);
  static std::shared_ptr<const CSSValue> ParseAtFontPaletteValuesDescriptor(AtRuleDescriptorID,
                                                                            CSSParserTokenRange&,
                                                                            std::shared_ptr<const CSSParserContext>);
  static std::shared_ptr<const CSSValue> ParseAtViewTransitionDescriptor(AtRuleDescriptorID,
                                                                         CSSParserTokenRange&,
                                                                         std::shared_ptr<const CSSParserContext>);
};

}  // namespace webf