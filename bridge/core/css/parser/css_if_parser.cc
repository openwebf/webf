// Copyright 2025 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#include "core/css/parser/css_if_parser.h"

#include "core/css/if_condition.h"
#include "core/css/kleene_value.h"
#include "core/css/media_query_exp.h"
#include "core/css/parser/container_query_parser.h"
#include "core/css/parser/css_supports_parser.h"
#include "core/css/properties/css_parsing_utils.h"
#include "media_type_names.h"

namespace webf {

using css_parsing_utils::AtIdent;
using css_parsing_utils::ConsumeIfIdent;

CSSIfParser::CSSIfParser(const CSSParserContext& context)
    : container_query_parser_(ContainerQueryParser(context)),
      supports_query_parser_(std::make_shared<CSSParserContext>(context)) {}

// <if-test> =
//   supports( [ <supports-condition> | <ident> : <declaration-value> ] ) |
//   media( <media-feature> | <media-condition> ) |
//   style( <style-query> )
std::shared_ptr<const IfCondition> CSSIfParser::ConsumeIfTest(CSSParserTokenStream& stream) {
  if (stream.Peek().GetType() == kFunctionToken &&
      stream.Peek().FunctionId() == CSSValueID::kSupports) {
    CSSParserTokenStream::RestoringBlockGuard guard(stream);
    stream.ConsumeWhitespace();
    CSSSupportsParser::Result supports_parsing_result =
        CSSSupportsParser::ConsumeSupportsCondition(stream,
                                                    supports_query_parser_);
    if (supports_parsing_result != CSSSupportsParser::Result::kParseFailure) {
      guard.Release();
      stream.ConsumeWhitespace();
      bool result =
          (supports_parsing_result == CSSSupportsParser::Result::kSupported);
      return std::make_shared<IfTestSupports>(result);
    }
    if (stream.Peek().GetType() == kIdentToken &&
        supports_query_parser_.ConsumeSupportsDeclaration(stream) &&
        guard.Release()) {
      stream.ConsumeWhitespace();
      return std::make_shared<IfTestSupports>(true);
    }
  }
  
  // Note: WebF doesn't support media() and style() conditions in if() yet
  // These would need to be implemented when WebF adds support for these features
  
  return nullptr;
}

std::shared_ptr<const IfCondition> CSSIfParser::ConsumeBooleanExprGroup(
    CSSParserTokenStream& stream) {
  stream.ConsumeWhitespace();
  if (stream.Peek().GetType() != kLeftParenthesisToken) {
    return ConsumeIfTest(stream);
  }

  CSSParserTokenStream::RestoringBlockGuard guard(stream);
  stream.ConsumeWhitespace();
  auto result = ConsumeIfTest(stream);
  // If that didn't work, try to parse as <boolean-expr>
  if (!result) {
    result = ConsumeBooleanExpr(stream);
  }
  stream.ConsumeWhitespace();
  if (!result || !guard.Release()) {
    return nullptr;
  }

  return result;
}

namespace {

bool IsOrderingKeyword(CSSParserToken token) {
  return token.GetType() == kIdentToken &&
         (token.Value() == "and" || token.Value() == "or");
}

}  // namespace

std::shared_ptr<const IfCondition> CSSIfParser::ConsumeBooleanExpr(
    CSSParserTokenStream& stream) {
  if (ConsumeIfIdent(stream, "not")) {
    auto result = ConsumeIfTest(stream);
    stream.ConsumeWhitespace();
    return result ? IfCondition::Not(result) : nullptr;
  }

  if (ConsumeIfIdent(stream, "else")) {
    stream.ConsumeWhitespace();
    if (stream.AtEnd()) {
      return std::make_shared<IfConditionElse>();
    }
    return nullptr;
  }

  auto result = ConsumeBooleanExprGroup(stream);
  if (!result) {
    return nullptr;
  }

  stream.ConsumeWhitespace();
  while (!stream.AtEnd() && IsOrderingKeyword(stream.Peek())) {
    bool is_and = (stream.Peek().Value() == "and");
    stream.ConsumeIncludingWhitespace();  // Keyword
    if (auto group = ConsumeBooleanExprGroup(stream)) {
      if (is_and) {
        result = IfCondition::And(result, group);
      } else {  // "or"
        result = IfCondition::Or(result, group);
      }
    } else {
      return std::make_shared<IfConditionUnknown>(
          std::string(stream.StringRangeAt(0, stream.LookAheadOffset() - 1)));
    }

    stream.ConsumeWhitespace();
  }

  return result;
}

// [ <container-query> | <supports-query> ]
// <container-query> = <container-name>? <container-condition>
// <supports-query> = <supports-condition>
std::shared_ptr<const IfCondition> CSSIfParser::ConsumeIfCondition(
    CSSParserTokenStream& stream) {
  stream.ConsumeWhitespace();

  // <boolean-expr[ <if-test> ]>
  return ConsumeBooleanExpr(stream);
}

}  // namespace webf