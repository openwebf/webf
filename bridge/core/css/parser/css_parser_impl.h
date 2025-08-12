// Copyright 2014 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef WEBF_CSS_PARSER_IMPL_H
#define WEBF_CSS_PARSER_IMPL_H

#include <span>
#include <vector>

#include "core/css/parser/css_at_rule_id.h"
#include "core/css/parser/allowed_rules.h"
#include "core/css/parser/css_tokenized_value.h"
#include "core/css/style_rule_keyframe.h"
#include "css_nesting_type.h"
#include "css_parser_mode.h"
#include "foundation/macros.h"
#include "foundation/string/wtf_string.h"

namespace webf {

class CSSParserContext;
class StyleSheetContents;
class CSSLazyParsingState;
class CSSParserTokenStream;
class CSSParserObserver;
class CSSSelector;
class CSSParserTokenRange;
class StyleRule;
class StyleRuleKeyframes;
class StyleRuleCounterStyle;
class CSSParserObserver;
class StyleRuleImport;
class StyleRuleBase;
class StyleRuleKeyframe;
class CSSPropertyValue;  // TODO(xiezuobing)

enum class ParseSheetResult {
  kSucceeded,
  kHasUnallowedImportRule,
};

class CSSParserImpl {
  WEBF_STACK_ALLOCATED();

 public:
  explicit CSSParserImpl(std::shared_ptr<const CSSParserContext>, std::shared_ptr<StyleSheetContents> = nullptr);
  CSSParserImpl(const CSSParserImpl&) = delete;
  CSSParserImpl& operator=(const CSSParserImpl&) = delete;

  // Regular rules are rules that are valid within a top-level grouping rule,
  // like @media, @supports, etc.
  static constexpr AllowedRules kRegularRules =
      AllowedRules{QualifiedRuleType::kStyle} |
      AllowedRules{
          CSSAtRuleID::kCSSAtRuleFontFace,
          CSSAtRuleID::kCSSAtRuleFontPaletteValues,
          CSSAtRuleID::kCSSAtRuleKeyframes,
          CSSAtRuleID::kCSSAtRuleLayer,
          CSSAtRuleID::kCSSAtRuleMedia,
          CSSAtRuleID::kCSSAtRulePage,
          CSSAtRuleID::kCSSAtRulePositionTry,
          CSSAtRuleID::kCSSAtRuleProperty,
          CSSAtRuleID::kCSSAtRuleContainer,
          CSSAtRuleID::kCSSAtRuleCounterStyle,
          CSSAtRuleID::kCSSAtRuleScope,
          CSSAtRuleID::kCSSAtRuleStartingStyle,
          CSSAtRuleID::kCSSAtRuleSupports,
          CSSAtRuleID::kCSSAtRuleWebkitKeyframes,
          CSSAtRuleID::kCSSAtRuleFontFeatureValues,
      };

  // A few rules are only valid top-level. For example, you may not specify
  // an @import rule within @media.
  static constexpr AllowedRules kTopLevelRules =
      kRegularRules | AllowedRules{
                          CSSAtRuleID::kCSSAtRuleCharset,
                          CSSAtRuleID::kCSSAtRuleImport,
                          CSSAtRuleID::kCSSAtRuleNamespace,
                      };

  // Valid rules within @keyframes.
  static constexpr AllowedRules kKeyframeRules = {QualifiedRuleType::kKeyframe};

  // Valid rules within @font-feature-values.
  static constexpr AllowedRules kFontFeatureRules = {
      CSSAtRuleID::kCSSAtRuleAnnotation,
      CSSAtRuleID::kCSSAtRuleCharacterVariant,
      CSSAtRuleID::kCSSAtRuleOrnaments,
      CSSAtRuleID::kCSSAtRuleStylistic,
      CSSAtRuleID::kCSSAtRuleStyleset,
      CSSAtRuleID::kCSSAtRuleSwash,
  };

