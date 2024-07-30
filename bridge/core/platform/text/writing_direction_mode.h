// Copyright 2020 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#ifndef WEBF_CORE_PLATFORM_TEXT_WRITING_DIRECTION_MODE_H_
#define WEBF_CORE_PLATFORM_TEXT_WRITING_DIRECTION_MODE_H_

#include <cassert>
#include "core/platform/geometry/physical_direction.h"
#include "core/platform/text/text_direction.h"
#include "core/platform/text/writing_mode.h"
#include "foundation/macros.h"

namespace webf {

// This class packs |WritingMode| and |TextDirection|, two enums that are often
// used and passed around together, into the size of the minimum memory align.
class WritingDirectionMode {
  WEBF_DISALLOW_NEW();

 public:
  WritingDirectionMode(WritingMode writing_mode, TextDirection direction)
      : writing_mode_(writing_mode), direction_(direction) {}

  //
  // Inline direction functions.
  //
  TextDirection Direction() const { return direction_; }
  void SetDirection(TextDirection direction) { direction_ = direction; }

  bool IsLtr() const { return webf::IsLtr(direction_); }
  bool IsRtl() const { return webf::IsRtl(direction_); }

  //
  // Block direction functions.
  //
  WritingMode GetWritingMode() const { return writing_mode_; }
  void SetWritingMode(WritingMode writing_mode) { writing_mode_ = writing_mode; }

  bool IsHorizontal() const { return IsHorizontalWritingMode(writing_mode_); }

  // Block progression increases in the opposite direction to normal; modes
  // vertical-rl.
  bool IsFlippedBlocks() const { return IsFlippedBlocksWritingMode(writing_mode_); }

  // Bottom of the line occurs earlier in the block; modes vertical-lr.
  bool IsFlippedLines() const { return IsFlippedLinesWritingMode(writing_mode_); }

  // Returns whether x/y is flipped.
  bool IsFlippedX() const;
  bool IsFlippedY() const;

  //
  // Functions for both inline and block directions.
  //
  bool IsHorizontalLtr() const { return IsHorizontal() && IsLtr(); }

  // Returns a physical direction corresponding to a logical direction.
  PhysicalDirection InlineStart() const;
  PhysicalDirection InlineEnd() const;
  PhysicalDirection BlockStart() const;
  PhysicalDirection BlockEnd() const;
  PhysicalDirection LineOver() const;
  PhysicalDirection LineUnder() const;

  bool operator==(const WritingDirectionMode& other) const {
    return writing_mode_ == other.writing_mode_ && direction_ == other.direction_;
  }
  bool operator!=(const WritingDirectionMode& other) const { return !operator==(other); }

 private:
  WritingMode writing_mode_;
  TextDirection direction_;
};

inline bool WritingDirectionMode::IsFlippedX() const {
  if (IsHorizontal())
    return IsRtl();
  return IsFlippedBlocks();
}

inline bool WritingDirectionMode::IsFlippedY() const {
  if (IsHorizontal()) {
    assert(!IsFlippedBlocks());
    return false;
  }
  return IsRtl() ^ (writing_mode_ == WritingMode::kSidewaysLr);
}

std::ostream& operator<<(std::ostream&, const WritingDirectionMode&);

}  // namespace webf

#endif  // WEBF_CORE_PLATFORM_TEXT_WRITING_DIRECTION_MODE_H_
