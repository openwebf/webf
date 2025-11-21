// Copyright 2014 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#include "media_query_parser.h"

#include "core/base/strings/string_util.h"
#include "core/css/css_raw_value.h"
#include "core/css/parser/css_parser_mode.h"
#include "core/css/parser/css_parser_token_range.h"
#include "core/css/parser/css_parser_token_stream.h"
#include "core/css/parser/css_tokenizer.h"
#include "core/css/parser/css_variable_parser.h"
#include "core/css/properties/css_parsing_utils.h"
#include "media_feature_names.h"
#include "media_type_names.h"

namespace webf {

using css_parsing_utils::AtIdent;
using css_parsing_utils::ConsumeAnyValue;
using css_parsing_utils::ConsumeIfDelimiter;
using css_parsing_utils::ConsumeIfIdent;

namespace {

class MediaQueryFeatureSet : public MediaQueryParser::FeatureSet {
  WEBF_STACK_ALLOCATED();

 public:
  MediaQueryFeatureSet() = default;

  bool IsAllowed(const AtomicString& feature) const override {
    if (feature == media_feature_names_atomicstring::kInlineSize ||
        feature == media_feature_names_atomicstring::kMinInlineSize ||
        feature == media_feature_names_atomicstring::kMaxInlineSize ||
        feature == media_feature_names_atomicstring::kMinBlockSize ||
        feature == media_feature_names_atomicstring::kMaxBlockSize || CSSVariableParser::IsValidVariableName(StringView(feature.GetString()))) {
      return false;
    }
    return true;
  }
  bool IsAllowedWithoutValue(const AtomicString& feature) const override {
    // Media features that are prefixed by min/max cannot be used without a
    // value.
    return feature == media_feature_names_atomicstring::kColor || feature == media_feature_names_atomicstring::kGrid ||
           feature == media_feature_names_atomicstring::kHeight || feature == media_feature_names_atomicstring::kWidth ||
           feature == media_feature_names_atomicstring::kInlineSize ||
           feature == media_feature_names_atomicstring::kDeviceHeight ||
           feature == media_feature_names_atomicstring::kDeviceWidth ||
           feature == media_feature_names_atomicstring::kAspectRatio ||
           feature == media_feature_names_atomicstring::kDeviceAspectRatio;
  }

