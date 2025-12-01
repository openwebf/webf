/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */
/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-2024 The WebF authors. All rights reserved.
 */

#ifndef WEBF_FOUNDATION_STRING_HASHER_H_
#define WEBF_FOUNDATION_STRING_HASHER_H_

#include <cassert>

#include "convert_to_8bit_hash_reader.h"
#include "foundation/macros.h"
#include "rapidhash.h"
#include "string_types.h"

namespace webf {

// Paul Hsieh's SuperFastHash
// http://www.azillionmonkeys.com/qed/hash.html

// LChar data is interpreted as Latin-1-encoded (zero extended to 16 bits).

// Golden ratio. Arbitrary start value to avoid mapping all zeros to a hash
// value of zero.
static const unsigned kStringHashingStartValue = 0x9E3779B9U;

class StringHasher {
  WEBF_DISALLOW_NEW();

 public:
  // Reserve 0 bits in the hash for flags; StringImpl stores flags separately.
  static const unsigned kFlagCount = 0;

  constexpr StringHasher() = default;

  // The hasher hashes two characters at a time, and thus an "aligned" hasher is
  // one where an even number of characters have been added. Callers that
  // always add characters two at a time can use the "assuming aligned"
  // functions.
  constexpr void AddCharactersAssumingAligned(char16_t a, char16_t b) {
    DCHECK(!has_pending_character_);
    hash_ += a;
    hash_ = (hash_ << 16) ^ ((b << 11) ^ hash_);
    hash_ += hash_ >> 11;
  }

  constexpr void AddCharacter(char16_t character) {
    if (has_pending_character_) {
      has_pending_character_ = false;
      AddCharactersAssumingAligned(pending_character_, character);
      return;
    }

    pending_character_ = character;
    has_pending_character_ = true;
  }

  void AddCharacters(char16_t a, char16_t b) {
    if (has_pending_character_) {
#if DCHECK_IS_ON()
      has_pending_character_ = false;
#endif
      AddCharactersAssumingAligned(pending_character_, a);
      pending_character_ = b;
#if DCHECK_IS_ON()
      has_pending_character_ = true;
#endif
      return;
    }

    AddCharactersAssumingAligned(a, b);
  }

  template <typename T, char16_t Converter(T)>
  void AddCharactersAssumingAligned(const T* data, unsigned length) {
    AddCharactersAssumingAligned_internal<T, Converter>(reinterpret_cast<const unsigned char*>(data), length);
  }

  template <typename T>
  void AddCharactersAssumingAligned(const T* data, unsigned length) {
    AddCharactersAssumingAligned_internal<T>(reinterpret_cast<const unsigned char*>(data), length);
  }

  template <typename T, char16_t Converter(T)>
  void AddCharacters(const T* data, unsigned length) {
    AddCharacters_internal<T, Converter>(reinterpret_cast<const unsigned char*>(data), length);
  }

  template <typename T>
  void AddCharacters(const T* data, unsigned length) {
    AddCharacters_internal<T>(reinterpret_cast<const unsigned char*>(data), length);
  }

  unsigned HashWithTop8BitsMasked() const {
    unsigned result = AvalancheBits();

    if constexpr (kFlagCount != 0) {
      // Reserving space from the high bits for flags preserves most of the hash's
      // value, since hash lookup typically masks out the high bits anyway.
      result &= (1u << (sizeof(result) * 8 - kFlagCount)) - 1u;

      // This avoids ever returning a hash code of 0, since that is used to
      // signal "hash not computed yet". Setting the high bit maintains
      // reasonable fidelity to a hash code of 0 because it is likely to yield
      // exactly 0 when hash lookup masks out the high bits.
      if (!result)
        result = 0x80000000u >> kFlagCount;
    } else {
      // Keep full 32 bits; ensure non-zero sentinel
      if (!result)
        result = 0x80000000u;
    }

    return result;
  }

  constexpr unsigned GetHash() const {
    unsigned result = AvalancheBits();

    // This avoids ever returning a hash code of 0, since that is used to
    // signal "hash not computed yet".
    if (!result)
      result = 0x80000000u;

    return result;
  }

