/*
 * Copyright (C) 2011 Apple Inc.  All rights reserved.
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
 * THIS SOFTWARE IS PROVIDED BY APPLE COMPUTER, INC. ``AS IS'' AND ANY
 * EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
 * PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL APPLE COMPUTER, INC. OR
 * CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
 * EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
 * PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
 * PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY
 * OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#include "core/css/css_crossfade_value.h"
#include "foundation/string_builder.h"

namespace webf {
namespace cssvalue {

CSSCrossfadeValue::CSSCrossfadeValue(
    bool is_prefixed_variant,
    std::vector<std::pair<std::shared_ptr<const CSSValue>, std::shared_ptr<const CSSPrimitiveValue>>>
        image_and_percentages)
    : CSSImageGeneratorValue(kCrossfadeClass),
      is_prefixed_variant_(is_prefixed_variant),
      image_and_percentages_(std::move(image_and_percentages)) {}

CSSCrossfadeValue::~CSSCrossfadeValue() = default;

std::string CSSCrossfadeValue::CustomCSSText() const {
  StringBuilder result;
  if (is_prefixed_variant_) {
    CHECK_EQ(2u, image_and_percentages_.size());
    result.Append("-webkit-cross-fade(");
    result.Append(image_and_percentages_[0].first->CssText());
    result.Append(", ");
    result.Append(image_and_percentages_[1].first->CssText());
    result.Append(", ");
    result.Append(image_and_percentages_[1].second->CssText());
    result.Append(')');
    DCHECK_EQ(nullptr, image_and_percentages_[0].second);
  } else {
    result.Append("cross-fade(");
    bool first = true;
    for (const auto& [image, percentage] : image_and_percentages_) {
      if (!first) {
        result.Append(", ");
      }
      result.Append(image->CssText());
      if (percentage) {
        result.Append(' ');
        result.Append(percentage->CssText());
      }
      first = false;
    }
    result.Append(')');
  }
  return result.ReleaseString();
}

bool CSSCrossfadeValue::HasFailedOrCanceledSubresources() const {
  return std::any_of(image_and_percentages_.begin(), image_and_percentages_.end(), [](const auto& image_and_percent) {
    return image_and_percent.first->HasFailedOrCanceledSubresources();
  });
}

bool CSSCrossfadeValue::Equals(const CSSCrossfadeValue& other) const {
  if (image_and_percentages_.size() != other.image_and_percentages_.size()) {
    return false;
  }
  for (unsigned i = 0; i < image_and_percentages_.size(); ++i) {
    if (!ValuesEquivalent(image_and_percentages_[i].first, other.image_and_percentages_[i].first)) {
      return false;
    }
    if (!ValuesEquivalent(image_and_percentages_[i].second, other.image_and_percentages_[i].second)) {
      return false;
    }
  }
  return true;
}

void CSSCrossfadeValue::TraceAfterDispatch(GCVisitor* visitor) const {
  CSSImageGeneratorValue::TraceAfterDispatch(visitor);
}

}  // namespace cssvalue
}  // namespace webf