/*
 * Copyright (C) 2003, 2004, 2005, 2006, 2010 Apple Inc. All rights reserved.
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
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef WEBF_COLOR_H
#define WEBF_COLOR_H

#include <iosfwd>
#include <optional>
#include <tuple>

#include "SkColor.h"
#include "bindings/qjs/atomic_string.h"
#include "foundation/macros.h"

namespace webf {

typedef unsigned RGBA32;  // RGBA quadruplet

struct NamedColor {
  const char* name;
  unsigned argb_value;
};

const NamedColor* FindColor(const char* str, unsigned len);

class Color {
  WEBF_DISALLOW_NEW();

 public:
  struct KeyHasher {
    std::size_t operator()(const Color& c) const { return c.GetHash(); }
  };
  // The default constructor creates a transparent color.
  constexpr Color() : param0_is_none_(0), param1_is_none_(0), param2_is_none_(0), alpha_is_none_(0) {}

  // TODO(crbug.com/ 1333988): We have to reevaluate how we input int RGB and
  // RGBA values into blink::color. We should remove the int inputs in the
  // interface, to avoid callers to have the double values and convert them to
  // int for then being converted again internally to float. We should deprecate
  // FromRGB, FromRGBA and FromRGBAFloat methods, to only allow for
  // FromRGBALegacy. We could also merge all the constructor methods to one
  // CreateColor(colorSpace, components...) method, that will internally create
  // methods depending of the color space and properly store the none-ness of
  // the components.

  Color(int r, int g, int b);
  Color(int r, int g, int b, int a);

  // Create a color using rgb() syntax.
  static constexpr Color FromRGB(int r, int g, int b) {
    return Color(0xFF000000 | ClampInt255(r) << 16 | ClampInt255(g) << 8 | ClampInt255(b));
  }

  // Create a color using rgba() syntax.
  static constexpr Color FromRGBA(int r, int g, int b, int a) {
    return Color(ClampInt255(a) << 24 | ClampInt255(r) << 16 | ClampInt255(g) << 8 | ClampInt255(b));
  }

  static Color FromRGBALegacy(std::optional<int> r,
                              std::optional<int> g,
                              std::optional<int> b,
                              std::optional<int> alpha);

  // Create a color using the rgba() syntax, with float arguments. All
  // parameters will be clamped to the [0, 1] interval.
  static constexpr Color FromRGBAFloat(float r, float g, float b, float a) { return Color(SkColor4f{r, g, b, a}); }

  // Create a color from a generic color space. Parameters that are none should
  // be specified as std::nullopt. The value for `alpha` will be clamped to the
  // [0, 1] interval. For colorspaces with Luminance the first channel will be
  // clamped to be non-negative. For colorspaces with chroma in param1 that
  // parameter will also be clamped to be non-negative.
  static Color FromColor(std::optional<float> param0,
                         std::optional<float> param1,
                         std::optional<float> param2,
                         std::optional<float> alpha);
  static Color FromColor(std::optional<float> param0, std::optional<float> param1, std::optional<float> param2) {
    return FromColor(param0, param1, param2, 1.0f);
  }

  // Create a color using the hsl() syntax.
  static Color FromHSLA(std::optional<float> h, std::optional<float> s, std::optional<float> l, std::optional<float> a);

  // Create a color using the hwb() syntax.
  static Color FromHWBA(std::optional<float> h, std::optional<float> w, std::optional<float> b, std::optional<float> a);

  enum class HueInterpolationMethod : uint8_t {
    kShorter,
    kLonger,
    kIncreasing,
    kDecreasing,
  };
  // TODO(crbug.com/1308932): These three functions are just helpers for
  // while we're converting platform/graphics to float color.
  static constexpr Color FromSkColor4f(SkColor4f fc) { return Color(fc); }
  static constexpr Color FromSkColor(SkColor color) { return Color(color); }
  static constexpr Color FromRGBA32(RGBA32 color) { return Color(color); }

  std::string SerializeInternal() const;
  // Returns the color serialized according to HTML5:
  // http://www.whatwg.org/specs/web-apps/current-work/#serialization-of-a-color
  std::string SerializeAsCSSColor() const;
  // Canvas colors are serialized somewhat differently:
  // https://html.spec.whatwg.org/multipage/canvas.html#serialisation-of-a-color
  std::string SerializeAsCanvasColor() const;
  // Returns the color serialized as either #RRGGBB or #RRGGBBAA. The latter
  // format is not a valid CSS color, and should only be seen in DRT dumps.
  std::string NameForLayoutTreeAsText() const;

  // Returns whether parsing succeeded. The resulting Color is arbitrary
  // if parsing fails.
  bool SetFromString(const std::string&);
  bool SetNamedColor(const std::string&);

  bool IsFullyTransparent() const { return Alpha() <= 0.0f; }
  bool IsOpaque() const { return Alpha() >= 1.0f; }

  float Param0() const { return param0_; }
  float Param1() const { return param1_; }
  float Param2() const { return param2_; }
  float Alpha() const { return alpha_; }

  // Gradient interpolation needs to know if parameters are "none".
  bool Param0IsNone() const { return param0_is_none_; }
  bool Param1IsNone() const { return param1_is_none_; }
  bool Param2IsNone() const { return param2_is_none_; }
  bool AlphaIsNone() const { return alpha_is_none_; }
  bool HasNoneParams() const { return Param0IsNone() || Param1IsNone() || Param2IsNone() || AlphaIsNone(); }

  void SetAlpha(float alpha) { alpha_ = alpha; }

  // Access the color as though it were created using rgba syntax. This will
  // clamp all colors to an 8-bit sRGB representation. All callers of these
  // functions should be audited. The function Rgb(), despite the name, does
  // not drop the alpha value.
  int Red() const;
  int Green() const;
  int Blue() const;

  // No colorspace conversions affect alpha.
  int AlphaAsInteger() const { return static_cast<int>(lrintf(alpha_ * 255.0f)); }

  RGBA32 Rgb() const;
  void GetRGBA(float& r, float& g, float& b, float& a) const;
  void GetRGBA(double& r, double& g, double& b, double& a) const;

  // Access the color as though it were created using the hsl() syntax.
  void GetHSL(double& h, double& s, double& l) const;

  // Access the color as though it were created using the hwb() syntax.
  void GetHWB(double& h, double& w, double& b) const;

  Color Light() const;
  Color Dark() const;

  // This is an implementation of Porter-Duff's "source-over" equation
  // TODO(https://crbug.com/1333988): Implement CSS Color level 4 blending,
  // including a color interpolation method parameter.
  Color Blend(const Color&) const;
  Color BlendWithWhite() const;

  static bool ParseHexColor(const std::string_view&, Color&);
  static bool ParseHexColor(const char*, unsigned, Color&);

  static const Color kBlack;
  static const Color kWhite;
  static const Color kDarkGray;
  static const Color kGray;
  static const Color kLightGray;
  static const Color kTransparent;

  inline bool operator==(const Color& other) const {
    return param0_is_none_ == other.param0_is_none_ &&
           param1_is_none_ == other.param1_is_none_ && param2_is_none_ == other.param2_is_none_ &&
           alpha_is_none_ == other.alpha_is_none_ && param0_ == other.param0_ && param1_ == other.param1_ &&
           param2_ == other.param2_ && alpha_ == other.alpha_;
  }
  inline bool operator!=(const Color& other) const { return !(*this == other); }

  unsigned GetHash() const;

  // Colors can parse calc(NaN) and calc(Infinity). At computed value time this
  // function is called which resolves all NaNs to zero and +/-infinities to
  // maximum/minimum values, if they exist. It leaves finite values unchanged.
  // See https://github.com/w3c/csswg-drafts/issues/8629
  void ResolveNonFiniteValues();
 private:
  std::string SerializeLegacyColorAsCSSColor() const;
  constexpr explicit Color(RGBA32 color)
      : param0_is_none_(0),
        param1_is_none_(0),
        param2_is_none_(0),
        alpha_is_none_(0),
        param0_(((color >> 16) & 0xFF)),
        param1_(((color >> 8) & 0xFF)),
        param2_(((color >> 0) & 0xFF)),
        alpha_(((color >> 24) & 0xFF) / 255.f) {}
  constexpr explicit Color(SkColor4f color)
      : param0_is_none_(0),
        param1_is_none_(0),
        param2_is_none_(0),
        alpha_is_none_(0),
        param0_(color.fR * 255.0),
        param1_(color.fG * 255.0),
        param2_(color.fB * 255.0),
        alpha_(color.fA) {}
  static constexpr int ClampInt255(int x) { return x < 0 ? 0 : (x > 255 ? 255 : x); }
  void GetHueMaxMin(double&, double&, double&) const;

  float PremultiplyColor();
  void UnpremultiplyColor();
  void ResolveMissingComponents();

  // Whether or not color parameters were specified as none (this only affects
  // interpolation behavior, the parameter values area always valid).
  unsigned param0_is_none_ : 1;
  unsigned param1_is_none_ : 1;
  unsigned param2_is_none_ : 1;
  unsigned alpha_is_none_ : 1;

  // The color parameters.
  float param0_ = 0.f;
  float param1_ = 0.f;
  float param2_ = 0.f;

  // The alpha value for the color is guaranteed to be in the [0, 1] interval.
  float alpha_ = 0.f;
};

// For unit tests and similar.
std::ostream& operator<<(std::ostream& os, const Color& color);

}  // namespace webf

#endif  // WEBF_COLOR_H