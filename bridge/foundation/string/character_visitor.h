// Copyright 2020 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#ifndef WEBF_FOUNDATION_STRING_CHARACTER_VISITOR_H_
#define WEBF_FOUNDATION_STRING_CHARACTER_VISITOR_H_

namespace webf {

// Visits the characters of a String, AtomicString, StringView or
// compatible type.
//
// Intended to be used with a generic lambda or other functor overloaded to
// handle either LChar* or UChar*. Reduces code duplication in many cases.
// The functor should receive a pointer and length, and should return the same type
// in both branches.
//
// Callers should ensure that characters exist (i.e. the string is not null)
// first.
//
// Example:
//
//   if (string.IsNull())
//     return false;
//
//   return webf::VisitCharacters(string, [&](auto chars) {
//     bool contains_space = false;
//     for (auto ch : chars)
//       contains_space |= IsASCIISpace(ch);
//     return contains_space;
//   });
//
// This will instantiate the functor for both LChar (8-bit) and UChar (16-bit)
// automatically.
template <typename StringType, typename Functor>
decltype(auto) VisitCharacters(const StringType& string,
                               const Functor& functor) {
  if (string.Is8Bit()) {
    return functor(tcb::span<const LChar>(string.Characters8(), string.length()));
  } else {
    return functor(tcb::span<const UChar>(string.Characters16(), string.length()));
  }
}

}  // namespace webf

#endif  // WEBF_FOUNDATION_STRING_CHARACTER_VISITOR_H_