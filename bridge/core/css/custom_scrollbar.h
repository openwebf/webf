// Copyright 2025 The WebF Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#ifndef WEBF_CORE_CSS_CUSTOM_SCROLLBAR_H_
#define WEBF_CORE_CSS_CUSTOM_SCROLLBAR_H_

namespace webf {

// Scrollbar parts enumeration
enum ScrollbarPart {
  kNoPart,
  kScrollbarBGPart,
  kTrackBGPart,
  kBackTrackPart,
  kForwardTrackPart,
  kThumbPart,
  kBackButtonStartPart,
  kBackButtonEndPart,
  kForwardButtonStartPart,
  kForwardButtonEndPart
};

enum ScrollbarOrientation {
  kHorizontalScrollbar,
  kVerticalScrollbar
};

// Stub for scrollbar theme
class ScrollbarTheme {
 public:
  bool NativeThemeHasButtons() const { return false; }
};

// Stub implementation for CustomScrollbar
// WebF doesn't currently support custom scrollbars, so this is a minimal stub
class CustomScrollbar {
 public:
  CustomScrollbar() = default;
  ~CustomScrollbar() = default;

  bool Enabled() const { return false; }
  ScrollbarPart HoveredPart() const { return kNoPart; }
  ScrollbarPart PressedPart() const { return kNoPart; }
  ScrollbarOrientation Orientation() const { return kHorizontalScrollbar; }
  const ScrollbarTheme& GetTheme() const { 
    static ScrollbarTheme theme;
    return theme; 
  }
};

}  // namespace webf

#endif  // WEBF_CORE_CSS_CUSTOM_SCROLLBAR_H_