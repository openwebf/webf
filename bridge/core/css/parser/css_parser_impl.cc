// Copyright 2014 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "css_parser_impl.h"

#include <cassert>
#include <vector>
#include "core/css/css_property_value.h"
#include "core/css/css_selector.h"
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
#include "foundation/casting.h"

namespace webf {

namespace {

// This may still consume tokens if it fails
AtomicString ConsumeStringOrURI(CSSParserTokenStream& stream, ExecutingContext* executingContext) {
  const CSSParserToken& token = stream.Peek();

  if (token.GetType() == kStringToken || token.GetType() == kUrlToken) {
    return stream.ConsumeIncludingWhitespace().Value().ToAtomicString(executingContext->ctx());
  }

  if (token.GetType() != kFunctionToken || !EqualIgnoringASCIICase(token.Value(), StringView("url"))) {
    return AtomicString();
  }

  AtomicString result;
  {
    CSSParserTokenStream::BlockGuard guard(stream);
    const CSSParserToken& uri = stream.ConsumeIncludingWhitespace();
    if (uri.GetType() != kBadStringToken && stream.UncheckedAtEnd()) {
      assert(uri.GetType() == kStringToken);
      result = uri.Value().ToAtomicString(executingContext->ctx());
    }
  }
  stream.ConsumeWhitespace();
  return result;
}
}  // namespace

CSSParserImpl::CSSParserImpl(const std::shared_ptr<const CSSParserContext>& context,
                             std::shared_ptr<StyleSheetContents> style_sheet)
    : context_(context), style_sheet_(style_sheet), observer_(nullptr), lazy_state_(nullptr) {}

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
//  bool first_rule_valid = parser.ConsumeRuleList(
//      stream, kTopLevelRuleList, CSSNestingType::kNone,
//      /*parent_rule_for_nesting=*/nullptr,
//      [&style_sheet, &result, &string, allow_import_rules, context](
//          const std::shared_ptr<StyleRuleBase>& rule, size_t offset) {
//        if (rule->IsCharsetRule()) {
//          return;
//        }
//        if (rule->IsImportRule()) {
//          if (!allow_import_rules || context->IsForMarkupSanitization()) {
//            result = ParseSheetResult::kHasUnallowedImportRule;
//            return;
//          }
//
//          Document* document = style_sheet->AnyOwnerDocument();
//          if (document) {
//            TextPosition position = TextPosition::MinimumPosition();
//            To<StyleRuleImport>(rule.get())->SetPositionHint(position);
//          }
//        }
//
//        style_sheet->ParserAppendRule(rule);
//      });
//  style_sheet->SetHasSyntacticallyValidCSSHeader(first_rule_valid);

  return result;
}

//static CSSParserImpl::AllowedRulesType ComputeNewAllowedRules(CSSParserImpl::AllowedRulesType allowed_rules,
//                                                              std::shared_ptr<StyleRuleBase> rule) {
//  if (!rule || allowed_rules == CSSParserImpl::kKeyframeRules || allowed_rules == CSSParserImpl::kFontFeatureRules ||
//      allowed_rules == CSSParserImpl::kNoRules) {
//    return allowed_rules;
//  }
//  assert(allowed_rules <= CSSParserImpl::kRegularRules);
//  if (rule->IsCharsetRule()) {
//    return CSSParserImpl::kAllowLayerStatementRules;
//  }
//  if (rule->IsLayerStatementRule()) {
//    if (allowed_rules <= CSSParserImpl::kAllowLayerStatementRules) {
//      return CSSParserImpl::kAllowLayerStatementRules;
//    }
//    return CSSParserImpl::kRegularRules;
//  }
//  if (rule->IsImportRule()) {
//    return CSSParserImpl::kAllowImportRules;
//  }
//  if (rule->IsNamespaceRule()) {
//    return CSSParserImpl::kAllowNamespaceRules;
//  }
//  return CSSParserImpl::kRegularRules;
//}

