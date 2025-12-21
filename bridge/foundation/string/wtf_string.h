/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */
/*
 * Copyright (C) 2022-2024 The WebF authors. All rights reserved.
 */

#ifndef WEBF_FOUNDATION_STRING_WTF_STRING_H_
#define WEBF_FOUNDATION_STRING_WTF_STRING_H_

#include <iostream>
#include <memory>
#include <string>
#include "quickjs/quickjs.h"
#include "string_impl.h"

namespace webf {

// Forward declaration to avoid circular dependency
class StringView;

class String {
 public:
  // Construct a null string, distinguishable from an empty string.
  String() = default;

  // Construct a string with UTF-16 data.
  String(const UChar* utf16_data, size_t length);
  explicit String(const UChar* utf16_data);

  // Construct a string with latin1 data.
  String(const LChar* latin1_data, size_t length);
  explicit String(const LChar* latin1_data);

  // cstr and std::string is treated as utf8.
  // this behavior is intentionally different from WTF::String.
  explicit String(const char* characters);
  String(const std::string&);

  // Construct a string referencing an existing StringImpl.
  explicit String(std::shared_ptr<StringImpl> impl) : impl_(std::move(impl)) {}
  
  // Construct from StringView
  explicit String(const StringView& view);

  // Construct from JSValue
  String(JSContext* ctx, JSValueConst qjs_value);

  // Copying a String is relatively inexpensive, since the underlying data is
  // immutable and refcounted.
  String(const String&) = default;
  String& operator=(const String&) = default;
  bool ToDouble(double* p);
  String(String&&) = default;
  String& operator=(String&&) = default;

  bool IsNull() const { return !impl_; }
  bool IsEmpty() const { return !impl_ || !impl_->length(); }
  bool Is8Bit() const { return impl_ && impl_->Is8Bit(); }

  size_t length() const { return impl_ ? impl_->length() : 0; }

  const LChar* Characters8() const {
    return impl_ ? impl_->Characters8() : nullptr;
  }

  const UChar* Characters16() const {
    return impl_ ? impl_->Characters16() : nullptr;
  }

  // Access characters by index
  UChar operator[](size_t index) const {
    return impl_ ? (*impl_)[index] : 0;
  }

  // String operations
  String Substring(size_t pos, size_t len = UINT_MAX) const;
  String LowerASCII() const;
  String UpperASCII() const;
  String StripWhiteSpace() const {
    if (!impl_) {
      return String();
    }
    return String(StringImpl::StripWhiteSpace(impl_));
  }

  // Search operations
  size_t Find(UChar c, size_t start = 0) const;
  size_t Find(const String& str, size_t start = 0) const;
  
  // Reverse find - searches from the end
  size_t RFind(UChar c) const;
  size_t RFind(const String& str) const;
  
  bool StartsWith(const String& prefix) const;
  bool StartsWith(UChar character) const;
  
  bool EndsWith(const String& suffix) const;
  bool EndsWith(UChar character) const;

  // Comparison
  bool operator==(const String& other) const;
  bool operator!=(const String& other) const { return !(*this == other); }
  bool operator==(const char* other) const;
  bool operator!=(const char* other) const { return !(*this == other); }

  // Conversion
  [[nodiscard]] UTF8String ToUTF8String() const;

  static String FromUTF8(const UTF8Char* utf8_data, size_t byte_length) {
    return FromUTF8({utf8_data, byte_length});
  }
  static String FromUTF8(const UTF8Char* utf8_data) {
    const auto& view = UTF8StringView(utf8_data);
    return FromUTF8({view.data(), view.length()});
  }
  static String FromUTF8(const UTF8String& utf8_data) {
    return String(utf8_data);
  }

  // Convert to StringView
  StringView ToStringView() const LIFETIME_BOUND;
  
  // Character access for Blink compatibility
  UChar CharacterStartingAt(size_t offset) const {
    return (impl_ && offset < length()) ? (*impl_)[offset] : 0;
  }

  // Get the underlying implementation
  StringImpl* Impl() const { return impl_.get(); }
  std::shared_ptr<StringImpl> ReleaseImpl() { return std::move(impl_); }

  // Static empty string
  static const String& EmptyString();

  // Static null string
  static const String& NullString();

  String EncodeForDebugging() const;

  // Number to String conversion
  template <typename IntegerType>
  static String Number(IntegerType number) {
    return String::FromUTF8(std::to_string(number).c_str());
  }
  
  static String Number(float);
  static String Number(double, unsigned precision = 6);
  
  // Format string
  static String Format(const char* format, ...);
  
  // Utf8 conversion (alias for StdUtf8 for Blink compatibility)
  std::string Utf8() const { return ToUTF8String(); }


 private:
  std::shared_ptr<StringImpl> impl_;
};

// Free functions
inline bool operator==(const char* a, const String& b) { return b == a; }
inline bool operator!=(const char* a, const String& b) { return b != a; }

// Stream output operators
std::ostream& operator<<(std::ostream&, const String&);

// String concatenation operators
String operator+(const String& a, const String& b);
String operator+(const String& a, const char* b);
String operator+(const char* a, const String& b);


inline webf::String operator""_s(const UTF8Char* s, size_t size) { return webf::String::FromUTF8(s, size); }
inline webf::String operator""_s(const webf::UChar* s, size_t size) { return {s, size}; }

}  // namespace webf

// Hashing support
namespace std {
template <>
struct hash<webf::String> {
  size_t operator()(const webf::String& string) const {
    return string.Impl() ? string.Impl()->GetHash() : 0;
  }
};
}  // namespace std

#endif  // WEBF_FOUNDATION_STRING_WTF_STRING_H_
