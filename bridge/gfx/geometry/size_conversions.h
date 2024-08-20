// Copyright 2012 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#ifndef UI_GFX_GEOMETRY_SIZE_CONVERSIONS_H_
#define UI_GFX_GEOMETRY_SIZE_CONVERSIONS_H_

#include "gfx/geometry/size.h"
#include "gfx/geometry/size_f.h"

namespace gfx {

// Returns a Size with each component from the input SizeF floored.
Size ToFlooredSize(const SizeF& size);

// Returns a Size with each component from the input SizeF ceiled.
Size ToCeiledSize(const SizeF& size);

// Returns a Size with each component from the input SizeF rounded.
Size ToRoundedSize(const SizeF& size);

}  // namespace gfx

#endif  // UI_GFX_GEOMETRY_SIZE_CONVERSIONS_H_