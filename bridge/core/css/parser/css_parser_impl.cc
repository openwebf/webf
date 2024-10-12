// Copyright 2014 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "css_parser_impl.h"

#include <cassert>
#include <vector>
#include "core/base/memory/shared_ptr.h"
#include "at_rule_descriptors.h"
#include "core/base/auto_reset.h"
#include "core/base/strings/string_util.h"
#include "core/css/css_at_rule_id.h"
#include "core/css/css_property_value.h"
#include "core/css/css_selector.h"
#include "core/css/css_style_sheet.h"
#include "core/css/css_unparsed_declaration_value.h"
#include "core/css/css_value_list.h"
#include "core/css/parser/at_rule_descriptor_parser.h"
#include "core/css/properties/css_parsing_utils.h"
#include "core/css/style_rule.h"
#include "core/css/style_rule_import.h"
#include "core/css/style_rule_keyframe.h"
#include "core/css/style_sheet_contents.h"
#include "core/platform/text/text_position.h"
#include "css_lazy_parsing_state.h"
#include "css_lazy_property_parser_impl.h"
#include "css_parser_context.h"
#include "css_parser_token_range.h"
#include "css_parser_token_stream.h"
#include "css_selector_parser.h"
#include "css_tokenizer.h"
#include "css_variable_parser.h"
#include "find_length_of_declaration_list-inl.h"
#include "css_value_id_mappings_generated.h"
#include "foundation/casting.h"

