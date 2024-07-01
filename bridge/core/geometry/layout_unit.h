//
// Created by 谢作兵 on 18/06/24.
//

#ifndef WEBF_LAYOUT_UNIT_H
#define WEBF_LAYOUT_UNIT_H


#include <climits>
#include <iosfwd>
#include <limits>
#include <optional>
#include <cassert>

#include "foundation/macros.h"
#include "core/platform/math_extras.h"
#include "core/platform/saturated_cast.h"

namespace webf {


static const unsigned kLayoutUnitFractionalBits = 6;
static const int kFixedPointDenominator = 1 << kLayoutUnitFractionalBits;

const int kIntMaxForLayoutUnit = INT_MAX / kFixedPointDenominator;
const int kIntMinForLayoutUnit = INT_MIN / kFixedPointDenominator;

inline int GetMaxSaturatedSetResultForTesting() {
  // For C version the set function maxes out to max int, this differs from
  // the ARM asm version.
  return std::numeric_limits<int>::max();
}

inline int GetMinSaturatedSetResultForTesting() {
  return std::numeric_limits<int>::min();
}

// TODO(thakis): Remove these two lines once http://llvm.org/PR26504 is resolved
class LayoutUnit;
constexpr bool operator<(const LayoutUnit&, const LayoutUnit&);



// LayoutUnit is a fixed-point math class, storing multiples of 1/64 of a pixel.
// See: https://trac.webkit.org/wiki/LayoutUnit
class LayoutUnit {
  WEBF_DISALLOW_NEW();

 public:
  constexpr LayoutUnit() : value_(0) {}
  // Creates a LayoutUnit with the specified integer value.
  // If the specified value is smaller than LayoutUnit::Min(), the new
  // LayoutUnit is equivalent to LayoutUnit::Min().
  // If the specified value is greater than the maximum integer value which
  // LayoutUnit can represent, the new LayoutUnit is equivalent to
  // LayoutUnit(kIntMaxForLayoutUnit) in 32-bit Arm, or is equivalent to
  // LayoutUnit::Max() otherwise.
  template <typename IntegerType>
  constexpr explicit LayoutUnit(IntegerType value) : value_(0) {
    if (std::is_signed<IntegerType>::value)
      SaturatedSet(static_cast<int>(value));
    else
      SaturatedSet(static_cast<unsigned>(value));
  }
  constexpr explicit LayoutUnit(uint64_t value)
      : value_(static_cast<int>(value * kFixedPointDenominator > INT_MAX ? INT_MAX : value * kFixedPointDenominator)) {}
  // The specified `value` is truncated to a multiple of 1/64 near 0, and
  // is clamped by Min() and Max().
  // A NaN `value` produces LayoutUnit(0).
  constexpr explicit LayoutUnit(float value)
      : value_(webf::saturated_cast<int>(value * kFixedPointDenominator)) {}
  constexpr explicit LayoutUnit(double value)
      : value_(webf::saturated_cast<int>(value * kFixedPointDenominator)) {}

  // The specified `value` is rounded up to a multiple of 1/64, and
  // is clamped by Min() and Max().
  // A NaN `value` produces LayoutUnit(0).
  static LayoutUnit FromFloatCeil(float value) {
    LayoutUnit v;
    v.value_ = webf::saturated_cast<int>(ceilf(value * kFixedPointDenominator));
    return v;
  }

  // The specified `value` is truncated to a multiple of 1/64, and is clamped
  // by Min() and Max().
  // A NaN `value` produces LayoutUnit(0).
  static LayoutUnit FromFloatFloor(float value) {
    LayoutUnit v;
    v.value_ =
        webf::saturated_cast<int>(floorf(value * kFixedPointDenominator));
    return v;
  }

  // The specified `value` is rounded to a multiple of 1/64, and
  // is clamped by Min() and Max().
  // A NaN `value` produces LayoutUnit(0).
  static LayoutUnit FromFloatRound(float value) {
    LayoutUnit v;
    v.value_ =
        webf::saturated_cast<int>(roundf(value * kFixedPointDenominator));
    return v;
  }

  static LayoutUnit FromDoubleRound(double value) {
    LayoutUnit v;
    v.value_ = webf::saturated_cast<int>(round(value * kFixedPointDenominator));
    return v;
  }

  static LayoutUnit FromRawValue(int raw_value) {
    LayoutUnit v;
    v.value_ = raw_value;
    return v;
  }

