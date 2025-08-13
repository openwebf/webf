// Copyright 2019 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#include "css_math_operator.h"
#include "core/css/parser/css_parser_token.h"

namespace webf {

CSSMathOperator ParseCSSArithmeticOperator(const CSSParserToken& token) {
  if (token.GetType() != kDelimiterToken) {
    return CSSMathOperator::kInvalid;
  }
  switch (token.Delimiter()) {
    case '+':
      return CSSMathOperator::kAdd;
    case '-':
      return CSSMathOperator::kSubtract;
    case '*':
      return CSSMathOperator::kMultiply;
    case '/':
      return CSSMathOperator::kDivide;
    default:
      return CSSMathOperator::kInvalid;
  }
}

StringView ToString(CSSMathOperator op) {
  switch (op) {
    case CSSMathOperator::kAdd:
      return StringView("+");
    case CSSMathOperator::kSubtract:
      return StringView("-");
    case CSSMathOperator::kMultiply:
      return StringView("*");
    case CSSMathOperator::kDivide:
      return StringView("/");
    case CSSMathOperator::kMin:
      return StringView("min");
    case CSSMathOperator::kMax:
      return StringView("max");
    case CSSMathOperator::kClamp:
      return StringView("clamp");
    case CSSMathOperator::kRoundNearest:
    case CSSMathOperator::kRoundUp:
    case CSSMathOperator::kRoundDown:
    case CSSMathOperator::kRoundToZero:
      return StringView("round");
    case CSSMathOperator::kMod:
      return StringView("mod");
    case CSSMathOperator::kRem:
      return StringView("rem");
    case CSSMathOperator::kHypot:
      return StringView("hypot");
    case CSSMathOperator::kAbs:
      return StringView("abs");
    case CSSMathOperator::kSign:
      return StringView("sign");
    case CSSMathOperator::kProgress:
      return StringView("progress");
    case CSSMathOperator::kCalcSize:
      return StringView("calc-size");
    case CSSMathOperator::kMediaProgress:
      return StringView("media-progress");
    case CSSMathOperator::kContainerProgress:
      return StringView("container-progress");
    default:
      assert(false);
      return StringView("");
  }
}

StringView ToRoundingStrategyString(CSSMathOperator op) {
  switch (op) {
    case CSSMathOperator::kRoundUp:
      return StringView("up");
    case CSSMathOperator::kRoundDown:
      return StringView("down");
    case CSSMathOperator::kRoundToZero:
      return StringView("to-zero");
    default:
      assert(false);
      return StringView("");
  }
}

bool IsComparison(CSSMathOperator op) {
  return op == CSSMathOperator::kMin || op == CSSMathOperator::kMax || op == CSSMathOperator::kClamp;
}

}  // namespace webf