/*
* Copyright (C) 2011 Google Inc. All rights reserved.
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

// Copyright (C) 2022-present The WebF authors. All rights reserved.

#include "css_font_feature_value.h"

namespace webf {

namespace cssvalue {

CSSFontFeatureValue::CSSFontFeatureValue(const std::string& tag, int value)
    : CSSValue(kFontFeatureClass), tag_(tag), value_(value) {}

std::string CSSFontFeatureValue::CustomCSSText() const {
  std::string builder;
  builder+='"';
  builder+=tag_;
  builder+='"';
  // Omit the value if it's 1 as 1 is implied by default.
  if (value_ != 1) {
    builder+=' ';
    builder=+value_;
  }
  return builder;
}

bool CSSFontFeatureValue::Equals(const CSSFontFeatureValue& other) const {
  return tag_ == other.tag_ && value_ == other.value_;
}

}  // namespace cssvalue
}  // namespace webf