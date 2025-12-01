/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-2024 The WebF authors. All rights reserved.
 */

#include "string_builder.h"
#include <cstring>
#include "wtf_string.h"

namespace webf {

String StringBuilder::ReleaseString() {
  if (!length_)
    return String::FromUTF8("");
  if (string_.IsNull()) {
    if (is_8bit_)
      string_ = String(Characters8(), length_);
    else
      string_ = String(Characters16(), length_);
  }
  String result = std::move(string_);
  Clear();
  return result;
}

String StringBuilder::ToString() {
  if (!length_)
    return String::EmptyString();
  if (string_.IsNull()) {
    if (is_8bit_)
      string_ = String(Characters8(), length_);
    else
      string_ = String(Characters16(), length_);
  }
  return string_;
}

AtomicString StringBuilder::ToAtomicString() {
  if (!length_)
    return AtomicString();
  String str = ToString();
  if (str.IsNull())
    return AtomicString();
  return AtomicString(str.ReleaseImpl());
}

void StringBuilder::Clear() {
  ClearBuffer();
  string_ = String();
  length_ = 0;
  is_8bit_ = true;
}

unsigned StringBuilder::Capacity() const {
  if (!HasBuffer())
    return 0;
  if (is_8bit_)
    return buffer8_.capacity();
  return buffer16_.capacity();
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

void StringBuilder::Resize(unsigned new_size) {
  DCHECK_LE(new_size, length_);
  length_ = new_size;
  if (HasBuffer()) {
    if (is_8bit_)
      buffer8_.resize(new_size);
    else
      buffer16_.resize(new_size);
  }
  // Clear cached string since buffer has changed
  string_ = String();
}

void StringBuilder::Ensure16Bit() {
  EnsureBuffer16(0);
}

void StringBuilder::CreateBuffer8(unsigned added_size) {
  DCHECK(!HasBuffer());
  DCHECK(is_8bit_);
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
  buffer8_.reserve(length_ + std::max(added_size, InitialBufferSize()));
  
  // If we have an existing string, append it to the buffer
  if (!string_.IsNull()) {
    const LChar* chars = string_.Characters8();
    buffer8_.insert(buffer8_.end(), chars, chars + length_);
    string_ = String();
  }
}

void StringBuilder::CreateBuffer16(unsigned added_size) {
  DCHECK(is_8bit_ || !HasBuffer());
  Buffer8 buffer8;
  unsigned old_length = length_;
  
  if (has_buffer_ && is_8bit_) {
    // Save existing 8-bit buffer
    buffer8 = std::move(buffer8_);
    buffer8_.~Buffer8();
  }
  
  new (&buffer16_) Buffer16;
  has_buffer_ = true;
  is_8bit_ = false;
  
  // Reserve capacity
  unsigned capacity = length_ + std::max(added_size, static_cast<unsigned>(InitialBufferSize() / sizeof(UChar)));
  buffer16_.reserve(capacity);
  
  // Copy existing content
  if (!buffer8.empty()) {
    // Convert 8-bit buffer to 16-bit
    for (unsigned i = 0; i < old_length; ++i) {
      buffer16_.push_back(buffer8[i]);
    }
  } else if (!string_.IsNull()) {
    // Copy from string
    if (string_.Is8Bit()) {
      const LChar* chars = string_.Characters8();
      for (unsigned i = 0; i < old_length; ++i) {
        buffer16_.push_back(chars[i]);
      }
    } else {
      const UChar* chars = string_.Characters16();
      buffer16_.insert(buffer16_.end(), chars, chars + old_length);
    }
    string_ = String();
  }
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

void StringBuilder::AppendNumber(double number, unsigned precision) {
  DCHECK_GT(precision, 0u);
  NumberToStringBuffer buffer;
  const char* string = NumberToFixedPrecisionString(number, precision, buffer);
  Append(reinterpret_cast<const LChar*>(string), strlen(string));
}

void StringBuilder::AppendFormat(const char* format, ...) {
  va_list args;

  static constexpr unsigned kDefaultSize = 256;
  char buffer[kDefaultSize];

  va_start(args, format);
  int length = vsnprintf(buffer, kDefaultSize, format, args);
  va_end(args);
  DCHECK_GE(length, 0);

  if (length >= static_cast<int>(kDefaultSize)) {
    // Buffer was too small, allocate a larger one
    std::vector<char> larger_buffer(length + 1);
    va_start(args, format);
    length = vsnprintf(larger_buffer.data(), larger_buffer.size(), format, args);
    va_end(args);
    Append(reinterpret_cast<const LChar*>(larger_buffer.data()), length);
  } else {
    Append(reinterpret_cast<const LChar*>(buffer), length);
  }
}

}  // namespace webf