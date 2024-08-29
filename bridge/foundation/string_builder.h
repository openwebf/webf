/*
* Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
* Copyright (C) 2022-present The WebF authors. All rights reserved.
*/


#ifndef WEBF_FOUNDATION_STRING_BUILDER_H_
#define WEBF_FOUNDATION_STRING_BUILDER_H_

#include <string>
#include <vector>
#include <codecvt>
#include "foundation/macros.h"
#include "foundation/string_view.h"

namespace webf {

class StringBuilder {
  WEBF_STACK_ALLOCATED();
 public:

  void Append(char16_t c) {
    if (c <= 0xFF) {
      Append(static_cast<char>(c));
      return;
    }
    assert(false);
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
    string_.append(std::string(1, c));
    ++length_;
  }

  void Append(const std::string& string_view) {
    EnsureBuffer8(1);
    string_.append(string_view);
    length_ += string_view.size();
  }

  const char* Characters8() const {
    if (!length_)
      return nullptr;
    DCHECK(has_buffer_);
    return string_.data();
  }

  operator StringView() const {
    return StringView(Characters8(), length_);
  }

  std::string ReleaseString() {
    return string_;
  }

  bool empty() const {
    return string_.empty();
  }

  size_t length() const {
    return string_.length();
  }

  void Append(char c) { Append(static_cast<char>(c)); }

  void Reserve(unsigned new_size);

 private:
  static const unsigned kInlineBufferSize = 16;
  static unsigned InitialBufferSize() { return kInlineBufferSize; }

  void EnsureBuffer8(unsigned added_size) {
    if (!HasBuffer())
      CreateBuffer8(added_size);
  }

  bool HasBuffer() const { return has_buffer_; }
  void CreateBuffer8(unsigned added_size);

  friend bool operator==(const StringBuilder& a, const std::string& b);

  unsigned length_ = 0;
  std::string string_;
  bool has_buffer_ = false;
};

inline bool operator==(const StringBuilder& a, const std::string& b) {
  return a.string_ == b;
}

}

#endif  // WEBF_FOUNDATION_STRING_BUILDER_H_
