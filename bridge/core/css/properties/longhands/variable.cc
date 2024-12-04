// Copyright 2018 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "variable.h"

namespace webf {

bool Variable::IsStaticInstance(const CSSProperty& property) {
  return &property == &GetCSSPropertyVariable();
}

}  // namespace webf
