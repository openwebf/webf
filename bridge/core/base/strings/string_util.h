//
// Created by 谢作兵 on 13/08/24.
//

#ifndef WEBF_STRING_UTIL_H
#define WEBF_STRING_UTIL_H


#include <stdarg.h>  // va_list
#include <stddef.h>
#include <stdint.h>

#include <concepts>
#include <initializer_list>
#include <memory>
#include <string>
#include <string_view>
#include <vector>
#include "core/base/ranges/algorithm.h"
#include "core/base/strings/string_util_internal.h"


namespace webf {

std::string ToLowerASCII(std::string_view str);


// Equality for ASCII case-insensitive comparisons. Non-ASCII bytes (or UTF-16
// code units in `std::u16string_view`) are permitted but will be compared
// unmodified. To compare all Unicode code points case-insensitively, use
// base::i18n::ToLower or base::i18n::FoldCase and then compare with either ==
// or !=.
inline bool EqualsCaseInsensitiveASCII(std::string_view a, std::string_view b) {
  return EqualsCaseInsensitiveASCIIT(a, b);
}
inline bool EqualsCaseInsensitiveASCII(std::u16string_view a,
                                       std::u16string_view b) {
  return EqualsCaseInsensitiveASCIIT(a, b);
}
inline bool EqualsCaseInsensitiveASCII(std::u16string_view a,
                                       std::string_view b) {
  return EqualsCaseInsensitiveASCIIT(a, b);
}
inline bool EqualsCaseInsensitiveASCII(std::string_view a,
                                       std::u16string_view b) {
  return EqualsCaseInsensitiveASCIIT(a, b);
}

}  // namespace webf

#endif  // WEBF_STRING_UTIL_H
