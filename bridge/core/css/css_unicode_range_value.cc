//
// Created by 谢作兵 on 12/08/24.
//

#include "css_unicode_range_value.h"

namespace webf {


namespace cssvalue {

std::string CSSUnicodeRangeValue::CustomCSSText() const {
  if (from_ == to_) {
    return std::format("U+{:X}", from_);
  }
  return std::format("U+{:X}-{:X}", from_, to_);
}

bool CSSUnicodeRangeValue::Equals(const CSSUnicodeRangeValue& other) const {
  return from_ == other.from_ && to_ == other.to_;
}

}  // namespace cssvalueÏ

}  // namespace webf