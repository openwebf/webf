/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef WEBF_FOUNDATION_STRING_IMPL_H_
#define WEBF_FOUNDATION_STRING_IMPL_H_

#include <cassert>
#include <cinttypes>
#include <memory>
#include "core/base/compiler_specific.h"
#include "core/base/containers/span.h"
#include "core/platform/static_constructors.h"
#include "foundation/ascii_fast_path.h"
#include "foundation/macros.h"
#include "foundation/string_hasher.h"

namespace webf {

class AtomicString;

typedef bool (*CharacterMatchFunctionPtr)(char16_t);

enum TextCaseSensitivity {
  kTextCaseSensitive,
  kTextCaseASCIIInsensitive,

  // Unicode aware case insensitive matching. Non-ASCII characters might match
  // to ASCII characters. This flag is rarely used to implement web platform
  // features.
  kTextCaseUnicodeInsensitive
};

const uint32_t kNotFound = UINT_MAX;

namespace internal {

inline size_t Find(const char* characters, size_t length, unsigned char match_character, size_t index = 0) {
  // Some clients rely on being able to pass index >= length.
  if (index >= length)
    return kNotFound;
  const char* found = static_cast<const char*>(memchr(characters + index, match_character, length - index));
  return found ? static_cast<size_t>(found - characters) : kNotFound;
}

inline size_t Find(const char16_t* characters, size_t length, char16_t match_character, size_t index = 0) {
  while (index < length) {
    if (characters[index] == match_character)
      return index;
    ++index;
  }
  return kNotFound;
}

inline size_t Find(const char* characters, size_t length, CharacterMatchFunctionPtr match_function, size_t index = 0) {
  while (index < length) {
    if (match_function(characters[index]))
      return index;
    ++index;
  }
  return kNotFound;
}

inline size_t Find(const char16_t* characters,
                   size_t length,
                   CharacterMatchFunctionPtr match_function,
                   size_t index = 0) {
  while (index < length) {
    if (match_function(characters[index]))
      return index;
    ++index;
  }
  return kNotFound;
}

}  // namespace internal

class StringImpl : public std::enable_shared_from_this<StringImpl> {
 public:
  struct StringImplHasher {
    size_t operator()(const std::shared_ptr<StringImpl>& string_impl) const {
      return string_impl->GetHash();
    }
  };

  // Custom equality function
  struct StringImplEqual {
    bool operator()(const std::shared_ptr<StringImpl>& lhs, const std::shared_ptr<StringImpl>& rhs) const {
      return lhs->GetHash() == rhs->GetHash();
    }
  };

  static inline constexpr uint32_t LengthToAsciiFlags(int length) {
    return length ? 0 : kAsciiPropertyCheckDone | kContainsOnlyAscii | kIsLowerAscii;
  }

  static inline uint32_t ASCIIStringAttributesToFlags(ASCIIStringAttributes ascii_attributes) {
    uint32_t flags = kAsciiPropertyCheckDone;
    if (ascii_attributes.contains_only_ascii)
      flags |= kContainsOnlyAscii;
    if (ascii_attributes.is_lower_ascii)
      flags |= kIsLowerAscii;
    return flags;
  }

  // Used to construct static strings, which have a special ref_count_ that can
  // never hit zero. This means that the static string will never be destroyed.
  enum ConstructEmptyStringTag { kConstructEmptyString };

  explicit StringImpl(ConstructEmptyStringTag)
      : length_(0),
        hash_and_flags_(kAsciiPropertyCheckDone | kContainsOnlyAscii | kIsLowerAscii | kIs8Bit | kIsStatic) {}

  enum ConstructEmptyString16BitTag { kConstructEmptyString16Bit };
  explicit StringImpl(ConstructEmptyString16BitTag)
      : length_(0), hash_and_flags_(kAsciiPropertyCheckDone | kContainsOnlyAscii | kIsLowerAscii | kIsStatic) {}

  enum Force8Bit { kForce8BitConstructor };
  StringImpl(size_t length, Force8Bit) : length_(length), hash_and_flags_(LengthToAsciiFlags(length) | kIs8Bit) {
    DCHECK(length_);
  }

  StringImpl(size_t length) : length_(length), hash_and_flags_(LengthToAsciiFlags(length)) { DCHECK(length_); }

