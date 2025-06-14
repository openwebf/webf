// Copyright 2016 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#include "core/platform/geometry/layout_unit.h"

#include <ostream>
#include "core/platform/text/text_stream.h"

namespace webf {

namespace {

std::string FromLayoutUnit(LayoutUnit value) {
  // Request full precision, avoid scientific notation. 14 is just enough for a
  // LayoutUnit (8 for the integer part (we can represent just above 30
  // million), plus 6 for the fractional part (1/64)).
  return std::to_string(value.ToDouble());
}

}  // anonymous namespace

std::string LayoutUnit::ToString() const {
  if (value_ == LayoutUnit::Max().RawValue())
    return "LayoutUnit::max(" + FromLayoutUnit(*this) + ")";
  if (value_ == LayoutUnit::Min().RawValue())
    return "LayoutUnit::min(" + FromLayoutUnit(*this) + ")";
  if (value_ == LayoutUnit::NearlyMax().RawValue())
    return "LayoutUnit::nearlyMax(" + FromLayoutUnit(*this) + ")";
  if (value_ == LayoutUnit::NearlyMin().RawValue())
    return "LayoutUnit::nearlyMin(" + FromLayoutUnit(*this) + ")";
  return FromLayoutUnit(*this);
}

std::ostream& operator<<(std::ostream& stream, const LayoutUnit& value) {
  return stream << value.ToString();
}

}  // namespace webf