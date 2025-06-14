// Copyright 2021 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// Copyright (C) 2022-present The WebF authors. All rights reserved.

#ifndef WEBF_RENDER_BLOCKING_BEHAVIOR_H
#define WEBF_RENDER_BLOCKING_BEHAVIOR_H

#include <cstdint>

namespace webf {

enum class RenderBlockingBehavior : uint8_t {
  kUnset,                 // Render blocking value was not set.
  kBlocking,              // Render Blocking resource.
  kNonBlocking,           // Non-blocking resource.
  kNonBlockingDynamic,    // Dynamically injected non-blocking resource.
  kPotentiallyBlocking,   // Dynamically injected non-blocking resource.
  kInBodyParserBlocking,  // Blocks parser below element declaration.
};
}  // namespace webf

#endif  // WEBF_RENDER_BLOCKING_BEHAVIOR_H
