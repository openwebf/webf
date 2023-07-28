/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef WEBF_CORE_DOM_SPACE_SPLIT_STRING_H_
#define WEBF_CORE_DOM_SPACE_SPLIT_STRING_H_

#include <unordered_map>
#include <vector>
#include "bindings/qjs/atomic_string.h"

namespace webf {

template <typename CharType>
inline bool IsHTMLSpace(CharType character) {
  // Histogram from Apple's page load test combined with some ad hoc browsing
  // some other test suites.
  //
  //     82%: 216330 non-space characters, all > U+0020
  //     11%:  30017 plain space characters, U+0020
  //      5%:  12099 newline characters, U+000A
  //      2%:   5346 tab characters, U+0009
  //
  // No other characters seen. No U+000C or U+000D, and no other control
  // characters. Accordingly, we check for non-spaces first, then space, then
  // newline, then tab, then the other characters.
  return character <= ' ' &&
         (character == ' ' || character == '\n' || character == '\t' || character == '\r' || character == '\f');
}

template <typename CharType>
inline bool IsNotHTMLSpace(CharType character) {
  return !IsHTMLSpace<CharType>(character);
}

class SpaceSplitString {
 public:
  SpaceSplitString() = default;
  explicit SpaceSplitString(JSContext* ctx, const AtomicString& string) { Set(ctx, string); };

  bool operator!=(const SpaceSplitString& other) const { return data_ != other.data_; }

  void Set(JSContext* ctx, const AtomicString& value);
  void Clear();

  bool Contains(const AtomicString& string) const { return data_ && data_->Contains(string); }

  bool ContainsAll(const SpaceSplitString& names) const {
    return !names.data_ || (data_ && data_->ContainsAll(*names.data_));
  }

  void Add(JSContext* ctx, const AtomicString&);
  bool Remove(const AtomicString&);
  void Remove(size_t index);
  void ReplaceAt(size_t index, const AtomicString&);

  // https://dom.spec.whatwg.org/#concept-ordered-set-serializer
  // The ordered set serializer takes a set and returns the concatenation of the
  // strings in set, separated from each other by U+0020, if set is non-empty,
  // and the empty string otherwise.
  AtomicString SerializeToString(JSContext* ctx) const;

  size_t size() const { return data_ ? data_->size() : 0; }
  bool IsNull() const { return !data_; }
  const AtomicString& operator[](size_t i) const { return (*data_)[i]; }

 private:
  class Data {
   public:
    explicit Data(JSContext* ctx, const AtomicString&);
    explicit Data(const Data&);
    bool Contains(const AtomicString& string) const {
      return std::find(vector_.begin(), vector_.end(), string) != vector_.end();
    }

    bool ContainsAll(Data&);

    void Add(const AtomicString&);
    void Remove(unsigned index);

    bool IsUnique() const { return key_string_.IsNull(); }
    size_t size() const { return vector_.size(); }
    const AtomicString& operator[](size_t i) const { return vector_[i]; }
    AtomicString& operator[](size_t i) { return vector_[i]; }

   private:
    void CreateVector(JSContext* ctx, const AtomicString&);
    template <typename CharacterType>
    inline void CreateVector(JSContext* ctx, const AtomicString&, const CharacterType*, unsigned);

    AtomicString key_string_;
    std::vector<AtomicString> vector_;
  };

  static std::unordered_map<JSAtom, Data*>& SharedDataMap();
  void EnsureUnique() {
    if (data_ != nullptr) {
      data_ = std::make_unique<Data>(*data_);
    }
  }

  std::unique_ptr<Data> data_ = nullptr;
};

}  // namespace webf

#endif  // WEBF_CORE_DOM_SPACE_SPLIT_STRING_H_
