// Copyright 2015 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#ifndef WEBF_CORE_CSS_CSS_STRING_VALUE_H_
#define WEBF_CORE_CSS_CSS_STRING_VALUE_H_

#include <string>
#include "core/css/css_value.h"

namespace webf {

class CSSStringValue : public CSSValue {
 public:
  CSSStringValue(const String&);

  const String& Value() const { return string_; }

  String CustomCSSText() const;

  bool Equals(const CSSStringValue& other) const { return string_ == other.string_; }

  void TraceAfterDispatch(GCVisitor*) const;

 private:
  String string_;
};

template <>
struct DowncastTraits<CSSStringValue> {
  static bool AllowFrom(const CSSValue& value) { return value.IsStringValue(); }
};

}  // namespace webf

#endif  // WEBF_CORE_CSS_CSS_STRING_VALUE_H_
