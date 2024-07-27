// Copyright 2019 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#ifndef WEBF_CORE_CSS_CSS_MATH_OPERATOR_H_
#define WEBF_CORE_CSS_CSS_MATH_OPERATOR_H_

#include "foundation/string_view.h"

namespace webf {


class CSSParserToken;

enum class CSSMathOperator {
  kAdd,
  kSubtract,
  kMultiply,
  kDivide,
  kMin,
  kMax,
  kClamp,
  kRoundNearest,
  kRoundUp,
  kRoundDown,
  kRoundToZero,
  kMod,
  kRem,
  kHypot,
  kAbs,
  kSign,
  kProgress,
  kCalcSize,
  kMediaProgress,
  kContainerProgress,
  kInvalid
};

CSSMathOperator ParseCSSArithmeticOperator(const CSSParserToken& token);
std::string ToString(CSSMathOperator);
std::string ToRoundingStrategyString(CSSMathOperator);

bool IsComparison(CSSMathOperator);

}

#endif  // WEBF_CORE_CSS_CSS_MATH_OPERATOR_H_
