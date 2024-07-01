// Copyright 2015 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef WEBF_CSS_VARIABLE_PARSER_H
#define WEBF_CSS_VARIABLE_PARSER_H


#include "core/css/parser/css_parser_token_range.h"
#include "core/executing_context.h"
#include "bindings/qjs/atomic_string.h"
#include "foundation/string_view.h"

namespace webf {


class CSSParserContext;
// TODO
class CSSUnparsedDeclarationValue;
// TODO
class CSSValue;
// TODO
struct CSSTokenizedValue;


class CSSVariableParser {
 public:
  static bool ContainsValidVariableReferences(CSSParserTokenRange,
                                              const ExecutingContext* context);

  static CSSValue* ParseDeclarationIncludingCSSWide(const CSSTokenizedValue&,
                                                    bool is_animation_tainted,
                                                    const CSSParserContext&);
  static CSSUnparsedDeclarationValue* ParseDeclarationValue(
      const CSSTokenizedValue&,
      bool is_animation_tainted,
      const CSSParserContext&);
  // Custom properties registered with universal syntax [1] are parsed with
  // this function.
  //
  // https://drafts.css-houdini.org/css-properties-values-api-1/#universal-syntax-definition
  static CSSUnparsedDeclarationValue* ParseUniversalSyntaxValue(
      CSSTokenizedValue,
      const CSSParserContext&,
      bool is_animation_tainted);

  static bool IsValidVariableName(const CSSParserToken&);
  static bool IsValidVariableName(StringView);

  // NOTE: We have to strip both leading and trailing whitespace (and comments)
  // from values as per spec, but we assume the tokenizer has already done the
  // leading ones for us; see comment on CSSPropertyParser::ParseValue().
  static StringView StripTrailingWhitespaceAndComments(StringView);
};


}  // namespace webf

#endif  // WEBF_CSS_VARIABLE_PARSER_H
