// Copyright 2022 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// Copyright (C) 2022-present The WebF authors. All rights reserved.

#ifndef WEBF_CORE_ANIMATION_TIMELINE_INSET_H_
#define WEBF_CORE_ANIMATION_TIMELINE_INSET_H_

#include "core/geometry/length.h"

namespace webf {

// https://drafts.csswg.org/scroll-animations-1/#view-timeline-inset
class TimelineInset {
 public:
  TimelineInset() = default;
  TimelineInset(const Length& start, const Length& end) : start_(start), end_(end) {}

  // Note these represent the logical start/end sides of the source scroller,
  // not the start/end of the timeline.
  // https://drafts.csswg.org/css-writing-modes-4/#css-start
  const Length& GetStart() const { return start_; }
  const Length& GetEnd() const { return end_; }

  bool operator==(const TimelineInset& o) const { return start_ == o.start_ && end_ == o.end_; }

  bool operator!=(const TimelineInset& o) const { return !(*this == o); }

 private:
  Length start_;
  Length end_;
};

}  // namespace webf

#endif  // WEBF_CORE_ANIMATION_TIMELINE_INSET_H_