  enum StaticStringTag { kStaticString };
  StringImpl(size_t length, size_t hash, StaticStringTag)
      : length_(length), hash_and_flags_(hash << kHashShift | LengthToAsciiFlags(length) | kIs8Bit | kIsStatic) {}

  static StringImpl* empty_;
  static StringImpl* empty16_bit_;

  ALWAYS_INLINE static std::shared_ptr<StringImpl> empty_shared() {
    return std::shared_ptr<StringImpl>(empty_, [](StringImpl*) {});
  }
  ALWAYS_INLINE static std::shared_ptr<StringImpl> empty16_shared() {
    return std::shared_ptr<StringImpl>(empty16_bit_, [](StringImpl*) {});
  }

  size_t length() const { return length_; }
  bool Is8Bit() const { return hash_and_flags_.load(std::memory_order_relaxed) & kIs8Bit; }

  static std::shared_ptr<StringImpl> Create(const char*, size_t length);
  static std::shared_ptr<StringImpl> Create(const char16_t*, size_t length);

  static void InitStatics();

  // Hash value is 24 bits.
  constexpr static int kHashShift = (sizeof(unsigned) * 8) - 24;

  unsigned GetHashRaw() const { return hash_and_flags_.load(std::memory_order_relaxed) >> kHashShift; }

  size_t GetHash() const {
    if (size_t hash = GetHashRaw())
      return hash;
    return HashSlowCase();
  }

  char16_t operator[](size_t i) const {
    DCHECK(i < length_);
    if (Is8Bit())
      return Characters8()[i];
    return Characters16()[i];
  }

  template <typename CharType>
  static size_t AllocationSize(size_t length) {
    return sizeof(StringImpl) + length * sizeof(CharType);
  }

  ALWAYS_INLINE const char* Characters8() const {
    DCHECK(Is8Bit());
    return reinterpret_cast<const char*>(this + 1);
  }
  ALWAYS_INLINE const char16_t* Characters16() const {
    DCHECK(!Is8Bit());
    return reinterpret_cast<const char16_t*>(this + 1);
  }
  ALWAYS_INLINE tcb::span<const char> Span8() const {
    DCHECK(Is8Bit());
    return {reinterpret_cast<const char*>(this + 1), length_};
  }
  ALWAYS_INLINE tcb::span<const char16_t> Span16() const {
    DCHECK(!Is8Bit());
    return {reinterpret_cast<const char16_t*>(this + 1), length_};
  }
  ALWAYS_INLINE const void* Bytes() const { return reinterpret_cast<const void*>(this + 1); }

  template <typename CharType>
  ALWAYS_INLINE const CharType* GetCharacters() const;

  static std::shared_ptr<StringImpl> CreateUninitialized(size_t length, char*& data);
  static std::shared_ptr<StringImpl> CreateUninitialized(size_t length, char16_t*& data);

  std::shared_ptr<StringImpl> LowerASCII();
  std::shared_ptr<StringImpl> UpperASCII();
  std::shared_ptr<StringImpl> RemoveCharacters(CharacterMatchFunctionPtr);
  template <typename CharType>
  ALWAYS_INLINE std::shared_ptr<StringImpl> RemoveCharacters(const CharType* characters, CharacterMatchFunctionPtr);

  bool ContainsOnlyASCIIOrEmpty() const;

  bool IsLowerASCII() const;
  bool IsDigit() const;

  // Find characters.
  size_t Find(unsigned char character, size_t start = 0);
  size_t Find(char character, size_t start = 0);
  size_t Find(char16_t character, size_t start = 0);
  size_t Find(CharacterMatchFunctionPtr, size_t index = 0);
  //  size_t Find(base::RepeatingCallback<bool(UChar)> match_callback,
  //                  wtf_size_t index = 0) const;

  // Find substrings.
  size_t Find(const AtomicString&, size_t index = 0);

  bool StartsWith(char16_t) const;
  bool StartsWith(const AtomicString&) const;

  bool EndsWith(char16_t) const;
  bool EndsWith(const AtomicString&) const;

  std::shared_ptr<StringImpl> Substring(size_t pos, size_t len = UINT_MAX) const;

