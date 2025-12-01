/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */
// Copyright 2020 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#ifndef WEBF_CORE_STYLE_STYLE_ASPECT_RATIO_H_
#define WEBF_CORE_STYLE_STYLE_ASPECT_RATIO_H_

#include "foundation/macros.h"
#include "core/platform/gfx/geometry/size_f.h"

namespace webf {

enum class EAspectRatioType { kAuto, kAutoAndRatio, kRatio };

class StyleAspectRatio {
  WEBF_DISALLOW_NEW();

 public:
  // Style data for aspect-ratio: auto || <ratio>
  StyleAspectRatio(EAspectRatioType type, gfx::SizeF ratio)
      : type_(static_cast<unsigned>(type)), ratio_(ratio) {}

  EAspectRatioType GetType() const {
    if (ratio_.IsEmpty()) {
      return EAspectRatioType::kAuto;
    }
    return GetTypeForComputedStyle();
  }

  EAspectRatioType GetTypeForComputedStyle() const {
    return static_cast<EAspectRatioType>(type_);
  }

  bool IsAuto() const { return GetType() == EAspectRatioType::kAuto; }

  gfx::SizeF GetRatio() const { return ratio_; }

  bool operator==(const StyleAspectRatio& o) const {
    return type_ == o.type_ && ratio_ == o.ratio_;
  }

  bool operator!=(const StyleAspectRatio& o) const { return !(*this == o); }

 private:
  unsigned type_ : 2;  // EAspectRatioType
  gfx::SizeF ratio_;
};

}  // namespace webf

#endif  // WEBF_CORE_STYLE_STYLE_ASPECT_RATIO_H_