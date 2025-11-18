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
    // After consuming "not", we expect a query in parentheses
    auto operand = func(stream);
    if (!operand) {
      return nullptr;
    }
    return MediaQueryExpNode::Not(operand);
  }

  std::shared_ptr<const MediaQueryExpNode> result = func(stream);
  if (!result) {
    return nullptr;
  }

  // Check for "and" or "or" operators
  stream.ConsumeWhitespace();  // Ensure we consume whitespace before checking for operators
  if (!stream.AtEnd() && AtIdent(stream.Peek(), "and")) {
    while (result && ConsumeIfIdent(stream, "and")) {
      auto operand = func(stream);
      if (!operand) {
        return nullptr;
      }
      result = MediaQueryExpNode::And(result, operand);
      stream.ConsumeWhitespace();  // Consume whitespace after each operand
    }
  } else if (!stream.AtEnd() && AtIdent(stream.Peek(), "or")) {
    while (result && ConsumeIfIdent(stream, "or")) {
      auto operand = func(stream);
      if (!operand) {
        return nullptr;
      }
      result = MediaQueryExpNode::Or(result, operand);
      stream.ConsumeWhitespace();  // Consume whitespace after each operand
    }
  }

  return result;
}

class SizeFeatureSet : public MediaQueryParser::FeatureSet {
  WEBF_STACK_ALLOCATED();

 public:
  bool IsAllowed(const AtomicString& feature) const override {
    return feature == media_feature_names_atomicstring::kWidth || feature == media_feature_names_atomicstring::kMinWidth ||
           feature == media_feature_names_atomicstring::kMaxWidth || feature == media_feature_names_atomicstring::kHeight ||
           feature == media_feature_names_atomicstring::kMinHeight ||
           feature == media_feature_names_atomicstring::kMaxHeight ||
           feature == media_feature_names_atomicstring::kInlineSize ||
           feature == media_feature_names_atomicstring::kMinInlineSize ||
           feature == media_feature_names_atomicstring::kMaxInlineSize ||
           feature == media_feature_names_atomicstring::kMinBlockSize ||
           feature == media_feature_names_atomicstring::kMaxBlockSize ||
           feature == media_feature_names_atomicstring::kAspectRatio ||
           feature == media_feature_names_atomicstring::kMinAspectRatio ||
           feature == media_feature_names_atomicstring::kMaxAspectRatio;
  }
  bool IsAllowedWithoutValue(const AtomicString& feature) const override {
    return feature == media_feature_names_atomicstring::kWidth || feature == media_feature_names_atomicstring::kHeight ||
           feature == media_feature_names_atomicstring::kInlineSize ||
           feature == media_feature_names_atomicstring::kAspectRatio;
  }
  bool IsCaseSensitive(const AtomicString& feature) const override { return false; }
  bool SupportsRange() const override { return true; }
};

class StyleFeatureSet : public MediaQueryParser::FeatureSet {
  WEBF_STACK_ALLOCATED();

 public:
  bool IsAllowed(const AtomicString& feature) const override {
    // TODO(crbug.com/1302630): Only support querying custom properties for now.
    return CSSVariableParser::IsValidVariableName(String(feature.GetString()));
  }
  bool IsAllowedWithoutValue(const AtomicString& feature) const override { return true; }
  bool IsCaseSensitive(const AtomicString& feature) const override {
    // TODO(crbug.com/1302630): non-custom properties are case-insensitive.
    return true;
  }
  bool SupportsRange() const override { return false; }
};

class StateFeatureSet : public MediaQueryParser::FeatureSet {
  WEBF_STACK_ALLOCATED();

 public:
  bool IsAllowed(const AtomicString& feature) const override { return false; }
  bool IsAllowedWithoutValue(const AtomicString& feature) const override { return true; }
  bool IsCaseSensitive(const AtomicString& feature) const override { return false; }
  bool SupportsRange() const override { return false; }
};

}  // namespace

ContainerQueryParser::ContainerQueryParser(const CSSParserContext& context)
    : context_(context),
      media_query_parser_(MediaQueryParser::kMediaQuerySetParser,
                          kHTMLStandardMode,
                          context.GetExecutingContext(),
                          MediaQueryParser::SyntaxLevel::kLevel4) {}

std::shared_ptr<const MediaQueryExpNode> ContainerQueryParser::ParseCondition(const String& value) {
  // Do not parse the container condition semantically; keep it as a raw
  // expression node so higher layers can interpret it as needed.
  return std::make_shared<MediaQueryUnknownExpNode>(value);
}

// Stream implementations
std::shared_ptr<const MediaQueryExpNode> ContainerQueryParser::ParseCondition(CSSParserTokenStream& stream) {
  CSSParserTokenRange range = stream.ConsumeUntilPeekedTypeIs<>();
  String serialized = range.Serialize();
  return std::make_shared<MediaQueryUnknownExpNode>(serialized);
}

