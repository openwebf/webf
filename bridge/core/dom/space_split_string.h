/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef WEBF_CORE_DOM_SPACE_SPLIT_STRING_H_
#define WEBF_CORE_DOM_SPACE_SPLIT_STRING_H_

#include <unordered_map>
#include <vector>
#include "foundation/atomic_string.h"

namespace webf {

class SpaceSplitString {
 public:
  SpaceSplitString() = default;
  explicit SpaceSplitString(const AtomicString& string) { Set(string); };
  SpaceSplitString(const SpaceSplitString& other) : data_(other.data_) {}
  SpaceSplitString(SpaceSplitString&&) = default;
  ~SpaceSplitString() = default;

  bool operator!=(const SpaceSplitString& other) const { return data_ != other.data_; }

  void Set(const AtomicString& value);
  void Clear();

  bool Contains(const AtomicString& string) const { return data_ && data_->Contains(string); }

  bool ContainsAll(const SpaceSplitString& names) const {
    return !names.data_ || (data_ && data_->ContainsAll(*names.data_));
  }

  void Add(const AtomicString&);
  bool Remove(const AtomicString&);
  void Remove(size_t index);
  void ReplaceAt(size_t index, const AtomicString&);

  // https://dom.spec.whatwg.org/#concept-ordered-set-serializer
  // The ordered set serializer takes a set and returns the concatenation of the
  // strings in set, separated from each other by U+0020, if set is non-empty,
  // and the empty string otherwise.
  AtomicString SerializeToString() const;

  size_t size() const { return data_ ? data_->size() : 0; }
  bool IsNull() const { return !data_; }
  const AtomicString& operator[](size_t i) const { return (*data_)[i]; }

  // Provide begin and end functions
  std::vector<AtomicString>::iterator begin() { return data_->vector_.begin(); }

  std::vector<AtomicString>::iterator end() { return data_->vector_.end(); }

  [[nodiscard]] std::vector<AtomicString>::const_iterator begin() const { return data_->vector_.begin(); }

  [[nodiscard]] std::vector<AtomicString>::const_iterator end() const { return data_->vector_.end(); }

 private:
  class Data {
   public:
    explicit Data(const AtomicString&);
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
    void CreateVector(const AtomicString&);
    template <typename CharacterType>
    inline void CreateVector(const AtomicString&, const CharacterType*, unsigned);

    AtomicString key_string_;

   public:
    std::vector<AtomicString> vector_;
  };

  static std::unordered_map<JSAtom, Data*>& SharedDataMap();
  void EnsureShared() {
    if (data_ != nullptr) {
      data_ = std::make_shared<Data>(*data_);
    }
  }

  std::shared_ptr<Data> data_ = nullptr;
};

}  // namespace webf

#endif  // WEBF_CORE_DOM_SPACE_SPLIT_STRING_H_
