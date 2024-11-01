// Copyright 2015 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// Copyright (C) 2022-present The WebF authors. All rights reserved.

#include "css_unparsed_declaration_value.h"

namespace webf {

void CSSUnparsedDeclarationValue::TraceAfterDispatch(
    GCVisitor* visitor) const {
  CSSValue::TraceAfterDispatch(visitor);
}

std::string CSSUnparsedDeclarationValue::CustomCSSText() const {
  // We may want to consider caching this value.
  return data_->Serialize();
}

}  // namespace webf