// Copyright 2021 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#include "container_query_parser.h"
#include "core/css/parser/css_variable_parser.h"
#include "core/css/properties/css_parsing_utils.h"
#include "media_feature_names.h"

namespace webf {

using css_parsing_utils::AtIdent;
using css_parsing_utils::ConsumeIfIdent;

namespace {

// not <func> | <func> [ and <func> ]* | <func> [ or <func> ]*
//
// For example, if <func> is a function that can parse <container-query>,
// then ConsumeNotAndOr can be used to parse <container-condition>:
//
// https://drafts.csswg.org/css-contain-3/#typedef-container-condition
template <typename Func>
std::shared_ptr<const MediaQueryExpNode> ConsumeNotAndOr(Func func, CSSParserTokenRange& range) {
  if (ConsumeIfIdent(range, "not")) {
    return MediaQueryExpNode::Not(func(range));
  }

  std::shared_ptr<const MediaQueryExpNode> result = func(range);

  if (AtIdent(range.Peek(), "and")) {
    while (result && ConsumeIfIdent(range, "and")) {
      result = MediaQueryExpNode::And(result, func(range));
    }
  } else if (AtIdent(range.Peek(), "or")) {
    while (ConsumeIfIdent(range, "or")) {
      result = MediaQueryExpNode::Or(result, func(range));
    }
  }

  return result;
}

class SizeFeatureSet : public MediaQueryParser::FeatureSet {
  WEBF_STACK_ALLOCATED();

 public:
  bool IsAllowed(const std::string& feature) const override {
    return feature == media_feature_names_stdstring::kWidth || feature == media_feature_names_stdstring::kMinWidth ||
           feature == media_feature_names_stdstring::kMaxWidth || feature == media_feature_names_stdstring::kHeight ||
           feature == media_feature_names_stdstring::kMinHeight ||
           feature == media_feature_names_stdstring::kMaxHeight ||
           feature == media_feature_names_stdstring::kInlineSize ||
           feature == media_feature_names_stdstring::kMinInlineSize ||
           feature == media_feature_names_stdstring::kMaxInlineSize ||
           feature == media_feature_names_stdstring::kMinBlockSize ||
           feature == media_feature_names_stdstring::kMaxBlockSize ||
           feature == media_feature_names_stdstring::kAspectRatio ||
           feature == media_feature_names_stdstring::kMinAspectRatio ||
           feature == media_feature_names_stdstring::kMaxAspectRatio;
  }
  bool IsAllowedWithoutValue(const std::string& feature) const override {
    return feature == media_feature_names_stdstring::kWidth || feature == media_feature_names_stdstring::kHeight ||
           feature == media_feature_names_stdstring::kInlineSize ||
           feature == media_feature_names_stdstring::kAspectRatio;
  }
  bool IsCaseSensitive(const std::string& feature) const override { return false; }
  bool SupportsRange() const override { return true; }
};

class StyleFeatureSet : public MediaQueryParser::FeatureSet {
  WEBF_STACK_ALLOCATED();

 public:
  bool IsAllowed(const std::string& feature) const override {
    // TODO(crbug.com/1302630): Only support querying custom properties for now.
    return CSSVariableParser::IsValidVariableName(feature);
  }
  bool IsAllowedWithoutValue(const std::string& feature) const override { return true; }
  bool IsCaseSensitive(const std::string& feature) const override {
    // TODO(crbug.com/1302630): non-custom properties are case-insensitive.
    return true;
  }
  bool SupportsRange() const override { return false; }
};

class StateFeatureSet : public MediaQueryParser::FeatureSet {
  WEBF_STACK_ALLOCATED();

