// Copyright 2025 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#include "core/css/if_condition.h"
#include "media_type_names.h"
#include "foundation/string/wtf_string.h"

namespace webf {

std::shared_ptr<const IfCondition> IfCondition::Not(std::shared_ptr<const IfCondition> operand) {
  if (!operand) {
    return nullptr;
  }
  return std::make_shared<IfConditionNot>(operand);
}

std::shared_ptr<const IfCondition> IfCondition::And(std::shared_ptr<const IfCondition> left,
                                                    std::shared_ptr<const IfCondition> right) {
  if (!left || !right) {
    return nullptr;
  }
  return std::make_shared<IfConditionAnd>(left, right);
}

std::shared_ptr<const IfCondition> IfCondition::Or(std::shared_ptr<const IfCondition> left,
                                                   std::shared_ptr<const IfCondition> right) {
  if (!left || !right) {
    return nullptr;
  }
  return std::make_shared<IfConditionOr>(left, right);
}

void IfConditionNot::Trace() const {
  // In WebF, Trace is often a no-op for shared_ptr based objects
  IfCondition::Trace();
}

void IfConditionAnd::Trace() const {
  IfCondition::Trace();
}

void IfConditionOr::Trace() const {
  IfCondition::Trace();
}

void IfTestStyle::Trace() const {
  IfCondition::Trace();
}

IfTestMedia::IfTestMedia(std::shared_ptr<const MediaQueryExpNode> exp_node) {
  std::vector<std::shared_ptr<const MediaQuery>> queries;
  queries.push_back(std::make_shared<MediaQuery>(
      MediaQuery::RestrictorType::kNone, String(media_type_names_atomicstring::kAll), exp_node));
  media_test_ = std::make_shared<MediaQuerySet>(queries);
}

void IfTestMedia::Trace() const {
  IfCondition::Trace();
}

void IfTestSupports::Trace() const {
  IfCondition::Trace();
}

void IfConditionUnknown::Trace() const {
  IfCondition::Trace();
}

void IfConditionElse::Trace() const {
  IfCondition::Trace();
}

}  // namespace webf