  constexpr int ToInt() const { return value_ / kFixedPointDenominator; }
  constexpr float ToFloat() const {
    return static_cast<float>(value_) / kFixedPointDenominator;
  }
  constexpr double ToDouble() const {
    return static_cast<double>(value_) / kFixedPointDenominator;
  }
  unsigned ToUnsigned() const {
    assert_m(value_ >= 0, "overflow");
    return ToInt();
  }

  // Conversion to int or unsigned is lossy. 'explicit' on these operators won't
  // work because there are also other implicit conversion paths (e.g. operator
  // bool then to int which would generate wrong result). Use toInt() and
  // toUnsigned() instead.
  operator int() const = delete;
  operator unsigned() const = delete;

  constexpr operator double() const { return ToDouble(); }
  constexpr operator float() const { return ToFloat(); }
  constexpr operator bool() const { return value_; }

  LayoutUnit operator++(int) {
    value_ = ClampAdd(value_, kFixedPointDenominator);
    return *this;
  }

  constexpr int RawValue() const { return value_; }
  inline void SetRawValue(int value) { value_ = value; }
  void SetRawValue(int64_t value) {
    assert_m(value > std::numeric_limits<int>::min() &&
                    value < std::numeric_limits<int>::max(), "overflow");
    value_ = static_cast<int>(value);
  }

  LayoutUnit Abs() const {
    LayoutUnit return_value;
    return_value.SetRawValue(::abs(value_));
    return return_value;
  }
  int Ceil() const {
    if (UNLIKELY(value_ >= INT_MAX - kFixedPointDenominator + 1))
      return kIntMaxForLayoutUnit;

    if (value_ >= 0)
      return (value_ + kFixedPointDenominator - 1) / kFixedPointDenominator;
    return ToInt();
  }
  inline int Round() const {
    return ToInt() + ((Fraction().RawValue() + (kFixedPointDenominator / 2)) >>
                      kLayoutUnitFractionalBits);
  }

  int Floor() const {
    if (UNLIKELY(value_ <= INT_MIN + kFixedPointDenominator - 1))
      return kIntMinForLayoutUnit;

    return value_ >> kLayoutUnitFractionalBits;
  }

  LayoutUnit ClampNegativeToZero() const {
    return value_ < 0 ? LayoutUnit() : *this;
  }

  LayoutUnit ClampPositiveToZero() const {
    return value_ > 0 ? LayoutUnit() : *this;
  }

  LayoutUnit ClampIndefiniteToZero() const {
    // We compare to |kFixedPointDenominator| here instead of |kIndefiniteSize|
    // as the operator== for LayoutUnit is inlined below.
    if (value_ == -kFixedPointDenominator)
      return LayoutUnit();
    assert(value_ >= 0);
    return *this;
  }

  constexpr bool HasFraction() const {
    return RawValue() % kFixedPointDenominator;
  }

  LayoutUnit Fraction() const {
    // Compute fraction using the mod operator to preserve the sign of the value
    // as it may affect rounding.
    LayoutUnit fraction;
    fraction.SetRawValue(RawValue() % kFixedPointDenominator);
    return fraction;
  }

  bool MightBeSaturated() const {
    return RawValue() == std::numeric_limits<int>::max() ||
           RawValue() == std::numeric_limits<int>::min();
  }

  static constexpr float Epsilon() { return 1.0f / kFixedPointDenominator; }

  LayoutUnit AddEpsilon() const {
    LayoutUnit return_value;
    return_value.SetRawValue(
        value_ < std::numeric_limits<int>::max() ? value_ + 1 : value_);
    return return_value;
  }

  static constexpr LayoutUnit Max() {
    LayoutUnit m;
    m.value_ = std::numeric_limits<int>::max();
    return m;
  }
  static constexpr LayoutUnit Min() {
    LayoutUnit m;
    m.value_ = std::numeric_limits<int>::min();
    return m;
  }

  // Versions of max/min that are slightly smaller/larger than max/min() to
  // allow for rounding without overflowing.
  static constexpr LayoutUnit NearlyMax() {
    LayoutUnit m;
    m.value_ = std::numeric_limits<int>::max() - kFixedPointDenominator / 2;
    return m;
  }
  static constexpr LayoutUnit NearlyMin() {
    LayoutUnit m;
    m.value_ = std::numeric_limits<int>::min() + kFixedPointDenominator / 2;
    return m;
  }

  static LayoutUnit Clamp(double value) { return FromFloatFloor(value); }

