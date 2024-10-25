// Copyright 2014 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "css_selector_parser.h"

#include <algorithm>
#include <cctype>
#include <memory>
#include <optional>
#include <span>
#include <string>
#include "core/base/strings/string_number_conversions.h"
#include "core/css/css_selector.h"
#include "core/css/css_selector_list.h"
#include "core/css/parser/css_nesting_type.h"
#include "core/css/parser/css_parser_context.h"
#include "core/css/parser/css_parser_observer.h"
#include "core/css/parser/css_parser_token.h"
#include "core/css/parser/css_parser_token_stream.h"
#include "core/css/style_sheet_contents.h"
#include "core/dom/document.h"
#include "core/base/auto_reset.h"
#include "core/css/parser/css_parser_context.h"
#include "core/css/parser/css_parser_save_point.h"
#include "core/css/style_engine.h"
#include "core/executing_context.h"
#include "core/style/computed_style_constants.h"

// TODO(xiezuobing):
namespace webf {

namespace {

CSSParserTokenRange ConsumeNestedArgument(CSSParserTokenRange& range) {
  const CSSParserToken& first = range.Peek();
  while (!range.AtEnd() && range.Peek().GetType() != kCommaToken) {
    const CSSParserToken& token = range.Peek();
    if (token.GetBlockType() == CSSParserToken::kBlockStart) {
      range.ConsumeBlock();
      continue;
    }
    range.Consume();
  }
  return range.MakeSubRange(&first, &range.Peek());
}

bool AtEndIgnoringWhitespace(CSSParserTokenStream& stream) {
  stream.EnsureLookAhead();
  CSSParserSavePoint savepoint(stream);
  stream.ConsumeWhitespace();
  return stream.AtEnd();
}

bool IsHostPseudoSelector(const CSSSelector& selector) {
  return selector.GetPseudoType() == CSSSelector::kPseudoHost ||
         selector.GetPseudoType() == CSSSelector::kPseudoHostContext;
}

// Some pseudo elements behave as if they have an implicit combinator to their
// left even though they are written without one. This method returns the
// correct implicit combinator. If no new combinator should be used,
// it returns RelationType::kSubSelector.
CSSSelector::RelationType GetImplicitShadowCombinatorForMatching(CSSSelector::PseudoType pseudo_type) {
  switch (pseudo_type) {
    case CSSSelector::PseudoType::kPseudoSlotted:
      return CSSSelector::RelationType::kShadowSlot;
    case CSSSelector::PseudoType::kPseudoWebKitCustomElement:
    case CSSSelector::PseudoType::kPseudoBlinkInternalElement:
    case CSSSelector::PseudoType::kPseudoCue:
    case CSSSelector::PseudoType::kPseudoDetailsContent:
    case CSSSelector::PseudoType::kPseudoPlaceholder:
    case CSSSelector::PseudoType::kPseudoFileSelectorButton:
    case CSSSelector::PseudoType::kPseudoSelectFallbackButton:
    case CSSSelector::PseudoType::kPseudoSelectFallbackButtonText:
    case CSSSelector::PseudoType::kPseudoSelectFallbackDatalist:
      return CSSSelector::RelationType::kUAShadow;
    case CSSSelector::PseudoType::kPseudoPart:
      return CSSSelector::RelationType::kShadowPart;
    default:
      return CSSSelector::RelationType::kSubSelector;
  }
}

bool NeedsImplicitShadowCombinatorForMatching(const CSSSelector& selector) {
  return GetImplicitShadowCombinatorForMatching(selector.GetPseudoType()) != CSSSelector::RelationType::kSubSelector;
}

// Marks the end of parsing a complex selector. (In many cases, there may
// be more complex selectors after this, since we are often dealing with
// lists of complex selectors. Those are marked using SetLastInSelectorList(),
// which happens in CSSSelectorList::AdoptSelectorVector.)
void MarkAsEntireComplexSelector(tcb::span<CSSSelector> selectors) {
  selectors.back().SetLastInComplexSelector(true);
}

}  // namespace

// static
tcb::span<CSSSelector> CSSSelectorParser::ParseSelector(CSSParserTokenStream& stream,
                                                        std::shared_ptr<const CSSParserContext> context,
                                                        CSSNestingType nesting_type,
                                                        std::shared_ptr<const StyleRule> parent_rule_for_nesting,
                                                        bool is_within_scope,
                                                        bool semicolon_aborts_nested_selector,
                                                        std::shared_ptr<StyleSheetContents> style_sheet,
                                                        std::vector<CSSSelector>& arena) {
  CSSSelectorParser parser(std::move(context), std::move(parent_rule_for_nesting), is_within_scope,
                           semicolon_aborts_nested_selector, std::move(style_sheet), arena);
  stream.ConsumeWhitespace();
  tcb::span<CSSSelector> result = parser.ConsumeComplexSelectorList(stream, nesting_type);
  if (!stream.AtEnd()) {
    return {};
  }

  return result;
}

// static
tcb::span<CSSSelector> CSSSelectorParser::ConsumeSelector(CSSParserTokenStream& stream,
                                                          std::shared_ptr<const CSSParserContext> context,
                                                          CSSNestingType nesting_type,
                                                          std::shared_ptr<const StyleRule> parent_rule_for_nesting,
                                                          bool is_within_scope,
                                                          bool semicolon_aborts_nested_selector,
                                                          std::shared_ptr<StyleSheetContents> style_sheet,
                                                          std::shared_ptr<CSSParserObserver> observer,
                                                          std::vector<CSSSelector>& arena) {
  CSSSelectorParser parser(context, parent_rule_for_nesting, is_within_scope, semicolon_aborts_nested_selector,
                           style_sheet, arena);
  stream.ConsumeWhitespace();
  tcb::span<CSSSelector> result = parser.ConsumeComplexSelectorList(stream, observer, nesting_type);
  return result;
}

bool CSSSelectorParser::ConsumeANPlusB(CSSParserTokenStream& stream, std::pair<int, int>& result) {
  if (stream.AtEnd()) {
    return false;
  }

  const CSSParserToken& token = stream.Consume();
  if (token.GetType() == kNumberToken && token.GetNumericValueType() == kIntegerValueType) {
    result = std::make_pair(0, ClampTo<int>(token.NumericValue()));
    return true;
  }
  if (token.GetType() == kIdentToken) {
    if (EqualIgnoringASCIICase(token.Value(), "odd")) {
      result = std::make_pair(2, 1);
      return true;
    }
    if (EqualIgnoringASCIICase(token.Value(), "even")) {
      result = std::make_pair(2, 0);
      return true;
    }
  }

  // The 'n' will end up as part of an ident or dimension. For a valid <an+b>,
  // this will store a string of the form 'n', 'n-', or 'n-123'.
  std::string n_string;

  if (token.GetType() == kDelimiterToken && token.Delimiter() == '+' && stream.Peek().GetType() == kIdentToken) {
    result.first = 1;
    n_string = stream.Consume().Value();
  } else if (token.GetType() == kDimensionToken && token.GetNumericValueType() == kIntegerValueType) {
    result.first = ClampTo<int>(token.NumericValue());
    n_string = token.Value();
  } else if (token.GetType() == kIdentToken) {
    if (token.Value()[0] == '-') {
      result.first = -1;
      n_string = token.Value().substr(1);
    } else {
      result.first = 1;
      n_string = token.Value();
    }
  }

  stream.ConsumeWhitespace();

  if (n_string.empty() || !IsASCIIAlphaCaselessEqual(n_string[0], 'n')) {
    return false;
  }
  if (n_string.length() > 1 && n_string[1] != '-') {
    return false;
  }

  if (n_string.length() > 2) {
    bool valid;
    int output;
    valid = base::StringToInt(n_string.substr(1), &output);
    result.second = output;
    return valid;
  }

  NumericSign sign = n_string.length() == 1 ? kNoSign : kMinusSign;
  if (sign == kNoSign && stream.Peek().GetType() == kDelimiterToken) {
    char delimiter_sign = stream.ConsumeIncludingWhitespace().Delimiter();
    if (delimiter_sign == '+') {
      sign = kPlusSign;
    } else if (delimiter_sign == '-') {
      sign = kMinusSign;
    } else {
      return false;
    }
  }

  if (sign == kNoSign && stream.Peek().GetType() != kNumberToken) {
    result.second = 0;
    return true;
  }

  const CSSParserToken& b = stream.Consume();
  if (b.GetType() != kNumberToken || b.GetNumericValueType() != kIntegerValueType) {
    return false;
  }
  if ((b.GetNumericSign() == kNoSign) == (sign == kNoSign)) {
    return false;
  }
  result.second = ClampTo<int>(b.NumericValue());
  if (sign == kMinusSign) {
    // Negating minimum integer returns itself, instead return max integer.
    if (result.second == std::numeric_limits<int>::min()) [[unlikely]] {
      result.second = std::numeric_limits<int>::max();
    } else {
      result.second = -result.second;
    }
  }
  return true;
}

// Consumes the “of ...” part of :nth_child(An+B of ...).
// Returns nullptr on failure.
std::shared_ptr<const CSSSelectorList> CSSSelectorParser::ConsumeNthChildOfSelectors(CSSParserTokenStream& stream) {
  if (stream.Peek().GetType() != kIdentToken || stream.Consume().Value() != "of") {
    return nullptr;
  }
  stream.ConsumeWhitespace();

  ResetVectorAfterScope reset_vector(output_);
  tcb::span<CSSSelector> selectors = ConsumeComplexSelectorList(stream, CSSNestingType::kNone);
  if (selectors.empty()) {
    return nullptr;
  }
  return CSSSelectorList::AdoptSelectorVector(selectors);
}

// static
// std::optional<tcb::span<CSSSelector>> CSSSelectorParser::ParseScopeBoundary(
//    CSSParserTokenStream& stream,
//    std::shared_ptr<const CSSParserContext> context,
//    CSSNestingType nesting_type,
//    std::shared_ptr<const StyleRule> parent_rule_for_nesting,
//    bool is_within_scope,
//    std::shared_ptr<StyleSheetContents> style_sheet,
//    std::vector<CSSSelector>& arena) {
//  CSSSelectorParser parser(std::move(context), parent_rule_for_nesting, is_within_scope,
//                           /*semicolon_aborts_nested_selector=*/false,
//                           std::move(style_sheet), arena);
//  DisallowPseudoElementsScope disallow_pseudo_elements(&parser);
//
//  stream.ConsumeWhitespace();
//  std::optional<tcb::span<CSSSelector>> result =
//      parser.ConsumeForgivingComplexSelectorList(stream, nesting_type);
//  assert(result.has_value());
//  if (!stream.AtEnd()) {
//    return std::nullopt;
//  }
//  return result;
//}

// static
bool CSSSelectorParser::SupportsComplexSelector(CSSParserTokenStream& stream,
                                                std::shared_ptr<const CSSParserContext> context) {
  stream.ConsumeWhitespace();
  std::vector<CSSSelector> arena;
  CSSSelectorParser parser(context, /*parent_rule_for_nesting=*/nullptr, /*is_within_scope=*/false,
                           /*semicolon_aborts_nested_selector=*/false, nullptr, arena);
  parser.SetInSupportsParsing();
  tcb::span<CSSSelector> selectors = parser.ConsumeComplexSelector(stream, CSSNestingType::kNone,
                                                                   /*first_in_complex_selector_list=*/true);
  if (parser.failed_parsing_ || !stream.AtEnd() || selectors.empty()) {
    return false;
  }
  return true;
}

CSSSelectorParser::CSSSelectorParser(std::shared_ptr<const CSSParserContext> context,
                                     std::shared_ptr<const StyleRule> parent_rule_for_nesting,
                                     bool is_within_scope,
                                     bool semicolon_aborts_nested_selector,
                                     std::shared_ptr<StyleSheetContents> style_sheet,
                                     std::vector<CSSSelector>& output)
    : context_(std::move(context)),
      parent_rule_for_nesting_(std::move(parent_rule_for_nesting)),
      is_within_scope_(is_within_scope),
      semicolon_aborts_nested_selector_(semicolon_aborts_nested_selector),
      style_sheet_(style_sheet),
      output_(output) {}

static bool AtEndOfComplexSelector(CSSParserTokenStream& stream) {
  const CSSParserToken& token = stream.Peek();
  return stream.AtEnd() || token.GetType() == kLeftBraceToken || token.GetType() == kCommaToken;
}

tcb::span<CSSSelector> CSSSelectorParser::ConsumeComplexSelectorList(CSSParserTokenStream& stream,
                                                                     CSSNestingType nesting_type) {
  ResetVectorAfterScope reset_vector(output_);
  if (ConsumeComplexSelector(stream, nesting_type,
                             /*first_in_complex_selector_list=*/true)
          .empty()) {
    return {};
  }
  while (!stream.AtEnd() && stream.Peek().GetType() == kCommaToken) {
    stream.ConsumeIncludingWhitespace();
    if (ConsumeComplexSelector(stream, nesting_type,
                               /*first_in_complex_selector_list=*/false)
            .empty()) {
      return {};
    }
  }

  if (failed_parsing_) {
    return {};
  }

  return reset_vector.CommitAddedElements();
}

tcb::span<CSSSelector> CSSSelectorParser::ConsumeComplexSelectorList(CSSParserTokenStream& stream,
                                                                     std::shared_ptr<CSSParserObserver> observer,
                                                                     CSSNestingType nesting_type) {
  ResetVectorAfterScope reset_vector(output_);

  bool first_in_complex_selector_list = true;
  while (true) {
    const uint32_t selector_offset_start = stream.LookAheadOffset();

    if (ConsumeComplexSelector(stream, nesting_type, first_in_complex_selector_list).empty() || failed_parsing_ ||
        !AtEndOfComplexSelector(stream)) {
      if (AbortsNestedSelectorParsing(kSemicolonToken, semicolon_aborts_nested_selector_, nesting_type)) {
        stream.SkipUntilPeekedTypeIs<kLeftBraceToken, kCommaToken, kSemicolonToken>();
      } else {
        stream.SkipUntilPeekedTypeIs<kLeftBraceToken, kCommaToken>();
      }
      return {};
    }
    const uint32_t selector_offset_end = stream.LookAheadOffset();
    first_in_complex_selector_list = false;

    if (observer) {
      observer->ObserveSelector(selector_offset_start, selector_offset_end);
    }

    if (stream.UncheckedAtEnd()) {
      break;
    }

    if (stream.Peek().GetType() == kLeftBraceToken ||
        AbortsNestedSelectorParsing(stream.Peek().GetType(), semicolon_aborts_nested_selector_, nesting_type)) {
      break;
    }

    assert(stream.Peek().GetType() == kCommaToken);
    stream.ConsumeIncludingWhitespace();
  }

  return reset_vector.CommitAddedElements();
}

std::shared_ptr<CSSSelectorList> CSSSelectorParser::ConsumeCompoundSelectorList(CSSParserTokenStream& stream) {
  ResetVectorAfterScope reset_vector(output_);

  tcb::span<CSSSelector> selector = ConsumeCompoundSelector(stream, CSSNestingType::kNone);
  stream.ConsumeWhitespace();
  if (selector.empty()) {
    return nullptr;
  }
  MarkAsEntireComplexSelector(selector);
  while (!stream.AtEnd() && stream.Peek().GetType() == kCommaToken) {
    stream.ConsumeIncludingWhitespace();
    selector = ConsumeCompoundSelector(stream, CSSNestingType::kNone);
    stream.ConsumeWhitespace();
    if (selector.empty()) {
      return nullptr;
    }
    MarkAsEntireComplexSelector(selector);
  }

  if (failed_parsing_) {
    return nullptr;
  }

  return CSSSelectorList::AdoptSelectorVector(reset_vector.AddedElements());
}

std::shared_ptr<CSSSelectorList> CSSSelectorParser::ConsumeNestedSelectorList(CSSParserTokenStream& stream) {
  if (inside_compound_pseudo_) {
    return ConsumeCompoundSelectorList(stream);
  }

  ResetVectorAfterScope reset_vector(output_);
  tcb::span<CSSSelector> result = ConsumeComplexSelectorList(stream, CSSNestingType::kNone);
  if (result.empty()) {
    return {};
  } else {
    std::shared_ptr<CSSSelectorList> selector_list = CSSSelectorList::AdoptSelectorVector(result);
    return selector_list;
  }
}

std::shared_ptr<CSSSelectorList> CSSSelectorParser::ConsumeForgivingNestedSelectorList(CSSParserTokenStream& stream) {
  if (inside_compound_pseudo_) {
    return ConsumeForgivingCompoundSelectorList(stream);
  }
  ResetVectorAfterScope reset_vector(output_);
  std::optional<tcb::span<CSSSelector>> forgiving_list =
      ConsumeForgivingComplexSelectorList(stream, CSSNestingType::kNone);
  if (!forgiving_list.has_value()) {
    return nullptr;
  }
  return CSSSelectorList::AdoptSelectorVector(forgiving_list.value());
}

// CSSSelectorList* CSSSelectorParser::ConsumeForgivingNestedSelectorList(
//     CSSParserTokenStream& stream) {
//   if (inside_compound_pseudo_) {
//     return ConsumeForgivingCompoundSelectorList(stream);
//   }
//   ResetVectorAfterScope reset_vector(output_);
//   std::optional<tcb::span<CSSSelector>> forgiving_list =
//       ConsumeForgivingComplexSelectorList(stream, CSSNestingType::kNone);
//   if (!forgiving_list.has_value()) {
//     return nullptr;
//   }
//   return CSSSelectorList::AdoptSelectorVector(forgiving_list.value());
// }

std::optional<tcb::span<CSSSelector>> CSSSelectorParser::ConsumeForgivingComplexSelectorList(
    CSSParserTokenStream& stream,
    CSSNestingType nesting_type) {
  if (in_supports_parsing_) {
    tcb::span<CSSSelector> selectors = ConsumeComplexSelectorList(stream, nesting_type);
    if (selectors.empty()) {
      return std::nullopt;
    } else {
      return selectors;
    }
  }

  ResetVectorAfterScope reset_vector(output_);

  bool first_in_complex_selector_list = true;
  while (!stream.AtEnd()) {
    webf::AutoReset<bool> reset_failure(&failed_parsing_, false);
    CSSParserTokenStream::State state = stream.Save();
    uint32_t subpos = output_.size();
    tcb::span<CSSSelector> selector = ConsumeComplexSelector(stream, nesting_type, first_in_complex_selector_list);
    if (selector.empty() || failed_parsing_ || !AtEndOfComplexSelector(stream)) {
      output_.resize(subpos);  // Drop what we parsed so far.
      stream.Restore(state);
      AddPlaceholderSelectorIfNeeded(stream);  // Forwards until the end of the argument (i.e. to comma or
                                               // EOB).
    }
    if (stream.AtEnd()) {
      break;
    }
    stream.ConsumeIncludingWhitespace();
    first_in_complex_selector_list = false;
  }

  if (reset_vector.AddedElements().empty()) {
    //  Parsed nothing that was supported.
    return tcb::span<CSSSelector>();
  }

  return reset_vector.CommitAddedElements();
}

static CSSNestingType ConsumeUntilCommaAndFindNestingType(CSSParserTokenStream& stream) {
  CSSNestingType nesting_type = CSSNestingType::kNone;
  CSSParserToken previous_token(kIdentToken);

  while (!stream.AtEnd()) {
    const CSSParserToken& token = stream.Peek();
    if (token.GetBlockType() == CSSParserToken::kBlockStart) {
      CSSParserTokenStream::BlockGuard block(stream);
      while (!stream.AtEnd()) {
        nesting_type = std::max(nesting_type, ConsumeUntilCommaAndFindNestingType(stream));
        if (!stream.AtEnd()) {
          assert(stream.Peek().GetType() == kCommaToken);
          stream.Consume();
        }
      }
      continue;
    }
    if (token.GetType() == kCommaToken) {
      // End of this argument.
      break;
    }
    if (token.GetType() == kDelimiterToken && token.Delimiter() == '&') {
      nesting_type = std::max(nesting_type, CSSNestingType::kNesting);
    }
    if (previous_token.GetType() == kColonToken && token.GetType() == kIdentToken &&
        EqualIgnoringASCIICase(token.Value(), "scope")) {
      nesting_type = CSSNestingType::kScope;
    }

    previous_token = token;
    stream.Consume();
  }
  return nesting_type;
}

// If the argument was unparsable but contained a parent-referencing selector
// (& or :scope), we need to keep it so that we still consider the :is()
// as containing that selector; furthermore, we need to keep it on serialization
// so that a round-trip doesn't lose this information.
// We have similar weaknesses here as in CSS custom properties,
// such as not preserving comments fully.
void CSSSelectorParser::AddPlaceholderSelectorIfNeeded(CSSParserTokenStream& stream) {
  uint32_t start = stream.LookAheadOffset();
  CSSNestingType nesting_type = ConsumeUntilCommaAndFindNestingType(stream);
  stream.EnsureLookAhead();
  uint32_t end = stream.LookAheadOffset();

  if (nesting_type != CSSNestingType::kNone) {
    CSSSelector placeholder_selector;
    placeholder_selector.SetMatch(CSSSelector::kPseudoClass);
    // TODO(xiezuobing): 需要传入ExecutingContext
    ExecutingContext* context;
    placeholder_selector.SetUnparsedPlaceholder(nesting_type, stream.StringRangeAt(start, end - start).data());
    placeholder_selector.SetLastInComplexSelector(true);
    output_.push_back(placeholder_selector);
  }
}

std::shared_ptr<CSSSelectorList> CSSSelectorParser::ConsumeForgivingCompoundSelectorList(CSSParserTokenStream& stream) {
  if (in_supports_parsing_) {
    std::shared_ptr<CSSSelectorList> selector_list = ConsumeCompoundSelectorList(stream);
    if (!selector_list || !selector_list->IsValid()) {
      return nullptr;
    }
    return selector_list;
  }

  ResetVectorAfterScope reset_vector(output_);
  while (!stream.AtEnd()) {
    webf::AutoReset<bool> reset_failure(&failed_parsing_, false);
    uint32_t subpos = output_.size();
    tcb::span<CSSSelector> selector = ConsumeCompoundSelector(stream, CSSNestingType::kNone);
    stream.ConsumeWhitespace();
    if (selector.empty() || failed_parsing_ || (!stream.AtEnd() && stream.Peek().GetType() != kCommaToken)) {
      output_.resize(subpos);  // Drop what we parsed so far.
      stream.SkipUntilPeekedTypeIs<kCommaToken>();
    } else {
      MarkAsEntireComplexSelector(selector);
    }
    if (!stream.AtEnd()) {
      stream.ConsumeIncludingWhitespace();
    }
  }

  if (reset_vector.AddedElements().empty()) {
    return CSSSelectorList::Empty();
  }

  return CSSSelectorList::AdoptSelectorVector(reset_vector.AddedElements());
}

std::shared_ptr<CSSSelectorList> CSSSelectorParser::ConsumeForgivingRelativeSelectorList(CSSParserTokenStream& stream) {
  if (in_supports_parsing_) {
    std::shared_ptr<CSSSelectorList> selector_list = ConsumeRelativeSelectorList(stream);
    if (!selector_list || !selector_list->IsValid()) {
      return nullptr;
    }
    return selector_list;
  }

  ResetVectorAfterScope reset_vector(output_);
  while (!stream.AtEnd()) {
    webf::AutoReset<bool> reset_failure(&failed_parsing_, false);
    CSSParserTokenStream::BlockGuard guard(stream);
    uint32_t subpos = output_.size();
    tcb::span<CSSSelector> selector = ConsumeRelativeSelector(stream);

    if (selector.empty() || failed_parsing_ || (!stream.AtEnd() && stream.Peek().GetType() != kCommaToken)) {
      output_.resize(subpos);  // Drop what we parsed so far.
      stream.SkipUntilPeekedTypeIs<kCommaToken>();
    }
    if (!stream.AtEnd()) {
      stream.ConsumeIncludingWhitespace();
    }
  }

  // :has() is not allowed in the pseudos accepting only compound selectors, or
  // not allowed after pseudo elements.
  // (e.g. '::slotted(:has(.a))', '::part(foo):has(:hover)')
  if (inside_compound_pseudo_ || restricting_pseudo_element_ != CSSSelector::kPseudoUnknown ||
      reset_vector.AddedElements().empty()) {
    // TODO(blee@igalia.com) Workaround to make :has() unforgiving to avoid
    // JQuery :has() issue: https://github.com/w3c/csswg-drafts/issues/7676
    // Should return empty CSSSelectorList. (return CSSSelectorList::Empty())
    return nullptr;
  }

  return CSSSelectorList::AdoptSelectorVector(reset_vector.AddedElements());
}

std::shared_ptr<CSSSelectorList> CSSSelectorParser::ConsumeRelativeSelectorList(CSSParserTokenStream& stream) {
  ResetVectorAfterScope reset_vector(output_);
  if (ConsumeRelativeSelector(stream).empty()) {
    return nullptr;
  }
  while (!stream.AtEnd() && stream.Peek().GetType() == kCommaToken) {
    stream.ConsumeIncludingWhitespace();
    if (ConsumeRelativeSelector(stream).empty()) {
      return nullptr;
    }
  }

  if (failed_parsing_) {
    return nullptr;
  }

  // :has() is not allowed in the pseudos accepting only compound selectors, or
  // not allowed after pseudo elements.
  // (e.g. '::slotted(:has(.a))', '::part(foo):has(:hover)')
  if (inside_compound_pseudo_ || restricting_pseudo_element_ != CSSSelector::kPseudoUnknown ||
      reset_vector.AddedElements().empty()) {
    return nullptr;
  }

  return CSSSelectorList::AdoptSelectorVector(reset_vector.AddedElements());
}

namespace {

enum CompoundSelectorFlags {
  kHasPseudoElementForRightmostCompound = 1 << 0,
};

unsigned ExtractCompoundFlags(const CSSSelector& simple_selector, CSSParserMode parser_mode) {
  if (simple_selector.Match() != CSSSelector::kPseudoElement) {
    return 0;
  }
  // We don't restrict what follows custom ::-webkit-* pseudo elements in UA
  // sheets. We currently use selectors in mediaControls.css like this:
  //
  // video::-webkit-media-text-track-region-container.scrolling
  if (parser_mode == kUASheetMode && simple_selector.GetPseudoType() == CSSSelector::kPseudoWebKitCustomElement) {
    return 0;
  }
  return kHasPseudoElementForRightmostCompound;
}

unsigned ExtractCompoundFlags(const tcb::span<CSSSelector> compound_selector, CSSParserMode parser_mode) {
  unsigned compound_flags = 0;
  for (const CSSSelector& simple : compound_selector) {
    if (compound_flags) {
      break;
    }
    compound_flags |= ExtractCompoundFlags(simple, parser_mode);
  }
  return compound_flags;
}

}  // namespace

tcb::span<CSSSelector> CSSSelectorParser::ConsumeRelativeSelector(CSSParserTokenStream& stream) {
  ResetVectorAfterScope reset_vector(output_);

  CSSSelector selector;
  selector.SetMatch(CSSSelector::kPseudoClass);
  // TODO(xiezuobing): 需要传入ExecutingContext
  ExecutingContext* context;
  selector.UpdatePseudoType("-internal-relative-anchor", *context_, false /*has_arguments*/, context_->Mode());
  assert(selector.GetPseudoType() == CSSSelector::kPseudoRelativeAnchor);
  output_.push_back(selector);

  CSSSelector::RelationType combinator = ConvertRelationToRelative(ConsumeCombinator(stream));
  unsigned previous_compound_flags = 0;

  if (!ConsumePartialComplexSelector(stream, combinator, previous_compound_flags, CSSNestingType::kNone)) {
    return {};
  }

  // See ConsumeComplexSelector().
  std::reverse(reset_vector.AddedElements().begin(), reset_vector.AddedElements().end());

  MarkAsEntireComplexSelector(reset_vector.AddedElements());
  return reset_vector.CommitAddedElements();
}

// This acts like CSSSelector::GetNestingType, except across a whole
// selector list.
//
// A return value of CSSNestingType::kNesting means that the list
// "contains the nesting selector".
// https://drafts.csswg.org/css-nesting-1/#contain-the-nesting-selector
//
// A return value of CSSNestingType::kScope means that the list
// contains the :scope selector.
static CSSNestingType GetNestingTypeForSelectorList(const CSSSelector* selector) {
  if (selector == nullptr) {
    return CSSNestingType::kNone;
  }
  CSSNestingType nesting_type = CSSNestingType::kNone;
  for (;;) {  // Termination condition within loop.
    nesting_type = std::max(nesting_type, selector->GetNestingType());
    if (selector->SelectorList() != nullptr) {
      nesting_type = std::max(nesting_type, GetNestingTypeForSelectorList(selector->SelectorList()->First()));
    }
    if (selector->IsLastInSelectorList() || nesting_type == CSSNestingType::kNesting) {
      break;
    }
    ++selector;
  }
  return nesting_type;
}

// https://drafts.csswg.org/selectors/#relative-selector-anchor-elements
static CSSSelector CreateImplicitAnchor(CSSNestingType nesting_type,
                                        std::shared_ptr<const StyleRule> parent_rule_for_nesting) {
  if (nesting_type == CSSNestingType::kNesting) {
    return CSSSelector(parent_rule_for_nesting, /*is_implicit=*/true);
  }
  assert(nesting_type == CSSNestingType::kScope);
  // TODO(xiezuobing): 需要传入ExecutingContext
  ExecutingContext* context;
  return CSSSelector("scope", /*is_implicit=*/true);
}

// Within @scope, each compound that contains either :scope or '&' is prepended
// with an implicit :true + relation=kScopeActivation. This makes it possible
// for SelectorChecker to (re)try the selector's NextSimpleSelector with
// different :scope nodes.
static CSSSelector CreateImplicitScopeActivation() {
  CSSSelector selector;
  selector.SetTrue();
  selector.SetRelation(CSSSelector::kScopeActivation);
  return selector;
}

static std::optional<CSSSelector> MaybeCreateImplicitDescendantAnchor(
    CSSNestingType nesting_type,
    std::shared_ptr<const StyleRule> parent_rule_for_nesting,
    const CSSSelector* selector) {
  switch (nesting_type) {
    case CSSNestingType::kNone:
      break;
    case CSSNestingType::kScope:
    case CSSNestingType::kNesting:
      static_assert(CSSNestingType::kNone < CSSNestingType::kScope);
      static_assert(CSSNestingType::kScope < CSSNestingType::kNesting);
      // For kNesting, we should only produce an implied descendant combinator
      // if the selector list is not nest-containing.
      //
      // For kScope, we should should only produce an implied descendant
      // combinator if the selector list is not :scope-containing. Note however
      // that selectors which are nest-containing are also treated as
      // :scope-containing.
      if (GetNestingTypeForSelectorList(selector) < nesting_type) {
        return CreateImplicitAnchor(nesting_type, parent_rule_for_nesting);
      }
      break;
  }
  return std::nullopt;
}

// A nested rule that starts with a combinator; very similar to
// ConsumeRelativeSelector() (but we don't use the kRelative* relations,
// as they have different matching semantics). There's an implicit anchor
// compound in front, which for CSSNestingType::kNesting is the nesting
// selector (&) and for CSSNestingType::kScope is the :scope pseudo class.
// E.g. given CSSNestingType::kNesting, “> .a” is parsed as “& > .a” ().
tcb::span<CSSSelector> CSSSelectorParser::ConsumeNestedRelativeSelector(CSSParserTokenStream& stream,
                                                                        CSSNestingType nesting_type) {
  assert(nesting_type != CSSNestingType::kNone);

  ResetVectorAfterScope reset_vector(output_);
  output_.push_back(CreateImplicitAnchor(nesting_type, parent_rule_for_nesting_));
  if (nesting_type == CSSNestingType::kScope) {
    output_.push_back(CreateImplicitScopeActivation());
  }
  CSSSelector::RelationType combinator = ConsumeCombinator(stream);
  unsigned previous_compound_flags = 0;
  if (!ConsumePartialComplexSelector(stream, combinator, previous_compound_flags, nesting_type)) {
    return {};
  }

  std::reverse(reset_vector.AddedElements().begin(), reset_vector.AddedElements().end());

  MarkAsEntireComplexSelector(reset_vector.AddedElements());
  return reset_vector.CommitAddedElements();
}

tcb::span<CSSSelector> CSSSelectorParser::ConsumeComplexSelector(CSSParserTokenStream& stream,
                                                                 CSSNestingType nesting_type,
                                                                 bool first_in_complex_selector_list) {
  if (nesting_type != CSSNestingType::kNone && PeekIsCombinator(stream)) {
    // Nested selectors that start with a combinator are to be
    // interpreted as relative selectors (with the anchor being
    // the parent selector, i.e., &).
    return ConsumeNestedRelativeSelector(stream, nesting_type);
  }

  ResetVectorAfterScope reset_vector(output_);
  tcb::span<CSSSelector> compound_selector = ConsumeCompoundSelector(stream, nesting_type);
  if (compound_selector.empty()) {
    return {};
  }

  // Reverse the compound selector, so that it comes out properly
  // after we reverse everything below.
  std::reverse(compound_selector.begin(), compound_selector.end());

  if (CSSSelector::RelationType combinator = ConsumeCombinator(stream)) {
    if (is_inside_has_argument_ && is_inside_logical_combination_in_has_argument_) {
      found_complex_logical_combinations_in_has_argument_ = true;
    }
    unsigned previous_compound_flags = ExtractCompoundFlags(compound_selector, context_->Mode());
    if (!ConsumePartialComplexSelector(stream, combinator, previous_compound_flags, nesting_type)) {
      return {};
    }
  }

  // Complex selectors (i.e., groups of compound selectors) are stored
  // right-to-left, ie., the opposite direction of what we parse them. However,
  // within each compound selector, the simple selectors are stored
  // left-to-right. The simplest way of doing this in-place is to reverse each
  // compound selector after we've parsed it (which we do above), and then
  // reverse the entire list in the end. So if the CSS text says:
  //
  //   .a.b.c .d.e.f .g.h
  //
  // we first parse and reverse each compound selector:
  //
  //   .c.b.a .f.e.d .h.g
  //
  // and then reverse the entire list, giving the desired in-memory layout:
  //
  //   .g.h .d.e.f .a.b.c
  //
  // The boundaries between the compound selectors are implicit; they are given
  // by having a Relation() not equal to kSubSelector, so they follow
  // automatically when we do the reversal.
  std::reverse(reset_vector.AddedElements().begin(), reset_vector.AddedElements().end());

  if (nesting_type != CSSNestingType::kNone) {
    // In nested top-level rules, if we do not have a & anywhere in the list,
    // we are a relative selector (with & as the anchor), and we must prepend
    // (or append, since we're storing reversed) an implicit & using
    // a descendant combinator.
    //
    // We need to temporarily mark the end of the selector list, for the benefit
    // of GetNestingTypeForSelectorList().
    uint32_t last_index = output_.size() - 1;
    output_[last_index].SetLastInSelectorList(true);
    if (std::optional<CSSSelector> anchor = MaybeCreateImplicitDescendantAnchor(nesting_type, parent_rule_for_nesting_,
                                                                                reset_vector.AddedElements().data())) {
      output_.back().SetRelation(CSSSelector::kDescendant);
      if (nesting_type != CSSNestingType::kNone && is_within_scope_) {
        output_.push_back(CreateImplicitScopeActivation());
      }
      output_.push_back(*anchor);
    }

    output_[last_index].SetLastInSelectorList(false);
  }

  MarkAsEntireComplexSelector(reset_vector.AddedElements());

  return reset_vector.CommitAddedElements();
}

bool CSSSelectorParser::ConsumePartialComplexSelector(CSSParserTokenStream& stream,
                                                      CSSSelector::RelationType& combinator,
                                                      unsigned previous_compound_flags,
                                                      CSSNestingType nesting_type) {
  do {
    tcb::span<CSSSelector> compound_selector = ConsumeCompoundSelector(stream, nesting_type);
    if (compound_selector.empty()) {
      // No more selectors. If we ended with some explicit combinator
      // (e.g. “a >” and then nothing), that's a parse error.
      // But if not, we're simply done and return everything
      // we've parsed so far.
      return combinator == CSSSelector::kDescendant;
    }
    compound_selector.back().SetRelation(combinator);

    // See ConsumeComplexSelector().
    std::reverse(compound_selector.begin(), compound_selector.end());

    if (previous_compound_flags & kHasPseudoElementForRightmostCompound) {
      // If we've already seen a compound that needs to be rightmost, and still
      // get more, that's a parse error.
      return false;
    }
    previous_compound_flags = ExtractCompoundFlags(compound_selector, context_->Mode());
  } while ((combinator = ConsumeCombinator(stream)));

  return true;
}

// static
CSSSelector::PseudoType CSSSelectorParser::ParsePseudoType(const std::string& name,
                                                           bool has_arguments,
                                                           const Document* document) {
  CSSSelector::PseudoType pseudo_type = CSSSelector::NameToPseudoType(name, has_arguments, document);

  if (pseudo_type != CSSSelector::PseudoType::kPseudoUnknown) {
    return pseudo_type;
  }

  if (name.compare(0, 8, "-webkit-") == 0) {
    return CSSSelector::PseudoType::kPseudoWebKitCustomElement;
  }
  if (name.compare(0, 10, "-internal-") == 0) {
    return CSSSelector::PseudoType::kPseudoBlinkInternalElement;
  }
  return CSSSelector::PseudoType::kPseudoUnknown;
}

// static
PseudoId CSSSelectorParser::ParsePseudoElement(const std::string& selector_string,
                                               const Node* parent,
                                               std::string& argument) {
  // For old pseudos (before, after, first-letter, first-line), we
  // allow the legacy behavior of single-colon / no-colon.
  {
    CSSTokenizer tokenizer(selector_string);
    CSSParserTokenStream stream(tokenizer);
    stream.EnsureLookAhead();
    int num_colons = 0;
    if (stream.Peek().GetType() == kColonToken) {
      stream.Consume();
      ++num_colons;
    }
    if (stream.Peek().GetType() == kColonToken) {
      stream.Consume();
      ++num_colons;
    }

    CSSParserToken selector_name_token = stream.Peek();
    if (selector_name_token.GetType() == kIdentToken) {
      stream.Consume();
      if (stream.Peek().GetType() != kEOFToken) {
        return kPseudoIdInvalid;
      }

      CSSSelector::PseudoType pseudo_type =
          ParsePseudoType(std::string(selector_name_token.Value()),
                          /*has_arguments=*/false, parent ? &parent->GetDocument() : nullptr);

      PseudoId pseudo_id = CSSSelector::GetPseudoId(pseudo_type);
      if (pseudo_id == kPseudoIdBefore || pseudo_id == kPseudoIdAfter || pseudo_id == kPseudoIdFirstLetter ||
          pseudo_id == kPseudoIdFirstLine) {
        return pseudo_id;
      }

      // Keep current behavior for shadow pseudo-elements like ::placeholder.
      if (GetImplicitShadowCombinatorForMatching(pseudo_type) == CSSSelector::kUAShadow && num_colons == 2) {
        return kPseudoIdNone;
      }
    }

    if (num_colons != 2) {
      return num_colons == 1 ? kPseudoIdInvalid : kPseudoIdNone;
    }
  }

  // Otherwise, we use the standard pseudo-selector parser.
  // A restart is OK here, since this function is called only from
  // getComputedStyle() and similar, not the main parsing path.
  std::vector<CSSSelector> arena;
  CSSSelectorParser parser(std::make_shared<CSSParserContext>(kHTMLStandardMode),
                           /*parent_rule_for_nesting=*/nullptr,
                           /*is_within_scope=*/false, /*semicolon_aborts_nested_selector=*/false,
                           /*style_sheet=*/nullptr, arena);

  ResetVectorAfterScope reset_vector(parser.output_);
  CSSTokenizer tokenizer(selector_string);
  CSSParserTokenStream stream(tokenizer);
  if (!parser.ConsumePseudo(stream)) {
    return kPseudoIdInvalid;
  }

  auto selector = reset_vector.AddedElements();
  if (selector.size() != 1 || !stream.AtEnd()) {
    return kPseudoIdInvalid;
  }

  const CSSSelector& result = selector[0];
  if (!result.MatchesPseudoElement()) {
    return kPseudoIdInvalid;
  }

  PseudoId pseudo_id = result.GetPseudoId(result.GetPseudoType());

  switch (pseudo_id) {
    case kPseudoIdHighlight: {
      argument = result.Argument().value_or("");
      return pseudo_id;
    }

    case kPseudoIdViewTransitionGroup:
    case kPseudoIdViewTransitionImagePair:
    case kPseudoIdViewTransitionOld:
    case kPseudoIdViewTransitionNew: {
      if (result.IdentList().size() != 1 || result.IdentList()[0] == CSSSelector::UniversalSelector()) {
        return kPseudoIdInvalid;
      }
      argument = result.IdentList()[0].value_or("");
      return pseudo_id;
    }

    default:
      return pseudo_id;
  }
}

// static
std::optional<tcb::span<CSSSelector>> CSSSelectorParser::ParseScopeBoundary(
    CSSParserTokenStream& stream,
    std::shared_ptr<const CSSParserContext> context,
    CSSNestingType nesting_type,
    std::shared_ptr<const StyleRule> parent_rule_for_nesting,
    bool is_within_scope,
    std::shared_ptr<StyleSheetContents> style_sheet,
    std::vector<CSSSelector>& arena) {
  CSSSelectorParser parser(std::move(context), std::move(parent_rule_for_nesting), is_within_scope,
                           /*semicolon_aborts_nested_selector=*/false, std::move(style_sheet), arena);
  DisallowPseudoElementsScope disallow_pseudo_elements(&parser);

  stream.ConsumeWhitespace();
  std::optional<tcb::span<CSSSelector>> result = parser.ConsumeForgivingComplexSelectorList(stream, nesting_type);
  DCHECK(result.has_value());
  if (!stream.AtEnd()) {
    return std::nullopt;
  }
  return result;
}

namespace {

bool IsScrollbarPseudoClass(CSSSelector::PseudoType pseudo) {
  switch (pseudo) {
    case CSSSelector::kPseudoEnabled:
    case CSSSelector::kPseudoDisabled:
    case CSSSelector::kPseudoHover:
    case CSSSelector::kPseudoActive:
    case CSSSelector::kPseudoHorizontal:
    case CSSSelector::kPseudoVertical:
    case CSSSelector::kPseudoDecrement:
    case CSSSelector::kPseudoIncrement:
    case CSSSelector::kPseudoStart:
    case CSSSelector::kPseudoEnd:
    case CSSSelector::kPseudoDoubleButton:
    case CSSSelector::kPseudoSingleButton:
    case CSSSelector::kPseudoNoButton:
    case CSSSelector::kPseudoCornerPresent:
    case CSSSelector::kPseudoWindowInactive:
      return true;
    default:
      return false;
  }
}

bool IsUserActionPseudoClass(CSSSelector::PseudoType pseudo) {
  switch (pseudo) {
    case CSSSelector::kPseudoHover:
    case CSSSelector::kPseudoFocus:
    case CSSSelector::kPseudoFocusVisible:
    case CSSSelector::kPseudoFocusWithin:
    case CSSSelector::kPseudoActive:
      return true;
    default:
      return false;
  }
}

bool IsPseudoClassValidAfterPseudoElement(CSSSelector::PseudoType pseudo_class,
                                          CSSSelector::PseudoType compound_pseudo_element) {
  switch (compound_pseudo_element) {
    case CSSSelector::kPseudoResizer:
    case CSSSelector::kPseudoScrollbar:
    case CSSSelector::kPseudoScrollbarCorner:
    case CSSSelector::kPseudoScrollbarButton:
    case CSSSelector::kPseudoScrollbarThumb:
    case CSSSelector::kPseudoScrollbarTrack:
    case CSSSelector::kPseudoScrollbarTrackPiece:
      return IsScrollbarPseudoClass(pseudo_class);
    case CSSSelector::kPseudoSelection:
      return pseudo_class == CSSSelector::kPseudoWindowInactive;
    case CSSSelector::kPseudoPart:
    // TODO(crbug.com/1511354): Add tests for the PseudoSelect cases here
    case CSSSelector::kPseudoSelectFallbackButton:
    case CSSSelector::kPseudoSelectFallbackButtonText:
    case CSSSelector::kPseudoSelectFallbackDatalist:
      return IsUserActionPseudoClass(pseudo_class) || pseudo_class == CSSSelector::kPseudoState ||
             pseudo_class == CSSSelector::kPseudoStateDeprecatedSyntax;
    case CSSSelector::kPseudoWebKitCustomElement:
    case CSSSelector::kPseudoBlinkInternalElement:
    case CSSSelector::kPseudoFileSelectorButton:
      return IsUserActionPseudoClass(pseudo_class);
    case CSSSelector::kPseudoViewTransitionGroup:
    case CSSSelector::kPseudoViewTransitionImagePair:
    case CSSSelector::kPseudoViewTransitionOld:
    case CSSSelector::kPseudoViewTransitionNew:
      return pseudo_class == CSSSelector::kPseudoOnlyChild;
    case CSSSelector::kPseudoSearchText:
      return pseudo_class == CSSSelector::kPseudoCurrent;
    default:
      return false;
  }
}

bool IsSimpleSelectorValidAfterPseudoElement(const CSSSelector& simple_selector,
                                             CSSSelector::PseudoType compound_pseudo_element) {
  switch (compound_pseudo_element) {
    case CSSSelector::kPseudoUnknown:
      return true;
    case CSSSelector::kPseudoAfter:
    case CSSSelector::kPseudoBefore:
      //      if (simple_selector.GetPseudoType() == CSSSelector::kPseudoMarker &&
      //          RuntimeEnabledFeatures::CSSMarkerNestedPseudoElementEnabled()) {
      //        return true;
      //      }
      return false;
      break;
    case CSSSelector::kPseudoSlotted:
      return simple_selector.IsTreeAbidingPseudoElement();
    case CSSSelector::kPseudoPart:
      if (simple_selector.IsAllowedAfterPart()) {
        return true;
      }
      break;
    default:
      break;
  }
  if (simple_selector.Match() != CSSSelector::kPseudoClass) {
    return false;
  }
  CSSSelector::PseudoType pseudo = simple_selector.GetPseudoType();
  switch (pseudo) {
    case CSSSelector::kPseudoIs:
    case CSSSelector::kPseudoWhere:
    case CSSSelector::kPseudoNot:
    case CSSSelector::kPseudoHas:
      // These pseudo-classes are themselves always valid.
      // CSSSelectorParser::restricting_pseudo_element_ ensures that invalid
      // nested selectors will be dropped if they are invalid according to
      // this function.
      return true;
    default:
      break;
  }
  return IsPseudoClassValidAfterPseudoElement(pseudo, compound_pseudo_element);
}

bool IsPseudoClassValidWithinHasArgument(CSSSelector& selector) {
  assert(selector.Match() == CSSSelector::kPseudoClass);
  switch (selector.GetPseudoType()) {
    // Limited nested :has() to avoid increasing :has() invalidation complexity.
    case CSSSelector::kPseudoHas:
      return false;
    default:
      return true;
  }
}

// Checks if an implicit scope activation (see CreateImplicitScopeActivation())
// must be prepended to a given compound selector.
static bool SelectorListRequiresScopeActivation(const CSSSelectorList& list);

static bool SimpleSelectorRequiresScopeActivation(const CSSSelector& selector) {
  if (selector.SelectorList()) {
    return SelectorListRequiresScopeActivation(*selector.SelectorList());
  }
  return selector.GetPseudoType() == CSSSelector::kPseudoScope ||
         selector.GetPseudoType() == CSSSelector::kPseudoParent;
}

static bool SelectorListRequiresScopeActivation(const CSSSelectorList& list) {
  for (const CSSSelector* selector = list.First(); selector; selector = CSSSelectorList::Next(*selector)) {
    for (const CSSSelector* simple = selector; simple; simple = simple->NextSimpleSelector()) {
      if (SimpleSelectorRequiresScopeActivation(*simple)) {
        return true;
      }
    }
  }
  return false;
}

}  // namespace

bool CSSSelectorParser::ConsumeName(CSSParserTokenStream& stream,
                                    std::optional<std::string>& name,
                                    std::string& namespace_prefix) {
  name = "";
  namespace_prefix = "";

  const CSSParserToken& first_token = stream.Peek();
  if (first_token.GetType() == kIdentToken) {
    name = first_token.Value();
    stream.Consume();
  } else if (first_token.GetType() == kDelimiterToken && first_token.Delimiter() == '*') {
    name = CSSSelector::UniversalSelector();
    stream.Consume();
  } else if (first_token.GetType() == kDelimiterToken && first_token.Delimiter() == '|') {
    // This is an empty namespace, which'll get assigned this value below
    name = "";
  } else {
    return false;
  }

  if (stream.Peek().GetType() != kDelimiterToken || stream.Peek().Delimiter() != '|') {
    return true;
  }

  CSSParserSavePoint savepoint(stream);
  stream.Consume();

  namespace_prefix = name == CSSSelector::UniversalSelector() ? "*" : name.value();
  if (stream.Peek().GetType() == kIdentToken) {
    name = stream.Consume().Value();
  } else if (stream.Peek().GetType() == kDelimiterToken && stream.Peek().Delimiter() == '*') {
    stream.Consume();
    name = CSSSelector::UniversalSelector();
  } else {
    name = "";
    namespace_prefix = "";
    return false;
  }

  savepoint.Release();
  return true;
}

bool CSSSelectorParser::ConsumeId(CSSParserTokenStream& stream) {
  DCHECK_EQ(stream.Peek().GetType(), kHashToken);
  if (stream.Peek().GetHashTokenType() != kHashTokenId) {
    return false;
  }
  CSSSelector selector;
  selector.SetMatch(CSSSelector::kId);
  std::string value = std::string(stream.Consume().Value());
  selector.SetValue(value, IsQuirksModeBehavior(context_->Mode()));
  output_.push_back(std::move(selector));
  return true;
}

bool CSSSelectorParser::ConsumeClass(CSSParserTokenStream& stream) {
  DCHECK_EQ(stream.Peek().GetType(), kDelimiterToken);
  DCHECK_EQ(stream.Peek().Delimiter(), '.');
  stream.Consume();
  if (stream.Peek().GetType() != kIdentToken) {
    return false;
  }
  CSSSelector selector;
  selector.SetMatch(CSSSelector::kClass);
  std::string value = std::string(stream.Consume().Value());
  selector.SetValue(value, IsQuirksModeBehavior(context_->Mode()));
  output_.push_back(std::move(selector));
  return true;
}

bool CSSSelectorParser::ConsumeAttribute(CSSParserTokenStream& stream) {
  DCHECK_EQ(stream.Peek().GetType(), kLeftBracketToken);
  CSSParserTokenStream::BlockGuard guard(stream);
  stream.ConsumeWhitespace();

  std::string namespace_prefix;
  std::optional<std::string> attribute_name;
  if (!ConsumeName(stream, attribute_name, namespace_prefix)) {
    return false;
  }
  if (attribute_name == CSSSelector::UniversalSelector()) {
    return false;
  }
  stream.ConsumeWhitespace();

  std::transform(attribute_name->begin(), attribute_name->end(), attribute_name->begin(), tolower);

  QualifiedName qualified_name =
      namespace_prefix.empty() ? QualifiedName(attribute_name) : QualifiedName(namespace_prefix, attribute_name, "");

  if (stream.AtEnd()) {
    CSSSelector selector(CSSSelector::kAttributeSet, qualified_name, CSSSelector::AttributeMatchType::kCaseSensitive);
    output_.push_back(std::move(selector));
    return true;
  }

  CSSSelector::MatchType match_type = ConsumeAttributeMatch(stream);

  CSSParserToken attribute_value = stream.Peek();
  if (attribute_value.GetType() != kIdentToken && attribute_value.GetType() != kStringToken) {
    return false;
  }
  stream.ConsumeIncludingWhitespace();
  CSSSelector::AttributeMatchType case_sensitivity = ConsumeAttributeFlags(stream);
  if (!stream.AtEnd()) {
    return false;
  }

  CSSSelector selector(match_type, qualified_name, case_sensitivity, std::string(attribute_value.Value()));
  output_.push_back(std::move(selector));
  return true;
}

bool CSSSelectorParser::ConsumePseudo(CSSParserTokenStream& stream) {
  DCHECK_EQ(stream.Peek().GetType(), kColonToken);
  stream.Consume();

  int colons = 1;
  if (stream.Peek().GetType() == kColonToken) {
    stream.Consume();
    colons++;
  }

  const CSSParserToken& token = stream.Peek();
  if (token.GetType() != kIdentToken && token.GetType() != kFunctionToken) {
    return false;
  }

  CSSSelector selector;
  selector.SetMatch(colons == 1 ? CSSSelector::kPseudoClass : CSSSelector::kPseudoElement);

  bool has_arguments = token.GetType() == kFunctionToken;
  selector.UpdatePseudoType(std::string(token.Value()), *context_, has_arguments, context_->Mode());

  if (selector.Match() == CSSSelector::kPseudoElement) {
    switch (selector.GetPseudoType()) {
      case CSSSelector::kPseudoBefore:
      case CSSSelector::kPseudoAfter:
        break;
      case CSSSelector::kPseudoMarker:
        if (context_->Mode() != kUASheetMode) {
        }
        break;
      default:
        break;
    }
  }

  if (selector.Match() == CSSSelector::kPseudoElement && disallow_pseudo_elements_) {
    return false;
  }

  if (is_inside_has_argument_) {
    DCHECK(disallow_pseudo_elements_);
    if (!IsPseudoClassValidWithinHasArgument(selector)) {
      return false;
    }
    found_pseudo_in_has_argument_ = true;
  }

  if (token.GetType() == kIdentToken) {
    stream.Consume();
    if (selector.GetPseudoType() == CSSSelector::kPseudoUnknown) {
      return false;
    }
    output_.push_back(std::move(selector));
    return true;
  }

  CSSParserTokenStream::BlockGuard guard(stream);
  stream.ConsumeWhitespace();
  if (selector.GetPseudoType() == CSSSelector::kPseudoUnknown) {
    return false;
  }

  switch (selector.GetPseudoType()) {
    case CSSSelector::kPseudoIs: {
      DisallowPseudoElementsScope scope(this);
      AutoReset<bool> resist_namespace(&resist_default_namespace_, true);
      AutoReset<bool> is_inside_logical_combination_in_has_argument(&is_inside_logical_combination_in_has_argument_,
                                                                    is_inside_has_argument_);

      std::shared_ptr<CSSSelectorList> selector_list = ConsumeForgivingNestedSelectorList(stream);
      if (!selector_list || !stream.AtEnd()) {
        return false;
      }
      selector.SetSelectorList(selector_list);
      output_.push_back(std::move(selector));
      return true;
    }
    case CSSSelector::kPseudoWhere: {
      DisallowPseudoElementsScope scope(this);
      AutoReset<bool> resist_namespace(&resist_default_namespace_, true);
      AutoReset<bool> is_inside_logical_combination_in_has_argument(&is_inside_logical_combination_in_has_argument_,
                                                                    is_inside_has_argument_);

      std::shared_ptr<CSSSelectorList> selector_list = ConsumeForgivingNestedSelectorList(stream);
      if (!selector_list || !stream.AtEnd()) {
        return false;
      }
      selector.SetSelectorList(selector_list);
      output_.push_back(std::move(selector));
      return true;
    }
    case CSSSelector::kPseudoHost:
    case CSSSelector::kPseudoHostContext:
    case CSSSelector::kPseudoAny:
    case CSSSelector::kPseudoCue: {
      DisallowPseudoElementsScope scope(this);
      AutoReset<bool> inside_compound(&inside_compound_pseudo_, true);
      AutoReset<bool> ignore_namespace(
          &ignore_default_namespace_, ignore_default_namespace_ || selector.GetPseudoType() == CSSSelector::kPseudoCue);

      std::shared_ptr<CSSSelectorList> selector_list = ConsumeCompoundSelectorList(stream);
      if (!selector_list || !selector_list->IsValid() || !stream.AtEnd()) {
        return false;
      }

      if (!selector_list->HasOneSelector()) {
        if (selector.GetPseudoType() == CSSSelector::kPseudoHost) {
          return false;
        }
        if (selector.GetPseudoType() == CSSSelector::kPseudoHostContext) {
          return false;
        }
      }

      selector.SetSelectorList(selector_list);
      output_.push_back(std::move(selector));
      return true;
    }
    case CSSSelector::kPseudoHas: {
      DisallowPseudoElementsScope scope(this);
      AutoReset<bool> resist_namespace(&resist_default_namespace_, true);

      AutoReset<bool> is_inside_has_argument(&is_inside_has_argument_, true);
      AutoReset<bool> found_pseudo_in_has_argument(&found_pseudo_in_has_argument_, false);
      AutoReset<bool> found_complex_logical_combinations_in_has_argument(
          &found_complex_logical_combinations_in_has_argument_, false);

      std::shared_ptr<CSSSelectorList> selector_list;
      selector_list = ConsumeRelativeSelectorList(stream);
      if (!selector_list || !selector_list->IsValid() || !stream.AtEnd()) {
        return false;
      }
      selector.SetSelectorList(selector_list);
      if (found_pseudo_in_has_argument_) {
        selector.SetContainsPseudoInsideHasPseudoClass();
      }
      if (found_complex_logical_combinations_in_has_argument_) {
        selector.SetContainsComplexLogicalCombinationsInsideHasPseudoClass();
      }
      output_.push_back(std::move(selector));
      return true;
    }
    case CSSSelector::kPseudoNot: {
      DisallowPseudoElementsScope scope(this);
      AutoReset<bool> resist_namespace(&resist_default_namespace_, true);
      AutoReset<bool> is_inside_logical_combination_in_has_argument(&is_inside_logical_combination_in_has_argument_,
                                                                    is_inside_has_argument_);

      std::shared_ptr<CSSSelectorList> selector_list = ConsumeNestedSelectorList(stream);
      if (!selector_list || !selector_list->IsValid() || !stream.AtEnd()) {
        return false;
      }

      selector.SetSelectorList(selector_list);
      output_.push_back(std::move(selector));
      return true;
    }
    case CSSSelector::kPseudoDir:
    case CSSSelector::kPseudoState: {
      CHECK(selector.GetPseudoType() != CSSSelector::kPseudoState);
      const CSSParserToken& ident = stream.Peek();
      if (ident.GetType() != kIdentToken) {
        return false;
      }
      selector.SetArgument(std::string(ident.Value()));
      stream.ConsumeIncludingWhitespace();
      if (!stream.AtEnd()) {
        return false;
      }
      output_.push_back(std::move(selector));
      return true;
    }
    case CSSSelector::kPseudoPart: {
      std::vector<std::optional<std::string>> parts;
      do {
        const CSSParserToken& ident = stream.Peek();
        if (ident.GetType() != kIdentToken) {
          return false;
        }
        parts.push_back(std::string(ident.Value()));
        stream.ConsumeIncludingWhitespace();
      } while (!stream.AtEnd());
      selector.SetIdentList(std::make_unique<std::vector<std::optional<std::string>>>(parts));
      output_.push_back(std::move(selector));
      return true;
    }
    case CSSSelector::kPseudoActiveViewTransitionType: {
      std::vector<std::optional<std::string>> types;
      for (;;) {
        const CSSParserToken& ident = stream.Peek();
        if (ident.GetType() != kIdentToken) {
          return false;
        }
        types.push_back(std::string(ident.Value()));
        stream.ConsumeIncludingWhitespace();

        if (stream.AtEnd()) {
          break;
        }

        const CSSParserToken& comma = stream.Peek();
        if (comma.GetType() != kCommaToken) {
          return false;
        }
        stream.ConsumeIncludingWhitespace();
        if (stream.AtEnd()) {
          return false;
        }
      }
      selector.SetIdentList(std::make_unique<std::vector<std::optional<std::string>>>(types));
      output_.push_back(std::move(selector));
      return true;
    }
    case CSSSelector::kPseudoViewTransitionGroup:
    case CSSSelector::kPseudoViewTransitionImagePair:
    case CSSSelector::kPseudoViewTransitionOld:
    case CSSSelector::kPseudoViewTransitionNew: {
      std::unique_ptr<std::vector<std::optional<std::string>>> name_and_classes =
          std::make_unique<std::vector<std::optional<std::string>>>();

      if (name_and_classes->empty()) {
        const CSSParserToken& ident = stream.Peek();
        if (ident.GetType() == kIdentToken) {
          name_and_classes->push_back(std::string(ident.Value()));
          stream.Consume();
        } else if (ident.GetType() == kDelimiterToken && ident.Delimiter() == '*') {
          name_and_classes->push_back(CSSSelector::UniversalSelector());
          stream.Consume();
        } else {
          return false;
        }
      }

      CHECK_EQ(name_and_classes->size(), 1ull);

      stream.ConsumeWhitespace();

      if (!stream.AtEnd()) {
        return false;
      }

      selector.SetIdentList(std::move(name_and_classes));
      output_.push_back(std::move(selector));
      return true;
    }
    case CSSSelector::kPseudoSlotted: {
      DisallowPseudoElementsScope scope(this);
      AutoReset<bool> inside_compound(&inside_compound_pseudo_, true);

      {
        ResetVectorAfterScope reset_vector(output_);
        tcb::span<CSSSelector> inner_selector = ConsumeCompoundSelector(stream, CSSNestingType::kNone);
        stream.ConsumeWhitespace();
        if (inner_selector.empty() || !stream.AtEnd()) {
          return false;
        }
        MarkAsEntireComplexSelector(reset_vector.AddedElements());
        selector.SetSelectorList(CSSSelectorList::AdoptSelectorVector(reset_vector.AddedElements()));
      }
      output_.push_back(std::move(selector));
      return true;
    }
    case CSSSelector::kPseudoLang: {
      // FIXME: CSS Selectors Level 4 allows :lang(*-foo)
      const CSSParserToken& ident = stream.Peek();
      if (ident.GetType() != kIdentToken) {
        return false;
      }
      selector.SetArgument(std::string(ident.Value()));
      stream.ConsumeIncludingWhitespace();
      if (!stream.AtEnd()) {
        return false;
      }
      output_.push_back(std::move(selector));
      return true;
    }
    case CSSSelector::kPseudoNthChild:
    case CSSSelector::kPseudoNthLastChild:
    case CSSSelector::kPseudoNthOfType:
    case CSSSelector::kPseudoNthLastOfType: {
      std::pair<int, int> ab;
      if (!ConsumeANPlusB(stream, ab)) {
        return false;
      }
      stream.ConsumeWhitespace();
      if (stream.AtEnd()) {
        selector.SetNth(ab.first, ab.second, nullptr);
        output_.push_back(std::move(selector));
        return true;
      }

      // See if there's an “of ...” part.
      if (selector.GetPseudoType() != CSSSelector::kPseudoNthChild &&
          selector.GetPseudoType() != CSSSelector::kPseudoNthLastChild) {
        return false;
      }

      std::shared_ptr<const CSSSelectorList> sub_selectors = ConsumeNthChildOfSelectors(stream);
      if (sub_selectors == nullptr) {
        return false;
      }
      stream.ConsumeWhitespace();
      if (!stream.AtEnd()) {
        return false;
      }

      selector.SetNth(ab.first, ab.second, std::const_pointer_cast<CSSSelectorList>(sub_selectors));
      output_.push_back(std::move(selector));
      return true;
    }
    case CSSSelector::kPseudoHighlight: {
      const CSSParserToken& ident = stream.Peek();
      if (ident.GetType() != kIdentToken) {
        return false;
      }
      selector.SetArgument(std::string(ident.Value()));
      stream.ConsumeIncludingWhitespace();
      if (!stream.AtEnd()) {
        return false;
      }
      output_.push_back(std::move(selector));
      return true;
    }
    default:
      break;
  }

  return false;
}

bool CSSSelectorParser::ConsumeNestingParent(CSSParserTokenStream& stream) {
  DCHECK_EQ(stream.Peek().GetType(), kDelimiterToken);
  DCHECK_EQ(stream.Peek().Delimiter(), '&');
  stream.Consume();

  output_.push_back(CSSSelector(parent_rule_for_nesting_, /*is_implicit=*/false));

  if (is_inside_has_argument_) {
    // In case that a nesting parent selector is inside a :has() pseudo class,
    // mark the :has() containing a pseudo selector and a complex selector
    // so that the StyleEngine can invalidate the anchor element of the :has()
    // for a pseudo state change (crbug.com/1517866) or a complex selector
    // state change (crbug.com/350946979) in the parent selector.
    // These ignore whether the nesting parent actually contains a pseudo or
    // complex selector to avoid nesting parent lookup overhead and the
    // complexity caused by reparenting style rules.
    found_pseudo_in_has_argument_ = true;
    found_complex_logical_combinations_in_has_argument_ = true;
  }

  return true;
}

bool CSSSelectorParser::PeekIsCombinator(CSSParserTokenStream& stream) {
  stream.ConsumeWhitespace();

  if (stream.Peek().GetType() != kDelimiterToken) {
    return false;
  }

  switch (stream.Peek().Delimiter()) {
    case '+':
    case '~':
    case '>':
      return true;
    default:
      return false;
  }
}

bool CSSSelectorParser::ConsumeSimpleSelector(CSSParserTokenStream& stream) {
  const CSSParserToken& token = stream.Peek();
  bool ok;
  if (token.GetType() == kHashToken) {
    ok = ConsumeId(stream);
  } else if (token.GetType() == kDelimiterToken && token.Delimiter() == '.') {
    ok = ConsumeClass(stream);
  } else if (token.GetType() == kLeftBracketToken) {
    ok = ConsumeAttribute(stream);
  } else if (token.GetType() == kColonToken) {
    ok = ConsumePseudo(stream);
  } else if (token.GetType() == kDelimiterToken && token.Delimiter() == '&') {
    ok = ConsumeNestingParent(stream);
  } else {
    return false;
  }
  // TODO(futhark@chromium.org): crbug.com/578131
  // The UASheetMode check is a work-around to allow this selector in
  // mediaControls(New).css:
  // video::-webkit-media-text-track-region-container.scrolling
  if (!ok || (context_->Mode() != kUASheetMode &&
              !IsSimpleSelectorValidAfterPseudoElement(output_.back(), restricting_pseudo_element_))) {
    failed_parsing_ = true;
    return false;
  }
  return true;
}

tcb::span<CSSSelector> CSSSelectorParser::ConsumeCompoundSelector(CSSParserTokenStream& stream,
                                                                  CSSNestingType nesting_type) {
  ResetVectorAfterScope reset_vector(output_);
  size_t start_pos = output_.size();
  AutoReset<CSSSelector::PseudoType> reset_restricting(&restricting_pseudo_element_, restricting_pseudo_element_);

  // See if the compound selector starts with a tag name, universal selector
  // or the likes (these can only be at the beginning). Note that we don't
  // add this to output_ yet, because there are situations where it should
  // be ignored (like if we have a universal selector and don't need it;
  // e.g. *:hover is the same as :hover). Thus, we just keep its data around
  // and prepend it if needed.
  //
  // TODO(sesse): In 99% of cases, we should add this, so the prepending logic
  // gets very complex with having to deal with both the explicit and the
  // implicit case. Consider just inserting it, and then removing it
  // afterwards if we really don't need it.
  std::string namespace_prefix;
  std::optional<std::string> element_name;
  const bool has_q_name = ConsumeName(stream, element_name, namespace_prefix);
  std::transform(element_name->begin(), element_name->end(), element_name->begin(), tolower);

  // A tag name is not valid following a pseudo-element. This can happen for
  // e.g. :::part(x):is(div).
  if (restricting_pseudo_element_ != CSSSelector::kPseudoUnknown && has_q_name) {
    failed_parsing_ = true;
    return {};  // Failure.
  }

  // Consume all the simple selectors that are not tag names.
  while (ConsumeSimpleSelector(stream)) {
    const CSSSelector& simple_selector = output_.back();
    if (simple_selector.Match() == CSSSelector::kPseudoElement) {
      restricting_pseudo_element_ = simple_selector.GetPseudoType();
    }
    output_.back().SetRelation(CSSSelector::kSubSelector);
  }

  // While inside a nested selector like :is(), the default namespace shall
  // be ignored when [1]:
  //
  // - The compound selector represents the subject [2], and
  // - The compound selector does not contain a type/universal selector.
  //
  // [1] https://drafts.csswg.org/selectors/#matches
  // [2] https://drafts.csswg.org/selectors/#selector-subject
  AutoReset<bool> ignore_namespace(
      &ignore_default_namespace_,
      ignore_default_namespace_ || (resist_default_namespace_ && !has_q_name && AtEndIgnoringWhitespace(stream)));

  if (reset_vector.AddedElements().empty()) {
    // No simple selectors except for the tag name.
    // TODO(sesse): Does this share too much code with
    // PrependTypeSelectorIfNeeded()?
    if (!has_q_name) {
      // No tag name either, so we fail parsing of this selector.
      return {};
    }
    DCHECK(has_q_name);
    namespace_prefix = "";
    output_.push_back(CSSSelector(QualifiedName(namespace_prefix, element_name, "")));
    return reset_vector.CommitAddedElements();
  }

  // Prepend a tag selector if we have one, either explicitly or implicitly.
  // One could be added implicitly e.g. if we are in a non-default namespace
  // and have no tag selector already, we may need to convert .foo to
  // (ns|*).foo, with an implicit universal selector prepended before .foo.
  // The explicit case is when we simply have a tag; e.g. if someone wrote
  // div.foo.bar, we've added .foo.bar earlier and are prepending div now.
  //
  // TODO(futhark@chromium.org): Prepending a type selector to the compound is
  // unnecessary if this compound is an argument to a pseudo selector like
  // :not(), since a type selector will be prepended at the top level of the
  // selector if necessary. We need to propagate that context information here
  // to tell if we are at the top level.
  PrependTypeSelectorIfNeeded(namespace_prefix, has_q_name, element_name, start_pos);

  // The relationship between all of these are that they are sub-selectors.
  for (CSSSelector& selector : reset_vector.AddedElements().first(reset_vector.AddedElements().size() - 1)) {
    selector.SetRelation(CSSSelector::kSubSelector);
  }

  // See CSSSelector::RelationType::kScopeActivation.
  bool insert_scope_activation = false;

  if (is_within_scope_ && nesting_type != CSSNestingType::kNone) {
    for (CSSSelector& selector : reset_vector.AddedElements()) {
      if (SimpleSelectorRequiresScopeActivation(selector)) {
        insert_scope_activation = true;
      }
    }
  }

  if (insert_scope_activation) {
    output_.insert(output_.begin() + start_pos, CreateImplicitScopeActivation());
  }

  SplitCompoundAtImplicitShadowCrossingCombinator(reset_vector.AddedElements());
  return reset_vector.CommitAddedElements();
}

CSSSelector::RelationType CSSSelectorParser::ConsumeCombinator(CSSParserTokenStream& stream) {
  CSSSelector::RelationType fallback_result = CSSSelector::kSubSelector;
  while (stream.Peek().GetType() == kWhitespaceToken) {
    stream.Consume();
    fallback_result = CSSSelector::kDescendant;
  }

  if (stream.Peek().GetType() != kDelimiterToken) {
    return fallback_result;
  }

  switch (stream.Peek().Delimiter()) {
    case '+':
      stream.ConsumeIncludingWhitespace();
      return CSSSelector::kDirectAdjacent;

    case '~':
      stream.ConsumeIncludingWhitespace();
      return CSSSelector::kIndirectAdjacent;

    case '>':
      stream.ConsumeIncludingWhitespace();
      return CSSSelector::kChild;

    default:
      break;
  }
  return fallback_result;
}

CSSSelector::MatchType CSSSelectorParser::ConsumeAttributeMatch(CSSParserTokenStream& stream) {
  const CSSParserToken& token = stream.Peek();
  switch (token.GetType()) {
    case kIncludeMatchToken:
      stream.ConsumeIncludingWhitespace();
      return CSSSelector::kAttributeList;
    case kDashMatchToken:
      stream.ConsumeIncludingWhitespace();
      return CSSSelector::kAttributeHyphen;
    case kPrefixMatchToken:
      stream.ConsumeIncludingWhitespace();
      return CSSSelector::kAttributeBegin;
    case kSuffixMatchToken:
      stream.ConsumeIncludingWhitespace();
      return CSSSelector::kAttributeEnd;
    case kSubstringMatchToken:
      stream.ConsumeIncludingWhitespace();
      return CSSSelector::kAttributeContain;
    case kDelimiterToken:
      if (token.Delimiter() == '=') {
        stream.ConsumeIncludingWhitespace();
        return CSSSelector::kAttributeExact;
      }
      [[fallthrough]];
    default:
      failed_parsing_ = true;
      return CSSSelector::kAttributeExact;
  }
}

CSSSelector::AttributeMatchType CSSSelectorParser::ConsumeAttributeFlags(CSSParserTokenStream& stream) {
  if (stream.Peek().GetType() != kIdentToken) {
    return CSSSelector::AttributeMatchType::kCaseSensitive;
  }
  const CSSParserToken& flag = stream.ConsumeIncludingWhitespace();
  if (EqualIgnoringASCIICase(flag.Value(), "i")) {
    return CSSSelector::AttributeMatchType::kCaseInsensitive;
  } else if (EqualIgnoringASCIICase(flag.Value(), "s")) {
    return CSSSelector::AttributeMatchType::kCaseSensitiveAlways;
  }
  failed_parsing_ = true;
  return CSSSelector::AttributeMatchType::kCaseSensitive;
}

void CSSSelectorParser::PrependTypeSelectorIfNeeded(const std::string& namespace_prefix,
                                                    bool has_q_name,
                                                    const std::optional<std::string>& element_name,
                                                    size_t start_index_of_compound_selector) {
  const CSSSelector& compound_selector = output_[start_index_of_compound_selector];

  if (!has_q_name && !NeedsImplicitShadowCombinatorForMatching(compound_selector)) {
    return;
  }

  std::optional<std::string> determined_element_name = !has_q_name ? CSSSelector::UniversalSelector() : element_name;
  std::string determined_prefix = "";
  QualifiedName tag = QualifiedName(determined_prefix, determined_element_name, "");

  // *:host/*:host-context never matches, so we can't discard the *,
  // otherwise we can't tell the difference between *:host and just :host.
  //
  // Also, selectors where we use a ShadowPseudo combinator between the
  // element and the pseudo element for matching (custom pseudo elements,
  // ::cue, ::shadow), we need a universal selector to set the combinator
  // (relation) on in the cases where there are no simple selectors preceding
  // the pseudo element.
  bool is_host_pseudo = IsHostPseudoSelector(compound_selector);
  if (is_host_pseudo && !has_q_name && namespace_prefix.empty()) {
    return;
  }
  if (tag != AnyQName() || is_host_pseudo || NeedsImplicitShadowCombinatorForMatching(compound_selector)) {
    const bool is_implicit =
        determined_prefix == "" && determined_element_name == CSSSelector::UniversalSelector() && !is_host_pseudo;

    output_.insert(output_.begin() + start_index_of_compound_selector, CSSSelector(tag, is_implicit));
  }
}

// If we have a compound that implicitly crosses a shadow root, rewrite it to
// have a shadow-crossing combinator (kUAShadow, which has no symbol, but let's
// call it >> for the same of the argument) instead of kSubSelector. E.g.:
//
//   video::-webkit-video-controls => video >> ::webkit-video-controls
//
// This is required because the element matching ::-webkit-video-controls is
// not the video element itself, but an element somewhere down in <video>'s
// shadow DOM tree. Note that since we store compounds right-to-left, this may
// require rearranging elements in memory (see the comment below).
void CSSSelectorParser::SplitCompoundAtImplicitShadowCrossingCombinator(tcb::span<CSSSelector> selectors) {
  // The simple selectors are stored in an array that stores
  // combinator-separated compound selectors from right-to-left. Yet, within a
  // single compound selector, stores the simple selectors from left-to-right.
  //
  // ".a.b > div#id" is stored as [div, #id, .a, .b], each element in the list
  // stored with an associated relation (combinator or SubSelector).
  //
  // ::cue, ::shadow, and custom pseudo elements have an implicit ShadowPseudo
  // combinator to their left, which really makes for a new compound selector,
  // yet it's consumed by the selector parser as a single compound selector.
  //
  // Example:
  //
  // input#x::-webkit-clear-button -> [ ::-webkit-clear-button, input, #x ]
  //
  // Likewise, ::slotted() pseudo element has an implicit ShadowSlot combinator
  // to its left for finding matching slot element in other TreeScope.
  //
  // ::part has a implicit ShadowPart combinator to its left finding the host
  // element in the scope of the style rule.
  //
  // Example:
  //
  // slot[name=foo]::slotted(div) -> [ ::slotted(div), slot, [name=foo] ]
  for (size_t i = 1; i < selectors.size(); ++i) {
    if (NeedsImplicitShadowCombinatorForMatching(selectors[i])) {
      CSSSelector::RelationType relation = GetImplicitShadowCombinatorForMatching(selectors[i].GetPseudoType());
      std::rotate(selectors.begin(), selectors.begin() + i, selectors.end());

      tcb::span<CSSSelector> remaining = selectors.first(selectors.size() - i);
      // We might need to split the compound twice, since ::placeholder is
      // allowed after ::slotted and they both need an implicit combinator for
      // matching.
      SplitCompoundAtImplicitShadowCrossingCombinator(remaining);
      remaining.back().SetRelation(relation);
      break;
    }
  }
}

}  // namespace webf
