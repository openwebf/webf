// Copyright 2022 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// Copyright (C) 2022-present The WebF authors. All rights reserved.

#ifndef WEBF_CORE_CSS_CSS_ANCHOR_QUERY_ENUMS_H_
#define WEBF_CORE_CSS_CSS_ANCHOR_QUERY_ENUMS_H_

#include <cstdint>

namespace webf {

enum class CSSAnchorQueryType : uint8_t {
  kAnchor = 1 << 0,
  kAnchorSize = 1 << 1
};

using CSSAnchorQueryTypes = uint8_t;
constexpr CSSAnchorQueryTypes kCSSAnchorQueryTypesNone = 0u;
constexpr CSSAnchorQueryTypes kCSSAnchorQueryTypesAll =
    ~kCSSAnchorQueryTypesNone;

enum class CSSAnchorValue {
  kInside,
  kOutside,
  kTop,
  kLeft,
  kRight,
  kBottom,
  kStart,
  kEnd,
  kSelfStart,
  kSelfEnd,
  kCenter,
  kPercentage,
};

enum class CSSAnchorSizeValue {
  kWidth,
  kHeight,
  kBlock,
  kInline,
  kSelfBlock,
  kSelfInline,
};

}  // namespace webf

#endif  // WEBF_CORE_CSS_CSS_ANCHOR_QUERY_ENUMS_H_