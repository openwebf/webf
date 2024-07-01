//
// Created by 谢作兵 on 18/06/24.
//

#include "css_view_value.h"
#include "foundation/string_builder.h"
#include "core/base/memory/values_equivalent.h"

namespace webf {

namespace cssvalue {

CSSViewValue::CSSViewValue(const CSSValue* axis, const CSSValue* inset)
    : CSSValue(kViewClass), axis_(axis), inset_(inset) {}

AtomicString CSSViewValue::CustomCSSText() const {
  StringBuilder result;
  result.Append("view(");
  if (axis_) {
    result.Append(axis_->CssText());
  }
  if (inset_) {
    if (axis_) {
      result.Append(' ');
    }
    result.Append(inset_->CssText());
  }
  result.Append(")");
  return result.ReleaseString();
}

bool CSSViewValue::Equals(const CSSViewValue& other) const {
  return webf::ValuesEquivalent(axis_, other.axis_) &&
         webf::ValuesEquivalent(inset_, other.inset_);
}

void CSSViewValue::TraceAfterDispatch(GCVisitor* visitor) const {
  CSSValue::TraceAfterDispatch(visitor);
}

}  // namespace cssvalue

}  // namespace webf