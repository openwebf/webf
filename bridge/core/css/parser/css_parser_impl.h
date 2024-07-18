// Copyright 2014 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef WEBF_CSS_PARSER_IMPL_H
#define WEBF_CSS_PARSER_IMPL_H

#include <span>

#include "foundation/macros.h"
#include "bindings/qjs/atomic_string.h"
#include "css_parser_mode.h"
#include "css_nesting_type.h"
#include "core/css/css_at_rule_id.h"

namespace webf {

class CSSParserContext;
class StyleSheetContents;
class CSSLazyParsingState;
class CSSParserTokenStream;
class CSSParserObserver;
class CSSSelector;
class CSSParserTokenRange;
class StyleRule;
class StyleRuleBase;
class StyleRuleKeyframe;
class CSSPropertyValue; // TODO(xiezuobing)

enum class ParseSheetResult {
  kSucceeded,
  kHasUnallowedImportRule,
};

class CSSParserImpl {
  WEBF_STACK_ALLOCATED();
 public:
  explicit CSSParserImpl(std::shared_ptr<const CSSParserContext>,
                         std::shared_ptr<StyleSheetContents> = nullptr);

  enum AllowedRulesType {
    // As per css-syntax, css-cascade and css-namespaces, @charset rules
    // must come first, followed by @layer, @import then @namespace.
    // AllowImportRules actually means we allow @import and any rules that
    // may follow it, i.e. @namespace rules and regular rules.
    // AllowCharsetRules and AllowNamespaceRules behave similarly.
    kAllowCharsetRules,
    kAllowLayerStatementRules,
    kAllowImportRules,
    kAllowNamespaceRules,
    kRegularRules,
    kKeyframeRules,
    kFontFeatureRules,
    // For parsing at-rules inside declaration lists.
    kNoRules,
    // https://drafts.csswg.org/css-nesting/#nested-group-rules
    kNestedGroupRules,
    // https://www.w3.org/TR/css-page-3/#syntax-page-selector
    kPageMarginRules,
  };

  // Represents the start and end offsets of a CSSParserTokenRange.
  struct RangeOffset {
    uint32_t start, end;

    RangeOffset(uint32_t start, uint32_t end) : start(start), end(end) {
      assert(start <= end);
    }

    // Used when we don't care what the offset is (typically when we don't have
    // an observer).
    static RangeOffset Ignore() { return {0, 0}; }
  };

//  static MutableCSSPropertyValueSet::SetResult ParseValue(
//      MutableCSSPropertyValueSet*,
//      CSSPropertyID,
//      StringView,
//      bool important,
//      const CSSParserContext*);
//  static MutableCSSPropertyValueSet::SetResult ParseVariableValue(
//      MutableCSSPropertyValueSet*,
//      const AtomicString& property_name,
//      StringView,
//      bool important,
//      const CSSParserContext*,
//      bool is_animation_tainted);
//  static ImmutableCSSPropertyValueSet* ParseInlineStyleDeclaration(
//      const String&,
//      Element*);
//  static ImmutableCSSPropertyValueSet* ParseInlineStyleDeclaration(
//      const String&,
//      CSSParserMode,
//      SecureContextMode,
//      const Document*);
//  // NOTE: This function can currently only be used to parse a
//  // declaration list with no nested rules, not a full style rule
//  // (it is only used for things like inline style).
//  static bool ParseDeclarationList(MutableCSSPropertyValueSet*,
//                                   const String&,
//                                   const CSSParserContext*);
//  static StyleRuleBase* ParseRule(const String&,
//                                  const CSSParserContext*,
//                                  CSSNestingType,
//                                  StyleRule* parent_rule_for_nesting,
//                                  StyleSheetContents*,
//                                  AllowedRulesType);

  static ParseSheetResult ParseStyleSheet(
      const std::string&,
      std::shared_ptr<const CSSParserContext>,
      std::shared_ptr<StyleSheetContents>,
      CSSDeferPropertyParsing = CSSDeferPropertyParsing::kNo,
      bool allow_import_rules = true);

  std::shared_ptr<StyleRuleBase> ConsumeAtRule(CSSParserTokenStream&,
                               AllowedRulesType,
                               CSSNestingType,
                               std::shared_ptr<StyleRule> parent_rule_for_nesting);
  std::shared_ptr<StyleRuleBase> ConsumeAtRuleContents(CSSAtRuleID id,
                                       CSSParserTokenStream& stream,
                                       AllowedRulesType allowed_rules,
                                       CSSNestingType,
                                       std::shared_ptr<StyleRule> parent_rule_for_nesting);
  std::shared_ptr<StyleRuleBase> ConsumeQualifiedRule(CSSParserTokenStream&,
                                      AllowedRulesType,
                                      CSSNestingType,
                                      std::shared_ptr<StyleRule> parent_rule_for_nesting);
  std::shared_ptr<StyleRuleKeyframe> ConsumeKeyframeStyleRule(CSSParserTokenRange prelude,
                                              const RangeOffset& prelude_offset,
                                              CSSParserTokenStream& block);
  std::shared_ptr<StyleRule> ConsumeStyleRule(CSSParserTokenStream&,
                              CSSNestingType,
                              std::shared_ptr<StyleRule> parent_rule_for_nesting,
                              bool semicolon_aborts_nested_selector);
  std::shared_ptr<StyleRule> ConsumeStyleRuleContents(std::span<CSSSelector> selector_vector,
                                      CSSParserTokenStream& stream);
  void ConsumeErroneousAtRule(CSSParserTokenStream& stream, CSSAtRuleID id);
  std::shared_ptr<const CSSParserContext> GetContext() const { return context_; }


 private:
  enum RuleListType {
    kTopLevelRuleList,
    kRegularRuleList,
    kKeyframesRuleList,
    kFontFeatureRuleList,
  };

  template <typename T>
  bool ConsumeRuleList(CSSParserTokenStream&,
                       RuleListType,
                       CSSNestingType,
                       std::shared_ptr<StyleRule> parent_rule_for_nesting,
                       T callback);

  std::shared_ptr<CSSLazyParsingState> lazy_state_;
  std::shared_ptr<StyleSheetContents> style_sheet_;
  std::shared_ptr<const CSSParserContext> context_;
  // For the inspector
  std::shared_ptr<CSSParserObserver> observer_;
  std::vector<CSSPropertyValue> parsed_properties_;

  // Used for temporary allocations of CSSParserSelector (we send it down
  // to CSSSelectorParser, which temporarily holds on to a reference to it).
  std::vector<CSSSelector> arena_;

  // True when parsing a StyleRule via ConsumeNestedRule.
  bool in_nested_style_rule_ = false;

  // True if we're within the body of an @scope rule. While this is true,
  // any selectors parsed will gain kScopeActivations as needed.
  bool is_within_scope_ = false;

};

}  // namespace webf

#endif  // WEBF_CSS_PARSER_IMPL_H
