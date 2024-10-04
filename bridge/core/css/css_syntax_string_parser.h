// Copyright 2019 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#ifndef WEBF_CORE_CSS_CSS_SYNTAX_STRING_PARSER_H_
#define WEBF_CORE_CSS_CSS_SYNTAX_STRING_PARSER_H_

#include "foundation/macros.h"
#include "core/css/parser/css_parser_token_stream.h"
#include "core/css/css_syntax_definition.h"

namespace webf {

class CSSTokenizerInputStream;

// Produces a CSSSyntaxDefinition from a CSSTokenizerInputStream.
//
// https://drafts.css-houdini.org/css-properties-values-api-1/#parsing-syntax
class CSSSyntaxStringParser {
  WEBF_STACK_ALLOCATED();

 public:
  explicit CSSSyntaxStringParser(const std::string&);

  // https://drafts.css-houdini.org/css-properties-values-api-1/#consume-syntax-definition
  std::optional<CSSSyntaxDefinition> Parse();

 private:
  // https://drafts.css-houdini.org/css-properties-values-api-1/#consume-syntax-component
  //
  // Appends a CSSSyntaxComponent to the Vector on success.
  bool ConsumeSyntaxComponent(std::vector<CSSSyntaxComponent>&);

  // https://drafts.css-houdini.org/css-properties-values-api-1/#consume-data-type-name
  //
  // Returns true if the input stream contained a supported data type name, i.e.
  // a string with a corresponding CSSSyntaxType.
  //
  // https://drafts.css-houdini.org/css-properties-values-api-1/#supported-names
  bool ConsumeDataTypeName(CSSSyntaxType&);

  // Consumes a name from the input stream, and stores the result in 'ident'.
  // Returns true if the value returned via 'ident' is not a css-wide keyword.
  bool ConsumeIdent(std::string& ident);

  // Consumes a '+' or '#' from the input stream (if present), and returns
  // the appropriate CSSSyntaxRepeat. CSSSyntaxRepeat::kNone is returned if
  // the next input code point is not '+' or '#'.
  CSSSyntaxRepeat ConsumeRepeatIfPresent();

  std::string string_;
  CSSTokenizerInputStream input_;
};

}

#endif  // WEBF_CORE_CSS_CSS_SYNTAX_STRING_PARSER_H_