  // Valid rules within @page.
  static constexpr AllowedRules kPageMarginRules = {
      CSSAtRuleID::kCSSAtRuleTopLeftCorner,
      CSSAtRuleID::kCSSAtRuleTopLeft,
      CSSAtRuleID::kCSSAtRuleTopCenter,
      CSSAtRuleID::kCSSAtRuleTopRight,
      CSSAtRuleID::kCSSAtRuleTopRightCorner,
      CSSAtRuleID::kCSSAtRuleBottomLeftCorner,
      CSSAtRuleID::kCSSAtRuleBottomLeft,
      CSSAtRuleID::kCSSAtRuleBottomCenter,
      CSSAtRuleID::kCSSAtRuleBottomRight,
      CSSAtRuleID::kCSSAtRuleBottomRightCorner,
      CSSAtRuleID::kCSSAtRuleLeftTop,
      CSSAtRuleID::kCSSAtRuleLeftMiddle,
      CSSAtRuleID::kCSSAtRuleLeftBottom,
      CSSAtRuleID::kCSSAtRuleRightTop,
      CSSAtRuleID::kCSSAtRuleRightMiddle,
      CSSAtRuleID::kCSSAtRuleRightBottom,
  };

  // No rules allowed.
  static constexpr AllowedRules kNoRules = {};

  // https://drafts.csswg.org/css-nesting/#nested-group-rules
  static constexpr AllowedRules kNestedGroupRules =
      AllowedRules{
          CSSAtRuleID::kCSSAtRuleMedia,
          CSSAtRuleID::kCSSAtRuleSupports,
          CSSAtRuleID::kCSSAtRuleContainer,
          CSSAtRuleID::kCSSAtRuleLayer,
          CSSAtRuleID::kCSSAtRuleScope,
          CSSAtRuleID::kCSSAtRuleStartingStyle,
      };

  // Alias for kTopLevelRules to match css_parser.cc usage
  static constexpr AllowedRules kAllowImportRules = kTopLevelRules;
  
  // Convenience constants for other rule types
  static constexpr AllowedRules kLayerRules = kRegularRules;
  static constexpr AllowedRules kPageRules = kRegularRules;
  static constexpr AllowedRules kStyleRules = {QualifiedRuleType::kStyle};
  static constexpr AllowedRules kAllRules = kTopLevelRules;

  // Legacy enum for backward compatibility - will be removed in future
  enum AllowedRulesType {
    kAllowCharsetRules,
    kAllowLayerStatementRules,
    kAllowImportRulesType,  // Renamed to avoid conflict with static constant
    kAllowNamespaceRules,
    kRegularRulesType,      // Renamed to avoid conflict
    kKeyframeRulesType,     // Renamed to avoid conflict
    kFontFeatureRulesType,  // Renamed to avoid conflict
    kNoRulesType,           // Renamed to avoid conflict
    kNestedGroupRulesType,  // Renamed to avoid conflict
    kPageMarginRulesType,   // Renamed to avoid conflict
    kLayerRulesType,        // Added for layer rules
    kPageRulesType,         // Added for page rules
    kStyleRulesType,        // Added for style rules
  };

  // Helper function to convert legacy enum to new AllowedRules
  static AllowedRules ConvertToAllowedRules(AllowedRulesType legacy_type);

  // Represents the start and end offsets of a CSSParserTokenRange.
  struct RangeOffset {
    uint32_t start, end;

    RangeOffset(uint32_t start, uint32_t end) : start(start), end(end) { assert(start <= end); }

    // Used when we don't care what the offset is (typically when we don't have
    // an observer).
    static RangeOffset Ignore() { return {0, 0}; }
  };

  static MutableCSSPropertyValueSet::SetResult ParseValue(MutableCSSPropertyValueSet*,
                                                          CSSPropertyID,
                                                          const String&,
                                                          bool important,
                                                          std::shared_ptr<const CSSParserContext>);
  static MutableCSSPropertyValueSet::SetResult ParseVariableValue(MutableCSSPropertyValueSet*,
                                                                  const String& property_name,
                                                                  const String&,
                                                                  bool important,
                                                                  std::shared_ptr<const CSSParserContext>,
                                                                  bool is_animation_tainted);

