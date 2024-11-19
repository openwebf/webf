/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef WEBF_FOUNDATION_STRING_BUILDER_H_
#define WEBF_FOUNDATION_STRING_BUILDER_H_

#include <codecvt>
#include <cstdarg>
#include <iomanip>
#include <sstream>
#include <string>
#include <vector>
#include "foundation/dtoa.h"
#include "foundation/macros.h"
#include "foundation/string_view.h"

#include <logging.h>

namespace webf {

/**
 * Is this code point a BMP code point (U+0000..U+ffff)?
 * @param c 32-bit code point
 * @return true or false
 * @stable ICU 2.8
 */
#define U_IS_BMP(c) ((uint32_t)(c) <= 0xffff)

/**
 * Get the lead surrogate (0xd800..0xdbff) for a
 * supplementary code point (0x10000..0x10ffff).
 * @param supplementary 32-bit code point (U+10000..U+10ffff)
 * @return lead surrogate (U+d800..U+dbff) for supplementary
 * @stable ICU 2.4
 */
#define U16_LEAD(supplementary) (char16_t)(((supplementary) >> 10) + 0xd7c0)

/**
 * Get the trail surrogate (0xdc00..0xdfff) for a
 * supplementary code point (0x10000..0x10ffff).
 * @param supplementary 32-bit code point (U+10000..U+10ffff)
 * @return trail surrogate (U+dc00..U+dfff) for supplementary
 * @stable ICU 2.4
 */
#define U16_TRAIL(supplementary) (char16_t)(((supplementary) & 0x3ff) | 0xdc00)


class StringBuilder {
  WEBF_STACK_ALLOCATED();

 public:
  void Append(char16_t c) {
    if (c <= 0xFF) {
      Append(static_cast<char>(c));
      return;
    }
  }

  void Append(const StringBuilder& other) {
    if (!other.length_)
      return;

    if (!length_ && !HasBuffer() && !other.string_.empty()) {
      string_ = other.string_;
      length_ = other.string_.length();
      return;
    }

    Append(other.string_);
  }

  void Append(unsigned char c) {
    EnsureBuffer8(1);
    string_.push_back(c);
    ++length_;
  }

  void Append(uint32_t c) {
    if (U_IS_BMP(c)) {
      Append(static_cast<char16_t>(c));
      return;
    }
    Append(U16_LEAD(c));
    Append(U16_TRAIL(c));
  }

  void Append(std::string_view view) {
    if (view.empty()) {
      return;
    }

    // If we're appending to an empty builder, and there is not a buffer
    // (reserveCapacity has not been called), then share the impl if
    // possible.
    //
    // This is important to avoid string copies inside dom operations like
    // Node::textContent when there's only a single Text node child, or
    // inside the parser in the common case when flushing buffered text to
    // a Text node.
    const char* impl = view.data();
    if (!length_ && !HasBuffer() && impl != nullptr) {
      string_ = std::string(impl, view.length());
      length_ = view.length();
      return;
    }

    EnsureBuffer8(view.length());
    string_.append(std::string(view.data(), view.length()));
    length_ += view.length();
  }

  void AppendFormat(const char* format, ...) {
    va_list args;

    static constexpr unsigned kDefaultSize = 256;
    std::string buffer;
    buffer.reserve(kDefaultSize);

    va_start(args, format);
    int length = vsnprintf(buffer.data(), kDefaultSize, format, args);
    va_end(args);
    DCHECK_GE(length, 0);

    if (length >= static_cast<int>(kDefaultSize)) {
      buffer.resize(length + 1);
      va_start(args, format);
      length = vsnprintf(buffer.data(), buffer.size(), format, args);
      va_end(args);
    }

    DCHECK_LT(static_cast<size_t>(length), buffer.size());

    Append(buffer);
  }

  void Append(int64_t v) {
    Append(std::to_string(v));
  }

  void Append(int32_t c) {
    if (U_IS_BMP(c)) {
      Append(static_cast<char16_t >(c));
      return;
    }
    Append(U16_LEAD(c));
    Append(U16_TRAIL(c));
  }

  void Append(char c) {
    EnsureBuffer8(1);
    string_.push_back(c);
    length_ += 1;
  }

  void Append(double v, unsigned precision = 6) {
    assert(precision > 0);
    NumberToStringBuffer buffer;
    NumberToFixedPrecisionString(v, precision, buffer);
    Append(std::string(buffer, strlen(buffer)));
  }

  const char* Characters8() const {
    if (!length_)
      return nullptr;
    DCHECK(has_buffer_);
    return string_.data();
  }

  operator StringView() const { return StringView(Characters8(), static_cast<unsigned>(length_)); }

  std::string ReleaseString() { return string_; }

  bool empty() const { return string_.empty(); }

  size_t length() const { return string_.length(); }

  void Reserve(unsigned new_size);

 private:
  static const size_t kInlineBufferSize = 16;
  static size_t InitialBufferSize() { return kInlineBufferSize; }

  void EnsureBuffer8(size_t added_size) {
    if (!HasBuffer())
      CreateBuffer8(added_size);
  }

  bool HasBuffer() const { return has_buffer_; }
  void CreateBuffer8(size_t added_size);

  friend bool operator==(const StringBuilder& a, const std::string& b);

  size_t length_ = 0;
  std::string string_;
  bool has_buffer_ = false;
};

inline bool operator==(const StringBuilder& a, const std::string& b) {
  return a.string_ == b;
}

}  // namespace webf

#endif  // WEBF_FOUNDATION_STRING_BUILDER_H_
