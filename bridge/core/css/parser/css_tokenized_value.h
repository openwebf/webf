// Copyright 2020 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#ifndef WEBF_CORE_CSS_PARSER_CSS_TOKENIZED_VALUE_H_
#define WEBF_CORE_CSS_PARSER_CSS_TOKENIZED_VALUE_H_

#include "core/css/parser/css_parser_token_range.h"
#include "foundation/string_view.h"

namespace webf {

struct CSSTokenizedValue {
  WEBF_STACK_ALLOCATED();

 public:
  CSSParserTokenRange range;
  std::string_view text;
};

}  // namespace blink

#endif  // WEBF_CORE_CSS_PARSER_CSS_TOKENIZED_VALUE_H_
