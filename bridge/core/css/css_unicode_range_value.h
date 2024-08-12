//
// Created by 谢作兵 on 12/08/24.
//

#ifndef WEBF_CSS_UNICODE_RANGE_VALUE_H
#define WEBF_CSS_UNICODE_RANGE_VALUE_H

#include "core/css/css_value.h"
#include "foundation/casting.h"

namespace webf {

namespace cssvalue {

class CSSUnicodeRangeValue : public CSSValue {
 public:
  CSSUnicodeRangeValue(int32_t from, int32_t to)
      : CSSValue(kUnicodeRangeClass), from_(from), to_(to) {}

  int32_t From() const { return from_; }
  int32_t To() const { return to_; }

  std::string CustomCSSText() const;

  bool Equals(const CSSUnicodeRangeValue&) const;

  void TraceAfterDispatch(GCVisitor* visitor) const {
    CSSValue::TraceAfterDispatch(visitor);
  }

 private:
  int32_t from_;
  int32_t to_;
};

}  // namespace cssvalue

template <>
struct DowncastTraits<cssvalue::CSSUnicodeRangeValue> {
  static bool AllowFrom(const CSSValue& value) {
    return value.IsUnicodeRangeValue();
  }
};Ï

}  // namespace webf

#endif  // WEBF_CSS_UNICODE_RANGE_VALUE_H
