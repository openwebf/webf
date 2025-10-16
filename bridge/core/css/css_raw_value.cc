#include "css_raw_value.h"
#include "core/css/css_markup.h"

namespace webf {

String CSSRawValue::CustomCSSText() const {
  return SerializeRaw(raw_);
}

}  // namespace webf
