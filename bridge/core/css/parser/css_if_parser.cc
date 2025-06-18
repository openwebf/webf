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

// <boolean-expr-group> = <if-test> | ( <boolean-expr[ <if-test> ]> ) |
// <general-enclosed>
// https://drafts.csswg.org/css-values-5/#typedef-boolean-expr
std::shared_ptr<const IfCondition> CSSIfParser::ConsumeBooleanExprGroup(
    CSSParserTokenStream& stream) {
  // <if-test> = supports( ... ) | media( ... ) | style( ... )
  std::shared_ptr<const IfCondition> result = ConsumeIfTest(stream);
  if (result) {
    return result;
  }

  // ( <boolean-expr[ <test> ]> )
  if (stream.Peek().GetType() == kLeftParenthesisToken) {
    CSSParserTokenStream::RestoringBlockGuard guard(stream);
    stream.ConsumeWhitespace();
    result = ConsumeBooleanExpr(stream);
    if (result && stream.AtEnd()) {
      guard.Release();
      stream.ConsumeWhitespace();
      return result;
    }
  }

  // <general-enclosed>
  // Note: WebF doesn't implement general-enclosed yet, so we return nullptr
  return nullptr;
}

namespace {

bool IsOrderingKeyword(CSSParserToken token) {
  return token.GetType() == kIdentToken &&
         (token.Value() == "and" || token.Value() == "or");
}

}  // namespace

// <boolean-expr[ <if-test> ]> = not <boolean-expr-group> | <boolean-expr-group>
//                            [ [ and <boolean-expr-group> ]*
//                            | [ or <boolean-expr-group> ]* ]
// https://drafts.csswg.org/css-values-5/#typedef-boolean-expr
std::shared_ptr<const IfCondition> CSSIfParser::ConsumeBooleanExpr(
    CSSParserTokenStream& stream) {
  if (ConsumeIfIdent(stream, "not")) {
    return IfCondition::Not(ConsumeBooleanExprGroup(stream));
  }

  std::shared_ptr<const IfCondition> result = ConsumeBooleanExprGroup(stream);

  if (AtIdent(stream.Peek(), "and")) {
    while (ConsumeIfIdent(stream, "and")) {
      result = IfCondition::And(result, ConsumeBooleanExprGroup(stream));
    }
  } else if (AtIdent(stream.Peek(), "or")) {
    while (ConsumeIfIdent(stream, "or")) {
      result = IfCondition::Or(result, ConsumeBooleanExprGroup(stream));
    }
  }

  return result;
}

// <if-condition> = <boolean-expr[ <if-test> ]> | else
// https://drafts.csswg.org/css-values-5/#typedef-if-condition
std::shared_ptr<const IfCondition> CSSIfParser::ConsumeIfCondition(
    CSSParserTokenStream& stream) {
  if (ConsumeIfIdent(stream, "else")) {
    return std::make_shared<IfConditionElse>();
  }

  // <boolean-expr[ <if-test> ]>
  return ConsumeBooleanExpr(stream);
}

}  // namespace webf