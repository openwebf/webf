// Copyright 2014 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// Copyright (C) 2022-present The WebF authors. All rights reserved.

#ifndef WEBF_CORE_ANIMATION_INTERPOLABLE_VALUE_H_
#define WEBF_CORE_ANIMATION_INTERPOLABLE_VALUE_H_

#include <array>
#include <memory>
#include <utility>

#include "core/css/css_math_expression_node.h"
#include "foundation/casting.h"

namespace webf {

// Represents the components of a PropertySpecificKeyframe's value that change
// smoothly as it interpolates to an adjacent value.
class InterpolableValue {
 public:
  // Interpolates from |this| InterpolableValue towards |to| at the given
  // |progress|, placing the output in |result|. That is:
  //
  //   result = this * (1 - progress) + to * progress
  //
  // Callers must make sure that |this|, |to|, and |result| are all of the same
  // concrete subclass.
  virtual void Interpolate(const InterpolableValue& to, const double progress, InterpolableValue& result) const = 0;

  virtual bool IsDouble() const { return false; }
  virtual bool IsNumber() const { return false; }
  virtual bool IsBool() const { return false; }
  virtual bool IsColor() const { return false; }
  virtual bool IsStyleColor() const { return false; }
  virtual bool IsScrollbarColor() const { return false; }
  virtual bool IsList() const { return false; }
  virtual bool IsLength() const { return false; }
  virtual bool IsAspectRatio() const { return false; }
  virtual bool IsShadow() const { return false; }
  virtual bool IsFilter() const { return false; }
  virtual bool IsTransformList() const { return false; }
  virtual bool IsGridLength() const { return false; }
  virtual bool IsGridTrackList() const { return false; }
  virtual bool IsGridTrackRepeater() const { return false; }
  virtual bool IsGridTrackSize() const { return false; }
  virtual bool IsFontPalette() const { return false; }
  virtual bool IsDynamicRangeLimit() const { return false; }

  // TODO(alancutter): Remove Equals().
  virtual bool Equals(const InterpolableValue&) const = 0;
  virtual void Scale(double scale) = 0;
  virtual void Add(const InterpolableValue& other) = 0;
  // The default implementation should be sufficient for most types, but
  // subclasses can override this to be more efficient if they chose.
  virtual void ScaleAndAdd(double scale, const InterpolableValue& other) {
    Scale(scale);
    Add(other);
  }
  virtual void AssertCanInterpolateWith(const InterpolableValue& other) const = 0;

  // Clone this value, optionally zeroing out the components at the same time.
  // These are not virtual to allow for covariant return types; see
  // documentation on RawClone/RawCloneAndZero.
  std::shared_ptr<InterpolableValue> Clone() const { return RawClone(); }
  std::shared_ptr<InterpolableValue> CloneAndZero() const { return RawCloneAndZero(); }

  // TODO(guopengfei)：
  // virtual void Trace(Visitor*) const {}

 private:
  // Helper methods to allow covariant Clone/CloneAndZero methods. Concrete
  // subclasses should not expose these methods publically, but instead should
  // declare their own version of Clone/CloneAndZero with a concrete return type
  // if it is useful for their clients.
  virtual std::shared_ptr<InterpolableValue> RawClone() const = 0;
  virtual std::shared_ptr<InterpolableValue> RawCloneAndZero() const = 0;
};

class InlinedInterpolableDouble final {
  WEBF_DISALLOW_NEW();

 public:
  InlinedInterpolableDouble() = default;
  explicit InlinedInterpolableDouble(double d) : value_(d) {}

  double Value() const { return value_; }
  void Set(double value) { value_ = value; }

  double Interpolate(double to, const double progress) const;

  void Scale(double scale) { value_ *= scale; }
  void Add(double other) { value_ += other; }
  void ScaleAndAdd(double scale, double other) { value_ = value_ * scale + other; }
  // TODO(guopengfei)：
  // void Trace(Visitor*) const {}

 private:
  double value_ = 0.;
};

class InterpolableNumber final : public InterpolableValue {
 public:
  InterpolableNumber() = default;
  explicit InterpolableNumber(double value,
                              CSSPrimitiveValue::UnitType unit_type = CSSPrimitiveValue::UnitType::kNumber);
  explicit InterpolableNumber(const CSSMathExpressionNode& expression);

  // TODO(crbug.com/1521261): Remove this, once the bug is fixed.
  double Value() const { return value_.Value(); }
  double Value(const CSSLengthResolver& length_resolver) const;

