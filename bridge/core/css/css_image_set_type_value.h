// Copyright 2023 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#ifndef CORE_CSS_CSS_IMAGE_SET_TYPE_VALUE_H_
#define CORE_CSS_CSS_IMAGE_SET_TYPE_VALUE_H_

#include "core/css/css_value.h"

namespace webf {

// This class represents the CSS type() function as specified in:
// https://w3c.github.io/csswg-drafts/css-images-4/#funcdef-image-set-type
// type(<string>) function, specifying the image's MIME type in the <string>.
class CSSImageSetTypeValue : public CSSValue {
 public:
  explicit CSSImageSetTypeValue(const std::string& type);

  ~CSSImageSetTypeValue();

  // Returns true if the image type is supported
  bool IsSupported() const;

  std::string CustomCSSText() const;

  bool Equals(const CSSImageSetTypeValue& other) const;

  void TraceAfterDispatch(GCVisitor* visitor) const;

 private:
  std::string type_;
};

template <>
struct DowncastTraits<CSSImageSetTypeValue> {
  static bool AllowFrom(const CSSValue& value) { return value.IsImageSetTypeValue(); }
};

}  // namespace webf

#endif  // CORE_CSS_CSS_IMAGE_SET_TYPE_VALUE_H_