// Copyright 2020 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "core/css/css_container_rule.h"

#include "../../foundation/string/string_builder.h"
#include "core/css/container_query.h"
#include "core/css/container_selector.h"
#include "core/css/style_rule.h"
#include "foundation/casting.h"

namespace webf {

CSSContainerRule::CSSContainerRule(std::shared_ptr<StyleRuleContainer> container_rule,
                                   CSSStyleSheet* parent)
    : CSSConditionRule(std::static_pointer_cast<StyleRuleCondition>(container_rule), parent) {}

CSSContainerRule::~CSSContainerRule() = default;

AtomicString CSSContainerRule::cssText() const {
  StringBuilder result;
  result.Append("@container");
  
  std::string name = containerName();
  if (!name.empty()) {
    result.Append(" ");
    result.Append(name);
  }
  
  std::string query = containerQuery();
  if (!query.empty()) {
    if (!name.empty()) {
      result.Append(" ");
    } else {
      result.Append(" ");
    }
    result.Append(query);
  }
  
  AppendCSSTextForItems(result);
  return AtomicString(result.ReleaseString());
}

std::string CSSContainerRule::containerName() const {
  auto* container_rule = To<StyleRuleContainer>(group_rule_.get());
  const class ContainerQuery& query = container_rule->GetContainerQuery();
  return query.Selector().Name();
}

std::string CSSContainerRule::containerQuery() const {
  auto* container_rule = To<StyleRuleContainer>(group_rule_.get());
  const class ContainerQuery& query = container_rule->GetContainerQuery();
  return query.ToString();
}

const std::string& CSSContainerRule::Name() const {
  auto* container_rule = To<StyleRuleContainer>(group_rule_.get());
  return container_rule->GetContainerQuery().Selector().Name();
}

const ContainerSelector& CSSContainerRule::Selector() const {
  auto* container_rule = To<StyleRuleContainer>(group_rule_.get());
  return container_rule->GetContainerQuery().Selector();
}

void CSSContainerRule::SetConditionText(const ExecutingContext*, const std::string&) {
  // TODO: Implement dynamic condition text setting
  // This would involve re-parsing the container query
}

const class ContainerQuery& CSSContainerRule::ContainerQuery() const {
  auto* container_rule = To<StyleRuleContainer>(group_rule_.get());
  return container_rule->GetContainerQuery();
}

}  // namespace webf