  // The high bits of 'hash' are always empty, but we prefer to store our
  // flags in the low bits because it makes them slightly more efficient to
  // access.  So, we shift left and right when setting and getting our hash
  // code.
  void SetHash(size_t hash) const {
    // Multiple clients assume that StringHasher is the canonical string
    // hash function.
    DCHECK(hash == (Is8Bit() ? StringHasher::ComputeHashAndMaskTop8Bits(Characters8(), length_)
                             : StringHasher::ComputeHashAndMaskTop8Bits(Characters16(), length_)));
    DCHECK(hash);  // Verify that 0 is a valid sentinel hash value.
    SetHashRaw(hash);
  }

  void SetHashRaw(unsigned hash_val) const {
    // Setting the hash is idempotent so fetch_or() is sufficient. DCHECK()
    // as a sanity check.
    unsigned previous_value = hash_and_flags_.fetch_or(hash_val << kHashShift, std::memory_order_relaxed);
    DCHECK(((previous_value >> kHashShift) == 0) || ((previous_value >> kHashShift) == hash_val));
  }

  bool HasHash() const { return GetHashRaw() != 0; }
  size_t ExistingHash() const {
    DCHECK(HasHash());
    return GetHashRaw();
  }

  // Calculates the kContainsOnlyAscii and kIsLowerAscii flags. Returns
  // a bitfield with those 2 values.
  unsigned ComputeASCIIFlags() const;

 private:
  size_t HashSlowCase() const;

  enum Flags {
    // These two fields are never modified for the lifetime of the StringImpl.
    // It is therefore safe to read them with a relaxed operation.
    kIs8Bit = 1 << 0,
    kIsStatic = 1 << 1,

    // This is the only flag that can be both set and unset. It is safe to do
    // so because all accesses are mediated by the same atomic string table and
    // so protected by a mutex. Thus these accesses can also be relaxed.
    kIsAtomic = 1 << 2,

    // These bits are set atomically together. They are initially all
    // zero, and like the hash computation below, become non-zero only as part
    // of a single atomic bitwise or. Thus concurrent loads will always observe
    // either a state where the ASCII property check has not been completed and
    // all bits are zero, or a state where the state is fully populated.
    //
    // The reason kIsLowerAscii is cached but upper ascii is not is that
    // DOM attributes APIs require a lowercasing check making it fairly hot.
    kAsciiPropertyCheckDone = 1 << 3,
    kContainsOnlyAscii = 1 << 4,
    kIsLowerAscii = 1 << 5,

    // The last 24 bits (past kHashShift) are reserved for the hash.
    // These bits are all zero if the hash is uncomputed, and the hash is
    // atomically stored with bitwise or.
    //
    // Therefore a relaxed read can be used, and will either observe an
    // uncomputed hash (if the fetch_or is not yet visible on this thread)
    // or the correct hash (if it is). It is possible for a thread to compute
    // the hash for a second time if there is a race. This is safe, since
    // storing the same bits again with a bitwise or is idempotent.
  };

  size_t length_;
  mutable std::atomic<uint32_t> hash_and_flags_;
};

inline size_t StringImpl::Find(unsigned char character, size_t start) {
  if (Is8Bit())
    return internal::Find(Characters8(), length_, character, start);
  return internal::Find(Characters16(), length_, character, start);
}

ALWAYS_INLINE size_t StringImpl::Find(char character, size_t start) {
  return Find(static_cast<unsigned char>(character), start);
}

inline size_t StringImpl::Find(char16_t character, size_t start) {
  if (Is8Bit())
    return internal::Find(Characters8(), length_, character, start);
  return internal::Find(Characters16(), length_, character, start);
}

template <>
ALWAYS_INLINE const char* StringImpl::GetCharacters<char>() const {
  return Characters8();
}

template <>
ALWAYS_INLINE const char16_t* StringImpl::GetCharacters<char16_t>() const {
  return Characters16();
}

ALWAYS_INLINE bool StringImpl::IsLowerASCII() const {
  uint32_t flags = hash_and_flags_.load(std::memory_order_relaxed);
  if (flags & kAsciiPropertyCheckDone)
    return flags & kIsLowerAscii;
  return ComputeASCIIFlags() & kIsLowerAscii;
}


ALWAYS_INLINE bool StringImpl::ContainsOnlyASCIIOrEmpty() const {
  uint32_t flags = hash_and_flags_.load(std::memory_order_relaxed);
  if (flags & kAsciiPropertyCheckDone)
    return flags & kContainsOnlyAscii;
  return ComputeASCIIFlags() & kContainsOnlyAscii;
}



}  // namespace webf

#endif  // WEBF_FOUNDATION_STRING_IMPL_H_