  // Multiply by |m| and divide by |d| as a single ("fused") operation, avoiding
  // any saturation of the intermediate result. Rounding matches that of the
  // regular operations (i.e the result of the divide is rounded towards zero).
  LayoutUnit MulDiv(LayoutUnit m, LayoutUnit d) const;

  // Return `std::nullopt` if `this` is the specified value.
  std::optional<LayoutUnit> NullOptIf(LayoutUnit null_value) const;
  std::optional<LayoutUnit> NullOptIfMin() const { return NullOptIf(Min()); }

  AtomicString ToString() const;

 private:
  static bool IsInBounds(int value) {
    return ::abs(value) <=
           std::numeric_limits<int>::max() / kFixedPointDenominator;
  }
  static bool IsInBounds(unsigned value) {
    return value <= static_cast<unsigned>(std::numeric_limits<int>::max()) /
                        kFixedPointDenominator;
  }
  static bool IsInBounds(double value) {
    return ::fabs(value) <=
           std::numeric_limits<int>::max() / kFixedPointDenominator;
  }

#if defined(ARCH_CPU_ARM_FAMILY) && defined(ARCH_CPU_32_BITS) && \
    defined(COMPILER_GCC) && !BUILDFLAG(IS_NACL) && __OPTIMIZE__
  // If we're building ARM 32-bit on GCC we replace the C++ versions with some
  // native ARM assembly for speed.
  constexpr inline void SaturatedSet(int value) {
    if (IsConstantEvaluated())
      SaturatedSetNonAsm(value);
    else
      SaturatedSetAsm(value);
  }

  inline void SaturatedSetAsm(int value) {
    // Figure out how many bits are left for storing the integer part of
    // the fixed point number, and saturate our input to that
    enum { Saturate = 32 - kLayoutUnitFractionalBits };

    int result;

    // The following ARM code will Saturate the passed value to the number of
    // bits used for the whole part of the fixed point representation, then
    // shift it up into place. This will result in the low
    // <kLayoutUnitFractionalBits> bits all being 0's. When the value saturates
    // this gives a different result to from the C++ case; in the C++ code a
    // saturated value has all the low bits set to 1 (for a +ve number at
    // least). This cannot be done rapidly in ARM ... we live with the
    // difference, for the sake of speed.

    asm("ssat %[output],%[saturate],%[value]\n\t"
        "lsl  %[output],%[shift]"
        : [output] "=r"(result)
        : [value] "r"(value), [saturate] "n"(Saturate),
          [shift] "n"(kLayoutUnitFractionalBits));

    value_ = result;
  }

  constexpr inline void SaturatedSet(unsigned value) {
    if (IsConstantEvaluated())
      SaturatedSetNonAsm(value);
    else
      SaturatedSetAsm(value);
  }

  inline void SaturatedSetAsm(unsigned value) {
    // Here we are being passed an unsigned value to saturate,
    // even though the result is returned as a signed integer. The ARM
    // instruction for unsigned saturation therefore needs to be given one
    // less bit (i.e. the sign bit) for the saturation to work correctly; hence
    // the '31' below.
    enum { Saturate = 31 - kLayoutUnitFractionalBits };

    // The following ARM code will Saturate the passed value to the number of
    // bits used for the whole part of the fixed point representation, then
    // shift it up into place. This will result in the low
    // <kLayoutUnitFractionalBits> bits all being 0's. When the value saturates
    // this gives a different result to from the C++ case; in the C++ code a
    // saturated value has all the low bits set to 1. This cannot be done
    // rapidly in ARM, so we live with the difference, for the sake of speed.

    int result;

    asm("usat %[output],%[saturate],%[value]\n\t"
        "lsl  %[output],%[shift]"
        : [output] "=r"(result)
        : [value] "r"(value), [saturate] "n"(Saturate),
          [shift] "n"(kLayoutUnitFractionalBits));

    value_ = result;
  }
#else  // end of 32-bit ARM GCC
  inline constexpr void SaturatedSet(int value) {
    SaturatedSetNonAsm(value);
  }

  inline constexpr void SaturatedSet(unsigned value) {
    SaturatedSetNonAsm(value);
  }
#endif

  inline constexpr void SaturatedSetNonAsm(int value) {
    if (value > kIntMaxForLayoutUnit)
      value_ = std::numeric_limits<int>::max();
    else if (value < kIntMinForLayoutUnit)
      value_ = std::numeric_limits<int>::min();
    else
      value_ = static_cast<unsigned>(value) << kLayoutUnitFractionalBits;
  }

