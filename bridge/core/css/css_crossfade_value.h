/*
 * Copyright (C) 2011 Apple Inc. All rights reserved.
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

#ifndef WEBF_CORE_CSS_CSS_CROSSFADE_VALUE_H_
#define WEBF_CORE_CSS_CSS_CROSSFADE_VALUE_H_

#include "core/css/css_image_generator_value.h"
#include "core/css/css_primitive_value.h"

namespace webf {

namespace cssvalue {

class CSSCrossfadeValue final : public CSSImageGeneratorValue {
 public:
  CSSCrossfadeValue(
      bool is_prefixed_variant,
      std::vector<std::pair<std::shared_ptr<const CSSValue>, std::shared_ptr<const CSSPrimitiveValue>>> image_and_percentages);
  ~CSSCrossfadeValue();

  const std::vector<std::pair<std::shared_ptr<const CSSValue>, std::shared_ptr<const CSSPrimitiveValue>>>& GetImagesAndPercentages()
      const {
    return image_and_percentages_;
  }
  bool IsPrefixedVariant() const { return is_prefixed_variant_; }

  std::string CustomCSSText() const;
  bool HasFailedOrCanceledSubresources() const;
  bool Equals(const CSSCrossfadeValue&) const;

  void TraceAfterDispatch(GCVisitor*) const;

 private:
  class ObserverProxy;

  bool is_prefixed_variant_;  // -webkit-cross-fade() instead of cross-fade()
  std::vector<std::pair<std::shared_ptr<const CSSValue>, std::shared_ptr<const CSSPrimitiveValue>>> image_and_percentages_;
};

}  // namespace cssvalue

template <>
struct DowncastTraits<cssvalue::CSSCrossfadeValue> {
  static bool AllowFrom(const CSSValue& value) { return value.IsCrossfadeValue(); }
};

}  // namespace webf

#endif  // WEBF_CORE_CSS_CSS_CROSSFADE_VALUE_H_