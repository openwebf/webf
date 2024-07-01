//
// Created by 谢作兵 on 18/06/24.
//

#ifndef WEBF_WRITING_MODE_H
#define WEBF_WRITING_MODE_H

#include <cstdint>
#include <iosfwd>

namespace webf {

// These values are named to match the CSS keywords they correspond to: namely
// horizontal-tb, vertical-rl and vertical-lr.
// Since these names aren't very self-explanatory, where possible use the
// inline utility functions below.
enum class WritingMode : uint8_t {
  kHorizontalTb = 0,
  kVerticalRl = 1,
  kVerticalLr = 2,
  // sideways-rl and sideways-lr are only supported by LayoutNG.
  kSidewaysRl = 3,
  kSidewaysLr = 4,

  kMaxWritingMode = kSidewaysLr,
};

// Lines have horizontal orientation; modes horizontal-tb.
inline bool IsHorizontalWritingMode(WritingMode writing_mode) {
  return writing_mode == WritingMode::kHorizontalTb;
}

// Bottom of the line occurs earlier in the block; modes vertical-lr.
inline bool IsFlippedLinesWritingMode(WritingMode writing_mode) {
  return writing_mode == WritingMode::kVerticalLr;
}

// In flipped-lines writing mode, 'line-over' and 'block-start' don't match.
// When dealing with the logical coordinate system in the [line-relative
// directions], 'vertical-lr' has 'line-over' on right, which is equivalent to
// the 'vertical-rl' in the flow-relative directions.
// https://drafts.csswg.org/css-writing-modes-3/#line-directions
inline WritingMode ToLineWritingMode(WritingMode writing_mode) {
  return !IsFlippedLinesWritingMode(writing_mode) ? writing_mode
                                                  : WritingMode::kVerticalRl;
}

// Block progression increases in the opposite direction to normal; modes
// vertical-rl.
inline bool IsFlippedBlocksWritingMode(WritingMode writing_mode) {
  return writing_mode == WritingMode::kVerticalRl;
}

// Whether the child and the containing block are parallel to each other.
// Example: vertical-rl and vertical-lr
inline bool IsParallelWritingMode(WritingMode a, WritingMode b) {
  return (a == WritingMode::kHorizontalTb) == (b == WritingMode::kHorizontalTb);
}

std::ostream& operator<<(std::ostream&, WritingMode);


}  // namespace webf

#endif  // WEBF_WRITING_MODE_H
