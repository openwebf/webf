// Copyright 2014 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "style_rule_keyframe.h"
#include "core/css/parser/css_parser.h"
#include "core/css/parser/css_parser_context.h"

namespace webf {

StyleRuleKeyframe::StyleRuleKeyframe(std::unique_ptr<std::vector<KeyframeOffset>> keys,
                                     std::shared_ptr<const CSSPropertyValueSet> properties)
    : StyleRuleBase(kKeyframe), properties_(properties), keys_(*keys) {}

String StyleRuleKeyframe::KeyText() const {
  DCHECK(!keys_.empty());

  StringBuilder key_text;
  for (unsigned i = 0; i < keys_.size(); ++i) {
    if (i) {
      key_text.Append(", "_s);
    }
    if (keys_.at(i).name != TimelineOffset::NamedRange::kNone) {
      key_text.Append(TimelineOffset::TimelineRangeNameToString(keys_.at(i).name));
      key_text.Append(" "_s);
    }
    key_text.AppendNumber(keys_.at(i).percent * 100);
    key_text.Append('%');
  }

  return key_text.ReleaseString();
}

bool StyleRuleKeyframe::SetKeyText(const ExecutingContext* execution_context, const String& key_text) {
  DCHECK(!key_text.IsEmpty());

  auto context = std::make_shared<CSSParserContext>(execution_context);

  std::unique_ptr<std::vector<KeyframeOffset>> keys = CSSParser::ParseKeyframeKeyList(context, key_text);
  if (!keys || keys->empty()) {
    return false;
  }

  keys_ = *keys;
  return true;
}

const std::vector<KeyframeOffset>& StyleRuleKeyframe::Keys() const {
  return keys_;
}

std::shared_ptr<const MutableCSSPropertyValueSet> StyleRuleKeyframe::MutableProperties() {
  if (!properties_->IsMutable()) {
    properties_ = properties_->MutableCopy();
  }
  return std::reinterpret_pointer_cast<const MutableCSSPropertyValueSet>(properties_);
}

String StyleRuleKeyframe::CssText() const {
  StringBuilder result;
  result.Append(KeyText());
  result.Append(" { "_s);
  String decls = properties_->AsText();
  result.Append(decls);
  if (!decls.IsEmpty()) {
    result.Append(' ');
  }
  result.Append('}');
  return result.ReleaseString();
}

void StyleRuleKeyframe::TraceAfterDispatch(GCVisitor* visitor) const {
  StyleRuleBase::TraceAfterDispatch(visitor);
}

}  // namespace webf
