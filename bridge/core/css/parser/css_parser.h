// Copyright 2014 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef WEBF_CSS_PARSER_H
#define WEBF_CSS_PARSER_H

#include "core/base/containers/span.h"
#include "core/css/css_color.h"
#include "core/css/css_primitive_value.h"
#include "core/css/css_property_value_set.h"
#include "core/css/parser/css_parser_observer.h"
#include "core/css/style_rule_keyframe.h"
#include "core/platform/graphics/color.h"
#include "css_parser_mode.h"
#include "foundation/macros.h"

namespace webf {

class CSSParserContext;
class StyleSheetContents;
enum class ParseSheetResult;

// This class serves as the public API for the css/parser subsystem
class CSSParser {
  WEBF_STATIC_ONLY(CSSParser);

 public:
  // As well as regular rules, allows @import and @namespace but not @charset
  static std::shared_ptr<StyleRuleBase> ParseRule(std::shared_ptr<CSSParserContext> context,
                                                  std::shared_ptr<StyleSheetContents> style_sheet,
                                                  CSSNestingType,
                                                  std::shared_ptr<StyleRule> parent_rule_for_nesting,
                                                  const std::string& rule);

  static ParseSheetResult ParseSheet(std::shared_ptr<CSSParserContext>,
                                     std::shared_ptr<StyleSheetContents>,
                                     const std::string&,
                                     CSSDeferPropertyParsing defer_property_parsing = CSSDeferPropertyParsing::kNo,
                                     bool allow_import_rules = true);

  // See CSSSelectorParser for lifetime of the returned value.
  static tcb::span<CSSSelector> ParseSelector(std::shared_ptr<const CSSParserContext>,
                                              CSSNestingType,
                                              std::shared_ptr<const StyleRule> parent_rule_for_nesting,
                                              bool is_within_scope,
                                              std::shared_ptr<StyleSheetContents>,
                                              const std::string&,
                                              std::vector<CSSSelector>& arena);
  static std::shared_ptr<const CSSSelectorList> ParsePageSelector(std::shared_ptr<const CSSParserContext> context,
                                                                  std::shared_ptr<StyleSheetContents>,
                                                                  const std::string&);
  static std::shared_ptr<StyleRuleBase> ParseMarginRule(std::shared_ptr<const CSSParserContext> context,
                                                        std::shared_ptr<StyleSheetContents>,
                                                        const std::string&);
  static bool ParseDeclarationList(std::shared_ptr<CSSParserContext>, MutableCSSPropertyValueSet*, const std::string&);

  static MutableCSSPropertyValueSet::SetResult ParseValue(MutableCSSPropertyValueSet*,
                                                          CSSPropertyID unresolved_property,
                                                          const std::string& value,
                                                          bool important,
                                                          const ExecutingContext* execution_context = nullptr);
  static MutableCSSPropertyValueSet::SetResult ParseValue(MutableCSSPropertyValueSet*,
                                                          CSSPropertyID unresolved_property,
                                                          const std::string& value,
                                                          bool important,
                                                          std::shared_ptr<StyleSheetContents>,
                                                          const ExecutingContext* execution_context = nullptr);

  static MutableCSSPropertyValueSet::SetResult ParseValue(MutableCSSPropertyValueSet* declaration,
                                                          CSSPropertyID unresolved_property,
                                                          const std::string& string,
                                                          bool important,
                                                          std::shared_ptr<const CSSParserContext> context);

  static MutableCSSPropertyValueSet::SetResult ParseValueForCustomProperty(MutableCSSPropertyValueSet*,
                                                                           const std::string& property_name,
                                                                           const std::string& value,
                                                                           bool important,
                                                                           std::shared_ptr<StyleSheetContents>,
                                                                           bool is_animation_tainted);

  // This is for non-shorthands only
  static std::shared_ptr<const CSSValue> ParseSingleValue(CSSPropertyID,
                                                          const std::string&,
                                                          std::shared_ptr<CSSParserContext>);

  static const std::shared_ptr<const CSSValue>* ParseFontFaceDescriptor(CSSPropertyID,
                                                                        const std::string&,
                                                                        std::shared_ptr<CSSParserContext>);

  static std::shared_ptr<const ImmutableCSSPropertyValueSet> ParseInlineStyleDeclaration(const std::string&, Element*);
  static std::shared_ptr<const ImmutableCSSPropertyValueSet> ParseInlineStyleDeclaration(const std::string&,
                                                                                         CSSParserMode,
                                                                                         const Document*);

  static std::unique_ptr<std::vector<KeyframeOffset>> ParseKeyframeKeyList(std::shared_ptr<CSSParserContext>,
                                                                           const std::string&);
  static std::shared_ptr<StyleRuleKeyframe> ParseKeyframeRule(std::shared_ptr<CSSParserContext>, const std::string&);
  static std::string ParseCustomPropertyName(const std::string&);

  static bool ParseSupportsCondition(const std::string&, const ExecutingContext*);

  // The color will only be changed when string contains a valid CSS color, so
  // callers can set it to a default color and ignore the boolean result.
  static bool ParseColor(Color&, const std::string&, bool strict = false);

  static void ParseDeclarationListForInspector(std::shared_ptr<CSSParserContext>,
                                               const std::string&,
                                               CSSParserObserver&);

  static std::shared_ptr<const CSSPrimitiveValue> ParseLengthPercentage(const std::string&,
                                                                        std::shared_ptr<CSSParserContext>,
                                                                        CSSPrimitiveValue::ValueRange);

  // https://html.spec.whatwg.org/multipage/canvas.html#dom-context-2d-font
  // https://drafts.csswg.org/css-font-loading/#find-the-matching-font-faces
  static std::shared_ptr<MutableCSSPropertyValueSet> ParseFont(const std::string&, const ExecutingContext*);

 private:
  static MutableCSSPropertyValueSet::SetResult ParseValue(MutableCSSPropertyValueSet*,
                                                          CSSPropertyID unresolved_property,
                                                          const std::string&,
                                                          bool important,
                                                          std::shared_ptr<CSSParserContext>);
};

}  // namespace webf

#endif  // WEBF_CSS_PARSER_H
