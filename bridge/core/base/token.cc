// Copyright 2018 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// Copyright (C) 2022-present The WebF authors. All rights reserved.

#ifdef UNSAFE_BUFFERS_BUILD
// TODO(crbug.com/40284755): Remove this and spanify to fix the errors.
#pragma allow_unsafe_buffers
#endif

#include <inttypes.h>
#include <optional>
#include <string_view>
#include <cassert>
#include <string>
#include <sstream>
#include <iomanip>
#include <cstdint>
#include <charconv>
#include <limits>
#include "core/base/token.h"
#include "core/base/hash/hash.h"

namespace webf {
/* // TODO(guopengfei)：先注释
// static
Token Token::CreateRandom() {
  Token token;

  // Use base::RandBytes instead of crypto::RandBytes, because crypto calls the
  // base version directly, and to prevent the dependency from base/ to crypto/.
  RandBytes(byte_span_from_ref(token));

  assert(!token.is_zero());

  return token;
}*/

std::string Token::ToString() const {
  //return StringPrintf("%016" PRIX64 "%016" PRIX64, words_[0], words_[1]);
  std::ostringstream oss;
  oss << std::uppercase << std::hex << std::setfill('0')
      << std::setw(16) << words_[0]
      << std::setw(16) << words_[1];
  return oss.str();
}

// static
std::optional<Token> Token::FromString(std::string_view string_representation) {
  if (string_representation.size() != 32) {
    return std::nullopt;
  }
  uint64_t words[2];
  for (size_t i = 0; i < 2; i++) {
    uint64_t word = 0;
    // This j loop is similar to HexStringToUInt64 but we are intentionally
    // strict about case, accepting 'A' but rejecting 'a'.
    for (size_t j = 0; j < 16; j++) {
      const char c = string_representation[(16 * i) + j];
      if (('0' <= c) && (c <= '9')) {
        word = (word << 4) | static_cast<uint64_t>(c - '0');
      } else if (('A' <= c) && (c <= 'F')) {
        word = (word << 4) | static_cast<uint64_t>(c - 'A' + 10);
      } else {
        return std::nullopt;
      }
    }
    words[i] = word;
  }
  return std::optional<Token>(std::in_place, words[0], words[1]);
}
/*
void WriteTokenToPickle(Pickle* pickle, const Token& token) {
  pickle->WriteUInt64(token.high());
  pickle->WriteUInt64(token.low());
}

std::optional<Token> ReadTokenFromPickle(PickleIterator* pickle_iterator) {
  uint64_t high;
  if (!pickle_iterator->ReadUInt64(&high))
    return std::nullopt;

  uint64_t low;
  if (!pickle_iterator->ReadUInt64(&low))
    return std::nullopt;

  return Token(high, low);
}
*/
size_t TokenHash::operator()(const Token& token) const {
  return HashInts64(token.high(), token.low());
}
// static
bool HexStringToUInt64(std::string_view input, uint64_t* output) {
  // Remove leading whitespace
  input.remove_prefix(std::min(input.find_first_not_of(" \t\n\r\f\v"), input.size()));

  // Check for negative sign
  if (!input.empty() && input[0] == '-') {
    return false; // uint64_t cannot be negative
  }

  // Remove leading '+' if present
  if (!input.empty() && input[0] == '+') {
    input.remove_prefix(1);
  }

  // Use std::from_chars to convert the string to uint64_t
  auto [ptr, ec] = std::from_chars(input.data(), input.data() + input.size(), *output, 16);

  // Check if the conversion was successful
  return ec == std::errc();
}

}  // namespace base
