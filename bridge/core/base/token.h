// Copyright 2018 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// Copyright (C) 2022-present The WebF authors. All rights reserved.

#ifdef UNSAFE_BUFFERS_BUILD
// TODO(crbug.com/40284755): Remove this and spanify to fix the errors.
#pragma allow_unsafe_buffers
#endif

#ifndef BASE_TOKEN_H_
#define BASE_TOKEN_H_

#include <stdint.h>

#include <compare>
#include <optional>
#include <string>
#include <string_view>
#include "core/base/containers/span.h"

namespace webf {

// A Token is a randomly chosen 128-bit integer. This class supports generation
// from a cryptographically strong random source, or constexpr construction over
// fixed values (e.g. to store a pre-generated constant value). Tokens are
// similar in spirit and purpose to UUIDs, without many of the constraints and
// expectations (such as byte layout and string representation) clasically
// associated with UUIDs.
class Token {
 public:
  // Constructs a zero Token.
  constexpr Token() = default;

  // Constructs a Token with |high| and |low| as its contents.
  constexpr Token(uint64_t high, uint64_t low) : words_{high, low} {}

  constexpr Token(const Token&) = default;
  constexpr Token& operator=(const Token&) = default;
  constexpr Token(Token&&) noexcept = default;
  constexpr Token& operator=(Token&&) = default;
  // TODO(guopengfei)：先注释
  // Constructs a new Token with random |high| and |low| values taken from a
  // cryptographically strong random source. The result's |is_zero()| is
  // guaranteed to be false.
  // static Token CreateRandom();

  // The high and low 64 bits of this Token.
  constexpr uint64_t high() const { return words_[0]; }
  constexpr uint64_t low() const { return words_[1]; }

  constexpr bool is_zero() const { return words_[0] == 0 && words_[1] == 0; }

  webf::span<const uint8_t, 16> AsBytes() const { return as_bytes(webf::span<const uint64_t, 2>(words_)); }

  friend constexpr auto operator<=>(const Token& lhs, const Token& rhs) = default;
  friend constexpr bool operator==(const Token& lhs, const Token& rhs) = default;

  // Generates a string representation of this Token useful for e.g. logging.
  std::string ToString() const;

  // FromString is the opposite of ToString. It returns std::nullopt if the
  // |string_representation| is invalid.
  static std::optional<Token> FromString(std::string_view string_representation);

 private:
  // Note: Two uint64_t are used instead of uint8_t[16] in order to have a
  // simpler implementation, paricularly for |ToString()|, |is_zero()|, and
  // constexpr value construction.

  uint64_t words_[2] = {0, 0};
};

// For use in std::unordered_map.
struct TokenHash {
  size_t operator()(const Token& token) const;
};
/* TODO(guopengfei)：临时注释Pickle相关
class Pickle;
class PickleIterator;

// For serializing and deserializing Token values.
void WriteTokenToPickle(Pickle* pickle, const Token& token);
std::optional<Token> ReadTokenFromPickle(
    PickleIterator* pickle_iterator);
*/

// 简化HexStringToUInt64，参考base/strings/string_number_conversions.cc
static bool HexStringToUInt64(std::string_view input, uint64_t* output);
}  // namespace webf

#endif  // BASE_TOKEN_H_
