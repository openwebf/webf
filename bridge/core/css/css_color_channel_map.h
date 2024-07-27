// Copyright 2024 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#ifndef WEBF_CORE_CSS_CSS_COLOR_CHANNEL_MAP_H_
#define WEBF_CORE_CSS_CSS_COLOR_CHANNEL_MAP_H_

#include <unordered_map>
#include "css_value_keywords.h"

namespace webf {

// Used in channel keyword substitutions for relative color syntax.
// https://www.w3.org/TR/css-color-5/#relative-colors
using CSSColorChannelMap = std::unordered_map<CSSValueID, double>;



}

#endif  // WEBF_CORE_CSS_CSS_COLOR_CHANNEL_MAP_H_
