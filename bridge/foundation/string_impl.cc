/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include <string>
#include <algorithm>
#include "ascii_fast_path.h"
#include "string_impl.h"
#include "string_buffer.h"

namespace webf {

DEFINE_GLOBAL(StringImpl, g_global_empty);
DEFINE_GLOBAL(StringImpl, g_global_empty16_bit);

// Callers need the global empty strings to be non-const.
StringImpl* StringImpl::empty_ = const_cast<StringImpl*>(&g_global_empty);
StringImpl* StringImpl::empty16_bit_ =
    const_cast<StringImpl*>(&g_global_empty16_bit);

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
  return string;
}

std::shared_ptr<StringImpl> StringImpl::Create(const char16_t* characters, size_t length) {
  if (!characters || !length)
    return empty_shared();

  char16_t* data;
  std::shared_ptr<StringImpl> string = CreateUninitialized(length, data);
  memcpy(data, characters, length * sizeof(char16_t));
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
  auto* string = static_cast<StringImpl*>(malloc(sizeof(char) * length));
  data = reinterpret_cast<char*>(string + 1);
  return std::shared_ptr<StringImpl>(new (string) StringImpl(length, kForce8BitConstructor));
}

std::shared_ptr<StringImpl> StringImpl::CreateUninitialized(size_t length, char16_t*& data) {
  if (!length) {
    data = nullptr;
    return empty_shared();
  }

  // Allocate a single buffer large enough to contain the StringImpl
  // struct as well as the data which it contains. This removes one
  // heap allocation from this call.
  StringImpl* string = static_cast<StringImpl*>(malloc(sizeof(char16_t) *length));
  data = reinterpret_cast<char16_t*>(string + 1);

  return std::shared_ptr<StringImpl>(new (string) StringImpl(length));
}

class StringImplAllocator {
 public:
  using ResultStringType = std::shared_ptr<StringImpl>;

  template <typename CharType>
  std::shared_ptr<StringImpl> Alloc(size_t length, CharType*& buffer) {
    return StringImpl::CreateUninitialized(length, buffer);
  }

  std::shared_ptr<StringImpl> CoerceOriginal(const StringImpl& string) {
    return std::shared_ptr<StringImpl>(const_cast<StringImpl*>(&string));
  }
};

std::shared_ptr<StringImpl> StringImpl::LowerASCII() {
  return ConvertASCIICase(*this, LowerConverter(), StringImplAllocator());
}

std::shared_ptr<StringImpl> StringImpl::UpperASCII() {
  return ConvertASCIICase(*this, UpperConverter(), StringImplAllocator());
}


template <typename CharType>
ALWAYS_INLINE std::shared_ptr<StringImpl> StringImpl::RemoveCharacters(
    const CharType* characters,
    CharacterMatchFunctionPtr find_match) {
  const CharType* from = characters;
  const CharType* fromend = from + length_;

  // Assume the common case will not remove any characters
  while (from != fromend && !find_match(*from))
    ++from;
  if (from == fromend)
    return shared_from_this();

  StringBuffer<CharType> data(length_);
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

std::shared_ptr<StringImpl> StringImpl::RemoveCharacters(
    CharacterMatchFunctionPtr find_match) {
  if (Is8Bit())
    return RemoveCharacters(Characters8(), find_match);
  return RemoveCharacters(Characters16(), find_match);
}


bool StringImpl::IsDigit() const {
  std::string str = std::string(Characters8());
  return std::all_of(str.begin(), str.end(), ::isdigit);
}

size_t StringImpl::Find(CharacterMatchFunctionPtr match_function,
                        size_t start) {
  if (Is8Bit())
    return internal::Find(Characters8(), length_, match_function, start);
  return internal::Find(Characters16(), length_, match_function, start);
}

std::shared_ptr<StringImpl> StringImpl::Substring(size_t start,
                                                  size_t length) const {
  if (start >= length_)
    return empty_shared();
  size_t max_length = length_ - start;
  if (length >= max_length) {
    // RefPtr has trouble dealing with const arguments. It should be updated
    // so this const_cast is not necessary.
    if (!start)
      return std::const_pointer_cast<StringImpl>(shared_from_this());
    length = max_length;
  }
  if (Is8Bit()) {
    tcb::span<const char> s = Span8().subspan(start, length);
    return Create(s.data(), s.size());
  }

  tcb::span<const char16_t> s = Span16().subspan(start, length);
  return Create(s.data(), s.size());
}


unsigned int StringImpl::ComputeASCIIFlags() const {
  ASCIIStringAttributes ascii_attributes =
      Is8Bit() ? CharacterAttributes(Characters8(), length())
               : CharacterAttributes(Characters16(), length());
  uint32_t new_flags = ASCIIStringAttributesToFlags(ascii_attributes);
  const uint32_t previous_flags =
      hash_and_flags_.fetch_or(new_flags, std::memory_order_relaxed);
  static constexpr uint32_t mask =
      kAsciiPropertyCheckDone | kContainsOnlyAscii | kIsLowerAscii;
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

}  // namespace webf