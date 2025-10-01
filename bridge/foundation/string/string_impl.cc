/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */
/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-2024 The WebF authors. All rights reserved.
 */

#include "string_impl.h"
#include <algorithm>
#include <cassert>
#include <string>
#include "ascii_fast_path.h"
#include "bindings/qjs/native_string_utils.h"
#include "core/base/strings/string_number_conversions.h"
#include "string_buffer.h"
#include "string_view.h"
#include "utf8_codecs.h"

#ifdef _WIN32
#include <objbase.h>  // For CoTaskMemAlloc and CoTaskMemFree
#endif

namespace webf {

// Platform-specific memory allocation functions
namespace {

inline void* AllocateStringMemory(size_t size) {
#ifdef _WIN32
  return CoTaskMemAlloc(size);
#else
  return malloc(size);
#endif
}

inline void FreeStringMemory(void* ptr) {
#ifdef _WIN32
  CoTaskMemFree(ptr);
#else
  free(ptr);
#endif
}

// Custom deleter for StringImpl objects allocated with platform-specific allocators
struct StringImplDeleter {
  void operator()(StringImpl* ptr) {
    if (ptr) {
      ptr->~StringImpl();  // Call destructor
      FreeStringMemory(ptr);  // Free memory with matching allocator
    }
  }
};

}  // anonymous namespace

DEFINE_GLOBAL(StringImpl, g_global_empty);
DEFINE_GLOBAL(StringImpl, g_global_empty16_bit);

ALWAYS_INLINE bool Equal(const LChar* a, const UChar* b, size_t length) {
  for (size_t i = 0; i < length; ++i) {
    if (a[i] != b[i])
      return false;
  }
  return true;
}

ALWAYS_INLINE bool Equal(const UChar* a, const LChar* b, size_t length) {
  return Equal(b, a, length);
}

template <typename CharType>
ALWAYS_INLINE bool Equal(const CharType* a, const CharType* b, size_t length) {
  return std::equal(a, a + length, b);
}

ALWAYS_INLINE bool Equal(const LChar* a, const StringView& b, size_t length) {
  if (b.Is8Bit()) {
    return Equal(a, b.Characters8(), length);
  }

  return Equal(a, b.Characters16(), length);
}

ALWAYS_INLINE bool Equal(const UChar* a, const StringView& b, size_t length) {
  if (b.Is8Bit()) {
    return Equal(a, b.Characters8(), length);
  }

  return Equal(a, b.Characters16(), length);
}

// Callers need the global empty strings to be non-const.
StringImpl* StringImpl::empty_ = const_cast<StringImpl*>(&g_global_empty);
StringImpl* StringImpl::empty16_bit_ = const_cast<StringImpl*>(&g_global_empty16_bit);

void StringImpl::InitStatics() {
  new ((void*)empty_) StringImpl(kConstructEmptyString);
  new ((void*)empty16_bit_) StringImpl(kConstructEmptyString16Bit);
}

bool StringImpl::ToDouble(double* p) const {
  if (Is8Bit()) {
    auto sv = Latin1StringView(Characters8(), length_);
    auto str = UTF8Codecs::EncodeLatin1(sv);
    return base::StringToDouble(str, p);
  }
  auto sv = UTF16StringView(Characters16(), length_);
  // Avoid relying on the UTF16 overload to prevent link-time undefined symbol.
  // Convert to UTF-8 and use the std::string_view overload instead.
  auto str = UTF8Codecs::EncodeUTF16(sv);
  return base::StringToDouble(str, p);
}

std::shared_ptr<StringImpl> StringImpl::Create(const LChar* characters, size_t length) {
  if (!characters || !length)
    return empty_shared();

  LChar* data;
  std::shared_ptr<StringImpl> string = CreateUninitialized(length, data);
  memcpy(data, characters, length * sizeof(char));
  data[length] = '\0';  // Add null termination
  unsigned hash = StringHasher::ComputeHashAndMaskTop8Bits(characters, length);
  string->SetHash(hash);
  return string;
}

std::shared_ptr<StringImpl> StringImpl::Create(const UChar* characters, size_t length) {
  if (!characters || !length)
    return empty16_shared();

  char16_t* data;
  std::shared_ptr<StringImpl> string = CreateUninitialized(length, data);
  memcpy(data, characters, length * sizeof(char16_t));
  data[length] = '\0';  // Add null termination
  unsigned hash = StringHasher::ComputeHashForWideString(characters, length);
  string->SetHash(hash);
  return string;
}

size_t StringImpl::GetHash() const {
  if (size_t hash = GetHashRaw())
    return hash;
  return HashSlowCase();
}

std::shared_ptr<StringImpl> StringImpl::CreateUninitialized(size_t length, LChar*& data) {
  if (!length) {
    data = nullptr;
    return empty_shared();
  }

  // Allocate a single buffer large enough to contain the StringImpl
  // struct as well as the data which it contains. This removes one
  // heap allocation from this call.
  auto* string = static_cast<StringImpl*>(AllocateStringMemory(AllocationSize<LChar>(length) + 1));
  data = reinterpret_cast<LChar*>(string + 1);
  return std::shared_ptr<StringImpl>(new (string) StringImpl(length, kForce8BitConstructor), StringImplDeleter{});
}

std::shared_ptr<StringImpl> StringImpl::CreateUninitialized(size_t length, UChar*& data) {
  if (!length) {
    data = nullptr;
    return empty16_shared();
  }

  // Allocate a single buffer large enough to contain the StringImpl
  // struct as well as the data which it contains. This removes one
  // heap allocation from this call.
  StringImpl* string = static_cast<StringImpl*>(AllocateStringMemory(AllocationSize<UChar>(length) + sizeof(UChar)));
  data = reinterpret_cast<UChar*>(string + 1);

  return std::shared_ptr<StringImpl>(new (string) StringImpl(length), StringImplDeleter{});
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
    const auto* chars = Characters8();
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

size_t StringImpl::RFind(const StringImpl& str) const {
  size_t str_length = str.length();
  
  if (str_length == 0)
    return length_;
    
  if (str_length > length_)
    return kNotFound;
    
  // Search from the end
  for (size_t i = length_ - str_length + 1; i > 0; --i) {
    bool match = true;
    for (size_t j = 0; j < str_length; ++j) {
      if ((*this)[i - 1 + j] != str[j]) {
        match = false;
        break;
      }
    }
    if (match) {
      return i - 1;
    }
  }
  
  return kNotFound;
}

bool StringImpl::StartsWith(char character) const {
  return length_ && (*this)[0] == character;
}

bool StringImpl::StartsWith(const StringView& prefix) const {
  if (prefix.length() > length())
    return false;
  if (Is8Bit()) {
    return Equal(Characters8(), prefix, prefix.length());
  }
  return Equal(Characters16(), prefix, prefix.length());
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
    tcb::span<const LChar> s = str->Span8().subspan(start, length);
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
    SetHash(StringHasher::ComputeHashForWideString(Characters16(), length_));
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
    uint8_t b1 = *p++;
    uint8_t b2 = *p++;
    c = ((c & 0x0F) << 12) | ((b1 & 0x3F) << 6) | (b2 & 0x3F);
    if (c < 0x800 || (c >= 0xD800 && c <= 0xDFFF)) return 0xFFFD;  // Overlong or surrogate
    return c;
  }
  
  if ((c & 0xF8) == 0xF0) {
    // 4-byte sequence
    if (p + 2 >= end || (*p & 0xC0) != 0x80 || (*(p+1) & 0xC0) != 0x80 || (*(p+2) & 0xC0) != 0x80) return 0xFFFD;
    uint8_t b1 = *p++;
    uint8_t b2 = *p++;
    uint8_t b3 = *p++;
    c = ((c & 0x07) << 18) | ((b1 & 0x3F) << 12) | ((b2 & 0x3F) << 6) | (b3 & 0x3F);
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

std::shared_ptr<StringImpl> StringImpl::CreateFromUTF8(const UTF8Char* utf8_data, size_t byte_length) {
  if (!utf8_data || !byte_length)
    return empty_shared();

  return CreateFromUTF8({utf8_data, byte_length});
}

std::shared_ptr<StringImpl> StringImpl::CreateFromUTF8(const UTF8StringView& string_view) {
  auto byte_length = string_view.length();

  const auto* p = reinterpret_cast<const uint8_t*>(string_view.data());
  const uint8_t* end = p + byte_length;

  // First, check if it's pure ASCII
  size_t ascii_length = CountASCII(p, byte_length);
  if (ascii_length == byte_length) {
    // Pure ASCII - use 8-bit string
    return Create(reinterpret_cast<const LChar*>(string_view.data()), byte_length);
  }

  auto u16 = UTF8Codecs::Decode(string_view);

  if (UTF8Codecs::UTF16IsLatin1(u16)) {
    // All characters fit in 8-bit
    LChar* data;
    std::shared_ptr<StringImpl> string = CreateUninitialized(u16.length(), data);

    // Copy u16 into
    std::ranges::copy(std::as_const(u16), data);

    // Add null termination
    data[u16.length()] = '\0';

    unsigned hash = StringHasher::ComputeHashAndMaskTop8Bits(data, u16.length());
    string->SetHash(hash);
    return string;
  } else {
    // Need 16-bit string
    char16_t* data;
    std::shared_ptr<StringImpl> string = CreateUninitialized(u16.length(), data);

    std::memcpy(data, u16.data(), u16.length() * sizeof(UChar));
    data[u16.length()] = '\0';  // Add null termination

    unsigned hash = StringHasher::ComputeHashForWideString(data, u16.length());
    string->SetHash(hash);
    return string;
  }
}

}  // namespace webf
