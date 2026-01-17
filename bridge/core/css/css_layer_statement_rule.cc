// Copyright 2021 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "core/css/css_layer_statement_rule.h"

#include "../../foundation/string/string_builder.h"
#include "core/css/style_rule.h"
#include "foundation/casting.h"

namespace webf {

CSSLayerStatementRule::CSSLayerStatementRule(std::shared_ptr<StyleRuleLayerStatement> layer_statement_rule,
                                             CSSStyleSheet* parent)
    : CSSRule(parent), rule_(layer_statement_rule) {}

CSSLayerStatementRule::~CSSLayerStatementRule() = default;

std::vector<AtomicString> CSSLayerStatementRule::nameList() const {
  std::vector<AtomicString> result;
  const auto& names = To<StyleRuleLayerStatement>(rule_.get())->GetNames();
  result.reserve(names.size());
  for (const auto& name : names) {
    result.emplace_back(AtomicString(StyleRuleBase::LayerNameAsString(name)));
  }
  return result;
}

AtomicString CSSLayerStatementRule::cssText() const {
  StringBuilder result;
  result.Append("@layer "_s);
  
  const auto names = nameList();
  for (size_t i = 0; i < names.size(); ++i) {
    if (i > 0)
      result.Append(", "_s);
    result.Append(names[i].GetString());
  }
  result.Append(";"_s);
  return AtomicString(result.ReleaseString());
}

void CSSLayerStatementRule::Reattach(std::shared_ptr<StyleRuleBase> rule) {
  rule_ = std::static_pointer_cast<StyleRuleLayerStatement>(rule);
}

}  // namespace webf
