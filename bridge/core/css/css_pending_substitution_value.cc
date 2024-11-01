// Copyright 2016 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// Copyright (C) 2022-present The WebF authors. All rights reserved.

#include "css_pending_substitution_value.h"

namespace webf {

namespace cssvalue {

void CSSPendingSubstitutionValue::TraceAfterDispatch(
    GCVisitor* visitor) const {
  CSSValue::TraceAfterDispatch(visitor);
}

std::string CSSPendingSubstitutionValue::CustomCSSText() const {
  return "";
}

}  // namespace cssvalue
}  // namespace webf