// Copyright 2016 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#include "core/platform/geometry/layout_unit.h"

#include <ostream>
#include "core/platform/text/text_stream.h"

namespace webf {

namespace {

template <unsigned fractional_bits, typename Storage>
std::string FromLayoutUnit(FixedPoint<fractional_bits, Storage> value) {
  // Request full precision, avoid scientific notation. 14 is just enough for a
  // LayoutUnit (8 for the integer part (we can represent just above 30
  // million), plus 6 for the fractional part (1/64)).
  return std::to_string(value.ToDouble());
}

}  // anonymous namespace

template <unsigned fractional_bits, typename Storage>
std::string FixedPoint<fractional_bits, Storage>::ToString() const {
  if (value_ == Max().RawValue()) {
    return "Max(" + FromLayoutUnit(*this) + ")";
  }
  if (value_ == Min().RawValue()) {
    return "Min(" + FromLayoutUnit(*this) + ")";
  }
  if (value_ == NearlyMax().RawValue()) {
    return "NearlyMax(" + FromLayoutUnit(*this) + ")";
  }
  if (value_ == NearlyMin().RawValue()) {
    return "NearlyMin(" + FromLayoutUnit(*this) + ")";
  }
  return FromLayoutUnit(*this);
}

template <unsigned fractional_bits, typename Storage>
std::ostream& operator<<(std::ostream& stream,
                         const FixedPoint<fractional_bits, Storage>& value) {
  return stream << value.ToString();
}

template <unsigned fractional_bits, typename Storage>
webf::TextStream& operator<<(webf::TextStream& ts,
                            const FixedPoint<fractional_bits, Storage>& unit) {
  return ts << webf::TextStream::FormatNumberRespectingIntegers(unit.ToDouble());
}

// Explicit instantiations.
#define INSTANTIATE(fractional_bits, Storage)                      \
  template class FixedPoint<fractional_bits, Storage>;             \
  template std::ostream& operator<<(                               \
      std::ostream&, const FixedPoint<fractional_bits, Storage>&); \
  template webf::TextStream& operator<<(                            \
      webf::TextStream&, const FixedPoint<fractional_bits, Storage>&)

INSTANTIATE(6, int32_t);
INSTANTIATE(16, int32_t);
INSTANTIATE(16, int64_t);

}  // namespace blink