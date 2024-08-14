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

  unsigned length_ = 0;
  std::string string_;
  bool has_buffer_ = false;
};

}

#endif  // WEBF_FOUNDATION_STRING_BUILDER_H_