// TODO:当前进度[ConsumeQualifiedRule]
//template <typename T>
//bool CSSParserImpl::ConsumeRuleList(CSSParserTokenStream& stream,
//                                    RuleListType rule_list_type,
//                                    CSSNestingType nesting_type,
//                                    const std::shared_ptr<StyleRule>& parent_rule_for_nesting,
//                                    const T callback) {
//  AllowedRulesType allowed_rules = kRegularRules;
//  switch (rule_list_type) {
//    case kTopLevelRuleList:
//      allowed_rules = kAllowCharsetRules;
//      break;
//    case kRegularRuleList:
//      allowed_rules = kRegularRules;
//      break;
//    case kKeyframesRuleList:
//      allowed_rules = kKeyframeRules;
//      break;
//    case kFontFeatureRuleList:
//      allowed_rules = kFontFeatureRules;
//      break;
//    default:
//      assert_m(false, "NOT REACHD IN MARGATION.");
//      //      NOTREACHED_IN_MIGRATION();
//  }
//
//  bool seen_rule = false;
//  bool first_rule_valid = false;
//  while (!stream.AtEnd()) {
//    uint32_t offset = stream.Offset();
//    std::shared_ptr<StyleRuleBase> rule = nullptr;
//    switch (stream.UncheckedPeek().GetType()) {
//      // NOTE: 空白
//      case kWhitespaceToken:
//        stream.UncheckedConsume();
//        continue;
//      // NOTE: @ 规范
//      case kAtKeywordToken:
//        rule = ConsumeAtRule(stream, allowed_rules, nesting_type, parent_rule_for_nesting);
//        break;
//      // NOTE: <!--
//      case kCDOToken:
//      // NOTE: -->
//      case kCDCToken:
//        if (rule_list_type == kTopLevelRuleList) {
//          stream.UncheckedConsume();
//          continue;
//        }
//        [[fallthrough]];
//      default:
//        // NOTE: 其他规则
//        rule = ConsumeQualifiedRule(stream, allowed_rules, nesting_type, parent_rule_for_nesting);
//        break;
//    }
//    if (!seen_rule) {
//      seen_rule = true;
//      first_rule_valid = (rule != nullptr);
//    }
//    if (rule) {
//      allowed_rules = ComputeNewAllowedRules(allowed_rules, rule);
//      callback(rule, offset);
//    }
//    assert(stream.Offset() > offset);
//  }
//
//  return first_rule_valid;
//}

// TODO: 当前进度[ConsumeStyleRule]
//std::shared_ptr<StyleRuleBase> CSSParserImpl::ConsumeQualifiedRule(CSSParserTokenStream& stream,
//                                                                   AllowedRulesType allowed_rules,
//                                                                   CSSNestingType nesting_type,
//                                                                   std::shared_ptr<StyleRule> parent_rule_for_nesting) {
//  if (allowed_rules <= kRegularRules) {
//    return ConsumeStyleRule(stream, nesting_type, parent_rule_for_nesting,
//                            /* semicolon_aborts_nested_selector */ false);
//  }
//
//  // TODO(xiezuobing): 关键帧动画处理
//  //  if (allowed_rules == kKeyframeRules) {
//  //    stream.EnsureLookAhead();
//  //    const uint32_t prelude_offset_start = stream.LookAheadOffset();
//  //    const CSSParserTokenRange prelude =
//  //        stream.ConsumeUntilPeekedTypeIs<kLeftBraceToken>();
//  //    const RangeOffset prelude_offset(prelude_offset_start,
//  //                                     stream.LookAheadOffset());
//  //
//  //    if (stream.AtEnd()) {
//  //      return nullptr;  // Parse error, EOF instead of qualified rule block
//  //    }
//  //
//  //    CSSParserTokenStream::BlockGuard guard(stream);
//  //    // TODO(xiezuobing): 消费关键帧
//  //    return ConsumeKeyframeStyleRule(prelude, prelude_offset, stream);
//  //  }
//
//  assert_m(false, "NOTREACHED_IN_MIGRATION");
//  //  NOTREACHED_IN_MIGRATION();
//  return nullptr;
//}

