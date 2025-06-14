// Copyright 2017 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#ifndef WEBF_CORE_CSS_CSS_RAY_VALUE_H_
#define WEBF_CORE_CSS_CSS_RAY_VALUE_H_

#include <memory>
#include "core/css/css_primitive_value.h"
#include "core/css/css_value.h"

namespace webf {

class CSSIdentifierValue;
class CSSPrimitiveValue;

namespace cssvalue {

class CSSRayValue : public CSSValue {
 public:
  CSSRayValue(const std::shared_ptr<const CSSPrimitiveValue>& angle,
              const std::shared_ptr<const CSSIdentifierValue>& size,
              const std::shared_ptr<const CSSIdentifierValue>& contain,
              const std::shared_ptr<const CSSValue>& center_x,
              const std::shared_ptr<const CSSValue>& center_y);

  const CSSPrimitiveValue& Angle() const { return *angle_; }
  const CSSIdentifierValue& Size() const { return *size_; }
  const CSSIdentifierValue* Contain() const { return contain_.get(); }
  const CSSValue* CenterX() const { return center_x_.get(); }
  const CSSValue* CenterY() const { return center_y_.get(); }

  std::string CustomCSSText() const;

  bool Equals(const CSSRayValue&) const;

  void TraceAfterDispatch(GCVisitor*) const;

 private:
  std::shared_ptr<const CSSPrimitiveValue> angle_;
  std::shared_ptr<const CSSIdentifierValue> size_;
  std::shared_ptr<const CSSIdentifierValue> contain_;
  std::shared_ptr<const CSSValue> center_x_;
  std::shared_ptr<const CSSValue> center_y_;
};

}  // namespace cssvalue

template <>
struct DowncastTraits<cssvalue::CSSRayValue> {
  static bool AllowFrom(const CSSValue& value) { return value.IsRayValue(); }
};

}  // namespace webf

#endif  // WEBF_CORE_CSS_CSS_RAY_VALUE_H_