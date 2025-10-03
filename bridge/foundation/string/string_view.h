// Copyright 2016 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-2024 The WebF authors. All rights reserved.
 */
#ifndef BRIDGE_FOUNDATION_STRING_VIEW_H_
#define BRIDGE_FOUNDATION_STRING_VIEW_H_

#include <cassert>
#include <string>
#include <string_view>
#include "../native_string.h"
#include "ascii_types.h"
#include "string_impl.h"
#include "string_types.h"

namespace webf {

typedef bool (*CharacterMatchFunctionPtr)(UChar);

class AtomicString;
class String;

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
  explicit StringView(const StringView& view, unsigned offset) : StringView(view, offset, view.length_ - offset) {}

  // From a StringImpl:
  explicit StringView(StringImpl* impl);
  StringView(StringImpl* impl, unsigned offset);
  StringView(StringImpl* impl, unsigned offset, unsigned length);
  explicit StringView(const UTF8Char*);
  explicit StringView(const LChar*);
  explicit StringView(const UChar*);
  explicit StringView(const std::string_view&);
  explicit StringView(const std::string& string);
  explicit StringView(const SharedNativeString* string);
  explicit StringView(void* bytes, unsigned length, bool is_wide_char);
  explicit StringView(const char* view, unsigned length);
  explicit StringView(const unsigned char* view, unsigned length);
  explicit StringView(const char16_t* view, unsigned length);

  // From a AtomicString
  StringView(AtomicString& string);
  StringView(const AtomicString& string);
  
  // From a String
  explicit StringView(const String& string);
  StringView(const String& string, unsigned offset);
  StringView(const String& string, unsigned offset, unsigned length);

  bool Is8Bit() const {
    assert(impl_);
    return impl_->Is8Bit();
  }

  FORCE_INLINE const void* Bytes() const { return bytes_; }
  
  // For compatibility with std::string_view
  const char* data() const { 
    return reinterpret_cast<const char*>(bytes_);
  }
  
  size_t size() const { return length(); }
  
  StringView substr(size_t pos, size_t len = std::string::npos) const {
    if (pos > length()) return StringView();
    size_t actual_len = (len == std::string::npos) ? length() - pos : std::min(len, length() - pos);
    return StringView(*this, pos, actual_len);
  }

  bool IsLowerASCII() const {
    if (Is8Bit()) {
      return webf::IsLowerASCII(Characters8(), length());
    }
    return webf::IsLowerASCII(Characters16(), length());
  }

  [[nodiscard]] const LChar* Characters8() const { return static_cast<const LChar*>(bytes_); }

  [[nodiscard]] const UChar* Characters16() const { return static_cast<const UChar*>(bytes_); }

  [[nodiscard]] size_t CharactersSizeInBytes() const { return length() * (Is8Bit() ? sizeof(char) : sizeof(char16_t)); }

  void Clear();

  unsigned length() const { return length_; }
  bool Empty() const { return length_ == 0; }
  bool IsEmpty() const { return length_ == 0; }
  bool IsNull() const { return !bytes_; }

  AtomicString ToAtomicString() const;
  String EncodeForDebugging() const;
  
  // Find characters. Returns the index of the match, or kNotFound.
  size_t Find(CharacterMatchFunctionPtr match_function, size_t start = 0) const;
  
  // For StringBuilder optimization - returns null since StringView doesn't own the impl
  StringImpl* SharedImpl() const { return nullptr; }
  
  // Helper span methods for Find implementation
  tcb::span<const LChar> Span8() const { 
    return tcb::span<const LChar>(Characters8(), length()); 
  }
  tcb::span<const UChar> Span16() const { 
    return tcb::span<const UChar>(Characters16(), length()); 
  }

  [[nodiscard]] UTF8String Characters8ToUTF8String() const;

  char16_t operator[](unsigned i) const {
    assert(i < length());
    if (Is8Bit())
      return Characters8()[i];
    return Characters16()[i];
  }
  
  // Comparison operators
  bool operator==(const StringView& other) const;
  bool operator!=(const StringView& other) const { return !(*this == other); }
  bool operator==(const char* str) const;
  bool operator!=(const char* str) const { return !(*this == str); } std::string ToUTF8String();

 private:
  // We use the StringImpl to mark for 8bit or 16bit, even for strings where
  // we were constructed from a char pointer. So impl_->Bytes() might have
  // nothing to do with this view's bytes().
  StringImpl* impl_{};
  const void* bytes_{};
  unsigned length_{};
};

inline void StringView::Clear() {
  length_ = 0;
  bytes_ = nullptr;
  impl_ = StringImpl::empty_; // mark as 8 bit.
}

// String constructors are implemented in string_view.cc to avoid circular dependency

bool EqualIgnoringASCIICase(const std::string_view&, const std::string_view&);
bool EqualIgnoringASCIICase(const StringView&, const StringView&);
bool EqualIgnoringASCIICase(const StringView&, const char*);
bool EqualIgnoringASCIICase(const String&, const String&);
bool EqualIgnoringASCIICase(const String&, const AtomicString&);
bool EqualIgnoringASCIICase(const AtomicString&, const String&);
bool EqualIgnoringASCIICase(const String&, const char*);
bool EqualIgnoringASCIICase(const std::string&, const char*);


// literals
inline StringView operator""_sv(const char* str, size_t len) { return StringView(str, len); }

}  // namespace webf

#endif  // BRIDGE_FOUNDATION_STRING_VIEW_H_
