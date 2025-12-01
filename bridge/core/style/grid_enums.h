/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */
// Copyright 2022 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// Copyright (C) 2022-present The WebF authors. All rights reserved.

#ifndef WEBF_CORE_STYLE_GRID_ENUMS_H_
#define WEBF_CORE_STYLE_GRID_ENUMS_H_

#include <cstdint>

namespace webf {

enum GridPositionSide { kColumnStartSide, kColumnEndSide, kRowStartSide, kRowEndSide };

enum GridTrackSizingDirection { kForColumns, kForRows };

enum class AutoRepeatType : uint8_t { kNoAutoRepeat, kAutoFill, kAutoFit };
enum class GridAxisType : uint8_t { kStandaloneAxis, kSubgriddedAxis };

}  // namespace webf

#endif  // WEBF_CORE_STYLE_GRID_ENUMS_H_