  // A value for a standard property has the following restriction:
  // it can not contain braces unless it's the whole value [1].
  // This function makes use of that restriction to early-out of the
  // streaming tokenizer as soon as possible.
  //
  // [1] https://github.com/w3c/csswg-drafts/issues/9317
  static CSSTokenizedValue ConsumeRestrictedPropertyValue(CSSParserTokenStream&);

  // NOTE: This function can currently only be used to parse a
  // declaration list with no nested rules, not a full style rule
  // (it is only used for things like inline style).
  static bool ParseDeclarationList(MutableCSSPropertyValueSet*,
                                   const String&,
                                   std::shared_ptr<const CSSParserContext>);
  static std::shared_ptr<StyleRuleBase> ParseRule(const String&,
                                                  std::shared_ptr<const CSSParserContext>,
                                                  CSSNestingType,
                                                  std::shared_ptr<StyleRule> parent_rule_for_nesting,
                                                  std::shared_ptr<StyleSheetContents>,
                                                  AllowedRulesType);
  
  // New overload using AllowedRules
  static std::shared_ptr<StyleRuleBase> ParseRule(const String&,
                                                  std::shared_ptr<const CSSParserContext>,
                                                  CSSNestingType,
                                                  std::shared_ptr<StyleRule> parent_rule_for_nesting,
                                                  std::shared_ptr<StyleSheetContents>,
                                                  AllowedRules);

  static ParseSheetResult ParseStyleSheet(const String&,
                                          const std::shared_ptr<const CSSParserContext>&,
                                          const std::shared_ptr<StyleSheetContents>&,
                                          CSSDeferPropertyParsing = CSSDeferPropertyParsing::kNo,
                                          bool allow_import_rules = true);

  static std::shared_ptr<const CSSSelectorList> ParsePageSelector(CSSParserTokenRange,
                                                                  std::shared_ptr<StyleSheetContents>,
                                                                  std::shared_ptr<const CSSParserContext> context);
  static std::shared_ptr<const CSSSelectorList> ParsePageSelector(CSSParserTokenStream&,
                                                                  std::shared_ptr<StyleSheetContents>,
                                                                  std::shared_ptr<const CSSParserContext> context);

  static std::unique_ptr<std::vector<KeyframeOffset>> ParseKeyframeKeyList(std::shared_ptr<const CSSParserContext>,
                                                                           const String&);

  static std::shared_ptr<CSSPropertyValueSet> ParseDeclarationListForLazyStyle(const String&,
                                                                               size_t offset,
                                                                               std::shared_ptr<const CSSParserContext>);

  std::shared_ptr<StyleRuleBase> ConsumeAtRule(CSSParserTokenStream&,
                                               AllowedRulesType,
                                               CSSNestingType,
                                               std::shared_ptr<const StyleRule> parent_rule_for_nesting);
  std::shared_ptr<StyleRuleBase> ConsumeAtRuleContents(CSSAtRuleID id,
                                                       CSSParserTokenStream& stream,
                                                       AllowedRulesType allowed_rules,
                                                       CSSNestingType,
                                                       std::shared_ptr<const StyleRule> parent_rule_for_nesting);
  std::shared_ptr<StyleRuleBase> ConsumeLayerRule(CSSParserTokenStream&,
                                                  CSSNestingType,
                                                  std::shared_ptr<const StyleRule> parent_rule_for_nesting);
  std::shared_ptr<StyleRuleBase> ConsumeQualifiedRule(CSSParserTokenStream&,
                                                      AllowedRulesType,
                                                      CSSNestingType,
                                                      std::shared_ptr<const StyleRule> parent_rule_for_nesting);
  std::shared_ptr<StyleRuleKeyframe> ConsumeKeyframeStyleRule(CSSParserTokenRange prelude,
                                                              const RangeOffset& prelude_offset,
                                                              CSSParserTokenStream& block);
  std::shared_ptr<StyleRule> ConsumeStyleRule(CSSParserTokenStream&,
                                              CSSNestingType,
                                              std::shared_ptr<const StyleRule> parent_rule_for_nesting,
                                              bool semicolon_aborts_nested_selector);

