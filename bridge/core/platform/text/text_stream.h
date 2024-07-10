/*
 * Copyright (C) 2004, 2008 Apple Inc. All rights reserved.
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
 * THIS SOFTWARE IS PROVIDED BY APPLE COMPUTER, INC. ``AS IS'' AND ANY
 * EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
 * PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL APPLE COMPUTER, INC. OR
 * CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
 * EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
 * PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
 * PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY
 * OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef WEBF_TEXT_STREAM_H
#define WEBF_TEXT_STREAM_H


#include <string>
#include "bindings/qjs/atomic_string.h"
#include "foundation/string_builder.h"

namespace webf {


class TextStream final {
  WEBF_STACK_ALLOCATED();

 public:
  struct FormatNumberRespectingIntegers {
    FormatNumberRespectingIntegers(double number) : value(number) {}
    double value;
  };

  TextStream& operator<<(bool);
  TextStream& operator<<(int16_t);
  TextStream& operator<<(uint16_t);
  TextStream& operator<<(int32_t);
  TextStream& operator<<(uint32_t);
  TextStream& operator<<(int64_t);
  TextStream& operator<<(uint64_t);
  TextStream& operator<<(float);
  TextStream& operator<<(double);
  TextStream& operator<<(const char*);
  TextStream& operator<<(const void*);
  TextStream& operator<<(const AtomicString&);
  TextStream& operator<<(const std::string&);
  TextStream& operator<<(const FormatNumberRespectingIntegers&);

  AtomicString Release();

 private:
  StringBuilder text_;
};

void WriteIndent(TextStream&, int indent);

template <typename Item>
TextStream& operator<<(TextStream& ts, const std::vector<Item>& vector) {
  ts << "[";

  unsigned size = vector.size();
  for (unsigned i = 0; i < size; ++i) {
    ts << vector[i];
    if (i < size - 1)
      ts << ", ";
  }

  ts << "]";
  return ts;
}

}  // namespace webf

#endif  // WEBF_TEXT_STREAM_H
