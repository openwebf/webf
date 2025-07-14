// Copyright 2020 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#ifndef WEBF_CORE_BASE_NOTREACHED_H_
#define WEBF_CORE_BASE_NOTREACHED_H_

#include <cassert>

// NOTREACHED() annotates code that should not be reached. 
// This is a simplified version for WebF compatibility with Blink code.
#define NOTREACHED() assert(false)

// TODO: Add more sophisticated implementation with logging if needed

#endif  // WEBF_CORE_BASE_NOTREACHED_H_