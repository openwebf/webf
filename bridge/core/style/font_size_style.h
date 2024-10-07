// Copyright 2023 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#ifndef WEBF_CORE_STYLE_FONT_SIZE_STYLE_H_
#define WEBF_CORE_STYLE_FONT_SIZE_STYLE_H_

#include "foundation/macros.h"
#include "core/platform/fonts/font.h"
#include "core/platform/geometry/length.h"

namespace webf {

// FontSizeStyle contains the subset of ComputedStyle/ComputedStyleBuilder
// which is needed to resolve units within CSSToLengthConversionData and
// friends.
class FontSizeStyle {
  WEBF_STACK_ALLOCATED();

 public:
  FontSizeStyle(const Font& font,
                const Length& specified_line_height,
                float effective_zoom)
      : font_(font),
        specified_line_height_(specified_line_height),
        effective_zoom_(effective_zoom) {}

  bool operator==(const FontSizeStyle& o) const {
    return (font_ == o.font_ &&
            specified_line_height_ == o.specified_line_height_ &&
            effective_zoom_ == o.effective_zoom_);
  }
  bool operator!=(const FontSizeStyle& o) const { return !(*this == o); }

  const Font& GetFont() const { return font_; }
  const Length& SpecifiedLineHeight() const { return specified_line_height_; }
  float SpecifiedFontSize() const {
    return font_.GetFontDescription().SpecifiedSize();
  }
  float EffectiveZoom() const { return effective_zoom_; }

 private:
  const Font& font_;
  const Length& specified_line_height_;
  const float effective_zoom_;
};

}

#endif  // WEBF_CORE_STYLE_FONT_SIZE_STYLE_H_