  std::shared_ptr<StyleRuleImport> ConsumeImportRule(const String& prelude_uri, CSSParserTokenStream&);
  std::shared_ptr<StyleRuleMedia> ConsumeMediaRule(CSSParserTokenStream& stream,
                                                   CSSNestingType,
                                                   std::shared_ptr<const StyleRule> parent_rule_for_nesting);
  std::shared_ptr<StyleRuleKeyframes> ConsumeKeyframesRule(bool webkit_prefixed, CSSParserTokenStream&);
  std::shared_ptr<StyleRuleFontFace> ConsumeFontFaceRule(CSSParserTokenStream&);
  std::shared_ptr<StyleRuleCounterStyle> ConsumeCounterStyleRule(CSSParserTokenStream&);
  // Finds a previously parsed MediaQuerySet for the given `prelude_string`
  // and returns it. If no MediaQuerySet is found, parses one using `prelude`,
  // and returns the result after caching it.
  std::shared_ptr<const MediaQuerySet> CachedMediaQuerySet(const String& prelude_string,
                                                           CSSParserTokenRange prelude,
                                                           const CSSParserTokenOffsets& offsets);

  // Create an implicit & {} rule to wrap properties in, and insert every
  // property from parsed_properties_ in it. Used when there are properties
  // directly in @media, @supports or similar (which cannot hold properties
  // by themselves, only rules; see
  // https://github.com/w3c/csswg-drafts/issues/7850).
  //
  // If CSSNestingType::kScope is provided, an implicit :scope {} rule
  // is created instead.
  //
  // The rule will carry the specified `signal`.
  std::shared_ptr<StyleRule> CreateImplicitNestedRule(CSSNestingType,
                                                      std::shared_ptr<const StyleRule> parent_rule_for_nesting,
                                                      CSSSelector::Signal signal);

  static std::shared_ptr<StyleRuleCharset> ConsumeCharsetRule(CSSParserTokenStream&);
  void ConsumeErroneousAtRule(CSSParserTokenStream& stream, CSSAtRuleID id);
  [[nodiscard]] std::shared_ptr<const CSSParserContext> GetContext() const { return context_; }

  static std::unique_ptr<std::vector<KeyframeOffset>> ConsumeKeyframeKeyList(std::shared_ptr<const CSSParserContext>,
                                                                             CSSParserTokenStream&);

  static String ParseCustomPropertyName(const String& name_text);

  static void ParseStyleSheetForInspector(const String&,
                                          std::shared_ptr<const CSSParserContext>,
                                          std::shared_ptr<StyleSheetContents>,
                                          CSSParserObserver&);
  static void ParseDeclarationListForInspector(const String&,
                                               std::shared_ptr<const CSSParserContext>,
                                               CSSParserObserver&);

  void ConsumeRuleListOrNestedDeclarationList(CSSParserTokenStream&,
                                              bool is_nested_group_rule,
                                              CSSNestingType,
                                              std::shared_ptr<const StyleRule> parent_rule_for_nesting,
                                              std::vector<std::shared_ptr<StyleRuleBase>>* child_rules);

  void ConsumeDeclarationList(CSSParserTokenStream&,
                              StyleRule::RuleType,
                              CSSNestingType,
                              std::shared_ptr<const StyleRule> parent_rule_for_nesting,
                              std::vector<std::shared_ptr<StyleRuleBase>>* child_rules);

  // Consumes tokens from the stream using the provided function, and wraps
  // the result in a CSSTokenizedValue.
  template <typename ConsumeFunction>
  static CSSTokenizedValue ConsumeValue(CSSParserTokenStream&, ConsumeFunction);

  bool ConsumeSupportsDeclaration(CSSParserTokenStream&);

