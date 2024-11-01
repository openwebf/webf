/*
 * CSS Media Query
 *
 * Copyright (C) 2006 Kimmo Kinnunen <kimmo.t.kinnunen@nokia.com>.
 * Copyright (C) 2010 Nokia Corporation and/or its subsidiary(-ies).
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
 * THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY
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

#ifndef WEBF_CORE_CSS_MEDIA_QUERY_EXP_H_
#define WEBF_CORE_CSS_MEDIA_QUERY_EXP_H_

#include <optional>

#include "foundation/macros.h"
#include "foundation/string_builder.h"
#include "core/base/memory/values_equivalent.h"
#include "core/css/css_primitive_value.h"
#include "core/css/css_numeric_literal_value.h"
#include "core/css/css_value.h"
#include "core/css/css_ratio_value.h"
#include "core/layout/geometry/axis.h"
#include "foundation/casting.h"

namespace webf {

class CSSParserContext;
class CSSParserTokenRange;
class CSSParserTokenOffsets;

class MediaQueryExpValue {
  WEBF_DISALLOW_NEW();
 public:
  // Type::kInvalid
  MediaQueryExpValue() = default;

  explicit MediaQueryExpValue(CSSValueID id) : type_(Type::kId), id_(id) {}
  explicit MediaQueryExpValue(std::shared_ptr<const CSSValue> value)
      : type_(Type::kValue), value_(std::move(value)) {}
  MediaQueryExpValue(const CSSPrimitiveValue& numerator,
                     const CSSPrimitiveValue& denominator)
      : type_(Type::kRatio),
        ratio_(std::make_shared<cssvalue::CSSRatioValue>(numerator,
                                                             denominator)) {}
  void Trace(GCVisitor* visitor) const {}

  bool IsValid() const { return type_ != Type::kInvalid; }
  bool IsId() const { return type_ == Type::kId; }
  bool IsRatio() const { return type_ == Type::kRatio; }
  bool IsValue() const { return type_ == Type::kValue; }

  bool IsPrimitiveValue() const {
    return IsValue() && value_->IsPrimitiveValue();
  }
  bool IsNumber() const {
    return IsPrimitiveValue() && To<CSSPrimitiveValue>(*value_).IsNumber();
  }
  bool IsResolution() const {
    return IsPrimitiveValue() && To<CSSPrimitiveValue>(*value_).IsResolution();
  }
  bool IsNumericLiteralValue() const {
    return IsValue() && value_->IsNumericLiteralValue();
  }
  bool IsDotsPerCentimeter() const {
    return IsNumericLiteralValue() &&
           To<CSSNumericLiteralValue>(*value_).GetType() ==
               CSSPrimitiveValue::UnitType::kDotsPerCentimeter;
  }

  CSSValueID Id() const {
    DCHECK(IsId());
    return id_;
  }

  double GetDoubleValue() const {
    DCHECK(IsNumericLiteralValue());
    return To<CSSNumericLiteralValue>(*value_).GetDoubleValue();
  }

  CSSPrimitiveValue::UnitType GetUnitType() const {
    DCHECK(IsNumericLiteralValue());
    return To<CSSNumericLiteralValue>(*value_).GetType();
  }

  const CSSValue& GetCSSValue() const {
    DCHECK(IsValue());
    return *value_;
  }

  const CSSValue& Numerator() const {
    DCHECK(IsRatio());
    return ratio_->First();
  }

  const CSSValue& Denominator() const {
    DCHECK(IsRatio());
    return ratio_->Second();
  }

  double Value(const CSSLengthResolver& length_resolver) const {
    DCHECK(IsValue());
    return To<CSSPrimitiveValue>(*value_).ComputeValueInCanonicalUnit(
        length_resolver);
  }

  double Numerator(const CSSLengthResolver& length_resolver) const {
    DCHECK(IsRatio());
    return ratio_->First().ComputeValueInCanonicalUnit(length_resolver);
  }

  double Denominator(const CSSLengthResolver& length_resolver) const {
    DCHECK(IsRatio());
    return ratio_->Second().ComputeValueInCanonicalUnit(length_resolver);
  }

  enum UnitFlags {
    kNone = 0,
    kFontRelative = 1 << 0,
    kRootFontRelative = 1 << 1,
    kDynamicViewport = 1 << 2,
    kStaticViewport = 1 << 3,
    kContainer = 1 << 4,
  };

  static const int kUnitFlagsBits = 5;

  unsigned GetUnitFlags() const;

  std::string CssText() const;
  bool operator==(const MediaQueryExpValue& other) const {
    if (type_ != other.type_) {
      return false;
    }
    switch (type_) {
      case Type::kInvalid:
        return true;
      case Type::kId:
        return id_ == other.id_;
      case Type::kValue:
        return webf::ValuesEquivalent(value_, other.value_);
      case Type::kRatio:
        return webf::ValuesEquivalent(ratio_, other.ratio_);
    }
  }
  bool operator!=(const MediaQueryExpValue& other) const {
    return !(*this == other);
  }

  // Consume a MediaQueryExpValue for the provided feature, which must already
  // be lower-cased.
  //
  // std::nullopt is returned on errors.
  static std::optional<MediaQueryExpValue> Consume(
      const std::string& lower_media_feature,
      CSSParserTokenRange&,
      const CSSParserTokenOffsets&,
      std::shared_ptr<const CSSParserContext>);

 private:
  enum class Type { kInvalid, kId, kValue, kRatio };

  Type type_ = Type::kInvalid;

  CSSValueID id_;
  std::shared_ptr<const CSSValue> value_;
  std::shared_ptr<const cssvalue::CSSRatioValue> ratio_;
};


// https://drafts.csswg.org/mediaqueries-4/#mq-syntax
enum class MediaQueryOperator {
  // Used for <mf-plain>, <mf-boolean>
  kNone,

  // Used for <mf-range>
  kEq,
  kLt,
  kLe,
  kGt,
  kGe,
};

// This represents the following part of a <media-feature> (example):
//
//  (width >= 10px)
//         ^^^^^^^
//
struct MediaQueryExpComparison {
  WEBF_DISALLOW_NEW();
  MediaQueryExpComparison() = default;
  explicit MediaQueryExpComparison(const MediaQueryExpValue& value)
      : value(value) {}
  MediaQueryExpComparison(const MediaQueryExpValue& value,
                          MediaQueryOperator op)
      : value(value), op(op) {}
  void Trace(GCVisitor* visitor) const { }

  bool operator==(const MediaQueryExpComparison& o) const {
    return value == o.value && op == o.op;
  }
  bool operator!=(const MediaQueryExpComparison& o) const {
    return !(*this == o);
  }

  bool IsValid() const { return value.IsValid(); }

  MediaQueryExpValue value;
  MediaQueryOperator op = MediaQueryOperator::kNone;
};

// There exists three types of <media-feature>s.
//
//  1) Boolean features, which is just the feature name, e.g. (color)
//  2) Plain features, which can appear in two different forms:
//       - Feature with specific value, e.g. (width: 100px)
//       - Feature with min/max prefix, e.g. (min-width: 100px)
//  3) Range features, which can appear in three different forms:
//       - Feature compared with value, e.g. (width >= 100px)
//       - Feature compared with value (reversed), e.g. (100px <= width)
//       - Feature within a certain range, e.g. (100px < width < 200px)
//
// In the first case, both |left| and |right| values are not set.
// In the second case, only |right| is set.
// In the third case, either |left| is set, |right| is set, or both, depending
// on the form.
//
// https://drafts.csswg.org/mediaqueries-4/#typedef-media-feature
struct MediaQueryExpBounds {
  WEBF_DISALLOW_NEW();
  MediaQueryExpBounds() = default;
  explicit MediaQueryExpBounds(const MediaQueryExpComparison& right)
      : right(right) {}
  MediaQueryExpBounds(const MediaQueryExpComparison& left,
                      const MediaQueryExpComparison& right)
      : left(left), right(right) {}
  void Trace(GCVisitor* visitor) const {
//    visitor->Trace(left);
//    visitor->Trace(right);
  }

  bool IsRange() const {
    return left.op != MediaQueryOperator::kNone ||
           right.op != MediaQueryOperator::kNone;
  }

  bool operator==(const MediaQueryExpBounds& o) const {
    return left == o.left && right == o.right;
  }
  bool operator!=(const MediaQueryExpBounds& o) const { return !(*this == o); }

  MediaQueryExpComparison left;
  MediaQueryExpComparison right;
};

class MediaQueryExp {
  WEBF_DISALLOW_NEW();

 public:
  // Returns an invalid MediaQueryExp if the arguments are invalid.
  static MediaQueryExp Create(const std::string& media_feature,
                              CSSParserTokenRange&,
                              const CSSParserTokenOffsets&,
                              std::shared_ptr<const CSSParserContext>);
  static MediaQueryExp Create(const std::string& media_feature,
                              const MediaQueryExpBounds&);
  static MediaQueryExp Invalid() {
    return MediaQueryExp("", MediaQueryExpValue());
  }

  MediaQueryExp(const MediaQueryExp& other);
  ~MediaQueryExp();
  void Trace(GCVisitor*) const;

  const std::string& MediaFeature() const { return media_feature_; }

  const MediaQueryExpBounds& Bounds() const { return bounds_; }

  bool IsValid() const { return !media_feature_.empty(); }

  bool operator==(const MediaQueryExp& other) const;
  bool operator!=(const MediaQueryExp& other) const {
    return !(*this == other);
  }

  bool IsViewportDependent() const;

  bool IsDeviceDependent() const;

  bool IsWidthDependent() const;
  bool IsHeightDependent() const;
  bool IsInlineSizeDependent() const;
  bool IsBlockSizeDependent() const;

  std::string Serialize() const;

  // Return the union of GetUnitFlags() from the expr values.
  unsigned GetUnitFlags() const;

 private:
  MediaQueryExp(const std::string&, const MediaQueryExpValue&);
  MediaQueryExp(const std::string&, const MediaQueryExpBounds&);

  std::string media_feature_;
  MediaQueryExpBounds bounds_;
};

// MediaQueryExpNode representing a tree of MediaQueryExp objects capable of
// nested/compound expressions.
class MediaQueryExpNode {
 public:
  virtual ~MediaQueryExpNode() = default;
  virtual void Trace(GCVisitor*) const {}

  enum class Type { kFeature, kNested, kFunction, kNot, kAnd, kOr, kUnknown };

  enum FeatureFlag {
    kFeatureUnknown = 1 << 1,
    kFeatureWidth = 1 << 2,
    kFeatureHeight = 1 << 3,
    kFeatureInlineSize = 1 << 4,
    kFeatureBlockSize = 1 << 5,
    kFeatureStyle = 1 << 6,
    kFeatureSticky = 1 << 7,
    kFeatureSnap = 1 << 8,
  };

  using FeatureFlags = unsigned;

  std::string Serialize() const;

  bool HasUnknown() const { return CollectFeatureFlags() & kFeatureUnknown; }

  virtual Type GetType() const = 0;
  virtual void SerializeTo(StringBuilder&) const = 0;
  virtual void CollectExpressions(std::vector<MediaQueryExp>&) const = 0;
  virtual FeatureFlags CollectFeatureFlags() const = 0;

  // These helper functions return nullptr if any argument is nullptr.
  static std::shared_ptr<const MediaQueryExpNode> Not(std::shared_ptr<const MediaQueryExpNode>);
  static std::shared_ptr<const MediaQueryExpNode> Nested(std::shared_ptr<const MediaQueryExpNode>);
  static std::shared_ptr<const MediaQueryExpNode> Function(std::shared_ptr<const MediaQueryExpNode>,
                                           const std::string& name);
  static std::shared_ptr<const MediaQueryExpNode> And(std::shared_ptr<const MediaQueryExpNode>,
                                      std::shared_ptr<const MediaQueryExpNode>);
  static std::shared_ptr<const MediaQueryExpNode> Or(std::shared_ptr<const MediaQueryExpNode>,
                                                     std::shared_ptr<const MediaQueryExpNode>);
};

class MediaQueryFeatureExpNode : public MediaQueryExpNode {
 public:
  explicit MediaQueryFeatureExpNode(const MediaQueryExp& exp) : exp_(exp) {}
  void Trace(GCVisitor*) const override;

  const std::string& Name() const { return exp_.MediaFeature(); }
  const MediaQueryExpBounds& Bounds() const { return exp_.Bounds(); }

  unsigned GetUnitFlags() const;
  bool IsViewportDependent() const;
  bool IsDeviceDependent() const;
  bool IsWidthDependent() const;
  bool IsHeightDependent() const;
  bool IsInlineSizeDependent() const;
  bool IsBlockSizeDependent() const;

  Type GetType() const override { return Type::kFeature; }
  void SerializeTo(StringBuilder&) const override;
  void CollectExpressions(std::vector<MediaQueryExp>&) const override;
  FeatureFlags CollectFeatureFlags() const override;

 private:
  MediaQueryExp exp_;
};

class MediaQueryUnaryExpNode : public MediaQueryExpNode {
 public:
  explicit MediaQueryUnaryExpNode(std::shared_ptr<const MediaQueryExpNode> operand)
      : operand_(operand) {
    DCHECK(operand_);
  }
  void Trace(GCVisitor*) const override;

  void CollectExpressions(std::vector<MediaQueryExp>&) const override;
  FeatureFlags CollectFeatureFlags() const override;
  const MediaQueryExpNode& Operand() const { return *operand_; }

 private:
  std::shared_ptr<const MediaQueryExpNode> operand_;
};

class MediaQueryNestedExpNode : public MediaQueryUnaryExpNode {
 public:
  explicit MediaQueryNestedExpNode(std::shared_ptr<const MediaQueryExpNode> operand)
      : MediaQueryUnaryExpNode(operand) {}

  Type GetType() const override { return Type::kNested; }
  void SerializeTo(StringBuilder&) const override;
};

class MediaQueryFunctionExpNode : public MediaQueryUnaryExpNode {
 public:
  explicit MediaQueryFunctionExpNode(std::shared_ptr<const MediaQueryExpNode> operand,
                                     const std::string& name)
      : MediaQueryUnaryExpNode(operand), name_(name) {}

  Type GetType() const override { return Type::kFunction; }
  void SerializeTo(StringBuilder&) const override;
  FeatureFlags CollectFeatureFlags() const override;

 private:
  std::string name_;
};

class MediaQueryNotExpNode : public MediaQueryUnaryExpNode {
 public:
  explicit MediaQueryNotExpNode(std::shared_ptr<const MediaQueryExpNode> operand)
      : MediaQueryUnaryExpNode(operand) {}

  Type GetType() const override { return Type::kNot; }
  void SerializeTo(StringBuilder&) const override;
};

class MediaQueryCompoundExpNode : public MediaQueryExpNode {
 public:
  MediaQueryCompoundExpNode(std::shared_ptr<const MediaQueryExpNode> left,
                            std::shared_ptr<const MediaQueryExpNode> right)
      : left_(std::move(left)), right_(std::move(right)) {
    DCHECK(left_);
    DCHECK(right_);
  }
  void Trace(GCVisitor*) const override;

  void CollectExpressions(std::vector<MediaQueryExp>&) const override;
  FeatureFlags CollectFeatureFlags() const override;
  const MediaQueryExpNode& Left() const { return *left_; }
  const MediaQueryExpNode& Right() const { return *right_; }

 private:
  std::shared_ptr<const MediaQueryExpNode> left_;
  std::shared_ptr<const MediaQueryExpNode> right_;
};

class MediaQueryAndExpNode : public MediaQueryCompoundExpNode {
 public:
  MediaQueryAndExpNode(std::shared_ptr<const MediaQueryExpNode> left,
                       std::shared_ptr<const MediaQueryExpNode> right)
      : MediaQueryCompoundExpNode(std::move(left), std::move(right)) {}

  Type GetType() const override { return Type::kAnd; }
  void SerializeTo(StringBuilder&) const override;
};

class MediaQueryOrExpNode : public MediaQueryCompoundExpNode {
 public:
  MediaQueryOrExpNode(std::shared_ptr<const MediaQueryExpNode> left,
                      std::shared_ptr<const MediaQueryExpNode> right)
      : MediaQueryCompoundExpNode(left, right) {}

  Type GetType() const override { return Type::kOr; }
  void SerializeTo(StringBuilder&) const override;
};

class MediaQueryUnknownExpNode : public MediaQueryExpNode {
 public:
  explicit MediaQueryUnknownExpNode(std::string string) : string_(string) {}

  Type GetType() const override { return Type::kUnknown; }
  void SerializeTo(StringBuilder&) const override;
  void CollectExpressions(std::vector<MediaQueryExp>&) const override;
  FeatureFlags CollectFeatureFlags() const override;

 private:
  std::string string_;
};

template <>
struct DowncastTraits<MediaQueryFeatureExpNode> {
  static bool AllowFrom(const MediaQueryExpNode& node) {
    return node.GetType() == MediaQueryExpNode::Type::kFeature;
  }
};

template <>
struct DowncastTraits<MediaQueryNestedExpNode> {
  static bool AllowFrom(const MediaQueryExpNode& node) {
    return node.GetType() == MediaQueryExpNode::Type::kNested;
  }
};

template <>
struct DowncastTraits<MediaQueryFunctionExpNode> {
  static bool AllowFrom(const MediaQueryExpNode& node) {
    return node.GetType() == MediaQueryExpNode::Type::kFunction;
  }
};

template <>
struct DowncastTraits<MediaQueryNotExpNode> {
  static bool AllowFrom(const MediaQueryExpNode& node) {
    return node.GetType() == MediaQueryExpNode::Type::kNot;
  }
};

template <>
struct DowncastTraits<MediaQueryAndExpNode> {
  static bool AllowFrom(const MediaQueryExpNode& node) {
    return node.GetType() == MediaQueryExpNode::Type::kAnd;
  }
};

template <>
struct DowncastTraits<MediaQueryOrExpNode> {
  static bool AllowFrom(const MediaQueryExpNode& node) {
    return node.GetType() == MediaQueryExpNode::Type::kOr;
  }
};

template <>
struct DowncastTraits<MediaQueryUnknownExpNode> {
  static bool AllowFrom(const MediaQueryExpNode& node) {
    return node.GetType() == MediaQueryExpNode::Type::kUnknown;
  }
};

}  // namespace webf

#endif  // WEBF_MEDIA_QUERY_EXP_H
