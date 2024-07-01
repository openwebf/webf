//
// Created by 谢作兵 on 18/06/24.
//

#ifndef WEBF_INTEGER_TO_STRING_CONVERSION_H
#define WEBF_INTEGER_TO_STRING_CONVERSION_H


#include <limits>
#include <type_traits>
#include "foundation/webf_malloc.h"

namespace webf {

// Determines if a numeric value is negative without throwing compiler
// warnings on: unsigned(value) < 0.
template <typename T>
requires(std::is_arithmetic_v<T> && std::is_signed_v<T>)
    constexpr bool IsValueNegative(T value) {
  return value < 0;
}

template <typename T>
requires(std::is_arithmetic_v<T> && std::is_unsigned_v<T>)
    constexpr bool IsValueNegative(T) {
  return false;
}

// TODO(esprehn): See if we can generalize IntToStringT in
// base/strings/string_number_conversions.cc, and use unsigned type expansion
// optimization here instead of base::CheckedNumeric::UnsignedAbs().
template <typename IntegerType>
class IntegerToStringConverter {
  USING_FAST_MALLOC(IntegerToStringConverter);

 public:
  static_assert(std::is_integral<IntegerType>::value,
                "IntegerType must be a type of integer.");

  explicit IntegerToStringConverter(IntegerType input) {
    unsigned char * end = buffer_ + kBufferSize;
    begin_ = end;

    // We need to switch to the unsigned type when negating the value since
    // abs(INT_MIN) == INT_MAX + 1.
    bool is_negative = IsValueNegative(input);
    UnsignedIntegerType value = is_negative ? 0u - static_cast<UnsignedIntegerType>(input) : input;

    do {
      --begin_;
      DCHECK_GE(begin_, buffer_);
      *begin_ = static_cast<unsigned char >((value % 10) + '0');
      value /= 10;
    } while (value);

    if (is_negative) {
      --begin_;
      DCHECK_GE(begin_, buffer_);
      *begin_ = static_cast<unsigned char>('-');
    }

    length_ = static_cast<unsigned>(end - begin_);
  }

  const unsigned char* Characters8() const { return begin_; }
  unsigned length() const { return length_; }

 private:
  using UnsignedIntegerType = typename std::make_unsigned<IntegerType>::type;
  static const size_t kBufferSize = 3 * sizeof(UnsignedIntegerType) +
                                    std::numeric_limits<IntegerType>::is_signed;

  unsigned char buffer_[kBufferSize];
  unsigned char* begin_;
  unsigned length_;
};

}  // namespace webf

#endif  // WEBF_INTEGER_TO_STRING_CONVERSION_H
