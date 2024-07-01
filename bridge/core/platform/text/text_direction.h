//
// Created by 谢作兵 on 18/06/24.
//

#ifndef WEBF_TEXT_DIRECTION_H
#define WEBF_TEXT_DIRECTION_H

#include <cstdint>
#include <iosfwd>

namespace webf {

namespace i18n {

enum TextDirection {
  UNKNOWN_DIRECTION = 0,
  RIGHT_TO_LEFT = 1,
  LEFT_TO_RIGHT = 2,
  TEXT_DIRECTION_MAX = LEFT_TO_RIGHT,
};

}

// The direction of text in bidirectional scripts such as Arabic or Hebrew.
//
// Used for explicit directions such as in the HTML dir attribute or the CSS
// 'direction' property.
// https://html.spec.whatwg.org/C/#the-dir-attribute
// https://drafts.csswg.org/css-writing-modes/#direction
//
// Also used for resolved directions by UAX#9 UNICODE BIDIRECTIONAL ALGORITHM.
// http://unicode.org/reports/tr9/
enum class TextDirection : uint8_t { kLtr = 0, kRtl = 1 };

inline bool IsLtr(TextDirection direction) {
  return direction == TextDirection::kLtr;
}

inline bool IsRtl(TextDirection direction) {
  return direction != TextDirection::kLtr;
}

inline TextDirection DirectionFromLevel(unsigned level) {
  return level & 1 ? TextDirection::kRtl : TextDirection::kLtr;
}

std::ostream& operator<<(std::ostream&, TextDirection);

inline i18n::TextDirection ToBaseTextDirection(TextDirection direction) {
  switch (direction) {
    case TextDirection::kLtr:
      return i18n::TextDirection::LEFT_TO_RIGHT;
    case TextDirection::kRtl:
      return i18n::TextDirection::RIGHT_TO_LEFT;
  }
  assert_m(false,  "NOTREACHED_IN_MIGRATION");
  return i18n::TextDirection::UNKNOWN_DIRECTION;
}

}  // namespace webf

#endif  // WEBF_TEXT_DIRECTION_H
