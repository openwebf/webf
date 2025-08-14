// Copyright 2023 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// Copyright (C) 2022-present The WebF authors. All rights reserved.

#include "timeline_offset.h"
#include <string>

#include "string/wtf_string.h"

namespace webf {

/* static */
String TimelineOffset::TimelineRangeNameToString(TimelineOffset::NamedRange range_name) {
  switch (range_name) {
    case NamedRange::kNone:
      return "none"_s;

    case NamedRange::kCover:
      return "cover"_s;

    case NamedRange::kContain:
      return "contain"_s;

    case NamedRange::kEntry:
      return "entry"_s;

    case NamedRange::kEntryCrossing:
      return "entry-crossing"_s;

    case NamedRange::kExit:
      return "exit"_s;

    case NamedRange::kExitCrossing:
      return "exit-crossing"_s;
  }
}

}  // namespace webf
