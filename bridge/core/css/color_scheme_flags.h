/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef WEBF_CSS_COLOR_SCHEME_FLAGS_H
#define WEBF_CSS_COLOR_SCHEME_FLAGS_H

namespace webf {

// Flags for color scheme preferences
enum class ColorSchemeFlags : unsigned {
  kNone = 0,
  kLight = 1 << 0,
  kDark = 1 << 1,
  kOnly = 1 << 2,
};

inline ColorSchemeFlags operator|(ColorSchemeFlags a, ColorSchemeFlags b) {
  return static_cast<ColorSchemeFlags>(
      static_cast<unsigned>(a) | static_cast<unsigned>(b));
}

inline ColorSchemeFlags operator&(ColorSchemeFlags a, ColorSchemeFlags b) {
  return static_cast<ColorSchemeFlags>(
      static_cast<unsigned>(a) & static_cast<unsigned>(b));
}

inline ColorSchemeFlags& operator|=(ColorSchemeFlags& a, ColorSchemeFlags b) {
  return a = a | b;
}

inline ColorSchemeFlags& operator&=(ColorSchemeFlags& a, ColorSchemeFlags b) {
  return a = a & b;
}

inline bool operator!(ColorSchemeFlags flags) {
  return flags == ColorSchemeFlags::kNone;
}

}  // namespace webf

#endif  // WEBF_CSS_COLOR_SCHEME_FLAGS_H