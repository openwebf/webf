//
// Created by 谢作兵 on 12/06/24.
//

#ifndef WEBF_STRING_BUILDER_H
#define WEBF_STRING_BUILDER_H

#include <unicode/utf16.h>

#include "bindings/qjs/atomic_string.h"
#include "foundation/string_view.h"
#include "foundation/webf_malloc.h"
#include "core/platform/text/integer_to_string_conversion.h"

namespace webf {


class StringBuilder {
  USING_FAST_MALLOC(StringBuilder);

 public:
  StringBuilder() : no_buffer_() {}
  StringBuilder(const StringBuilder&) = delete;
  StringBuilder& operator=(const StringBuilder&) = delete;
  ~StringBuilder() { ClearBuffer(); }

  bool DoesAppendCauseOverflow(unsigned length) const;

  void Append(const char16_t *, unsigned length);
  void Append(const unsigned char*, unsigned length);

  inline void Append(const char* characters, unsigned length) {
    Append(reinterpret_cast<const unsigned char*>(characters), length);
  }

  void Append(const StringBuilder& other) {
    if (!other.length_)
      return;

    if (!length_ && !HasBuffer() && !other.string_.IsNull()) {
      string_ = other.string_;
      length_ = other.string_.length();
      is_8bit_ = other.string_.Is8Bit();
      return;
    }

    if (other.Is8Bit())
      Append(other.Characters8(), other.length_);
    else
      Append(other.Characters16(), other.length_);
  }

  // NOTE: The semantics of this are different than StringView(..., offset,
  // length) in that an invalid offset or invalid length is a no-op instead of
  // an error.
  // TODO(esprehn): We should probably unify the semantics instead.
  void Append(const StringView& string, unsigned offset, unsigned length) {
    unsigned extent = offset + length;
    if (extent < offset || extent > string.length())
      return;

    // We can't do this before the above check since StringView's constructor
    // doesn't accept invalid offsets or lengths.
    Append(StringView(string, offset, length));
  }

  void Append(const StringView& string) {
    if (string.Empty())
      return;

    // If we're appending to an empty builder, and there is not a buffer
    // (reserveCapacity has not been called), then share the impl if
    // possible.
    //
    // This is important to avoid string copies inside dom operations like
    // Node::textContent when there's only a single Text node child, or
    // inside the parser in the common case when flushing buffered text to
    // a Text node.
    AtomicString impl = AtomicString();
    if (!length_ && !HasBuffer()) {
      string_ = impl;
      length_ = impl.length();
      is_8bit_ = impl.Is8Bit();
      return;
    }

    if (string.Is8Bit())
      Append(string.Characters8(), string.length());
    else
      Append(string.Characters16(), string.length());
  }

  void Append(char16_t c) {
    if (is_8bit_ && c <= 0xFF) {
      Append(static_cast<unsigned char>(c));
      return;
    }
    EnsureBuffer16(1);
    buffer16_.push_back(c);
    ++length_;
  }

  void Append( unsigned char c) {
    if (!is_8bit_) {
      Append(static_cast<char16_t>(c));
      return;
    }
    EnsureBuffer8(1);
    buffer8_.push_back(c);
    ++length_;
  }

  void Append(char c) { Append(static_cast< unsigned char>(c)); }

  void Append(int32_t c) {
    if (U_IS_BMP(c)) {
      Append(static_cast<char16_t>(c));
      return;
    }
    Append(U16_LEAD(c));
    Append(U16_TRAIL(c));
  }

  template <typename IntegerType>
  void AppendNumber(IntegerType number) {
    IntegerToStringConverter<IntegerType> converter(number);
    Append(converter.Characters8(), converter.length());
  }

  void AppendNumber(bool);

  void AppendNumber(float);

  void AppendNumber(double, unsigned precision = 6);

  // Like WTF::String::Format, supports Latin-1 only.
  //  PRINTF_FORMAT(2, 3)
  void AppendFormat(const char* format, ...);

  void erase(unsigned);

  // ReleaseString is similar to ToString but releases the string_ object
  // to the caller, preventing refcount trashing. Prefer it over ToString()
  // if the StringBuilder is going to be destroyed or cleared afterwards.
  AtomicString ReleaseString();
  AtomicString ToString();
  AtomicString ToAtomicString();
  AtomicString Substring(unsigned start, unsigned length) const;
  StringView SubstringView(unsigned start, unsigned length) const;

  operator StringView() const {
    if (Is8Bit()) {
      return StringView(Characters8(), length());
    } else {
      return StringView(Characters16(), length());
    }
  }

  unsigned length() const { return length_; }
  bool empty() const { return !length_; }

  unsigned Capacity() const;
  // Increase the capacity of the backing buffer to at least |new_capacity|. The
  // behavior is the same as |Vector::ReserveCapacity|:
  // * Increase the capacity even when there are existing characters or a
  //   capacity.
  // * The characters in the backing buffer are not affected.
  // * This function does not shrink the size of the backing buffer, even if
  //   |new_capacity| is small.
  // * This function may cause a reallocation.
  void ReserveCapacity(unsigned new_capacity);
  // This is analogous to |Ensure16Bit| and |ReserveCapacity|, but can avoid
  // double reallocations when the current buffer is 8 bits and is smaller than
  // |new_capacity|.
  void Reserve16BitCapacity(unsigned new_capacity);

