// Copyright 2019 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef WEBF_CSS_EXPOSURE_H
#define WEBF_CSS_EXPOSURE_H

namespace webf {

// Describes whether a property is exposed to author/user style sheets,
// UA style sheets, or not at all.
enum class CSSExposure {
  // The property can't be used anywhere, i.e. it's disabled.
  kNone,
  // The property may be used in UA stylesheets, but not in author and user
  // stylesheets, and the property is otherwise not visible to the author.
  kUA,
  // The property is "web exposed", which means it's available everywhere.
  kWeb
};

inline bool IsUAExposed(CSSExposure exposure) {
  return exposure >= CSSExposure::kUA;
}

inline bool IsWebExposed(CSSExposure exposure) {
  return exposure == CSSExposure::kWeb;
}

}  // namespace webf

#endif  // WEBF_CSS_EXPOSURE_H
