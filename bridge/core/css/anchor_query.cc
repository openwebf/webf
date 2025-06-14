// Copyright 2024 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "core/css/anchor_query.h"

#include "core/base/memory/values_equivalent.h"
#include "core/style/anchor_specifier_value.h"

namespace webf {

bool AnchorQuery::operator==(const AnchorQuery& other) const {
  return query_type_ == other.query_type_ && percentage_ == other.percentage_ &&
         webf::ValuesEquivalent(anchor_specifier_, other.anchor_specifier_) && value_ == other.value_;
}

void AnchorQuery::Trace(GCVisitor* visitor) const {
  // TODO(guopengfei)：
  // visitor->Trace(anchor_specifier_);
}

}  // namespace webf
