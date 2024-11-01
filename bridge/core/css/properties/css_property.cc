// Copyright 2019 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "css_property.h"

namespace webf {

const CSSProperty& GetCSSPropertyVariable() {
  return To<CSSProperty>(*GetPropertyInternal(CSSPropertyID::kVariable));
}

bool CSSProperty::HasEqualCSSPropertyName(const CSSProperty& other) const {
  return property_id_ == other.property_id_;
}

// The correctness of static functions that operate on CSSPropertyName is
// ensured by:
//
// - assert in the CustomProperty constructor.
// - CSSPropertyTest.StaticVariableInstanceFlags

bool CSSProperty::IsShorthand(const CSSPropertyName& name) {
  return !name.IsCustomProperty() && Get(name.Id()).IsShorthand();
}

bool CSSProperty::IsRepeated(const CSSPropertyName& name) {
  return !name.IsCustomProperty() && Get(name.Id()).IsRepeated();
}

std::shared_ptr<const CSSValue> CSSProperty::CSSValueFromComputedStyle(
    const ComputedStyle& style,
    const LayoutObject* layout_object,
    bool allow_visited_style,
    CSSValuePhase value_phase) const {
  return nullptr;
//  const CSSProperty& resolved_property =
//      ResolveDirectionAwareProperty(style.GetWritingDirection());
//  return resolved_property.CSSValueFromComputedStyleInternal(
//      style, layout_object, allow_visited_style, value_phase);
}



}  // namespace webf
