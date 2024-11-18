/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef WEBF_FOUNDATION_ATOMIC_STRING_H_
#define WEBF_FOUNDATION_ATOMIC_STRING_H_

#include <memory>
#include <string>
#include "core/base/hash/hash.h"
#include "string_impl.h"
#include "native_value.h"

namespace webf {

class AtomicString {
 public:
  AtomicString() = default;

  static AtomicString Null() { return AtomicString(); }
  static AtomicString Empty() { return AtomicString(""); }

  explicit AtomicString(const char* chars)
      : AtomicString(chars,
                     chars ? strlen(reinterpret_cast<const char*>(chars)) : 0) {
  }

  AtomicString(std::string_view string_view);
  AtomicString(const char* chars, size_t length);
  AtomicString(const uint16_t* str, size_t length);
  AtomicString(const char16_t* str, size_t length);
  AtomicString(std::shared_ptr<StringImpl> string_impl);

  AtomicString(JSContext* ctx, JSValue qjs_value);
  AtomicString(JSContext* ctx, JSAtom qjs_atom);
  AtomicString(const std::string& s): AtomicString(s.c_str(), s.length()) {};
  AtomicString(const std::unique_ptr<AutoFreeNativeString>& native_string);
  ~AtomicString() = default;

  // Returns a lowercase/uppercase version of the string.
  // These functions convert ASCII characters only.
  static AtomicString LowerASCII(AtomicString source);
  AtomicString LowerASCII() const;
  AtomicString UpperASCII() const;

  bool IsLowerASCII() const { return string_->IsLowerASCII(); }

  std::unique_ptr<SharedNativeString> ToNativeString() const;

  std::string ToStdString() const { return std::string(string_->Characters8(), string_->length()); }
  std::string_view ToStringView() const { return std::string_view(Characters8(), length()); }

  JSValue ToQuickJS(JSContext* ctx) const;

  explicit operator bool() const { return !IsNull(); }
  bool IsNull() const { return string_ == nullptr; }
  bool empty() const { return  !string_ || !string_->length(); }

  char16_t operator[](size_t i) const { return string_->operator[](i); }

  size_t length() const { return string_->length(); }
  bool Is8Bit() const { return string_->Is8Bit(); }

  const char* Characters8() const;
  const char16_t* Characters16() const;
  std::string GetString() const { return string_->Characters8(); }

  AtomicString RemoveCharacters(CharacterMatchFunctionPtr);

  std::shared_ptr<StringImpl> Impl() const { return string_; }

  // Find characters.
  size_t find(char16_t c, size_t start = 0) const {
    return string_->Find(c, start);
  }
  size_t find(unsigned char c, size_t start = 0) const {
    return string_->Find(c, start);
  }
  size_t find(char c, size_t start = 0) const {
    return find(static_cast<unsigned char>(c), start);
  }
  size_t Find(CharacterMatchFunctionPtr match_function,
              size_t start = 0) const {
    return string_->Find(match_function, start);
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
    if (string_ == nullptr) return 0;
    return string_->GetHash();
  }

  struct KeyHasher {
    std::size_t operator()(const AtomicString& k) const { return k.Hash(); }
  };

 private:
  ALWAYS_INLINE static std::shared_ptr<StringImpl> Add(
      std::shared_ptr<StringImpl>&& r) {
    if (!r)
      return std::move(r);
    return AddSlowCase(std::move(r));
  }

  static std::shared_ptr<StringImpl> AddSlowCase(std::shared_ptr<StringImpl>&&);

  std::shared_ptr<StringImpl> string_ = nullptr;
};

inline bool operator==(const AtomicString& a, const AtomicString& b) {
  return a.Impl() == b.Impl();
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

}  // namespace webf

#endif  // WEBF_FOUNDATION_ATOMIC_STRING_H_
