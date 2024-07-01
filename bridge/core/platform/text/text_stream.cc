//
// Created by 谢作兵 on 18/06/24.
//

#include "text_stream.h"

#include "core/platform/math_extras.h"
#include "foundation/string_builder.h"

namespace webf {

// large enough for any integer or floating point value in string format,
// including trailing null character
static const size_t kPrintBufferSize = 100;

static inline bool HasFractions(double val) {
  // We use 0.011 to more than match the number of significant digits we print
  // out when dumping the render tree.
  static const double kEpsilon = 0.011;
  int ival = static_cast<int>(round(val));
  double dval = static_cast<double>(ival);
  return fabs(val - dval) > kEpsilon;
}

TextStream& TextStream::operator<<(bool b) {
  return *this << (b ? "1" : "0");
}

TextStream& TextStream::operator<<(int16_t i) {
  text_.AppendNumber(i);
  return *this;
}

TextStream& TextStream::operator<<(uint16_t i) {
  text_.AppendNumber(i);
  return *this;
}

TextStream& TextStream::operator<<(int32_t i) {
  text_.AppendNumber(i);
  return *this;
}

TextStream& TextStream::operator<<(uint32_t i) {
  text_.AppendNumber(i);
  return *this;
}

TextStream& TextStream::operator<<(int64_t i) {
  text_.AppendNumber(i);
  return *this;
}

TextStream& TextStream::operator<<(uint64_t i) {
  // TODO(xiezuobing): StringBuilder::AppendNumber
  text_.AppendNumber(i);
  return *this;
}

TextStream& TextStream::operator<<(float f) {
  // TODO(xiezuobing): AtomicString::NumberToStringFixedWidth
  text_.Append(AtomicString::NumberToStringFixedWidth(f, 2));
  return *this;
}

TextStream& TextStream::operator<<(double d) {
  text_.Append(String::NumberToStringFixedWidth(d, 2));
  return *this;
}

TextStream& TextStream::operator<<(const char* string) {
  text_.Append(string);
  return *this;
}

TextStream& TextStream::operator<<(const void* p) {
  char buffer[kPrintBufferSize];
  snprintf(buffer, sizeof(buffer) - 1, "%p", p);
  return *this << buffer;
}

TextStream& TextStream::operator<<(const std::string& string) {
  text_.Append(string.data(), string.length());
  return *this;
}

TextStream& TextStream::operator<<(const String& string) {
  text_.Append(string);
  return *this;
}

TextStream& TextStream::operator<<(
    const FormatNumberRespectingIntegers& number_to_format) {
  if (HasFractions(number_to_format.value))
    return *this << number_to_format.value;

  text_.AppendNumber(static_cast<int>(round(number_to_format.value)));
  return *this;
}

AtomicString TextStream::Release() {
  AtomicString result = text_.ToString();
  text_.Clear();
  return result;
}

void WriteIndent(TextStream& ts, int indent) {
  for (int i = 0; i != indent; ++i)
    ts << "  ";
}

}  // namespace webf