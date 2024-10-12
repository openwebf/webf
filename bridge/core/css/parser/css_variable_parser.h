// Copyright 2015 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef WEBF_CSS_VARIABLE_PARSER_H
#define WEBF_CSS_VARIABLE_PARSER_H

#include "bindings/qjs/atomic_string.h"
#include "core/css/css_variable_data.h"
#include "core/css/parser/css_parser_token_range.h"
#include "core/css/parser/css_parser_token_stream.h"
#include "core/executing_context.h"
#include "foundation/string_view.h"

namespace webf {

class CSSUnparsedDeclarationValue;
class CSSParserContext;
class CSSUnparsedDeclarationValue;
struct CSSTokenizedValue;

class CSSVariableParser {
 public:
  static bool ContainsValidVariableReferences(CSSParserTokenRange, const ExecutingContext* context);

  static std::shared_ptr<const CSSValue> ParseDeclarationIncludingCSSWide(const CSSTokenizedValue&,
                                                                          bool is_animation_tainted,
                                                                          std::shared_ptr<const CSSParserContext>&);
  static std::shared_ptr<const CSSUnparsedDeclarationValue> ParseDeclarationValue(
      const CSSTokenizedValue&,
      bool is_animation_tainted,
      std::shared_ptr<const CSSParserContext>& context);
  // Custom properties registered with universal syntax [1] are parsed with
  // this function.
  //
  // https://drafts.css-houdini.org/css-properties-values-api-1/#universal-syntax-definition
  static std::shared_ptr<const CSSUnparsedDeclarationValue> ParseUniversalSyntaxValue(const std::string&,
                                                                                      std::shared_ptr<const CSSParserContext>&,
                                                                                      bool is_animation_tainted);

  // Consume a declaration without trying to parse it as any specific
  // property. This is mostly useful for either custom property declarations,
  // or for standard properties referencing custom properties
  // (var(), or similarly env() etc.).
  //
  // Returns nullptr on failure, such as a stray top-level ! or },
  // or if “must_contain_variable_reference” (useful for standard
  // properties), “restricted_value” or “allow_important_annotation”
  // is violated. If so, the parser is left at an indeterminate place,
  // but with the same block level as it started. On success, returns
  // a CSSVariableData containing the original text for the property,
  // with leading and trailing whitespace and comments removed,
  // plus “!important” (if existing) stripped. The parser will be
  // at the end of the declaration, i.e., typically at a semicolon.
  //
  // A value for a standard property (restricted_value=true) has
  // the following restriction: it can not contain braces unless
  // it's the whole value [1]. This function makes use of that
  // restriction to early-out of the streaming tokenizer as
  // soon as possible. (This used to be important to avoid a O(n²),
  // but it is not anymore, as failure of this function is no longer
  // a common case in the happy parsing path.) If restricted_value=false
  // (as is the case with custom properties and descriptors), the function
  // will simply consume until AtEnd(), unless an error is encountered.
  //
  // [1] https://github.com/w3c/csswg-drafts/issues/9317
  static std::shared_ptr<CSSVariableData> ConsumeUnparsedDeclaration(
      CSSParserTokenStream& stream,
      bool allow_important_annotation,
      bool is_animation_tainted,
      bool must_contain_variable_reference,
      bool restricted_value,
      bool comma_ends_declaration,
      bool& important,
      const ExecutingContext* context);

  static bool IsValidVariableName(const CSSParserToken&);
  static bool IsValidVariableName(const std::string_view&);

  // NOTE: We have to strip both leading and trailing whitespace (and comments)
  // from values as per spec, but we assume the tokenizer has already done the
  // leading ones for us; see comment on CSSPropertyParser::ParseValue().
  static std::string_view StripTrailingWhitespaceAndComments(std::string_view);
};

}  // namespace webf

#endif  // WEBF_CSS_VARIABLE_PARSER_H
