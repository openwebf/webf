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
#include "core/css/css_markup.h"
#include "core/css/style_rule.h"
#include "foundation/casting.h"

namespace webf {

CSSContainerRule::CSSContainerRule(std::shared_ptr<StyleRuleContainer> container_rule,
                                   CSSStyleSheet* parent)
    : CSSConditionRule(std::static_pointer_cast<StyleRuleCondition>(container_rule), parent) {}

CSSContainerRule::~CSSContainerRule() = default;

AtomicString CSSContainerRule::cssText() const {
  StringBuilder result;
  result.Append("@container"_s);
  
  String name = containerName();
  if (!name.IsEmpty()) {
    result.Append(" "_s);
    result.Append(name);
  }
  
  String query = containerQuery();
  if (!query.IsEmpty()) {
    if (!name.IsEmpty()) {
      result.Append(" "_s);
    } else {
      result.Append(" "_s);
    }
    result.Append(query);
  }
  
  AppendCSSTextForItems(result);
  return AtomicString(result.ReleaseString());
}

String CSSContainerRule::containerName() const {
  StringBuilder result;
  auto* container_rule = To<StyleRuleContainer>(group_rule_.get());
  const class ContainerQuery& query = container_rule->GetContainerQuery();
  const AtomicString& name = query.Selector().Name();
  if (!name.empty()) {
    SerializeIdentifier(String(name), result);
  }
  return result.ReleaseString();
}

String CSSContainerRule::containerQuery() const {
  auto* container_rule = To<StyleRuleContainer>(group_rule_.get());
  const class ContainerQuery& query = container_rule->GetContainerQuery();
  return query.ToString();
}

String CSSContainerRule::Name() const {
  auto* container_rule = To<StyleRuleContainer>(group_rule_.get());
  const AtomicString& name = container_rule->GetContainerQuery().Selector().Name();
  return String(name);
}

const ContainerSelector& CSSContainerRule::Selector() const {
  auto* container_rule = To<StyleRuleContainer>(group_rule_.get());
  return container_rule->GetContainerQuery().Selector();
}

void CSSContainerRule::SetConditionText(const ExecutingContext*, const String&) {
  // TODO: Implement dynamic condition text setting
  // This would involve re-parsing the container query
}

const class ContainerQuery& CSSContainerRule::ContainerQuery() const {
  auto* container_rule = To<StyleRuleContainer>(group_rule_.get());
  return container_rule->GetContainerQuery();
}

}  // namespace webf