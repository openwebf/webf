// Copyright 2025 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#ifndef BRIDGE_CORE_CSS_PARSER_CSS_IF_PARSER_H_
#define BRIDGE_CORE_CSS_PARSER_CSS_IF_PARSER_H_

#include "core/css/if_condition.h"
#include "core/css/media_query_exp.h"
#include "core/css/parser/container_query_parser.h"
#include "core/css/parser/css_parser_context.h"
#include "core/css/parser/css_parser_impl.h"
#include "core/css/parser/css_parser_token_stream.h"

namespace webf {

class CSSIfParser {
  WEBF_STACK_ALLOCATED();

 public:
  explicit CSSIfParser(const CSSParserContext&);

  // Supports only style() and media() queries in condition for now.
  // https://drafts.csswg.org/css-values-5/#if-notation
  std::shared_ptr<const IfCondition> ConsumeIfCondition(CSSParserTokenStream&);

 private:
  std::shared_ptr<const IfCondition> ConsumeBooleanExpr(CSSParserTokenStream&);

  std::shared_ptr<const IfCondition> ConsumeBooleanExprGroup(CSSParserTokenStream&);

  std::shared_ptr<const IfCondition> ConsumeIfTest(CSSParserTokenStream&);

  ContainerQueryParser container_query_parser_;
  CSSParserImpl supports_query_parser_;
};

}  // namespace webf

#endif  // BRIDGE_CORE_CSS_PARSER_CSS_IF_PARSER_H_
