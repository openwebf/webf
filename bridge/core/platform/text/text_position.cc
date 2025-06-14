/*
 * Copyright (C) 2013, Google Inc. All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY APPLE INC. AND ITS CONTRIBUTORS ``AS IS'' AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED. IN NO EVENT SHALL APPLE INC. OR ITS CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 * CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
 * OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH
 * DAMAGE.
 */

/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "text_position.h"
#include <algorithm>
#include <memory>
#include <vector>

namespace webf {

OrdinalNumber TextPosition::ToOffset(const std::vector<unsigned>& line_endings) {
  unsigned line_start_offset = line_ != OrdinalNumber::First() ? line_endings.at(line_.ZeroBasedInt() - 1) + 1 : 0;
  return OrdinalNumber::FromZeroBasedInt(line_start_offset + column_.ZeroBasedInt());
}

TextPosition TextPosition::FromOffsetAndLineEndings(unsigned offset, const std::vector<unsigned>& line_endings) {
  const unsigned* found_line_ending = std::lower_bound(&line_endings.front(), &line_endings.back(), offset);
  int line_index = static_cast<int>(found_line_ending - &line_endings.at(0));
  unsigned line_start_offset = line_index > 0 ? line_endings.at(line_index - 1) + 1 : 0;
  int column = offset - line_start_offset;
  return TextPosition(OrdinalNumber::FromZeroBasedInt(line_index), OrdinalNumber::FromZeroBasedInt(column));
}

}  // namespace webf
