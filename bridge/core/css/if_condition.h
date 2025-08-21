// Copyright 2025 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#ifndef BRIDGE_CORE_CSS_IF_CONDITION_H_
#define BRIDGE_CORE_CSS_IF_CONDITION_H_

#include "core/css/media_list.h"
#include "core/css/media_query.h"
#include "core/css/media_query_exp.h"
#include <memory>
#include "../../foundation/string/wtf_string.h"

namespace webf {

// https://drafts.csswg.org/css-values-5/#typedef-if-condition
class IfCondition : public std::enable_shared_from_this<IfCondition> {
 public:
  virtual ~IfCondition() = default;
  virtual void Trace() const {}

  enum class Type {
    kStyle,
    kMedia,
    kSupports,
    kNot,
    kAnd,
    kOr,
    kUnknown,
    kElse
  };
  virtual Type GetType() const = 0;

  // These helper functions return nullptr if any argument is nullptr.
  static std::shared_ptr<const IfCondition> Not(std::shared_ptr<const IfCondition>);
  static std::shared_ptr<const IfCondition> And(std::shared_ptr<const IfCondition>, std::shared_ptr<const IfCondition>);
  static std::shared_ptr<const IfCondition> Or(std::shared_ptr<const IfCondition>, std::shared_ptr<const IfCondition>);
};

class IfConditionNot : public IfCondition {
 public:
  explicit IfConditionNot(std::shared_ptr<const IfCondition> operand) : operand_(operand) {}
  void Trace() const override;
  Type GetType() const override { return Type::kNot; }
  const IfCondition& Operand() const { return *operand_; }

 private:
  std::shared_ptr<const IfCondition> operand_;
};

class IfConditionAnd : public IfCondition {
 public:
  IfConditionAnd(std::shared_ptr<const IfCondition> left, std::shared_ptr<const IfCondition> right)
      : left_(left), right_(right) {}
  void Trace() const override;
  Type GetType() const override { return Type::kAnd; }
  const IfCondition& Left() const { return *left_; }
  const IfCondition& Right() const { return *right_; }

 private:
  std::shared_ptr<const IfCondition> left_;
  std::shared_ptr<const IfCondition> right_;
};

class IfConditionOr : public IfCondition {
 public:
  IfConditionOr(std::shared_ptr<const IfCondition> left, std::shared_ptr<const IfCondition> right)
      : left_(left), right_(right) {}
  void Trace() const override;
  Type GetType() const override { return Type::kOr; }
  const IfCondition& Left() const { return *left_; }
  const IfCondition& Right() const { return *right_; }

 private:
  std::shared_ptr<const IfCondition> left_;
  std::shared_ptr<const IfCondition> right_;
};

class IfTestStyle : public IfCondition {
 public:
  explicit IfTestStyle(std::shared_ptr<const MediaQueryExpNode> style_test)
      : style_test_(style_test) {}
  void Trace() const override;
  Type GetType() const override { return Type::kStyle; }
  std::shared_ptr<const MediaQueryExpNode> GetMediaQueryExpNode() const { return style_test_; }

 private:
  std::shared_ptr<const MediaQueryExpNode> style_test_;
};

class IfTestMedia : public IfCondition {
 public:
  explicit IfTestMedia(std::shared_ptr<const MediaQueryExpNode> exp_node);
  explicit IfTestMedia(std::shared_ptr<const MediaQuerySet> media_query_set)
      : media_test_(media_query_set) {}
  void Trace() const override;
  Type GetType() const override { return Type::kMedia; }
  std::shared_ptr<const MediaQuerySet> GetMediaQuerySet() const { return media_test_; }

 private:
  std::shared_ptr<const MediaQuerySet> media_test_;
};

class IfTestSupports : public IfCondition {
 public:
  explicit IfTestSupports(bool result) : result_(result) {}
  void Trace() const override;
  Type GetType() const override { return Type::kSupports; }
  bool GetResult() const { return result_; }

 private:
  bool result_;
};

class IfConditionUnknown : public IfCondition {
 public:
  explicit IfConditionUnknown(String string) : string_(std::move(string)) {}
  void Trace() const override;
  Type GetType() const override { return Type::kUnknown; }
  String GetString() const { return string_; }

 private:
  String string_;
};

class IfConditionElse : public IfCondition {
 public:
  explicit IfConditionElse() = default;
  void Trace() const override;
  Type GetType() const override { return Type::kElse; }
};

template <>
struct DowncastTraits<IfConditionNot> {
  static bool AllowFrom(const IfCondition& node) {
    return node.GetType() == IfCondition::Type::kNot;
  }
};

template <>
struct DowncastTraits<IfConditionAnd> {
  static bool AllowFrom(const IfCondition& node) {
    return node.GetType() == IfCondition::Type::kAnd;
  }
};

template <>
struct DowncastTraits<IfConditionOr> {
  static bool AllowFrom(const IfCondition& node) {
    return node.GetType() == IfCondition::Type::kOr;
  }
};

template <>
struct DowncastTraits<IfTestStyle> {
  static bool AllowFrom(const IfCondition& node) {
    return node.GetType() == IfCondition::Type::kStyle;
  }
};

template <>
struct DowncastTraits<IfTestMedia> {
  static bool AllowFrom(const IfCondition& node) {
    return node.GetType() == IfCondition::Type::kMedia;
  }
};

template <>
struct DowncastTraits<IfTestSupports> {
  static bool AllowFrom(const IfCondition& node) {
    return node.GetType() == IfCondition::Type::kSupports;
  }
};

template <>
struct DowncastTraits<IfConditionUnknown> {
  static bool AllowFrom(const IfCondition& node) {
    return node.GetType() == IfCondition::Type::kUnknown;
  }
};

template <>
struct DowncastTraits<IfConditionElse> {
  static bool AllowFrom(const IfCondition& node) {
    return node.GetType() == IfCondition::Type::kElse;
  }
};

}  // namespace webf

#endif  // BRIDGE_CORE_CSS_IF_CONDITION_H_
