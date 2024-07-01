//
// Created by 谢作兵 on 18/06/24.
//

#include "text_direction.h"

#include <ostream>

namespace webf {

std::ostream& operator<<(std::ostream& ostream, TextDirection direction) {
  return ostream << (IsLtr(direction) ? "LTR" : "RTL");
}


}  // namespace webf