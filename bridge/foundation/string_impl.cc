/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "string_impl.h"
#include <algorithm>
#include <cassert>
#include <string>
#include "ascii_fast_path.h"
#include "string_buffer.h"

namespace webf {

DEFINE_GLOBAL(StringImpl, g_global_empty);
DEFINE_GLOBAL(StringImpl, g_global_empty16_bit);

ALWAYS_INLINE bool Equal(const char* a, const char16_t* b, size_t length) {
  for (size_t i = 0; i < length; ++i) {
    if (a[i] != b[i])
      return false;
  }
  return true;
}

ALWAYS_INLINE bool Equal(const char16_t* a, const char* b, size_t length) {
  return Equal(b, a, length);
}

template <typename CharType>
ALWAYS_INLINE bool Equal(const CharType* a, const CharType* b, size_t length) {
  return std::equal(a, a + length, b);
}

// Callers need the global empty strings to be non-const.
StringImpl* StringImpl::empty_ = const_cast<StringImpl*>(&g_global_empty);
StringImpl* StringImpl::empty16_bit_ = const_cast<StringImpl*>(&g_global_empty16_bit);

void StringImpl::InitStatics() {
  new ((void*)empty_) StringImpl(kConstructEmptyString);
  new ((void*)empty16_bit_) StringImpl(kConstructEmptyString16Bit);
}

std::shared_ptr<StringImpl> StringImpl::Create(const char* characters, size_t length) {
  if (!characters || !length)
    return empty_shared();

  char* data;
  std::shared_ptr<StringImpl> string = CreateUninitialized(length, data);
  memcpy(data, characters, length * sizeof(char));
  unsigned hash = StringHasher::ComputeHashAndMaskTop8Bits(characters, length);
  string->SetHash(hash);
  return string;
}

std::shared_ptr<StringImpl> StringImpl::Create(const char16_t* characters, size_t length) {
  if (!characters || !length)
    return empty16_shared();

  char16_t* data;
  std::shared_ptr<StringImpl> string = CreateUninitialized(length, data);
  memcpy(data, characters, length * sizeof(char16_t));
  unsigned hash = StringHasher::ComputeHashAndMaskTop8Bits(characters, length);
  string->SetHash(hash);
  return string;
}

std::shared_ptr<StringImpl> StringImpl::CreateUninitialized(size_t length, char*& data) {
  if (!length) {
    data = nullptr;
    return empty_shared();
  }

  // Allocate a single buffer large enough to contain the StringImpl
  // struct as well as the data which it contains. This removes one
  // heap allocation from this call.
  auto* string = static_cast<StringImpl*>(malloc(AllocationSize<char>(length) + 1));
  data = reinterpret_cast<char*>(string + 1);
  return std::shared_ptr<StringImpl>(new (string) StringImpl(length, kForce8BitConstructor));
}

std::shared_ptr<StringImpl> StringImpl::CreateUninitialized(size_t length, char16_t*& data) {
  if (!length) {
    data = nullptr;
    return empty16_shared();
  }

  // Allocate a single buffer large enough to contain the StringImpl
  // struct as well as the data which it contains. This removes one
  // heap allocation from this call.
  StringImpl* string = static_cast<StringImpl*>(malloc(AllocationSize<char16_t>(length) + 1));
  data = reinterpret_cast<char16_t*>(string + 1);

  return std::shared_ptr<StringImpl>(new (string) StringImpl(length));
}

class StringImplAllocator {
 public:
  using ResultStringType = std::shared_ptr<StringImpl>;

  StringImplAllocator(const std::shared_ptr<StringImpl>& original) : original_(original) {}

  template <typename CharType>
  std::shared_ptr<StringImpl> Alloc(size_t length, CharType*& buffer) {
    return StringImpl::CreateUninitialized(length, buffer);
  }

  std::shared_ptr<StringImpl> CoerceOriginal(const StringImpl& string) {
    // Return the original shared_ptr if the StringImpl hasn't changed
    if (&string == original_.get()) {
      return original_;
    }
    // This should not happen in practice
    assert(false);
    return nullptr;
  }