  // InterpolableValue
  void Interpolate(const InterpolableValue& to, const double progress, InterpolableValue& result) const final;
  bool IsNumber() const final { return true; }
  bool Equals(const InterpolableValue& other) const final;
  void Scale(double scale) final;
  void Scale(const InterpolableNumber& other);
  void Add(const InterpolableValue& other) final;
  void AssertCanInterpolateWith(const InterpolableValue& other) const final;

  std::shared_ptr<InterpolableNumber> Clone() const { return RawClone(); }
  std::shared_ptr<InterpolableNumber> CloneAndZero() const { return RawCloneAndZero(); }
  // TODO(guopengfei)：
  // void Trace(Visitor* v) const override {
  //  InterpolableValue::Trace(v);
  //  v->Trace(value_);
  //  v->Trace(expression_);
  //}

 private:
  std::shared_ptr<InterpolableNumber> RawClone() const final {
    if (IsDoubleValue()) {
      return std::make_shared<InterpolableNumber>(value_.Value());
    }
    return std::make_shared<InterpolableNumber>(*expression_);
  }
  std::shared_ptr<InterpolableNumber> RawCloneAndZero() const final { return std::make_shared<InterpolableNumber>(0); }

  bool IsDoubleValue() const { return type_ == Type::kDouble; }
  bool IsExpression() const { return type_ == Type::kExpression; }

  void SetDouble(double value, CSSPrimitiveValue::UnitType unit_type);
  void SetExpression(const CSSMathExpressionNode& expression);
  const CSSMathExpressionNode& AsExpression() const;

  enum class Type { kDouble, kExpression };
  Type type_;
  InlinedInterpolableDouble value_;
  CSSPrimitiveValue::UnitType unit_type_;
  std::shared_ptr<const CSSMathExpressionNode> expression_;
};

// static_assert(std::is_trivially_destructible_v<InterpolableNumber>,
//              "Require trivial destruction for faster sweeping");

class InterpolableList final : public InterpolableValue {
 public:
  explicit InterpolableList(uint32_t size) : values_(size) {
    // static_assert(std::is_trivially_destructible_v<InterpolableList>,
    //              "Require trivial destruction for faster sweeping");
  }

  explicit InterpolableList(std::vector<std::shared_ptr<InterpolableValue>>&& values) : values_(std::move(values)) {}

  InterpolableList(const InterpolableList&) = delete;
  InterpolableList& operator=(const InterpolableList&) = delete;
  InterpolableList(InterpolableList&&) = default;
  InterpolableList& operator=(InterpolableList&&) = default;

  const std::shared_ptr<InterpolableValue> Get(uint32_t position) const { return values_[position]; }
  std::shared_ptr<InterpolableValue>& GetMutable(uint32_t position) { return values_[position]; }
  uint32_t length() const { return values_.size(); }
  void Set(uint32_t position, std::shared_ptr<InterpolableValue> value) {
    if (position >= values_.size()) {
      values_.resize(position + 1);
    }
    values_[position] = std::move(value);
  }

  std::shared_ptr<InterpolableList> Clone() const { return RawClone(); }
  std::shared_ptr<InterpolableList> CloneAndZero() const { return RawCloneAndZero(); }

  // InterpolableValue
  void Interpolate(const InterpolableValue& to, const double progress, InterpolableValue& result) const final;
  bool IsList() const final { return true; }
  bool Equals(const InterpolableValue& other) const final;
  void Scale(double scale) final;
  void Add(const InterpolableValue& other) final;
  // We override this to avoid two passes on the list from the base version.
  void ScaleAndAdd(double scale, const InterpolableValue& other) final;
  void AssertCanInterpolateWith(const InterpolableValue& other) const final;
  // TODO(guopengfei)：
  // void Trace(Visitor* v) const override {
  //  InterpolableValue::Trace(v);
  //  v->Trace(values_);
  //}

 private:
  std::shared_ptr<InterpolableList> RawClone() const final {
    std::shared_ptr<InterpolableList> result = std::make_shared<InterpolableList>(length());
    for (uint32_t i = 0; i < length(); i++) {
      result->Set(i, values_[i]->Clone());
    }
    return result;
  }
  std::shared_ptr<InterpolableList> RawCloneAndZero() const final;

  std::vector<std::shared_ptr<InterpolableValue>> values_;
};

template <>
struct DowncastTraits<InterpolableNumber> {
  static bool AllowFrom(const InterpolableValue& value) { return value.IsNumber(); }
};
template <>
struct DowncastTraits<InterpolableList> {
  static bool AllowFrom(const InterpolableValue& value) { return value.IsList(); }
};

}  // namespace webf

#endif  // WEBF_CORE_ANIMATION_INTERPOLABLE_VALUE_H_
