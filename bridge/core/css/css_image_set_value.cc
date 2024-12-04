/*
 * Copyright (C) 2012 Apple Inc. All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY APPLE INC. AND ITS CONTRIBUTORS ``AS IS''
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
 * THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
 * PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL APPLE INC. OR ITS CONTRIBUTORS
 * BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF
 * THE POSSIBILITY OF SUCH DAMAGE.
 */

#include "core/css/css_image_set_value.h"
#include "core/css/css_image_set_option_value.h"
#include "foundation/string_builder.h"

#include <algorithm>

namespace webf {

CSSImageSetValue::CSSImageSetValue() : CSSValueList(kImageSetClass, kCommaSeparator) {}

CSSImageSetValue::~CSSImageSetValue() = default;

const std::shared_ptr<const CSSImageSetOptionValue> CSSImageSetValue::GetBestOption(const float device_scale_factor) {
  // This method is implementing the selection logic described in the
  // "CSS Images Module Level 4" spec:
  // https://w3c.github.io/csswg-drafts/css-images-4/#image-set-notation
  //
  // Spec definition of image-set-option selection algorithm:
  //
  // "An image-set() function contains a list of one or more
  // <image-set-option>s, and must select only one of them
  // to determine what image it will represent:
  //
  //   1. First, remove any <image-set-option>s from the list that specify an
  //      unknown or unsupported MIME type in their type() value.
  //   2. Second, remove any <image-set-option>s from the list that have the
  //      same <resolution> as a previous option in the list.
  //   3. Finally, among the remaining <image-set-option>s, make a UA-specific
  //      choice of which to load, based on whatever criteria deemed relevant
  //      (such as the resolution of the display, connection speed, etc).
  //   4. The image-set() function then represents the <image> of the chosen
  //      <image-set-option>."

  if (options_.empty()) {
    for (const auto& i : *this) {
      auto option = std::static_pointer_cast<const CSSImageSetOptionValue>(i);
      if (option->IsSupported()) {
        options_.push_back(option);
      }
    }

    if (options_.empty()) {
      // No supported options were identified in the image-set.
      // As an optimization in order to avoid having to iterate
      // through the unsupported options on subsequent calls,
      // nullptr is inserted in the options_ vector.
      options_.push_back(nullptr);
    } else {
      std::stable_sort(options_.begin(), options_.end(), [](auto& left, auto& right) {
        return left->ComputedResolution() < right->ComputedResolution();
      });
      auto last = std::unique(options_.begin(), options_.end(), [](auto& left, auto& right) {
        return left->ComputedResolution() == right->ComputedResolution();
      });
      options_.erase(last, options_.end());
    }
  }

  for (const auto& option : options_) {
    if (option && option->ComputedResolution() >= device_scale_factor) {
      return option;
    }
  }

  return options_.back();
}

std::string CSSImageSetValue::CustomCSSText() const {
  StringBuilder result;
  result.Append("image-set(");

  for (size_t i = 0, length = this->length(); i < length; ++i) {
    if (i > 0) {
      result.Append(", ");
    }

    result.Append(Item(i)->CssText());
  }

  result.Append(')');

  return result.ReleaseString();
}

void CSSImageSetValue::TraceAfterDispatch(GCVisitor* visitor) const {
  CSSValueList::TraceAfterDispatch(visitor);
}

}  // namespace webf