namespace webf {

namespace {

// This may still consume tokens if it fails
std::string ConsumeStringOrURI(CSSParserTokenStream& stream) {
  const CSSParserToken& token = stream.Peek();

  if (token.GetType() == kStringToken || token.GetType() == kUrlToken) {
    return std::string(stream.ConsumeIncludingWhitespace().Value());
  }

  if (token.GetType() != kFunctionToken || !EqualIgnoringASCIICase(token.Value(), "url")) {
    return "";
  }

  std::string result;
  {
    CSSParserTokenStream::BlockGuard guard(stream);
    const CSSParserToken& uri = stream.ConsumeIncludingWhitespace();
    if (uri.GetType() != kBadStringToken && stream.UncheckedAtEnd()) {
      assert(uri.GetType() == kStringToken);
      result = uri.Value();
    }
  }
  stream.ConsumeWhitespace();
  return result;
}
}  // namespace

CSSParserImpl::CSSParserImpl(std::shared_ptr<const CSSParserContext> context,
                             std::shared_ptr<StyleSheetContents> style_sheet)
    : context_(std::move(context)), style_sheet_(std::move(style_sheet)), lazy_state_(nullptr) {}

StyleRule::RuleType RuleTypeForMutableDeclaration(MutableCSSPropertyValueSet* declaration) {
  switch (declaration->CssParserMode()) {
    case kCSSFontFaceRuleMode:
      return StyleRule::kFontFace;
    case kCSSKeyframeRuleMode:
      return StyleRule::kKeyframe;
    case kCSSPropertyRuleMode:
      return StyleRule::kProperty;
    case kCSSFontPaletteValuesRuleMode:
      return StyleRule::kFontPaletteValues;
    case kCSSPositionTryRuleMode:
      return StyleRule::kPositionTry;
    default:
      return StyleRule::kStyle;
  }
}

MutableCSSPropertyValueSet::SetResult CSSParserImpl::ParseValue(MutableCSSPropertyValueSet* declaration,
                                                                CSSPropertyID unresolved_property,
                                                                const std::string& string,
                                                                bool important,
                                                                std::shared_ptr<const CSSParserContext> context) {
  STACK_UNINITIALIZED CSSParserImpl parser(context);
  StyleRule::RuleType rule_type = RuleTypeForMutableDeclaration(declaration);
  CSSTokenizer tokenizer(string);
  CSSParserTokenStream stream(tokenizer);
  parser.ConsumeDeclarationValue(stream, unresolved_property,
                                 /*is_in_declaration_list=*/false, rule_type);
  if (parser.parsed_properties_.empty()) {
    return MutableCSSPropertyValueSet::kParseError;
  }
  if (important) {
    for (CSSPropertyValue& property : parser.parsed_properties_) {
      property.SetImportant();
    }
  }
  return declaration->AddParsedProperties(parser.parsed_properties_);
}

MutableCSSPropertyValueSet::SetResult CSSParserImpl::ParseVariableValue(MutableCSSPropertyValueSet* declaration,
                                                                        const std::string& property_name,
                                                                        const std::string& value,
                                                                        bool important,
                                                                        std::shared_ptr<const CSSParserContext> context,
                                                                        bool is_animation_tainted) {
  STACK_UNINITIALIZED CSSParserImpl parser(context);
  CSSTokenizer tokenizer(value);
  CSSParserTokenStream stream(tokenizer);
  if (!parser.ConsumeVariableValue(stream, property_name,
                                   /*allow_important_annotation=*/false, is_animation_tainted)) {
    return MutableCSSPropertyValueSet::kParseError;
  }
  if (important) {
    parser.parsed_properties_.back().SetImportant();
  }
  return declaration->AddParsedProperties(parser.parsed_properties_);
}


CSSTokenizedValue CSSParserImpl::ConsumeRestrictedPropertyValue(
    CSSParserTokenStream& stream) {
  if (stream.Peek().GetType() == kLeftBraceToken) {
    // '{}' must be the whole value, hence we simply consume a component
    // value from the stream, and consider this the whole value.
    return ConsumeValue(stream, [](CSSParserTokenStream& stream) {
      return stream.ConsumeComponentValueIncludingWhitespace();
    });
  }
  // Otherwise, we consume until we're AtEnd() (which in the normal case
  // means we hit a kSemicolonToken), or until we see kLeftBraceToken.
  // The latter is a kind of error state, which is dealt with via additional
  // AtEnd() checks at the call site.
  return ConsumeValue(stream, [](CSSParserTokenStream& stream) {
    return stream.ConsumeUntilPeekedTypeIs<kLeftBraceToken>();
  });
}

static inline void FilterProperties(bool important,
                                    const std::vector<CSSPropertyValue>& input,
                                    std::vector<CSSPropertyValue>& output,
                                    size_t& unused_entries,
                                    std::bitset<kNumCSSProperties>& seen_properties,
                                    std::unordered_set<std::string>& seen_custom_properties) {
  // Add properties in reverse order so that highest priority definitions are
  // reached first. Duplicate definitions can then be ignored when found.
  for (size_t i = input.size(); i--;) {
    const CSSPropertyValue& property = input[i];
    if (property.IsImportant() != important) {
      continue;
    }
    if (property.Id() == CSSPropertyID::kVariable) {
      const std::string& name = property.CustomPropertyName();
      if (seen_custom_properties.count(name) > 0) {
        continue;
      }
      seen_custom_properties.insert(name);
    } else {
      const unsigned property_id_index = GetCSSPropertyIDIndex(property.Id());
      if (seen_properties.test(property_id_index)) {
        continue;
      }
      seen_properties.set(property_id_index);
    }
    output[--unused_entries] = property;
  }
}

bool CSSParserImpl::ParseDeclarationList(MutableCSSPropertyValueSet* declaration,
                                         const std::string& string,
                                         std::shared_ptr<const CSSParserContext> context) {
  CSSParserImpl parser(context);
  StyleRule::RuleType rule_type = RuleTypeForMutableDeclaration(declaration);
  CSSTokenizer tokenizer(string);
  CSSParserTokenStream stream(tokenizer);
  // See function declaration comment for why parent_rule_for_nesting ==
  // nullptr.
  parser.ConsumeDeclarationList(stream, rule_type, CSSNestingType::kNone,
                                /*parent_rule_for_nesting=*/nullptr,
                                /*child_rules=*/nullptr);
  if (parser.parsed_properties_.empty()) {
    return false;
  }

  std::bitset<kNumCSSProperties> seen_properties;
  size_t unused_entries = parser.parsed_properties_.size();
  std::vector<CSSPropertyValue> results;
  results.reserve(64);
  std::unordered_set<std::string> seen_custom_properties;
  FilterProperties(true, parser.parsed_properties_, results, unused_entries, seen_properties, seen_custom_properties);
  FilterProperties(false, parser.parsed_properties_, results, unused_entries, seen_properties, seen_custom_properties);
  if (unused_entries) {
    results.erase(results.begin(), results.begin() + unused_entries);
  }
  return declaration->AddParsedProperties(results);
}

std::shared_ptr<StyleRuleBase> CSSParserImpl::ParseRule(const std::string& string,
                                                        std::shared_ptr<const CSSParserContext> context,
                                                        CSSNestingType nesting_type,
                                                        std::shared_ptr<StyleRule> parent_rule_for_nesting,
                                                        std::shared_ptr<StyleSheetContents> style_sheet,
                                                        AllowedRulesType allowed_rules) {
  CSSParserImpl parser(context, style_sheet);
  CSSTokenizer tokenizer(string);
  CSSParserTokenStream stream(tokenizer);
  stream.ConsumeWhitespace();
  if (stream.UncheckedAtEnd()) {
    return nullptr;  // Parse error, empty rule
  }
  std::shared_ptr<StyleRuleBase> rule;
  if (stream.UncheckedPeek().GetType() == kAtKeywordToken) {
    rule = parser.ConsumeAtRule(stream, allowed_rules, CSSNestingType::kNone,
                                /*parent_rule_for_nesting=*/nullptr);
  } else if (allowed_rules == kPageMarginRules) {
    // Style rules are not allowed inside @page.
    rule = nullptr;
  } else {
    rule = parser.ConsumeQualifiedRule(stream, allowed_rules, nesting_type, parent_rule_for_nesting);
  }
  if (!rule) {
    return nullptr;  // Parse error, failed to consume rule
  }
  stream.ConsumeWhitespace();
  if (!rule || !stream.UncheckedAtEnd()) {
    return nullptr;  // Parse error, trailing garbage
  }
  return rule;
}

ParseSheetResult CSSParserImpl::ParseStyleSheet(const std::string& string,
                                                const std::shared_ptr<const CSSParserContext>& context,
                                                const std::shared_ptr<StyleSheetContents>& style_sheet,
                                                CSSDeferPropertyParsing defer_property_parsing,
                                                bool allow_import_rules) {
  CSSTokenizer tokenizer(string);
  CSSParserTokenStream stream(tokenizer);
  CSSParserImpl parser(context, style_sheet);
  if (defer_property_parsing == CSSDeferPropertyParsing::kYes) {
    parser.lazy_state_ = std::make_shared<CSSLazyParsingState>(context, string, parser.style_sheet_);
  }
  ParseSheetResult result = ParseSheetResult::kSucceeded;
  auto consume_rule_list_callback = [&style_sheet, &result, &string, allow_import_rules, context](
                                        const std::shared_ptr<StyleRuleBase>& rule, size_t offset) {
    if (rule->IsCharsetRule()) {
      return;
    }
    if (rule->IsImportRule()) {
      if (!allow_import_rules || context->IsForMarkupSanitization()) {
        result = ParseSheetResult::kHasUnallowedImportRule;
        return;
      }

      Document* document = style_sheet->AnyOwnerDocument();
      if (document) {
        TextPosition position = TextPosition::MinimumPosition();
        To<StyleRuleImport>(rule.get())->SetPositionHint(position);
      }
    }

    style_sheet->ParserAppendRule(rule);
  };
  bool first_rule_valid = parser.ConsumeRuleList(stream, kTopLevelRuleList, CSSNestingType::kNone,
                                                 /*parent_rule_for_nesting=*/nullptr, consume_rule_list_callback);
  style_sheet->SetHasSyntacticallyValidCSSHeader(first_rule_valid);

  return result;
}

std::shared_ptr<const CSSSelectorList> CSSParserImpl::ParsePageSelector(
    CSSParserTokenRange range,
    std::shared_ptr<StyleSheetContents> style_sheet,
    std::shared_ptr<const CSSParserContext> context) {
  // We only support a small subset of the css-page spec.
  range.ConsumeWhitespace();
  std::string type_selector;
  if (range.Peek().GetType() == kIdentToken) {
    type_selector = range.Consume().Value();
  }

  std::string pseudo;
  if (range.Peek().GetType() == kColonToken) {
    range.Consume();
    if (range.Peek().GetType() != kIdentToken) {
      return nullptr;
    }
    pseudo = range.Consume().Value();
  }

  range.ConsumeWhitespace();
  if (!range.AtEnd()) {
    return nullptr;  // Parse error; extra tokens in @page selector
  }

  std::vector<CSSSelector> selectors;
  if (!type_selector.empty()) {
    selectors.push_back(CSSSelector(
        QualifiedName("", type_selector, "*")));
  }
  if (!pseudo.empty()) {
    CSSSelector selector;
    selector.SetMatch(CSSSelector::kPagePseudoClass);
    selector.UpdatePseudoPage(base::ToLowerASCII(pseudo), context->GetDocument());
    if (selector.GetPseudoType() == CSSSelector::kPseudoUnknown) {
      return nullptr;
    }
    if (!selectors.empty()) {
      selectors[0].SetLastInComplexSelector(false);
    }
    selectors.push_back(selector);
  }
  if (selectors.empty()) {
    selectors.emplace_back(CSSSelector());
  }
  selectors[0].SetForPage();
  selectors.back().SetLastInComplexSelector(true);
  return CSSSelectorList::AdoptSelectorVector(tcb::span<CSSSelector>(selectors));
}

std::unique_ptr<std::vector<KeyframeOffset>> CSSParserImpl::ParseKeyframeKeyList(
    std::shared_ptr<const CSSParserContext> context,
    const std::string& key_list) {
  CSSTokenizer tokenizer(key_list);
  return ConsumeKeyframeKeyList(context, CSSParserTokenRange(tokenizer.TokenizeToEOF()));
}

static CSSParserImpl::AllowedRulesType ComputeNewAllowedRules(CSSParserImpl::AllowedRulesType allowed_rules,
                                                              std::shared_ptr<StyleRuleBase> rule) {
  if (!rule || allowed_rules == CSSParserImpl::kKeyframeRules || allowed_rules == CSSParserImpl::kFontFeatureRules ||
      allowed_rules == CSSParserImpl::kNoRules) {
    return allowed_rules;
  }
  assert(allowed_rules <= CSSParserImpl::kRegularRules);
  if (rule->IsCharsetRule()) {
    return CSSParserImpl::kAllowLayerStatementRules;
  }
  if (rule->IsLayerStatementRule()) {
    if (allowed_rules <= CSSParserImpl::kAllowLayerStatementRules) {
      return CSSParserImpl::kAllowLayerStatementRules;
    }
    return CSSParserImpl::kRegularRules;
  }
  if (rule->IsImportRule()) {
    return CSSParserImpl::kAllowImportRules;
  }
  if (rule->IsNamespaceRule()) {
    return CSSParserImpl::kAllowNamespaceRules;
  }
  return CSSParserImpl::kRegularRules;
}

// TODO:当前进度[ConsumeQualifiedRule]
template <typename T>
bool CSSParserImpl::ConsumeRuleList(CSSParserTokenStream& stream,
                                    RuleListType rule_list_type,
                                    CSSNestingType nesting_type,
                                    const std::shared_ptr<const StyleRule>& parent_rule_for_nesting,
                                    const T callback) {
  AllowedRulesType allowed_rules = kRegularRules;
  switch (rule_list_type) {
    case kTopLevelRuleList:
      allowed_rules = kAllowCharsetRules;
      break;
    case kRegularRuleList:
      allowed_rules = kRegularRules;
      break;
    case kKeyframesRuleList:
      allowed_rules = kKeyframeRules;
      break;
    case kFontFeatureRuleList:
      allowed_rules = kFontFeatureRules;
      break;
    default:
      assert_m(false, "NOT REACHD IN MARGATION.");
      //      NOTREACHED_IN_MIGRATION();
  }

  bool seen_rule = false;
  bool first_rule_valid = false;
  while (!stream.AtEnd()) {
    uint32_t offset = stream.Offset();
    std::shared_ptr<StyleRuleBase> rule = nullptr;
    switch (stream.UncheckedPeek().GetType()) {
      case kWhitespaceToken:
        stream.UncheckedConsume();
        continue;
      case kAtKeywordToken:
        rule = ConsumeAtRule(stream, allowed_rules, nesting_type, parent_rule_for_nesting);
        break;
      // NOTE: <!--
      case kCDOToken:
      // NOTE: -->
      case kCDCToken:
        if (rule_list_type == kTopLevelRuleList) {
          stream.UncheckedConsume();
          continue;
        }
        [[fallthrough]];
      default:
        rule = ConsumeQualifiedRule(stream, allowed_rules, nesting_type, parent_rule_for_nesting);
        break;
    }
    if (!seen_rule) {
      seen_rule = true;
      first_rule_valid = (rule != nullptr);
    }
    if (rule) {
      allowed_rules = ComputeNewAllowedRules(allowed_rules, rule);
      callback(rule, offset);
    }
    assert(stream.Offset() > offset);
  }

  return first_rule_valid;
}

std::shared_ptr<StyleRuleBase> CSSParserImpl::ConsumeQualifiedRule(
    CSSParserTokenStream& stream,
    AllowedRulesType allowed_rules,
    CSSNestingType nesting_type,
    std::shared_ptr<const StyleRule> parent_rule_for_nesting) {
  if (allowed_rules <= kRegularRules) {
    return ConsumeStyleRule(stream, nesting_type, std::move(parent_rule_for_nesting),
                            /* semicolon_aborts_nested_selector */ false);
  }

  if (allowed_rules == kKeyframeRules) {
    stream.EnsureLookAhead();
    const uint32_t prelude_offset_start = stream.LookAheadOffset();
    const CSSParserTokenRange prelude = stream.ConsumeUntilPeekedTypeIs<kLeftBraceToken>();
    const RangeOffset prelude_offset(prelude_offset_start, stream.LookAheadOffset());

    if (stream.AtEnd()) {
      return nullptr;  // Parse error, EOF instead of qualified rule block
    }

    CSSParserTokenStream::BlockGuard guard(stream);
    return ConsumeKeyframeStyleRule(prelude, prelude_offset, stream);
  }

  assert_m(false, "NOTREACHED_IN_MIGRATION");
  //  NOTREACHED_IN_MIGRATION();
  return nullptr;
}

std::unique_ptr<std::vector<KeyframeOffset>> CSSParserImpl::ConsumeKeyframeKeyList(
    std::shared_ptr<const CSSParserContext> context,
    CSSParserTokenRange range) {
  std::unique_ptr<std::vector<KeyframeOffset>> result = std::make_unique<std::vector<KeyframeOffset>>();
  while (true) {
    range.ConsumeWhitespace();
    const CSSParserToken& token = range.Peek();
    if (token.GetType() == kPercentageToken && token.NumericValue() >= 0 && token.NumericValue() <= 100) {
      result->push_back(KeyframeOffset(TimelineOffset::NamedRange::kNone, token.NumericValue() / 100));
      range.ConsumeIncludingWhitespace();
    } else if (token.GetType() == kIdentToken) {
      if (EqualIgnoringASCIICase(token.Value(), "from")) {
        result->push_back(KeyframeOffset(TimelineOffset::NamedRange::kNone, 0));
        range.ConsumeIncludingWhitespace();
      } else if (EqualIgnoringASCIICase(token.Value(), "to")) {
        result->push_back(KeyframeOffset(TimelineOffset::NamedRange::kNone, 1));
        range.ConsumeIncludingWhitespace();
      } else {
        auto range_name_percent = std::reinterpret_pointer_cast<const CSSValueList>(
            css_parsing_utils::ConsumeTimelineRangeNameAndPercent(range, context));
        if (!range_name_percent) {
          return nullptr;
        }

        auto range_name = std::reinterpret_pointer_cast<const CSSIdentifierValue>(range_name_percent->Item(0))
                              ->ConvertTo<TimelineOffset::NamedRange>();
        auto percent =
            std::reinterpret_pointer_cast<const CSSPrimitiveValue>(range_name_percent->Item(1))->GetFloatValue();

        if (range_name != TimelineOffset::NamedRange::kNone) {
          return nullptr;
        }

        result->push_back(KeyframeOffset(range_name, percent / 100.0));
      }
    } else {
      return nullptr;
    }

    if (range.AtEnd()) {
      return result;
    }
    if (range.Consume().GetType() != kCommaToken) {
      return nullptr;  // Parser error
    }
  }
}

std::string CSSParserImpl::ParseCustomPropertyName(const std::string& name_text) {
  CSSTokenizer tokenizer(name_text);
  auto tokens = tokenizer.TokenizeToEOF();
  CSSParserTokenRange range = tokens;
  const CSSParserToken& name_token = range.ConsumeIncludingWhitespace();
  if (!range.AtEnd()) {
    return {};
  }
  if (!CSSVariableParser::IsValidVariableName(name_token)) {
    return {};
  }
  return std::string(name_token.Value());
}

// This function is used for two different but very similarly specified actions
// in [css-syntax-3], namely “parse a list of declarations” (used for style
// attributes, @page rules and a few other things) and “consume a style block's
// contents” (used for the interior of rules, such as in a normal stylesheet).
// The only real difference between the two is that the latter cannot contain
// nested rules. In particular, both have the effective behavior that when
// seeing something that is not an ident and is not a valid selector, we should
// skip to the next semicolon. (For “consume a style block's contents”, this is
// explicit, and for “parse a list of declarations”, it happens due to
// synchronization behavior. Of course, for the latter case, a _valid_ selector
// would get the same skipping behavior.)
//
// So as the spec stands, we can unify these cases; we use
// parent_rule_for_nesting as a marker for which case we are in (see [1]).
// If it's nullptr, we're parsing a declaration list and not a style block,
// so non-idents should not begin consuming qualified rules. See also
// AbortsNestedSelectorParsing(), which uses parent_rule_for_nesting to check
// whether semicolons should abort parsing (the prelude of) qualified rules;
// if semicolons always aborted such parsing, we wouldn't need this distinction.
void CSSParserImpl::ConsumeDeclarationList(CSSParserTokenStream& stream,
                                           StyleRule::RuleType rule_type,
                                           CSSNestingType nesting_type,
                                           std::shared_ptr<StyleRule> parent_rule_for_nesting,
                                           std::vector<std::shared_ptr<StyleRuleBase>>* child_rules) {
  DCHECK(parsed_properties_.empty());

  // Whenever we hit a nested rule, we emit a invisible rule from the
  // declarations in [parsed_properties_.begin() + invisible_rule_start_index,
  // parsed_properties_.end()>, and update invisible_rule_start_index to prepare
  // for the next invisible rule.
  size_t invisible_rule_start_index = kNotFound;

  while (true) {
    // Having a lookahead may skip comments, which are used by the observer.
    DCHECK(!stream.HasLookAhead() || stream.AtEnd());

    if (stream.AtEnd()) {
      break;
    }

    switch (stream.UncheckedPeek().GetType()) {
      case kWhitespaceToken:
      case kSemicolonToken:
        stream.UncheckedConsume();
        break;
      case kAtKeywordToken: {
        CSSParserToken name_token = stream.ConsumeIncludingWhitespace();
        const std::string_view name = name_token.Value();
        const CSSAtRuleID id = CssAtRuleID(name);
        std::shared_ptr<StyleRuleBase> child =
            ConsumeNestedRule(id, rule_type, stream, nesting_type, parent_rule_for_nesting);
        if (child && child_rules) {
          EmitInvisibleRuleIfNeeded(parent_rule_for_nesting, invisible_rule_start_index,
                                    CSSSelector::Signal::kBareDeclarationShift, child_rules);
          invisible_rule_start_index = parsed_properties_.size();
          child_rules->push_back(child);
        }
        break;
      }
      case kIdentToken: {
        CSSParserTokenStream::State state = stream.Save();
        bool consumed_declaration = false;
        {
          CSSParserTokenStream::Boundary boundary(stream, kSemicolonToken);
          consumed_declaration = ConsumeDeclaration(stream, rule_type);
        }
        if (consumed_declaration) {
          if (!stream.AtEnd()) {
            DCHECK_EQ(stream.UncheckedPeek().GetType(), kSemicolonToken);
            stream.UncheckedConsume();  // kSemicolonToken
          }
          break;
        } else if (stream.UncheckedPeek().GetType() == kSemicolonToken) {
          // As an optimization, we avoid the restart below (retrying as a
          // nested style rule) if we ended on a kSemicolonToken, as this
          // situation can't produce a valid rule.
          stream.SkipUntilPeekedTypeIs<kSemicolonToken>();
          if (!stream.AtEnd()) {
            stream.UncheckedConsume();  // kSemicolonToken
          }
          break;
        }
        // Retry as nested rule.
        stream.Restore(state);
        [[fallthrough]];
      }
      default:
        if (parent_rule_for_nesting != nullptr) {  // [1] (see function comment)
          std::shared_ptr<StyleRuleBase> child =
              ConsumeNestedRule(std::nullopt, rule_type, stream, nesting_type, parent_rule_for_nesting);
          if (child) {
            if (child_rules) {
              EmitInvisibleRuleIfNeeded(parent_rule_for_nesting, invisible_rule_start_index,
                                        CSSSelector::Signal::kBareDeclarationShift, child_rules);
              invisible_rule_start_index = parsed_properties_.size();
              child_rules->push_back(child);
            }
            break;
          }
          // Fall through to error recovery.
          stream.EnsureLookAhead();
        }

        [[fallthrough]];
        // Function tokens should start parsing a declaration
        // (which then immediately goes into error recovery mode).
      case CSSParserTokenType::kFunctionToken:
        while (!stream.UncheckedAtEnd() && stream.UncheckedPeek().GetType() != kSemicolonToken) {
          stream.UncheckedConsumeComponentValue();
        }

        if (!stream.UncheckedAtEnd()) {
          stream.UncheckedConsume();  // kSemicolonToken
        }

        break;
    }
  }

  // We need a final call to EmitInvisibleRuleIfNeeded in case there are
  // trailing bare declarations.
  EmitInvisibleRuleIfNeeded(parent_rule_for_nesting, invisible_rule_start_index,
                            CSSSelector::Signal::kBareDeclarationShift, child_rules);
}

template <typename ConsumeFunction>
CSSTokenizedValue CSSParserImpl::ConsumeValue(CSSParserTokenStream& stream, ConsumeFunction consume_function) {
  // Consume leading whitespace and comments. This is needed
  // by ConsumeDeclarationValue() / CSSPropertyParser::ParseValue(),
  // and also CSSVariableParser::ParseDeclarationIncludingCSSWide().
  stream.ConsumeWhitespace();
  size_t value_start_offset = stream.LookAheadOffset();
  CSSParserTokenRange range = consume_function(stream);
  size_t value_end_offset = stream.LookAheadOffset();

  return {range, stream.StringRangeAt(value_start_offset, value_end_offset - value_start_offset)};
}

bool CSSParserImpl::ConsumeSupportsDeclaration(CSSParserTokenStream& stream) {
  DCHECK(parsed_properties_.empty());
  // Even though we might use an observer here, this is just to test if we
  // successfully parse the range, so we can temporarily remove the observer.
  ConsumeDeclaration(stream, StyleRule::kStyle);

  bool result = !parsed_properties_.empty();
  parsed_properties_.clear();
  return result;
}


std::shared_ptr<StyleRuleBase> CSSParserImpl::ConsumeNestedRule(std::optional<CSSAtRuleID> id,
                                                                StyleRule::RuleType parent_rule_type,
                                                                CSSParserTokenStream& stream,
                                                                CSSNestingType nesting_type,
                                                                std::shared_ptr<StyleRule> parent_rule_for_nesting) {
  // A nested style rule. Recurse into the parser; we need to move the parsed
  // properties out of the way while we're parsing the child rule, though.
  // TODO(sesse): The spec says that any properties after a nested rule
  // should be ignored. We don't support this yet.
  // See https://github.com/w3c/csswg-drafts/issues/7501.
  std::vector<CSSPropertyValue> outer_parsed_properties;
  outer_parsed_properties.reserve(64);
  swap(parsed_properties_, outer_parsed_properties);
  std::shared_ptr<StyleRuleBase> child;
  webf::AutoReset<bool> reset_in_nested_style_rule(&in_nested_style_rule_, true);
  if (!id.has_value()) {
    child = ConsumeStyleRule(stream, nesting_type, parent_rule_for_nesting,
                             /* semicolon_aborts_nested_selector */ true);
  } else {
    child =
        ConsumeAtRuleContents(*id, stream, parent_rule_type == StyleRule::kPage ? kPageMarginRules : kNestedGroupRules,
                              nesting_type, parent_rule_for_nesting);
  }
  parsed_properties_ = std::move(outer_parsed_properties);
  return child;
}

static std::shared_ptr<ImmutableCSSPropertyValueSet> CreateCSSPropertyValueSet(
    std::vector<CSSPropertyValue>& parsed_properties,
    CSSParserMode mode,
    const Document* document) {
  if (mode != kHTMLQuirksMode &&
      (parsed_properties.size() < 2 ||
       (parsed_properties.size() == 2 && parsed_properties[0].Id() != parsed_properties[1].Id()))) {
    // Fast path for the situations where we can trivially detect that there can
    // be no collision between properties, and don't need to reorder, make
    // bitsets, or similar.
    auto result = ImmutableCSSPropertyValueSet::Create(parsed_properties.data(), parsed_properties.size(), mode);
    parsed_properties.clear();
    return result;
  }

  std::bitset<kNumCSSProperties> seen_properties;
  size_t unused_entries = parsed_properties.size();
  std::vector<CSSPropertyValue> results;
  results.reserve(64);
  std::unordered_set<std::string> seen_custom_properties;

  FilterProperties(true, parsed_properties, results, unused_entries, seen_properties, seen_custom_properties);
  FilterProperties(false, parsed_properties, results, unused_entries, seen_properties, seen_custom_properties);

  auto result =
      ImmutableCSSPropertyValueSet::Create(results.data() + unused_entries, results.size() - unused_entries, mode);
  parsed_properties.clear();
  return result;
}

std::shared_ptr<StyleRule> CSSParserImpl::ConsumeStyleRuleContents(tcb::span<CSSSelector> selector_vector,
                                                                   CSSParserTokenStream& stream) {
  std::shared_ptr<StyleRule> style_rule = StyleRule::Create(selector_vector);
  std::vector<std::shared_ptr<StyleRuleBase>> child_rules;
  child_rules.reserve(4);
  ConsumeDeclarationList(stream, StyleRule::kStyle, CSSNestingType::kNesting,
                         /*parent_rule_for_nesting=*/style_rule, &child_rules);
  for (auto &&child_rule : child_rules) {
    style_rule->AddChildRule(child_rule);
  }
  style_rule->SetProperties(CreateCSSPropertyValueSet(parsed_properties_, context_->Mode(), context_->GetDocument()));
  return style_rule;
}

std::shared_ptr<const ImmutableCSSPropertyValueSet> CSSParserImpl::ParseInlineStyleDeclaration(
    const std::string& string,
    Element* element) {
  Document& document = element->GetDocument();
  auto context = std::make_shared<CSSParserContext>(document.ElementSheet().Contents()->ParserContext().get(),
                                                    document.ElementSheet().Contents().get());
  CSSParserMode mode = kHTMLStandardMode;
  context->SetMode(mode);
  CSSParserImpl parser(context, document.ElementSheet().Contents());
  CSSTokenizer tokenizer(string);
  CSSParserTokenStream stream(tokenizer);
  parser.ConsumeDeclarationList(stream, StyleRule::kStyle, CSSNestingType::kNone,
                                /*parent_rule_for_nesting=*/nullptr,
                                /*child_rules=*/nullptr);
  return CreateCSSPropertyValueSet(parser.parsed_properties_, mode, &document);
}

std::shared_ptr<const ImmutableCSSPropertyValueSet> CSSParserImpl::ParseInlineStyleDeclaration(
    const std::string& string,
    CSSParserMode parser_mode,
    const Document* document) {
  auto context = std::make_shared<CSSParserContext>(parser_mode);
  CSSParserImpl parser(context);
  CSSTokenizer tokenizer(string);
  CSSParserTokenStream stream(tokenizer);
  parser.ConsumeDeclarationList(stream, StyleRule::kStyle, CSSNestingType::kNone,
                                /*parent_rule_for_nesting=*/nullptr,
                                /*child_rules=*/nullptr);
  return CreateCSSPropertyValueSet(parser.parsed_properties_, parser_mode, document);
}

std::shared_ptr<StyleRule> CSSParserImpl::CreateInvisibleRule(const CSSSelector* selector_list,
                                                              size_t start_index,
                                                              size_t end_index,
                                                              CSSSelector::Signal signal) {
  DCHECK(selector_list);
  DCHECK_LT(start_index, end_index);
  // Create a invisible rule covering all declarations since `start_index`.

  std::vector<CSSPropertyValue> invisible_declarations;
  invisible_declarations.reserve(64);

  for (auto begin = parsed_properties_.begin() + start_index; begin < parsed_properties_.begin() + end_index; begin++) {
    invisible_declarations.emplace_back(*begin);
  }

  // Copy the selector list, and mark each CSSSelector (top-level) as invisible.
  // We only strictly need to mark the first CSSSelector in each complex
  // selector, but it's easier to just mark everything.
  std::vector<CSSSelector> selectors;
  for (const CSSSelector* selector = selector_list; selector;
       selector = selector->IsLastInSelectorList() ? nullptr : (selector + 1)) {
    selectors.push_back(*selector);
    selectors.back().SetInvisible();
    selectors.back().SetSignal(signal);
  }

  CHECK(!selectors.empty());
  CHECK(selectors.back().IsLastInComplexSelector());
  CHECK(selectors.back().IsLastInSelectorList());

  return StyleRule::Create(
      tcb::span<CSSSelector>{selectors.data(), selectors.size()},
      CreateCSSPropertyValueSet(invisible_declarations, context_->Mode(), context_->GetDocument()));
}

void CSSParserImpl::EmitInvisibleRuleIfNeeded(std::shared_ptr<StyleRule> parent_rule_for_nesting,
                                              size_t start_index,
                                              CSSSelector::Signal signal,
                                              std::vector<std::shared_ptr<StyleRuleBase>>* child_rules) {
  if (!child_rules) {
    // This can happen we we consume a declaration list
    // for a top-level style rule.
    return;
  }
  if (!parent_rule_for_nesting) {
    // This can happen for @page, which behaves simiarly to CSS Nesting
    // (and cares about child rules), but doesn't have a parent style rule.
    return;
  }
  size_t end_index = parsed_properties_.size();
  if (start_index >= end_index) {
    // No need to emit a rule with nothing in it.
    return;
  }
  if (std::shared_ptr<StyleRule> invisible_rule =
          CreateInvisibleRule(parent_rule_for_nesting->FirstSelector(), start_index, end_index, signal)) {
    child_rules->push_back(invisible_rule);
  }
}

CSSTokenizedValue CSSParserImpl::ConsumeUnrestrictedPropertyValue(CSSParserTokenStream& stream) {
  return ConsumeValue(stream, [](CSSParserTokenStream& stream) { return stream.ConsumeUntilPeekedTypeIs<>(); });
}

bool CSSParserImpl::ConsumeVariableValue(CSSParserTokenStream& stream,
                                         const std::string& variable_name,
                                         bool allow_important_annotation,
                                         bool is_animation_tainted) {
  stream.EnsureLookAhead();

  // First, see if this is (only) a CSS-wide keyword.
  bool important;
  std::shared_ptr<const CSSValue> value =
      CSSPropertyParser::ConsumeCSSWideKeyword(stream, allow_important_annotation, important);
  if (!value) {
    // It was not, so try to parse it as an unparsed declaration value
    // (which is pretty free-form).
    std::shared_ptr<CSSVariableData> variable_data = CSSVariableParser::ConsumeUnparsedDeclaration(
        stream, allow_important_annotation, is_animation_tainted,
        /*must_contain_variable_reference=*/false,
        /*restricted_value=*/false, /*comma_ends_declaration=*/false, important, context_->GetExecutingContext());
    if (!variable_data) {
      return false;
    }

    value = std::make_shared<CSSUnparsedDeclarationValue>(variable_data, context_);
  }
  parsed_properties_.emplace_back(CSSPropertyName(variable_name), value, important);
  return true;
}

// NOTE: Leading whitespace must be stripped from the stream, since
// ParseValue() has the same requirement.
void CSSParserImpl::ConsumeDeclarationValue(CSSParserTokenStream& stream,
                                            CSSPropertyID unresolved_property,
                                            bool is_in_declaration_list,
                                            StyleRule::RuleType rule_type) {
  const bool allow_important_annotation =
      is_in_declaration_list && rule_type != StyleRule::kKeyframe && rule_type != StyleRule::kPositionTry;
  CSSPropertyParser::ParseValue(unresolved_property, allow_important_annotation, stream, context_,
                                parsed_properties_, rule_type);
}

bool CSSParserImpl::RemoveImportantAnnotationIfPresent(CSSTokenizedValue& tokenized_value) {
  if (tokenized_value.range.size() == 0) {
    return false;
  }
  const CSSParserToken* first = tokenized_value.range.begin();
  const CSSParserToken* last = tokenized_value.range.end() - 1;
  while (last >= first && last->GetType() == kWhitespaceToken) {
    --last;
  }
  if (last >= first && last->GetType() == kIdentToken && EqualIgnoringASCIICase(last->Value(), "important")) {
    --last;
    while (last >= first && last->GetType() == kWhitespaceToken) {
      --last;
    }
    if (last >= first && last->GetType() == kDelimiterToken && last->Delimiter() == '!') {
      tokenized_value.range = tokenized_value.range.MakeSubRange(first, last);

      // Truncate the text to remove the delimiter and everything after it.
      if (!tokenized_value.text.empty()) {
        DCHECK_NE(std::string(tokenized_value.text).find('!'), std::string::npos);
        unsigned truncated_length = tokenized_value.text.length() - 1;
        while (tokenized_value.text[truncated_length] != '!') {
          --truncated_length;
        }
        tokenized_value.text = std::string_view(tokenized_value.text.data() + 0, truncated_length);
      }
      return true;
    }
  }

  return false;
}

// This function can leave the stream in one of the following states:
//
//  1) If the ident token is not immediately followed by kColonToken,
//     then the stream is left at the token where kColonToken was expected.
//  2) If the ident token is not a recognized property/descriptor,
//     then the stream is left at the token immediately after kColonToken.
//  3) Otherwise the stream is is left AtEnd(), regardless of whether or
//     not the value was valid.
//
// Leaving the stream in an awkward states is normally not desirable for
// Consume functions, but declarations are sometimes parsed speculatively,
// which may cause a restart at the call site (see ConsumeDeclarationList,
// kIdentToken branch). If we are anyway going to restart, any work we do
// to leave the stream in a more consistent state is just wasted.
bool CSSParserImpl::ConsumeDeclaration(CSSParserTokenStream& stream, StyleRule::RuleType rule_type) {
  const size_t decl_offset_start = stream.Offset();

  DCHECK_EQ(stream.Peek().GetType(), kIdentToken);
  const CSSParserToken& lhs = stream.ConsumeIncludingWhitespace();
  if (stream.Peek().GetType() != kColonToken) {
    return false;  // Parse error.
  }

  stream.UncheckedConsume();  // kColonToken
  stream.EnsureLookAhead();

  size_t properties_count = parsed_properties_.size();

  bool parsing_descriptor = rule_type == StyleRule::kFontFace || rule_type == StyleRule::kFontPaletteValues ||
                            rule_type == StyleRule::kProperty || rule_type == StyleRule::kViewTransition;

  uint64_t id = parsing_descriptor ? static_cast<uint64_t>(lhs.ParseAsAtRuleDescriptorID())
                                   : static_cast<uint64_t>(lhs.ParseAsUnresolvedCSSPropertyID(
                                         context_->GetExecutingContext(), context_->Mode()));

  bool important = false;

  static_assert(static_cast<uint64_t>(AtRuleDescriptorID::Invalid) == 0u);
  static_assert(static_cast<uint64_t>(CSSPropertyID::kInvalid) == 0u);

  stream.ConsumeWhitespace();

  if (id) {
    if (parsing_descriptor) {
      CSSTokenizedValue tokenized_value = ConsumeUnrestrictedPropertyValue(stream);
      important = RemoveImportantAnnotationIfPresent(tokenized_value);
      if (important) {
        return false;  // Invalid for descriptors.
      }
      const AtRuleDescriptorID atrule_id = static_cast<AtRuleDescriptorID>(id);
      AtRuleDescriptorParser::ParseAtRule(rule_type, atrule_id, tokenized_value, context_, parsed_properties_);
    } else {
      const CSSPropertyID unresolved_property = static_cast<CSSPropertyID>(id);
      if (unresolved_property == CSSPropertyID::kVariable) {
        if (rule_type != StyleRule::kStyle && rule_type != StyleRule::kKeyframe) {
          return false;
        }
        CSSTokenizedValue tokenized_value = ConsumeUnrestrictedPropertyValue(stream);
        important = RemoveImportantAnnotationIfPresent(tokenized_value);
        if (important && (rule_type == StyleRule::kKeyframe)) {
          return false;
        }
        std::string variable_name = std::string(lhs.Value());
        bool allow_important_annotation = (rule_type != StyleRule::kKeyframe);
        bool is_animation_tainted = rule_type == StyleRule::kKeyframe;
        if (!ConsumeVariableValue(stream, variable_name, allow_important_annotation, is_animation_tainted)) {
          return false;
        }
      } else if (unresolved_property != CSSPropertyID::kInvalid) {
        ConsumeDeclarationValue(stream, unresolved_property,
                                /*is_in_declaration_list=*/true, rule_type);
      }
    }
  }
  if ((rule_type == StyleRule::kStyle || rule_type == StyleRule::kKeyframe || rule_type == StyleRule::kProperty ||
       rule_type == StyleRule::kPositionTry || rule_type == StyleRule::kFontPaletteValues)) {
    if (!id) {
      // If we skipped the relevant Consume*() calls above due to an invalid
      // property/descriptor, the inspector still needs to know the offset
      // where the would-be declaration ends.
      CSSVariableParser::ConsumeUnparsedDeclaration(stream, /*allow_important_annotation=*/true,
                                                    /*is_animation_tainted=*/false,
                                                    /*must_contain_variable_reference=*/false,
                                                    /*restricted_value=*/true, /*comma_ends_declaration=*/false,
                                                    important, context_->GetExecutingContext());
    }
  }

  return parsed_properties_.size() != properties_count;
}

std::shared_ptr<StyleRuleKeyframe> CSSParserImpl::ConsumeKeyframeStyleRule(
    webf::CSSParserTokenRange prelude,
    const webf::CSSParserImpl::RangeOffset& prelude_offset,
    webf::CSSParserTokenStream& block) {
  std::unique_ptr<std::vector<KeyframeOffset>> key_list = ConsumeKeyframeKeyList(context_, prelude);
  if (!key_list) {
    return nullptr;
  }

  ConsumeDeclarationList(block, StyleRule::kKeyframe, CSSNestingType::kNone,
                         /*parent_rule_for_nesting=*/nullptr,
                         /*child_rules=*/nullptr);

  return std::make_shared<StyleRuleKeyframe>(
      std::move(key_list),
      CreateCSSPropertyValueSet(parsed_properties_, kCSSKeyframeRuleMode, context_->GetDocument()));
}

std::shared_ptr<StyleRuleBase> CSSParserImpl::ConsumeAtRule(CSSParserTokenStream& stream,
                                                            AllowedRulesType allowed_rules,
                                                            CSSNestingType nesting_type,
                                                            std::shared_ptr<const StyleRule> parent_rule_for_nesting) {
  assert(stream.Peek().GetType() == kAtKeywordToken);
  CSSParserToken name_token = stream.ConsumeIncludingWhitespace();  // Must live until CssAtRuleID().
  const std::string_view name = name_token.Value();
  const CSSAtRuleID id = CssAtRuleID(name);
  return ConsumeAtRuleContents(id, stream, allowed_rules, nesting_type, parent_rule_for_nesting);
}

std::shared_ptr<StyleRuleBase> CSSParserImpl::ConsumeAtRuleContents(
    CSSAtRuleID id,
    CSSParserTokenStream& stream,
    AllowedRulesType allowed_rules,
    CSSNestingType nesting_type,
    std::shared_ptr<const StyleRule> parent_rule_for_nesting) {
  if (allowed_rules == kNestedGroupRules) {
    if (id != CSSAtRuleID::kCSSAtRuleMedia &&      // [css-conditional-3]
        id != CSSAtRuleID::kCSSAtRuleSupports &&   // [css-conditional-3]
        id != CSSAtRuleID::kCSSAtRuleContainer &&  // [css-contain-3]
        id != CSSAtRuleID::kCSSAtRuleLayer &&      // [css-cascade-5]
        id != CSSAtRuleID::kCSSAtRuleScope &&      // [css-cascade-6]
        id != CSSAtRuleID::kCSSAtRuleStartingStyle && id != CSSAtRuleID::kCSSAtRuleViewTransition &&
        (id < CSSAtRuleID::kCSSAtRuleTopLeftCorner || id > CSSAtRuleID::kCSSAtRuleRightBottom)) {
      ConsumeErroneousAtRule(stream, id);
      return nullptr;
    }
    allowed_rules = kRegularRules;
  }

  ExecutingContext* executingContext = GetContext()->GetExecutingContext();

  // @import rules have a URI component that is not technically part of the
  // prelude.
  std::string import_prelude_uri;
  if (allowed_rules <= kAllowImportRules && id == CSSAtRuleID::kCSSAtRuleImport) {
    import_prelude_uri = ConsumeStringOrURI(stream);
  }

  // NOTE: @keyframes
  if (allowed_rules == kKeyframeRules || allowed_rules == kNoRules) {
    // Parse error, no at-rules supported inside @keyframes,
    // or blocks supported inside declaration lists.
    ConsumeErroneousAtRule(stream, id);
    return nullptr;
  }

  stream.EnsureLookAhead();
  if (allowed_rules == kAllowCharsetRules && id == CSSAtRuleID::kCSSAtRuleCharset) {
    return ConsumeCharsetRule(stream);
  }
  // TODO: @import
  else if (allowed_rules <= kAllowImportRules && id == CSSAtRuleID::kCSSAtRuleImport) {
    //    return ConsumeImportRule(std::move(import_prelude_uri), stream);
  } else {
    assert(allowed_rules <= kRegularRules);

    switch (id) {
        //      TODO(xiezuobing): @media
        //      case CSSAtRuleID::kCSSAtRuleMedia:
        //        return ConsumeMediaRule(stream, nesting_type, parent_rule_for_nesting);
        //      TODO(xiezuobing): @supports
        //      case CSSAtRuleID::kCSSAtRuleSupports:
        //        return ConsumeSupportsRule(stream, nesting_type,
        //                                   parent_rule_for_nesting);
        //      TODO(xiezuobing): @font-face
        //      case CSSAtRuleID::kCSSAtRuleFontFace:
        //        return ConsumeFontFaceRule(stream);
        //      TODO(xiezuobing): @--webkit-keyframes 草案
        //      case CSSAtRuleID::kCSSAtRuleWebkitKeyframes:
        //        return ConsumeKeyframesRule(true, stream);
        //      TODO(xiezuobing): @keyframes
        //      case CSSAtRuleID::kCSSAtRuleKeyframes:
        //        return ConsumeKeyframesRule(false, stream);
      case CSSAtRuleID::kCSSAtRuleInvalid:
      case CSSAtRuleID::kCSSAtRuleCharset:
      case CSSAtRuleID::kCSSAtRuleImport:
      case CSSAtRuleID::kCSSAtRuleNamespace:
      case CSSAtRuleID::kCSSAtRuleStylistic:
      case CSSAtRuleID::kCSSAtRuleStyleset:
      case CSSAtRuleID::kCSSAtRuleCharacterVariant:
      case CSSAtRuleID::kCSSAtRuleSwash:
      case CSSAtRuleID::kCSSAtRuleOrnaments:
      case CSSAtRuleID::kCSSAtRuleAnnotation:
      case CSSAtRuleID::kCSSAtRuleTopLeftCorner:
      case CSSAtRuleID::kCSSAtRuleTopLeft:
      case CSSAtRuleID::kCSSAtRuleTopCenter:
      case CSSAtRuleID::kCSSAtRuleTopRight:
      case CSSAtRuleID::kCSSAtRuleTopRightCorner:
      case CSSAtRuleID::kCSSAtRuleBottomLeftCorner:
      case CSSAtRuleID::kCSSAtRuleBottomLeft:
      case CSSAtRuleID::kCSSAtRuleBottomCenter:
      case CSSAtRuleID::kCSSAtRuleBottomRight:
      case CSSAtRuleID::kCSSAtRuleBottomRightCorner:
      case CSSAtRuleID::kCSSAtRuleLeftTop:
      case CSSAtRuleID::kCSSAtRuleLeftMiddle:
      case CSSAtRuleID::kCSSAtRuleLeftBottom:
      case CSSAtRuleID::kCSSAtRuleRightTop:
      case CSSAtRuleID::kCSSAtRuleRightMiddle:
      case CSSAtRuleID::kCSSAtRuleRightBottom:
        ConsumeErroneousAtRule(stream, id);
        return nullptr;  // Parse error, unrecognised or not-allowed at-rule
    }
  }
}

void CSSParserImpl::ConsumeErroneousAtRule(CSSParserTokenStream& stream, CSSAtRuleID id) {
  // Consume the prelude and block if present.
  stream.SkipUntilPeekedTypeIs<kLeftBraceToken, kSemicolonToken>();
  if (!stream.AtEnd()) {
    if (stream.UncheckedPeek().GetType() == kLeftBraceToken) {
      CSSParserTokenStream::BlockGuard guard(stream);
    } else {
      stream.UncheckedConsume();  // kSemicolonToken
    }
  }
}

// A (hopefully) fast check for whether the given declaration block could
// contain nested CSS rules. All of these have to involve { in some shape
// or form, so we simply check for the existence of that. (It means we will
// have false positives for e.g. { within comments or strings, but this
// only means we will turn off lazy parsing for that rule, nothing worse.)
// This will work even for UTF-16, although with some more false positives
// with certain Unicode characters such as U+017E (LATIN SMALL LETTER Z
// WITH CARON). This is, again, not a big problem for us.
static bool MayContainNestedRules(const std::string& text, size_t offset, size_t length) {
  if (length < 2u) {
    // {} is the shortest possible block (but if there's
    // a lone { and then EOF, we will be called with length 1).
    return false;
  }

  size_t char_size = sizeof(uint8_t);

  // Strip away the outer {} pair (the { would always give us a false positive).
  DCHECK_EQ(text[offset], '{');
  if (text[offset + length - 1] != '}') {
    // EOF within the block, so just be on the safe side
    // and use the normal (non-lazy) code path.
    return true;
  }
  ++offset;
  length -= 2;

  return memchr(reinterpret_cast<const char*>(text.data()) + offset * char_size, '{', length * char_size) != nullptr;
}

std::shared_ptr<StyleRule> CSSParserImpl::ConsumeStyleRule(CSSParserTokenStream& stream,
                                                           CSSNestingType nesting_type,
                                                           std::shared_ptr<const StyleRule> parent_rule_for_nesting,
                                                           bool semicolon_aborts_nested_selector) {
  if (!in_nested_style_rule_) {
    assert(0u == arena_.size());
  }
  auto func_clear_arena = [&](std::vector<CSSSelector>* arena) {
    if (!in_nested_style_rule_) {
      arena->resize(0);  // See class c
                         // omment on CSSSelectorParser.
    }
  };
  std::unique_ptr<std::vector<CSSSelector>, decltype(func_clear_arena)> scope_guard(&arena_,
                                                                                    std::move(func_clear_arena));
  // Style rules that look like custom property declarations
  // are not allowed by css-syntax.
  //
  // https://drafts.csswg.org/css-syntax/#consume-qualified-rule
  bool custom_property_ambiguity = false;
  if (CSSVariableParser::IsValidVariableName(stream.Peek())) {
    CSSParserTokenStream::State state = stream.Save();
    stream.ConsumeIncludingWhitespace();  // <ident>
    custom_property_ambiguity = stream.Peek().GetType() == kColonToken;
    stream.Restore(state);
  }

  // Parse the prelude of the style rule
  tcb::span<CSSSelector> selector_vector =
      CSSSelectorParser::ConsumeSelector(stream, context_, nesting_type, parent_rule_for_nesting, is_within_scope_,
                                         semicolon_aborts_nested_selector, style_sheet_, nullptr, arena_);

  if (selector_vector.empty()) {
    // Read the rest of the prelude if there was an error
    stream.EnsureLookAhead();
    while (!stream.UncheckedAtEnd() && stream.UncheckedPeek().GetType() != kLeftBraceToken &&
           !AbortsNestedSelectorParsing(stream.UncheckedPeek().GetType(), semicolon_aborts_nested_selector,
                                        nesting_type)) {
      stream.UncheckedConsumeComponentValue();
    }
  }

  if (stream.AtEnd() ||
      AbortsNestedSelectorParsing(stream.UncheckedPeek().GetType(), semicolon_aborts_nested_selector, nesting_type)) {
    // Parse error, EOF instead of qualified rule block
    // (or we went into error recovery above).
    // NOTE: If we aborted due to a semicolon, don't consume it here;
    // the caller will do that for us.
    return nullptr;
  }

  assert(stream.Peek().GetType() == kLeftBraceToken);
  bool is_css_lazy_parsing_fast_path_enabled_ = true;

  if (is_css_lazy_parsing_fast_path_enabled_) {
    if (selector_vector.empty() || custom_property_ambiguity) {
      // Parse error, invalid selector list or ambiguous custom property.
      CSSParserTokenStream::BlockGuard guard(stream);
      return nullptr;
    }

    if (lazy_state_) {
      assert(style_sheet_);

      uint32_t len = static_cast<uint32_t>(FindLengthOfDeclarationList(std::string_view(stream.RemainingText().data() + 1)));
      if (len != 0) {
        uint32_t block_start_offset = stream.Offset();
        stream.SkipToEndOfBlock(len + 2);  // +2 for { and }.
        return StyleRule::Create(selector_vector,
                                 std::make_shared<CSSLazyPropertyParserImpl>(block_start_offset, lazy_state_));
      }
    }
    CSSParserTokenStream::BlockGuard guard(stream);
    return ConsumeStyleRuleContents(selector_vector, stream);
  } else {
    CSSParserTokenStream::BlockGuard guard(stream);

    if (selector_vector.empty()) {
      // Parse error, invalid selector list.
      return nullptr;
    }
    if (custom_property_ambiguity) {
      return nullptr;
    }

    // TODO(csharrison): How should we lazily parse css that needs the observer?
    if (lazy_state_) {
      DCHECK(style_sheet_);

      size_t block_start_offset = stream.Offset() - 1;  // - 1 for the {.
      guard.SkipToEndOfBlock();
      size_t block_length = stream.Offset() - block_start_offset;

      // Lazy parsing cannot deal with nested rules. We make a very quick check
      // to see if there could possibly be any in there; if so, we need to go
      // back to normal (non-lazy) parsing. If that happens, we've wasted some
      // work; specifically, the SkipToEndOfBlock(), and potentially that we
      // cannot use the CachedCSSTokenizer if that would otherwise be in use.
      if (MayContainNestedRules(lazy_state_->SheetText(), block_start_offset, block_length)) {
        CSSTokenizer tokenizer(lazy_state_->SheetText(), block_start_offset);
        CSSParserTokenStream block_stream(tokenizer);
        CSSParserTokenStream::BlockGuard sub_guard(block_stream);  // Consume the {, and open the block stack.
        return ConsumeStyleRuleContents(selector_vector, block_stream);
      }

      return StyleRule::Create(selector_vector,
                               std::make_shared<CSSLazyPropertyParserImpl>(block_start_offset, lazy_state_));
    }
    return ConsumeStyleRuleContents(selector_vector, stream);
  }
}

CSSParserTokenRange ConsumeAtRulePrelude(CSSParserTokenStream& stream) {
  return stream.ConsumeUntilPeekedTypeIs<kLeftBraceToken, kSemicolonToken>();
}

bool ConsumeEndOfPreludeForAtRuleWithoutBlock(CSSParserTokenStream& stream) {
  if (stream.AtEnd() || stream.UncheckedPeek().GetType() == kSemicolonToken) {
    if (!stream.UncheckedAtEnd()) {
      stream.UncheckedConsume();  // kSemicolonToken
    }
    return true;
  }

  // Consume the erroneous block.
  CSSParserTokenStream::BlockGuard guard(stream);
  return false;  // Parse error, we expected no block.
}

std::shared_ptr<StyleRuleCharset> CSSParserImpl::ConsumeCharsetRule(CSSParserTokenStream& stream) {
  CSSParserTokenRange prelude = ConsumeAtRulePrelude(stream);
  if (!ConsumeEndOfPreludeForAtRuleWithoutBlock(stream)) {
    return nullptr;
  }

  const CSSParserToken& string = prelude.ConsumeIncludingWhitespace();
  if (string.GetType() != kStringToken || !prelude.AtEnd()) {
    return nullptr;  // Parse error, expected a single string
  }
  return std::make_shared<StyleRuleCharset>();
}


std::shared_ptr<CSSPropertyValueSet> CSSParserImpl::ParseDeclarationListForLazyStyle(
    const std::string& string,
    size_t offset,
    std::shared_ptr<const CSSParserContext> context) {
  // NOTE: Lazy parsing does not support nested rules (it happens
  // only after matching, which means that we cannot insert child rules
  // we encounter during parsing -- we never match against them),
  // so parent_rule_for_nesting is always nullptr here. The parser
  // explicitly makes sure we do not invoke lazy parsing for rules
  // with child rules in them.
  CSSTokenizer tokenizer(string, offset);
  CSSParserTokenStream stream(tokenizer);
  CSSParserTokenStream::BlockGuard guard(stream);
  CSSParserImpl parser(context);
  parser.ConsumeDeclarationList(stream, StyleRule::kStyle,
                                CSSNestingType::kNone,
                                /*parent_rule_for_nesting=*/nullptr,
                                /*child_rules=*/nullptr);
  return CreateCSSPropertyValueSet(parser.parsed_properties_, context->Mode(),
                                   context->GetDocument());
}

}  // namespace webf
