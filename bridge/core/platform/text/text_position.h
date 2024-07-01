//
// Created by 谢作兵 on 06/06/24.
//

#ifndef WEBF_TEXT_POSITION_H
#define WEBF_TEXT_POSITION_H

#include <memory>
#include "foundation/macros.h"
#include "bindings/qjs/atomic_string.h"

namespace webf {


// An abstract number of element in a sequence. The sequence has a first
// element.  This type should be used instead of integer because 2
// contradicting traditions can call a first element '0' or '1' which makes
// integer type ambiguous.
class OrdinalNumber final {
  WEBF_DISALLOW_NEW();
  
 public:
  static OrdinalNumber FromZeroBasedInt(int zero_based_int) {
    return OrdinalNumber(zero_based_int);
  }
  static OrdinalNumber FromOneBasedInt(int one_based_int) {
    return OrdinalNumber(one_based_int - 1);
  }

  // Use First() instead.
  OrdinalNumber() = delete;

  int ZeroBasedInt() const { return zero_based_value_; }
  int OneBasedInt() const { return zero_based_value_ + 1; }

  bool operator==(OrdinalNumber other) const {
    return zero_based_value_ == other.zero_based_value_;
  }
  bool operator!=(OrdinalNumber other) const { return !((*this) == other); }

  static OrdinalNumber First() { return OrdinalNumber(0); }
  static OrdinalNumber BeforeFirst() { return OrdinalNumber(-1); }

 private:
  OrdinalNumber(int zero_based_int) : zero_based_value_(zero_based_int) {}
  int zero_based_value_;
};

// TextPosition structure specifies coordinates within an text resource. It is
// used mostly
// for saving script source position.
class TextPosition final {
  WEBF_DISALLOW_NEW();

 public:
  TextPosition(OrdinalNumber line, OrdinalNumber column)
      : line_(line), column_(column) {}

  // Use MinimumPosition() instead.
  TextPosition() = delete;

  bool operator==(const TextPosition& other) const {
    return line_ == other.line_ && column_ == other.column_;
  }
  bool operator!=(const TextPosition& other) const {
    return !((*this) == other);
  }
  OrdinalNumber ToOffset(const std::vector<unsigned>&);

  // A 'minimum' value of position, used as a default value.
  static TextPosition MinimumPosition() {
    return TextPosition(OrdinalNumber::First(), OrdinalNumber::First());
  }

  // A value with line value less than a minimum; used as an impossible
  // position.
  static TextPosition BelowRangePosition() {
    return TextPosition(OrdinalNumber::BeforeFirst(),
                        OrdinalNumber::BeforeFirst());
  }

  // A value corresponding to a position with given offset within text having
  // the specified line ending offsets.
  static TextPosition FromOffsetAndLineEndings(
      unsigned,
      const std::vector<unsigned>&);

  OrdinalNumber line_;
  OrdinalNumber column_;
};

 std::unique_ptr<std::vector<uint32_t>> GetLineEndings(const AtomicString&);

}  // namespace webf

using webf::OrdinalNumber;

using webf::TextPosition;

using webf::GetLineEndings;

#endif  // WEBF_TEXT_POSITION_H
