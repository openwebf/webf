/*
 * Copyright (C) 2007 Apple Computer, Inc.  All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY APPLE COMPUTER, INC. ``AS IS'' AND ANY
 * EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
 * PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL APPLE COMPUTER, INC. OR
 * CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
 * EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
 * PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
 * PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY
 * OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */
// Use WebF String/StringBuilder rather than std::string

#include "core/css/css_timing_function_value.h"
#include <cstdint>
#include "foundation/string/string_builder.h"

namespace webf::cssvalue {

String CSSLinearTimingFunctionValue::CustomCSSText() const {
  StringBuilder sb;
  sb.Append("linear("_s);
  for (uint32_t i = 0; i < points_.size(); ++i) {
    if (i != 0) {
      sb.Append(", "_s);
    }
    sb.AppendNumber(points_[i].output);
    sb.Append(' ');
    sb.AppendNumber(points_[i].input);
    sb.Append('%');
  }
  sb.Append(')');
  return sb.ReleaseString();
}

bool CSSLinearTimingFunctionValue::Equals(const CSSLinearTimingFunctionValue& other) const {
  return std::equal(points_.begin(), points_.end(), other.points_.begin(), other.points_.end(),
                    [](const auto& a, const auto& b) { return a.input == b.input && a.output == b.output; });
}

String CSSCubicBezierTimingFunctionValue::CustomCSSText() const {
  StringBuilder sb;
  sb.Append("cubic-bezier("_s);
  sb.AppendNumber(x1_);
  sb.Append(", "_s);
  sb.AppendNumber(y1_);
  sb.Append(", "_s);
  sb.AppendNumber(x2_);
  sb.Append(", "_s);
  sb.AppendNumber(y2_);
  sb.Append(')');
  return sb.ReleaseString();
}

bool CSSCubicBezierTimingFunctionValue::Equals(const CSSCubicBezierTimingFunctionValue& other) const {
  return x1_ == other.x1_ && x2_ == other.x2_ && y1_ == other.y1_ && y2_ == other.y2_;
}

String CSSStepsTimingFunctionValue::CustomCSSText() const {
  String step_position_string;
  switch (step_position_) {
    case StepsTimingFunction::StepPosition::START:
      step_position_string = "start"_s;
      break;

    case StepsTimingFunction::StepPosition::END:
      step_position_string = String::EmptyString();
      break;

    case StepsTimingFunction::StepPosition::JUMP_BOTH:
      step_position_string = "jump-both"_s;
      break;

    case StepsTimingFunction::StepPosition::JUMP_END:
      step_position_string = String::EmptyString();
      break;

    case StepsTimingFunction::StepPosition::JUMP_NONE:
      step_position_string = "jump-none"_s;
      break;

    case StepsTimingFunction::StepPosition::JUMP_START:
      step_position_string = "jump-start"_s;
  }

  // https://drafts.csswg.org/css-easing-1/#serialization
  // If the step position is jump-end or end, serialize as steps(<integer>).
  // Otherwise, serialize as steps(<integer>, <step-position>).
  StringBuilder result;
  result.Append("steps("_s);
  result.AppendNumber(steps_);
  if (!step_position_string.IsEmpty()) {
    result.Append(", "_s);
    result.Append(step_position_string);
  }
  result.Append(')');
  return result.ReleaseString();
}

bool CSSStepsTimingFunctionValue::Equals(const CSSStepsTimingFunctionValue& other) const {
  return steps_ == other.steps_ && step_position_ == other.step_position_;
}

}  // namespace webf::cssvalue
