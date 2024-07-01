//
// Created by 谢作兵 on 06/06/24.
//

#include "text_position.h"
#include <algorithm>
#include <memory>
#include <vector>

namespace webf {

OrdinalNumber TextPosition::ToOffset(const std::vector<unsigned>& line_endings) {
  unsigned line_start_offset =
      line_ != OrdinalNumber::First()
          ? line_endings.at(line_.ZeroBasedInt() - 1) + 1
          : 0;
  return OrdinalNumber::FromZeroBasedInt(line_start_offset +
                                         column_.ZeroBasedInt());
}

TextPosition TextPosition::FromOffsetAndLineEndings(
    unsigned offset,
    const std::vector<unsigned>& line_endings) {

  const unsigned* found_line_ending =
      std::lower_bound(&line_endings.front(), &line_endings.back(), offset);
  int line_index = static_cast<int>(found_line_ending - &line_endings.at(0));
  unsigned line_start_offset =
      line_index > 0 ? line_endings.at(line_index - 1) + 1 : 0;
  int column = offset - line_start_offset;
  return TextPosition(OrdinalNumber::FromZeroBasedInt(line_index),
                      OrdinalNumber::FromZeroBasedInt(column));
}


}  // namespace webf