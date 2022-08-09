/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef KRAKENBRIDGE_CORE_DOM_LEGACY_SPACE_SPLIT_STRING_H_
#define KRAKENBRIDGE_CORE_DOM_LEGACY_SPACE_SPLIT_STRING_H_

#include <string>
#include <vector>

namespace webf {

class SpaceSplitString {
 public:
  SpaceSplitString() = default;
  explicit SpaceSplitString(std::string string) { set(string); }

  void set(std::string& string);
  bool contains(std::string& string);
  bool containsAll(std::string s);

 private:
  static std::string m_delimiter;
  std::vector<std::string> m_szData;
};

}  // namespace webf

#endif  // KRAKENBRIDGE_CORE_DOM_LEGACY_SPACE_SPLIT_STRING_H_