  // If id is std::nullopt, we're parsing a qualified style rule;
  // otherwise, we're parsing an at-rule.
  std::shared_ptr<StyleRuleBase> ConsumeNestedRule(std::optional<CSSAtRuleID> id,
                                                   StyleRule::RuleType parent_rule_type,
                                                   CSSParserTokenStream& stream,
                                                   CSSNestingType,
                                                   std::shared_ptr<const StyleRule> parent_rule_for_nesting);

  std::shared_ptr<StyleRule> ConsumeStyleRuleContents(tcb::span<CSSSelector> selector_vector,
                                                      CSSParserTokenStream& stream);

  static std::shared_ptr<const ImmutableCSSPropertyValueSet> ParseInlineStyleDeclaration(const String&, Element*);
  static std::shared_ptr<const ImmutableCSSPropertyValueSet> ParseInlineStyleDeclaration(const String&,
                                                                                         CSSParserMode,
                                                                                         const Document*);
  // Creates an invisible rule containing the declarations
  // in parsed_properties_ within the range [start_index,end_index).
  //
  // The resulting rule will carry the specified signal, which may be kNone.
  //
  // See also CSSSelector::IsInvisible.
  std::shared_ptr<StyleRule> CreateInvisibleRule(const CSSSelector* selector_list,
                                                 size_t start_index,
                                                 size_t end_index,
                                                 CSSSelector::Signal);

  // Adds the result of `CreateInvisibleRule` into `child_rules`,
  // provided that we have any declarations to add.
  void EmitInvisibleRuleIfNeeded(std::shared_ptr<const StyleRule> parent_rule_for_nesting,
                                 size_t start_index,
                                 CSSSelector::Signal,
                                 std::vector<std::shared_ptr<StyleRuleBase>>* child_rules);

  // Returns true if a declaration was parsed and added to parsed_properties_,
  // and false otherwise.
  bool ConsumeDeclaration(CSSParserTokenStream&, StyleRule::RuleType);

  // Custom properties (as well as descriptors) do not have the restriction
  // explained above. This function will simply consume until AtEnd.
  static CSSTokenizedValue ConsumeUnrestrictedPropertyValue(CSSParserTokenStream&);

  bool ConsumeVariableValue(CSSParserTokenStream& stream,
                            const AtomicString& property_name,
                            bool allow_important_annotation,
                            bool is_animation_tainted);

  void ConsumeDeclarationValue(CSSParserTokenStream&, CSSPropertyID, bool is_in_declaration_list, StyleRule::RuleType);

  // FIXME: This setter shouldn't exist, however the current lifetime of
  // CSSParserContext is not well understood and thus we sometimes need to
  // override this field.
  void SetMode(CSSParserMode mode) { mode_ = mode; }
  CSSParserMode GetMode() const { return mode_; }

  static bool RemoveImportantAnnotationIfPresent(CSSTokenizedValue&);

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
                       const std::shared_ptr<const StyleRule>& parent_rule_for_nesting,
                       T callback);

  std::shared_ptr<CSSLazyParsingState> lazy_state_;
  std::shared_ptr<StyleSheetContents> style_sheet_;
  std::shared_ptr<const CSSParserContext> context_;
  std::vector<CSSPropertyValue> parsed_properties_;

  // Used for temporary allocations of CSSParserSelector (we send it down
  // to CSSSelectorParser, which temporarily holds on to a reference to it).
  std::vector<CSSSelector> arena_;

  CSSParserMode mode_;

  // True when parsing a StyleRule via ConsumeNestedRule.
  bool in_nested_style_rule_ = false;

  // True if we're within the body of an @scope rule. While this is true,
  // any selectors parsed will gain kScopeActivations as needed.
  bool is_within_scope_ = false;

  CSSParserObserver* observer_{nullptr};
  std::unordered_map<String, std::shared_ptr<const MediaQuerySet>> media_query_cache_;
};

}  // namespace webf

#endif  // WEBF_CSS_PARSER_IMPL_H