 public:
  bool IsAllowed(const std::string& feature) const override { return false; }
  bool IsAllowedWithoutValue(const std::string& feature) const override { return true; }
  bool IsCaseSensitive(const std::string& feature) const override { return false; }
  bool SupportsRange() const override { return false; }
};

}  // namespace

ContainerQueryParser::ContainerQueryParser(const CSSParserContext& context)
    : context_(context),
      media_query_parser_(MediaQueryParser::kMediaQuerySetParser,
                          kHTMLStandardMode,
                          context.GetExecutingContext(),
                          MediaQueryParser::SyntaxLevel::kLevel4) {}

std::shared_ptr<const MediaQueryExpNode> ContainerQueryParser::ParseCondition(const std::string& value) {
  CSSTokenizer tokenizer(value);
  auto [tokens, raw_offsets] = tokenizer.TokenizeToEOFWithOffsets();
  CSSParserTokenRange range(tokens);
  CSSParserTokenOffsets offsets(tokens, std::move(raw_offsets), value);
  return ParseCondition(range, offsets);
}

std::shared_ptr<const MediaQueryExpNode> ContainerQueryParser::ParseCondition(CSSParserTokenRange range,
                                                                              const CSSParserTokenOffsets& offsets) {
  range.ConsumeWhitespace();
  std::shared_ptr<const MediaQueryExpNode> node = ConsumeContainerCondition(range, offsets);
  if (!range.AtEnd()) {
    return nullptr;
  }
  return node;
}

// <query-in-parens> = ( <container-condition> )
//                   | ( <size-feature> )
//                   | style( <style-query> )
//                   | <general-enclosed>
std::shared_ptr<const MediaQueryExpNode> ContainerQueryParser::ConsumeQueryInParens(
    CSSParserTokenRange& range,
    const CSSParserTokenOffsets& offsets) {
  CSSParserTokenRange original_range = range;

  if (range.Peek().GetType() == kLeftParenthesisToken) {
    // ( <size-feature> ) | ( <container-condition> )
    CSSParserTokenRange block = range.ConsumeBlock();
    block.ConsumeWhitespace();
    range.ConsumeWhitespace();

    CSSParserTokenRange original_block = block;
    // <size-feature>
    std::shared_ptr<const MediaQueryExpNode> query = ConsumeFeature(block, offsets, SizeFeatureSet());
    if (query && block.AtEnd()) {
      return MediaQueryExpNode::Nested(query);
    }
    block = original_block;

    // <container-condition>
    std::shared_ptr<const MediaQueryExpNode> condition = ConsumeContainerCondition(block, offsets);
    if (condition && block.AtEnd()) {
      return MediaQueryExpNode::Nested(condition);
    }
  } else if (range.Peek().GetType() == kFunctionToken && range.Peek().FunctionId() == CSSValueID::kStyle) {
    // style( <style-query> )
    CSSParserTokenRange block = range.ConsumeBlock();
    block.ConsumeWhitespace();
    range.ConsumeWhitespace();

    if (std::shared_ptr<const MediaQueryExpNode> query = ConsumeFeatureQuery(block, offsets, StyleFeatureSet())) {
      return MediaQueryExpNode::Function(query, "style");
    }
  } else if (range.Peek().GetType() == kFunctionToken && range.Peek().FunctionId() == CSSValueID::kScrollState) {
    // scroll-state(stuck: [ none | top | left | right | bottom | inset-* ] )
    // scroll-state(snapped: [ none | block | inline | x | y ] )
    CSSParserTokenRange block = range.ConsumeBlock();
    block.ConsumeWhitespace();
    range.ConsumeWhitespace();

    if (std::shared_ptr<const MediaQueryExpNode> query = ConsumeFeatureQuery(block, offsets, StateFeatureSet())) {
      return MediaQueryExpNode::Function(query, "scroll-state");
    }
  }
  range = original_range;

  // <general-enclosed>
  return media_query_parser_.ConsumeGeneralEnclosed(range);
}

std::shared_ptr<const MediaQueryExpNode> ContainerQueryParser::ConsumeContainerCondition(
    CSSParserTokenRange& range,
    const CSSParserTokenOffsets& offsets) {
  return ConsumeNotAndOr(
      [this, offsets](CSSParserTokenRange& range) { return this->ConsumeQueryInParens(range, offsets); }, range);
}

std::shared_ptr<const MediaQueryExpNode> ContainerQueryParser::ConsumeFeatureQuery(CSSParserTokenRange& range,
                                                                                   const CSSParserTokenOffsets& offsets,
                                                                                   const FeatureSet& feature_set) {
  CSSParserTokenRange original_range = range;

  if (std::shared_ptr<const MediaQueryExpNode> feature = ConsumeFeature(range, offsets, feature_set)) {
    return feature;
  }
  range = original_range;

  if (std::shared_ptr<const MediaQueryExpNode> node = ConsumeFeatureCondition(range, offsets, feature_set)) {
    return node;
  }

  return nullptr;
}

std::shared_ptr<const MediaQueryExpNode> ContainerQueryParser::ConsumeFeatureQueryInParens(
    CSSParserTokenRange& range,
    const CSSParserTokenOffsets& offsets,
    const FeatureSet& feature_set) {
  CSSParserTokenRange original_range = range;

  if (range.Peek().GetType() == kLeftParenthesisToken) {
    auto block = range.ConsumeBlock();
    block.ConsumeWhitespace();
    range.ConsumeWhitespace();
    std::shared_ptr<const MediaQueryExpNode> query = ConsumeFeatureQuery(block, offsets, feature_set);
    if (query && block.AtEnd()) {
      return MediaQueryExpNode::Nested(query);
    }
  }
  range = original_range;

  return media_query_parser_.ConsumeGeneralEnclosed(range);
}

std::shared_ptr<const MediaQueryExpNode> ContainerQueryParser::ConsumeFeatureCondition(
    CSSParserTokenRange& range,
    const CSSParserTokenOffsets& offsets,
    const FeatureSet& feature_set) {
  return ConsumeNotAndOr(
      [this, &offsets, &feature_set](CSSParserTokenRange& range) {
        return this->ConsumeFeatureQueryInParens(range, offsets, feature_set);
      },
      range);
}

std::shared_ptr<const MediaQueryExpNode> ContainerQueryParser::ConsumeFeature(CSSParserTokenRange& range,
                                                                              const CSSParserTokenOffsets& offsets,
                                                                              const FeatureSet& feature_set) {
  return media_query_parser_.ConsumeFeature(range, offsets, feature_set);
}

}  // namespace webf