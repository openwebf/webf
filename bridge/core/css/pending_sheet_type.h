// Copyright 2022 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef WEBF_PENDING_SHEET_TYPE_H
#define WEBF_PENDING_SHEET_TYPE_H

#include <utility>
#include "core/base/render_blocking_behavior.h"

namespace webf {

class Element;

enum class PendingSheetType {
  // Not a pending sheet, hasn't started or already finished
  kNone,
  // Pending but does not block anything
  kNonBlocking,
  // Dynamically inserted render-blocking but not script-blocking sheet
  kDynamicRenderBlocking,
  // Parser-inserted sheet that by default blocks scripts. Also blocks rendering
  // if in head, or blocks parser if in body.
  kBlocking
};

std::pair<PendingSheetType, RenderBlockingBehavior> ComputePendingSheetTypeAndRenderBlockingBehavior(
    Element& sheet_owner,
    bool is_critical_sheet,
    bool is_created_by_parser);

}  // namespace webf

#endif  // WEBF_PENDING_SHEET_TYPE_H
