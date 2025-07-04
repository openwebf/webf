/*
 * Copyright (C) 2020 Google Inc. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are
 * met:
 *
 *     * Redistributions of source code must retain the above copyright
 * notice, this list of conditions and the following disclaimer.
 *     * Redistributions in binary form must reproduce the above
 * copyright notice, this list of conditions and the following disclaimer
 * in the documentation and/or other materials provided with the
 * distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
 * A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
 * OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 * LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
 * THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#ifndef WEBF_CORE_CSS_RESOLVER_CASCADE_ORIGIN_H_
#define WEBF_CORE_CSS_RESOLVER_CASCADE_ORIGIN_H_

#include <cstdint>

namespace webf {

// https://drafts.csswg.org/css-cascade/#cascade-origin
//
// The top 5 bits of CascadePriority::priority_ are used to store the
// cascade origin and the important bit. The lower values represent higher
// priority.
//
// The important bit is set by inverting the origin value. This way important
// user styles get higher priority than important author styles.
//
// The cascade origin values for animations are special. Since animations
// exist in-between author and !important author, we need to stretch the
// cascade origin by one extra bit.
//
// All origins (without the important bit) must fit in 5 bits. The important
// bit is used to generate important origins by flipping the origin value.
enum class StyleCascadeOrigin : uint8_t {
  kUserAgent = 0b00001,
  kUser = 0b00010,
  kAuthorPresentationalHint = 0b00011,
  kAuthor = 0b00100,
  kAnimation = 0b00101,
  
  // Important versions (inverted):
  kImportantAuthor = 0b11011,  // ~kAuthor & 0x1F
  kImportantUser = 0b11101,   // ~kUser & 0x1F
  kImportantUserAgent = 0b11110,  // ~kUserAgent & 0x1F
  
  kTransition = 0b10000,
  
  kNone = 0,
  kMax = kTransition,
};

constexpr uint8_t kCascadeOriginImportantBit = 0b10000;

inline bool IsImportantOrigin(StyleCascadeOrigin origin) {
  return static_cast<uint8_t>(origin) & kCascadeOriginImportantBit;
}

inline StyleCascadeOrigin ToImportantOrigin(StyleCascadeOrigin origin) {
  return static_cast<StyleCascadeOrigin>(~static_cast<uint8_t>(origin) & 0x1F);
}

inline StyleCascadeOrigin ToNonImportantOrigin(StyleCascadeOrigin origin) {
  if (!IsImportantOrigin(origin))
    return origin;
  return static_cast<StyleCascadeOrigin>(~static_cast<uint8_t>(origin) & 0x1F);
}

}  // namespace webf

#endif  // WEBF_CORE_CSS_RESOLVER_CASCADE_ORIGIN_H_