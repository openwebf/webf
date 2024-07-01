//
// Created by 谢作兵 on 27/06/24.
//

#include "css_initial_value.h"
#include "core/css/css_value_pool.h"

namespace webf {

CSSInitialValue* CSSInitialValue::Create() {
  return CssValuePool().InitialValue();
}

AtomicString CSSInitialValue::CustomCSSText(JSContext* ctx) const {
  return AtomicString(ctx, "initial");
}

}  // namespace webf