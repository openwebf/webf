// Copyright 2023 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// Copyright (C) 2022-present The WebF authors. All rights reserved.

#ifndef WEBF_TIMELINE_OFFSET_H
#define WEBF_TIMELINE_OFFSET_H

#include <cstddef>
#include <string>

#include "string/wtf_string.h"

namespace webf {

class Document;
class Element;
class CSSValue;

enum class Enum : size_t { kNone, kCover, kContain, kEntry, kEntryCrossing, kExit, kExitCrossing };

struct TimelineOffset {
  using NamedRange = Enum;

  static String TimelineRangeNameToString(NamedRange range_name);
  
  // Add comparison operators for std::optional<TimelineOffset> comparisons
  bool operator==(const TimelineOffset& other) const {
    // Since TimelineOffset is currently just a struct with static members,
    // all instances are considered equal
    return true;
  }
  
  bool operator!=(const TimelineOffset& other) const {
    return !(*this == other);
  }
};

}  // namespace webf

#endif  // WEBF_TIMELINE_OFFSET_H
