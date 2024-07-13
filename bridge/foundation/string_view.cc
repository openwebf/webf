/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */
#include "string_view.h"
#include "bindings/qjs/atomic_string.h"

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
    bytes_ = string.Character8();
  } else {
    bytes_ = string.Character16();
  }
}

StringView::StringView(const AtomicString& string) : length_(string.length()), is_8bit_(string.Is8Bit()) {
  if (string.Is8Bit()) {
    bytes_ = string.Character8();
  } else {
    bytes_ = string.Character16();
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
//
//template <typename CharacterTypeA, typename CharacterTypeB>
//bool EqualIgnoringASCIICase2(const CharacterTypeA* a, const CharacterTypeB* b, uint32_t length) {
//  for (uint32_t i = 0; i < length; ++i) {
//    if (ToASCIILower(a[i]) != ToASCIILower(b[i]))
//      return false;
//  }
//  return true;
//}

AtomicString StringView::ToAtomicString(JSContext* ctx) const {
  if (Is8Bit()) {
    return {ctx, Characters8(), length()};
  } else {
    // TODO(xiezuobing): 确认抢类型转换是否安全
    return {ctx, reinterpret_cast<const uint16_t*>(Characters16()), length()};
  }
}

bool EqualIgnoringASCIICase(const StringView& a, const StringView& b) {
  if (a.length() != b.length())
    return false;
  if (a.Bytes() == b.Bytes() && a.Is8Bit() == b.Is8Bit())
    return true;
  if (a.Is8Bit()) {
    if (b.Is8Bit())
      return EqualIgnoringASCIICase(a.Characters8(), b.Characters8(), a.length());
    return EqualIgnoringASCIICase(a.Characters8(), b.Characters16(), a.length());
  }
  if (b.Is8Bit())
    return EqualIgnoringASCIICase(a.Characters16(), b.Characters8(), a.length());
  return EqualIgnoringASCIICase(a.Characters16(), b.Characters16(), a.length());
}

}  // namespace webf
