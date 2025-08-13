/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "wtf_string.h"
#include <cstring>
#include <cstdarg>
#include <vector>
#include <cstdio>
#include "string_builder.h"
#include "string_view.h"

namespace webf {

// Static empty string singleton
static const String* g_empty_string = nullptr;

const String& String::EmptyString() {
  if (!g_empty_string) {
    static String empty_string(StringImpl::empty_shared());
    g_empty_string = &empty_string;
  }
  return *g_empty_string;
}
String String::EncodeForDebugging() const  {
  return StringView(*this).EncodeForDebugging();
}

String::String(const UChar* utf16_data, size_t length) {
  if (!utf16_data || !length) {
    return;
  }
  impl_ = StringImpl::Create(utf16_data, length);
}

String::String(const UChar* utf16_data) {
  if (!utf16_data) {
    return;
  }
  size_t length = 0;
  while (utf16_data[length]) {
    ++length;
  }
  if (length) {
    impl_ = StringImpl::Create(utf16_data, length);
  }
}

String::String(const LChar* latin1_data, size_t length) {
  if (!latin1_data || !length) {
    return;
  }
  impl_ = StringImpl::Create(latin1_data, length);
}

String::String(const LChar* latin1_data) {
  if (!latin1_data) {
    return;
  }
  impl_ = StringImpl::Create(latin1_data, strlen(reinterpret_cast<const char*>(latin1_data)));
}

String::String(const char* characters) {
  if (!characters) {
    return;
  }
  impl_ = StringImpl::Create(reinterpret_cast<const LChar*>(characters), strlen(characters));
}

String::String(const std::string& s) {
  if (s.empty()) {
    return;
  }
  impl_ = StringImpl::Create(reinterpret_cast<const LChar*>(s.data()), s.length());
}

String::String(const StringView& view) {
  if (view.IsNull()) {
    return;
  }
  if (view.Is8Bit()) {
    impl_ = StringImpl::Create(view.Characters8(), view.length());
  } else {
    impl_ = StringImpl::Create(view.Characters16(), view.length());
  }
}

String String::Substring(size_t pos, size_t len) const {
  if (!impl_) {
    return String();
  }
  return String(StringImpl::Substring(impl_, pos, len));
}

String String::LowerASCII() const {
  if (!impl_) {
    return String();
  }
  return String(StringImpl::LowerASCII(impl_));
}

String String::UpperASCII() const {
  if (!impl_) {
    return String();
  }
  return String(StringImpl::UpperASCII(impl_));
}

size_t String::Find(UChar c, size_t start) const {
  if (!impl_) {
    return kNotFound;
  }
  return impl_->Find(c, start);
}

size_t String::Find(const String& str, size_t start) const {
  if (!impl_ || str.IsNull()) {
    return kNotFound;
  }
  
  // Handle empty string search
  if (str.IsEmpty()) {
    return start <= length() ? start : kNotFound;
  }
  
  // Simple substring search
  size_t str_length = str.length();
  if (str_length > length()) {
    return kNotFound;
  }
  
  size_t max_start = length() - str_length;
  for (size_t i = start; i <= max_start; ++i) {
    bool match = true;
    for (size_t j = 0; j < str_length; ++j) {
      if ((*this)[i + j] != str[j]) {
        match = false;
        break;
      }
    }
    if (match) {
      return i;
    }
  }
  
  return kNotFound;
}

bool String::StartsWith(const String& prefix) const {
  if (!impl_ || prefix.IsNull()) {
    return false;
  }
  if (prefix.IsEmpty()) {
    return true;
  }
  if (prefix.length() > length()) {
    return false;
  }
  
  for (size_t i = 0; i < prefix.length(); ++i) {
    if ((*this)[i] != prefix[i]) {
      return false;
    }
  }
  return true;
}

bool String::StartsWith(UChar character) const {
  return impl_ && impl_->StartsWith(character);
}

bool String::EndsWith(const String& suffix) const {
  if (!impl_ || suffix.IsNull()) {
    return false;
  }
  if (suffix.IsEmpty()) {
    return true;
  }
  if (suffix.length() > length()) {
    return false;
  }
  
  size_t start = length() - suffix.length();
  for (size_t i = 0; i < suffix.length(); ++i) {
    if ((*this)[start + i] != suffix[i]) {
      return false;
    }
  }
  return true;
}

bool String::EndsWith(UChar character) const {
  return impl_ && impl_->length() > 0 && (*impl_)[impl_->length() - 1] == character;
}

bool String::operator==(const String& other) const {
  if (impl_ == other.impl_) {
    return true;
  }
  if (!impl_ || !other.impl_) {
    return false;
  }
  if (impl_->length() != other.impl_->length()) {
    return false;
  }
  
  // Compare character by character
  for (size_t i = 0; i < impl_->length(); ++i) {
    if ((*impl_)[i] != (*other.impl_)[i]) {
      return false;
    }
  }
  return true;
}

bool String::operator==(const char* other) const {
  if (!other) {
    return !impl_;
  }
  if (!impl_) {
    return false;
  }
  
  return *impl_ == other;
}

std::string String::StdUtf8() const {
  if (!impl_) {
    return std::string();
  }
  
  if (impl_->Is8Bit()) {
    // For 8-bit strings, we can just copy the bytes
    return std::string(reinterpret_cast<const char*>(impl_->Characters8()), impl_->length());
  } else {
    // For 16-bit strings, we need to convert to UTF-8
    // This is a simplified implementation - production code would need proper UTF-8 encoding
    std::string result;
    result.reserve(impl_->length() * 3);  // Worst case UTF-8 expansion
    
    const UChar* chars = impl_->Characters16();
    for (size_t i = 0; i < impl_->length(); ++i) {
      UChar ch = chars[i];
      if (ch < 0x80) {
        result.push_back(static_cast<char>(ch));
      } else if (ch < 0x800) {
        result.push_back(static_cast<char>(0xC0 | (ch >> 6)));
        result.push_back(static_cast<char>(0x80 | (ch & 0x3F)));
      } else {
        result.push_back(static_cast<char>(0xE0 | (ch >> 12)));
        result.push_back(static_cast<char>(0x80 | ((ch >> 6) & 0x3F)));
        result.push_back(static_cast<char>(0x80 | (ch & 0x3F)));
      }
    }
    
    return result;
  }
}

String String::FromUTF8(const char* utf8_data, size_t byte_length) {
  if (!utf8_data || !byte_length) {
    return String();
  }
  return String(StringImpl::CreateFromUTF8(utf8_data, byte_length));
}

String String::FromUTF8(const char* utf8_data) {
  if (!utf8_data) {
    return String();
  }
  return FromUTF8(utf8_data, strlen(utf8_data));
}

StringView String::ToStringView() const {
  if (IsNull()) {
    return StringView();
  }
  if (Is8Bit()) {
    return StringView(Characters8(), length());
  } else {
    return StringView(Characters16(), length());
  }
}

// String concatenation operators
String operator+(const String& a, const String& b) {
  if (a.IsNull())
    return b;
  if (b.IsNull())
    return a;
  
  StringBuilder builder;
  builder.Append(a);
  builder.Append(b);
  return builder.ReleaseString();
}

String operator+(const String& a, const char* b) {
  if (!b || !*b)
    return a;
  if (a.IsNull())
    return String(b);
    
  StringBuilder builder;
  builder.Append(a);
  builder.Append(b);
  return builder.ReleaseString();
}

String operator+(const char* a, const String& b) {
  if (!a || !*a)
    return b;
  if (b.IsNull())
    return String(a);
    
  StringBuilder builder;
  builder.Append(a);
  builder.Append(b);
  return builder.ReleaseString();
}

// Stream output operator
std::ostream& operator<<(std::ostream& out, const String& string) {
  if (string.IsNull()) {
    return out << "<null>";
  }
  return out << StringView(string).EncodeForDebugging().StdUtf8();
}

// Number to String conversion implementations
String String::Number(float number) {
  char buffer[256];
  snprintf(buffer, sizeof(buffer), "%.6g", number);
  return String(buffer);
}

String String::Number(double number, unsigned precision) {
  char buffer[256];
  char format[32];
  snprintf(format, sizeof(format), "%%.%ug", precision);
  snprintf(buffer, sizeof(buffer), format, number);
  return String(buffer);
}

// Format string implementation
String String::Format(const char* format, ...) {
  va_list args;
  va_start(args, format);
  
  // Get required buffer size
  va_list args_copy;
  va_copy(args_copy, args);
  int size = vsnprintf(nullptr, 0, format, args_copy);
  va_end(args_copy);
  
  if (size < 0) {
    va_end(args);
    return String();
  }
  
  // Allocate buffer and format string
  std::vector<char> buffer(size + 1);
  vsnprintf(buffer.data(), buffer.size(), format, args);
  va_end(args);
  
  return String(buffer.data());
}

}  // namespace webf