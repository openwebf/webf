/*
 * Copyright (C) 2011 Andreas Kling (kling@webkit.org)
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
 *
 */

/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "core/geometry/length.h"
#include "css_identifier_value.h"
#include "core/css/css_primitive_value.h"
#include "css_value.h"

namespace webf {

std::shared_ptr<CSSValue> CSSValue::Create(const webf::Length& value, float zoom) {
  switch (value.GetType()) {
    case Length::kAuto:
    case Length::kMinContent:
    case Length::kMaxContent:
    case Length::kFillAvailable:
    case Length::kFitContent:
    case Length::kContent:
    case Length::kExtendToZoom:
      return CSSIdentifierValue::Create(value);
    case Length::kPercent:
    case Length::kFixed:
    case Length::kCalculated:
    case Length::kFlex:
      return CSSPrimitiveValue::CreateFromLength(value, zoom);
    case Length::kDeviceWidth:
    case Length::kDeviceHeight:
    case Length::kMinIntrinsic:
    case Length::kNone:
      assert(false);
      break;
  }
  return nullptr;
}


}  // namespace webf
