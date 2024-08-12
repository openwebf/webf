/*
* Copyright (C) 2008 Apple Inc. All rights reserved.
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

/*
* Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
* Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef WEBF_CSS_UNICODE_RANGE_VALUE_H
#define WEBF_CSS_UNICODE_RANGE_VALUE_H

#include "core/css/css_value.h"
#include "foundation/casting.h"

namespace webf {

namespace cssvalue {

class CSSUnicodeRangeValue : public CSSValue {
 public:
  CSSUnicodeRangeValue(int32_t from, int32_t to)
      : CSSValue(kUnicodeRangeClass), from_(from), to_(to) {}

  int32_t From() const { return from_; }
  int32_t To() const { return to_; }

  std::string CustomCSSText() const;

  bool Equals(const CSSUnicodeRangeValue&) const;

  void TraceAfterDispatch(GCVisitor* visitor) const {
    CSSValue::TraceAfterDispatch(visitor);
  }

 private:
  int32_t from_;
  int32_t to_;
};

}  // namespace cssvalue

template <>
struct DowncastTraits<cssvalue::CSSUnicodeRangeValue> {
  static bool AllowFrom(const CSSValue& value) {
    return value.IsUnicodeRangeValue();
  }
};Ï

}  // namespace webf

#endif  // WEBF_CSS_UNICODE_RANGE_VALUE_H
