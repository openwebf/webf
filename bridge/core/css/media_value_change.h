// Copyright 2024 The WebF authors. All rights reserved.
//
// Minimal mirror of Blink's MediaValueChange enum, used to describe
// which classes of environment changes affect media query evaluation.

#ifndef WEBF_CORE_CSS_MEDIA_VALUE_CHANGE_H_
#define WEBF_CORE_CSS_MEDIA_VALUE_CHANGE_H_

namespace webf {

// Viewport / device environment changes that can affect media queries.
enum class MediaValueChange {
  // Viewport or device size changed (width/height/device-width/device-height).
  kSize = 0,
  // Dynamic viewport (dv* units) evaluation changed.
  kDynamicViewport = 1,
  // Any other value that affects media query evaluation (e.g., color-scheme).
  kOther = 2,
};

}  // namespace webf

#endif  // WEBF_CORE_CSS_MEDIA_VALUE_CHANGE_H_