 private:
  std::shared_ptr<StringImpl> original_;
};

std::shared_ptr<StringImpl> StringImpl::LowerASCII(const std::shared_ptr<StringImpl>& str) {
  return ConvertASCIICase(*str, LowerConverter(), StringImplAllocator(str));
}

std::shared_ptr<StringImpl> StringImpl::UpperASCII(const std::shared_ptr<StringImpl>& str) {
  return ConvertASCIICase(*str, UpperConverter(), StringImplAllocator(str));
}

template <typename CharType>
ALWAYS_INLINE std::shared_ptr<StringImpl> StringImpl::RemoveCharacters(const std::shared_ptr<StringImpl>& str,
                                                                       const CharType* characters,
                                                                       CharacterMatchFunctionPtr find_match) {
  const CharType* from = characters;
  const CharType* fromend = from + str->length_;

  // Assume the common case will not remove any characters
  while (from != fromend && !find_match(*from))
    ++from;
  if (from == fromend) {
    // No characters need to be removed, return the original string
    return str;
  }

  StringBuffer<CharType> data(str->length_);
  CharType* to = data.Characters();
  size_t outc = static_cast<size_t>(from - characters);

  if (outc)
    memcpy(to, characters, outc * sizeof(CharType));

  while (true) {
    while (from != fromend && find_match(*from))
      ++from;
    while (from != fromend && !find_match(*from))
      to[outc++] = *from++;
    if (from == fromend)
      break;
  }

  data.Shrink(outc);

  return data.Release();
}

std::shared_ptr<StringImpl> StringImpl::RemoveCharacters(const std::shared_ptr<StringImpl>& str,
                                                         CharacterMatchFunctionPtr find_match) {
  if (str->Is8Bit())
    return RemoveCharacters(str, str->Characters8(), find_match);
  return RemoveCharacters(str, str->Characters16(), find_match);
}

bool StringImpl::IsDigit() const {
  if (Is8Bit()) {
    const char* chars = Characters8();
    for (size_t i = 0; i < length_; i++) {
      if (!::isdigit(chars[i])) {
        return false;
      }
    }
    return true;
  } else {
    const char16_t* chars = Characters16();
    for (size_t i = 0; i < length_; i++) {
      // Check if character is in ASCII digit range
      if (chars[i] < '0' || chars[i] > '9') {
        return false;
      }
    }
    return true;
  }
}

size_t StringImpl::Find(CharacterMatchFunctionPtr match_function, size_t start) {
  if (Is8Bit())
    return internal::Find(Characters8(), length_, match_function, start);
  return internal::Find(Characters16(), length_, match_function, start);
}

bool StringImpl::StartsWith(char character) const {
  return length_ && (*this)[0] == character;
}

bool StringImpl::StartsWith(const std::string_view& prefix) const {
  if (prefix.length() > length())
    return false;
  if (Is8Bit()) {
    return Equal(Characters8(), prefix.data(), prefix.length());
  }
  return Equal(Characters16(), prefix.data(), prefix.length());
}

std::shared_ptr<StringImpl> StringImpl::Substring(const std::shared_ptr<StringImpl>& str,
                                                  size_t start, size_t length) {
  if (start >= str->length_)
    return empty_shared();
  size_t max_length = str->length_ - start;
  if (length >= max_length) {
    if (!start) {
      // Taking the full string, return the original
      return str;
    }
    length = max_length;
  }
  if (str->Is8Bit()) {
    tcb::span<const char> s = str->Span8().subspan(start, length);
    return Create(s.data(), s.size());
  }

  tcb::span<const char16_t> s = str->Span16().subspan(start, length);
  return Create(s.data(), s.size());
}

unsigned int StringImpl::ComputeASCIIFlags() const {
  ASCIIStringAttributes ascii_attributes =
      Is8Bit() ? CharacterAttributes(Characters8(), length()) : CharacterAttributes(Characters16(), length());
  uint32_t new_flags = ASCIIStringAttributesToFlags(ascii_attributes);
  const uint32_t previous_flags = hash_and_flags_.fetch_or(new_flags, std::memory_order_relaxed);
  static constexpr uint32_t mask = kAsciiPropertyCheckDone | kContainsOnlyAscii | kIsLowerAscii;
  DCHECK((previous_flags & mask) == 0 || (previous_flags & mask) == new_flags);
  return new_flags;
}

size_t StringImpl::HashSlowCase() const {
  if (Is8Bit())
    SetHash(StringHasher::ComputeHashAndMaskTop8Bits(Characters8(), length_));
  else
    SetHash(StringHasher::ComputeHashAndMaskTop8Bits(Characters16(), length_));
  return ExistingHash();
}

// Helper function to decode UTF-8 character
static inline uint32_t DecodeUTF8Char(const uint8_t*& p, const uint8_t* end) {
  uint32_t c = *p++;
  
  if (c < 0x80) {
    // ASCII character
    return c;
  }
  
  if ((c & 0xE0) == 0xC0) {
    // 2-byte sequence
    if (p >= end || (*p & 0xC0) != 0x80) return 0xFFFD;
    c = ((c & 0x1F) << 6) | (*p++ & 0x3F);
    if (c < 0x80) return 0xFFFD;  // Overlong encoding
    return c;
  }
  
  if ((c & 0xF0) == 0xE0) {
    // 3-byte sequence
    if (p + 1 >= end || (*p & 0xC0) != 0x80 || (*(p+1) & 0xC0) != 0x80) return 0xFFFD;
    c = ((c & 0x0F) << 12) | ((*p++ & 0x3F) << 6) | (*p++ & 0x3F);
    if (c < 0x800 || (c >= 0xD800 && c <= 0xDFFF)) return 0xFFFD;  // Overlong or surrogate
    return c;
  }
  
  if ((c & 0xF8) == 0xF0) {
    // 4-byte sequence
    if (p + 2 >= end || (*p & 0xC0) != 0x80 || (*(p+1) & 0xC0) != 0x80 || (*(p+2) & 0xC0) != 0x80) return 0xFFFD;
    c = ((c & 0x07) << 18) | ((*p++ & 0x3F) << 12) | ((*p++ & 0x3F) << 6) | (*p++ & 0x3F);
    if (c < 0x10000 || c > 0x10FFFF) return 0xFFFD;  // Overlong or out of range
    return c;
  }
  
  // Invalid UTF-8 sequence
  return 0xFFFD;
}

// Count ASCII characters at the beginning of a UTF-8 string
static inline size_t CountASCII(const uint8_t* p, size_t len) {
  size_t count = 0;
  while (count < len && p[count] < 0x80) {
    count++;
  }
  return count;
}

std::shared_ptr<StringImpl> StringImpl::CreateFromUTF8(const char* utf8_data, size_t byte_length) {
  if (!utf8_data || !byte_length)
    return empty_shared();
  
  const uint8_t* p = reinterpret_cast<const uint8_t*>(utf8_data);
  const uint8_t* end = p + byte_length;
  
  // First, check if it's pure ASCII
  size_t ascii_length = CountASCII(p, byte_length);
  if (ascii_length == byte_length) {
    // Pure ASCII - use 8-bit string
    return Create(utf8_data, byte_length);
  }
  
  // Count characters and check if we need 16-bit
  const uint8_t* scan = p + ascii_length;
  size_t char_count = ascii_length;
  bool needs_16bit = false;
  
  while (scan < end) {
    uint32_t c = DecodeUTF8Char(scan, end);
    if (c >= 0x100) {
      needs_16bit = true;
    }
    if (c > 0xFFFF) {
      // Surrogate pair needed
      char_count += 2;
    } else {
      char_count += 1;
    }
  }
  
  if (!needs_16bit) {
    // All characters fit in 8-bit
    char* data;
    std::shared_ptr<StringImpl> string = CreateUninitialized(char_count, data);
    
    // Copy ASCII portion
    memcpy(data, utf8_data, ascii_length);
    
    // Decode remaining UTF-8
    scan = p + ascii_length;
    size_t i = ascii_length;
    while (scan < end) {
      uint32_t c = DecodeUTF8Char(scan, end);
      data[i++] = static_cast<char>(c);
    }
    data[char_count] = 0;
    
    unsigned hash = StringHasher::ComputeHashAndMaskTop8Bits(data, char_count);
    string->SetHash(hash);
    return string;
  } else {
    // Need 16-bit string
    char16_t* data;
    std::shared_ptr<StringImpl> string = CreateUninitialized(char_count, data);
    
    // Copy ASCII portion
    for (size_t i = 0; i < ascii_length; i++) {
      data[i] = p[i];
    }
    
    // Decode remaining UTF-8
    scan = p + ascii_length;
    size_t i = ascii_length;
    while (scan < end) {
      uint32_t c = DecodeUTF8Char(scan, end);
      if (c > 0xFFFF) {
        // Encode as surrogate pair
        data[i++] = 0xD800 + ((c - 0x10000) >> 10);
        data[i++] = 0xDC00 + ((c - 0x10000) & 0x3FF);
      } else {
        data[i++] = static_cast<char16_t>(c);
      }
    }
    
    unsigned hash = StringHasher::ComputeHashAndMaskTop8Bits(data, char_count);
    string->SetHash(hash);
    return string;
  }
}

}  // namespace webf