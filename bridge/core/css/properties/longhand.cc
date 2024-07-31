// Copyright 2024 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */


#include "longhand.h"

namespace webf {

void Longhand::ApplyParentValue(StyleResolverState& state) const {
  // Creating the (computed) CSSValue involves unzooming using the parent's
  // effective zoom.
//  const CSSValue* parent_computed_value =
//      ComputedStyleUtils::ComputedPropertyValue(*this, *state.ParentStyle());
//  assert(parent_computed_value);
//  // Applying the CSSValue involves zooming using our effective zoom.
//  ApplyValue(state, *parent_computed_value, ValueMode::kNormal);
}

bool Longhand::ApplyParentValueIfZoomChanged(StyleResolverState& state) const {
//  if (state.ParentStyle()->EffectiveZoom() !=
//      state.StyleBuilder().EffectiveZoom()) {
//    ApplyParentValue(state);
//    return true;
//  }
  return false;
}

}  // namespace webf
