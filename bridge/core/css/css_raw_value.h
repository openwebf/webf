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
  const String& BaseHref() const { return base_href_; }
  bool HasBaseHref() const { return !base_href_.IsNull() && base_href_.length(); }
  void SetBaseHref(const String& base_href) { base_href_ = base_href; }

  String CustomCSSText() const;

  bool Equals(const CSSRawValue& other) const { return raw_ == other.raw_; }

  void TraceAfterDispatch(GCVisitor* visitor) const { CSSValue::TraceAfterDispatch(visitor); }

 private:
  String raw_;
  // Optional base href for this declaration's value, derived from the
  // CSSParserContext base URL at parse time. Used so consumers (e.g. Dart
  // bridge) can resolve relative url(...) tokens consistently with the
  // stylesheet that defined the declaration.
  String base_href_;
};

template <>
struct DowncastTraits<CSSRawValue> {
  static bool AllowFrom(const CSSValue& value) { return value.IsRawValue(); }
};

}  // namespace webf

#endif  // WEBF_CORE_CSS_CSS_RAW_VALUE_H_
