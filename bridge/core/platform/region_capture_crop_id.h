// Copyright 2021 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// Copyright (C) 2022-present The WebF authors. All rights reserved.

#ifndef THIRD_PARTY_BLINK_RENDERER_PLATFORM_REGION_CAPTURE_CROP_ID_H_
#define THIRD_PARTY_BLINK_RENDERER_PLATFORM_REGION_CAPTURE_CROP_ID_H_

#include "core/base/token.h"
#include "core/base/types/strong_alias.h"
#include "core/base/uuid.h"

namespace webf {

using RegionCaptureCropId = base::StrongAlias<class RegionCaptureCropIdTag, webf::Token>;

// Convert between base::Uuid and base::Token. Both encode identity using
// 128 bits of information, but GUID does so in a string-based way that is
// inefficient to move around.
Token GUIDToToken(const webf::Uuid& guid);
Uuid TokenToGUID(const webf::Token& token);

}  // namespace webf

#endif  // THIRD_PARTY_BLINK_RENDERER_PLATFORM_REGION_CAPTURE_CROP_ID_H_
