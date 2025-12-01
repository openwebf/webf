/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */
/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-2024 The WebF authors. All rights reserved.
 */

#ifndef WEBF_FOUNDATION_STRING_BUILDER_H_
#define WEBF_FOUNDATION_STRING_BUILDER_H_

#include <unicode/utf16.h>
#include <cstdarg>
#include <vector>
#include "foundation/dtoa.h"
#include "foundation/macros.h"
#include "atomic_string.h"
#include "string_view.h"
#include "wtf_string.h"

#include <logging.h>

namespace webf {

class StringBuilder {
  WEBF_STACK_ALLOCATED();

 public:
  StringBuilder() : no_buffer_(0) {}
  StringBuilder(const StringBuilder&) = delete;
  StringBuilder& operator=(const StringBuilder&) = delete;
  ~StringBuilder() { ClearBuffer(); }

  void Append(const LChar* chars, unsigned length) {
    if (!length)
      return;
    
    if (is_8bit_) {
      EnsureBuffer8(length);
      buffer8_.insert(buffer8_.end(), chars, chars + length);
      length_ += length;
      return;
    }

    EnsureBuffer16(length);
    for (unsigned i = 0; i < length; ++i) {
      buffer16_.push_back(chars[i]);
    }
    length_ += length;
  }

  void Append(const UChar* chars, unsigned length) {
    if (!length)
      return;
    
    // If there's only one char we use Append(UChar) instead since it will
    // check for latin1 and avoid converting to 16bit if possible.
    if (length == 1) {
      Append(chars[0]);
      return;
    }

    EnsureBuffer16(length);
    buffer16_.insert(buffer16_.end(), chars, chars + length);
    length_ += length;
  }

  void Append(const StringBuilder& other) {
    if (!other.length_)
      return;

    if (!length_ && !HasBuffer() && !other.string_.IsNull()) {
      string_ = other.string_;
      length_ = other.string_.length();
      is_8bit_ = other.string_.Is8Bit();
      return;
    }

    if (other.Is8Bit())
      Append(other.Characters8(), other.length());
    else
      Append(other.Characters16(), other.length());
  }

  void Append(const StringView& string, unsigned offset, unsigned length) {
    unsigned extent = offset + length;
    if (extent < offset || extent > string.length())
      return;

    // We can't do this before the above check since StringView's constructor
    // doesn't accept invalid offsets or lengths.
    Append(StringView(string, offset, length));
  }

  void Append(const StringView& string) {
    if (string.Empty())
      return;

    // If we're appending to an empty builder, and there is not a buffer
    // (reserveCapacity has not been called), then share the impl if
    // possible.
    //
    // This is important to avoid string copies inside dom operations like
    // Node::textContent when there's only a single Text node child, or
    // inside the parser in the common case when flushing buffered text to
    // a Text node.
    // Skip the SharedImpl optimization for now as our StringView doesn't have it
    // TODO: Add SharedImpl support to StringView

    if (string.Is8Bit())
      Append(string.Characters8(), string.length());
    else
      Append(string.Characters16(), string.length());
  }

  void Append(const String& string) {
    if (string.IsNull())
      return;
    if (string.Is8Bit())
      Append(string.Characters8(), string.length());
    else
      Append(string.Characters16(), string.length());
  }

  void Append(const AtomicString& atomicString) {
    Append(atomicString.GetString());
  }

  void Append(UChar c) {
    if (is_8bit_ && c <= 0xFF) {
      Append(static_cast<LChar>(c));
      return;
    }
    EnsureBuffer16(1);
    buffer16_.push_back(c);
    ++length_;
  }

  void Append(LChar c) {
    if (!is_8bit_) {
      Append(static_cast<UChar>(c));
      return;
    }
    EnsureBuffer8(1);
    buffer8_.push_back(c);
    ++length_;
  }

  void Append(char c) { Append(static_cast<LChar>(c)); }

  void Append(UCharCodePoint c) {
    if (U_IS_BMP(c)) {
      Append(static_cast<UChar>(c));
      return;
    }
    Append(U16_LEAD(c));
    Append(U16_TRAIL(c));
  }

  void AppendNumber(int number) {
    char buffer[32];
    int length = snprintf(buffer, sizeof(buffer), "%d", number);
    Append(reinterpret_cast<const LChar*>(buffer), length);
  }

