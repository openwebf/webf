// Copyright 2014 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#ifndef WEBF_CORE_CSS_PARSER_MEDIA_QUERY_PARSER_H_
#define WEBF_CORE_CSS_PARSER_MEDIA_QUERY_PARSER_H_

#include "foundation/macros.h"
#include "core/css/media_list.h"
#include "core/css/media_query_exp.h"
#include "core/css/parser/css_parser_token_range.h"

namespace webf {

class MediaQuerySet;
class CSSParserContext;
class ContainerQueryParser;

class MediaQueryParser {
  WEBF_STACK_ALLOCATED();

 public:
  static std::shared_ptr<MediaQuerySet> ParseMediaQuerySet(const std::string&,
                                           const ExecutingContext*);
  static std::shared_ptr<MediaQuerySet> ParseMediaQuerySet(CSSParserTokenRange,
                                           const CSSParserTokenOffsets&,
                                           const ExecutingContext*);
  static std::shared_ptr<MediaQuerySet> ParseMediaCondition(CSSParserTokenRange,
                                            const CSSParserTokenOffsets&,
                                            const ExecutingContext*);
  static std::shared_ptr<MediaQuerySet> ParseMediaQuerySetInMode(CSSParserTokenRange,
                                                 const CSSParserTokenOffsets&,
                                                 CSSParserMode,
                                                 const ExecutingContext*);

  // Passed to ConsumeFeature to determine which features are allowed.
  class FeatureSet {
    WEBF_STACK_ALLOCATED();

   public:
    // Returns true if the feature name is allowed in this set.
    virtual bool IsAllowed(const std::string& feature) const = 0;

    // Returns true if the feature can be queried without a value.
    virtual bool IsAllowedWithoutValue(const std::string& feature) const = 0;

    // Returns true is the feature name is case sensitive.
    virtual bool IsCaseSensitive(const std::string& feature) const = 0;

    // Whether the features support range syntax. This is typically false for
    // style container queries.
    virtual bool SupportsRange() const = 0;
  };

 private:
  friend class ContainerQueryParser;

  enum ParserType {
    kMediaQuerySetParser,
    kMediaConditionParser,
  };

  enum class SyntaxLevel {
    // Determined by CSSMediaQueries4 flag.
    kAuto,
    // Use mediaqueries-4 syntax regardless of flags.
    kLevel4,
  };

  MediaQueryParser(ParserType,
                   CSSParserMode,
                   const ExecutingContext*,
                   SyntaxLevel = SyntaxLevel::kAuto);
  MediaQueryParser(const MediaQueryParser&) = delete;
  MediaQueryParser& operator=(const MediaQueryParser&) = delete;
  virtual ~MediaQueryParser();

  // [ not | only ]
  static MediaQuery::RestrictorType ConsumeRestrictor(CSSParserTokenRange&);

  // https://drafts.csswg.org/mediaqueries-4/#typedef-media-type
  static std::string ConsumeType(CSSParserTokenRange&);

  // https://drafts.csswg.org/mediaqueries-4/#typedef-mf-comparison
  static MediaQueryOperator ConsumeComparison(CSSParserTokenRange&);

  // https://drafts.csswg.org/mediaqueries-4/#typedef-mf-name
  //
  // The <mf-name> is only consumed if the name is allowed by the specified
  // FeatureSet.
  std::string ConsumeAllowedName(CSSParserTokenRange&, const FeatureSet&);

  // Like ConsumeAllowedName, except returns null if the name has a min-
  // or max- prefix.
  std::string ConsumeUnprefixedName(CSSParserTokenRange&, const FeatureSet&);

  enum class NameAffinity {
    // <mf-name> appears on the left, e.g. width < 10px.
    kLeft,
    // <mf-name> appears on the right, e.g. 10px > width.
    kRight
  };

  // Helper function for parsing features with a single MediaQueryOperator,
  // for example 'width <= 10px', or '10px = width'.
  //
  // NameAffinity::kLeft means |lhs| will be interpreted as the <mf-name>,
  // otherwise |rhs| will be interpreted as the <mf-name>.
  //
  // Note that this function accepts CSSParserTokenRanges by *value*, unlike
  // Consume* functions, and that nullptr is returned if either |lhs|
  // or |rhs| aren't fully consumed.
  std::shared_ptr<const MediaQueryExpNode> ParseNameValueComparison(
      CSSParserTokenRange lhs,
      MediaQueryOperator op,
      CSSParserTokenRange rhs,
      const CSSParserTokenOffsets& offsets,
      NameAffinity,
      const FeatureSet&);

  // https://drafts.csswg.org/mediaqueries-4/#typedef-media-feature
  //
  // Currently, only <mf-boolean> and <mf-plain> productions are supported.
  std::shared_ptr<const MediaQueryExpNode> ConsumeFeature(CSSParserTokenRange&,
                                          const CSSParserTokenOffsets& offsets,
                                          const FeatureSet&);

  enum class ConditionMode {
    // https://drafts.csswg.org/mediaqueries-4/#typedef-media-condition
    kNormal,
    // https://drafts.csswg.org/mediaqueries-4/#typedef-media-condition-without-or
    kWithoutOr,
  };

  // https://drafts.csswg.org/mediaqueries-4/#typedef-media-condition
  std::shared_ptr<const MediaQueryExpNode> ConsumeCondition(
      CSSParserTokenRange&,
      const CSSParserTokenOffsets&,
      ConditionMode = ConditionMode::kNormal);

  // https://drafts.csswg.org/mediaqueries-4/#typedef-media-in-parens
  std::shared_ptr<const MediaQueryExpNode> ConsumeInParens(CSSParserTokenRange&,
                                           const CSSParserTokenOffsets&);

  // https://drafts.csswg.org/mediaqueries-4/#typedef-general-enclosed
  std::shared_ptr<const MediaQueryExpNode> ConsumeGeneralEnclosed(CSSParserTokenRange&);

  // https://drafts.csswg.org/mediaqueries-4/#typedef-media-query
  std::shared_ptr<MediaQuery> ConsumeQuery(CSSParserTokenRange&, const CSSParserTokenOffsets&);

  // Used for ParserType::kMediaConditionParser.
  //
  // Parsing a single condition is useful for the 'sizes' attribute.
  //
  // https://html.spec.whatwg.org/multipage/images.html#sizes-attribute
  std::shared_ptr<MediaQuerySet> ConsumeSingleCondition(CSSParserTokenRange,
                                        const CSSParserTokenOffsets&);

  std::shared_ptr<MediaQuerySet> ParseImpl(CSSParserTokenRange, const CSSParserTokenOffsets&);

  ParserType parser_type_;
  CSSParserMode mode_;
  const ExecutingContext* execution_context_;
  SyntaxLevel syntax_level_;
};


}

#endif  // WEBF_CORE_CSS_PARSER_MEDIA_QUERY_PARSER_H_
