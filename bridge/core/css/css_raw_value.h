#ifndef WEBF_CORE_CSS_CSS_RAW_VALUE_H_
#define WEBF_CORE_CSS_CSS_RAW_VALUE_H_

#include "core/css/css_value.h"

namespace webf {

// A simple wrapper for raw CSS text (unquoted), serialized using SerializeRaw.
class CSSRawValue : public CSSValue {
 public:
  explicit CSSRawValue(const String& raw) : CSSValue(kRawClass), raw_(raw) { SetRawText(raw_); }
  explicit CSSRawValue(StringView raw) : CSSValue(kRawClass), raw_(raw) { SetRawText(raw_); }

  const String& Value() const { return raw_; }

  String CustomCSSText() const;

  bool Equals(const CSSRawValue& other) const { return raw_ == other.raw_; }

  void TraceAfterDispatch(GCVisitor* visitor) const { CSSValue::TraceAfterDispatch(visitor); }

 private:
  String raw_;
};

template <>
struct DowncastTraits<CSSRawValue> {
  static bool AllowFrom(const CSSValue& value) { return value.IsRawValue(); }
};

}  // namespace webf

#endif  // WEBF_CORE_CSS_CSS_RAW_VALUE_H_
