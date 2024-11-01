// Copyright 2021 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// Copyright (C) 2022-present The WebF authors. All rights reserved.

#include "core/platform/region_capture_crop_id.h"

#include <inttypes.h>
#include <cassert>
#include <string>
#include <string_view>
#include <cstdio>
#include <algorithm>
#include <vector>
#include <numeric>
#include <cstdarg>
#include <stdexcept>
#include <format>

namespace webf {

Token GUIDToToken(const webf::Uuid& guid) {
  std::string lowercase = guid.AsLowercaseString();

  // |lowercase| is either empty, or follows the expected pattern.
  // TODO(crbug.com/1260380): Resolve open question of correct treatment
  // of an invalid GUID.
  if (lowercase.empty()) {
    return webf::Token();
  }
  assert(lowercase.length() == 32u + 4u);  // 32 hex-chars; 4 hyphens.

  // Remove hyphens from the string
  lowercase.erase(std::remove(lowercase.begin(), lowercase.end(), '-'), lowercase.end());
  assert(lowercase.length() == 32u);  // 32 hex-chars; 0 hyphens.

  std::string_view string_piece(lowercase);

  uint64_t high = 0;
  bool success = webf::HexStringToUInt64(string_piece.substr(0, 16), &high);
  assert(success);

  uint64_t low = 0;
  success = webf::HexStringToUInt64(string_piece.substr(16, 16), &low);
  assert(success);

  return webf::Token(high, low);
}

// Function to concatenate a list of string views using the standard library
inline std::string StrCat(std::initializer_list<std::string_view> pieces) {
  // Calculate the total size needed
  size_t total_size = std::accumulate(pieces.begin(), pieces.end(), size_t(0),
                                      [](size_t sum, std::string_view piece) {
                                        return sum + piece.size();
                                      });

  // Create a string with the required size
  std::string result;
  result.reserve(total_size);

  // Append each piece to the result string
  for (const auto& piece : pieces) {
    result.append(piece);
  }

  return result;
}

Uuid TokenToGUID(const Token& token) {
/*
  const std::string hex_str = base::StringPrintf("%016" PRIx64 "%016" PRIx64,
                                                 token.high(), token.low());
  const std::string_view hex_string_piece(hex_str);
  const std::string lowercase = base::StrCat(
      {hex_string_piece.substr(0, 8), "-", hex_string_piece.substr(8, 4), "-",
       hex_string_piece.substr(12, 4), "-", hex_string_piece.substr(16, 4), "-",
       hex_string_piece.substr(20, 12)});

  return Uuid::ParseLowercase(lowercase);
 */
  const std::string hex_str = std::format("{:016X}{:016X}", token.high(), token.low());
  const std::string_view hex_string_piece(hex_str);
  const std::string lowercase = StrCat(
      {hex_string_piece.substr(0, 8), "-", hex_string_piece.substr(8, 4), "-",
       hex_string_piece.substr(12, 4), "-", hex_string_piece.substr(16, 4), "-",
       hex_string_piece.substr(20, 12)});

  return Uuid::ParseLowercase(lowercase);
}

}  // namespace webf