// <query-in-parens> = ( <container-condition> )
//                   | ( <size-feature> )
//                   | style( <style-query> )
//                   | scroll-state( <scroll-state-query> )
//                   | <general-enclosed>
std::shared_ptr<const MediaQueryExpNode> ContainerQueryParser::ConsumeQueryInParens(CSSParserTokenStream& stream) {
  CSSParserTokenStream::State savepoint = stream.Save();

  if (stream.Peek().GetType() == kLeftParenthesisToken) {
    // ( <size-feature> ) | ( <container-condition> )
    {
      CSSParserTokenStream::RestoringBlockGuard guard(stream);
      stream.ConsumeWhitespace();
      // <size-feature>
      std::shared_ptr<const MediaQueryExpNode> query = ConsumeFeature(stream, SizeFeatureSet());
      if (query && stream.AtEnd()) {
        guard.Release();
        stream.ConsumeWhitespace();
        return MediaQueryExpNode::Nested(query);
      }
    }

    {
      CSSParserTokenStream::RestoringBlockGuard guard(stream);
      stream.ConsumeWhitespace();
      // <container-condition>
      std::shared_ptr<const MediaQueryExpNode> condition = ConsumeContainerCondition(stream);
      if (condition) {
        stream.ConsumeWhitespace();
        if (stream.AtEnd()) {
          guard.Release();
          stream.ConsumeWhitespace();
          return MediaQueryExpNode::Nested(condition);
        }
      }
    }
  } else if (stream.Peek().GetType() == kFunctionToken &&
             stream.Peek().FunctionId() == CSSValueID::kStyle) {
    // style( <style-query> )
    CSSParserTokenStream::RestoringBlockGuard guard(stream);
    stream.ConsumeWhitespace();

    std::shared_ptr<const MediaQueryExpNode> query = ConsumeFeatureQuery(stream, StyleFeatureSet());
    if (query) {
      guard.Release();
      stream.ConsumeWhitespace();
      return MediaQueryExpNode::Function(query, AtomicString::CreateFromUTF8("style"));
    }
  } else if (stream.Peek().GetType() == kFunctionToken &&
             stream.Peek().FunctionId() == CSSValueID::kScrollState) {
    // scroll-state( <scroll-state-query> )
    CSSParserTokenStream::RestoringBlockGuard guard(stream);
    stream.ConsumeWhitespace();

    std::shared_ptr<const MediaQueryExpNode> query = ConsumeFeatureQuery(stream, StateFeatureSet());
    if (query) {
      guard.Release();
      stream.ConsumeWhitespace();
      return MediaQueryExpNode::Function(query, AtomicString::CreateFromUTF8("scroll-state"));
    }
  }
  stream.Restore(savepoint);

  // <general-enclosed>
  return media_query_parser_.ConsumeGeneralEnclosed(stream);
}

std::shared_ptr<const MediaQueryExpNode> ContainerQueryParser::ConsumeContainerCondition(CSSParserTokenStream& stream) {
  return ConsumeNotAndOr(
      [this](CSSParserTokenStream& stream) {
        return this->ConsumeQueryInParens(stream);
      },
      stream);
}

std::shared_ptr<const MediaQueryExpNode> ContainerQueryParser::ConsumeFeatureQuery(CSSParserTokenStream& stream,
                                                                                   const FeatureSet& feature_set) {
  stream.EnsureLookAhead();
  CSSParserTokenStream::State savepoint = stream.Save();
  std::shared_ptr<const MediaQueryExpNode> feature = ConsumeFeature(stream, feature_set);
  if (feature) {
    return feature;
  }
  stream.Restore(savepoint);

  std::shared_ptr<const MediaQueryExpNode> node = ConsumeFeatureCondition(stream, feature_set);
  if (node) {
    return node;
  }

  return nullptr;
}

std::shared_ptr<const MediaQueryExpNode> ContainerQueryParser::ConsumeFeatureQueryInParens(CSSParserTokenStream& stream,
                                                                                           const FeatureSet& feature_set) {
  CSSParserTokenStream::State savepoint = stream.Save();
  if (stream.Peek().GetType() == kLeftParenthesisToken) {
    CSSParserTokenStream::RestoringBlockGuard guard(stream);
    stream.ConsumeWhitespace();
    std::shared_ptr<const MediaQueryExpNode> query = ConsumeFeatureQuery(stream, feature_set);
    if (query && stream.AtEnd()) {
      guard.Release();
      stream.ConsumeWhitespace();
      return MediaQueryExpNode::Nested(query);
    }
  }
  stream.Restore(savepoint);

  return media_query_parser_.ConsumeGeneralEnclosed(stream);
}

std::shared_ptr<const MediaQueryExpNode> ContainerQueryParser::ConsumeFeatureCondition(CSSParserTokenStream& stream,
                                                                                       const FeatureSet& feature_set) {
  return ConsumeNotAndOr(
      [this, &feature_set](CSSParserTokenStream& stream) {
        return this->ConsumeFeatureQueryInParens(stream, feature_set);
      },
      stream);
}

std::shared_ptr<const MediaQueryExpNode> ContainerQueryParser::ConsumeFeature(CSSParserTokenStream& stream,
                                                                              const FeatureSet& feature_set) {
  return media_query_parser_.ConsumeFeature(stream, feature_set);
}

}  // namespace webf
