// Copyright 2021 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#ifndef WEBF_CORE_CSS_PARSER_CONTAINER_QUERY_PARSER_H_
#define WEBF_CORE_CSS_PARSER_CONTAINER_QUERY_PARSER_H_

#include "core/css/media_query_exp.h"
#include "core/css/parser/media_query_parser.h"
#include "foundation/macros.h"
#include "foundation/string/wtf_string.h"

namespace webf {

class CSSParserContext;
class CSSParserTokenStream;

class ContainerQueryParser {
  WEBF_STACK_ALLOCATED();

 public:
  explicit ContainerQueryParser(const CSSParserContext&);

  // https://drafts.csswg.org/css-contain-3/#typedef-container-condition
  std::shared_ptr<const MediaQueryExpNode> ParseCondition(const String&);
  std::shared_ptr<const MediaQueryExpNode> ParseCondition(CSSParserTokenStream&);

 private:
  friend class ContainerQueryParserTest;

  using FeatureSet = MediaQueryParser::FeatureSet;

  std::shared_ptr<const MediaQueryExpNode> ConsumeQueryInParens(CSSParserTokenStream&);
  std::shared_ptr<const MediaQueryExpNode> ConsumeContainerCondition(CSSParserTokenStream&);
  std::shared_ptr<const MediaQueryExpNode> ConsumeFeatureQuery(CSSParserTokenStream&,
                                                               const FeatureSet&);
  std::shared_ptr<const MediaQueryExpNode> ConsumeFeatureQueryInParens(CSSParserTokenStream&,
                                                                       const FeatureSet&);
  std::shared_ptr<const MediaQueryExpNode> ConsumeFeatureCondition(CSSParserTokenStream&,
                                                                   const FeatureSet&);
  std::shared_ptr<const MediaQueryExpNode> ConsumeFeature(CSSParserTokenStream&,
                                                          const FeatureSet&);

  const CSSParserContext& context_;
  MediaQueryParser media_query_parser_;
};

}  // namespace webf

#endif  // WEBF_CORE_CSS_PARSER_CONTAINER_QUERY_PARSER_H_
