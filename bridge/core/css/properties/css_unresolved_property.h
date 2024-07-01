//
// Created by 谢作兵 on 18/06/24.
//

#ifndef WEBF_CSS_UNRESOLVED_PROPERTY_H
#define WEBF_CSS_UNRESOLVED_PROPERTY_H

#include "core/css/properties/css_exposure.h"
#include "core/css/properties/css_property_instances.h"
#include "built_in_string.h"
//#include ""

namespace webf {

class ExecutingContext;

// TODO(crbug.com/793288): audit and consider redesigning how aliases are
// handled once more of project Ribbon is done and all use of aliases can be
// found and (hopefully) constrained.
class CSSUnresolvedProperty {
 public:
  static const CSSUnresolvedProperty& Get(CSSPropertyID id) {
    assert(id != CSSPropertyID::kInvalid);
    assert(id <= kLastUnresolvedCSSProperty);
    return *GetPropertyInternal(id);
  }

  // Origin trials are taken into account only when a non-nullptr
  // ExecutingContext is provided.
  bool IsWebExposed(const ExecutingContext* context = nullptr) const {
    return webf::IsWebExposed(Exposure(context));
  }
  bool IsUAExposed(const ExecutingContext* context = nullptr) const {
    return webf::IsUAExposed(Exposure(context));
  }
  virtual CSSExposure Exposure(const ExecutingContext* = nullptr) const {
    return CSSExposure::kWeb;
  }

  virtual bool IsResolvedProperty() const { return false; }
  virtual const char* GetPropertyName() const {
    assert_m(false, "NOTREACHED_IN_MIGRATION");
    return nullptr;
  }
  virtual const AtomicString& GetPropertyNameAtomicString() const {
    assert_m(false, "NOTREACHED_IN_MIGRATION");
    return built_in_string::kempty_string;
  }
  virtual const char* GetJSPropertyName() const {
    assert_m(false, "NOTREACHED_IN_MIGRATION");
    return "";
  }
  AtomicString GetPropertyNameString() const {
    // We share the StringImpl with the AtomicStrings.
    return GetPropertyNameAtomicString();
  }
  // See documentation near "alternative_of" in css_properties.json5.
  virtual CSSPropertyID GetAlternative() const {
    return CSSPropertyID::kInvalid;
  }

 protected:
  constexpr CSSUnresolvedProperty() = default;
};

}  // namespace webf

#endif  // WEBF_CSS_UNRESOLVED_PROPERTY_H
