// Copyright 2017 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "text_direction.h"

#include <ostream>

namespace webf {

std::ostream& operator<<(std::ostream& ostream, TextDirection direction) {
  return ostream << (IsLtr(direction) ? "LTR" : "RTL");
}


}  // namespace webf