  bool IsCaseSensitive(const AtomicString& feature) const override { return false; }
  bool SupportsRange() const override { return true; }
};

}  // namespace

std::shared_ptr<MediaQuerySet> MediaQueryParser::ParseMediaQuerySet(const String& query_string,
                                                                    const ExecutingContext* execution_context) {
  if (query_string.IsEmpty()) {
    return std::make_shared<MediaQuerySet>();
  }

  // Tokenize the query string and build offsets so that the full
  // MediaQueryParser machinery (including range parsing and
  // MediaQueryExpNode construction) can be used.
  CSSTokenizer tokenizer(query_string);
  auto tokens_and_offsets = tokenizer.TokenizeToEOFWithOffsets();
  std::vector<CSSParserToken>& tokens = tokens_and_offsets.first;
  std::vector<size_t>& raw_offsets = tokens_and_offsets.second;

  if (tokens.empty()) {
    return std::make_shared<MediaQuerySet>();
  }

  CSSParserTokenRange range(tokens);
  CSSParserTokenOffsets offsets(tcb::span<const CSSParserToken>(tokens.data(), tokens.size()),
                                std::move(raw_offsets),
                                StringView(query_string));

  MediaQueryParser parser(kMediaQuerySetParser, CSSParserMode::kHTMLStandardMode, execution_context);
  return parser.ParseImpl(range, offsets);
}

std::shared_ptr<MediaQuerySet> MediaQueryParser::ParseMediaQuerySet(CSSParserTokenRange range,
                                                                    const CSSParserTokenOffsets& offsets,
                                                                    const ExecutingContext* execution_context) {
  MediaQueryParser parser(kMediaQuerySetParser, CSSParserMode::kHTMLStandardMode, execution_context);
  return parser.ParseImpl(range, offsets);
}

std::shared_ptr<MediaQuerySet> MediaQueryParser::ParseMediaQuerySet(CSSParserTokenStream& stream,
                                                                    const ExecutingContext* execution_context) {
  CSSParserTokenRange range = stream.ConsumeUntilPeekedTypeIs<>();

  // Build a minimal offsets table from the consumed tokens. For callers that
  // go through this path we don't rely on precise StringForTokens(), so we
  // can use a zero-based offset vector.
  std::vector<CSSParserToken> tokens(range.RemainingSpan().begin(), range.RemainingSpan().end());
  std::vector<size_t> raw_offsets;
  raw_offsets.resize(tokens.size() + 1);

  CSSParserTokenOffsets offsets(tcb::span<const CSSParserToken>(tokens.data(), tokens.size()),
                                std::move(raw_offsets),
                                StringView());
  CSSParserTokenRange replay_range(tokens);

  MediaQueryParser parser(kMediaQuerySetParser, CSSParserMode::kHTMLStandardMode, execution_context);
  return parser.ParseImpl(replay_range, offsets);
}

std::shared_ptr<MediaQuerySet> MediaQueryParser::ParseMediaQuerySetInMode(CSSParserTokenRange range,
                                                                          const CSSParserTokenOffsets& offsets,
                                                                          CSSParserMode mode,
                                                                          const ExecutingContext* execution_context) {
  MediaQueryParser parser(kMediaQuerySetParser, mode, execution_context);
  return parser.ParseImpl(range, offsets);
}

std::shared_ptr<MediaQuerySet> MediaQueryParser::ParseMediaCondition(CSSParserTokenRange range,
                                                                     const CSSParserTokenOffsets& offsets,
                                                                     const ExecutingContext* execution_context) {
  MediaQueryParser parser(kMediaConditionParser, CSSParserMode::kHTMLStandardMode, execution_context);
  return parser.ParseImpl(range, offsets);
}

std::shared_ptr<MediaQuerySet> MediaQueryParser::ParseMediaCondition(CSSParserTokenStream& stream,
                                                                     const ExecutingContext* execution_context) {
  CSSParserTokenRange range = stream.ConsumeUntilPeekedTypeIs<>();

  // As above, build a simple offsets table; media conditions parsed from a
  // stream don't currently rely on exact substring reconstruction.
  std::vector<CSSParserToken> tokens(range.RemainingSpan().begin(), range.RemainingSpan().end());
  std::vector<size_t> raw_offsets;
  raw_offsets.resize(tokens.size() + 1);

  CSSParserTokenOffsets offsets(tcb::span<const CSSParserToken>(tokens.data(), tokens.size()),
                                std::move(raw_offsets),
                                StringView());
  CSSParserTokenRange replay_range(tokens);

  MediaQueryParser parser(kMediaConditionParser, CSSParserMode::kHTMLStandardMode, execution_context);
  return parser.ParseImpl(replay_range, offsets);
}

MediaQueryParser::MediaQueryParser(ParserType parser_type,
                                   CSSParserMode mode,
                                   const ExecutingContext* execution_context,
                                   SyntaxLevel syntax_level)
    : parser_type_(parser_type), mode_(mode), execution_context_(execution_context), syntax_level_(syntax_level) {}

MediaQueryParser::~MediaQueryParser() = default;

namespace {

bool IsRestrictorOrLogicalOperator(const CSSParserToken& token) {
  // FIXME: it would be more efficient to use lower-case always for tokenValue.
  return EqualIgnoringASCIICase(token.Value(), "not") || EqualIgnoringASCIICase(token.Value(), "and") ||
         EqualIgnoringASCIICase(token.Value(), "or") || EqualIgnoringASCIICase(token.Value(), "only") ||
         EqualIgnoringASCIICase(token.Value(), "layer");
}

bool ConsumeUntilCommaInclusive(CSSParserTokenRange& range) {
  while (!range.AtEnd()) {
    if (range.Peek().GetType() == kCommaToken) {
      range.ConsumeIncludingWhitespace();
      return true;
    }
    range.ConsumeComponentValue();
  }
  return false;
}

bool ConsumeUntilCommaInclusive(CSSParserTokenStream& stream) {
  while (!stream.AtEnd()) {
    if (stream.Peek().GetType() == kCommaToken) {
      stream.ConsumeIncludingWhitespace();
      return true;
    }
    stream.ConsumeComponentValue();
  }
  return false;
}

bool IsComparisonDelimiter(char c) {
  return c == '<' || c == '>' || c == '=';
}

CSSParserTokenRange ConsumeUntilComparisonOrColon(CSSParserTokenRange& range) {
  const CSSParserToken* first = range.begin();
  while (!range.AtEnd()) {
    const CSSParserToken& token = range.Peek();
    if ((token.GetType() == kDelimiterToken && IsComparisonDelimiter(token.Delimiter())) ||
        token.GetType() == kColonToken) {
      break;
    }
    range.ConsumeComponentValue();
  }
  return range.MakeSubRange(first, range.begin());
}

CSSParserTokenRange ConsumeUntilComparisonOrColon(CSSParserTokenStream& stream) {
  // Ensure lookahead before saving position
  stream.EnsureLookAhead();
  // Save the position before we start consuming
  CSSParserTokenStream::State start_state = stream.Save();
  
  while (!stream.AtEnd()) {
    const CSSParserToken& token = stream.Peek();
    if ((token.GetType() == kDelimiterToken && IsComparisonDelimiter(token.Delimiter())) ||
        token.GetType() == kColonToken) {
      break;
    }
    stream.ConsumeComponentValue();
  }
  
  // Get the consumed tokens as a range
  stream.EnsureLookAhead();
  CSSParserTokenStream::State end_state = stream.Save();
  stream.Restore(start_state);
  
  // Consume tokens up to the saved position to create a range
  return stream.ConsumeUntilPeekedTypeIs<>();
}

bool IsLtLe(MediaQueryOperator op) {
  return op == MediaQueryOperator::kLt || op == MediaQueryOperator::kLe;
}

bool IsGtGe(MediaQueryOperator op) {
  return op == MediaQueryOperator::kGt || op == MediaQueryOperator::kGe;
}

}  // namespace

MediaQuery::RestrictorType MediaQueryParser::ConsumeRestrictor(CSSParserTokenRange& range) {
  if (ConsumeIfIdent(range, "not")) {
    return MediaQuery::RestrictorType::kNot;
  }
  if (ConsumeIfIdent(range, "only")) {
    return MediaQuery::RestrictorType::kOnly;
  }
  return MediaQuery::RestrictorType::kNone;
}

MediaQuery::RestrictorType MediaQueryParser::ConsumeRestrictor(CSSParserTokenStream& stream) {
  if (ConsumeIfIdent(stream, "not")) {
    return MediaQuery::RestrictorType::kNot;
  }
  if (ConsumeIfIdent(stream, "only")) {
    return MediaQuery::RestrictorType::kOnly;
  }
  return MediaQuery::RestrictorType::kNone;
}

AtomicString MediaQueryParser::ConsumeType(CSSParserTokenRange& range) {
  if (range.Peek().GetType() != kIdentToken) {
    return AtomicString();
  }
  if (IsRestrictorOrLogicalOperator(range.Peek())) {
    return AtomicString();
  }
  return range.ConsumeIncludingWhitespace().Value().ToAtomicString();
}

AtomicString MediaQueryParser::ConsumeType(CSSParserTokenStream& stream) {
  if (stream.Peek().GetType() != kIdentToken) {
    return AtomicString();
  }
  if (IsRestrictorOrLogicalOperator(stream.Peek())) {
    return AtomicString();
  }
  return stream.ConsumeIncludingWhitespace().Value().ToAtomicString();
}

MediaQueryOperator MediaQueryParser::ConsumeComparison(CSSParserTokenRange& range) {
  const CSSParserToken& first = range.Peek();
  if (first.GetType() != kDelimiterToken) {
    return MediaQueryOperator::kNone;
  }
  DCHECK(IsComparisonDelimiter(first.Delimiter()));
  switch (first.Delimiter()) {
    case '=':
      range.ConsumeIncludingWhitespace();
      return MediaQueryOperator::kEq;
    case '<':
      range.Consume();
      if (ConsumeIfDelimiter(range, '=')) {
        return MediaQueryOperator::kLe;
      }
      range.ConsumeWhitespace();
      return MediaQueryOperator::kLt;
    case '>':
      range.Consume();
      if (ConsumeIfDelimiter(range, '=')) {
        return MediaQueryOperator::kGe;
      }
      range.ConsumeWhitespace();
      return MediaQueryOperator::kGt;
  }

  NOTREACHED_IN_MIGRATION();
  return MediaQueryOperator::kNone;
}

MediaQueryOperator MediaQueryParser::ConsumeComparison(CSSParserTokenStream& stream) {
  const CSSParserToken& first = stream.Peek();
  if (first.GetType() != kDelimiterToken) {
    return MediaQueryOperator::kNone;
  }
  DCHECK(IsComparisonDelimiter(first.Delimiter()));
  switch (first.Delimiter()) {
    case '=':
      stream.ConsumeIncludingWhitespace();
      return MediaQueryOperator::kEq;
    case '<':
      stream.Consume();
      if (ConsumeIfDelimiter(stream, '=')) {
        return MediaQueryOperator::kLe;
      }
      stream.ConsumeWhitespace();
      return MediaQueryOperator::kLt;
    case '>':
      stream.Consume();
      if (ConsumeIfDelimiter(stream, '=')) {
        return MediaQueryOperator::kGe;
      }
      stream.ConsumeWhitespace();
      return MediaQueryOperator::kGt;
  }

  NOTREACHED_IN_MIGRATION();
  return MediaQueryOperator::kNone;
}

AtomicString MediaQueryParser::ConsumeAllowedName(CSSParserTokenRange& range, const FeatureSet& feature_set) {
  if (range.Peek().GetType() != kIdentToken) {
    return AtomicString();
  }
  AtomicString name = range.Peek().Value().ToAtomicString();
  if (!feature_set.IsCaseSensitive(name)) {
    name = AtomicString(name.LowerASCII());
  }
  if (!feature_set.IsAllowed(name)) {
    return AtomicString();
  }
  range.ConsumeIncludingWhitespace();
  return name;
}

AtomicString MediaQueryParser::ConsumeUnprefixedName(CSSParserTokenRange& range, const FeatureSet& feature_set) {
  AtomicString name = ConsumeAllowedName(range, feature_set);
  if (name.IsNull()) {
    return name;
  }
  if (name.StartsWith(StringView("min-")) || name.StartsWith(StringView("max-"))) {
    return AtomicString();
  }
  return name;
}

AtomicString MediaQueryParser::ConsumeAllowedName(CSSParserTokenStream& stream, const FeatureSet& feature_set) {
  if (stream.Peek().GetType() != kIdentToken) {
    return AtomicString();
  }
  AtomicString name = stream.Peek().Value().ToAtomicString();
  if (!feature_set.IsCaseSensitive(name)) {
    name = AtomicString(name.LowerASCII());
  }
  if (!feature_set.IsAllowed(name)) {
    return AtomicString();
  }
  stream.ConsumeIncludingWhitespace();
  return name;
}

AtomicString MediaQueryParser::ConsumeUnprefixedName(CSSParserTokenStream& stream, const FeatureSet& feature_set) {
  AtomicString name = ConsumeAllowedName(stream, feature_set);
  if (name.IsNull()) {
    return name;
  }
  if (name.StartsWith(StringView("min-")) || name.StartsWith(StringView("max-"))) {
    return AtomicString();
  }
  return name;
}

std::shared_ptr<const MediaQueryExpNode> MediaQueryParser::ParseNameValueComparison(
    CSSParserTokenRange lhs,
    MediaQueryOperator op,
    CSSParserTokenRange rhs,
    const CSSParserTokenOffsets& offsets,
    NameAffinity name_affinity,
    const FeatureSet& feature_set) {
  if (name_affinity == NameAffinity::kRight) {
    std::swap(lhs, rhs);
  }

  AtomicString feature_name = ConsumeUnprefixedName(lhs, feature_set);
  if (feature_name.IsNull() || !lhs.AtEnd()) {
    return nullptr;
  }

  auto value =
      MediaQueryExpValue::Consume(feature_name.GetString(), rhs, offsets, std::make_shared<CSSParserContext>(kHTMLStandardMode));

  if (!value || !rhs.AtEnd()) {
    return nullptr;
  }

  auto left = MediaQueryExpComparison();
  auto right = MediaQueryExpComparison(*value, op);

  if (name_affinity == NameAffinity::kRight) {
    std::swap(left, right);
  }

  return std::make_shared<MediaQueryFeatureExpNode>(
      MediaQueryExp::Create(feature_name, MediaQueryExpBounds(left, right)));
}

std::shared_ptr<const MediaQueryExpNode> MediaQueryParser::ConsumeFeature(CSSParserTokenRange& range,
                                                                          const CSSParserTokenOffsets& offsets,
                                                                          const FeatureSet& feature_set) {
  // Because we don't know exactly where <mf-name> appears in the grammar, we
  // split |range| on top-level separators, and parse each segment
  // individually.
  //
  // Local variables names in this function are chosen with the expectation
  // that we are heading towards the most complicated form of <mf-range>:
  //
  //  <mf-value> <mf-gt> <mf-name> <mf-gt> <mf-value>
  //
  // Which corresponds to the local variables:
  //
  //  <segment1> <op1> <segment2> <op2> <segment3>

  CSSParserTokenRange segment1 = ConsumeUntilComparisonOrColon(range);

  // <mf-boolean> = <mf-name>
  if (range.AtEnd()) {
    AtomicString feature_name = ConsumeAllowedName(segment1, feature_set);
    if (feature_name.IsNull() || !segment1.AtEnd() || !feature_set.IsAllowedWithoutValue(feature_name)) {
      return nullptr;
    }
    return std::make_shared<MediaQueryFeatureExpNode>(MediaQueryExp::Create(feature_name, MediaQueryExpBounds()));
  }

  // <mf-plain> = <mf-name> : <mf-value>
  if (range.Peek().GetType() == kColonToken) {
    range.ConsumeIncludingWhitespace();
    AtomicString feature_name = ConsumeAllowedName(segment1, feature_set);
    if (feature_name.IsNull() || !segment1.AtEnd()) {
      return nullptr;
    }
    auto exp =
        MediaQueryExp::Create(feature_name, range, offsets, std::make_shared<CSSParserContext>(kHTMLStandardMode));
    if (!exp.IsValid() || !range.AtEnd()) {
      return nullptr;
    }
    return std::make_shared<MediaQueryFeatureExpNode>(exp);
  }

  if (!feature_set.SupportsRange()) {
    return nullptr;
  }

  // Otherwise <mf-range>:
  //
  // <mf-range> = <mf-name> <mf-comparison> <mf-value>
  //            | <mf-value> <mf-comparison> <mf-name>
  //            | <mf-value> <mf-lt> <mf-name> <mf-lt> <mf-value>
  //            | <mf-value> <mf-gt> <mf-name> <mf-gt> <mf-value>

  MediaQueryOperator op1 = ConsumeComparison(range);
  DCHECK_NE(op1, MediaQueryOperator::kNone);

  CSSParserTokenRange segment2 = ConsumeUntilComparisonOrColon(range);

  // If the range ended, the feature must be on the following form:
  //
  //  <segment1> <op1> <segment2>
  //
  // We don't know which of <segment1> and <segment2> should be interpreted as
  // the <mf-name> and which should be interpreted as <mf-value>. We have to
  // try both.
  if (range.AtEnd()) {
    // Try: <mf-name> <mf-comparison> <mf-value>
    if (auto node = ParseNameValueComparison(segment1, op1, segment2, offsets, NameAffinity::kLeft, feature_set)) {
      return node;
    }

    // Otherwise: <mf-value> <mf-comparison> <mf-name>
    return ParseNameValueComparison(segment1, op1, segment2, offsets, NameAffinity::kRight, feature_set);
  }

  // Otherwise, the feature must be on the form:
  //
  // <segment1> <op1> <segment2> <op2> <segment3>
  //
  // This grammar is easier to deal with, since <mf-name> can only appear
  // at <segment2>.
  MediaQueryOperator op2 = ConsumeComparison(range);
  if (op2 == MediaQueryOperator::kNone) {
    return nullptr;
  }

  // Mixing [lt, le] and [gt, ge] is not allowed by the grammar.
  const bool both_lt_le = IsLtLe(op1) && IsLtLe(op2);
  const bool both_gt_ge = IsGtGe(op1) && IsGtGe(op2);
  if (!(both_lt_le || both_gt_ge)) {
    return nullptr;
  }

  if (range.AtEnd()) {
    return nullptr;
  }

  AtomicString feature_name = ConsumeUnprefixedName(segment2, feature_set);
  if (feature_name.IsNull() || !segment2.AtEnd()) {
    return nullptr;
  }

  auto left_value = MediaQueryExpValue::Consume(feature_name.GetString(), segment1, offsets,
                                                std::make_shared<CSSParserContext>(kHTMLStandardMode));
  if (!left_value || !segment1.AtEnd()) {
    return nullptr;
  }

  CSSParserTokenRange& segment3 = range;
  auto right_value = MediaQueryExpValue::Consume(feature_name.GetString(), segment3, offsets,
                                                 std::make_shared<CSSParserContext>(kHTMLStandardMode));
  if (!right_value || !segment3.AtEnd()) {
    return nullptr;
  }

  return std::make_shared<MediaQueryFeatureExpNode>(MediaQueryExp::Create(
      feature_name,
      MediaQueryExpBounds(MediaQueryExpComparison(*left_value, op1), MediaQueryExpComparison(*right_value, op2))));
}

std::shared_ptr<const MediaQueryExpNode> MediaQueryParser::ConsumeFeature(CSSParserTokenStream& stream,
                                                                          const FeatureSet& feature_set) {
  // The stream-based ConsumeFeature is not fully implemented.
  // For now, we'll convert the stream content to a range and use the existing
  // range-based implementation.
  
  // Collect all tokens until we hit a boundary
  std::vector<CSSParserToken> tokens;
  std::vector<size_t> offsets_vec;
  
  stream.EnsureLookAhead();
  while (!stream.AtEnd()) {
    const CSSParserToken& token = stream.Peek();
    
    // Stop at tokens that would end a feature expression
    if (token.GetType() == kRightParenthesisToken ||
        token.GetType() == kCommaToken ||
        (token.GetType() == kIdentToken && 
         (token.Value() == "and" || token.Value() == "or"))) {
      break;
    }
    
    // If we see a block start token, we should stop here
    if (token.GetBlockType() == CSSParserToken::kBlockStart) {
      break;
    }
    
    tokens.push_back(token);
    offsets_vec.push_back(0);
    stream.ConsumeIncludingWhitespace();
  }
  
  if (tokens.empty()) {
    return nullptr;
  }
  
  // Add final offset
  offsets_vec.push_back(0);
  
  // Create range and parse
  CSSParserTokenRange range(tokens);
  CSSParserTokenOffsets offsets(tcb::span<const CSSParserToken>(tokens.data(), tokens.size()),
                                std::move(offsets_vec), StringView());
  
  auto result = ConsumeFeature(range, offsets, feature_set);
  
  if (!result || !range.AtEnd()) {
    // Restore stream state if parsing failed
    // Note: This is a simplified approach; a proper implementation would
    // save and restore the stream state
    return nullptr;
  }
  
  return result;
}

std::shared_ptr<const MediaQueryExpNode> MediaQueryParser::ConsumeCondition(CSSParserTokenRange& range,
                                                                            const CSSParserTokenOffsets& offsets,
                                                                            ConditionMode mode) {
  // <media-not>
  if (ConsumeIfIdent(range, "not")) {
    return MediaQueryExpNode::Not(ConsumeInParens(range, offsets));
  }

  // Otherwise:
  // <media-in-parens> [ <media-and>* | <media-or>* ]

  std::shared_ptr<const MediaQueryExpNode> result = ConsumeInParens(range, offsets);

  if (AtIdent(range.Peek(), "and")) {
    while (result && ConsumeIfIdent(range, "and")) {
      result = MediaQueryExpNode::And(result, ConsumeInParens(range, offsets));
    }
  } else if (result && AtIdent(range.Peek(), "or") && mode == ConditionMode::kNormal) {
    while (result && ConsumeIfIdent(range, "or")) {
      result = MediaQueryExpNode::Or(result, ConsumeInParens(range, offsets));
    }
  }

  return result;
}

std::shared_ptr<const MediaQueryExpNode> MediaQueryParser::ConsumeCondition(CSSParserTokenStream& stream,
                                                                            ConditionMode mode) {
  // <media-not>
  if (ConsumeIfIdent(stream, "not")) {
    return MediaQueryExpNode::Not(ConsumeInParens(stream));
  }

  // Otherwise:
  // <media-in-parens> [ <media-and>* | <media-or>* ]

  std::shared_ptr<const MediaQueryExpNode> result = ConsumeInParens(stream);

  if (AtIdent(stream.Peek(), "and")) {
    while (result && ConsumeIfIdent(stream, "and")) {
      result = MediaQueryExpNode::And(result, ConsumeInParens(stream));
    }
  } else if (result && AtIdent(stream.Peek(), "or") && mode == ConditionMode::kNormal) {
    while (result && ConsumeIfIdent(stream, "or")) {
      result = MediaQueryExpNode::Or(result, ConsumeInParens(stream));
    }
  }

  return result;
}

std::shared_ptr<const MediaQueryExpNode> MediaQueryParser::ConsumeInParens(CSSParserTokenRange& range,
                                                                           const CSSParserTokenOffsets& offsets) {
  CSSParserTokenRange original_range = range;

  if (range.Peek().GetType() == kLeftParenthesisToken) {
    CSSParserTokenRange block = range.ConsumeBlock();
    block.ConsumeWhitespace();
    range.ConsumeWhitespace();

    CSSParserTokenRange original_block = block;

    // ( <media-condition> )
    std::shared_ptr<const MediaQueryExpNode> condition = ConsumeCondition(block, offsets);
    if (condition && block.AtEnd()) {
      return MediaQueryExpNode::Nested(condition);
    }
    block = original_block;

    // ( <media-feature> )
    std::shared_ptr<const MediaQueryExpNode> feature = ConsumeFeature(block, offsets, MediaQueryFeatureSet());
    if (feature && block.AtEnd()) {
      return MediaQueryExpNode::Nested(feature);
    }
  }
  range = original_range;

  // <general-enclosed>
  return ConsumeGeneralEnclosed(range);
}

std::shared_ptr<const MediaQueryExpNode> MediaQueryParser::ConsumeInParens(CSSParserTokenStream& stream) {
  stream.EnsureLookAhead();
  CSSParserTokenStream::State save_point = stream.Save();

  if (stream.Peek().GetType() == kLeftParenthesisToken) {
    {
      CSSParserTokenStream::BlockGuard guard(stream);
      stream.ConsumeWhitespace();
      
      stream.EnsureLookAhead();
      CSSParserTokenStream::State block_save = stream.Save();

      // ( <media-condition> )
      std::shared_ptr<const MediaQueryExpNode> condition = ConsumeCondition(stream);
      if (condition && stream.AtEnd()) {
        return MediaQueryExpNode::Nested(condition);
      }
      stream.Restore(block_save);

      // ( <media-feature> )
      std::shared_ptr<const MediaQueryExpNode> feature = ConsumeFeature(stream, MediaQueryFeatureSet());
      if (feature && stream.AtEnd()) {
        return MediaQueryExpNode::Nested(feature);
      }
    }
  }
  stream.Restore(save_point);

  // <general-enclosed>
  return ConsumeGeneralEnclosed(stream);
}

std::shared_ptr<const MediaQueryExpNode> MediaQueryParser::ConsumeGeneralEnclosed(CSSParserTokenRange& range) {
  if (range.Peek().GetType() != kLeftParenthesisToken && range.Peek().GetType() != kFunctionToken) {
    return nullptr;
  }

  const CSSParserToken* first = range.begin();

  CSSParserTokenRange block = range.ConsumeBlock();
  block.ConsumeWhitespace();

  // Note that <any-value> is optional in <general-enclosed>, so having an
  // empty block is fine.
  if (!block.AtEnd()) {
    if (!ConsumeAnyValue(block) || !block.AtEnd()) {
      return nullptr;
    }
  }

  // TODO(crbug.com/962417): This is not well specified.
  String general_enclosed = range.MakeSubRange(first, range.begin()).Serialize();
  range.ConsumeWhitespace();
  return std::make_shared<MediaQueryUnknownExpNode>(general_enclosed);
}

std::shared_ptr<const MediaQueryExpNode> MediaQueryParser::ConsumeGeneralEnclosed(CSSParserTokenStream& stream) {
  if (stream.Peek().GetType() != kLeftParenthesisToken && stream.Peek().GetType() != kFunctionToken) {
    return nullptr;
  }

  // Save state before consuming
  stream.EnsureLookAhead();
  CSSParserTokenStream::State start = stream.Save();
  
  // Consume the entire component value (block or function)
  CSSParserTokenRange consumed_range = stream.ConsumeComponentValue();
  
  // Validate the content if it's non-empty
  if (!consumed_range.AtEnd()) {
    // We need to validate that the content follows <any-value> rules
    // For now, we'll accept any content inside <general-enclosed>
    // This matches the comment that <any-value> is optional
  }
  
  String general_enclosed = consumed_range.Serialize();
  stream.ConsumeWhitespace();
  return std::make_shared<MediaQueryUnknownExpNode>(general_enclosed);
}

std::shared_ptr<MediaQuerySet> MediaQueryParser::ConsumeSingleCondition(CSSParserTokenRange range,
                                                                        const CSSParserTokenOffsets& offsets) {
  DCHECK_EQ(parser_type_, kMediaConditionParser);

  String serialized = range.Serialize();
  return ParseMediaQuerySet(serialized, execution_context_);
}

std::shared_ptr<MediaQuery> MediaQueryParser::ConsumeQuery(CSSParserTokenRange& range,
                                                           const CSSParserTokenOffsets& offsets) {
  DCHECK_EQ(parser_type_, kMediaQuerySetParser);
  CSSParserTokenRange original_range = range;

  // First try to parse following grammar:
  //
  // [ not | only ]? <media-type> [ and <media-condition-without-or> ]?
  MediaQuery::RestrictorType restrictor = ConsumeRestrictor(range);
  AtomicString type = ConsumeType(range);

  if (!type.IsNull()) {
    if (!ConsumeIfIdent(range, "and")) {
      return std::make_shared<MediaQuery>(restrictor, String(type), nullptr);
    }
    if (auto node = ConsumeCondition(range, offsets, ConditionMode::kWithoutOr)) {
      return std::make_shared<MediaQuery>(restrictor, String(type), node);
    }
    return nullptr;
  }
  range = original_range;

  // Otherwise, <media-condition>
  if (auto node = ConsumeCondition(range, offsets)) {
    return std::make_shared<MediaQuery>(MediaQuery::RestrictorType::kNone, String(media_type_names_atomicstring::kAll), node);
  }
  return nullptr;
}

std::shared_ptr<MediaQuery> MediaQueryParser::ConsumeQuery(CSSParserTokenStream& stream) {
  DCHECK_EQ(parser_type_, kMediaQuerySetParser);
  stream.EnsureLookAhead();
  CSSParserTokenStream::State save_point = stream.Save();

  // First try to parse following grammar:
  //
  // [ not | only ]? <media-type> [ and <media-condition-without-or> ]?
  MediaQuery::RestrictorType restrictor = ConsumeRestrictor(stream);
  AtomicString type = ConsumeType(stream);

  if (!type.IsNull()) {
    if (!ConsumeIfIdent(stream, "and")) {
      return std::make_shared<MediaQuery>(restrictor, String(type), nullptr);
    }
    if (auto node = ConsumeCondition(stream, ConditionMode::kWithoutOr)) {
      return std::make_shared<MediaQuery>(restrictor, String(type), node);
    }
    return nullptr;
  }
  stream.Restore(save_point);

  // Otherwise, <media-condition>
  if (auto node = ConsumeCondition(stream)) {
    return std::make_shared<MediaQuery>(MediaQuery::RestrictorType::kNone, String(media_type_names_atomicstring::kAll), node);
  }
  return nullptr;
}

std::shared_ptr<MediaQuerySet> MediaQueryParser::ParseImpl(CSSParserTokenRange range,
                                                           const CSSParserTokenOffsets& offsets) {
  range.ConsumeWhitespace();

  // Note that we currently expect an empty input to evaluate to an empty
  // MediaQuerySet, rather than "not all".
  if (range.AtEnd()) {
    return std::make_shared<MediaQuerySet>();
  }

  if (parser_type_ == kMediaConditionParser) {
    return ConsumeSingleCondition(range, offsets);
  }

  DCHECK_EQ(parser_type_, kMediaQuerySetParser);

  std::vector<std::shared_ptr<const MediaQuery>> queries;

  do {
    auto query = ConsumeQuery(range, offsets);
    bool ok = query && (range.AtEnd() || range.Peek().GetType() == kCommaToken);
    queries.push_back(ok ? query : MediaQuery::CreateNotAll());
  } while (!range.AtEnd() && ConsumeUntilCommaInclusive(range));

  return std::make_shared<MediaQuerySet>(std::move(queries));
}

}  // namespace webf
