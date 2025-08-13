// Copyright 2020 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef WEBF_CORE_CSS_CSS_CONTAINER_RULE_H_
#define WEBF_CORE_CSS_CSS_CONTAINER_RULE_H_

#include "core/css/css_condition_rule.h"
#include "foundation/casting.h"

namespace webf {

class StyleRuleContainer;
class ContainerQuery;
class ContainerSelector;

class CSSContainerRule final : public CSSConditionRule {
 public:
  CSSContainerRule(std::shared_ptr<StyleRuleContainer>, CSSStyleSheet*);
  ~CSSContainerRule() override;

  AtomicString cssText() const override;
  String containerName() const;
  String containerQuery() const;

  String Name() const;
  const ContainerSelector& Selector() const;
  void SetConditionText(const ExecutingContext*, const String&);

 private:
  CSSRule::Type GetType() const override { return kContainerRule; }
  const class ContainerQuery& ContainerQuery() const;
};

template <>
struct DowncastTraits<CSSContainerRule> {
  static bool AllowFrom(const CSSRule& rule) {
    return rule.GetType() == CSSRule::kContainerRule;
  }
};

}  // namespace webf

#endif  // WEBF_CORE_CSS_CSS_CONTAINER_RULE_H_