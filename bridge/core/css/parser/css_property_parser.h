//
// Created by 谢作兵 on 18/06/24.
//

#ifndef WEBF_CSS_PROPERTY_PARSER_H
#define WEBF_CSS_PROPERTY_PARSER_H



//#include "css_tokenized_value.h"
#include "core/css/parser/css_parser_context.h"
#include "core/css/parser/css_parser_mode.h"
#include "core/css/parser/css_parser_token_range.h"
#include "core/css/parser/css_parser_token_stream.h"
#include "core/css/parser/css_tokenizer.h"
#include "core/css/style_rule.h"
#include "foundation/string_view.h"

namespace webf {


class CSSPropertyValue;
class CSSParserTokenStream;
class CSSValue;
class ExecutingContext;
//class

// Inputs: PropertyID, isImportant bool, CSSParserTokenRange.
// Outputs: Vector of CSSProperties

class CSSPropertyParser {
  WEBF_STACK_ALLOCATED();

 public:
  CSSPropertyParser(const CSSPropertyParser&) = delete;
  CSSPropertyParser& operator=(const CSSPropertyParser&) = delete;

  // NOTE: The stream must have leading whitespace (and comments)
  // stripped; it will strip any trailing whitespace (and comments) itself.
  // This is done because it's easy to strip tokens from the start when
  // tokenizing (but trailing comments is so rare that we can just as well
  // do that in a slow path).
  static bool ParseValue(CSSPropertyID,
                         bool allow_important_annotation,
                         CSSParserTokenStream&,
                         const CSSParserContext*,
                         std::vector<CSSPropertyValue>&,
                         StyleRule::RuleType);

  // Parses a non-shorthand CSS property
  static const CSSValue* ParseSingleValue(CSSPropertyID,
                                          CSSParserTokenStream&,
                                          const CSSParserContext*);

 private:
  CSSPropertyParser(CSSParserTokenStream&,
                    const CSSParserContext*,
                    std::vector<CSSPropertyValue>*);

  // TODO(timloh): Rename once the CSSParserValue-based parseValue is removed
  bool ParseValueStart(CSSPropertyID unresolved_property,
                       bool allow_important_annotation,
                       StyleRule::RuleType rule_type);
  bool ConsumeCSSWideKeyword(CSSPropertyID unresolved_property,
                             bool allow_important_annotation);

  bool ParseFontFaceDescriptor(CSSPropertyID);

 private:
  // Inputs:
  CSSParserTokenStream& stream_;
  const CSSParserContext* context_;
  // Outputs:
  std::vector<CSSPropertyValue>* parsed_properties_;
};

CSSPropertyID UnresolvedCSSPropertyID(const ExecutingContext*,
                        StringView,
                        CSSParserMode mode = kHTMLStandardMode);
CSSValueID CssValueKeywordID(StringView);
}  // namespace webf

#endif  // WEBF_CSS_PROPERTY_PARSER_H
