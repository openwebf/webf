// Copyright 2016 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "css_color.h"
#include "core/css/css_value_pool.h" //TODO(xiezuobing):

namespace webf::cssvalue {

//CSSColor* CSSColor::Create(const Color& color) {
//  //TODO(xiezuobing): css_value_pool.j
//  return CssValuePool().GetOrCreateColor(color);
//}

AtomicString CSSColor::SerializeAsCSSComponentValue(Color color) {
  return color.SerializeAsCSSColor();
}

}  // namespace webf