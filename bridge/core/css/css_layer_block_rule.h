// Copyright 2021 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef WEBF_CORE_CSS_CSS_LAYER_BLOCK_RULE_H_
#define WEBF_CORE_CSS_CSS_LAYER_BLOCK_RULE_H_

#include "core/css/css_grouping_rule.h"
#include "foundation/casting.h"

namespace webf {

class StyleRuleLayerBlock;

class CSSLayerBlockRule final : public CSSGroupingRule {
 public:
  CSSLayerBlockRule(std::shared_ptr<StyleRuleLayerBlock>, CSSStyleSheet*);
  ~CSSLayerBlockRule() override;

  String name() const;

  void Reattach(std::shared_ptr<StyleRuleBase>) override;
  AtomicString cssText() const override;

 private:
  // TODO: Add DevTools support.

  CSSRule::Type GetType() const override { return kLayerBlockRule; }
};

template <>
struct DowncastTraits<CSSLayerBlockRule> {
  static bool AllowFrom(const CSSRule& rule) {
    return rule.GetType() == CSSRule::kLayerBlockRule;
  }
};

}  // namespace webf

#endif  // WEBF_CORE_CSS_CSS_LAYER_BLOCK_RULE_H_
