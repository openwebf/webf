// Copyright 2023 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#ifndef CORE_CSS_CSS_IMAGE_SET_OPTION_VALUE_H_
#define CORE_CSS_CSS_IMAGE_SET_OPTION_VALUE_H_

#include "core/css/css_value.h"

namespace webf {

class CSSImageSetTypeValue;
class CSSPrimitiveValue;

// This class represents an image-set-option as specified in:
// https://w3c.github.io/csswg-drafts/css-images-4/#typedef-image-set-option
// <image-set-option> = [ <image> | <string> ] [<resolution> || type(<string>)]
class CSSImageSetOptionValue : public CSSValue {
 public:
  explicit CSSImageSetOptionValue(std::shared_ptr<const CSSValue> image,
                                  std::shared_ptr<const CSSPrimitiveValue> resolution = nullptr,
                                  std::shared_ptr<const CSSImageSetTypeValue> type = nullptr);

  // It is expected that CSSImageSetOptionValue objects should always have
  // non-null image and resolution values.
  CSSImageSetOptionValue() = delete;

  ~CSSImageSetOptionValue();

  // Gets the resolution value in Dots Per Pixel
  double ComputedResolution() const;

  // Returns true if the image-set-option uses an image format that the
  // browser can render.
  bool IsSupported() const;

  CSSValue& GetImage() const;
  const CSSPrimitiveValue& GetResolution() const;
  const CSSImageSetTypeValue* GetType() const;

  std::string CustomCSSText() const;

  bool Equals(const CSSImageSetOptionValue& other) const;

  void TraceAfterDispatch(GCVisitor* visitor) const;

 private:
  std::shared_ptr<const CSSValue> image_;
  std::shared_ptr<const CSSPrimitiveValue> resolution_;
  std::shared_ptr<const CSSImageSetTypeValue> type_;
};

template <>
struct DowncastTraits<CSSImageSetOptionValue> {
  static bool AllowFrom(const CSSValue& value) {
    return value.IsImageSetOptionValue();
  }
};

}  // namespace blink

#endif  // CORE_CSS_CSS_IMAGE_SET_OPTION_VALUE_H_