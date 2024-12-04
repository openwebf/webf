// Copyright 2021 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#ifndef WEBF_CORE_CSS_PARSER_CONTAINER_QUERY_PARSER_H_
#define WEBF_CORE_CSS_PARSER_CONTAINER_QUERY_PARSER_H_

#include "core/css/media_query_exp.h"
#include "core/css/parser/media_query_parser.h"
#include "foundation/macros.h"

namespace webf {

class CSSParserContext;

class ContainerQueryParser {
  WEBF_STACK_ALLOCATED();

 public:
  explicit ContainerQueryParser(const CSSParserContext&);

  // https://drafts.csswg.org/css-contain-3/#typedef-container-condition
  std::shared_ptr<const MediaQueryExpNode> ParseCondition(const std::string&);
  std::shared_ptr<const MediaQueryExpNode> ParseCondition(CSSParserTokenRange, const CSSParserTokenOffsets&);

 private:
  friend class ContainerQueryParserTest;

  using FeatureSet = MediaQueryParser::FeatureSet;

  std::shared_ptr<const MediaQueryExpNode> ConsumeQueryInParens(CSSParserTokenRange&,
                                                                const CSSParserTokenOffsets& offsets);
  std::shared_ptr<const MediaQueryExpNode> ConsumeContainerCondition(CSSParserTokenRange&,
                                                                     const CSSParserTokenOffsets&);
  std::shared_ptr<const MediaQueryExpNode> ConsumeFeatureQuery(CSSParserTokenRange&,
                                                               const CSSParserTokenOffsets& offsets,
                                                               const FeatureSet&);
  std::shared_ptr<const MediaQueryExpNode> ConsumeFeatureQueryInParens(CSSParserTokenRange&,
                                                                       const CSSParserTokenOffsets&,
                                                                       const FeatureSet&);
  std::shared_ptr<const MediaQueryExpNode> ConsumeFeatureCondition(CSSParserTokenRange&,
                                                                   const CSSParserTokenOffsets& offsets,
                                                                   const FeatureSet&);
  std::shared_ptr<const MediaQueryExpNode> ConsumeFeature(CSSParserTokenRange&,
                                                          const CSSParserTokenOffsets& offsets,
                                                          const FeatureSet&);

  const CSSParserContext& context_;
  MediaQueryParser media_query_parser_;
};

}  // namespace webf

#endif  // WEBF_CORE_CSS_PARSER_CONTAINER_QUERY_PARSER_H_
