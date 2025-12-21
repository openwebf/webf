/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-2024 The WebF authors. All rights reserved.
 */
#include "string_view.h"
#include "atomic_string.h"
#include "string_builder.h"
#include "utf8_codecs.h"
#include "wtf_string.h"

namespace webf {

StringView::StringView(const StringView& view, unsigned offset, unsigned length)
    : impl_(view.impl_), length_(length) {
  assert(offset + length <= view.length());
  if (Is8Bit())
    bytes_ = view.Characters8() + offset;
  else
    bytes_ = view.Characters16() + offset;
};

StringView::StringView(const char* string) 
    : impl_(StringImpl::empty_),
      bytes_(string), 
      length_(string ? strlen(string) : 0) {}
StringView::StringView(const unsigned char* string)
    : impl_(StringImpl::empty_),
      bytes_(string), 
      length_(strlen(reinterpret_cast<const char*>(string))) {}

StringView::StringView(AtomicString& string) : impl_(string.Impl().get()), length_(string.length()) {
  if (string.Is8Bit()) {
    bytes_ = string.Characters8();
  } else {
    bytes_ = string.Characters16();
  }
}

StringView::StringView(const AtomicString& string) : impl_(string.Impl().get()), length_(string.length()) {
  if (string.Is8Bit()) {
    bytes_ = string.Characters8();
  } else {
    bytes_ = string.Characters16();
  }
}

// These constructors are now inline in the header
StringView::StringView(StringImpl* impl) {
  if (!impl) {
    Clear();
    return;
  }
  impl_ = const_cast<StringImpl*>(impl);
  length_ = impl->length();
  if (impl->Is8Bit()) {
    bytes_ = impl->Characters8();
  } else {
    bytes_ = impl->Characters16();
  }
}

StringView::StringView(StringImpl* impl, unsigned offset) {
  if (!impl) {
    Clear();
    return;
  }
  impl_ = impl;
  if (offset >= impl->length()) {
    Clear();
    return;
  }
  length_ = impl->length() - offset;
  if (impl->Is8Bit()) {
    bytes_ = impl->Characters8() + offset;
  } else {
    bytes_ = impl->Characters16() + offset;
  }
}

StringView::StringView(StringImpl* impl, unsigned offset, unsigned length) {
  if (!impl) {
    Clear();
    return;
  }
  impl_ = impl;
  if (offset >= impl->length() || offset + length > impl->length()) {
    Clear();
    return;
  }
  length_ = length;
  if (impl->Is8Bit()) {
    bytes_ = impl->Characters8() + offset;
  } else {
    bytes_ = impl->Characters16() + offset;
  }
}

// String constructors
StringView::StringView(const String& string, unsigned offset, unsigned length)
    : StringView(string.Impl(), offset, length) {}

StringView::StringView(const String& string, unsigned offset)
    : StringView(string.Impl(), offset) {}

StringView::StringView(const String& string)
    : StringView(string.Impl()) {}

StringView::StringView(const SharedNativeString* string)
    : impl_(StringImpl::empty16_bit_),
      bytes_(string->string()), 
      length_(string->length()) {}

StringView::StringView(void* bytes, unsigned length, bool is_wide_char)
    : impl_(is_wide_char ? StringImpl::empty16_bit_ : StringImpl::empty_),
      bytes_(bytes), 
      length_(length) {}

StringView::StringView(const char* view, unsigned length) 
    : impl_(StringImpl::empty_), bytes_(view), length_(length) {}
StringView::StringView(const unsigned char* view, unsigned length) 
    : impl_(StringImpl::empty_), bytes_(view), length_(length) {}
StringView::StringView(const char16_t* view, unsigned length) 
    : impl_(StringImpl::empty16_bit_), bytes_(view), length_(length) {}

AtomicString StringView::ToAtomicString() const {
  if (Is8Bit()) {
    return {Characters8(), length()};
  } else {
    return {reinterpret_cast<const uint16_t*>(Characters16()), length()};
  }
}

// Function to convert Characters8 to UTF8String
UTF8String StringView::Characters8ToUTF8String() const {
  if (Is8Bit()) {
    return UTF8Codecs::EncodeLatin1({Characters8(), length()});
  } else {
    return UTF8Codecs::EncodeUTF16({Characters16(), length()});
  }
}

namespace {
inline bool EqualIgnoringASCIICase(const char* a, const char* b, size_t length) {
  for (size_t i = 0; i < length; ++i) {
    if (ToASCIILower(a[i]) != ToASCIILower(b[i]))
      return false;
  }
  return true;
}
}  // namespace

bool EqualIgnoringASCIICase(const std::string_view& a, const std::string_view& b) {
  if (a.length() != b.length())
    return false;
  if (a.data() == b.data())
    return true;
  return EqualIgnoringASCIICase(a.data(), b.data(), a.length());
}

bool EqualIgnoringASCIICase(const StringView& a, const StringView& b) {
  if (a.length() != b.length())
    return false;
  
  // Handle null cases
  if (a.IsNull() && b.IsNull())
    return true;
  if (a.IsNull() || b.IsNull())
    return false;
    
  // Fast path for same buffer
  if (a.Bytes() == b.Bytes() && a.Is8Bit() == b.Is8Bit())
    return true;
    
  // Compare character by character
  for (size_t i = 0; i < a.length(); ++i) {
    if (ToASCIILower(a[i]) != ToASCIILower(b[i]))
      return false;
  }
  return true;
}

bool EqualIgnoringASCIICase(const StringView& a, const char* b) {
  if (!b)
    return a.IsNull();
  
  size_t b_length = strlen(b);
  if (a.length() != b_length)
    return false;
    
  for (size_t i = 0; i < a.length(); ++i) {
    if (ToASCIILower(a[i]) != ToASCIILower(b[i]))
      return false;
  }
  return true;
}

bool StringView::operator==(const StringView& other) const {
  if (IsNull() != other.IsNull())
    return false;
  if (IsNull())
    return true;
  if (length() != other.length())
    return false;
    
  // Fast path for same buffer
  if (bytes_ == other.bytes_ && Is8Bit() == other.Is8Bit())
    return true;
    
  if (Is8Bit() == other.Is8Bit()) {
    if (Is8Bit()) {
      return memcmp(Characters8(), other.Characters8(), length()) == 0;
    } else {
      return memcmp(Characters16(), other.Characters16(), length() * sizeof(UChar)) == 0;
    }
  }
  
  // Different encodings - need to compare character by character
  for (size_t i = 0; i < length(); ++i) {
    if ((*this)[i] != other[i])
      return false;
  }
  return true;
}

bool StringView::operator==(const char* str) const {
  if (!str)
    return IsNull();
  if (IsNull())
    return false;
    
  size_t str_len = strlen(str);
  if (length() != str_len)
    return false;
    
  if (Is8Bit()) {
    return memcmp(Characters8(), str, str_len) == 0;
  } else {
    // Compare 16-bit chars with 8-bit chars
    const UChar* chars = Characters16();
    for (size_t i = 0; i < str_len; ++i) {
      if (chars[i] != static_cast<unsigned char>(str[i]))
        return false;
    }
    return true;
  }
}

std::string StringView::ToUTF8String() {
  if (impl_ == nullptr) {
    return std::string();
  }

  return impl_->ToUTF8String();
}

String StringView::EncodeForDebugging() const {
  if (IsNull()) {
    return String::FromUTF8("<null>");
  }

  StringBuilder builder;
  builder.Append('"');
  for (unsigned index = 0; index < length(); ++index) {
    // Print shorthands for select cases.
    UChar character = (*this)[index];
    switch (character) {
      case '\t':
        builder.Append("\\t"_s);
        break;
      case '\n':
        builder.Append("\\n"_s);
        break;
      case '\r':
        builder.Append("\\r"_s);
        break;
      case '"':
        builder.Append("\\\""_s);
        break;
      case '\\':
        builder.Append("\\\\"_s);
        break;
      default:
        if (IsASCIIPrintable(character)) {
          builder.Append(static_cast<char>(character));
        } else {
          // Print "\uXXXX" for control or non-ASCII characters.
          builder.AppendFormat("\\u%04X", character);
        }
        break;
    }
  }
  builder.Append('"');
  return builder.ToString();
}

bool EqualIgnoringASCIICase(const String& a, const String& b) {
  if (a.length() != b.length())
    return false;
  return EqualIgnoringASCIICase(StringView(a), StringView(b));
}

bool EqualIgnoringASCIICase(const String& a, const AtomicString& b) {
  if (a.length() != b.length())
    return false;
  return EqualIgnoringASCIICase(StringView(a), StringView(b));
}

bool EqualIgnoringASCIICase(const AtomicString& a, const String& b) {
  if (a.length() != b.length())
    return false;
  return EqualIgnoringASCIICase(StringView(a), StringView(b));
}

bool EqualIgnoringASCIICase(const String& a, const char* b) {
  return EqualIgnoringASCIICase(StringView(a), b);
}

bool EqualIgnoringASCIICase(const std::string& a, const char* b) {
  return EqualIgnoringASCIICase(std::string_view(a), std::string_view(b));
}

// Template Find functions like in Blink
template <typename CharType>
inline size_t Find(tcb::span<const CharType> characters,
                   CharType match_character,
                   size_t index = 0) {
  if (index >= characters.size()) {
    return kNotFound;
  }
  const CharType* begin = characters.data();
  const CharType* end = begin + characters.size();
  const CharType* it = std::find(begin + index, end, match_character);
  return it == end ? kNotFound : std::distance(begin, it);
}

template <typename CharType>
inline size_t Find(tcb::span<const CharType> characters,
                   CharacterMatchFunctionPtr match_function,
                   size_t index = 0) {
  if (index >= characters.size()) {
    return kNotFound;
  }
  for (size_t i = index; i < characters.size(); ++i) {
    if (match_function(characters[i])) {
      return i;
    }
  }
  return kNotFound;
}

size_t StringView::Find(CharacterMatchFunctionPtr match_function, size_t start) const {
  return Is8Bit() ? webf::Find(Span8(), match_function, start)
                  : webf::Find(Span16(), match_function, start);
}

}  // namespace webf
