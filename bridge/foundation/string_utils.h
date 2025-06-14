/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef WEBF_FOUNDATION_STRING_UTILS_H_
#define WEBF_FOUNDATION_STRING_UTILS_H_

#include <cstddef>
#include <string>

namespace webf {

static inline int _CodeUnitCompare(size_t l1, size_t l2, const char* c1, const char* c2) {
  const size_t lmin = l1 < l2 ? l1 : l2;
  size_t pos = 0;
  while (pos < lmin && *c1 == *c2) {
    ++c1;
    ++c2;
    ++pos;
  }

  if (pos < lmin)
    return (c1[0] > c2[0]) ? 1 : -1;

  if (l1 == l2)
    return 0;

  return (l1 > l2) ? 1 : -1;
}

static inline int CodeUnitCompare8(const std::string& string1, const std::string& string2) {
  return _CodeUnitCompare(string1.length(), string2.length(), string1.data(), string2.data());
}

static inline int CodeUnitCompare(const std::string& string1, const std::string& string2) {
  if (string1.empty())
    return (!string2.empty()) ? -1 : 0;

  if (string2.empty())
    return !string1.empty() ? 1 : 0;

  return CodeUnitCompare8(string1, string2);
}

inline bool CodeUnitCompareLessThan(const std::string& a, const std::string& b) {
  return CodeUnitCompare(a, b) < 0;
}

}  // namespace webf

#endif  // WEBF_FOUNDATION_STRING_UTILS_H_
