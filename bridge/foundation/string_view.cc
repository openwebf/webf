/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */
#include "string_view.h"
#include "foundation/atomic_string.h"

namespace webf {

StringView::StringView(const StringView& view, unsigned offset, unsigned length)
    : length_(length), is_8bit_(view.is_8bit_) {
  assert(offset + length <= view.length());
  if (Is8Bit())
    bytes_ = view.Characters8() + offset;
  else
    bytes_ = view.Characters16() + offset;
};

StringView::StringView(const char* string) : bytes_(string), length_(strlen(string)), is_8bit_(true) {}
StringView::StringView(const unsigned char* string)
    : bytes_(string), length_(strlen(reinterpret_cast<const char*>(string))), is_8bit_(true) {}

StringView::StringView(AtomicString& string) : length_(string.length()), is_8bit_(string.Is8Bit()) {
  if (string.Is8Bit()) {
    bytes_ = string.Characters8();
  } else {
    bytes_ = string.Characters16();
  }
}

StringView::StringView(const AtomicString& string) : length_(string.length()), is_8bit_(string.Is8Bit()) {
  if (string.Is8Bit()) {
    bytes_ = string.Characters8();
  } else {
    bytes_ = string.Characters16();
  }
}

StringView::StringView(const std::string& string) : bytes_(string.data()), length_(string.length()), is_8bit_(true) {}

StringView::StringView(const SharedNativeString* string)
    : bytes_(string->string()), length_(string->length()), is_8bit_(false) {}

StringView::StringView(void* bytes, unsigned length, bool is_wide_char)
    : bytes_(bytes), length_(length), is_8bit_(!is_wide_char) {}


StringView::StringView(const char* view, unsigned length) : bytes_(view), length_(length), is_8bit_(true){};
StringView::StringView(const unsigned char* view, unsigned length) : bytes_(view), length_(length), is_8bit_(true){};
StringView::StringView(const char16_t* view, unsigned length) : bytes_(view), length_(length), is_8bit_(false){};

AtomicString StringView::ToAtomicString() const {
  if (Is8Bit()) {
    return {Characters8(), length()};
  } else {
    return {reinterpret_cast<const uint16_t*>(Characters16()), length()};
  }
}

// Function to convert Characters8 to std::string
std::string StringView::Characters8ToStdString() const {
  if (is_8bit_) {
    return {Characters8(), length()};
  } else {
    return "";
  }
}

namespace {
inline bool EqualIgnoringASCIICase(const char* a,
                                   const char* b,
                                   size_t length) {
  for (size_t i = 0; i < length; ++i) {
    if (ToASCIILower(a[i]) != ToASCIILower(b[i]))
      return false;
  }
  return true;
}
}

bool EqualIgnoringASCIICase(const std::string_view& a, const std::string_view& b) {
  if (a.length() != b.length())
    return false;
  if (a.data() == b.data())
    return true;
  return EqualIgnoringASCIICase(a.data(), b.data(), a.length());
}

}  // namespace webf
