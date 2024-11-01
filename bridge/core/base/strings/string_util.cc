// Copyright 2013 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "string_util.h"
#include <algorithm>
#include <string_view>
#include "foundation/ascii_types.h"

namespace base {

bool StartsWith(std::string_view str, std::string_view search_for) {
  return str.size() >= search_for.size() &&
         str.substr(0, search_for.size()) == search_for;
}

bool EndsWith(std::string_view str, std::string_view search_for) {
  return str.size() >= search_for.size() &&
         str.substr(str.size() - search_for.size()) == search_for;
}

size_t Find(const std::string_view needle, const std::string_view& haystack) {
  if (needle.empty())
    return 0;
  if (needle.size() > haystack.size())
    return std::string::npos;
  for (size_t i = 0; i < haystack.size() - (needle.size() - 1); ++i) {
    if (strncmp(haystack.data() + i, needle.data(), needle.size()) == 0)
      return i;
  }
  return std::string::npos;
}

bool ReplaceChars(std::string_view input,
                  std::string_view from,
                  std::string_view to,
                  std::string* output) {
  // Commonly, this is called with output and input being the same string; in
  // that case, skip the copy.
  if (input.data() != output->data() || input.size() != output->size())
    output->assign(input.data(), input.size());

  size_t start_pos = 0;
  *output = std::string(input.data(), input.size());
  while ((start_pos = input.find(from, start_pos)) != std::string::npos) {
    output->replace(start_pos, from.length(), to);
    start_pos += to.length(); // Move past the last replacement
  }

  return true;
}

bool ContainsOnlyASCIIOrEmpty(const std::string& string) {
  // Performance note: This loop will not vectorize properly in -Oz. Ensure
  // the calling code is built with -O2.
  bool is_ascii = false;
  for (size_t i = 0; i < string.length(); i++) {
    is_ascii |= webf::IsASCII(string[i]);
  }

  return is_ascii || string.empty();
}

std::string ToLowerASCII(const std::string& string) {
  std::string result = string;
  std::transform(result.begin(), result.end(), result.begin(), tolower);
  return result;
}


}  // namespace base