  // TODO(esprehn): Rename to shrink().
  void Resize(unsigned new_size);

  char16_t operator[](unsigned i) const {
    assert(i < length_);
    if (is_8bit_)
      return Characters8()[i];
    return Characters16()[i];
  }

  const unsigned char* Characters8() const {
    assert(is_8bit_);
    if (!length())
      return nullptr;
    if (!string_.IsNull())
      return string_.Character8();
    assert(has_buffer_);
    return buffer8_.data();
  }

  const char16_t* Characters16() const {
    assert(!is_8bit_);
    if (!length())
      return nullptr;
    if (!string_.IsNull())
      return reinterpret_cast<const char16_t*>(string_.Character16());
    assert(has_buffer_);
    return buffer16_.data();
  }

  bool Is8Bit() const { return is_8bit_; }
  void Ensure16Bit();

  void Clear();
  void Swap(StringBuilder&);
  uint32_t HexToUIntStrict(bool* ok);

 private:
  static const unsigned kInlineBufferSize = 16;
  static unsigned InitialBufferSize() { return kInlineBufferSize; }

  typedef std::vector< unsigned char> Buffer8;
  typedef std::vector<char16_t> Buffer16;

  void EnsureBuffer8(unsigned added_size) {
    assert(is_8bit_);
    if (!HasBuffer())
      CreateBuffer8(added_size);
  }

  void EnsureBuffer16(unsigned added_size) {
    if (is_8bit_ || !HasBuffer())
      CreateBuffer16(added_size);
  }

  void CreateBuffer8(unsigned added_size);
  void CreateBuffer16(unsigned added_size);
  void ClearBuffer();
  bool HasBuffer() const { return has_buffer_; }

  template <typename StringType>
  void BuildString() {
    if (is_8bit_)
      string_ = StringType(Characters8(), length_);
    else
      string_ = StringType(Characters16(), length_);
    ClearBuffer();
  }

  AtomicString string_;
  union {
    char no_buffer_;
    Buffer8 buffer8_;
    Buffer16 buffer16_;
  };
  unsigned length_ = 0;
  bool is_8bit_ = true;
  bool has_buffer_ = false;
};

template <typename CharType>
bool Equal(const StringBuilder& s, const CharType* buffer, unsigned length) {
  if (s.length() != length)
    return false;

  if (s.Is8Bit())
    return Equal(s.Characters8(), buffer, length);

  return Equal(s.Characters16(), buffer, length);
}

//template <typename CharType>
//bool DeprecatedEqualIgnoringCase(const StringBuilder& s,
//                                 const CharType* buffer,
//                                 unsigned length) {
//  if (s.length() != length)
//    return false;
//
//  if (s.Is8Bit())
//    return DeprecatedEqualIgnoringCase(s.Characters8(), buffer, length);
//
//  return DeprecatedEqualIgnoringCase(s.Characters16(), buffer, length);
//}

// Unicode aware case insensitive string matching. Non-ASCII characters might
// match to ASCII characters. This function is rarely used to implement web
// platform features.
// This function is deprecated. We should introduce EqualIgnoringASCIICase() or
// EqualIgnoringUnicodeCase(). See crbug.com/627682
//inline bool DeprecatedEqualIgnoringCase(const StringBuilder& s,
//                                        const char* string) {
//  return DeprecatedEqualIgnoringCase(
//      s, reinterpret_cast<const unsigned char*>(string),
//      static_cast<uint32_t>(strlen(string)));
//}
//
//template <typename StringType>
//bool Equal(const StringBuilder& a, const StringType& b) {
//  if (a.length() != b.length())
//    return false;
//
//  if (!a.length())
//    return true;
//
//  if (a.Is8Bit()) {
//    if (b.Is8Bit())
//      return Equal(a.Characters8(), b.Characters8(), a.length());
//    return Equal(a.Characters8(), b.Characters16(), a.length());
//  }
//
//  if (b.Is8Bit())
//    return Equal(a.Characters16(), b.Characters8(), a.length());
//  return Equal(a.Characters16(), b.Characters16(), a.length());
//}

//inline bool operator==(const StringBuilder& a, const StringBuilder& b) {
//  return Equal(a, b);
//}
//inline bool operator!=(const StringBuilder& a, const StringBuilder& b) {
//  return !Equal(a, b);
//}
//inline bool operator==(const StringBuilder& a, const String& b) {
//  return Equal(a, b);
//}
//inline bool operator!=(const StringBuilder& a, const String& b) {
//  return !Equal(a, b);
//}
//inline bool operator==(const String& a, const StringBuilder& b) {
//  return Equal(b, a);
//}
//inline bool operator!=(const String& a, const StringBuilder& b) {
//  return !Equal(b, a);
//}

}  // namespace webf

#endif  // WEBF_STRING_BUILDER_