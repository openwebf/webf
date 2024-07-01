//
// Created by 谢作兵 on 14/06/24.
//

#ifndef WEBF_TIMELINE_OFFSET_H
#define WEBF_TIMELINE_OFFSET_H

#include <cstddef>

namespace webf {


class Document;
class Element;
class CSSValue;

enum class Enum : size_t {
  kNone,
  kCover,
  kContain,
  kEntry,
  kEntryCrossing,
  kExit,
  kExitCrossing
};

struct TimelineOffset {
  using NamedRange = Enum;
};

}  // namespace webf

#endif  // WEBF_TIMELINE_OFFSET_H
