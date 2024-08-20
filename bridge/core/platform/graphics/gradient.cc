/*
 * Copyright (C) 2006, 2007, 2008, 2010 Apple Inc. All rights reserved.
 * Copyright (C) 2007 Alp Toker <alp@atoker.com>
 * Copyright (C) 2013 Google Inc. All rights reserved.
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

#include "core/platform/graphics/gradient.h"
#include "gfx/geometry/point_f.h"

#include <algorithm>
#include <optional>

namespace webf {

Gradient::Gradient(Type type,
                   GradientSpreadMethod spread_method,
                   ColorInterpolation interpolation,
                   DegenerateHandling degenerate_handling)
    : type_(type),
      spread_method_(spread_method),
      color_interpolation_(interpolation),
      degenerate_handling_(degenerate_handling),
      stops_sorted_(true) {}

Gradient::~Gradient() = default;

static inline bool CompareStops(const Gradient::ColorStop& a, const Gradient::ColorStop& b) {
  return a.stop < b.stop;
}

void Gradient::AddColorStop(const Gradient::ColorStop& stop) {
  if (stops_.empty()) {
    stops_sorted_ = true;
  } else {
    stops_sorted_ = stops_sorted_ && CompareStops(stops_.back(), stop);
  }

  stops_.push_back(stop);
}

void Gradient::AddColorStops(const std::vector<Gradient::ColorStop>& stops) {
  for (const auto& stop : stops) {
    AddColorStop(stop);
  }
}

namespace {

class LinearGradient final : public Gradient {
 public:
  LinearGradient(const gfx::PointF& p0,
                 const gfx::PointF& p1,
                 GradientSpreadMethod spread_method,
                 ColorInterpolation interpolation,
                 DegenerateHandling degenerate_handling)
      : Gradient(Type::kLinear, spread_method, interpolation, degenerate_handling), p0_(p0), p1_(p1) {}

 protected:
 private:
  const gfx::PointF p0_;
  const gfx::PointF p1_;
};

class RadialGradient final : public Gradient {
 public:
  RadialGradient(const gfx::PointF& p0,
                 float r0,
                 const gfx::PointF& p1,
                 float r1,
                 float aspect_ratio,
                 GradientSpreadMethod spread_method,
                 ColorInterpolation interpolation,
                 DegenerateHandling degenerate_handling)
      : Gradient(Type::kRadial, spread_method, interpolation, degenerate_handling),
        p0_(p0),
        p1_(p1),
        r0_(r0),
        r1_(r1),
        aspect_ratio_(aspect_ratio) {}

 protected:
 private:
  const gfx::PointF p0_;
  const gfx::PointF p1_;
  const float r0_;
  const float r1_;
  const float aspect_ratio_;  // For elliptical gradient, width / height.
};

class ConicGradient final : public Gradient {
 public:
  ConicGradient(const gfx::PointF& position,
                float rotation,
                float start_angle,
                float end_angle,
                GradientSpreadMethod spread_method,
                ColorInterpolation interpolation,
                DegenerateHandling degenerate_handling)
      : Gradient(Type::kConic, spread_method, interpolation, degenerate_handling),
        position_(position),
        rotation_(rotation),
        start_angle_(start_angle),
        end_angle_(end_angle) {}

 protected:
 private:
  const gfx::PointF position_;  // center point
  const float rotation_;        // global rotation (deg)
  const float start_angle_;     // angle (deg) corresponding to color position 0
  const float end_angle_;       // angle (deg) corresponding to color position 1
};

}  // namespace

std::shared_ptr<Gradient> Gradient::CreateLinear(const gfx::PointF& p0,
                                                 const gfx::PointF& p1,
                                                 GradientSpreadMethod spread_method,
                                                 ColorInterpolation interpolation,
                                                 DegenerateHandling degenerate_handling) {
  return std::make_shared<LinearGradient>(p0, p1, spread_method, interpolation, degenerate_handling);
}

std::shared_ptr<Gradient> Gradient::CreateRadial(const gfx::PointF& p0,
                                               float r0,
                                               const gfx::PointF& p1,
                                               float r1,
                                               float aspect_ratio,
                                               GradientSpreadMethod spread_method,
                                               ColorInterpolation interpolation,
                                               DegenerateHandling degenerate_handling) {
  return std::make_shared<RadialGradient>(p0, r0, p1, r1, aspect_ratio, spread_method, interpolation, degenerate_handling);
}

std::shared_ptr<Gradient> Gradient::CreateConic(const gfx::PointF& position,
                                              float rotation,
                                              float start_angle,
                                              float end_angle,
                                              GradientSpreadMethod spread_method,
                                              ColorInterpolation interpolation,
                                              DegenerateHandling degenerate_handling) {
  return std::make_shared<ConicGradient>(position, rotation, start_angle, end_angle, spread_method, interpolation, degenerate_handling);
}

}  // namespace webf