//std::shared_ptr<StyleRuleKeyframe> CSSParserImpl::ConsumeKeyframeStyleRule(
//    webf::CSSParserTokenRange prelude,
//    const webf::CSSParserImpl::RangeOffset& prelude_offset,
//    webf::CSSParserTokenStream& block) {
//  return nullptr;
//}

//std::shared_ptr<StyleRuleBase> CSSParserImpl::ConsumeAtRule(CSSParserTokenStream& stream,
//                                                            AllowedRulesType allowed_rules,
//                                                            CSSNestingType nesting_type,
//                                                            std::shared_ptr<StyleRule> parent_rule_for_nesting) {
//  assert(stream.Peek().GetType() == kAtKeywordToken);
//  CSSParserToken name_token = stream.ConsumeIncludingWhitespace();  // Must live until CssAtRuleID().
//  const StringView name = name_token.Value();
//  const CSSAtRuleID id = CssAtRuleID(name);
//  return ConsumeAtRuleContents(id, stream, allowed_rules, nesting_type, parent_rule_for_nesting);
//}

//std::shared_ptr<StyleRuleBase> CSSParserImpl::ConsumeAtRuleContents(
//    CSSAtRuleID id,
//    CSSParserTokenStream& stream,
//    AllowedRulesType allowed_rules,
//    CSSNestingType nesting_type,
//    std::shared_ptr<StyleRule> parent_rule_for_nesting) {
//  if (allowed_rules == kNestedGroupRules) {
//    if (id != CSSAtRuleID::kCSSAtRuleMedia &&      // [css-conditional-3]
//        id != CSSAtRuleID::kCSSAtRuleSupports &&   // [css-conditional-3]
//        id != CSSAtRuleID::kCSSAtRuleContainer &&  // [css-contain-3]
//        id != CSSAtRuleID::kCSSAtRuleLayer &&      // [css-cascade-5]
//        id != CSSAtRuleID::kCSSAtRuleScope &&      // [css-cascade-6]
//        id != CSSAtRuleID::kCSSAtRuleStartingStyle && id != CSSAtRuleID::kCSSAtRuleViewTransition &&
//        (id < CSSAtRuleID::kCSSAtRuleTopLeftCorner || id > CSSAtRuleID::kCSSAtRuleRightBottom)) {
//      ConsumeErroneousAtRule(stream, id);
//      return nullptr;
//    }
//    allowed_rules = kRegularRules;
//  }
//
//  ExecutingContext* executingContext = GetContext()->GetExecutingContext();
//
//  // @import rules have a URI component that is not technically part of the
//  // prelude.
//  // NOTE: @import 中的[URL]
//  AtomicString import_prelude_uri;
//  if (allowed_rules <= kAllowImportRules && id == CSSAtRuleID::kCSSAtRuleImport) {
//    import_prelude_uri = ConsumeStringOrURI(stream, executingContext);
//  }
//
//  // NOTE: @keyframes
//  if (allowed_rules == kKeyframeRules || allowed_rules == kNoRules) {
//    // Parse error, no at-rules supported inside @keyframes,
//    // or blocks supported inside declaration lists.
//    ConsumeErroneousAtRule(stream, id);
//    return nullptr;
//  }
//
//  stream.EnsureLookAhead();
//  // TODO: @charset
//  if (allowed_rules == kAllowCharsetRules && id == CSSAtRuleID::kCSSAtRuleCharset) {
//    //    return ConsumeCharsetRule(stream);
//  }
//  // TODO: @import
//  else if (allowed_rules <= kAllowImportRules && id == CSSAtRuleID::kCSSAtRuleImport) {
//    //    return ConsumeImportRule(std::move(import_prelude_uri), stream);
//  } else {
//    assert(allowed_rules <= kRegularRules);
//
//    switch (id) {
//        //      TODO(xiezuobing): @media
//        //      case CSSAtRuleID::kCSSAtRuleMedia:
//        //        return ConsumeMediaRule(stream, nesting_type, parent_rule_for_nesting);
//        //      TODO(xiezuobing): @supports
//        //      case CSSAtRuleID::kCSSAtRuleSupports:
//        //        return ConsumeSupportsRule(stream, nesting_type,
//        //                                   parent_rule_for_nesting);
//        //      TODO(xiezuobing): @font-face
//        //      case CSSAtRuleID::kCSSAtRuleFontFace:
//        //        return ConsumeFontFaceRule(stream);
//        //      TODO(xiezuobing): @--webkit-keyframes 草案
//        //      case CSSAtRuleID::kCSSAtRuleWebkitKeyframes:
//        //        return ConsumeKeyframesRule(true, stream);
//        //      TODO(xiezuobing): @keyframes
//        //      case CSSAtRuleID::kCSSAtRuleKeyframes:
//        //        return ConsumeKeyframesRule(false, stream);
//      case CSSAtRuleID::kCSSAtRuleInvalid:
//      case CSSAtRuleID::kCSSAtRuleCharset:
//      case CSSAtRuleID::kCSSAtRuleImport:
//      case CSSAtRuleID::kCSSAtRuleNamespace:
//      case CSSAtRuleID::kCSSAtRuleStylistic:
//      case CSSAtRuleID::kCSSAtRuleStyleset:
//      case CSSAtRuleID::kCSSAtRuleCharacterVariant:
//      case CSSAtRuleID::kCSSAtRuleSwash:
//      case CSSAtRuleID::kCSSAtRuleOrnaments:
//      case CSSAtRuleID::kCSSAtRuleAnnotation:
//      case CSSAtRuleID::kCSSAtRuleTopLeftCorner:
//      case CSSAtRuleID::kCSSAtRuleTopLeft:
//      case CSSAtRuleID::kCSSAtRuleTopCenter:
//      case CSSAtRuleID::kCSSAtRuleTopRight:
//      case CSSAtRuleID::kCSSAtRuleTopRightCorner:
//      case CSSAtRuleID::kCSSAtRuleBottomLeftCorner:
//      case CSSAtRuleID::kCSSAtRuleBottomLeft:
//      case CSSAtRuleID::kCSSAtRuleBottomCenter:
//      case CSSAtRuleID::kCSSAtRuleBottomRight:
//      case CSSAtRuleID::kCSSAtRuleBottomRightCorner:
//      case CSSAtRuleID::kCSSAtRuleLeftTop:
//      case CSSAtRuleID::kCSSAtRuleLeftMiddle:
//      case CSSAtRuleID::kCSSAtRuleLeftBottom:
//      case CSSAtRuleID::kCSSAtRuleRightTop:
//      case CSSAtRuleID::kCSSAtRuleRightMiddle:
//      case CSSAtRuleID::kCSSAtRuleRightBottom:
//        ConsumeErroneousAtRule(stream, id);
//        return nullptr;  // Parse error, unrecognised or not-allowed at-rule
//    }
//  }
//}
//
//CSSParserTokenRange ConsumeAtRulePrelude(CSSParserTokenStream& stream) {
//  return stream.ConsumeUntilPeekedTypeIs<kLeftBraceToken, kSemicolonToken>();
//}
//
//void CSSParserImpl::ConsumeErroneousAtRule(CSSParserTokenStream& stream, CSSAtRuleID id) {
//  //  TODO(xiezuobing): [inspect] 暂时不实现
//  //  if (observer_) {
//  //    observer_->ObserveErroneousAtRule(stream.Offset(), id);
//  //  }
//  // Consume the prelude and block if present.
//  ConsumeAtRulePrelude(stream);
//  if (!stream.AtEnd()) {
//    if (stream.UncheckedPeek().GetType() == kLeftBraceToken) {
//      CSSParserTokenStream::BlockGuard guard(stream);
//    } else {
//      stream.UncheckedConsume();  // kSemicolonToken
//    }
//  }
//}
//
//// This may still consume tokens if it fails
//static AtomicString ConsumeStringOrURI(CSSParserTokenRange& range, ExecutingContext* executingContext) {
//  const CSSParserToken& token = range.Peek();
//
//  if (token.GetType() == kStringToken || token.GetType() == kUrlToken) {
//    // TODO(xiezuobing): ToAtomicString 确认强类型转换风险
//    return range.ConsumeIncludingWhitespace().Value().ToAtomicString(executingContext->ctx());
//  }
//
//  if (token.GetType() != kFunctionToken || !EqualIgnoringASCIICase(token.Value(), StringView("url"))) {
//    return AtomicString();
//  }
//
//  CSSParserTokenRange contents = range.ConsumeBlock();
//  const CSSParserToken& uri = contents.ConsumeIncludingWhitespace();
//  if (uri.GetType() == kBadStringToken || !contents.AtEnd()) {
//    return AtomicString();
//  }
//  assert(uri.GetType() == kStringToken);
//  return uri.Value().ToAtomicString(executingContext->ctx());
//}
//
//std::shared_ptr<StyleRule> CSSParserImpl::ConsumeStyleRule(CSSParserTokenStream& stream,
//                                                           CSSNestingType nesting_type,
//                                                           std::shared_ptr<StyleRule> parent_rule_for_nesting,
//                                                           bool semicolon_aborts_nested_selector) {
//  if (!in_nested_style_rule_) {
//    assert(0u == arena_.size());
//  }
//  auto func_clear_arena = [&](std::vector<CSSSelector>* arena) {
//    if (!in_nested_style_rule_) {
//      arena->resize(0);  // See class comment on CSSSelectorParser.
//    }
//  };
//  std::unique_ptr<std::vector<CSSSelector>, decltype(func_clear_arena)> scope_guard(&arena_,
//                                                                                    std::move(func_clear_arena));
//  //  TODO: [inspect] 暂时不实现
//  //  if (observer_) {
//  //    observer_->StartRuleHeader(StyleRule::kStyle, stream.LookAheadOffset());
//  //  }
//
//  // Style rules that look like custom property declarations
//  // are not allowed by css-syntax.
//  //
//  // https://drafts.csswg.org/css-syntax/#consume-qualified-rule
//  bool custom_property_ambiguity = false;
//  if (CSSVariableParser::IsValidVariableName(stream.Peek())) {
//    CSSParserTokenStream::State state = stream.Save();
//    stream.ConsumeIncludingWhitespace();  // <ident>
//    custom_property_ambiguity = stream.Peek().GetType() == kColonToken;
//    stream.Restore(state);
//  }
//
//  // Parse the prelude of the style rule
//  std::span<CSSSelector> selector_vector =
//      CSSSelectorParser::ConsumeSelector(stream, context_, nesting_type, parent_rule_for_nesting, is_within_scope_,
//                                         semicolon_aborts_nested_selector, style_sheet_, observer_, arena_);
//
//  if (selector_vector.empty()) {
//    // Read the rest of the prelude if there was an error
//    stream.EnsureLookAhead();
//    while (!stream.UncheckedAtEnd() && stream.UncheckedPeek().GetType() != kLeftBraceToken &&
//           !AbortsNestedSelectorParsing(stream.UncheckedPeek().GetType(), semicolon_aborts_nested_selector,
//                                        nesting_type)) {
//      stream.UncheckedConsumeComponentValue();
//    }
//  }
//
//  //  TODO: [inspect]
//  //  if (observer_) {
//  //    observer_->EndRuleHeader(stream.LookAheadOffset());
//  //  }
//
//  if (stream.AtEnd() ||
//      AbortsNestedSelectorParsing(stream.UncheckedPeek().GetType(), semicolon_aborts_nested_selector, nesting_type)) {
//    // Parse error, EOF instead of qualified rule block
//    // (or we went into error recovery above).
//    // NOTE: If we aborted due to a semicolon, don't consume it here;
//    // the caller will do that for us.
//    return nullptr;
//  }
//
//  assert(stream.Peek().GetType() == kLeftBraceToken);
//  //  TODO: CSS Lazy Loading，之后优化补全
//  //  RuntimeEnabledFeatures::CSSLazyParsingFastPathEnabled()
//  bool is_css_lazy_parsing_fast_path_enabled_ = false;
//
//  if (is_css_lazy_parsing_fast_path_enabled_) {
//    //    if (selector_vector.empty() || custom_property_ambiguity) {
//    //      // Parse error, invalid selector list or ambiguous custom property.
//    //      CSSParserTokenStream::BlockGuard guard(stream);
//    //      return nullptr;
//    //    }
//    //
//    //    // TODO(csharrison): How should we lazily parse css that needs the observer?
//    //    if (!observer_ && lazy_state_) {
//    //      assert(style_sheet_);
//    //
//    //      uint32_t len = static_cast<uint32_t>(
//    //          FindLengthOfDeclarationList(StringView(stream.RemainingText(), 1)));
//    //      if (len != 0) {
//    //        uint32_t block_start_offset = stream.Offset();
//    //        stream.SkipToEndOfBlock(len + 2);  // +2 for { and }.
//    //        return StyleRule::Create(
//    //            selector_vector, MakeGarbageCollected<CSSLazyPropertyParserImpl>(
//    //                                 block_start_offset, lazy_state_));
//    //      }
//    //    }
//    //    CSSParserTokenStream::BlockGuard guard(stream);
//    //    return ConsumeStyleRuleContents(selector_vector, stream);
//  } else {
//    CSSParserTokenStream::BlockGuard guard(stream);
//
//    if (selector_vector.empty()) {
//      // Parse error, invalid selector list.
//      return nullptr;
//    }
//    if (custom_property_ambiguity) {
//      return nullptr;
//    }
//
//    // TODO(csharrison): How should we lazily parse css that needs the observer?
//    if (!observer_ && lazy_state_) {
//      assert(style_sheet_);
//
//      uint32_t block_start_offset = stream.Offset() - 1;  // - 1 for the {.
//      guard.SkipToEndOfBlock();
//      uint32_t block_length = stream.Offset() - block_start_offset;
//
//      // Lazy parsing cannot deal with nested rules. We make a very quick check
//      // to see if there could possibly be any in there; if so, we need to go
//      // back to normal (non-lazy) parsing. If that happens, we've wasted some
//      // work; specifically, the SkipToEndOfBlock(), and potentially that we
//      // cannot use the CachedCSSTokenizer if that would otherwise be in use.
//      // TODO(xiezuobing): 嵌套规则，这里先不考虑哈
//      // Example: .outer { .inner { ... } }
//      //      if (MayContainNestedRules(lazy_state_->SheetText(), block_start_offset,
//      //                                block_length)) {
//      //        CSSTokenizer tokenizer(lazy_state_->SheetText(), block_start_offset);
//      //        CSSParserTokenStream block_stream(tokenizer);
//      //        CSSParserTokenStream::BlockGuard sub_guard(
//      //            block_stream);  // Consume the {, and open the block stack.
//      //        return ConsumeStyleRuleContents(selector_vector, block_stream);
//      //      }
//
//      return StyleRule::Create(selector_vector,
//                               std::make_shared<CSSLazyPropertyParserImpl>(block_start_offset, lazy_state_));
//    }
//    return ConsumeStyleRuleContents(selector_vector, stream);
//  }
//}
//
////
// static ImmutableCSSPropertyValueSet* CreateCSSPropertyValueSet(
//    std::vector<CSSPropertyValue>& parsed_properties,
//    CSSParserMode mode,
//    const Document* document) {
//  if (mode != kHTMLQuirksMode &&
//      (parsed_properties.size() < 2 ||
//       (parsed_properties.size() == 2 &&
//        parsed_properties[0].Id() != parsed_properties[1].Id()))) {
//    // Fast path for the situations where we can trivially detect that there can
//    // be no collision between properties, and don't need to reorder, make
//    // bitsets, or similar.
//    ImmutableCSSPropertyValueSet* result = ImmutableCSSPropertyValueSet::Create(
//        parsed_properties.data(), parsed_properties.size(), mode);
//    parsed_properties.clear();
//    return result;
//  }
//
//  std::bitset<kNumCSSProperties> seen_properties;
//  uint32_t unused_entries = parsed_properties.size();
//  std::vector<CSSPropertyValue> results(unused_entries);
//  std::unordered_set<AtomicString> seen_custom_properties;
//
//  FilterProperties(true, parsed_properties, results, unused_entries,
//                   seen_properties, seen_custom_properties);
//  FilterProperties(false, parsed_properties, results, unused_entries,
//                   seen_properties, seen_custom_properties);
//
//  bool count_cursor_hand = false;
//  if (document && mode == kHTMLQuirksMode &&
//      seen_properties.test(GetCSSPropertyIDIndex(CSSPropertyID::kCursor))) {
//    // See if the properties contain “cursor: hand” without also containing
//    // “cursor: pointer”. This is a reasonable approximation for whether
//    // removing support for the former would actually matter. (Of course,
//    // we don't check whether “cursor: hand” could lose in the cascade
//    // due to properties coming from other declarations, but that would be
//    // much more complicated)
//    bool contains_cursor_hand = false;
//    bool contains_cursor_pointer = false;
//    for (const CSSPropertyValue& property : parsed_properties) {
//      const CSSIdentifierValue* value =
//          DynamicTo<CSSIdentifierValue>(property.Value());
//      if (value) {
//        if (value->WasQuirky()) {
//          contains_cursor_hand = true;
//        } else if (value->GetValueID() == CSSValueID::kPointer) {
//          contains_cursor_pointer = true;
//        }
//      }
//    }
//    if (contains_cursor_hand && !contains_cursor_pointer) {
//      document->CountUse(WebFeature::kQuirksModeCursorHand);
//      count_cursor_hand = true;
//    }
//  }
//
//  ImmutableCSSPropertyValueSet* result = ImmutableCSSPropertyValueSet::Create(
//      results.data() + unused_entries, results.size() - unused_entries, mode,
//      count_cursor_hand);
//  parsed_properties.clear();
//  return result;
//}
//
//std::shared_ptr<StyleRule> CSSParserImpl::ConsumeStyleRuleContents(std::span<CSSSelector> selector_vector,
//                                                                   CSSParserTokenStream& stream) {
//  std::shared_ptr<StyleRule> style_rule = StyleRule::Create(selector_vector);
//  std::vector<Member<StyleRuleBase>> child_rules;
//  // TODO(xiezuobing): ConsumeDeclarationList
//  //  ConsumeDeclarationList(stream, StyleRule::kStyle, CSSNestingType::kNesting,
//  //                         /*parent_rule_for_nesting=*/style_rule, &child_rules);
//  for (StyleRuleBase* child_rule : child_rules) {
//    style_rule->AddChildRule(child_rule);
//  }
//  // TODO(xiezuobing): CreateCSSPropertyValueSet
//  //  style_rule->SetProperties(CreateCSSPropertyValueSet(
//  //      parsed_properties_, context_->Mode(), context_->GetDocument()));
//  return style_rule;
//}
//
}  // namespace webf
