// Copyright 2016 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// Copyright (C) 2022-present The WebF authors. All rights reserved.

#include "core/css/css_global_rule_set.h"

//#include "third_party/blink/renderer/core/css/css_default_style_sheets.h"
//#include "third_party/blink/renderer/core/css/css_selector_watch.h"
//#include "third_party/blink/renderer/core/css/rule_set.h"
#include "core/css/style_engine.h"
#include "core/dom/document.h"
//#include "third_party/blink/renderer/core/speculation_rules/document_speculation_rules.h"

namespace webf {

void CSSGlobalRuleSet::InitWatchedSelectorsRuleSet(Document& document) {
/*
  MarkDirty();
  watched_selectors_rule_set_ = nullptr;
  CSSSelectorWatch* watch = CSSSelectorWatch::FromIfExists(document);
  if (!watch) {
    return;
  }
  const HeapVector<Member<StyleRule>>& watched_selectors =
      watch->WatchedCallbackSelectors();
  if (!watched_selectors.size()) {
    return;
  }
  watched_selectors_rule_set_ = MakeGarbageCollected<RuleSet>();
  MediaQueryEvaluator* medium =
      MakeGarbageCollected<MediaQueryEvaluator>(document.GetFrame());
  for (unsigned i = 0; i < watched_selectors.size(); ++i) {
    watched_selectors_rule_set_->AddStyleRule(
        watched_selectors[i], nullptr, *medium, kRuleHasNoSpecialState, false);
  }
  */
}

void CSSGlobalRuleSet::UpdateDocumentRulesSelectorsRuleSet(Document& document) {
/*
  MarkDirty();
  document_rules_selectors_rule_set_ = nullptr;
  const HeapVector<Member<StyleRule>>& document_rules_selectors =
      DocumentSpeculationRules::From(document).selectors();
  if (document_rules_selectors.empty()) {
    return;
  }
  document_rules_selectors_rule_set_ = MakeGarbageCollected<RuleSet>();
  MediaQueryEvaluator* medium =
      MakeGarbageCollected<MediaQueryEvaluator>(document.GetFrame());
  for (StyleRule* selector : document_rules_selectors) {
    document_rules_selectors_rule_set_->AddStyleRule(
        selector, nullptr, *medium, kRuleHasNoSpecialState, false);
  }
 */
}

void CSSGlobalRuleSet::Update(Document& document) {
/*
  if (!is_dirty_) {
    return;
  }

  is_dirty_ = false;
  features_.Clear();

  CSSDefaultStyleSheets& default_style_sheets =
      CSSDefaultStyleSheets::Instance();

  has_fullscreen_ua_style_ = default_style_sheets.FullscreenStyleSheet();

  default_style_sheets.CollectFeaturesTo(document, features_);

  if (watched_selectors_rule_set_) {
    features_.Merge(watched_selectors_rule_set_->Features());
  }

  if (document_rules_selectors_rule_set_) {
    features_.Merge(document_rules_selectors_rule_set_->Features());
  }

  document.GetStyleEngine().CollectFeaturesTo(features_);

 */
}

void CSSGlobalRuleSet::Dispose() {
/*
  features_.Clear();
  watched_selectors_rule_set_ = nullptr;
  document_rules_selectors_rule_set_ = nullptr;
  has_fullscreen_ua_style_ = false;
  is_dirty_ = true;

 */
}

void CSSGlobalRuleSet::Trace(GCVisitor* visitor) const {
  //visitor->TraceMember(watched_selectors_rule_set_);
  //visitor->TraceMember(document_rules_selectors_rule_set_);
}

}  // namespace webf
