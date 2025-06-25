// Copyright 2021 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#include "container_query_parser.h"
#include "core/css/parser/css_parser_token_stream.h"
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
std::shared_ptr<const MediaQueryExpNode> ConsumeNotAndOr(Func func, CSSParserTokenStream& stream) {
  if (ConsumeIfIdent(stream, "not")) {
    return MediaQueryExpNode::Not(func(stream));
  }

  std::shared_ptr<const MediaQueryExpNode> result = func(stream);

  if (AtIdent(stream.Peek(), "and")) {
    while (result && ConsumeIfIdent(stream, "and")) {
      result = MediaQueryExpNode::And(result, func(stream));
    }
  } else if (AtIdent(stream.Peek(), "or")) {
    while (ConsumeIfIdent(stream, "or")) {
      result = MediaQueryExpNode::Or(result, func(stream));
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
  CSSParserTokenStream stream(tokenizer);
  return ParseCondition(stream);
}

// Stream implementations
std::shared_ptr<const MediaQueryExpNode> ContainerQueryParser::ParseCondition(CSSParserTokenStream& stream) {
  stream.ConsumeWhitespace();
  std::shared_ptr<const MediaQueryExpNode> node = ConsumeContainerCondition(stream);
  if (!stream.AtEnd()) {
    return nullptr;
  }
  return node;
}

std::shared_ptr<const MediaQueryExpNode> ContainerQueryParser::ConsumeQueryInParens(CSSParserTokenStream& stream) {
  stream.EnsureLookAhead();
  auto save_state = stream.Save();

  if (stream.Peek().GetType() == kLeftParenthesisToken) {
    // ( <size-feature> ) | ( <container-condition> )
    CSSParserTokenStream::BlockGuard guard(stream);
    stream.ConsumeWhitespace();

    stream.EnsureLookAhead();
    auto inner_save_state = stream.Save();
    // <size-feature>
    std::shared_ptr<const MediaQueryExpNode> query = ConsumeFeature(stream, SizeFeatureSet());
    if (query && stream.AtEnd()) {
      return MediaQueryExpNode::Nested(query);
    }
    stream.Restore(inner_save_state);

    // <container-condition>
    std::shared_ptr<const MediaQueryExpNode> condition = ConsumeContainerCondition(stream);
    if (condition && stream.AtEnd()) {
      return MediaQueryExpNode::Nested(condition);
    }
  } else if (stream.Peek().GetType() == kFunctionToken && stream.Peek().FunctionId() == CSSValueID::kStyle) {
    // style( <style-query> )
    CSSParserTokenStream::BlockGuard guard(stream);
    stream.ConsumeWhitespace();

    if (std::shared_ptr<const MediaQueryExpNode> query = ConsumeFeatureQuery(stream, StyleFeatureSet())) {
      return MediaQueryExpNode::Function(query, "style");
    }
  } else if (stream.Peek().GetType() == kFunctionToken && stream.Peek().FunctionId() == CSSValueID::kScrollState) {
    // scroll-state(stuck: [ none | top | left | right | bottom | inset-* ] )
    // scroll-state(snapped: [ none | block | inline | x | y ] )
    CSSParserTokenStream::BlockGuard guard(stream);
    stream.ConsumeWhitespace();

    if (std::shared_ptr<const MediaQueryExpNode> query = ConsumeFeatureQuery(stream, StateFeatureSet())) {
      return MediaQueryExpNode::Function(query, "scroll-state");
    }
  }
  stream.Restore(save_state);

  // <general-enclosed>
  return media_query_parser_.ConsumeGeneralEnclosed(stream);
}

std::shared_ptr<const MediaQueryExpNode> ContainerQueryParser::ConsumeContainerCondition(CSSParserTokenStream& stream) {
  return ConsumeNotAndOr([this](CSSParserTokenStream& stream) { 
    return this->ConsumeQueryInParens(stream); 
  }, stream);
}

std::shared_ptr<const MediaQueryExpNode> ContainerQueryParser::ConsumeFeatureQuery(CSSParserTokenStream& stream,
                                                                                   const FeatureSet& feature_set) {
  stream.EnsureLookAhead();
  auto save_state = stream.Save();

  if (std::shared_ptr<const MediaQueryExpNode> feature = ConsumeFeature(stream, feature_set)) {
    return feature;
  }
  stream.Restore(save_state);

  if (std::shared_ptr<const MediaQueryExpNode> node = ConsumeFeatureCondition(stream, feature_set)) {
    return node;
  }

  return nullptr;
}

std::shared_ptr<const MediaQueryExpNode> ContainerQueryParser::ConsumeFeatureQueryInParens(CSSParserTokenStream& stream,
                                                                                           const FeatureSet& feature_set) {
  stream.EnsureLookAhead();
  auto save_state = stream.Save();

  if (stream.Peek().GetType() == kLeftParenthesisToken) {
    CSSParserTokenStream::BlockGuard guard(stream);
    stream.ConsumeWhitespace();
    std::shared_ptr<const MediaQueryExpNode> query = ConsumeFeatureQuery(stream, feature_set);
    if (query && stream.AtEnd()) {
      return MediaQueryExpNode::Nested(query);
    }
  }
  stream.Restore(save_state);

  return media_query_parser_.ConsumeGeneralEnclosed(stream);
}

std::shared_ptr<const MediaQueryExpNode> ContainerQueryParser::ConsumeFeatureCondition(CSSParserTokenStream& stream,
                                                                                       const FeatureSet& feature_set) {
  return ConsumeNotAndOr([this, &feature_set](CSSParserTokenStream& stream) {
    return this->ConsumeFeatureQueryInParens(stream, feature_set);
  }, stream);
}

std::shared_ptr<const MediaQueryExpNode> ContainerQueryParser::ConsumeFeature(CSSParserTokenStream& stream,
                                                                              const FeatureSet& feature_set) {
  return media_query_parser_.ConsumeFeature(stream, feature_set);
}

}  // namespace webf