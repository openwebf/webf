/*
 * Copyright (c) 2013, Opera Software ASA. All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 * 3. Neither the name of Opera Software ASA nor the names of its
 *    contributors may be used to endorse or promote products derived
 *    from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
 * FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
 * COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
 * INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
 * STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED
 * OF THE POSSIBILITY OF SUCH DAMAGE.
 */

/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef BRIDGE_FOUNDATION_CASTING_H_
#define BRIDGE_FOUNDATION_CASTING_H_

#include <cassert>
#include <type_traits>
#include <memory>

namespace webf {

// Helpers for downcasting in a class hierarchy.
//
//   IsA<T>(x): returns true if |x| can be safely downcast to T*. Usage of this
//       should not be common; if it is paired with a call to To<T>, consider
//       using DynamicTo<T> instead (see below). Note that this also returns
//       false if |x| is nullptr.
//
//   To<T>(x): unconditionally downcasts and returns |x| as a T*.
//   Use when IsA<T>(x) is known to be true due to external invariants.
//   If |x| is nullptr, returns nullptr.
//
//   DynamicTo<T>(x): downcasts and returns |x| as a T* iff IsA<T>(x) is true,
//       and nullptr otherwise. This is useful for combining a conditional
//       branch on IsA<T>(x) and an invocation of To<T>(x), e.g.:
//           if (IsA<DerivedClass>(x))
//             To<DerivedClass>(x)->...
//       can be written:
//           if (auto* derived = DynamicTo<DerivedClass>(x))
//             derived->...;
//
// Marking downcasts as safe is done by specializing the DowncastTraits
// template:
//
// template <>
// struct DowncastTraits<DerivedClass> {
//   static bool AllowFrom(const BaseClass& b) {
//     return b.IsDerivedClass();
//   }
//   static bool AllowFrom(const AnotherBaseClass& b) {
//     return b.type() == AnotherBaseClass::kDerivedClassTag;
//   }
// };
//
// int main() {
//   BaseClass* base = CreateDerived();
//   AnotherBaseClass* another_base = CreateDerived();
//   UnrelatedClass* unrelated = CreateUnrelated();
//
//   std::cout << std::boolalpha;
//   std::cout << IsA<Derived>(base) << '\n';          // prints true
//   std::cout << IsA<Derived>(another_base) << '\n';  // prints true
//   std::cout << IsA<Derived>(unrelated) << '\n';     // prints false
// }
template <typename T>
struct DowncastTraits {
  template <typename U>
  static bool AllowFrom(const U&) {
    static_assert(sizeof(U) == 0, "no downcast traits specialization for T");
    assert(false);
    return false;
  }
};

namespace internal {

// Though redundant with the return type inferred by `auto`, the trailing return
// type is needed for SFINAE.
template <typename Derived, typename Base>
auto IsDowncastAllowedHelper(const Base& from) -> decltype(DowncastTraits<Derived>::AllowFrom(from)) {
  return DowncastTraits<Derived>::AllowFrom(from);
}

}  // namespace internal

// Returns true iff the conversion from Base to Derived is allowed. For the
// pointer overloads, returns false if the input pointer is nullptr.
template <typename Derived, typename Base>
bool IsA(const Base& from) {
  return internal::IsDowncastAllowedHelper<Derived>(from);
}

template <typename Derived, typename Base>
bool IsA(const Base* from) {
  return from && IsA<Derived>(*from);
}

template <typename Derived, typename Base>
bool IsA(Base& from) {
  return IsA<Derived>(static_cast<const Base&>(from));
}

template <typename Derived, typename Base>
bool IsA(Base* from) {
  return from && IsA<Derived>(*from);
}

// Unconditionally downcasts from Base to Derived. Internally, this asserts
// that |from| is a Derived to help catch bad casts in testing/fuzzing. For the
// pointer overloads, returns nullptr if the input pointer is nullptr.
template <typename Derived, typename Base>
const Derived& To(const Base& from) {
  return static_cast<const Derived&>(from);
}

template <typename Derived, typename Base>
const Derived* To(const Base* from) {
  return from ? &To<Derived>(*from) : nullptr;
}

template <typename Derived, typename Base>
Derived& To(Base& from) {
  return static_cast<Derived&>(from);
}
template <typename Derived, typename Base>
Derived* To(Base* from) {
  return from ? &To<Derived>(*from) : nullptr;
}

// Unconditionally downcasts from Base to Derived. Internally, this asserts
// that |from| is a Derived to help catch bad casts in testing/fuzzing. For the
// pointer overloads, returns nullptr if the input pointer is nullptr.
template <typename Derived, typename Base>
const Derived& UnsafeTo(const Base& from) {
  assert(IsA<Derived>(from));
  return static_cast<const Derived&>(from);
}

template <typename Derived, typename Base>
const Derived* UnsafeTo(const Base* from) {
  return from ? &UnsafeTo<Derived>(*from) : nullptr;
}
// Safely downcasts from Base to Derived. If |from| is not a Derived, returns
// nullptr; otherwise, downcasts from Base to Derived. For the pointer
// overloads, returns nullptr if the input pointer is nullptr.
template <typename Derived, typename Base>
const Derived* DynamicTo(const Base* from) {
  return IsA<Derived>(from) ? To<Derived>(from) : nullptr;
}

// overloads, returns nullptr if the input pointer is nullptr.
template <typename Derived, typename Base>
std::shared_ptr<const Derived> DynamicTo(const std::shared_ptr<Base> from) {
  return IsA<Derived>(from) ? To<Derived>(from) : nullptr;
}

template <typename Derived, typename Base>
const Derived* DynamicTo(const Base& from) {
  return IsA<Derived>(from) ? &To<Derived>(from) : nullptr;
}

template <typename Derived, typename Base>
Derived* DynamicTo(Base* from) {
  return IsA<Derived>(from) ? To<Derived>(from) : nullptr;
}

template <typename Derived, typename Base>
Derived* DynamicTo(Base& from) {
  return IsA<Derived>(from) ? &To<Derived>(from) : nullptr;
}

}  // namespace webf

#endif  // BRIDGE_FOUNDATION_CASTING_H_
