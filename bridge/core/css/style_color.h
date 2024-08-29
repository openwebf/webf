/*
 * Copyright (C) 2013 Google Inc. All rights reserved.
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
 *     * Neither the name of Google Inc. nor the names of its
 * contributors may be used to endorse or promote products derived from
 * this software without specific prior written permission.
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

// Copyright (C) 2022-present The WebF authors. All rights reserved.

#ifndef WEBF_CORE_CSS_STYLE_COLOR_H_
#define WEBF_CORE_CSS_STYLE_COLOR_H_

#include "core/css/css_color.h"
#include "css_value_keywords.h"
#include <memory>

//#include "third_party/blink/public/mojom/frame/color_scheme.mojom-blink-forward.h"
#include "css_value_keywords.h"
#include "core/platform/graphics/color.h"
#include "foundation/macros.h"
#include "bindings/qjs/cppgc/garbage_collected.h"
#include "bindings/qjs/cppgc/member.h"

namespace ui {
class ColorProvider;
}  // namespace ui

namespace webf {

namespace mojom {
enum class ColorScheme : int32_t;
}

namespace cssvalue {
class CSSColorMixValue;
}  // namespace cssvalue

class StyleColor {
  WEBF_DISALLOW_NEW();

 public:
  // When color-mix functions contain colors that cannot be resolved until used
  // value time (such as "currentcolor"), we need to store them here and
  // resolve them to individual colors later.
  struct ColorOrUnresolvedColorMix {
    WEBF_DISALLOW_NEW();

   public:
    ColorOrUnresolvedColorMix() : color(Color::kTransparent) {}
    explicit ColorOrUnresolvedColorMix(Color color) : color(color) {}

    Color color;
  };

  StyleColor() = default;
  explicit StyleColor(Color color) : color_keyword_(CSSValueID::kInvalid) {}
  explicit StyleColor(CSSValueID keyword) : color_keyword_(keyword) {}
//  explicit StyleColor(const UnresolvedColorMix* color_mix)
//      : color_keyword_(CSSValueID::kColorMix),
//        color_or_unresolved_color_mix_(color_mix) {}
  // We need to store the color and keyword for system colors to be able to
  // distinguish system colors from a normal color. System colors won't be
  // overridden by forced colors mode, even if forced-color-adjust is 'auto'.
  StyleColor(Color color, CSSValueID keyword) : color_keyword_(keyword) {}

  void Trace(GCVisitor* visitor) const {}

  static StyleColor CurrentColor() { return StyleColor(); }

  bool IsCurrentColor() const { return color_keyword_ == CSSValueID::kCurrentcolor; }
  bool IsSystemColorIncludingDeprecated() const { return IsSystemColorIncludingDeprecated(color_keyword_); }
  bool IsUnresolvedColorMixFunction() const {
    return color_keyword_ == CSSValueID::kColorMix;
  }
  bool IsSystemColor() const { return IsSystemColor(color_keyword_); }
  bool IsAbsoluteColor() const { return !IsCurrentColor(); }
  Color GetColor() const;

  CSSValueID GetColorKeyword() const {
    assert(!IsNumeric());
    return color_keyword_;
  }
  bool HasColorKeyword() const { return color_keyword_ != CSSValueID::kInvalid; }

  Color Resolve(const Color& current_color, ColorScheme color_scheme, bool* is_current_color = nullptr) const;

  bool IsNumeric() const { return EffectiveColorKeyword() == CSSValueID::kInvalid; }

  static Color ColorFromKeyword(CSSValueID, ColorScheme color_scheme);
  static bool IsColorKeyword(CSSValueID);
  static bool IsSystemColorIncludingDeprecated(CSSValueID);
  static bool IsSystemColor(CSSValueID);

  inline bool operator==(const StyleColor& other) const {
    if (color_keyword_ != other.color_keyword_) {
      return false;
    }

    if (IsCurrentColor() && other.IsCurrentColor()) {
      return true;
    }

    return color == other.color;
  }

  inline bool operator!=(const StyleColor& other) const { return !(*this == other); }

 protected:
  CSSValueID color_keyword_ = CSSValueID::kCurrentcolor;
  Color color;
  ColorOrUnresolvedColorMix color_or_unresolved_color_mix_;

 private:
  CSSValueID EffectiveColorKeyword() const;
};

// For debugging only.
std::ostream& operator<<(std::ostream& stream, const StyleColor& color);

}  // namespace webf

#endif  // WEBF_CORE_CSS_STYLE_COLOR_H_
