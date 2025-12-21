// Copyright 2021 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "core/css/css_layer_block_rule.h"

#include "../../foundation/string/string_builder.h"
#include "core/css/style_rule.h"
#include "foundation/casting.h"

namespace webf {

CSSLayerBlockRule::CSSLayerBlockRule(std::shared_ptr<StyleRuleLayerBlock> layer_block_rule,
                                     CSSStyleSheet* parent)
    : CSSGroupingRule(std::static_pointer_cast<StyleRuleGroup>(layer_block_rule), parent) {}

CSSLayerBlockRule::~CSSLayerBlockRule() = default;

String CSSLayerBlockRule::name() const {
  return To<StyleRuleLayerBlock>(group_rule_.get())->GetNameAsString();
}

AtomicString CSSLayerBlockRule::cssText() const {
  StringBuilder result;
  result.Append("@layer"_s);
  const String& layer_name = name();
  if (layer_name.length()) {
    result.Append(" "_s);
    result.Append(layer_name);
  }
  AppendCSSTextForItems(result);
  return AtomicString(result.ReleaseString());
}

void CSSLayerBlockRule::Reattach(std::shared_ptr<StyleRuleBase> rule) {
  CSSGroupingRule::Reattach(rule);
}

}  // namespace webf