  inline constexpr void SaturatedSetNonAsm(unsigned value) {
    if (value >= static_cast<unsigned>(kIntMaxForLayoutUnit))
      value_ = std::numeric_limits<int>::max();
    else
      value_ = value << kLayoutUnitFractionalBits;
  }

  int value_;
};

// kIndefiniteSize is a special value used within layout code. It is typical
// within layout to have sizes which are only allowed to be non-negative or
// "indefinite". We use the value of "-1" to represent these indefinite values.
//
// It is common to clamp these indefinite values to zero.
// |LayoutUnit::ClampIndefiniteToZero| provides this functionality, and
// additionally DCHECKs that it isn't some other negative value.
constexpr LayoutUnit kIndefiniteSize(-1);

constexpr bool operator<=(const LayoutUnit& a, const LayoutUnit& b) {
  return a.RawValue() <= b.RawValue();
}

constexpr bool operator<=(const LayoutUnit& a, float b) {
  return a.ToFloat() <= b;
}

inline bool operator<=(const LayoutUnit& a, int b) {
  return a <= LayoutUnit(b);
}

constexpr bool operator<=(const float a, const LayoutUnit& b) {
  return a <= b.ToFloat();
}

inline bool operator<=(const int a, const LayoutUnit& b) {
  return LayoutUnit(a) <= b;
}

constexpr bool operator>=(const LayoutUnit& a, const LayoutUnit& b) {
  return a.RawValue() >= b.RawValue();
}

inline bool operator>=(const LayoutUnit& a, int b) {
  return a >= LayoutUnit(b);
}

constexpr bool operator>=(const float a, const LayoutUnit& b) {
  return a >= b.ToFloat();
}

constexpr bool operator>=(const LayoutUnit& a, float b) {
  return a.ToFloat() >= b;
}

inline bool operator>=(const int a, const LayoutUnit& b) {
  return LayoutUnit(a) >= b;
}

constexpr bool operator<(const LayoutUnit& a, const LayoutUnit& b) {
  return a.RawValue() < b.RawValue();
}

inline bool operator<(const LayoutUnit& a, int b) {
  return a < LayoutUnit(b);
}

constexpr bool operator<(const LayoutUnit& a, float b) {
  return a.ToFloat() < b;
}

constexpr bool operator<(const LayoutUnit& a, double b) {
  return a.ToDouble() < b;
}

inline bool operator<(const int a, const LayoutUnit& b) {
  return LayoutUnit(a) < b;
}

constexpr bool operator<(const float a, const LayoutUnit& b) {
  return a < b.ToFloat();
}

constexpr bool operator>(const LayoutUnit& a, const LayoutUnit& b) {
  return a.RawValue() > b.RawValue();
}

constexpr bool operator>(const LayoutUnit& a, double b) {
  return a.ToDouble() > b;
}

constexpr bool operator>(const LayoutUnit& a, float b) {
  return a.ToFloat() > b;
}

inline bool operator>(const LayoutUnit& a, int b) {
  return a > LayoutUnit(b);
}

inline bool operator>(const int a, const LayoutUnit& b) {
  return LayoutUnit(a) > b;
}

constexpr bool operator>(const float a, const LayoutUnit& b) {
  return a > b.ToFloat();
}

constexpr bool operator>(const double a, const LayoutUnit& b) {
  return a > b.ToDouble();
}

constexpr bool operator!=(const LayoutUnit& a, const LayoutUnit& b) {
  return a.RawValue() != b.RawValue();
}

inline bool operator!=(const LayoutUnit& a, float b) {
  return a != LayoutUnit(b);
}

inline bool operator!=(const int a, const LayoutUnit& b) {
  return LayoutUnit(a) != b;
}

inline bool operator!=(const LayoutUnit& a, int b) {
  return a != LayoutUnit(b);
}

constexpr bool operator==(const LayoutUnit& a, const LayoutUnit& b) {
  return a.RawValue() == b.RawValue();
}

inline bool operator==(const LayoutUnit& a, int b) {
  return a == LayoutUnit(b);
}

inline bool operator==(const int a, const LayoutUnit& b) {
  return LayoutUnit(a) == b;
}

constexpr bool operator==(const LayoutUnit& a, float b) {
  return a.ToFloat() == b;
}

constexpr bool operator==(const float a, const LayoutUnit& b) {
  return a == b.ToFloat();
}

// For multiplication that's prone to overflow, this bounds it to
// LayoutUnit::max() and ::min()
inline LayoutUnit BoundedMultiply(const LayoutUnit& a, const LayoutUnit& b) {
  int64_t result = static_cast<int64_t>(a.RawValue()) *
                   static_cast<int64_t>(b.RawValue()) / kFixedPointDenominator;
  int32_t high = static_cast<int32_t>(result >> 32);
  int32_t low = static_cast<int32_t>(result);
  uint32_t saturated =
      (static_cast<uint32_t>(a.RawValue() ^ b.RawValue()) >> 31) +
      std::numeric_limits<int>::max();
  // If the higher 32 bits does not match the lower 32 with sign extension the
  // operation overflowed.
  if (high != low >> 31)
    result = saturated;

  LayoutUnit return_val;
  return_val.SetRawValue(static_cast<int>(result));
  return return_val;
}

inline LayoutUnit operator*(const LayoutUnit& a, const LayoutUnit& b) {
  return BoundedMultiply(a, b);
}

inline double operator*(const LayoutUnit& a, double b) {
  return a.ToDouble() * b;
}

inline float operator*(const LayoutUnit& a, float b) {
  return a.ToFloat() * b;
}

template <typename IntegerType>
inline LayoutUnit operator*(const LayoutUnit& a, IntegerType b) {
  return a * LayoutUnit(b);
}

template <typename IntegerType>
inline LayoutUnit operator*(IntegerType a, const LayoutUnit& b) {
  return LayoutUnit(a) * b;
}

constexpr float operator*(const float a, const LayoutUnit& b) {
  return a * b.ToFloat();
}

constexpr double operator*(const double a, const LayoutUnit& b) {
  return a * b.ToDouble();
}

inline LayoutUnit operator/(const LayoutUnit& a, const LayoutUnit& b) {
  LayoutUnit return_val;
  int64_t raw_val = static_cast<int64_t>(kFixedPointDenominator) *
                    a.RawValue() / b.RawValue();
  return_val.SetRawValue(webf::saturated_cast<int>(raw_val));
  return return_val;
}

inline LayoutUnit LayoutUnit::MulDiv(LayoutUnit m, LayoutUnit d) const {
  int64_t n = static_cast<int64_t>(RawValue()) * m.RawValue();
  int64_t q = n / d.RawValue();
  return FromRawValue(webf::saturated_cast<int>(q));
}

constexpr float operator/(const LayoutUnit& a, float b) {
  return a.ToFloat() / b;
}

constexpr double operator/(const LayoutUnit& a, double b) {
  return a.ToDouble() / b;
}

template <typename IntegerType>
inline LayoutUnit operator/(const LayoutUnit& a, IntegerType b) {
  return a / LayoutUnit(b);
}

constexpr float operator/(const float a, const LayoutUnit& b) {
  return a / b.ToFloat();
}

constexpr double operator/(const double a, const LayoutUnit& b) {
  return a / b.ToDouble();
}

template <typename IntegerType>
inline LayoutUnit operator/(const IntegerType a, const LayoutUnit& b) {
  return LayoutUnit(a) / b;
}

inline LayoutUnit operator+(const LayoutUnit& a, const LayoutUnit& b) {
  LayoutUnit return_val;
  return_val.SetRawValue(ClampAdd(a.RawValue(), b.RawValue()).RawValue());
  return return_val;
}

template <typename IntegerType>
inline LayoutUnit operator+(const LayoutUnit& a, IntegerType b) {
  return a + LayoutUnit(b);
}

inline float operator+(const LayoutUnit& a, float b) {
  return a.ToFloat() + b;
}

inline double operator+(const LayoutUnit& a, double b) {
  return a.ToDouble() + b;
}

template <typename IntegerType>
inline LayoutUnit operator+(const IntegerType a, const LayoutUnit& b) {
  return LayoutUnit(a) + b;
}

constexpr float operator+(const float a, const LayoutUnit& b) {
  return a + b.ToFloat();
}

constexpr double operator+(const double a, const LayoutUnit& b) {
  return a + b.ToDouble();
}

inline LayoutUnit operator-(const LayoutUnit& a, const LayoutUnit& b) {
  LayoutUnit return_val;
  return_val.SetRawValue(webf::ClampSub(a.RawValue(), b.RawValue()).RawValue());
  return return_val;
}

template <typename IntegerType>
inline LayoutUnit operator-(const LayoutUnit& a, IntegerType b) {
  return a - LayoutUnit(b);
}

constexpr float operator-(const LayoutUnit& a, float b) {
  return a.ToFloat() - b;
}

constexpr double operator-(const LayoutUnit& a, double b) {
  return a.ToDouble() - b;
}

template <typename IntegerType>
inline LayoutUnit operator-(const IntegerType a, const LayoutUnit& b) {
  return LayoutUnit(a) - b;
}

constexpr float operator-(const float a, const LayoutUnit& b) {
  return a - b.ToFloat();
}

inline LayoutUnit operator-(const LayoutUnit& a) {
  LayoutUnit return_val;
  return_val.SetRawValue((-base::MakeClampedNum(a.RawValue())).RawValue());
  return return_val;
}

// Returns the remainder after a division with integer results.
// This calculates the modulo so that:
//   a = static_cast<int>(a / b) * b + IntMod(a, b).
inline LayoutUnit IntMod(const LayoutUnit& a, const LayoutUnit& b) {
  LayoutUnit return_val;
  return_val.SetRawValue(a.RawValue() % b.RawValue());
  return return_val;
}

inline LayoutUnit& operator+=(LayoutUnit& a, const LayoutUnit& b) {
  a.SetRawValue(base::ClampAdd(a.RawValue(), b.RawValue()).RawValue());
  return a;
}

template <typename IntegerType>
inline LayoutUnit& operator+=(LayoutUnit& a, IntegerType b) {
  a = a + LayoutUnit(b);
  return a;
}

inline LayoutUnit& operator+=(LayoutUnit& a, float b) {
  a = LayoutUnit(a + b);
  return a;
}

inline float& operator+=(float& a, const LayoutUnit& b) {
  a = a + b;
  return a;
}

template <typename IntegerType>
inline LayoutUnit& operator-=(LayoutUnit& a, IntegerType b) {
  a = a - LayoutUnit(b);
  return a;
}

inline LayoutUnit& operator-=(LayoutUnit& a, const LayoutUnit& b) {
  a.SetRawValue(base::ClampSub(a.RawValue(), b.RawValue()).RawValue());
  return a;
}

inline LayoutUnit& operator-=(LayoutUnit& a, float b) {
  a = LayoutUnit(a - b);
  return a;
}

inline float& operator-=(float& a, const LayoutUnit& b) {
  a = a - b;
  return a;
}

inline LayoutUnit& operator*=(LayoutUnit& a, const LayoutUnit& b) {
  a = a * b;
  return a;
}

inline LayoutUnit& operator*=(LayoutUnit& a, float b) {
  a = LayoutUnit(a * b);
  return a;
}

inline float& operator*=(float& a, const LayoutUnit& b) {
  a = a * b;
  return a;
}

inline LayoutUnit& operator/=(LayoutUnit& a, const LayoutUnit& b) {
  a = a / b;
  return a;
}

inline LayoutUnit& operator/=(LayoutUnit& a, float b) {
  a = LayoutUnit(a / b);
  return a;
}

inline float& operator/=(float& a, const LayoutUnit& b) {
  a = a / b;
  return a;
}

inline int SnapSizeToPixel(LayoutUnit size, LayoutUnit location) {
  LayoutUnit fraction = location.Fraction();
  int result = (fraction + size).Round() - fraction.Round();
  if (UNLIKELY(result == 0 && (size.RawValue() > 4 || size.RawValue() < -4))) {
    return size > 0 ? 1 : -1;
  }
  return result;
}

inline int SnapSizeToPixelAllowingZero(LayoutUnit size, LayoutUnit location) {
  LayoutUnit fraction = location.Fraction();
  return (fraction + size).Round() - fraction.Round();
}

inline int RoundToInt(LayoutUnit value) {
  return value.Round();
}

inline int FloorToInt(LayoutUnit value) {
  return value.Floor();
}

inline int CeilToInt(LayoutUnit value) {
  return value.Ceil();
}

inline LayoutUnit AbsoluteValue(const LayoutUnit& value) {
  return value.Abs();
}

inline bool IsIntegerValue(const LayoutUnit value) {
  return value.ToInt() == value;
}

inline std::optional<LayoutUnit> LayoutUnit::NullOptIf(
    LayoutUnit null_value) const {
  if (*this == null_value) {
    return std::nullopt;
  }
  return *this;
}

std::ostream& operator<<(std::ostream&, const LayoutUnit&);
webf::TextStream& operator<<(webf::TextStream&, const LayoutUnit&);

}  // namespace webf

#endif  // WEBF_LAYOUT_UNIT_H
