// Copyright 2011 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// Copyright (C) 2022-present The WebF authors. All rights reserved.

#ifndef BASE_HASH_HASH_H_
#define BASE_HASH_HASH_H_

#include <stddef.h>
#include <stdint.h>

#include <limits>
#include <string>
#include <string_view>
#include <utility>

//#include "base/containers/span.h"

namespace webf {

uint32_t SuperFastHash(const char* data, int len);



}  // namespace base

#endif  // BASE_HASH_HASH_H_
