// Copyright 2014 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#ifndef BRIDGE_CORE_CSS_PARSER_SIZES_MATH_FUNCTION_PARSER_H_
#define BRIDGE_CORE_CSS_PARSER_SIZES_MATH_FUNCTION_PARSER_H_

#include "core/css/css_math_operator.h"
#include "core/css/media_values.h"
#include "core/css/parser/css_parser_token.h"
#include "core/css/parser/css_parser_token_stream.h"
#include "foundation/macros.h"
#include <string>
#include <vector>

namespace webf {

struct SizesMathValue {
  WEBF_DISALLOW_NEW();
  double value = 0;
  bool is_length = false;
  CSSMathOperator operation = CSSMathOperator::kInvalid;

  SizesMathValue() = default;

  SizesMathValue(double numeric_value, bool length)
      : value(numeric_value), is_length(length) {}

  explicit SizesMathValue(CSSMathOperator op) : operation(op) {}
};

class SizesMathFunctionParser {
  WEBF_STACK_ALLOCATED();

 public:
  SizesMathFunctionParser(CSSParserTokenStream&, MediaValues*);

  float Result() const;
  bool IsValid() const { return is_valid_; }

 private:
  bool CalcToReversePolishNotation(CSSParserTokenStream&);
  bool ConsumeCalc(CSSParserTokenStream&, std::vector<CSSParserToken>& stack);
  bool ConsumeBlockContent(CSSParserTokenStream&,
                           std::vector<CSSParserToken>& stack);
  bool Calculate();
  void AppendNumber(const CSSParserToken&);
  bool AppendLength(const CSSParserToken&);
  bool HandleComma(std::vector<CSSParserToken>& stack, const CSSParserToken&);
  bool HandleRightParenthesis(std::vector<CSSParserToken>& stack);
  bool HandleOperator(std::vector<CSSParserToken>& stack, const CSSParserToken&);
  void AppendOperator(const CSSParserToken&);

  std::vector<SizesMathValue> value_list_;
  MediaValues* media_values_;
  bool is_valid_;
  float result_;
};

}  // namespace webf

#endif  // BRIDGE_CORE_CSS_PARSER_SIZES_MATH_FUNCTION_PARSER_H_
