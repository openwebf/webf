/*
 * Copyright (C) 2000 Lars Knoll (knoll@kde.org)
 *           (C) 2000 Antti Koivisto (koivisto@kde.org)
 *           (C) 2000 Dirk Mueller (mueller@kde.org)
 * Copyright (C) 2003, 2005, 2006, 2007, 2008 Apple Inc. All rights reserved.
 * Copyright (C) 2006 Graham Dennis (graham.dennis@gmail.com)
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Library General Public
 * License as published by the Free Software Foundation; either
 * version 2 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Library General Public License for more details.
 *
 * You should have received a copy of the GNU Library General Public License
 * along with this library; see the file COPYING.LIB.  If not, write to
 * the Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
 * Boston, MA 02110-1301, USA.
 *
 */

// Copyright (C) 2022-present The WebF authors. All rights reserved.

#ifndef WEBF_PLATFORM_ANIMATION_TIMING_FUNCTION_H_
#define WEBF_PLATFORM_ANIMATION_TIMING_FUNCTION_H_

#include <vector>
#include <cassert>
#include "foundation/macros.h"
//#include "base/memory/scoped_refptr.h"
#include "core/base/ranges/algorithm.h"
//#include "third_party/blink/renderer/platform/wtf/casting.h"
#include "foundation/casting.h"
//#include "third_party/blink/renderer/platform/wtf/text/wtf_string.h"
//#include "third_party/blink/renderer/platform/wtf/thread_safe_ref_counted.h"
#include "gfx/animation/keyframe/timing_function.h"

namespace webf {

class TimingFunction {
 public:
  using Type = gfx::TimingFunction::Type;
  using LimitDirection = gfx::TimingFunction::LimitDirection;

  virtual ~TimingFunction() = default;

  Type GetType() const { return type_; }

  virtual std::string ToString() const = 0;

  // Evaluates the timing function at the given fraction. The limit direction
  // applies when evaluating a function at a discontinuous boundary and
  // indicates if the left or right limit should be applied.
  virtual double Evaluate(double fraction,
                          LimitDirection limit_direction) const = 0;

  // This function returns the minimum and maximum values obtainable when
  // calling evaluate();
  virtual void Range(double* min_value, double* max_value) const = 0;

  // Create CC instance.
  virtual std::unique_ptr<gfx::TimingFunction> CloneToCC() const = 0;

 protected:
  TimingFunction(Type type) : type_(type) {}

 private:
  Type type_;
};

class LinearTimingFunction final : public TimingFunction {
 public:
  static std::shared_ptr<LinearTimingFunction> Shared() {
    static auto linear = std::make_shared<LinearTimingFunction>();
    return linear;
  }

  static std::shared_ptr<LinearTimingFunction> Create(
      std::vector<gfx::LinearEasingPoint> points) {
    return std::make_shared<LinearTimingFunction>(std::move(points));
  }
  /*
  // TODO:: 参数改成std::vector<gfx::LinearEasingPoint>之后，与上面的函数同名同参，所以去掉
  static scoped_refptr<LinearTimingFunction> Create(
      Vector<gfx::LinearEasingPoint> points) {
    std::vector<gfx::LinearEasingPoint> temp_points(points.begin(),
                                                    points.end());
    return base::AdoptRef(new LinearTimingFunction(std::move(temp_points)));
  }
  */

  ~LinearTimingFunction() override = default;

  // TimingFunction implementation.
  std::string ToString() const override;
  double Evaluate(
      double fraction,
      LimitDirection limit_direction = LimitDirection::RIGHT) const override;
  void Range(double* min_value, double* max_value) const override;
  std::unique_ptr<gfx::TimingFunction> CloneToCC() const override;

  const std::vector<gfx::LinearEasingPoint>& Points() const {
    return linear_->Points();
  }
  bool IsTrivial() const { return linear_->IsTrivial(); }

  bool operator==(const LinearTimingFunction& other) const {
    return webf::ranges::equal(Points(), other.Points());
  }

public:
  LinearTimingFunction()
      : TimingFunction(Type::LINEAR),
        linear_(gfx::LinearTimingFunction::Create()) {}
  explicit LinearTimingFunction(std::vector<gfx::LinearEasingPoint> points)
      : TimingFunction(Type::LINEAR),
        linear_(gfx::LinearTimingFunction::Create(std::move(points))) {}

private:
  std::unique_ptr<gfx::LinearTimingFunction> linear_;
};

class  CubicBezierTimingFunction final : public TimingFunction {
 public:
  using EaseType = gfx::CubicBezierTimingFunction::EaseType;

  static std::shared_ptr<CubicBezierTimingFunction> Create(double x1,
                                                         double y1,
                                                         double x2,
                                                         double y2) {
    return std::make_shared<CubicBezierTimingFunction>(x1, y1, x2, y2);
  }

  static std::shared_ptr<CubicBezierTimingFunction> Preset(EaseType);

