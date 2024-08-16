// Copyright 2019 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "core/css/css_keyframe_shorthand_value.h"
#include <iostream>
#include "style_property_shorthand.h"

namespace webf {

#if DCHECK_IS_ON()
namespace {
bool ShorthandMatches(CSSPropertyID expected_shorthand,
                      CSSPropertyID longhand) {
  std::vector<StylePropertyShorthand> shorthands;
  getMatchingShorthandsForLonghand(longhand, &shorthands);
  for (unsigned i = 0; i < shorthands.size(); ++i) {
    if (shorthands.at(i).id() == expected_shorthand) {
      return true;
    }
  }

  return false;
}

}  // namespace
#endif

CSSKeyframeShorthandValue::CSSKeyframeShorthandValue(
    CSSPropertyID shorthand,
    std::shared_ptr<ImmutableCSSPropertyValueSet>& properties)
    : CSSValue(kKeyframeShorthandClass),
      shorthand_(shorthand),
      properties_(properties) {}

std::string CSSKeyframeShorthandValue::CustomCSSText() const {
#if DCHECK_IS_ON()
  // Check that all property/value pairs belong to the same shorthand.
  for (unsigned i = 0; i < properties_->PropertyCount(); i++) {
    if(!ShorthandMatches(shorthand_, properties_->PropertyAt(i).Id())) {
     std::cout << "These are not the longhands you're looking for." << std::endl;
    }
  }
#endif

  return properties_->GetPropertyValue(shorthand_);
}

void CSSKeyframeShorthandValue::TraceAfterDispatch(GCVisitor* visitor) const {
//  visitor->TraceMember(properties_);
  CSSValue::TraceAfterDispatch(visitor);
}

}  // namespace webf
