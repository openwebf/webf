//
// Created by 谢作兵 on 13/08/24.
//

#include "string_util.h"

namespace webf {


template <typename T, typename CharT = typename T::value_type>
std::basic_string<CharT> ToLowerASCIIImpl(T str) {
  std::basic_string<CharT> ret;
  ret.reserve(str.size());
  for (size_t i = 0; i < str.size(); i++)
    // TODO(xiezuobing): tolower只处理char类型
    ret.push_back(ToLowerASCII(str[i]));
  return ret;
}

std::string ToLowerASCII(std::string_view str) {
  return ToLowerASCIIImpl(str);
}

}  // namespace webf