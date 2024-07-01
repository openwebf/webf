//
// Created by 谢作兵 on 27/06/24.
//

#ifndef WEBF_CSS_INITIAL_VALUE_H
#define WEBF_CSS_INITIAL_VALUE_H

#include "core/css/css_value.h"
#include "foundation/casting.h"

namespace webf {


class CSSInitialValue : public CSSValue {
 public:
  static CSSInitialValue* Create();

  CSSInitialValue() : CSSValue(kInitialClass) {}

  AtomicString CustomCSSText(JSContext* ctx) const;

  bool Equals(const CSSInitialValue&) const { return true; }

  void TraceAfterDispatch(GCVisitor* visitor) const {
    CSSValue::TraceAfterDispatch(visitor);
  }

 private:
  friend class CSSValuePool;
};

template <>
struct DowncastTraits<CSSInitialValue> {
  static bool AllowFrom(const CSSValue& value) {
    return value.IsInitialValue();
  }
};


}  // namespace webf

#endif  // WEBF_CSS_INITIAL_VALUE_H
