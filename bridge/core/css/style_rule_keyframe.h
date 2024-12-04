// Copyright 2014 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef WEBF_STYLE_RULE_KEYFRAME_H
#define WEBF_STYLE_RULE_KEYFRAME_H
#include "core/animation/timeline_offset.h"
#include "style_rule.h"

namespace webf {

class MutableCSSPropertyValueSet;
class CSSPropertyValueSet;
class ExecutingContext;

struct KeyframeOffset {
  explicit KeyframeOffset(TimelineOffset::NamedRange name = TimelineOffset::NamedRange::kNone, double percent = 0)
      : name(name), percent(percent) {}

  bool operator==(const KeyframeOffset& b) const { return percent == b.percent && name == b.name; }

  bool operator!=(const KeyframeOffset& b) const { return !(*this == b); }

  TimelineOffset::NamedRange name;
  double percent;
};

class StyleRuleKeyframe final : public StyleRuleBase {
 public:
  StyleRuleKeyframe(std::unique_ptr<std::vector<KeyframeOffset>>, std::shared_ptr<const CSSPropertyValueSet>);

  // Exposed to JavaScript.
  std::string KeyText() const;
  bool SetKeyText(const ExecutingContext*, const std::string&);

  // Used by StyleResolver.
  const std::vector<KeyframeOffset>& Keys() const;

  const CSSPropertyValueSet& Properties() const { return *properties_; }
  std::shared_ptr<const MutableCSSPropertyValueSet> MutableProperties();

  std::string CssText() const;

  void TraceAfterDispatch(GCVisitor*) const;

 private:
  std::shared_ptr<const CSSPropertyValueSet> properties_;
  std::vector<KeyframeOffset> keys_;
};
}  // namespace webf

#endif  // WEBF_STYLE_RULE_KEYFRAME_H
