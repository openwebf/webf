/*
 * Copyright (C) 2010 Apple Inc. All rights reserved.
 * Copyright (C) 2012 Google Inc. All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY APPLE INC. ``AS IS'' AND ANY
 * EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
 * PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL APPLE INC. OR
 * CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
 * EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
 * PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
 * PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY
 * OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "string_builder.h"
#include "bindings/qjs/atomic_string.h"
#include <unicode/uchar.h>

namespace webf {

void StringBuilder::CreateBuffer16(unsigned added_size) {
  assert(is_8bit_ || !HasBuffer());
  Buffer8 buffer8;
  unsigned length = length_;
  int32_t capacity = 0;
  if (has_buffer_) {
    buffer8 = std::move(buffer8_);
    buffer8_.~Buffer8();
    capacity = buffer8.capacity();
  }
  new (&buffer16_) Buffer16;
  has_buffer_ = true;
  capacity = std::max<int32_t>(
      capacity, length_ + std::max<unsigned>(
                              added_size, InitialBufferSize() / sizeof(char16_t )));
  // See CreateBuffer8's call to ReserveInitialCapacity for why we do this.
  buffer16_.reserve(capacity);
  is_8bit_ = false;
  length_ = 0;
  if (!buffer8.empty()) {
    Append(buffer8.data(), length);
    return;
  }
  Append(string_);
  string_ = AtomicString();
}


void StringBuilder::CreateBuffer8(unsigned added_size) {
  assert(!HasBuffer());
  assert(is_8bit_);
  new (&buffer8_) Buffer8;
  has_buffer_ = true;
  // createBuffer is called right before appending addedSize more bytes. We
  // want to ensure we have enough space to fit m_string plus the added
  // size.
  //
  // We also ensure that we have at least the initialBufferSize of extra space
  // for appending new bytes to avoid future mallocs for appending short
  // strings or single characters. This is a no-op if m_length == 0 since
  // initialBufferSize() is the same as the inline capacity of the vector.
  // This allows doing append(string); append('\0') without extra mallocs.
  buffer8_.reserve(length_ +
                                  std::max(added_size, InitialBufferSize()));
  length_ = 0;
  Append(string_);
  string_ = AtomicString();
}


void StringBuilder::Append(const unsigned char* characters, unsigned length) {
  if (!length)
    return;
  assert(characters);

  if (is_8bit_) {
    EnsureBuffer8(length);
    buffer8_.insert(buffer8_.end(), characters, characters+length);
    length_ += length;
    return;
  }

  EnsureBuffer16(length);
  buffer16_.insert(buffer16_.end(), characters, characters + length);
  length_ += length;
}


void StringBuilder::Append(const char16_t * characters, unsigned length) {
  if (!length)
    return;
  assert(characters);

  if (is_8bit_) {
    EnsureBuffer8(length);
    buffer8_.insert(buffer8_.end() ,characters, characters+length);
    length_ += length;
    return;
  }

  EnsureBuffer16(length);
  buffer16_.insert(buffer16_.end(), characters, characters+length);
  length_ += length;
}


void StringBuilder::Clear() {
  ClearBuffer();
  string_ = AtomicString();
  length_ = 0;
  is_8bit_ = true;
}

void StringBuilder::ClearBuffer() {
  if (!has_buffer_)
    return;
  if (is_8bit_)
    buffer8_.~Buffer8();
  else
    buffer16_.~Buffer16();
  has_buffer_ = false;
}

AtomicString StringBuilder::ReleaseString() {
  AtomicString string = std::move(string_);
  Clear();
  return string;
}

AtomicString StringBuilder::ToString() {
  return string_;
}

AtomicString StringBuilder::ToAtomicString() {
  return ToString();
}

inline bool IsSpaceOrNewline(char16_t c) {
  return IsASCIISpace(c);
}

template <typename IntegralType = unsigned, typename CharType>
inline unsigned ToIntegralType(const CharType* data,
                                          size_t length,
                                          bool* parsing_result) {
  static constexpr IntegralType kIntegralMax =
      std::numeric_limits<IntegralType>::max();
  static constexpr IntegralType kIntegralMin =
      std::numeric_limits<IntegralType>::min();
  static constexpr bool kIsSigned =
      std::numeric_limits<IntegralType>::is_signed;
  assert(parsing_result);

  unsigned value = 0;
  bool result = false;
  bool is_negative = false;
  bool overflow = false;
  const bool accept_minus = true;

  if (!data)
    goto bye;

  while (length && IsSpaceOrNewline(*data)) {
    --length;
    ++data;
  }

  if (accept_minus && length && *data == '-') {
    --length;
    ++data;
    is_negative = true;
  } else if (length && *data == '+') {
    --length;
    ++data;
  }

  if (!length || !IsASCIIHexDigit(*data))
    goto bye;

  while (length && IsASCIIHexDigit(*data)) {
    --length;
    unsigned digit_value;
    CharType c = *data;
    if (IsASCIIDigit(c))
      digit_value = c - '0';
    else if (c >= 'a')
      digit_value = c - 'a' + 10;
    else
      digit_value = c - 'A' + 10;

    if (is_negative) {
      if (!kIsSigned) {
        if (digit_value != 0) {
          result = false;
          overflow = true;
        }
      } else {
        // Overflow condition:
        //       value * base - digit_value < kIntegralMin
        //   <=> value < (kIntegralMin + digit_value) / base
        // We must be careful of rounding errors here, but the default rounding
        // mode (round to zero) works well, so we can use this formula as-is.
        if (value < (kIntegralMin + digit_value) / 16) {
          result = false;
          overflow = true;
        }
      }
    } else {
      // Overflow condition:
      //       value * base + digit_value > kIntegralMax
      //   <=> value > (kIntegralMax + digit_value) / base
      // Ditto regarding rounding errors.
      if (value > (kIntegralMax - digit_value) / 16) {
        result = false;
        overflow = true;
      }
    }

    if (!overflow) {
      if (is_negative)
        value = 16 * value - digit_value;
      else
        value = 16 * value + digit_value;
    }
    ++data;
  }

  while (length && IsSpaceOrNewline(*data)) {
    --length;
    ++data;
  }

  if (length == 0) {
    if (!overflow)
      result = false;
  } else {
    // Even if we detected overflow, we return kError for trailing garbage.
    result = false;
  }
bye:
  *parsing_result = result;
  return result ? value : 0;
}

uint32_t StringBuilder::HexToUIntStrict(bool* ok) {
  if (string_.Is8Bit()) {
    return ToIntegralType<unsigned, unsigned char>(string_.Character8(), length_, ok);
  }
  return ToIntegralType<unsigned, uint16_t>(string_.Character16(), length_, ok);
}

void StringBuilder::ReserveCapacity(unsigned new_capacity) {
  if (!HasBuffer()) {
    if (is_8bit_)
      CreateBuffer8(new_capacity);
    else
      CreateBuffer16(new_capacity);
    return;
  }
  if (is_8bit_)
    buffer8_.reserve(new_capacity);
  else
    buffer16_.reserve(new_capacity);
}

void StringBuilder::Reserve16BitCapacity(unsigned new_capacity) {
  if (is_8bit_ || !HasBuffer())
    CreateBuffer16(new_capacity);
  else
    buffer16_.reserve(new_capacity);
}


}  // namespace webf