  ~CubicBezierTimingFunction() override = default;

  // TimingFunction implementation.
  std::string ToString() const override;
  double Evaluate(
      double fraction,
      LimitDirection limit_direction = LimitDirection::RIGHT) const override;
  void Range(double* min_value, double* max_value) const override;
  std::unique_ptr<gfx::TimingFunction> CloneToCC() const override;

  double X1() const {
    assert(GetEaseType() == EaseType::CUSTOM);
    return x1_;
  }
  double Y1() const {
    assert(GetEaseType() == EaseType::CUSTOM);
    return y1_;
  }
  double X2() const {
    assert(GetEaseType() == EaseType::CUSTOM);
    return x2_;
  }
  double Y2() const {
    assert(GetEaseType() == EaseType::CUSTOM);
    return y2_;
  }
  EaseType GetEaseType() const { return bezier_->ease_type(); }

 public:
  explicit CubicBezierTimingFunction(EaseType ease_type)
      : TimingFunction(Type::CUBIC_BEZIER),
        bezier_(gfx::CubicBezierTimingFunction::CreatePreset(ease_type)),
        x1_(),
        y1_(),
        x2_(),
        y2_() {}

  CubicBezierTimingFunction(double x1, double y1, double x2, double y2)
      : TimingFunction(Type::CUBIC_BEZIER),
        bezier_(gfx::CubicBezierTimingFunction::Create(x1, y1, x2, y2)),
        x1_(x1),
        y1_(y1),
        x2_(x2),
        y2_(y2) {}
private:
  std::unique_ptr<gfx::CubicBezierTimingFunction> bezier_;

  // TODO(loyso): Get these values from m_bezier->bezier_ (gfx::CubicBezier)
  const double x1_;
  const double y1_;
  const double x2_;
  const double y2_;
};

class  StepsTimingFunction final : public TimingFunction {
 public:
  using StepPosition = gfx::StepsTimingFunction::StepPosition;

  static std::shared_ptr<StepsTimingFunction> Create(int steps,
                                                   StepPosition step_position) {
    return std::make_shared<StepsTimingFunction>(steps, step_position);
  }

  static std::shared_ptr<StepsTimingFunction> Preset(StepPosition position) {
    //DEFINE_STATIC_REF(StepsTimingFunction, start,Create(1, StepPosition::START));
    //DEFINE_STATIC_REF(StepsTimingFunction, end, Create(1, StepPosition::END));
    thtead_local static std::shared_ptr<StepsTimingFunction> start = Create(1, StepPosition::START);
    thtead_local static std::shared_ptr<StepsTimingFunction> end = Create(1, StepPosition::END);
    switch (position) {
      case StepPosition::START:
        return start;
      case StepPosition::END:
        return end;
      default:
        assert_m(false, "StepsTimingFunction::Preset NOTREACHED_IN_MIGRATION");
        return end;
    }
  }

  ~StepsTimingFunction() override = default;

  // TimingFunction implementation.
  std::string ToString() const override;
  double Evaluate(double fraction,
                  LimitDirection limit_direction) const override;

  void Range(double* min_value, double* max_value) const override;
  std::unique_ptr<gfx::TimingFunction> CloneToCC() const override;

  int NumberOfSteps() const { return steps_->steps(); }
  StepPosition GetStepPosition() const { return steps_->step_position(); }

 public:
  StepsTimingFunction(int steps, StepPosition step_position)
      : TimingFunction(Type::STEPS),
        steps_(gfx::StepsTimingFunction::Create(steps, step_position)) {}
private:
  std::unique_ptr<gfx::StepsTimingFunction> steps_;
};

std::shared_ptr<TimingFunction>
CreateCompositorTimingFunctionFromCC(const gfx::TimingFunction*);

 bool operator==(const LinearTimingFunction&,
                                const TimingFunction&);
 bool operator==(const CubicBezierTimingFunction&,
                                const TimingFunction&);
 bool operator==(const StepsTimingFunction&,
                                const TimingFunction&);

 bool operator==(const TimingFunction&, const TimingFunction&);
 bool operator!=(const TimingFunction&, const TimingFunction&);

template <>
struct DowncastTraits<LinearTimingFunction> {
  static bool AllowFrom(const TimingFunction& value) {
    return value.GetType() == TimingFunction::Type::LINEAR;
  }
};
template <>
struct DowncastTraits<CubicBezierTimingFunction> {
  static bool AllowFrom(const TimingFunction& value) {
    return value.GetType() == TimingFunction::Type::CUBIC_BEZIER;
  }
};
template <>
struct DowncastTraits<StepsTimingFunction> {
  static bool AllowFrom(const TimingFunction& value) {
    return value.GetType() == TimingFunction::Type::STEPS;
  }
};

}  // namespace webf

#endif  // WEBF_PLATFORM_ANIMATION_TIMING_FUNCTION_H_
