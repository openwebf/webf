/*
 * Copyright (C) 2008 Apple Inc. All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 *
 * 1.  Redistributions of source code must retain the above copyright
 *     notice, this list of conditions and the following disclaimer.
 * 2.  Redistributions in binary form must reproduce the above copyright
 *     notice, this list of conditions and the following disclaimer in the
 *     documentation and/or other materials provided with the distribution.
 * 3.  Neither the name of Apple Computer, Inc. ("Apple") nor the names of
 *     its contributors may be used to endorse or promote products derived
 *     from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY APPLE AND ITS CONTRIBUTORS "AS IS" AND ANY
 * EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL APPLE OR ITS CONTRIBUTORS BE LIABLE FOR ANY
 * DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
 * THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef WEBF_PLATFORM_WTF_TEXT_ATOMIC_STRING_HASH_H_
#define WEBF_PLATFORM_WTF_TEXT_ATOMIC_STRING_HASH_H_

#include "core/platform/hash_traits.h"
#include "bindings/qjs/atomic_string.h"

namespace webf {

using webf::AtomicString;

template <>
struct HashTraits<AtomicString> : SimpleClassHashTraits<AtomicString> {
  static unsigned GetHash(const AtomicString& key) { return key.Hash(); }

  static constexpr bool kSafeToCompareToEmptyOrDeleted = false;

  // Unlike other types, we can return a const reference for AtomicString's
  // empty value (g_null_atom).
  typedef const AtomicString& PeekOutType;

  static const AtomicString& EmptyValue() { return AtomicString::Empty(); }
  static PeekOutType Peek(const AtomicString& value) { return value; }

  static bool IsEmptyValue(const AtomicString& value) { return value.IsNull(); }
  /*
  // TODO(guopengfei)：先注释
  static bool IsDeletedValue(const AtomicString& value) {
    return HashTraits<String>::IsDeletedValue(value.string_);
  }

  static void ConstructDeletedValue(AtomicString& slot) {
    HashTraits<String>::ConstructDeletedValue(slot.string_);
  }
   */
};

}  // namespace webf

#endif  // WEBF_PLATFORM_WTF_TEXT_ATOMIC_STRING_HASH_H_