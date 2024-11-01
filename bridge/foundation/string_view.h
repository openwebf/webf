// Copyright 2016 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */
#ifndef BRIDGE_FOUNDATION_STRING_VIEW_H_
#define BRIDGE_FOUNDATION_STRING_VIEW_H_

#include <string>
#include <cassert>
#include "ascii_types.h"
#include "native_string.h"
#include "foundation/ascii_types.h"

namespace webf {

class AtomicString;

// A string like object that wraps either a 8bit or 16bit byte sequence
// and keeps track of the length and the type, it does NOT own the bytes.
//
// Since StringView does not own the bytes creating a StringView from a String,
// then calling clear() on the String will result in a use-after-free. Asserts
// in ~StringView attempt to enforce this for most common cases.
class StringView final {
  WEBF_DISALLOW_NEW();

 public:
  // Null string.
  StringView() { Clear(); }

  // From a StringView:
  explicit StringView(const StringView& view, unsigned offset, unsigned length);
  explicit StringView(const StringView& view, unsigned offset)
      : StringView(view, offset, view.length_ - offset) {}

  // From a StringImpl:
  explicit StringView(const char*);
  explicit StringView(const unsigned char*);
  explicit StringView(const std::string& string);
  explicit StringView(const SharedNativeString* string);
  explicit StringView(void* bytes, unsigned length, bool is_wide_char);
  explicit StringView(const char* view, unsigned length);
  explicit StringView(const unsigned char* view, unsigned length);
  explicit StringView(const char16_t* view, unsigned length);

  // From a AtomicString
  StringView(AtomicString& string);
  StringView(const AtomicString& string);

  bool Is8Bit() const { return is_8bit_; }

  FORCE_INLINE const void* Bytes() const {
    return bytes_;
  }

  bool IsLowerASCII() const {
    if (is_8bit_) {
      return webf::IsLowerASCII(Characters8(), length());
    }
    return webf::IsLowerASCII(Characters16(), length());
  }

  const char* Characters8() const { return static_cast<const char*>(bytes_); }

  const char16_t* Characters16() const { return static_cast<const char16_t*>(bytes_); }

  size_t CharactersSizeInBytes() const {
    return length() * (Is8Bit() ? sizeof(char) : sizeof(char16_t));
  }

  void Clear();

  unsigned length() const { return length_; }
  bool Empty() const { return length_ == 0; }
  bool IsNull() const { return !bytes_; }

  AtomicString ToAtomicString(JSContext* ctx) const;

  // TODO(guopengfei)：just support utf-8
  [[nodiscard]] std::string Characters8ToStdString() const;

  char16_t operator[](unsigned i) const {
    assert(i < length());
    if (Is8Bit())
      return Characters8()[i];
    return Characters16()[i];
  }

 private:
  const void* bytes_;
  unsigned length_;
  unsigned is_8bit_ : 1;
};

inline void StringView::Clear() {
  length_ = 0;
  bytes_ = nullptr;
}

bool EqualIgnoringASCIICase(const std::string_view&, const std::string_view&);


}  // namespace webf

#endif  // BRIDGE_FOUNDATION_STRING_VIEW_H_
