/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */
/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-2024 The WebF authors. All rights reserved.
 */

#ifndef WEBF_FOUNDATION_ATOMIC_STRING_H_
#define WEBF_FOUNDATION_ATOMIC_STRING_H_

#include <memory>
#include <string>
#include "../native_value.h"
#include "core/base/hash/hash.h"
#include "string_impl.h"
#include "string_view.h"
#include "wtf_string.h"

namespace webf {

class AtomicString {
 public:
  AtomicString() = default;

  static AtomicString Null() { return AtomicString{}; }
  static AtomicString Empty() { return CreateFromUTF8(""); }

  // disable construct frm cstr
  AtomicString(const char*) = delete;

  /**
   * @see {AtomicString::CreateFromUTF8} if you want to create AtomicString from utf8 buffers.
   * @param chars the chars are Latin1(iso-8859-1) encoded
   */
  explicit AtomicString(const LChar* chars)
      : AtomicString(chars, chars ? strlen(reinterpret_cast<const char*>(chars)) : 0) {}
  AtomicString(const LChar* chars, size_t length);

  explicit AtomicString(UTF8StringView string_view);
  explicit AtomicString(const UTF8String& s) : AtomicString(CreateFromUTF8(s)){};
  explicit AtomicString(const String& s);
  explicit AtomicString(String&& s);

  explicit AtomicString(const UChar* chars)
    : AtomicString(chars, chars ? std::char_traits<char16_t>::length(chars) : 0) {}

  AtomicString(UTF16StringView string_view);
  static AtomicString CreateFromUTF8(const UTF8Char* chars, size_t length);
  static AtomicString CreateFromUTF8(const UTF8String& chars);
  AtomicString(const uint16_t* str, size_t length);
  AtomicString(const UChar* str, size_t length);
  AtomicString(const std::shared_ptr<StringImpl>& string_impl);

  AtomicString(JSContext* ctx, JSValue qjs_value);
  AtomicString(JSContext* ctx, JSAtom qjs_atom);
  AtomicString(const std::unique_ptr<AutoFreeNativeString>& native_string);
  AtomicString(const AtomicString&) = default;
  ~AtomicString() = default;

  // Returns a lowercase/uppercase version of the string.
  // These functions convert ASCII characters only.
  static AtomicString LowerASCII(AtomicString source);
  AtomicString LowerASCII() const;
  AtomicString UpperASCII() const;

  bool IsLowerASCII() const { return string_->IsLowerASCII(); }

  std::unique_ptr<SharedNativeString> ToNativeString() const;
  std::unique_ptr<SharedNativeString> ToStylePropertyNameNativeString() const;

  [[nodiscard]] UTF8String ToUTF8String() const;

  JSValue ToQuickJS(JSContext* ctx) const;

  explicit operator bool() const { return !IsNull(); }
  bool IsNull() const { return string_ == nullptr; }
  bool empty() const { return !string_ || !string_->length(); }
  bool IsEmpty() const { return empty(); }

  friend bool operator==(const AtomicString& lhs, const char* rhs) {
    return *lhs.string_ == rhs;
  }

  char16_t operator[](size_t i) const { return string_->operator[](i); }

  size_t length() const { return string_->length(); }
  bool Is8Bit() const { return string_->Is8Bit(); }

  const LChar* Characters8() const;
  const char16_t* Characters16() const;
  String GetString() const;

  AtomicString RemoveCharacters(CharacterMatchFunctionPtr);

  std::shared_ptr<StringImpl> Impl() const { return string_; }

  // Find characters.
  size_t find(char16_t c, size_t start = 0) const { return string_->Find(c, start); }
  size_t find(unsigned char c, size_t start = 0) const { return string_->Find(c, start); }
  size_t find(char c, size_t start = 0) const { return find(static_cast<unsigned char>(c), start); }
  size_t Find(CharacterMatchFunctionPtr match_function, size_t start = 0) const {
    return string_->Find(match_function, start);
  }

  bool Contains(char ch, size_t start = 0) const { return string_->Contains(ch, start); }
  bool Contains(char16_t ch, size_t start = 0) const { return string_->Contains(ch, start); }

  bool StartsWith(
      const StringView& prefix,
      TextCaseSensitivity case_sensitivity = kTextCaseSensitive) const {
    return string_->StartsWith(prefix);
  }

  inline bool ContainsOnlyLatin1OrEmpty() const {
    if (empty())
      return true;

    if (Is8Bit())
      return true;

    const char16_t* characters = Characters16();
    char16_t ored = 0;
    for (size_t i = 0; i < string_->length(); ++i)
      ored |= characters[i];
    return !(ored & 0xFF00);
  }

  unsigned Hash() const {
    if (string_ == nullptr)
      return 0;
    return string_->GetHash();
  }

  struct KeyHasher {
    std::size_t operator()(const AtomicString& k) const { return k.Hash(); }
  };

 private:
  ALWAYS_INLINE static std::shared_ptr<StringImpl> Add(std::shared_ptr<StringImpl>&& r) {
    if (!r)
      return std::move(r);
    return AddSlowCase(std::move(r));
  }

  static std::shared_ptr<StringImpl> AddSlowCase(std::shared_ptr<StringImpl>&&);

  std::shared_ptr<StringImpl> string_ = nullptr;
};

inline AtomicString operator""_as(const char* str, size_t len) {
  return AtomicString::CreateFromUTF8(str, len);
}

inline AtomicString operator""_as(const char16_t* str, size_t len) {
  return {str, len};
}

// AtomicStringRef is a reference to an AtomicString's string data.
// It is used to pass an AtomicString's string data without copying the string data.
struct AtomicStringRef {
  AtomicStringRef(const AtomicString& atomic_string) {
    if (atomic_string.IsNull()) {
      is_8bit = false;
      data.characters16 = nullptr;
      length = 0;
      return;
    }
    is_8bit = atomic_string.Is8Bit();
    if (is_8bit) {
      data.characters8 = reinterpret_cast<const uint8_t*>(atomic_string.Characters8());
    } else {
      data.characters16 = reinterpret_cast<const uint16_t*>(atomic_string.Characters16());
    }
    length = atomic_string.length();
  }

  AtomicStringRef(const std::string& string) {
    is_8bit = true;
    data.characters8 = reinterpret_cast<const uint8_t*>(string.c_str());
    length = string.length();
  }

  bool is_8bit;
  union {
    const uint8_t* characters8;
    const uint16_t* characters16;
  } data;
  int64_t length;
};

inline bool operator==(const AtomicString& a, const AtomicString& b) {
  return a.Impl() == b.Impl();
}

inline bool operator==(const AtomicString& a, const String& b) {
  return a.Impl().get() == b.Impl();
}

inline bool operator==(const String& a, const AtomicString& b) {
  return b == a;
}

// Define external global variables for the commonly used atomic strings.
// These are only usable from the main thread.
extern const AtomicString& g_null_atom;
extern const AtomicString& g_empty_atom;
extern const AtomicString& g_star_atom;
extern const AtomicString& g_xml_atom;
extern const AtomicString& g_xmlns_atom;
extern const AtomicString& g_xlink_atom;
extern const AtomicString& g_http_atom;
extern const AtomicString& g_https_atom;
extern const AtomicString& g_class_atom;
extern const AtomicString& g_style_atom;
extern const AtomicString& g_id_atom;

}  // namespace webf

#endif  // WEBF_FOUNDATION_ATOMIC_STRING_H_
