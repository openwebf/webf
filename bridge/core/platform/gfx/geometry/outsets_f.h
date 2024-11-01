// Copyright 2022 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#ifndef UI_GFX_GEOMETRY_OUTSETS_F_H_
#define UI_GFX_GEOMETRY_OUTSETS_F_H_

#include "insets_f.h"
#include "insets_outsets_f_base.h"

namespace gfx {

// A floating point version of gfx::Outsets.
class OutsetsF : public InsetsOutsetsFBase<OutsetsF> {
 public:
  using InsetsOutsetsFBase::InsetsOutsetsFBase;

  // Conversion from OutsetsF to InsetsF negates all components.
  InsetsF ToInsets() const {
    return InsetsF()
        .set_left(-left())
        .set_right(-right())
        .set_top(-top())
        .set_bottom(-bottom());
  }
};

inline OutsetsF operator+(OutsetsF lhs, const OutsetsF& rhs) {
  lhs += rhs;
  return lhs;
}

inline OutsetsF operator-(OutsetsF lhs, const OutsetsF& rhs) {
  lhs -= rhs;
  return lhs;
}

}  // namespace gfx

#endif  // UI_GFX_GEOMETRY_OUTSETS_F_H_