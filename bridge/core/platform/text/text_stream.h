//
// Created by 谢作兵 on 18/06/24.
//

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
