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

std::string ToString(CSSMathOperator op) {
  switch (op) {
    case CSSMathOperator::kAdd:
      return "+";
    case CSSMathOperator::kSubtract:
      return "-";
    case CSSMathOperator::kMultiply:
      return "*";
    case CSSMathOperator::kDivide:
      return "/";
    case CSSMathOperator::kMin:
      return "min";
    case CSSMathOperator::kMax:
      return "max";
    case CSSMathOperator::kClamp:
      return "clamp";
    case CSSMathOperator::kRoundNearest:
    case CSSMathOperator::kRoundUp:
    case CSSMathOperator::kRoundDown:
    case CSSMathOperator::kRoundToZero:
      return "round";
    case CSSMathOperator::kMod:
      return "mod";
    case CSSMathOperator::kRem:
      return "rem";
    case CSSMathOperator::kHypot:
      return "hypot";
    case CSSMathOperator::kAbs:
      return "abs";
    case CSSMathOperator::kSign:
      return "sign";
    case CSSMathOperator::kProgress:
      return "progress";
    case CSSMathOperator::kCalcSize:
      return "calc-size";
    case CSSMathOperator::kMediaProgress:
      return "media-progress";
    case CSSMathOperator::kContainerProgress:
      return "container-progress";
    default:
      assert(false);
      return "";
  }
}

std::string ToRoundingStrategyString(CSSMathOperator op) {
  switch (op) {
    case CSSMathOperator::kRoundUp:
      return "up";
    case CSSMathOperator::kRoundDown:
      return "down";
    case CSSMathOperator::kRoundToZero:
      return "to-zero";
    default:
      assert(false);
      return "";
  }
}

bool IsComparison(CSSMathOperator op) {
  return op == CSSMathOperator::kMin || op == CSSMathOperator::kMax ||
         op == CSSMathOperator::kClamp;
}

}