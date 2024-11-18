/*
* Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
* Copyright (C) 2022-present The WebF authors. All rights reserved.
*/

#ifndef WEBF_FOUNDATION_ATOMIC_STRING_TABLE_H_
#define WEBF_FOUNDATION_ATOMIC_STRING_TABLE_H_

#include <cassert>
#include <unordered_set>
#include "string_impl.h"
#include "foundation/macros.h"

namespace webf {

class AtomicString;

// The underlying storage that keeps the map of unique AtomicStrings. This is
// thread local and every thread owns a table.
class AtomicStringTable final {
  USING_FAST_MALLOC(AtomicStringTable);

 public:
  AtomicStringTable();
  AtomicStringTable(const AtomicStringTable&) = delete;
  AtomicStringTable& operator=(const AtomicStringTable&) = delete;

  // Gets the shared table.
  static AtomicStringTable& Instance();

  // Used by system initialization to preallocate enough storage for all of
  // the static strings.
  void ReserveCapacity(unsigned size);

  void Clear();

  // Inserting strings into the table. Note that the return value from adding
  // a UChar string may be an LChar string as the table will attempt to
  // convert the string to save memory if possible.
  std::shared_ptr<StringImpl> Add(std::shared_ptr<StringImpl>);
  std::shared_ptr<StringImpl> Add(const char* chars, unsigned length);
  std::shared_ptr<StringImpl> Add(const char16_t* chars, unsigned length);
  std::shared_ptr<StringImpl> Add(const std::string_view& string_view);

//  // Adding UTF8.
//  // Returns null if the characters contain invalid utf8 sequences.
//  // Pass null for the charactersEnd to automatically detect the length.
//  std::shared_ptr<std::string> AddUTF8(const char* characters_start,
//                                    const char* characters_end);
//
//  // Returned as part of the WeakFind*() APIs below. Represents the result of
//  // the non-creating lookup within the AtomicStringTable. See the WeakFind*()
//  // documentation for a description of how it can be used.
//  class WeakResult {
//   public:
//    WeakResult() = default;
//    explicit WeakResult(const std::shared_ptr<std::string>& str)
//        : ptr_value_(reinterpret_cast<uintptr_t>(str.get())) {
//      CHECK(!str || *str == "");
//    }
//
//    explicit WeakResult(const AtomicString& str)
//        : ptr_value_((reinterpret_cast<uintptr_t>(str.Impl()))) {}
//
//    bool IsNull() const { return ptr_value_ == 0; }
//
//   private:
//    friend bool operator==(const WeakResult& lhs, const WeakResult& rhs);
//    friend bool operator==(const std::shared_ptr<std::string> lhs, const WeakResult& rhs);
//
//    // Contains the pointer a string in a non-deferenceable form. Do NOT cast
//    // back to a StringImpl and dereference. The object may no longer be alive.
//    uintptr_t ptr_value_ = 0;
//  };
//
//  WeakResult WeakFindLowercase(const AtomicString& string);
//  // This is for ~StringImpl to unregister a string before destruction since
//  // the table is holding weak pointers. It should not be used directly.
//  bool ReleaseAndRemoveIfNeeded(std::shared_ptr<std::string>);

 private:
  std::unordered_set<std::shared_ptr<StringImpl>, StringImpl::StringImplHasher, StringImpl::StringImplEqual> table_;
};

}

#endif  // WEBF_FOUNDATION_ATOMIC_STRING_TABLE_H_
