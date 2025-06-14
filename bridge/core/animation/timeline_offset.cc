// Copyright 2023 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// Copyright (C) 2022-present The WebF authors. All rights reserved.

#include "timeline_offset.h"
#include <string>

namespace webf {

/* static */
std::string TimelineOffset::TimelineRangeNameToString(TimelineOffset::NamedRange range_name) {
  switch (range_name) {
    case NamedRange::kNone:
      return "none";

    case NamedRange::kCover:
      return "cover";

    case NamedRange::kContain:
      return "contain";

    case NamedRange::kEntry:
      return "entry";

    case NamedRange::kEntryCrossing:
      return "entry-crossing";

    case NamedRange::kExit:
      return "exit";

    case NamedRange::kExitCrossing:
      return "exit-crossing";
  }
}

}  // namespace webf