  template <typename Reader = PlainHashReader>
  static unsigned ComputeHashAndMaskTop8Bits(const LChar* data, unsigned length) {
    return MaskTop8Bits(rapidhash<Reader>(reinterpret_cast<const uint8_t*>(data), length));
  }

  static unsigned ComputeHashForWideString(const UChar* data, unsigned length) {
    bool is_all_latin1 = true;

    for (size_t i = 0; i < length; i++) {
      if (data[i] & 0xff00) {
        is_all_latin1 = false;
        break;
      }
    }

    if (is_all_latin1) {
      return StringHasher::ComputeHashAndMaskTop8Bits<ConvertTo8BitHashReader>(
          reinterpret_cast<const LChar*>(data), length);
    } else {
      return StringHasher::ComputeHashAndMaskTop8Bits(
          reinterpret_cast<const uint8_t*>(data), length * 2);
    }
  }

  template <typename T, char16_t Converter(T)>
  static unsigned ComputeHash(const T* data, unsigned length) {
    StringHasher hasher;
    hasher.AddCharactersAssumingAligned<T, Converter>(data, length);
    return hasher.GetHash();
  }

  template <typename T>
  static unsigned ComputeHash(const T* data, unsigned length) {
    return ComputeHash<T, DefaultConverter>(data, length);
  }

  static unsigned HashMemory(const void* data, unsigned length) {
    return rapidhash(static_cast<const std::uint8_t*>(data), length);
  }

  template <size_t length>
  static unsigned HashMemory(const void* data) {
    static_assert(!(length % 2), "length must be a multiple of two");
    return HashMemory(data, length);
  }

 private:
  // The StringHasher works on UChar so all converters should normalize input
  // data into being a UChar.
  static char16_t DefaultConverter(char16_t character) { return character; }
  static char16_t DefaultConverter(char character) { return character; }

  static unsigned MaskTop8Bits(uint64_t result) {
    if constexpr (kFlagCount == 0) {
      // Keep full 32-bit result; ensure non-zero sentinel
      unsigned r = static_cast<unsigned>(result);
      if (!r) r = 0x80000000u;
      return r;
    } else {
      // Reserving space from the high bits for flags preserves most of the hash's
      // value, since hash lookup typically masks out the high bits anyway.
      result &= (1u << (32 - kFlagCount)) - 1u;

      // This avoids ever returning a hash code of 0, since that is used to
      // signal "hash not computed yet". Setting the high bit maintains
      // reasonable fidelity to a hash code of 0 because it is likely to yield
      // exactly 0 when hash lookup masks out the high bits.
      if (!result) {
        result = 0x80000000u >> kFlagCount;
      }

      return static_cast<unsigned>(result);
    }
  }

  template <typename T>
  void AddCharactersAssumingAligned_internal(const unsigned char* data, unsigned length) {
    AddCharactersAssumingAligned_internal<T, DefaultConverter>(data, length);
  }

  template <typename T, char16_t Converter(T)>
  void AddCharacters_internal(const unsigned char* data, unsigned length) {
    static_assert(std::is_trivial_v<T> && std::is_standard_layout_v<T>, "we only support hashing POD types");

    if (has_pending_character_ && length) {
      has_pending_character_ = false;
      T data_converted;
      std::memcpy(&data_converted, data, sizeof(T));
      AddCharactersAssumingAligned(pending_character_, Converter(data_converted));
      data += sizeof(T);
      --length;
    }
    AddCharactersAssumingAligned_internal<T, Converter>(data, length);
  }

  template <typename T>
  void AddCharacters_internal(const unsigned char* data, unsigned length) {
    AddCharacters_internal<T, DefaultConverter>(data, length);
  }

  constexpr unsigned AvalancheBits() const {
    unsigned result = hash_;

    // Handle end case.
    if (has_pending_character_) {
      result += pending_character_;
      result ^= result << 11;
      result += result >> 17;
    }

    // Force "avalanching" of final 31 bits.
    result ^= result << 3;
    result += result >> 5;
    result ^= result << 2;
    result += result >> 15;
    result ^= result << 10;

    return result;
  }

  unsigned hash_ = kStringHashingStartValue;
  bool has_pending_character_ = false;
  char16_t pending_character_ = 0;
};

}  // namespace webf

#endif  // WEBF_FOUNDATION_STRING_HASHER_H_