  void AppendNumber(unsigned number) {
    char buffer[32];
    int length = snprintf(buffer, sizeof(buffer), "%u", number);
    Append(reinterpret_cast<const LChar*>(buffer), length);
  }

  void AppendNumber(long number) {
    char buffer[32];
    int length = snprintf(buffer, sizeof(buffer), "%ld", number);
    Append(reinterpret_cast<const LChar*>(buffer), length);
  }

  void AppendNumber(unsigned long number) {
    char buffer[32];
    int length = snprintf(buffer, sizeof(buffer), "%lu", number);
    Append(reinterpret_cast<const LChar*>(buffer), length);
  }

  void AppendNumber(long long number) {
    char buffer[32];
    int length = snprintf(buffer, sizeof(buffer), "%lld", number);
    Append(reinterpret_cast<const LChar*>(buffer), length);
  }

  void AppendNumber(unsigned long long number) {
    char buffer[32];
    int length = snprintf(buffer, sizeof(buffer), "%llu", number);
    Append(reinterpret_cast<const LChar*>(buffer), length);
  }

  void AppendNumber(double number, unsigned precision = 6);

  void AppendFormat(const char* format, ...);

  String ReleaseString();
  String ToString();
  AtomicString ToAtomicString();

  operator StringView() const {
    if (Is8Bit()) {
      return StringView(Characters8(), length_);
    } else {
      return StringView(Characters16(), length_);
    }
  }

  unsigned length() const { return length_; }
  bool empty() const { return !length_; }
  bool IsEmpty() const { return !length_; }

  unsigned Capacity() const;
  void ReserveCapacity(unsigned new_capacity);
  void Reserve16BitCapacity(unsigned new_capacity);

  void Resize(unsigned new_size);

  UChar operator[](unsigned i) const {
    DCHECK_LT(i, length_);
    if (is_8bit_)
      return Characters8()[i];
    return Characters16()[i];
  }

  const LChar* Characters8() const {
    DCHECK(is_8bit_);
    if (!length())
      return nullptr;
    if (!string_.IsNull())
      return string_.Characters8();
    DCHECK(has_buffer_);
    return buffer8_.data();
  }

  const UChar* Characters16() const {
    DCHECK(!is_8bit_);
    if (!length())
      return nullptr;
    if (!string_.IsNull())
      return string_.Characters16();
    DCHECK(has_buffer_);
    return buffer16_.data();
  }

  bool Is8Bit() const { return is_8bit_; }
  void Ensure16Bit();

  void Clear();

 private:
  static const unsigned kInlineBufferSize = 256;
  static unsigned InitialBufferSize() { return kInlineBufferSize; }

  typedef std::vector<LChar> Buffer8;
  typedef std::vector<UChar> Buffer16;

  void EnsureBuffer8(unsigned added_size) {
    DCHECK(is_8bit_);
    if (!HasBuffer())
      CreateBuffer8(added_size);
  }

  void EnsureBuffer16(unsigned added_size) {
    if (is_8bit_ || !HasBuffer())
      CreateBuffer16(added_size);
  }

  void CreateBuffer8(unsigned added_size);
  void CreateBuffer16(unsigned added_size);
  void ClearBuffer();
  bool HasBuffer() const { return has_buffer_; }

  String string_;
  union {
    char no_buffer_;
    Buffer8 buffer8_;
    Buffer16 buffer16_;
  };
  unsigned length_ = 0;
  bool is_8bit_ = true;
  bool has_buffer_ = false;
};

template <typename StringType>
bool Equal(const StringBuilder& a, const StringType& b) {
  if (a.length() != b.length())
    return false;

  if (!a.length())
    return true;

  if (a.Is8Bit()) {
    if (b.Is8Bit())
      return memcmp(a.Characters8(), b.Characters8(), a.length()) == 0;
    return false;  // Can't compare 8-bit to 16-bit directly
  }

  if (b.Is8Bit())
    return false;  // Can't compare 16-bit to 8-bit directly
  return memcmp(a.Characters16(), b.Characters16(), a.length() * sizeof(UChar)) == 0;
}

inline bool operator==(const StringBuilder& a, const String& b) {
  return Equal(a, b);
}

}  // namespace webf

#endif  // WEBF_FOUNDATION_STRING_BUILDER_H_