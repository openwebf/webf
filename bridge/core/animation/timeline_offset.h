// Copyright 2023 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// Copyright (C) 2022-present The WebF authors. All rights reserved.

#ifndef WEBF_TIMELINE_OFFSET_H
#define WEBF_TIMELINE_OFFSET_H

#include <cstddef>

namespace webf {

class Document;
class Element;
class CSSValue;

enum class Enum : size_t { kNone, kCover, kContain, kEntry, kEntryCrossing, kExit, kExitCrossing };

struct TimelineOffset {
  using NamedRange = Enum;

  static std::string TimelineRangeNameToString(NamedRange range_name);
};

}  // namespace webf

#endif  // WEBF_TIMELINE_OFFSET_H
