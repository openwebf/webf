//
// Created by 谢作兵 on 18/06/24.
//

#ifndef WEBF_CSS_VIEW_VALUE_H
#define WEBF_CSS_VIEW_VALUE_H

#include "core/css/css_value.h"

namespace webf {

namespace cssvalue {

// https://drafts.csswg.org/scroll-animations-1/#view-notation
class CSSViewValue : public CSSValue {
 public:
  CSSViewValue(const CSSValue* axis, const CSSValue* inset);

  const CSSValue* Axis() const { return axis_.get(); }
  const CSSValue* Inset() const { return inset_.get(); }

  AtomicString CustomCSSText() const;
  bool Equals(const CSSViewValue&) const;
  void TraceAfterDispatch(GCVisitor*) const;

 private:
  std::shared_ptr<const CSSValue> axis_;
  std::shared_ptr<const CSSValue> inset_;
};

}  // namespace cssvalue

template <>
struct DowncastTraits<cssvalue::CSSViewValue> {
  static bool AllowFrom(const CSSValue& value) { return value.IsViewValue(); }
};

}  // namespace webf

#endif  // WEBF_CSS_VIEW_VALUE_H
